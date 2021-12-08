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

if [ -d ios ]
then
   echo "ios文件夹已存在"
else
   mkdir ios/
fi

cd ../
rm -rf output/android/*
rm -rf output/ios/*

react-native bundle --platform android --dev false --entry-file ZegoMart/index.js  --bundle-output output/android/bundle.jsbundle --assets-dest output/android/
react-native bundle --platform ios --dev false --entry-file ZegoMart/index.js  --bundle-output output/ios/bundle.jsbundle --assets-dest output/ios/

cd output/android
zip -r -o rn-android_$(date +%Y%m%d%H%M%S).zip bundle.jsbundle drawable-mdpi/
rm -rf bundle.jsbundle
rm -rf drawable-*

rm -rf ../../lastRelease/android/*
cp rn-android_$(date +%Y%m%d%H%M%S).zip ../../lastRelease/android/rn-android_last_release.zip

cd ../ios
zip -r -o rn-ios_$(date +%Y%m%d%H%M%S).zip bundle.jsbundle assets/
rm -rf bundle.jsbundle
rm -rf assets

rm -rf ../../lastRelease/ios/*
cp rn-ios_$(date +%Y%m%d%H%M%S).zip ../../lastRelease/ios/rn-ios_last_release.zip


echo "android ios rn 打包完成"


