import React from 'react';
import {AppNavigation, initAppNavigator} from "./basic/components/AppNavigation";
import {initProps, updateCurrentUserInfo} from "./basic/config/AppConfig";
import {hideNativeLauncherMask, setNativeStatusBarStyle} from "./basic/utils/NativeMethodUtil";
import {EVENT_ON_LOGIN, EVENT_ON_LOGOUT, registerEventToNative} from "./basic/utils/EventUtil";
import {isEmpty} from "./basic/utils/StringUtil";

export default class App extends React.Component {
    constructor(props){
        super(props);

        setNativeStatusBarStyle('white');
        initProps(props);

        if(isEmpty(props.orderNo)){
            initAppNavigator( "Recharge");
        }else {
            initAppNavigator( "OrderDetail", {
                orderNo: props.orderNo
            });
        }
    }

    componentDidMount() {
        hideNativeLauncherMask();
        //登录
        this.onLoginListener = registerEventToNative(EVENT_ON_LOGIN, (userInfo) => {
            updateCurrentUserInfo(userInfo);
        });

        //退出登录
        this.onLogoutListener = registerEventToNative(EVENT_ON_LOGOUT, () => {
            updateCurrentUserInfo(null);
        });
    }

    componentWillUnmount() {
        this.onLoginListener?.remove();
        this.onLogoutListener?.remove();
    }

    render(){
        return <AppNavigation/>
    }
}

