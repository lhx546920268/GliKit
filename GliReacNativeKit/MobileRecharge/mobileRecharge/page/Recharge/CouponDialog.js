import React from 'react';
import {View, Text, Image, KeyboardAvoidingView, TouchableOpacity, TextInput, FlatList, Animated, TouchableWithoutFeedback, Keyboard} from 'react-native';
import {dividerColor, titleTextColor} from "../../res/Colors";
import {close_btn, tick_n, tick_s} from "../../res/Image";
import {getString} from "../../basic/utils/LauguageUtils";
import {getIphoneXBottomHeight, SCREEN_WIDTH} from "../../basic/utils/AppUtil";
import IPhoneXBottom from "../../basic/components/IPhoneXBottom";
import PropTypes from 'prop-types'
import {get} from "../../basic/utils/HttpUtils";
import {formatMoney, formatTimeStamp, isEmpty} from "../../basic/utils/StringUtil";
import {showNativeErrorToast} from "../../basic/utils/NativeMethodUtil";

//不使用优惠券
export const COUPON_CODE_DO_NOT_USE = "doNotUse";

//优惠券弹窗
export default class CouponDialog extends React.Component{

    static defaultProps = {
        couponData: null, //优惠券信息
        onUseCoupon: null, //使用某个优惠券 参数为空 表示不使用
        orderAmount: 0, //当前订单金额
        usedCouponCode: null, //当前使用的优惠码
    };

    static propsTypes = {
        couponData: PropTypes.object,
        onUseCoupon: PropTypes.func,
        orderAmount: PropTypes.number,
        usedCouponCode: PropTypes.string,
    };

    constructor(props){
        super(props);

        //添加 不使用优惠券item 和 输入优惠码item
        let couponData = props.couponData;
        if(!couponData){
            couponData = [];
        }

        //判断是否已加了
        if(!(couponData.length >= 2 && couponData[couponData.length - 2].couponCode === COUPON_CODE_DO_NOT_USE)){
            couponData.push({couponCode: COUPON_CODE_DO_NOT_USE}, {});
        }

        //输入的优惠码
        let couponCode = couponData[couponData.length - 1].couponCode;

        this.state = {
            data: couponData, //充值数据
            orderAmount: props.orderAmount, //当前订单金额
            usedCouponCode: props.usedCouponCode, //当前使用的优惠码
            transformYAnim: new Animated.Value(0), //弹窗y轴初始值
            opacityAnim: new Animated.Value(0), //透明度动画
            couponCode: couponCode ? couponCode : null, //输入的优惠码
        };
    }

    componentDidMount(){
        Animated.parallel([Animated.timing(
            this.state.transformYAnim,
            {
                toValue: 1,
                duration: 250
            }
        ), Animated.timing(
            this.state.opacityAnim,
            {
                toValue: 1,
                duration: 250
            }
        )]).start();
    }

    //隐藏弹窗
    dismissDialog(){
        Animated.parallel([Animated.timing(
            this.state.transformYAnim,
            {
                toValue: 0,
                duration: 250
            }
        ), Animated.timing(
            this.state.opacityAnim,
            {
                toValue: 0,
                duration: 250
            }
        )]).start();
        setTimeout(() => {
            if(this.props.onClose != null){
                this.props.onClose();
            }
        }, 250);
    }

    //点击某个item
    _handleClickItem(index){
        Keyboard.dismiss();
        if(this.state.data.length - 1 === index){
            this._getCouponItem();
            return;
        }
        this._useCoupon(index);
    }

    //根据优惠码获取优惠券信息
    _getCouponItem(){
        const {couponCode} = this.state;
        if(isEmpty(couponCode)){
            showNativeErrorToast(getString().enterCouponCode);
            return;
        }

        let index = this.state.data.length - 1;
        let item = this.state.data[index];
        if(item.couponCode === couponCode){
            this._useCoupon(index);
        }else {
            get("/zegobird-recharge/coupon/findCouponByCode", {
                couponCode: couponCode
            }, true, true, 0.5).then((response) => {
                const data = response.data;
                Object.assign(item, {
                    couponCode: data.couponCode,
                    discountAmount: data.discountAmount,
                    conditionAmount: data.monetary,
                    title: data.couponName,
                    endTimeStamp: data.endTime,
                    endTime: formatTimeStamp(data.endTime, "yyyy-MM-dd")
                });
                console.log(this.state.data[index]);
                this._useCoupon(index)
            }, () => {})
        }
    }

