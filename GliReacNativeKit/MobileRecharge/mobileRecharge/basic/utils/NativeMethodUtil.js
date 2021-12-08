import {NativeModules, Platform} from 'react-native';
import {getCurrentUserInfo, updateCurrentUserInfo} from '../config/AppConfig';

export const NATIVE_MODULE = 'ReactNativeInteraction';

/**
 * 回调原生方法
 * @param moduleName 模块名
 * @param funcName 方法名
 * @param params 参数
 */
export function callNativeMethod(moduleName, funcName, params) {
  if (NativeModules[moduleName]) {
    if (NativeModules[moduleName][funcName]) {
      if (params) {
        NativeModules[moduleName][funcName](params);
      } else {
        NativeModules[moduleName][funcName]();
      }
    } else {
      console.log(`找不到[${moduleName}]模块中的[${funcName}]方法`);
    }
  } else {
    console.log(`找不到[${moduleName}]模块中的[${funcName}]方法`);
  }
}

/**
 * 选择联系人
 */
export function initContact() {
  callNativeMethod(NATIVE_MODULE, "initContact");
}

/**
 * 选择联系人
 */
export function pickContact(callback) {
  callNativeMethod(NATIVE_MODULE, "pickContact", callback);
}

/**
 * 搜索联系人
 */
export function searchContact(keyword, callback) {
  let module = NativeModules[NATIVE_MODULE];
  if (module) {
    let funcName = module["searchContact"];
    if (funcName) {
      funcName(keyword, callback);
    }
  }
}

/**
 * 是否可以打印
 */
export function nativePrintEnable(callback) {
  callNativeMethod(NATIVE_MODULE, "printEnable", callback);
}

/**
 * 打印订单
 */
export function nativePrintOrder(data) {
  callNativeMethod(NATIVE_MODULE, "print", data);
}

/**
 * 隐藏原生启动蒙版
 */
export function hideNativeLauncherMask() {
  callNativeMethod(NATIVE_MODULE, 'hideNativeLauncherMask');
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
    callNativeMethod(NATIVE_MODULE, 'login', userInfo => {
      if (userInfo) {
        updateCurrentUserInfo(userInfo);
        if (typeof loginCompletion === 'function') {
          loginCompletion(userInfo);
        }
      } else {
        if (typeof cancelCallback === 'function') {
          cancelCallback();
        }
      }
    });
}

/**
 * 返回原生界面
 */
export function goBackToNative() {
  callNativeMethod(NATIVE_MODULE, 'goBack');
}

/**
 * 设置原生状态栏样式
 * @param colorName ['white','black]
 */
export function setNativeStatusBarStyle(colorName = 'white') {
  callNativeMethod(NATIVE_MODULE, 'setStatusBarStyle', colorName);
}

/**
 * 显示错误toast提示
 * @param text
 */
export function showNativeErrorToast(text) {
  callNativeMethod(NATIVE_MODULE, 'showErrorToast', text);
}

/**
 * 显示成功toast提示
 * @param text
 */
export function showNativeSuccessToast(text) {
  callNativeMethod(NATIVE_MODULE, 'showSuccessToast', text);
}

/**
 * 显示loading弹窗
 * @param text
 * @param delay
 */
export function showNativeLoadingToast(text, delay) {
  if (Platform.OS === 'ios') {
    callNativeMethod(NATIVE_MODULE, 'showLoadingToast', {text, delay});
  } else {
    callNativeMethod(NATIVE_MODULE, 'showLoadingToast');
  }
}

/**
 * 隐藏loading弹窗
 */
export function hideNativeLoadingToast() {
  callNativeMethod(NATIVE_MODULE, 'hideLoadingToast');
}

/**
 * 打开原生界面commonId
 * @param className
 * @param data
 */
export function openNativePage(className, data) {
  callNativeMethod(NATIVE_MODULE, 'openAppWindow', {className, data});
}

/**
 * 打开原生商品详情界面
 * @param commonId
 */
export function openGoodsDetailNativePage(commonId) {
  openNativePage(
    Platform.OS === 'ios'
      ? 'CAGoodsDetailViewController'
      : 'com.zegobird.shop.ui.goods.detail.GoodsDetailActivity',
    {commonId: commonId.toString()},
  );
}

//购物车结算
export function shopCartNativeCheckout(json) {
  if (Platform.OS === 'ios') {
    openNativePage('CAOrderConfirmViewController', {
      fromShopcart: true,
      existDiscountSet: false,
      json: json,
    });
  } else {
    openNativePage('com.zegobird.shop.ui.order.confirm.ConfirmOrderActivity', {
      KEY_ORDER_INFO: json,
      KEY_IS_CART: '1',
      KEY_IS_EXIST_BUNDLING: '0',
    });
  }
}

//设置页面是可以滑动返回，ios专用
export function setNativeInteractivePopEnable(enable = true) {
  callNativeMethod(
    NATIVE_MODULE,
    'setInteractivePopEnable',
    enable ? 'true' : 'false',
  );
}

/**
 * 点击跳转到原生模块
 * @param data
 */
export function clickGotoNativeModule(data) {
  callNativeMethod(
    NATIVE_MODULE,
    'clickGotoNativeModule',
    JSON.stringify(data),
  );
}

/**
 * 支付
 */
export function nativeZegoPay(data, callback) {
  const moduleName = NativeModules[NATIVE_MODULE];
  if (moduleName) {
    const funcName = moduleName["zegoPay"];
    if (funcName) {
      funcName(data, callback);
    }
  }
}

/*
@param data 确认框参数
{
  style: "alert", //默认alert，还有个actionSheet
  title: "标题",
  subtitle: "副标题",
  destructiveButtonIndex: -1, //显示红色警告的按钮，在按钮数组范围内则有效，0开始
  buttonTitles:[
    "按钮1",
    "按钮2", //按钮可以传多个，如果没传，则使用默认的取消按钮
  ]
}
@param callback 点击某个按钮回调，里面会返回点击的按钮下标
*/
export function showNativeAlert(data, callback){
  const moduleName = NativeModules[NATIVE_MODULE];
  if (moduleName) {
    const funcName = moduleName["showAlert"];
    if (funcName) {
      funcName(data, callback);
    }
  }
}
