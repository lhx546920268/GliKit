
import React from 'react';
import {BackHandler, Platform} from 'react-native';
import PUBG from "./page/PUBG";
import MobileLegends from "./page/MobileLegends";
import OrderDetail from "./page/OrderDetail";
import zawgyi from "./basic/language/zawgyi";
import mm3 from "./basic/language/mm3";
import zh from "./basic/language/zh_Hans";
import en from "./basic/language/en";
import {AppConfig, NativeMethodUtil, EventUtil, StringUtil, LanguageUtil,} from "react-native-zego-framework";

export default class App extends React.Component {
  constructor(props){
    super(props);

    NativeMethodUtil.setNativeStatusBarStyle('white');
    AppConfig.initProps(props);
    LanguageUtil.registerString({name:LanguageUtil.LANG_ZAWGYI,strings:zawgyi});
    LanguageUtil.registerString({name:LanguageUtil.LANG_MM3,strings:mm3});
    LanguageUtil.registerString({name:LanguageUtil.LANG_ENGLISH,strings:en});
    LanguageUtil.registerString({name:LanguageUtil.LANG_CHINESE,strings:zh});
  }

  componentDidMount(): void {
    NativeMethodUtil.hideNativeLauncherMask();
    //登录
    this.onLoginListener = EventUtil.registerLoginEventToNative((userInfo) => {
      AppConfig.updateCurrentUserInfo(userInfo);
    });

    //退出登录
    this.onLogoutListener = EventUtil.registerLogoutEventToNative(() => {
      AppConfig.updateCurrentUserInfo(null);
    });

    //监听安卓的物理返回键
    if(Platform.OS === 'android'){
      BackHandler.addEventListener('hardwareBackPress', () => {
        NativeMethodUtil.goBackToNative();
            return true;
          }
      );
    }
  }

  componentWillUnmount(): void {
    if(this.onLoginListener && this.onLogoutListener){
      this.onLoginListener.remove();
      this.onLogoutListener.remove();
    }
    // //移除安卓物理返回键监听
    // if (Platform.OS === 'android') {
    //   BackHandler.removeEventListener('hardwareBackPress',()=>{});
    // }
  }

  render(){

    if(!StringUtil.isEmpty(this.props.orderNo)){
      return <OrderDetail orderNo={this.props.orderNo}/>
    }

    if(this.props.page === 'MobileLegends'){
      return <MobileLegends/>
    }else {
      return <PUBG/>
    }
  }
}

