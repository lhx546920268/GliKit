//zawgyi : my-MM
//mm3 : my
import {isEmpty} from "../utils/StringUtil";

export const LANG_ZAWGYI =  'my-MM';
export const LANG_MM3 =  'my';
export const LANG_ENGLISH = 'en';
export const LANG_CHINESE = 'zh-Hans';

let DEBUG = true;

//当前语言
let language = LANG_ZAWGYI;

//当前用户信息
let currentUserInfo = null;

//店铺id
let zegoMartShopId = null;

//域名
let zegoMartDomain = null;

export const setDebug=(debug)=>{
    DEBUG = debug
};

export const isDebug=()=>{
    return DEBUG
};

/**
 * 更新语言
 * @param lang
 */
export const updateLanguage=(lang)=>{
    if(lang == null){
        lang = LANG_ZAWGYI;
    }
    if(lang === "zh"){
        lang = LANG_CHINESE;
    }
    language = lang
};

export const getLanguage=()=>{
    return language
};

export function updateCurrentUserInfo(userInfo){
    currentUserInfo = userInfo;
}

export function getCurrentUserInfo(){
    // if(__DEV__){
    //     return {
    //         token: "7f42a4656f424fb9ac1c231a07e0573c"
    //     };
    // }
    return currentUserInfo;
}

export function getZegoMartShopId() {
    if(zegoMartShopId && zegoMartShopId > 0){
        return zegoMartShopId;
    }else {
        return 3;
    }
}

export function updateZegoMartShopId(shopId) {
    zegoMartShopId = shopId;
}

export function getZegoMartDomain() {
    if(isEmpty(zegoMartDomain)){
        return "http://192.168.50.71:8888";
    }
    return zegoMartDomain;
}

export function updateZegoMartDomain(domain) {
    zegoMartDomain = domain;
}

export const EVENT_ADD_SHOPPING_CART_ANIM = 'EVENT_ADD_SHOPPING_CART_ANIM'; //加入购物车曲线动画
export const EVENT_ADD_SHOPPING_CART_ICON_ANIM = 'EVENT_ADD_SHOPPING_CART_ICON_ANIM'; //加入购物车曲线完成后 购物车图标缩放动画
export const EVENT_ON_ADD_SHOPPING_CART_RN = 'EVENT_ON_ADD_SHOPPING_CART_RN'; //rn加入购物车成功
export const EVENT_ON_ADD_SHOPPING_CART = 'EVENT_ON_ADD_SHOPPING_CART'; //原生app加入购物车成功
export const EVENT_ON_ORDER_CONFIRM = 'EVENT_ON_ORDER_CONFIRM'; //订单确认后
export const EVENT_ON_LOGIN = 'EVENT_ON_LOGIN'; //登录成功
export const EVENT_ON_LOGOUT = 'EVENT_ON_LOGOUT'; //退出登录
