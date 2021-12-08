import React, {Component} from 'react'
import {Text, TouchableOpacity, View} from 'react-native'
import PropTypes from "prop-types";
import LinearGradient from "react-native-linear-gradient";

//zegoBird 按钮
export default class ZegobirdButton extends Component {

    static defaultProps = {
        style: null, //样式
        title: null, //标题
        onPress: null, //点击事件
        disabled: false, //是否关闭点击
    };

    static propTypes = {
        style: PropTypes.object,
        title : PropTypes.string,
        onPress : PropTypes.func,
        disabled: PropTypes.bool,
    };

    render() {
        let text;
        if(this.props.disabled){
            text = <View style={{backgroundColor: '#cccccc', flex: 1, alignItems: 'center', justifyContent: 'center'}}>
                <Text allowFontScaling={false} numberOfLines={1} ellipsizeMode='middle' style={{color: 'white', fontSize: 16, fontWeight: 'bold'}}>{this.props.title}</Text>
            </View>
        }else{
            text = <LinearGradient style={{alignItems: 'center', justifyContent: 'center', flex: 1}} 
                    colors={['#FFA919', '#FFC725', '#FFB321']} start={{x: 0, y: 0.5}} end={{x: 1, y: 0.5}}>
                    <Text allowFontScaling={false} numberOfLines={1} ellipsizeMode='middle'  style={{color: 'white', fontSize: 16, fontWeight: 'bold'}}>{this.props.title}</Text>
            </LinearGradient>
        }
        return (
            <TouchableOpacity disabled={this.props.disabled} activeOpacity={0.7} style={[{overflow: 'hidden'}, this.props.style]} onPress={this.props.onPress}>
                {text}
             </TouchableOpacity>
        )
    }
}
