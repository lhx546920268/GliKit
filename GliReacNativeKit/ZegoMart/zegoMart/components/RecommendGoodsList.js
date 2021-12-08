import {SCREEN_WIDTH} from "../utils/AppUtil";
import {FlatList, Image, ImageBackground, Text, TouchableOpacity, View} from "react-native";
import {CommonStyles} from "../constraint/Styles";
import {contentLightTextColor, priceColor, titleTextColor} from "../constraint/Colors";
import {formatMoney} from "../utils/StringUtil";
import AddShoppingCartBtnContainer from "./widgets/AddShoppingCartBtnContainer";
import {discount_bg, shop_cart_add} from "../constraint/Image";
import React, {Component} from "react";
import {openGoodsDetailNativePage} from "../utils/NativeMethodUtil";
import PropTypes from "prop-types";
import {ImageView} from "../widgets/ImageView";

export default class RecommendGoodsList extends Component {
    constructor(props) {
        super(props);

        this.state = {
            // isLoading:true,
            goodsList: props.goodsList,
        }
    }

    static defaultProps = {
        goodsList:[],
    };

    static propTypes = {
        goodsList: PropTypes.array,
    };

    _getGoodsListContent(){

        let imageSize = (SCREEN_WIDTH - 55) / 3.5;
        let viewSize = (SCREEN_WIDTH - 20) / 3.5;
        let viewHeight = '100%';
        // let viewHeight = viewSize * 1.75;

        return <View style={{flex:1,height:viewHeight}}><FlatList
            data={this.state.goodsList}
            horizontal={true}
            showsHorizontalScrollIndicator={false}
            keyExtractor={(item, index) => index.toString()}
            renderItem={({item, index}) => this._getGoodsItem(item, index,imageSize,viewSize)}/>
        </View>
    }

    /**
     * 获取商品item
     * @private
     */
    _getGoodsItem(item, index,imageSize,viewSize) {
        // console.log(item);
        let {imageURL,goodsName,price,commonId} = item;
        let originPrice = null;
        let discount = null;

        if(item.promotionType === 1 && item.originalPrice > item.price){
            originPrice = <Text allowFontScaling={false} ellipsizeMode='tail' numberOfLines={1} style={{ fontSize: 12, color: contentLightTextColor, textDecorationLine: 'line-through'}}>{formatMoney(item.originalPrice)}</Text>;
            discount = <ImageBackground source={discount_bg} style={{position: 'absolute', flexDirection: 'row', justifyContent: 'center', left: 5, top: 5, width: 40, height: 40}}>
                <Text allowFontScaling={false} style={{fontSize: 12, textAlign: 'center', color: titleTextColor, marginTop: 5, flex: 1, transform: [{
                        rotateZ: '-45deg'
                    }]}}>{item.discountRateString()}</Text>
            </ImageBackground>
        }

        return <TouchableOpacity style={[{backgroundColor: 'white',width: viewSize, margin: 3,}, CommonStyles.shadow]}
                                 activeOpacity={0.7}
                                 onPress={()=>openGoodsDetailNativePage(commonId)}>
            <ImageView style={{width: imageSize, height: imageSize, marginLeft: 5, marginRight: 5, marginTop: 5}}
                   source={{uri: imageURL}}/>
            {discount}
            <Text allowFontScaling={false} numberOfLines={2} style={{color: '#999999', fontSize: 12,marginTop:5, marginLeft: 5, marginRight: 5}}>{goodsName}</Text>
            <Text allowFontScaling={false} style={{color: priceColor, fontSize: 14, marginTop: 4, fontWeight: 'bold', marginLeft: 5, marginRight: 5}}>{formatMoney(price)}</Text>
            <View style={{flex: 1,flexDirection: 'row'}}>

                <View style={{flex:1, marginLeft: 5}}>
                    {originPrice}
                </View>
                <AddShoppingCartBtnContainer item={item} style={{padding: 5}}>
                    <Image style={{width: 20, height: 20}} source={shop_cart_add}/>
                </AddShoppingCartBtnContainer>
            </View>
        </TouchableOpacity>
    }

    render() {
        return<View style={{flex:1}}>
                {this._getGoodsListContent()}
            </View>
    }
}