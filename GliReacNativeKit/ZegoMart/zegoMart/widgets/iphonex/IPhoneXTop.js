import React from "react";
import {NativeModules, Platform, StatusBar, StyleSheet, View} from "react-native";
import {getIphoneXTopHeight} from "../../utils/AppUtil";

const { StatusBarManager } = NativeModules;


export default class IPhoneXTop extends React.Component {
    constructor(props) {
        super(props);
    }

    getWidgetHeight(){
        return getIphoneXTopHeight();
    }

    render() {
        if(Platform.OS === 'android'){
           return <StatusBar translucent={false} barStyle='light-content' backgroundColor='#2C2D31'/>
        }else {
            let {style} = this.props;
            return <View style={[styles.top, style]}/>
        }
    }
}

const styles = StyleSheet.create({
    top: {
        height: getIphoneXTopHeight(),
        width: '100%',
        backgroundColor: '#2C2D31'
    }
});