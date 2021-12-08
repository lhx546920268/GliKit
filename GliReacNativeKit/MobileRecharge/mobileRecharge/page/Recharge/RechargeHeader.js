
import React from 'react';
import {View, Text, TextInput, Image, TouchableOpacity, Keyboard} from 'react-native';
import {contact} from "../../res/Image";
import {isEmpty} from "../../basic/utils/StringUtil";
import {contentLightTextColor, dividerColor, mainColor, mainTintColor} from "../../res/Colors";
import PropTypes from 'prop-types'
import {pickContact, searchContact} from "../../basic/utils/NativeMethodUtil";
import {operatorForMobile} from "../../basic/utils/MobileRuleUtils";
import {SCREEN_WIDTH} from "../../basic/utils/AppUtil";

//充值头部
export default class RechargeHeader extends React.Component{

    static defaultProps = {
        mobile: null, //默认手机号
        contactName: null, //联系人名称
        onContactsMatch: null, //匹配到的联系人
        onOperatorChange: null, //运营商改变
    };

    static propsTypes = {
        mobile: PropTypes.string,
        contactName: PropTypes.string,
        onContactsMatch: PropTypes.func,
        onOperatorChange: PropTypes.func,
    };

    constructor(props){
        super(props);

        this.state = {
            mobile: props.mobile, //手机号
            operator: null, //运营商名称
            contactName: null, //联系人名称
            isTraffic: this.props.isTraffic, //是否是流量充值
        }
    }

    setTraffic(traffic){
        if(this.state.isTraffic !== traffic){
            this.setState({
                isTraffic: traffic
            });
            this.handleChangeText(this.state.mobile);
        }
    }

    //重置
    reset(){
        this.setState({
            mobile: null,
            operator: null,
            contactName: null
        })
    }

    //输入内容改变
    handleChangeText(text){
        this.setState({
            mobile: text
        }, () => {

            if(!isEmpty(text) && text.length >= 3){
                searchContact(text, (contacts) => {

                    //如果只有一个匹配的 直接使用这个联系人名称
                    let contactData = null;
                    if(contacts && contacts.length === 1 && contacts[0].mobile === text){
                        contactData = contacts[0];
                    }

                    let operator = this._getOperator(text, contactData);
                    let contactName = contactData ? contactData.name : null;

                    this.setState({
                        operator: operator,
                        contactName: contactName,
                        // mobile: text
                    });

                    if(this.props.onContactsMatch){
                        this.props.onContactsMatch(contactData ? null : contacts);
                    }
                });
            }else {
                if(this.props.onContactsMatch){
                    this.props.onContactsMatch(null);
                }
            }
        });
    }

    //点击联系人按钮
    _handleContact(){
        pickContact((data) => {
            let operator = this._getOperator(data.mobile, data);
            this.setState({
                mobile: data.mobile,
                contactName: data.name,
                operator: operator
            })
        });
    }

    //设置联系人
    setContact(contact){
        if(contact){
            Keyboard.dismiss();
            let operator = this._getOperator(contact.mobile, contact);
            this.setState({
                mobile: contact.mobile,
                contactName: contact.name,
                operator: operator
            })
        }
    }

    //获取运营商名称
    _getOperator(mobile, contactData){
        let operator = operatorForMobile(mobile);
        operator = this.props.onOperatorChange(operator, mobile, contactData);
        return operator;
    }

    render(){

        let operatorView = null;
        let contactNameView = null;
        let {operator, contactName} = this.state;

        //运营商名称
        if(!isEmpty(operator)){
            operatorView = <Text allowFontScaling={false}
                                 style={{fontSize: 12, color: mainTintColor, backgroundColor: this.state.isTraffic ? '#333333' : mainColor,
                                     paddingHorizontal: 2, paddingVertical: 1, marginRight: 10}}>{operator}</Text>;
        }

        //手机号关联的联系人
        if(!isEmpty(contactName)){
            contactNameView = <Text allowFontScaling={false}
                                    ellipsizeMode='tail'
                                 style={{fontSize: 12, color: contentLightTextColor, paddingVertical: 1, marginRight: 15}}>{contactName}</Text>;
        }

        return (
            <View>
                <View style={{flexDirection: 'row', justifyContent: 'flex-end', marginTop: 15, marginLeft: 15}}>
                    <TextInput placeholder="Recharge Number"
                               allowFontScaling={false}
                               inputAccessoryViewTitle="OK"
                               placeholderTextColor="#cccccc"
                               keyboardType="number-pad"
                               underlineColorAndroid='transparent'
                               value={this.state.mobile}
                               style={{height: 40, flex: 1, fontSize: (SCREEN_WIDTH <= 320 ? 28 : 32), fontWeight: 'bold', paddingVertical: 0}}
                               maxLength={11} onChangeText={(text) => {
                                    this.handleChangeText(text);
                    }}/>
                    <TouchableOpacity style={{paddingHorizontal: 15, paddingVertical: 10}} activeOpacity={0.7} onPress={this._handleContact.bind(this)}>
                        <Image source={contact} style={{width: 20, height:20}}/>
                    </TouchableOpacity>
                </View>
                <View style={{flexDirection: 'row', justifyContent: 'flex-start', marginTop: 5, marginLeft: 15}}>
                    {operatorView}
                    {contactNameView}
                </View>
                <View style={{width: '100%', height: 0.5, backgroundColor: dividerColor, marginTop: 10}}/>
            </View>
        )
    }
}
