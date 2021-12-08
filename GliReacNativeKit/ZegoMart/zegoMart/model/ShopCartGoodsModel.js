import {GoodsModel} from "./GoodsModel";

//购物车商品信息
export class ShopCartGoodsModel extends GoodsModel{

    constructor(obj){
        super(obj);
        
        this.cartId = obj.cartId; //购物车id
        this.specValues = obj.goodsFullSpecs; //规格值
        this.buyCount = obj.buyNum; //购买数量
        this.selected = true; //默认选中
    }

    //是否可以购买
    buyEnable(){
        return this.storage > 0 && this.selected;
    }
}