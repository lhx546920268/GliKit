import React, {Component} from 'react'
import {Image, View} from 'react-native'
import {loading} from "../../res/Image";

//页面加载中
export default class Loading extends Component{

    render(){
        return(
            <View style={[this.props.style, {flex: 1, alignItems: 'center', justifyContent: 'center'}]}>
                <Image source={loading} style={[{width: 100, height: 50},this.props.imageStyle]}/>
            </View>
        )
    }
}
