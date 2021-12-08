import React, {Component} from "react";
import {createAppContainer, NavigationActions, StackActions} from "react-navigation";
import {createStackNavigator} from "react-navigation-stack"
import {getRouterConfig, routeConfig} from "../config/RouteConfig";
import {BackHandler, Platform, View} from "react-native";
import {goBackToNative, setNativeInteractivePopEnable} from "../utils/NativeMethodUtil";

let AppNavigator = null;

//当前路由下标
let AppCurrentRouterIndex = 0;

export function getAppCurrentRouterIndex() {
    return AppCurrentRouterIndex;
}

//初始化一个页面导航控制器
export function initAppNavigator(initialPage, params) {
    AppNavigator = createAppContainer(createStackNavigator(routeConfig, getRouterConfig(initialPage, params)));
    AppNavigator.router.getStateForAction = navigateAndPushOnce(AppNavigator.router.getStateForAction);
}

export function getStateForAction(action,state){
    action = AppNavigator.router.getStateForAction(action, state);
    return action;
}

//防止页面触发多次push
let pushTime = 0;
const navigateAndPushOnce = (getStateForAction) => (action, state) => {
    const {type, routeName} = action;
    if(state  && routeName === state.routes[state.routes.length - 1].routeName){
        if(type === NavigationActions.NAVIGATE) return null;

        if(type === StackActions.PUSH){
            if(pushTime !== 0 && new Date().getTime() - pushTime < 700){
                return null;
            }
            pushTime = new Date().getTime();
        }
    }

    return getStateForAction(action, state);
};

//页面导航切换
export class AppNavigation extends Component {
    constructor(props) {
        super(props);
    }

    componentDidMount(){

        //监听安卓的物理返回键
        if(Platform.OS === 'android'){
            BackHandler.addEventListener('hardwareBackPress', () => {
                    if(AppCurrentRouterIndex === 0){
                        goBackToNative();
                        return true;
                    }
                }
            );
        }
    }

    componentWillUnmount() {

        //移除安卓物理返回键监听
        if (Platform.OS === 'android') {
            BackHandler.removeEventListener('hardwareBackPress',()=>{});
        }
    }

    render() {
        return (
            <View style={{flex:1}}>
                <AppNavigator onNavigationStateChange={(prevState, currentState) => {
                    AppCurrentRouterIndex = currentState.index;

                    //当是第一页的时候让ios 的滑动返回生效
                    setNativeInteractivePopEnable(AppCurrentRouterIndex === 0);
                }}/>
            </View>
        )
    }
}

