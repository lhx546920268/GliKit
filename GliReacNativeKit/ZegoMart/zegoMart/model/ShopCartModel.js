import {FullPreferentialModel} from "./FullPreferentialModel";
import {ShopCartGoodsModel} from "./ShopCartGoodsModel";

//购物车信息
export class ShopCartModel {

    constructor(obj){
        this.goodsModels = null; //购物车商品信息
        this.fullPreferentialModels = null; //店铺满优惠信息

        let stores = obj.cartStoreVoList;
        if(stores != null && stores.length > 0){
            let store = stores[0];
            let conformList = store.conformList;

            if(conformList != null && conformList.length > 0){
                this.fullPreferentialModels = [];
                for(let i = 0;i < conformList.length;i ++){
                    this.fullPreferentialModels[i] = new FullPreferentialModel(conformList[i]);
                }
            }

            this.goodsModels = [];
            let cartSpuVoList = store.cartSpuVoList;
            if(cartSpuVoList != null && cartSpuVoList.length > 0){
                for(let i = 0;i < cartSpuVoList.length;i ++){
                    let cartItemVoList = cartSpuVoList[i].cartItemVoList;
                    if(cartItemVoList != null && cartItemVoList.length > 0){
                        for(let j = 0;j < cartItemVoList.length;j ++){
                            this.goodsModels.push(new ShopCartGoodsModel(cartItemVoList[j]));
                        }
                    }
                }
            }
        }
    }

    //购物车数量
    getShopCartCount(){
        if(this.goodsModels != null && this.goodsModels.length > 0){
            let totalCount = 0;
            for(let i = 0;i < this.goodsModels.length;i ++){
                totalCount += this.goodsModels[i].buyCount;
            }

            return totalCount;
        }
        return 0;
    }

    //获取购物车总价
    getTotalPrice(){
        let totalPrice = 0;
        if(this.goodsModels != null){
            for(let i = 0;i < this.goodsModels.length;i ++){
                let model = this.goodsModels[i];
                if(model.buyEnable()){
                    totalPrice += model.price * model.buyCount;
                }
            }
        }

        return totalPrice;
    }

    //获取当前合适的满优惠金额
    getPromotionPrice(totalPrice){
        let price = 0; //获取满足条件最大的金额
        if(totalPrice > 0 && this.fullPreferentialModels && this.fullPreferentialModels.length > 0){
            for(let i = 0;i < this.fullPreferentialModels.length;i ++){
                let model = this.fullPreferentialModels[i];
                if(totalPrice > model.leastAmount && model.preferentialAmount > price){
                    price = model.preferentialAmount;
                }
            }
        }
        return price;
    }

    //获取更多优惠
    getDifferFullPreferentialModel(totalPrice, promotionPrice){
        let moreModel = null;
        if(totalPrice > 0 && this.fullPreferentialModels && this.fullPreferentialModels.length > 0){
            for(let i = 0;i < this.fullPreferentialModels.length;i ++){
                let model = this.fullPreferentialModels[i];
                if(totalPrice < model.leastAmount && model.preferentialAmount > promotionPrice){
                    if(moreModel && model.leastAmount > moreModel.leastAmount){
                        continue;
                    }
                    moreModel = model;
                }
            }
        }
        return moreModel;
    }

    //是否可以购买
    buyEnable(){
        if(this.goodsModels && this.goodsModels.length > 0){
            for(let i = 0;i < this.goodsModels.length;i ++){
                let model = this.goodsModels[i];
                if(model.selected){
                    return true;
                }
            }
        }
        return false;
    }

    //是否全选
    isSelectAll(){
        let selected = false;
        if(this.goodsModels != null){
            selected = true;
            for(let i = 0;i < this.goodsModels.length;i ++){
                let model = this.goodsModels[i];
                if(!model.selected){
                    selected = false;
                    break;
                }
            }
        }
        return selected;
    }

    //设置全选
    setSelectAll(selectAll){
        if(this.goodsModels != null){
            for(let i = 0;i < this.goodsModels.length;i ++){
                let model = this.goodsModels[i];
                model.selected = selectAll;
            }
        }
    }
}