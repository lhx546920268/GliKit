import React, {Component} from 'react';
import {Alert, Animated, FlatList, Image, Text, TouchableOpacity, TouchableWithoutFeedback, View} from 'react-native';
import {mainColor, titleTextColor} from "../constraint/Colors";
import {close_black, minus, plus, shop_cart, shop_cart_empty, tick_n, tick_s} from '../constraint/Image'
import BadgeValue from "./widgets/BadgeValue";
import {formatMoney, formatString} from "../utils/StringUtil";
import PropTypes from "prop-types";
import {getIphoneXBottomHeight, SCREEN_HEIGHT, SCREEN_WIDTH} from "../utils/AppUtil";
import Loading from "./widgets/Loading";
import FailPage from "./widgets/FailPage";
import EmptyView from "./widgets/EmptyView";
import {getString} from "../constraint/String";
import ZegobirdButton from "./widgets/ZegobirdButton";
import {registerEvent, registerEventToNative} from "../utils/EventUtil";
import {EVENT_ADD_SHOPPING_CART_ICON_ANIM, EVENT_ON_ADD_SHOPPING_CART, EVENT_ON_ADD_SHOPPING_CART_RN, EVENT_ON_LOGIN, EVENT_ON_LOGOUT, EVENT_ON_ORDER_CONFIRM} from "../config/AppConfig";
import {get, post} from "../utils/HttpUtils";
import {isLogin, openNativePage, shopCartNativeCheckout, shopcartNativeUpdate, showNativeErrorToast} from "../utils/NativeMethodUtil";
import {ShopCartModel} from "../model/ShopCartModel";
import {ImageView} from "../widgets/ImageView";

//底部视图
export class ZegoMartBottomContainer extends Component{

    static defaultProps = {
        onPressShopCartIcon: null, //点击购物车图标
    };

    static propTypes = {
        onPressShopCartIcon: PropTypes.func,
    };

    constructor(props){
        super(props);
        this.state = {
            shopCartIconScaleAnim: new Animated.Value(1.0), //购物车图标 缩放颤抖动画
            shopCartModel: null, //购物车信息
            loading: false, //是否正在加载
            loadFail: false, //是否加载失败
        };
    }

    //获取购物车弹窗
    getShopCartDialog(){
        return <ShopCartDialog showShopcartDialog={this.props.onPressShopCartIcon}
                               shopCartModel={this.state.shopCartModel}
                               loading={this.state.loading}
                               loadFail={this.state.loadFail}
                               onReload={() => {
                                   this._loadShopCartData();
                               }}
                               onShopCartUpdate={this._handleShopCartUpdate.bind(this)}
                               ref={f => this.shopCartDialog = f}/>;
    }

    //隐藏购物车弹窗
    dismissShopCartDialog(callback){
        this.shopCartDialog.dismissDialog(callback);
    }

    componentDidMount(): void {
       
        this.shopcartIconScaleAnimListener = registerEvent(EVENT_ADD_SHOPPING_CART_ICON_ANIM,()=>{
            this.startShopCartIconScaleAnim()
        });

        //有商品加入购物车了
        this.onShopCartAddListener = registerEvent(EVENT_ON_ADD_SHOPPING_CART_RN, () => {
            this._loadShopCartData();
        });

        //有商品加入购物车了
        this.onShopCartAddListener = registerEventToNative(EVENT_ON_ADD_SHOPPING_CART, (data) => {
            console.log("加入购物车了 EVENT_ON_ADD_SHOPPING_CART");
            this._loadShopCartData();
        });

        //确认订单了
        this.onOrderConfirmListener = registerEventToNative(EVENT_ON_ORDER_CONFIRM, (data) => {
            this._loadShopCartData();
        });

        //登录
        this.onLoginListener = registerEventToNative(EVENT_ON_LOGIN, () => {
            this._loadShopCartData();
        });

        //退出登录
        this.onLogoutListener = registerEventToNative(EVENT_ON_LOGOUT, () => {
            this.setState({
                shopCartModel: null,
                loading: false,
                loadFail: false
            })
        });
        this._loadShopCartData();
    }

    componentWillUnmount(): void {
        this.shopcartIconScaleAnimListener.remove();
        this.onShopCartAddListener.remove();
        this.onOrderConfirmListener.remove();
        this.onLoginListener.remove();
        this.onLogoutListener.remove();
    }

