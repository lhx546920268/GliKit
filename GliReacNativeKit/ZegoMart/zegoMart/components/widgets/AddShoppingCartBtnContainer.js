import React, {Component} from "react";
import {findNodeHandle, TouchableOpacity, UIManager} from "react-native";
import {postEvent} from "../../utils/EventUtil";
import {EVENT_ADD_SHOPPING_CART_ANIM, EVENT_ON_ADD_SHOPPING_CART_RN} from "../../config/AppConfig";
import {isLogin, loginNative, shopcartNativeUpdate} from "../../utils/NativeMethodUtil";
import {post} from "../../utils/HttpUtils";
import PropTypes from "prop-types";

export default class AddShoppingCartBtnContainer extends Component{

    static defaultProps = {
        item: null, //商品信息 GoodsModel
    };

    static propTypes = {
        item: PropTypes.object,
    };

    startAddShoppingCartAnim(){
        let imagePosition = {};
        UIManager.measure(findNodeHandle(this.container), (x, y, width, height, pageX, pageY) => {
            imagePosition = {x, y, width, height, pageX, pageY};
            postEvent(EVENT_ADD_SHOPPING_CART_ANIM,({image:this.getImageView(),position: imagePosition}))
        });
    }

    getImageView(){
        return this.props.children
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
            buyData: JSON.stringify([{
                buyNum: 1,
                goodsId: this.props.item.goodsId
            }])
        }, true, true, 500).then(() => {

            this.startAddShoppingCartAnim();
            postEvent(EVENT_ON_ADD_SHOPPING_CART_RN);
            shopcartNativeUpdate();
        }, () => {

        });
    }

    render(): React.ReactNode {
        let {style} = this.props;
        return <TouchableOpacity style={style?style:{alignSelf: 'flex-end'}}
                                 activeOpacity={0.7}
                                 onPress={()=>{
                                     this._handleShopCartAdd();
                                 }}
                                 ref={f=>this.container=f}>
            {this.props.children}
        </TouchableOpacity>
    }
}