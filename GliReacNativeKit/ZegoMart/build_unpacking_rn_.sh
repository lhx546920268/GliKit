#!/bin/bash

if [ -d output ]
then
   echo "output文件夹已存在"
else
   mkdir output/
fi

cd output

if [ -d android ]
then
   echo "android文件夹已存在"
else
   mkdir android/
fi

if [ -d android/basic ]
then
echo "android/basic文件夹已存在"
else
mkdir android/basic
fi

if [ -d android/zegoMart ]
then
echo "android/zegoMart文件夹已存在"
else
mkdir android/zegoMart
fi

if [ -d ios ]
then
   echo "ios文件夹已存在"
else
   mkdir ios/
fi

if [ -d ios/basic ]
then
echo "ios/basic文件夹已存在"
else
mkdir ios/basic
fi

if [ -d ios/zegoMart ]
then
echo "ios/zegoMart文件夹已存在"
else
mkdir ios/zegoMart
fi

cd ../

rm -rf output/android/basic/*
rm -rf output/android/zegoMart/*
rm -rf output/ios/basic/*
rm -rf output/ios/zegoMart/*


react-native bundle --platform ios --dev false --entry-file basics.js  --bundle-output output/ios/basic/bundle.jsbundle --assets-dest output/ios/basic/ --config basics_config.js
echo "ios 基础打包完成"
react-native bundle --platform ios --dev false --entry-file zegoMart/index.js  --bundle-output output/ios/zegoMart/bundle.jsbundle --assets-dest output/ios/zegoMart/ --config business_config.js
echo "ios 业务打包完成"

react-native bundle --platform android --dev false --entry-file basics.js --bundle-output output/android/basic/bundle.jsbundle --assets-dest output/android/basic/ --config basics_config.js
echo "android 基础打包完成"

react-native bundle --platform android --dev false --entry-file zegoMart/index.js --bundle-output output/android/zegoMart/bundle.jsbundle --assets-dest output/android/zegoMart/ --config business_config.js
echo "android 业务打包完成"

cd output/ios/zegoMart

rm -rf assets/node_modules
zip -r -o rn-ios_$(date +%Y%m%d%H%M%S).zip bundle.jsbundle assets/
rm -rf bundle.jsbundle
rm -rf assets

rm -rf ../../../lastRelease/ios/*
cp rn-ios_$(date +%Y%m%d%H%M%S).zip ../../../lastRelease/ios/rn-ios_last_release.zip

cd ../../android/zegoMart

zip -r -o rn-android_$(date +%Y%m%d%H%M%S).zip bundle.jsbundle drawable-mdpi/
rm -rf bundle.jsbundle
rm -rf drawable-*

rm -rf ../../../lastRelease/android/*
cp rn-android_$(date +%Y%m%d%H%M%S).zip ../../../lastRelease/android/rn-android_last_release.zip





echo "android ios rn 打包完成"


