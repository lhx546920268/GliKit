import React from 'react';
import {View, KeyboardAvoidingView, Text, Image, TouchableOpacity, TextInput} from 'react-native';
import {contentLightTextColor, mainColor, titleTextColor} from "../../res/Colors";
import {close_btn} from "../../res/Image";
import {getString} from "../../basic/utils/LauguageUtils";
import PropTypes from 'prop-types'
import {formatMoney} from "../../basic/utils/StringUtil";

//话费充值其他金额
export default class MobileRechargeOther extends React.Component{

    static defaultProps = {
        onClose: null, //关闭了
        onBuyCountChange: null, //购买数量改变
        onRecharge: null, //点击充值
        price: 0, //商品单价
    };

    static propsTypes = {
        onClose: PropTypes.func,
        onBuyCountChange: PropTypes.func,
        onRecharge: PropTypes.func,
        price: PropTypes.number,
    };

    constructor(props){
        super(props);

        let buyCount = props.buyCount;
        if(!buyCount){
            buyCount = 1;
        }
        if(buyCount < 1){
            buyCount = 1;
        }else if(buyCount > 200){
            buyCount = 200;
        }

        this.hasChangeText = buyCount > 1; //是否已改变文字
        this.state = {
            price: props.price, //商品单价
            buyCount: buyCount, //购买数量
            redWarning: false, //是否显示红色警
        }
    }

    //输入内容改变
    _handleTChangeText(text){

        let value = parseInt(text);
        let warning = false;
        if(isNaN(value)){
            value = 1;
            warning = true;
            this.hasChangeText = false;
        }else {
            if(!this.hasChangeText){
                this.hasChangeText = true;
                value = value % 10;
            }

            if(value < 1){
                value = 1;
                warning = true;
            }else if(value > 200){
                value = 200;
                warning = true;
            }
        }

        this.setState({
            buyCount: value,
            redWarning: warning
        });

        if(this.props.onBuyCountChange){
            this.props.onBuyCountChange(value);
        }
    }

    render(){

        return <KeyboardAvoidingView behavior='padding'
                                     style={{flex: 1, alignItems: 'center', justifyContent: 'center', backgroundColor: '#00000066'}}>
            <View style={{width: 245, backgroundColor: 'white', borderRadius: 15, alignItems: 'center'}}>
                <Text allowFontScaling={false} style={{color: titleTextColor, fontSize: 14, marginTop: 12}}>Other Amount</Text>
                <TouchableOpacity activeOpacity={0.7}
                                  onPress={this.props.onClose}
                                  style={{position: 'absolute', right: 0, top: 0, paddingVertical: 12, paddingHorizontal: 15}}>
                    <Image source={close_btn} style={{width: 20, height: 20}}/>
                </TouchableOpacity>

                <View style={{flexDirection: 'row', alignItems: 'flex-end', justifyContent: 'center', height: 42}}>
                    <TextInput allowFontScaling={false}
                               autoFocus={true}
                               keyboardType="number-pad"
                               underlineColorAndroid='transparent'
                               value={this.state.buyCount.toString()}
                               style={{fontSize: 22, width: 100, color: titleTextColor, textAlign: 'right', paddingVertical: 0}}
                               maxLength={4} onChangeText={(text) => {
                        this._handleTChangeText(text);
                    }}/>
                    <Text allowFontScaling={false} style={{fontSize: 22, width: 100, color: titleTextColor}}>,000</Text>
                </View>
                <Text allowFontScaling={false} style={{color: (this.state.redWarning ? 'red' : contentLightTextColor), fontSize: 10, marginTop: 5}}>{getString().mobileRechargeLimit}</Text>
                <TouchableOpacity activeOpacity={0.7}
                                  onPress={() => {
                                      this.props.onRecharge(this.state.buyCount);
                                  }}
                                  style={{marginVertical: 10, marginHorizontal: 10, height: 30, width: 245 - 20, borderRadius: 15,
                                      backgroundColor: mainColor, justifyContent: 'center', alignItems: 'center'}}>

                    <Text style={{fontSize: 14, color: 'white'}}>{formatMoney(this.state.buyCount * this.state.price) + " Recharge"}</Text>
                </TouchableOpacity>
            </View>
        </KeyboardAvoidingView>
    }
}
