import React, {Component} from "react";
import {createAppContainer, NavigationActions, StackActions} from "react-navigation";
import {createStackNavigator} from "react-navigation-stack"
import {getRouterConfig, routeConfig} from "../../config/RouteConfig";
import {Animated, BackHandler, Easing, Image, Platform, View} from "react-native";
import {postEvent, registerEvent} from "../../utils/EventUtil";
import {SCREEN_HEIGHT} from "../../utils/AppUtil";
import {isIphoneX} from "react-native-iphone-x-helper";
import {EVENT_ADD_SHOPPING_CART_ANIM, EVENT_ADD_SHOPPING_CART_ICON_ANIM} from "../../config/AppConfig";
import {shop_cart_add} from "../../constraint/Image";
import {ZegoMartBottomContainer} from "../../components/ShopCart";
import IPhoneXBottom from "../../widgets/iphonex/IPhoneXBottom"
import {goBackToNative, isLogin, loginNative, setNativeInteractivePopEnable} from "../../utils/NativeMethodUtil";
import IPhoneXTop from "../../widgets/iphonex/IPhoneXTop";

let AppNavigator = null;

export function initAppNavigator(initialPage) {
    AppNavigator = createAppContainer(createStackNavigator(routeConfig,getRouterConfig(initialPage)));
    AppNavigator.router.getStateForAction = navigateAndPushOnce(AppNavigator.router.getStateForAction);
}

export function getStateForAction(action,state){
    action = AppNavigator.router.getStateForAction(action,state);
    return action;
}

let pushTime = 0;
const navigateAndPushOnce = (getStateForAction) => (action, state) => {
    const {type, routeName} = action;
    if(state  && routeName === state.routes[state.routes.length - 1].routeName ){
        if(type === NavigationActions.NAVIGATE)return null;

        if(type === StackActions.PUSH){
            if(pushTime !== 0 && new Date().getTime() - pushTime < 700){
                return null;
            }
            pushTime = new Date().getTime();
        }
    }

    return getStateForAction(action,state);
};

export class AppNavigation extends Component {
    constructor(props) {
        super(props);

        this.stackIndex = 0;

        this.state = {
            image:null,
            position:null,
            addShoppingCartAnimViewArr:[],
            showShopCartDialog: false, //是否显示购物车弹窗
        }
    }

    componentDidMount(){
        this.addShoppingCartAnimListener = registerEvent(EVENT_ADD_SHOPPING_CART_ANIM,({image,position})=>{
            this._showAddShoppingCartAnim(image,position)
        });
        if(Platform.OS === 'android'){
            BackHandler.addEventListener('hardwareBackPress', () => {
                    if(this.stackIndex === 0){
                        goBackToNative();
                        return true;
                    }
                }
            );
        }
    }

    componentWillUnmount() {
        this.addShoppingCartAnimListener.remove();
        if (Platform.OS === 'android') {
            BackHandler.removeEventListener('hardwareBackPress',()=>{});
        }
    }

    _showAddShoppingCartAnim(component,position){

        let {pageX, pageY} = position;
        //购物车位置
        const shopCartX = 15;
        const shopCartY = SCREEN_HEIGHT - (isIphoneX() ? 34 : 0) - 40;

        let animateInputs = [0,1];
        let translateOutputYs = [pageY,shopCartY];
        let translateOutputXs = [pageX,shopCartX];

        let key = new Date().valueOf();

        this.state[`shopCartAddXAnim${key}`]= new Animated.Value(0); //加入购物车x轴动画
        this.state[`shopCartAddYAnim${key}`]= new Animated.Value(0); //加入购物车y轴动画
        let animView = <Animated.View
            key={key}
            style={{position:'absolute', zIndex: 100,  left: this.state[`shopCartAddXAnim${key}`].interpolate({
                    inputRange: animateInputs,
                    outputRange: translateOutputXs,
                }), top: this.state[`shopCartAddYAnim${key}`].interpolate({
                    inputRange: animateInputs,
                    outputRange: translateOutputYs,
                })}}
        >
            <Image style={{width: 25, height: 25}} source={shop_cart_add}/>
        </Animated.View>;

        let animArr = this.state.addShoppingCartAnimViewArr;
        animArr.push({key,animView});

        this.setState({addShoppingCartAnimViewArr: animArr},()=>this._shopCartAddAnimate(key))
    }

    //执行加入购物车动画
    _shopCartAddAnimate(key) {

        Animated.parallel([
            Animated.timing(
                this.state[`shopCartAddXAnim${key}`], {
                    duration: 500,
                    toValue: 1.0,
                }
            ),
            Animated.timing(
                this.state[`shopCartAddYAnim${key}`], {
                    duration: 500,
                    toValue: 1.0,
                    easing: Easing.bezier(0.44,-0.19,0.48,-0.42)
                }
            ),
        ]).start();

        setTimeout(() => {
            let animArr = this.state.addShoppingCartAnimViewArr;
            this.setState({addShoppingCartAnimViewArr:animArr.filter(item=>item.key !== key)});
            postEvent(EVENT_ADD_SHOPPING_CART_ICON_ANIM)
        }, 500);
    }

    //点击购物车图标
    _handlePressShopCartIcon(){
        if(isLogin()){
            this._openShopCartDialog();
        }else {
            loginNative(() => {
                this._openShopCartDialog();
            });
        }
    }

    //打开购物车弹窗
    _openShopCartDialog(){
        if(this.state.showShopCartDialog){
            this.bottomContainer.dismissShopCartDialog(() => {
                this.setState({
                    showShopCartDialog: false
                })
            })
        }else {
            this.setState({
                showShopCartDialog: true
            })
        }
    }

    render() {
        let shopCartDialog = null;
        if(this.bottomContainer && this.state.showShopCartDialog){
            shopCartDialog = this.bottomContainer.getShopCartDialog();
        }
        return (
            <View style={{flex:1}}>
                <IPhoneXTop/>
                <AppNavigator onNavigationStateChange={(prevState, currentState) => {
                    this.stackIndex = currentState.index;
                    setNativeInteractivePopEnable(this.stackIndex === 0);
                }}/>
                {shopCartDialog}
                <ZegoMartBottomContainer ref={f => this.bottomContainer = f} onPressShopCartIcon={this._handlePressShopCartIcon.bind(this)}/>
                <IPhoneXBottom style={{backgroundColor: 'white'}}/>
                {this.state.addShoppingCartAnimViewArr.map(item=>item.animView)}
            </View>
        )
    }
}

