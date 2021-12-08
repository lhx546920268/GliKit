//广告信息
import {isEmpty} from "../utils/StringUtil";
import {isLogin, loginNative, shopcartNativeUpdate} from "../utils/NativeMethodUtil";
import {postEvent} from "../utils/EventUtil";
import {EVENT_ADD_SHOPPING_CART_ANIM, EVENT_ON_ADD_SHOPPING_CART_RN} from "../config/AppConfig";
import {findNodeHandle, UIManager} from 'react-native';
import {post} from "../utils/HttpUtils";

export class AdModel {

    constructor(obj){

        //width height 宽高

        this.imageURL = obj.imageUrl; //图片链接
        this.data = obj.data; //广告关联的数据
        this.type = obj.type; //广告类型
    }

    //打开
    open(navigation){
        if(!isEmpty(this.data)){
            switch (this.type) {
                case "storeKeyword" : {
                    navigation.navigate('GoodsList', {
                        'searchKey': this.data
                    })
                }
                    break;
                case "goods" : {
                    this._handleShopCartAdd();
                }
                    break;
                case "storeSpecial" : {
                    navigation.navigate("Special", {
                        specialId: this.data,
                    });
                }
                    break;
            }
        }
    }

    //点击加入购物车
    _handleShopCartAdd(){
        if(isLogin()){
            this._handleShopCartAddAfterLogin();
        }else {
            loginNative(() => {
                this._handleShopCartAddAfterLogin();
            })
        }
    }
    //登录成功后
    _handleShopCartAddAfterLogin(){

        post("cart/add", {
            commonId: this.data,
            buyData: JSON.stringify([{
                buyNum: 1,
            }])
        }, true, true, 500).then(() => {

            let imagePosition = {};
            UIManager.measure(findNodeHandle(this.ref), (x, y, width, height, pageX, pageY) => {


                pageX += width / 2;
                pageY += height / 2;
                imagePosition = {x, y, width, height, pageX, pageY};
                postEvent(EVENT_ADD_SHOPPING_CART_ANIM,({position: imagePosition}))
            });
            postEvent(EVENT_ON_ADD_SHOPPING_CART_RN);
            shopcartNativeUpdate();
        }, () => {

        });
    }
}