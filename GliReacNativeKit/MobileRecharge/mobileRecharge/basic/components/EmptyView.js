import React, {Component} from 'react'
import {Image, Text, View} from 'react-native'
import {contentLightTextColor} from "../../res/Colors";
import PropTypes from 'prop-types'
import {goods_empty} from "../../res/Image";
import {getString} from "../utils/LauguageUtils";

//页面空视图
export default class EmptyView extends Component{

    static defaultProps = {
        icon: null, //图标
        text: null, //文字
    };

    static propsTypes = {
        icon: PropTypes.object,
        text: PropTypes.string,
    };

    render(){
        let icon = this.props.icon;
        let text = this.props.text;
        if(!icon){
            icon = goods_empty;
        }
        if(!text){
            text = getString().nothing;
        }

        return(
            <View style={[{flex:1, justifyContent: 'center', alignItems: 'center'}, this.props.style]}>
                    <Image source={icon} style={{width: 50, height: 50}}/>
                    <Text allowFontScaling={false} style={{fontSize: 14, textAlign: 'center', color: contentLightTextColor, marginTop: 25, marginLeft: 15, marginRight: 15}}>{text}</Text>
            </View>
        )
    }
}
