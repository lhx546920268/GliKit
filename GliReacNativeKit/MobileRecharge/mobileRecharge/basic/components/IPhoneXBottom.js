import React from "react";
import {StyleSheet, View} from "react-native";
import {isIphoneX} from "react-native-iphone-x-helper";
import {getIphoneXBottomHeight} from "../utils/AppUtil";


export default class IPhoneXBottom extends React.Component {
    constructor(props) {
        super(props);
        this.widgetHeight = 0;

        if(this.props.style){
          if(this.props.style.height){
              this.widgetHeight = this.props.style.height;
          }
        }
    }

    render() {
        let {style} = this.props;
        return (
            isIphoneX() ?
                <View style={[styles.defaultStyle, style]}/> : null
        )
    }
}

const styles = StyleSheet.create({
    defaultStyle: {
        height: getIphoneXBottomHeight(),
        width: '100%',
        backgroundColor: 'white'
    }
});
