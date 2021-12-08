#!/bin/bash
cd ./zegoMartRes/
function syncImage(){
    cat /dev/null > ../zegoMart/constraint/Image.js
    echo "/**********************************************/" >> ../zegoMart/constraint/Image.js
    echo "/* 此处文件由脚本 build_image.sh 生成,请勿手动更改*/">> ../zegoMart/constraint/Image.js
    echo "/**********************************************/">> ../zegoMart/constraint/Image.js
    for element in `ls`
    do
        if [ -f $element ]
        then
            echo "export const ${element%.*} = require('../../zegoMartRes/$element');" >> ../zegoMart/constraint/Image.js
        fi
    done
    echo '所有图片都已经写入Image.js'
}

syncImage
