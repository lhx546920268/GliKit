import React, {Component} from 'react';
import {Platform} from 'react-native';
import {AppNavigation, initAppNavigator} from "./components/routers/AppNavigation";
import {EVENT_ON_LOGIN, EVENT_ON_LOGOUT, setDebug, updateCurrentUserInfo, updateLanguage, updateZegoMartDomain, updateZegoMartShopId} from "./config/AppConfig";
import {registerEventToNative} from "./utils/EventUtil";
import {hideNativeLauncherMask} from "./utils/NativeMethodUtil";

export default class App extends Component<Props> {

  constructor(props) {
    super(props);
    updateLanguage(this.props.language);
    let userInfo = this.props.userInfo;
    if(userInfo != null && typeof userInfo === 'object'){
        updateCurrentUserInfo(userInfo);
    }
    //
    updateZegoMartDomain(this.props.domain);
    updateZegoMartShopId(this.props.storeId);
    setDebug(this.props.debug);

    initAppNavigator('ZegoMart');//此方法必须最先调用，否则路由配置会出问题

    initProps(props);
  }

  componentDidMount(): void {
      hideNativeLauncherMask();
      //登录
        this.onLoginListener = registerEventToNative(EVENT_ON_LOGIN, (userInfo) => {
            updateCurrentUserInfo(userInfo);
            // postEvent(EVENT_ON_LOGIN)
        });

        //退出登录
        this.onLogoutListener = registerEventToNative(EVENT_ON_LOGOUT, () => {
            updateCurrentUserInfo(null);
            // postEvent(EVENT_ON_LOGOUT)
        });
    }

    componentWillUnmount(): void {
        this.onLoginListener.remove();
        this.onLogoutListener.remove();
    }

    render(){
      return <AppNavigation/>
    }
}

const ENV_RELEASE = "RELEASE";
const ENV_BETA = "BETA";
const ENV_PRE = "PRE";
const ENV_TEST_GZ = "TEST_GZ";
const ENV_TEST_GZ_IP = "TEST_GZ_IP";
const ENV_TEST_MMR = "TEST_MMR";
const ENV_CUSTOM = "CUSTOM";

function initProps(props) {
    if(Platform.OS === 'android'){
        if(props.environment){
            switch (props.environment) {
                case ENV_RELEASE:
                case ENV_BETA:
                case ENV_PRE: updateZegoMartShopId('2121');break;
                case ENV_TEST_MMR:updateZegoMartShopId('13');break;
                case ENV_TEST_GZ:
                case ENV_TEST_GZ_IP:
                case ENV_CUSTOM:updateZegoMartShopId('3');break;
            }
        }
    }
}