    //使用某个优惠券
    _useCoupon(index){
        let item = this.state.data[index];
        if(item.conditionAmount > this.state.orderAmount){
            showNativeErrorToast("The recharge amount must be greater than " + item.conditionAmount);
            return;
        }

        this.setState({
            usedCouponCode: item.couponCode
        });
        if(this.props.onUseCoupon){
            this.props.onUseCoupon(item);
        }
        this.dismissDialog()
    }


    //输入优惠码改变
    _onChangeText(text){
        this.state.couponCode = text;
        let {data} = this.state;
        let index = data.length - 1;
        let item = data[index];
        //优惠码改变了 要清空以前的信息
        if(item.couponCode && item.couponCode !== text){
            data.pop();
            data.push({});
            this.setState({
                data: data
            });

            if(this.props.onUseCoupon){
                this.props.onUseCoupon(null);
            }
        }
    }

    //获取item
    _getItem(item, index){

        if(this.state.data.length - 1 === index){
            return this._getEnterCouponCodeItem(item, index);
        }

        if(this.state.data.length - 2 === index){
            return this._getDoNotUseCouponItem(item, index);
        }

        let enable = item.conditionAmount <= this.state.orderAmount;
        let leftColor = enable ? '#FFC22D' : '#999999';
        let rightColor = enable ? 'white' : '#cccccc';

        let rightView = null;
        if(enable){
            rightView = <TouchableOpacity style={{width: 40, height: 85, justifyContent: 'center', alignItems: 'center'}} onPress={() => this._handleClickItem(index)}>
                <CheckBox checked={this.state.usedCouponCode === item.couponCode}/>
            </TouchableOpacity>
        }else {
            rightView = <Text allowFontScaling={false} style={{fontSize: 12, color: 'gray'}}>Unavailable</Text>
        }

        return <View style={{width: SCREEN_WIDTH - 30, alignItems: 'center', flexDirection: 'row', borderRadius: 5, borderWidth: 1, borderColor: leftColor, marginBottom: 10, marginHorizontal: 15, marginTop: index === 0 ? 10 : 0}}>
            <View style={{width: SCREEN_WIDTH - 30 - 85 - 2, height: 85, paddingHorizontal: 15, backgroundColor: leftColor, borderTopLeftRadius: 5, borderBottomLeftRadius: 5}}>
                <View style={{flexDirection: 'row', alignItems: 'baseline', marginTop: 10}}>
                    <Text allowFontScaling={false} style={{color: 'white', fontSize: 21, marginTop: 5}}>{formatMoney(item.discountAmount)}</Text>
                    <Text allowFontScaling={false} style={{color: 'white', fontSize: 12}}>off {formatMoney(item.conditionAmount)}+</Text>
                </View>
                <Text allowFontScaling={false} style={{color: 'white', fontSize: 10, marginTop: 3}}>{item.title}</Text>
                <Text allowFontScaling={false} style={{color: 'white', fontSize: 10, marginTop: 5}}>Expires: {item.endTime}</Text>
            </View>
            <View style={{width: 85, height: 85, justifyContent: 'center', alignItems: 'center',
                marginRight: 2, backgroundColor: rightColor, borderTopRightRadius: 5, borderBottomRightRadius: 5}}>
                {rightView}
            </View>
        </View>
    }

    //获取不使用优惠券item
    _getDoNotUseCouponItem(item, index){
        return <View style={{width: SCREEN_WIDTH - 30, alignItems: 'center', flexDirection: 'row',
            justifyContent: 'space-between', backgroundColor: 'white', borderRadius: 5, borderWidth: 1, borderColor: '#999999',
            marginBottom: 10, marginHorizontal: 15, marginTop: index === 0 ? 10 : 0}}>
            <Text allowFontScaling={false} style={{color: titleTextColor, fontSize: 15, marginLeft: 15}}>{getString().doNotUseCoupons}</Text>
            <View style={{width: 85, height: 85, alignItems: 'center', justifyContent: 'center', borderLeftColor: '#999999', borderLeftWidth: 1}}>
                <TouchableOpacity style={{width: 40, height: 85, justifyContent: 'center', alignItems: 'center'}} onPress={() => this._handleClickItem(index)}>
                    <CheckBox checked={this.state.usedCouponCode === item.couponCode}/>
                </TouchableOpacity>
            </View>
        </View>
    }

