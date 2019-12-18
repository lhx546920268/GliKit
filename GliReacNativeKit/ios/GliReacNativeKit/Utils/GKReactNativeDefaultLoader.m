//
//  GKReactNativeDefaultLoader.m
//  GliReacNativeKit
//
//  Created by 罗海雄 on 2019/12/18.
//  Copyright © 2019 luohaixiong. All rights reserved.
//

#import "GKReactNativeDefaultLoader.h"
#import <SSZipArchive.h>
#import <GKFileManager.h>
#import "GKReactNativeVersionModel.h"
#import <GKHttpSessionManager.h>
#import <NSString+GKUtils.h>
#import <GKBaseDefines.h>
#import <SDWebImageDefine.h>

@interface GKReactNativeDefaultLoader ()

///版本关键字
@property(nonatomic, readonly) NSString *versionKey;

///加载完成回调
@property(nonatomic, copy) GKLoadReactNativeCompletionHandler completionHandler;

///当前下载任务
@property(nonatomic, weak) NSURLSessionTask *downloadTask;

///当前版本信息
@property(nonatomic, strong) GKReactNativeVersionModel *versionModel;

@end

@implementation GKReactNativeDefaultLoader

@synthesize moduleName = _moduleName;

- (instancetype)initWithModuleName:(NSString*) moduleName
{
    self = [super init];
    if (self) {
        _moduleName = [moduleName copy];
    }
    return self;
}

- (void)dealloc
{
    [self.downloadTask cancel];
}

- (void)loadReactNativeFileWithCompletionHandler:(GKLoadReactNativeCompletionHandler)handler
{
    self.completionHandler = handler;
    [self detectVersion];
}

- (NSString *)jsBundleName
{
    if(!_jsBundleName){
        return _jsBundleName;
    }
    return @"bundle.jsbundle";
}

// MARK: - api

///检查版本
- (void)detectVersion
{
    
}

///检查版本完成
- (void)onDetectVersion:(GKReactNativeVersionModel*) model
{
    if(model){
        if(model.available){
            NSString *version = [self reactNativeVersion];
            self.versionModel = model;
            
            //版本不相同 重新下载
            if(![version isEqualToString:model.reactNativeVersion]){
                
                [self downloadReactNative];
            }else{
                NSString *bundlePath = [self reactNativeBundlePath];
                //文件不存在
                if(![[NSFileManager defaultManager] fileExistsAtPath:bundlePath]){
                    
                    //压缩包不存在
                    NSString *zipPath = [self reactNativeZipPath];
                    if([[NSFileManager defaultManager] fileExistsAtPath:zipPath]){
                        [self unpackZip];
                    }else{
                        [self downloadReactNative];
                    }
                }else{
                    !self.completionHandler ?: self.completionHandler([NSURL fileURLWithPath:bundlePath], self.moduleName, model);
                }
            }
        }else{
            !self.completionHandler ?: self.completionHandler(nil, self.moduleName, model);
        }
    }else{
        [self onError];
    }
}

///下载rn包
- (void)downloadReactNative
{
    if([NSString isEmpty:self.versionModel.reactNativeDownloadURL]){
        [self onError];
    }else{
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.versionModel.reactNativeDownloadURL]];
        request.timeoutInterval = 15;
        
        WeakObj(self)
        NSURLSessionDownloadTask *task = [[GKHttpSessionManager sharedManager] downloadTaskWithRequest:request progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            
            return [selfWeak getDestination];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            
            [selfWeak onDownloadWithFilePath:filePath error:error];
        }];
        self.downloadTask = task;
        [task resume];
    }
}

///获取下载后的文件路径
- (NSURL*)getDestination
{
    NSString *zipPath = [self reactNativeZipPath];
    //删除旧的
    if([[NSFileManager defaultManager] fileExistsAtPath:zipPath]){
        [[NSFileManager defaultManager] removeItemAtPath:zipPath error:nil];
    }
    
    return [NSURL fileURLWithPath:zipPath];
}

///下载完成
- (void)onDownloadWithFilePath:(NSURL*) filePath error:(NSError*) error
{
    dispatch_main_async_safe(^{
        
        if(error){
            [self onError];
        }else{
            //标记iCloud不备份
            [GKFileManager addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[self reactNativeDirectory]]];
            [self saveReactNativeVersion:self.versionModel.reactNativeVersion];
            [self unpackZip];
        }
    })
}

///加载失败 使用本地的
- (void)onError
{
    //文件不存在
    NSString *filePath = [self reactNativeBundlePath];
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        
        //压缩包不存在
        NSString *zipPath = [self reactNativeZipPath];
        if([[NSFileManager defaultManager] fileExistsAtPath:zipPath]){
            [self unpackZip];
        }else{
            
        }
    }else{
        !self.completionHandler ?: self.completionHandler([NSURL fileURLWithPath:filePath], self.moduleName, nil);
    }
}

