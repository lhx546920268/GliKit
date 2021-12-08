import React from "react";
import {NativeModules, Platform, StatusBar, StyleSheet, View} from "react-native";
import {getIphoneXTopHeight} from "../utils/AppUtil";

export default class IPhoneXTop extends React.Component {
    constructor(props) {
        super(props);
    }

    getWidgetHeight(){
        return getIphoneXTopHeight();
    }

    render() {
        if(Platform.OS === 'android'){
            let backgroundColor = styles.top.backgroundColor;
            if(this.props.style && this.props.style.backgroundColor){
                backgroundColor = this.props.style.backgroundColor;
            }
            return <StatusBar translucent={false} barStyle='light-content' backgroundColor={backgroundColor}/>
        }else {
            return <View style={[styles.top, this.props.style]}/>
        }
    }
}

const styles = StyleSheet.create({
    top: {
        height: getIphoneXTopHeight(),
        width: '100%',
        backgroundColor: '#0FD7C8'
    }
});