    //获取输入优惠码item
    _getEnterCouponCodeItem(item, index){
        return <View style={{width: SCREEN_WIDTH - 30, alignItems: 'center', flexDirection: 'row',
            justifyContent: 'space-between', backgroundColor: 'white', borderRadius: 5, borderWidth: 1, borderColor: '#999999',
            marginBottom: 10, marginHorizontal: 15, marginTop: index === 0 ? 10 : 0}}>
            <TextInput allowFontScaling={false}
                       defaultValue={this.state.couponCode}
                       inputAccessoryViewTitle="OK"
                       onChangeText={this._onChangeText.bind(this)}
                       placeholder={getString().enterCouponCode} style={{color: titleTextColor, fontSize: 15, marginLeft: 15,
                paddingVertical: 0, width: SCREEN_WIDTH - 30 - 15 * 2 - 85, height: 40}}/>
            <View style={{width: 85, height: 85, alignItems: 'center', justifyContent: 'center', borderLeftColor: '#999999', borderLeftWidth: 1}}>
                <TouchableOpacity style={{width: 40, height: 85, justifyContent: 'center', alignItems: 'center'}} onPress={() => this._handleClickItem(index)}>
                    <CheckBox checked={this.state.usedCouponCode === item.couponCode}/>
                </TouchableOpacity>
            </View>
        </View>
    }

    render(){
        let height = 400 + getIphoneXBottomHeight();
        return <KeyboardAvoidingView behavior='padding'
                                     style={{flex: 1}}>
            <View style={{flex: 1}}>
                <TouchableWithoutFeedback onPress={this.dismissDialog.bind(this)}>
                    <Animated.View style={{position: 'absolute', width: '100%', height: '100%', backgroundColor: "#00000066", opacity: this.state.opacityAnim}}/>
                </TouchableWithoutFeedback>
                <Animated.View style={{width: SCREEN_WIDTH, height: height, position: 'absolute', bottom: this.state.transformYAnim.interpolate({
                        inputRange: [0, 1],
                        outputRange: [-height, 0]
                    }), backgroundColor: 'white', alignItems: 'center'}}>
                    <View style={{borderBottomColor: dividerColor, borderBottomWidth: 0.5, width: SCREEN_WIDTH, height: 50, justifyContent: 'center', alignItems: 'center'}}>
                        <Text allowFontScaling={false} style={{color: titleTextColor, fontSize: 16}}>{getString().coupon}</Text>
                        <TouchableOpacity activeOpacity={0.7}
                                          onPress={this.dismissDialog.bind(this)}
                                          style={{position: 'absolute', right: 0, top: 0, bottom: 0, paddingVertical: 15, paddingHorizontal: 15}}>
                            <Image source={close_btn} style={{width: 20, height: 20}}/>
                        </TouchableOpacity>
                    </View>

                    <FlatList style={{flex: 1}} data={this.state.data}
                              keyboardShouldPersistTaps="handled"
                              alwaysBounceVertical={false}
                              keyExtractor={(item, index) => index.toString()}
                              ListFooterComponent={() => {
                                  return <IPhoneXBottom/>;
                              }}
                              renderItem={({item, index}) => {
                                  return this._getItem(item, index);
                              }}/>
                </Animated.View>
            </View>
        </KeyboardAvoidingView>
    }
}

//打钩和未打钩
class CheckBox extends React.Component{

    static defaultProps = {
        checked : false
    };
    static propTypes = {
        checked : PropTypes.bool
    };

    render(){
        return (
            <Image style={{width: 20, height: 20}} source={this.props.checked ? tick_s : tick_n}/>
        )
    }
}
