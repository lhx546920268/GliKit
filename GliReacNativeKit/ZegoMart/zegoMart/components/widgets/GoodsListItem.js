import React, {Component} from 'react';
import {Image, ImageBackground, Text, TouchableOpacity, View} from 'react-native';
import {contentLightTextColor, titleTextColor} from "../../constraint/Colors";
import {discount_bg, shop_cart_add} from '../../constraint/Image'
import PropTypes from "prop-types";
import {formatMoney} from '../../utils/StringUtil';
import AddShoppingCartBtnContainer from "./AddShoppingCartBtnContainer";
import {openGoodsDetailNativePage} from "../../utils/NativeMethodUtil";
import {ImageView} from '../../widgets/ImageView'

//商品列表item  传item属性 宽度属性width
export class GoodsListItem extends Component{

    static defaultProps = {
        item: null, //GoodsModel
        width: 0,  //宽度
        addIconSize: 20, //加入购物车按钮大小
    };

    static propTypes = {
        item: PropTypes.object,
        width: PropTypes.number,
        addIconSize: PropTypes.number,
    };

    constructor(props){
        super(props)
    }

    //点击item
    _handleTouchItem(){
        openGoodsDetailNativePage(this.props.item.commonId)
    }

    render(){

        //GoodsModel
        const item = this.props.item;
        
        let originPrice = null;
        let tips = null;
        let discount = null;

        if(item.promotionType === 1){
            originPrice = <Text allowFontScaling={false} ellipsizeMode='tail' numberOfLines={1} style={{ fontSize: 12, color: contentLightTextColor, textDecorationLine: 'line-through'}}>{formatMoney(item.originalPrice)}</Text>;
            tips = <Text allowFontScaling={false} ellipsizeMode='tail' numberOfLines={1} style={{ fontSize: 12, color: '#FFC22D', bottom: 8 , position: 'absolute', left: 5}}>{item.promotionTips}</Text>;
            discount = <ImageBackground source={discount_bg} style={{position: 'absolute', flexDirection: 'row', justifyContent: 'center', left: 0, top: 0, width: 40, height: 40}}>
                <Text allowFontScaling={false} style={{fontSize: 12, textAlign: 'center', color: titleTextColor, marginTop: 5, flex: 1, transform: [{
                        rotateZ: '-45deg'
                    }]}}>{item.discountRateString()}</Text>
            </ImageBackground>
        }


        return(
            <TouchableOpacity style={[{width: this.props.width, borderRadius: 8, backgroundColor: 'white'}, this.props.style]} activeOpacity={0.7} onPress={() => this._handleTouchItem()}>
                <View style={{ borderRadius: 8, overflow: 'hidden'}}>
                    <ImageView ref="goodsImage" style={{height: this.props.width}}
                    source={{uri : item.thumbnailURL()}}/>
                    {discount}
                    <View style={{height: 113, paddingLeft: 5, paddingRight: 5, marginTop: 5}}>
                        <Text allowFontScaling={false} ellipsizeMode='tail' numberOfLines={2} style={{ fontSize: 14, color: contentLightTextColor}}>{item.goodsName}</Text>
                        <Text allowFontScaling={false} ellipsizeMode='tail' numberOfLines={1} style={{ fontSize: 18, color: titleTextColor, marginTop: 5}}>{formatMoney(item.price)}</Text>
                        {originPrice}
                        {tips}
                        <AddShoppingCartBtnContainer item={item} style={{position: 'absolute', right: 0, bottom: 0, padding: 8}}>
                            <Image style={{width: this.props.addIconSize, height: this.props.addIconSize}} source={shop_cart_add}/>
                        </AddShoppingCartBtnContainer>
                    </View>
                </View>
            </TouchableOpacity>
        )
    }
}

