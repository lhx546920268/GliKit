import {isEmpty} from "../utils/StringUtil";
import {AdModel} from "./AdModel";
import {GoodsModel} from "./GoodsModel";
import {SCREEN_WIDTH} from "../utils/AppUtil";

export const AD_TYPE_NOT_KNOW = 0; //图片广告 无法识别的类型
export const AD_TYPE_IMAGE = 1; //图片广告 行高度一致的
export const AD_TYPE_BANNER = 2; //轮播图
export const AD_TYPE_IMAGE_LEFT_1 = 3; //图片广告 左边1个 右边2个
export const AD_TYPE_IMAGE_LEFT_2 = 4; //图片广告 左边2个 右边1个
export const AD_TYPE_IMAGE_GOODS = 5; //商品
export const AD_TYPE_IMAGE_RIGHT_2 = 6; //图片广告 左边1张 右边2个

//获取section广告 如果广告类型无法识别 返回null
export function adModelFromObject(obj) {

    let str = obj.itemType;
    let adType = AD_TYPE_NOT_KNOW;
    let index = 0;
    if(!isEmpty(str)){
        switch (str) {
            case "ad" : {
                adType = AD_TYPE_BANNER;
            }
            break;
            case "goods" : {
                adType = AD_TYPE_IMAGE_GOODS;
            }
            break;
            default : {
                if(str.search("home") !== -1 && str.length > 4){
                    index = parseInt(str.slice(4, str.length));
                    if(index > 0 && index < 10){
                        switch (index) {
                            case 2 : {
                                adType = AD_TYPE_IMAGE_LEFT_1;
                            }
                            break;
                            case 4 : {
                                adType = AD_TYPE_IMAGE_LEFT_2;
                            }
                            break;
                            case 9 : {
                                adType = AD_TYPE_IMAGE_RIGHT_2;
                            }
                            break;
                            default : {
                                adType = AD_TYPE_IMAGE;
                            }
                            break;
                        }
                    }
                }
            }
        }
    }

    if(adType !== AD_TYPE_NOT_KNOW){
        try {
            let array = JSON.parse(obj.itemData);
            let model = new AdSectionModel();
            model.adType = adType;
            model.parseData(array, index);
            return model;
        }catch {
            return null;
        }
    }

    return null;
}

//每个区域的广告信息
export class AdSectionModel {

    constructor(){
        this.models = [];
        this.numColumns = 1;
    }
    //解析数据
    parseData(array, index){

        if(this.adType === AD_TYPE_IMAGE_GOODS){
            this.numColumns = 2;
            for(let i = 0;i < array.length;i ++){
                this.models.push(new GoodsModel(array[i]));
            }
        }else {
            for(let i = 0;i < array.length;i ++){
                let model = new AdModel(array[i]);
                let width = 0;
                let height = 0;
                switch (this.adType) {
                    case AD_TYPE_IMAGE : {
                        switch (index) {
                            case 1 : {
                                //单张图片
                                width = SCREEN_WIDTH;
                                height = Math.floor(SCREEN_WIDTH * (260.0 / 640.0));
                            }
                            break;
                            case 3 : {
                                this.numColumns = 2;
                                //添加多张宽高一致的图片左右排列，用于商品活动推荐类小广告图使用。建议图片尺寸：320*180像素。
                                width = SCREEN_WIDTH / 2.0;
                                height = Math.floor(width * (180.0 / 320.0));
                            }
                            break;
                            case 5 : {
                                this.numColumns = 3;
                                //添加三张宽高一致的图片单行排列，用于商品活动推荐类小广告图使用。建议图片尺寸：213*260像素
                                width = Math.floor(SCREEN_WIDTH / 3.0);
                                height = Math.floor(width * (260.0 / 213.0));
                                if(i % 3 === 2){
                                    width = SCREEN_WIDTH - width * 2;
                                }
                            }
                            break;
                            case 6 : {
                                this.numColumns = 4;
                                //添加四张宽高同比一致的正方形图片单行排列，可用户应用模块快速链接使用
                                width = Math.floor(SCREEN_WIDTH / 4.0);
                                height = Math.floor(SCREEN_WIDTH / 4.0);
                                if(i % 4 === 3){
                                    width = SCREEN_WIDTH - width * 3;
                                }
                            }
                            break;
                            case 7 : {
                                //添加单条图片用于模块之间的空白间隔或模块标题图使用。建议图片尺寸：640*80像素。
                                width = SCREEN_WIDTH;
                                height = Math.floor(SCREEN_WIDTH * (80.0 / 640.0));
                            }
                                break;
                            case 8 : {
                                //添加五张宽高同比一致的正方形图片单行排列，可用户应用模块快速链接使用，例如：我的商城、分类导航等功能。建议图片尺寸：128*128像素。
                                width = Math.floor(SCREEN_WIDTH / 5.0);
                                this.numColumns = 5;
                                height = Math.floor(SCREEN_WIDTH / 5.0);
                                if(i % 5 === 4){
                                    width = SCREEN_WIDTH - width * 4;
                                }
                            }
                                break;
                            case 10 : {
                                //添加四张宽高一致的图片单行排列，用于商品活动推荐类小广告图使用。建议图片尺寸：160*210像素。
                                this.numColumns = 4;
                                width = Math.floor(SCREEN_WIDTH / 4.0);
                                height = Math.floor(width * (210.0 / 160.0));
                                if(i % 4 === 3){
                                    width = SCREEN_WIDTH - width * 3;
                                }
                            }
                                break;
                        }
                    }
                    break;
                    case AD_TYPE_IMAGE_LEFT_1 : {
                        //模块布局为左侧一张大图，右侧两张小图形式，图片添加修改顺序依次为左侧大图 > 右侧小图上 > 右侧小图下。建议图片尺寸：大图320*260像素；小图320*130像素。
                        width = SCREEN_WIDTH / 2.0;
                        height = Math.floor(width * (260.0 / 320.0));
                        if(i % 3 !== 0){
                            height = height / 2.0;
                        }
                    }
                    break;
                    case AD_TYPE_IMAGE_LEFT_2 : {
                        //模块布局为左侧两张小图，右侧一张大图形式，图片添加修改顺序依次为左侧小图上 > 左侧小图下 > 右侧大图。建议图片尺寸：小图320*130像素；大图320*260像素。
                        width = SCREEN_WIDTH / 2.0;
                        height = Math.floor(width * (260 / 320.0));
                        if(i % 3 !== 2){
                            height = height / 2.0;
                        }
                    }
                    break;
                    case AD_TYPE_IMAGE_RIGHT_2 : {
                        // 3张图片，左侧1张大图320×210，右侧2张小图160×210
                        width = SCREEN_WIDTH / 2.0;
                        height = Math.floor(width * (210.0 / 320.0));
                        if(i % 3 !== 0){
                            height = height / 2.0;
                        }
                    }
                    break;
                }

                model.width = width;
                model.height = height;
                this.models.push(model);
            }
        }

        //构建data
        if(this.adType !== AD_TYPE_IMAGE_GOODS && index !== 3){
            this.data = [this.models];
        }else {
            this.data = [];
            for(let i = 0;i < this.models.length;i += 2){
                let array = [];
                array.push(this.models[i]);
                if(i + 1 < this.models.length){
                    array.push(this.models[i + 1]);
                }
                this.data.push(array);
            }
        }
    }
}