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

if [ -d android/gameRecharge ]
then
echo "android/gameRecharge文件夹已存在"
else
mkdir android/gameRecharge
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

if [ -d ios/gameRecharge ]
then
echo "ios/gameRecharge文件夹已存在"
else
mkdir ios/gameRecharge
fi

cd ../

rm -rf output/android/basic/*
rm -rf output/android/gameRecharge/*
rm -rf output/ios/basic/*
rm -rf output/ios/gameRecharge/*


react-native bundle --platform ios --dev false --entry-file basics.js  --bundle-output output/ios/basic/bundle.jsbundle --assets-dest output/ios/basic/ --config basics_config.js
echo "ios 基础打包完成"
react-native bundle --platform ios --dev false --entry-file gameRecharge/index.js  --bundle-output output/ios/gameRecharge/bundle.jsbundle --assets-dest output/ios/gameRecharge/ --config business_config.js
echo "ios 业务打包完成"

react-native bundle --platform android --dev false --entry-file basics.js --bundle-output output/android/basic/bundle.jsbundle --assets-dest output/android/basic/ --config basics_config.js
echo "android 基础打包完成"

react-native bundle --platform android --dev false --entry-file gameRecharge/index.js --bundle-output output/android/gameRecharge/bundle.jsbundle --assets-dest output/android/gameRecharge/ --config business_config.js
echo "android 业务打包完成"

cd output/ios/gameRecharge

#rm -rf assets/node_modules
zip -r -o rn-ios_$(date +%Y%m%d%H%M%S).zip bundle.jsbundle assets/
rm -rf bundle.jsbundle
rm -rf assets

rm -rf ../../../lastRelease/ios/*
cp rn-ios_$(date +%Y%m%d%H%M%S).zip ../../../lastRelease/ios/rn-ios_last_release.zip

cd ../../android/gameRecharge

zip -r -o rn-android_$(date +%Y%m%d%H%M%S).zip bundle.jsbundle drawable-mdpi/
rm -rf bundle.jsbundle
rm -rf drawable-*

rm -rf ../../../lastRelease/android/*
cp rn-android_$(date +%Y%m%d%H%M%S).zip ../../../lastRelease/android/rn-android_last_release.zip





echo "android ios rn 打包完成"