    //购物车图标缩放动画
    startShopCartIconScaleAnim(){
        this.state.shopCartIconScaleAnim.setValue(0.7);
        Animated.spring(
            this.state.shopCartIconScaleAnim, {
                toValue: 1.0,
                friction: 1,
                tension: 20,
            }
        ).start()
    }

    //结算
    _checkout(){
        let models = [];
        let goodsModels = this.state.shopCartModel.goodsModels;
        for(let i = 0;i < goodsModels.length;i ++){
            let goodsModel = goodsModels[i];
            if(goodsModel.buyEnable()){
                models.push({
                    goodsId: goodsModel.cartId,
                    buyNum: goodsModel.buyCount
                });
            }
        }

        post("member/buy/step1", {
            buyData: JSON.stringify(models),
            isExistBundling: 0,
            isCart: 1
        }, true, true, 500, null, false).then((response) => {
            shopCartNativeCheckout(JSON.stringify(response.data));
        }, () => {

        });
    }

    //加载购物车数据
    _loadShopCartData(){
        if(isLogin()){
            this.state.loading = true;
            this.state.loadFail = false;
            if(this.shopCartDialog){
                this.shopCartDialog.setLoading(true);
            }

            if(this.shopCartDataRequest != null){
                this.shopCartDataRequest.cancel();
            }
            this.shopCartDataRequest = get("member/zegomart/cart/list", {});
            this.shopCartDataRequest.then((response) => {

                this.setState({
                    loading: false,
                    shopCartModel: new ShopCartModel(response.data),
                });

                if(this.shopCartDialog != null){
                    this.shopCartDialog.onLoadComplete(this.state.shopCartModel, false);
                }

                this.shopCartDataRequest = null;
            }, () => {
                this.shopCartDataRequest = null;
                this.setState({
                    loading: false,
                    loadFail: true,
                });

                if(this.shopCartDialog != null){
                    this.shopCartDialog.onLoadComplete(null, true);
                }
            });
        }
    }

    //购物车更新了
    _handleShopCartUpdate(){
        this.forceUpdate();
    }

    render(){
        let totalPrice = 0;
        let promotionPrice = 0;
        let differModel = null;
        let shopCartCount = 0;

        let shopCartModel = this.state.shopCartModel;
        //获取当前合适的满优惠金额，如果有个满优惠大于当前合适的优惠金额，要显示对应的满优惠信息
        if(shopCartModel != null){
            totalPrice = shopCartModel.getTotalPrice();
            promotionPrice = shopCartModel.getPromotionPrice(totalPrice);
            differModel = shopCartModel.getDifferFullPreferentialModel(totalPrice, promotionPrice);
            shopCartCount = shopCartModel.getShopCartCount();
        }

        let promotionText = null; //促销金额
        let differText = null; //差多少可以满减

        let totalText = <Text allowFontScaling={false} style={{fontSize: 16, fontWeight: 'bold', width: '100%', color: titleTextColor}} ellipsizeMode='tail' numberOfLines={1}>Total：{formatMoney(totalPrice)}</Text>;
        if(promotionPrice > 0){
            let str = formatString(getString().promotion, [formatMoney(promotionPrice)]);
            promotionText = <Text allowFontScaling={false} style={{fontSize: 9, color: '#FF3A30'}} ellipsizeMode='tail' numberOfLines={1}>{str}</Text>;
        }
        if(differModel !== null){

            let str = formatString(getString().differenceDiscount, [formatMoney(differModel.leastAmount - totalPrice), formatMoney(differModel.preferentialAmount)]);
            differText = <Text allowFontScaling={false} style={{fontSize: 9, color: '#FF3A30'}} ellipsizeMode='tail'
                               numberOfLines={1}>{str}</Text>;
        }

        return (
            <View style={{height: 50, flexDirection: 'row', alignItems: 'center', backgroundColor: 'white', borderTopColor: "#dedede7d", borderTopWidth: 0.5}}>
                <TouchableOpacity activeOpacity={0.7} style={{flex: 1, flexDirection: 'row', alignItems: 'center',}} onPress={this.props.onPressShopCartIcon}>
                    <View style={{padding: 15}}>
                        <Animated.Image source={shop_cart} style={{width: 20, height: 20, transform:[{scale: this.state.shopCartIconScaleAnim}]}}/>
                        <BadgeValue style={{position: 'absolute', top: 10, right: 10}} value = {shopCartCount}/>
                    </View>

                    <View style={{alignItems: 'flex-start', justifyContent:'space-between', flex: 1}}>
                        {totalText}
                        {promotionText}
                        {differText}
                    </View>
                </TouchableOpacity>
                <ZegobirdButton disabled={shopCartModel == null || !shopCartModel.buyEnable()} onPress={() => this._checkout()} style={{marginRight: 10, marginLeft: 10, borderRadius: 20, height: 40, width: 125}} title={getString().checkout}/>
            </View>
        )
    }
}

