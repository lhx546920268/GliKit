#!/bin/bash
cd ./mobileRechargeRes/
function syncImage(){
    cat /dev/null > ../mobileRecharge/res/Image.js
    echo "/**********************************************/" >> ../mobileRecharge/res/Image.js
    echo "/* 此处文件由脚本 build_image.sh 生成,请勿手动更改*/">> ../mobileRecharge/res/Image.js
    echo "/**********************************************/">> ../mobileRecharge/res/Image.js
    for element in `ls`
    do
        if [ -f $element ]
        then
            echo "export const ${element%.*} = require('../../mobileRechargeRes/$element');" >> ../mobileRecharge/res/Image.js
        fi
    done
    echo '所有图片都已经写入Image.js'
}

syncImage
