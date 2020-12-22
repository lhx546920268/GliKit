//
//  GKFileManager.m
//  GliKit
//
//  Created by 罗海雄 on 2019/5/10.
//  Copyright © 2019 罗海雄. All rights reserved.
//

#import "GKFileManager.h"
#import "NSDate+GKUtils.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSString+GKUtils.h"

@implementation GKFileManager

+ (NSArray<NSString*>*)writeImages:(NSArray<UIImage*>*) images
{
    return [GKFileManager writeImages:images scale:1.0];
}

+ (NSArray<NSString*>*)writeImages:(NSArray<UIImage*>*) images scale:(float) scale
{
    return [GKFileManager writeImages:images scale:scale failImages:nil];
}

+ (NSArray<NSString*>*)writeImages:(NSArray<UIImage*>*) images scale:(float) scale failImages:(NSMutableArray<UIImage*>*) failImages
{
    scale = MIN(scale, 1.0);
    scale = MAX(scale, 0);
    
    NSString *filePath = NSTemporaryDirectory();
    NSMutableArray *files = [[NSMutableArray alloc] init];
    
    
    for(NSInteger i = 0; i < images.count; i ++){
        UIImage *image = images[i];
        NSString *fileName = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"tmpImage%@.%@", NSString.gkUUID, @"jpg"]];
        
        NSData *imageData = UIImageJPEGRepresentation(image, scale);
        
        NSError *error = nil;
        if([imageData writeToFile:fileName options:NSDataWritingAtomic error:&error]){
            [files addObject:fileName];
        }else{
#ifdef DEBUG
            NSLog(@"error = %@",error);
#endif
            [failImages addObject:image];
        }
    }
    
    return files;
}

+ (NSDictionary<NSNumber*, NSString*>*)writeImagesReturnDictionary:(NSArray<UIImage*>*) images scale:(float) scale
{
    if(images.count == 0)
        return nil;
    scale = MIN(scale, 1.0);
    scale = MAX(scale, 0);
    
    NSString *filePath = NSTemporaryDirectory();
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:images.count];
    for(NSInteger i = 0; i < images.count; i ++){
        UIImage *image = images[i];
        NSString *fileName = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"tmpImage%@.%@", NSString.gkUUID, @"jpg"]];
        
        NSData *imageData = UIImageJPEGRepresentation(image, scale);
        
        NSError *error = nil;
        if([imageData writeToFile:fileName options:NSDataWritingAtomic error:&error]){
            [dic setObject:fileName forKey:@(i)];
        }else{
#ifdef DEBUG
            NSLog(@"error = %@",error);
#endif
        }
    }
    
    return dic;
}

+ (NSString*)writeImage:(UIImage*) image scale:(float) scale
{
    scale = MIN(scale, 1.0);
    scale = MAX(scale, 0);
    
    NSString *filePath = NSTemporaryDirectory();
    
    
    NSString *fileName = [filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"tmpImage%@.%@", NSString.gkUUID, @"jpg"]];
    
    NSData *imageData = UIImageJPEGRepresentation(image, scale);
    
    NSError *error = nil;
    if([imageData writeToFile:fileName options:NSDataWritingAtomic error:&error]){
        return fileName;
    }else{
#ifdef DEBUG
        NSLog(@"error = %@",error);
#endif
    }
    
    return nil;
}

+ (void)deleteFiles:(NSArray<NSString*>*) files
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
        
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        for(NSString *file in files){
            [fileManager removeItemAtPath:file error:nil];
        }
    });
}

+ (void)deleteOneFile:(NSString*) file
{
    if(![file isKindOfClass:[NSString class]])
        return;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
        
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        [fileManager removeItemAtPath:file error:nil];
    });
}


//获取临时文件
+ (NSString*)getTemporaryFile
{
    return [GKFileManager getTemporaryFileWithSuffix:@"tmp"];
}

+ (NSString*)getTemporaryFileWithSuffix:(NSString*) suffix
{
    NSString *temp = NSTemporaryDirectory();
    NSString *file = [NSString stringWithFormat:@"%@.%@", NSString.gkUUID, suffix];
    
    return [temp stringByAppendingPathComponent:file];
}

+ (NSString*)fileNameForURL:(NSString*) url suffix:(NSString *)suffix
{
    NSString *fileName = [url gkSha256String];
    
    if(![NSString isEmpty:suffix]){
        fileName = [fileName stringByAppendingFormat:@".%@",suffix];
    }
    return fileName;
}

+ (void)moveFiles:(NSArray<NSString*>*) files withURLs:(NSArray<NSString*>*) URLs suffix:(NSString*) suffix toPath:(NSString*) path
{
    if([NSString isEmpty:path])
        return;
    dispatch_block_t block = ^(void){
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        
        for(NSInteger i = 0;i < files.count && i < URLs.count;i ++){
            NSString *file = files[i];
            NSString *url = URLs[i];
            
            NSString *toPath = [path stringByAppendingPathComponent:[GKFileManager fileNameForURL:url suffix:suffix]];
            [fileManager moveItemAtPath:file toPath:toPath error:nil];
        }
    };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), block);
}

+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    if(![[NSFileManager defaultManager] fileExistsAtPath:[URL path]])
        return NO;

    [URL setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:nil];
    
    return YES;
}

+ (NSString *)mimeTypeForFileAtPath:(NSString *)path
{
    if (![[[NSFileManager alloc] init] fileExistsAtPath:path]){
        return nil;
    }
    
    // Borrowed from http://stackoverflow.com/questions/2439020/wheres-the-iphone-mime-type-database
    
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[path pathExtension], NULL);
    
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass (UTI, kUTTagClassMIMEType);
    
    CFRelease(UTI);
    
    if (!MIMEType){
        return @"application/octet-stream";
    }
    
    return CFBridgingRelease(MIMEType);
}

+ (NSString*)formatBytes:(NSUInteger) bytes
{
    if(bytes > 1024){
        NSUInteger kb = bytes / 1024;
        if(kb > 1024){
            NSUInteger mb = kb / 1024;
            if(mb > 1024){
                NSUInteger gb = mb / 1024;
                if(gb > 1024){
                    return [NSString stringWithFormat:@"%0.2LfT", (long double)gb / 1024.0];
                }else{
                    return [NSString stringWithFormat:@"%0.2LfG", (long double)mb / 1024.0];
                }
            }
            else{
                return [NSString stringWithFormat:@"%0.2LfM", (long double)kb / 1024.0];
            }
        }
        else{
            return [NSString stringWithFormat:@"%ldK", (long)kb];
        }
    }else{
        return [NSString stringWithFormat:@"%ldB", (long)bytes];
    }
}


@end