//购物车弹窗
export class ShopCartDialog extends Component{

    static defaultProps = {
        showShopcartDialog: null,
        shopCartModel: null, //购物车信息
        onShopCartUpdate: null, //购物车信息更新了
    };

    static propTypes = {
        showShopcartDialog: PropTypes.func,
        shopCartModel: PropTypes.object,
        onShopCartUpdate: PropTypes.func,
    };

    constructor(props){
        super(props);
        this.state = {
            transformYAnim: new Animated.Value(0), //弹窗y轴初始值
            opacityAnim: new Animated.Value(0), //透明度动画
            shopCartModel: this.props.shopCartModel, //商品信息
            loading: this.props.loading, //是否正在加载
            loadFail: this.props.loadFail, //失败
            heightAnim: new Animated.Value(0), //高度动画
            heightAnimOutputRange: null, //高度动画输出
        }
    }

    componentDidMount(){
        Animated.parallel([Animated.timing(
            this.state.transformYAnim,
            {
                toValue: 1,
                duration: 250
            }
        ), Animated.timing(
            this.state.opacityAnim,
            {
                toValue: 1,
                duration: 250
            }
        )]).start();
    }

    //隐藏弹窗
    dismissDialog(callback){
        Animated.parallel([Animated.timing(
            this.state.transformYAnim,
            {
                toValue: 0,
                duration: 250
            }
        ), Animated.timing(
            this.state.opacityAnim,
            {
                toValue: 0,
                duration: 250
            }
        )]).start();
         setTimeout(() => {
             if(callback != null){
                 callback();
             }
         }, 250);
    }

    //设置加载状态
    setLoading(loading){
        this.setState({
            loading,
            loadFail: false
        });
    }

    //加载完成
    onLoadComplete(shopCartModel, loadFail){

        let oldHeight = this._getShopCartDialogHeight(this.state.shopCartModel);
        let newHeight = this._getShopCartDialogHeight(shopCartModel);
        if(oldHeight !== newHeight){
            this.state.heightAnimOutputRange = [oldHeight, newHeight];
        }

        this.setState({
            loadFail: loadFail,
            shopCartModel: shopCartModel,
            loading: false,
        });
        if(oldHeight !== newHeight){
            this._startHeightAnimate();
        }
    }

    //执行高度动画
    _startHeightAnimate(){
        this.state.heightAnim.setValue(0);
        Animated.timing(
            this.state.heightAnim, {
                toValue: 1.0,
                duration: 250
            }
        ).start();
    }

    //全选
    _handleSelectAll(){
        let shopCartModel = this.state.shopCartModel;
        shopCartModel.setSelectAll(!shopCartModel.isSelectAll());
        this.setState({
            shopCartModel: shopCartModel,
        });

        if(this.props.onShopCartUpdate !== null){
            this.props.onShopCartUpdate();
        }
    }

    //选中某个item
    _handleSingleSelect(item){
        let shopCartModel = this.state.shopCartModel;
        item.selected = !item.selected;
        this.setState({
            shopCartModel: shopCartModel
        });

        if(this.props.onShopCartUpdate !== null){
            this.props.onShopCartUpdate();
        }
    }

    //加
    _handlePlus(item){
        if(item.buyCount >= item.storage){
            showNativeErrorToast(getString().shopCartMaxStorageError);
            return;
        }

        if(item.limitStorage > 0 && item.buyCount >= item.limitStorage){
            showNativeErrorToast(formatString(getString().shopCartMaxLimitError, [item.limitStorage]));
            return;
        }
        this._updateCount(item, item.buyCount + 1);
    }

    //减
    _handleMinus(item){
        if(item.buyCount === 1){
            Alert.alert(getString().goodsDeleteAlert, "", [
                {
                    text: 'NO',
                },
                {
                    text: 'YES',
                    onPress: () => {
                        this._handleDelete(item);
                    },
                    style: 'destructive',
                }
            ]);
        }else {
            this._updateCount(item, item.buyCount - 1);
        }
    }

