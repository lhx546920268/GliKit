
import {updateLanguage} from '../utils/LauguageUtils';

let DEBUG = true;

//当前用户信息
let currentUserInfo = null;

//当前环境
let environment = null;

//授权码
let accessKey = null;

const ENV_RELEASE = "RELEASE"; //正式
const ENV_BETA = "BETA"; //缅甸灰度测试
const ENV_PRE = "PRE"; //预生产
const ENV_TEST_GZ = "TEST_GZ"; //广州测试 域名
const ENV_TEST_GZ_IP = "TEST_GZ_IP"; //广州测试  IP
const ENV_TEST_MMR = "TEST_MMR"; //缅甸测试
const ENV_CUSTOM = "CUSTOM"; //自定义域名

///初始化
export function initProps(props) {

    updateLanguage(props.language);
    let userInfo = props.userInfo;
    if(userInfo != null && typeof userInfo === 'object'){
        updateCurrentUserInfo(userInfo);
    }

    DEBUG = props.debug;
    environment = props.environment;
    if(!environment){
        environment = ENV_RELEASE;
    }
}

export const isDebug=()=>{
    return DEBUG
};

export function getAccessKey() {
    return accessKey;
}

export function setAccessKey(key) {
    accessKey = key;
}

export function updateCurrentUserInfo(userInfo){
    currentUserInfo = userInfo;
}

export function getCurrentUserInfo(){
    if(__DEV__){
        return {
            token: "6186df9e0a124d6fb9ebb7388d58ca1a",
            userId: 951,
            username: 'a09780001567',
        };
    }
    return currentUserInfo;
}

export function getApiDomain() {
    switch (environment) {
        case ENV_RELEASE :
            return "https://phonebill.zegobird.com:30001";
        case ENV_BETA :
        case ENV_PRE :
        case ENV_TEST_MMR :
            return "https://testphonebill.zegobird.com:31001";
        case ENV_TEST_GZ :
        case ENV_TEST_GZ_IP :
        case ENV_CUSTOM :
            return "https://phonebilldevtest.zegobird.com:30005";
    }
    return "";
}
