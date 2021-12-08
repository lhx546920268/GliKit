import React, {Component} from 'react'
import {Image, Text, View} from 'react-native'
import {contentLightTextColor} from "../../constraint/Colors";

//页面空视图 icon 图标 text 文字
export default class EmptyView extends Component{
    
    render(){
        return(
            <View style={[{flex:1, justifyContent: 'center', alignItems: 'center'}, this.props.style]}>
                    <Image source={this.props.icon} style={{width: 50, height: 50}}/>
                    <Text allowFontScaling={false} style={{fontSize: 14, textAlign: 'center', color: contentLightTextColor, marginTop: 25, marginLeft: 15, marginRight: 15}}>{this.props.text}</Text>
            </View>
        )
    }
}