    //更新数量
    _updateCount(item, count){
        post("cart/edit", {
            buyNum: count,
            cartId: item.cartId,
        }, true, true, 500).then(() => {
            item.buyCount = count;

            this.forceUpdate();
            if(this.props.onShopCartUpdate !== null){
                this.props.onShopCartUpdate();
            }
            shopcartNativeUpdate();
        });
    }

    //删除
    _handleDelete(item){
        post("cart/del/batch/sku", {
            cartId: item.cartId
        }, true, true, 500).then(() => {
            let shopCartModel = this.state.shopCartModel;
            let oldHeight = this._getShopCartDialogHeight(this.state.shopCartModel);
            shopCartModel.goodsModels.splice(shopCartModel.goodsModels.indexOf(item), 1);
            let newHeight = this._getShopCartDialogHeight(shopCartModel);
            if(oldHeight !== newHeight){
                this.state.heightAnimOutputRange = [oldHeight, newHeight];
            }
            this.forceUpdate();
            if(oldHeight !== newHeight){
                this._startHeightAnimate();
            }
            if(this.props.onShopCartUpdate !== null){
                this.props.onShopCartUpdate();
            }
            shopcartNativeUpdate();
        })
    }

    //创建购物车商品item
    _createShopCartGoodsListItem(item){
        let originPrice = null;
        let width = SCREEN_WIDTH - 40 - 50 - 10 * 2;
        if(item.promotionType === 1 && item.originalPrice > item.price){
            originPrice = <Text allowFontScaling={false} style={{color: '#cccccc', fontSize: 12, textDecorationLine: 'line-through', width: width}} ellipsizeMode='tail' numberOfLines={1}>{formatMoney(item.originalPrice)}</Text>
        }
        return (
            <View style={{height: 70, flexDirection: 'row', justifyContent: 'flex-start', alignItems: 'center'}}>
                <TouchableOpacity style={{width: 40, height: 70, justifyContent: 'center', alignItems: 'center'}} onPress={() => this._handleSingleSelect(item)}>
                    <CheckBox checked={item.selected}/>
                </TouchableOpacity>
                <ImageView source={{uri: item.thumbnailURL()}} style={{width: 50, height: 50}}/>
                <View style={{marginLeft: 10, marginRight: 10, height: 50, justifyContent: 'flex-start', alignItems: 'flex-start'}}>
                    <Text allowFontScaling={false} style={{fontSize: 14, color: titleTextColor, width: width}} ellipsizeMode='tail' numberOfLines={1}>{item.goodsName}</Text>
                    <Text allowFontScaling={false} style={{fontSize: 14, marginTop: 2, fontWeight: 'bold', color: titleTextColor, width: width}} ellipsizeMode='tail' numberOfLines={1}>{formatMoney(item.price)}</Text>
                    {originPrice}
                </View>

                <ShopCartControl item={item}
                                 style={{position: 'absolute', right: 0, bottom: 8}}
                                 plus={() => this._handlePlus(item)}
                                 minus={() => this._handleMinus(item)}/>
            </View>
        )
    }

    //获取购物车弹窗高度
    _getShopCartDialogHeight(shopCartModel){

        let goodsModels = null;
        if(shopCartModel != null){
            goodsModels = shopCartModel.goodsModels;
        }
        let height = 0;
        if(goodsModels != null && goodsModels.length > 0){
            height = goodsModels.length * 70;
            let maxHeight = SCREEN_HEIGHT - getIphoneXBottomHeight() - 50 - 40 - 200;
            if(height > maxHeight){
                height = maxHeight;
            }
        }
        if(height < 210){
            height = 210;
        }

        return height + 40;
    }

    //获取购物车弹窗可动画的高度
    _getShopCartDialogAnimatedHeight(shopCartModel){
        if(this.state.heightAnimOutputRange != null){
            let animateHeight = this.state.heightAnim.interpolate({
                inputRange: [0, 1],
                outputRange: this.state.heightAnimOutputRange
            });
            this.state.heightAnimOutputRange = null;
            return animateHeight;
        }else {
            return this._getShopCartDialogHeight(shopCartModel);
        }
    }