///解压
- (void)unpackZip
{
    WeakObj(self)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *bundlePath = [selfWeak reactNativeBundlePath];
        NSString *tempUnZipPath = [selfWeak reactNativeTemporaryUnZipDirectory];
        NSString *zipPath = [selfWeak reactNativeZipPath];
        NSString *assetsPath = [selfWeak reactNativeAssetsPath];
        
        BOOL result = [SSZipArchive unzipFileAtPath:zipPath toDestination:tempUnZipPath];
        
        NSError *error = nil;
        if(result){
            //解压成功
            
            //把 js移到对应文件夹
            if([NSFileManager.defaultManager fileExistsAtPath:bundlePath]){
                [NSFileManager.defaultManager removeItemAtPath:bundlePath error:&error];
            }
            
            if(!error){
                [NSFileManager.defaultManager moveItemAtPath:[tempUnZipPath stringByAppendingPathComponent:self.jsBundleName] toPath:bundlePath error:&error];
            }
            
            if(!error){
                
                //把图片资源文件移到assets
                NSString *tempAssetsPath = [tempUnZipPath stringByAppendingPathComponent:@"assets"];
                
                NSArray *subPaths = [NSFileManager.defaultManager contentsOfDirectoryAtPath:tempAssetsPath error:&error];
                if(!error){
                    for(NSString *subPath in subPaths){
                        NSString *destPath = [assetsPath stringByAppendingPathComponent:subPath];
                        if([NSFileManager.defaultManager fileExistsAtPath:destPath]){
                            [NSFileManager.defaultManager removeItemAtPath:destPath error:&error];
                        }
                        if(error){
                            break;
                        }
                        
                        [NSFileManager.defaultManager moveItemAtPath:[tempAssetsPath stringByAppendingPathComponent:subPath] toPath:destPath error:&error];
                        
                        if(error){
                            break;
                        }
                    }
                }
            }
        }
        
        if(error){
            result = NO;
            //文件操作发生错误，删除文件
            [NSFileManager.defaultManager removeItemAtPath:zipPath error:nil];
            [NSFileManager.defaultManager removeItemAtPath:bundlePath error:nil];
        }
        
        //删除临时解压文件
        [NSFileManager.defaultManager removeItemAtPath:tempUnZipPath error:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            !selfWeak.completionHandler ?: selfWeak.completionHandler(result ? [NSURL fileURLWithPath:bundlePath] : nil, selfWeak.moduleName, nil);
        });
    });
}

// MARK: - key

- (NSString *)versionKey
{
    return [NSString stringWithFormat:@"%@_reactNative_version", self.moduleName];
}

///获取本地rn版本
- (NSString*)reactNativeVersion
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:self.versionKey];
}

///保存rn版本
- (void)saveReactNativeVersion:(NSString*) version
{
    [[NSUserDefaults standardUserDefaults] setObject:version forKey:self.versionKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

///rn保存在本地的文件夹
- (NSString*)reactNativeDirectory
{
    return [GKReactNativeDefaultLoader reactNativeDirectory];
}

///rn本地bundle路径
- (NSString*)reactNativeBundlePath
{
    return [GKReactNativeDefaultLoader reactNativeBundlePathForModuleName:self.moduleName];
}

///rn本地zip路径
- (NSString*)reactNativeZipPath
{
    NSString *filePath = [[self reactNativeDirectory] stringByAppendingPathComponent:@"rnZip"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", self.moduleName]];
}

///临时解压路径
- (NSString*)reactNativeTemporaryUnZipDirectory
{
    NSString *filePath = [[self reactNativeDirectory] stringByAppendingPathComponent:@"rnUpZip"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return filePath;
}

///资源路径
- (NSString*)reactNativeAssetsPath
{
    NSString *filePath = [[self reactNativeDirectory] stringByAppendingPathComponent:@"assets"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return filePath;
}

+ (NSString*)reactNativeDirectory
{
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *filePath = [documentPath stringByAppendingPathComponent:@"ReactNative"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return filePath;
}

+ (NSString *)reactNativeBundlePathForModuleName:(NSString *)moduleName
{
    NSString *bundleDir = [[GKReactNativeDefaultLoader reactNativeDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"rnBundle"]];
    if(![[NSFileManager defaultManager] fileExistsAtPath:bundleDir]){
        [[NSFileManager defaultManager] createDirectoryAtPath:bundleDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [bundleDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jsbundle", moduleName]];
}


@end
