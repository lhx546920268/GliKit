import React, {Component} from 'react';
import {Text, View} from "react-native";
import PropTypes from "prop-types";

//角标
export default class BadgeValue extends Component{

    static defaultProps = {
        value: 0, //角标数量
    };

    static propTypes = {
        value: PropTypes.number,
    };

    render(){
        let value = this.props.value;
        if(value === null || value === 0){
            return null;
        }
        if(value > 100){
            value = 99;
        }
        return (
            <View style={[this.props.style, {alignItems:'center', justifyContent:'center', backgroundColor: 'red',  minWidth: 13, minHeight: 13, borderRadius: 6}]}>
                <Text allowFontScaling={false} textAlign='center' style={{color: 'white', fontSize:9}}>{value}</Text>
            </View>
        )
    }
}