    render(){

        let contentView = null; //内容视图
        let selectAllView = null; //全选

        if(this.state.loading){
            contentView = <Loading/>
        }else if(this.state.loadFail){
            contentView = <FailPage onReload={this.props.onReload}/>
        } else{
            let goodsModels = null;
            if(this.state.shopCartModel != null){
                goodsModels = this.state.shopCartModel.goodsModels;
            }
            if(goodsModels != null && goodsModels.length > 0){
                contentView = <FlatList style={{flex: 1}} keyExtractor={(item, index) => index.toString()} data={goodsModels}
                                    renderItem={({item}) => {
                                        return this._createShopCartGoodsListItem(item)
                                    }}/>;
                selectAllView = <TouchableOpacity activeOpacity={0.7}
                                                  onPress={this._handleSelectAll.bind(this)}
                                                  style={{justifyContent:'center', position:'absolute', left: 0, top: 0, bottom: 0, margin: 'auto'}}>
                    <View style={{flexDirection: 'row', marginLeft:10, alignItems:'center'}}>
                        <CheckBox checked={this.state.shopCartModel.isSelectAll()}/>
                        <Text allowFontScaling={false} style={{marginLeft:10, color: titleTextColor, fontSize: 14}}>{getString().selectAll}</Text>
                    </View>
                </TouchableOpacity>;
            }else{
                contentView = <EmptyView icon={shop_cart_empty} text={getString().shopCartEmpty}/>
            }
        }

        return (
            <Animated.View style={{position: 'absolute', width: '100%', height: '100%'}}>
                <TouchableWithoutFeedback onPress={this.props.showShopcartDialog}>
                    <Animated.View style={{position: 'absolute', width: '100%', height: '100%', backgroundColor: "#00000066", opacity: this.state.opacityAnim}}/>
                </TouchableWithoutFeedback>
                <Animated.View style={{backgroundColor: 'white', position: 'absolute', width: '100%', bottom: this.state.transformYAnim.interpolate({
                        inputRange: [0, 1],
                        outputRange: [-this._getShopCartDialogHeight(this.state.shopCartModel), 50 + getIphoneXBottomHeight()]
                    }), height: this._getShopCartDialogAnimatedHeight(this.state.shopCartModel)}}>
                    <View style={{height: 40,
                     borderBottomColor: "#dedede7d", borderBottomWidth: 0.5,
                     borderTopColor: "#dedede7d", borderTopWidth: 0.5}}>
                        {selectAllView}
                        <TouchableOpacity activeOpacity = {0.7}
                                          style = {{position:'absolute', top: 0, bottom: 0, margin: 'auto', paddingLeft: 15,
                                              paddingRight: 15, height: 40, alignItems: 'center', justifyContent: 'center', right: 0}}
                                          onPress = {this.props.showShopcartDialog}>
                            <Image style={{width: 20, height: 20}} source={close_black}/>
                        </TouchableOpacity>
                    </View>
                    {contentView}
                </Animated.View>
            </Animated.View>
        )
    }
}

//打钩和未打钩
class CheckBox extends Component{

    static defaultProps = {
        checked : false
    };
    static propTypes = {
        checked : PropTypes.bool
    };

    render(){
        return (
            <Image style={{width: 20, height: 20}} source={this.props.checked ? tick_s : tick_n}/>
        )
    }
}

//购物车数量
class ShopCartControl extends Component{

    static defaultProps = {
        plus : null, //加方法
        minus: null, //减方法
    };
    static propTypes = {
        plus : PropTypes.func,
        minus: PropTypes.func,
    };

    render(){
        return (
            <View style={[this.props.style, {flexDirection: 'row', alignItems: 'center'}]}>
                <TouchableOpacity style={{paddingLeft: 10, paddingTop: 10, paddingBottom: 10}} activeOpacity={0.7} onPress={this.props.minus}>
                    <Image source={minus} style={{width: 20, height: 20}}/>
                </TouchableOpacity>
                <Text allowFontScaling={false} style={{width: 30, fontSize: 14, color: mainColor, textAlign: 'center'}}>{this.props.item.buyCount}</Text>
                <TouchableOpacity style={{paddingRight: 10, paddingTop: 10, paddingBottom: 10}} activeOpacity={0.7} onPress={this.props.plus}>
                    <Image source={plus} style={{width: 20, height: 20}}/>
                </TouchableOpacity>
            </View>
        )
    }
}
