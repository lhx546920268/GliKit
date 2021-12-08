import {hideNativeLoadingToast, showNativeErrorToast, showNativeLoadingToast} from "./NativeMethodUtil";
import {Platform} from 'react-native'
import {isEmpty} from "./StringUtil";
import {transferToZawgyiIfNeeded} from '../utils/LauguageUtils';
import {getCurrentUserInfo, getApiDomain, isDebug} from "../config/AppConfig";

//第一页
export const FIRST_PAGE = 1;

/**
 *  get请求
 * @param {*} method 服务器的请求方法
 * @param {*} params 参数
 * @param {*} showLoading 是否显示loading
 * @param {*} showError 是否提示报错信息
 * @param {*} loadingDelay loading 延迟 毫秒
 * @param {*} loadingText loading 文字
 * @param {*} transferToZawgyi 是否需要转成zawgyi
 */
export function get(method, params = {}, showLoading = false, showError = false, loadingDelay = 0, loadingText, transferToZawgyi = true) {
    return request('GET', method, params, showLoading, showError, loadingDelay, loadingText, transferToZawgyi);
}

///post请求 参数和上面一致
export function post(method, params = {}, showLoading = false, showError = false, loadingDelay = 0, loadingText, transferToZawgyi = true) {
    return request('POST', method, params, showLoading, showError, loadingDelay, loadingText, transferToZawgyi);
}

function request(httpMethod, method, params = {}, showLoading = false, showError = false, loadingDelay = 0, loadingText, transferToZawgyi = true) {

    if(showLoading){
        showLoadingToast(loadingText, loadingDelay);
    }
    params = checkParams(params);

    let body = '';
    let requestURL = getApiDomain() + method;

    for (let key in params) {
        body += body ? '&' : '';
        body += key + '=' + params[key];
    }

    let postBody = null;
    if (httpMethod === 'POST') {
        postBody = body;
    } else {
        requestURL += '?' + body;
    }

     if(isShowLog()){
        console.log(requestURL);
        console.log(params);
     }

     let xhr = new XMLHttpRequest();
    let promise = new Promise((resolve, reject) => {

        xhr.onload = () => {

            if(isShowLog()){
                console.log(xhr.responseText);
            }

            try{
                let text = xhr.responseText;
                if(transferToZawgyi){
                    text = transferToZawgyiIfNeeded(text);
                }
                let data = JSON.parse(text);
                // 数据报错
                if (data == null || typeof data !== 'object') {
                    onError(reject, showLoading, showError, "Data Error");
                } else {
                    if (data.code === getSuccessCode(method)) {
                        if(showLoading){
                            hideLoadingToast()
                        }
                        resolve({data: data.data});
                    } else {
                        //接口报错
                        let message = data.msg;
                        onError(reject, showLoading, showError, message);
                    }
                }
            }catch {
                if(isShowLog()){
                    console.log(requestURL + " json解析异常");
                }
                onError(reject, showLoading, showError, "Data Error");
            }
        };

        xhr.onerror = (e) => {
            if(isShowLog()){
                console.log(requestURL + "报错了", e);
            }
            onError(reject, showLoading, showError);
        };

        xhr.ontimeout = () => {
            if(isShowLog()){
                console.log(requestURL + "超时了");
            }
            onError(reject, showLoading, showError);
        };

        xhr.timeout = 15 * 1000;
        xhr.open(httpMethod, requestURL);
        xhr.setRequestHeader('Accept', 'application/json');
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.send(postBody);
    });
    promise.cancel = () => {
        xhr.abort();
    };

   return promise;
}

function isShowLog(){
    //return false;
    return __DEV__;
}

//接口报错
function onError(reject, showLoading, showError, message) {

    if(!showError || Platform.OS === 'android'){
        if(showLoading){
            hideLoadingToast();
        }
    }

    if(isEmpty(message)){
        message = "Network Error";
    }

    if(showError){
        showToastShort(message);
    }
    reject({ message: message });
}

function showToastShort(text) {
    showNativeErrorToast(text)
}

function showLoadingToast(text, delay) {
    showNativeLoadingToast(text, delay)
}

function hideLoadingToast() {
    hideNativeLoadingToast()
}

/**
 * 获取成功的状态码
 * @param method 接口方法名称
 */
function getSuccessCode(method) {
    return 200;
}

/**
 * 检查属性是否是null or undefined，是则删除该属性
 * @param params
 */
function checkParams(params) {
    if(params === undefined){
        return {};
    }
    for (let key in params) {
        const value = params[key];
        if (value === null || value === undefined) {
            delete params[key];
        }
    }
    return params;
}
