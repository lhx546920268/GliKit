import {NativeModules, Platform} from "react-native";
import {getCurrentUserInfo} from "../config/AppConfig";

export const NATIVE_MODULE = 'ReactNativeInteraction';

/**
 * 回调原生方法
 * @param moduleName 模块名
 * @param funcName 方法名
 * @param params 参数
 */
export function callNativeMethod(moduleName,funcName, params) {
    if(NativeModules[moduleName]){
        if(NativeModules[moduleName][funcName]){
            if(params){
                NativeModules[moduleName][funcName](params);
            }else{
                NativeModules[moduleName][funcName]();
            }
        }else{
            console.log(`找不到[${moduleName}]模块中的[${funcName}]方法`);
        }
    }else{
        console.log(`找不到[${moduleName}]模块中的[${funcName}]方法`);
    }
}


/**
 * 隐藏原生启动蒙版
 */
export function hideNativeLauncherMask() {
    callNativeMethod(NATIVE_MODULE, "hideNativeLauncherMask")
}

/**
 * 是否已登录
 */
export function isLogin() {
    return getCurrentUserInfo() != null;
}

/**
 * 登录
 */
export function loginNative(loginCompletion, cancelCallback) {
    if(Platform.OS === 'ios') {
        callNativeMethod(NATIVE_MODULE, "login", (userInfo) => {
            if (userInfo) {
                if (typeof loginCompletion === 'function') {
                    loginCompletion(userInfo);
                }
            } else {
                if (typeof cancelCallback === 'function') {
                    cancelCallback();
                }
            }
        })
    }else {
        callNativeMethod(NATIVE_MODULE, "login")
    }
}

/**
 * 返回原生界面
 */
export function goBackToNative(){
    callNativeMethod(NATIVE_MODULE,'goBack')
}

/**
 * 设置原生状态栏样式
 * @param colorName ['white','black]
 */
export function setNativeStatusBarStyle(colorName = 'white'){
    callNativeMethod(NATIVE_MODULE, "setStatusBarStyle", colorName);
}

/**
 * 显示错误toast提示
 * @param text
 */
export function showNativeErrorToast(text) {
    callNativeMethod(NATIVE_MODULE, "showErrorToast", text);
}

/**
 * 显示成功toast提示
 * @param text
 */
export function showNativeSuccessToast(text) {
    callNativeMethod(NATIVE_MODULE, "showSuccessToast", text);
}

/**
 * 显示loading弹窗
 * @param text
 * @param delay
 */
export function showNativeLoadingToast(text, delay) {
    if(Platform.OS === 'ios'){
        callNativeMethod(NATIVE_MODULE, "showLoadingToast", {text, delay});
    }else{
        callNativeMethod(NATIVE_MODULE, "showLoadingToast");
    }

}

/**
 * 隐藏loading弹窗
 */
export function hideNativeLoadingToast() {
    callNativeMethod(NATIVE_MODULE, "hideLoadingToast");
}

/**
 * 打开原生界面commonId
 * @param className
 * @param data
 */
export function openNativePage(className,data) {
    callNativeMethod(NATIVE_MODULE, "openAppWindow",{className, data});
}

/**
 * 打开原生商品详情界面
 * @param commonId
 */
export function openGoodsDetailNativePage(commonId) {
    openNativePage(Platform.OS === 'ios'?
        'CAGoodsDetailViewController':'com.zegobird.shop.ui.goods.detail.GoodsDetailActivity'
        ,{commonId:commonId.toString()}
    )
}

//购物车结算
export function shopCartNativeCheckout(json) {
    if(Platform.OS === 'ios'){
        openNativePage(
            'CAOrderConfirmViewController'
            ,{
                fromShopcart : true,
                existDiscountSet: false,
                json : json
            }
        );
    }else{

        openNativePage('com.zegobird.shop.ui.order.confirm.ConfirmOrderActivity',
            {
                    KEY_ORDER_INFO: json,
                    KEY_IS_CART: '1',
                    KEY_IS_EXIST_BUNDLING: '0'
            })
    }
}

//通知app购物车更新
export function shopcartNativeUpdate() {
    callNativeMethod(NATIVE_MODULE, "shopCartUpdate");
}

/**
 * 打开原生广告
 * @param data
 */
export function openNativeAdvertising(data){
    callNativeMethod(NATIVE_MODULE,'openAdvertising', JSON.stringify(data));
}

//设置页面是可以滑动返回，ios专用
export function setNativeInteractivePopEnable(enable = true) {
    callNativeMethod(NATIVE_MODULE,'setInteractivePopEnable', enable ? "true" : "false");
}

/**
 * 点击跳转到原生模块
 * @param data
 */
export function clickGotoNativeModule(data){
    callNativeMethod(NATIVE_MODULE,'clickGotoNativeModule',JSON.stringify(data))
}


