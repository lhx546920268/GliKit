//商品信息
import {isEmpty} from "../utils/StringUtil";

export class GoodsModel{

    constructor(obj){

         this.goodsId = obj.goodsId; //商品对应的规格商品id
         let specs = obj.goodsSpecList;
         if(specs != null && (typeof specs === "object") && specs.length > 0){
             this.goodsId = specs[0].goodsId;
         }

         this.commonId = obj.commonId; //商品id
         this.goodsName = obj.goodsName; //商品名称
         this.imageURL = obj.imageSrc; //商品图片
         if (isEmpty(this.imageURL)) {
             this.imageURL = obj.imageUrl;
         }

         this.storage = obj.goodsStorage; //库存
         this.limitStorage = obj.limitTotalStorage; //限购库存
         this.promotionTips = obj.promotionTypeText; //促销提示语

         //当前要显示的价格
         let price = obj.appPriceMin;
         if(!price){
             price = obj.appPrice0;
         }
         if (!price) {
             price = obj.goodsPrice;
         }

         this.promotionType = 0;

         //批发商品没有促销
         if (obj.goodsModal !== 2){
             //1 限时折扣，2 全款预售 3 定金预售
             this.promotionType = obj.promotionType;
             if(this.promotionType === 1){

                 //判断app是否可用
                 //判断是否有折扣活动
                 let discount = obj.discount;
                 if (discount != null && typeof discount === 'object' && obj.app === 1){

                     if (discount.promotionCountDownTime > 0){
                         //拿外面的折扣率，因为秒杀活动可以为每个商品设置折扣率，discount返回的是全局的折扣率
                         this.discountRate = obj.promotionDiscountRate;
                         if(this.discountRate === undefined || this.discountRate === null){
                             this.discountRate = discount.discountRate;
                         }

                         //限时折扣还没开始， 折扣价格要自己计算
                         if (discount.promotionCountDownTimeText === '距开始'){

                         }else{
                             this.originalPrice = price * 10 / this.discountRate;
                         }
                     }else{
                         this.promotionType = 0;
                     }
                 }else{
                     //有些地方没有 discount 字段
                     if (obj.promotionState !== null && obj.promotionState !== undefined){
                         if (obj.promotionState === 1 && obj.goodsPrice0 !== undefined && obj.goodsPrice0 > 0){
                             this.originalPrice = obj.goodsPrice0;
                         }else{
                             this.promotionType = 0;
                         }
                     }else{
                         if(obj.goodsPrice0 !== undefined && obj.goodsPrice0 > 0){
                             this.originalPrice = obj.goodsPrice0;
                         }else {
                             this.promotionType = 0;
                         }
                     }
                 }
             }
         }

         if(this.promotionType === 1){
             if (this.promotionTips == null || this.promotionTips.length === 0) {
                 this.promotionTips = "Flash Sales";
             }
         }else {
             this.promotionTips = "";
         }

         this.price = price;
    }

    //获取商品图片缩略图
    thumbnailURL(){
        return this.imageURL + '@200w_200h';
    }

    //获取折扣率字符串
    discountRateString(){
        if(this.promotionType === 1){
            return "-" + Math.floor(100 - this.discountRate * 10) + "%";
        }
        return "";
    }
}
