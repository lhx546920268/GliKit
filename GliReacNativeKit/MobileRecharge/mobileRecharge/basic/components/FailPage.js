import React, {Component} from 'react'
import {Image, Text, TouchableOpacity, View} from 'react-native'
import {load_fail} from '../../res/Image'
import {contentLightTextColor, titleTextColor} from '../../res/Colors'
import {getString} from "../utils/LauguageUtils";
import PropTypes from 'prop-types'

//失败页面 onReload 重新加载
export default class FailPage extends Component{

    static defaultProps = {
        onReload: null, //重新加载回调
    };

    static propsTypes = {
        onReload: PropTypes.func,
    };

    render(){
        return (
            <View style={[this.props.style, {flex: 1, alignItems: 'center', justifyContent: 'center'}]}>
                <Image source={load_fail} style={{width: 50, height: 50}}/>
                <Text allowFontScaling={false} style={{color: contentLightTextColor, fontSize: 14, marginTop: 25}}>{getString().loadFailTip}</Text>

                <TouchableOpacity activeOpacity={0.5} onPress={() => this.props.onReload()} style={{width: 100, height: 30, borderRadius: 15, borderWidth: 0.5, borderColor: '#cccccc',
                marginTop: 50, alignItems: 'center', justifyContent: 'center'}}>
                    <Text allowFontScaling={false} style={{color: titleTextColor, fontSize: 14}}>{getString().refresh}</Text>
                </TouchableOpacity>
            </View>
        )
    }
}
