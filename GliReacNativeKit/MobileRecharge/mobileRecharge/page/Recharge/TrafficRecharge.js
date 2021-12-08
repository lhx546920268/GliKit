import React from 'react';
import {View, Text, FlatList, TouchableOpacity} from 'react-native';
import {contentLightTextColor, titleTextColor} from "../../res/Colors";
import {SCREEN_WIDTH} from "../../basic/utils/AppUtil";
import RechargeFooter from "./RechargeFooter";
import {formatMoney, formatString, isEmpty} from "../../basic/utils/StringUtil";
import {getAccessKey, getCurrentUserInfo} from "../../basic/config/AppConfig";
import {post} from "../../basic/utils/HttpUtils";
import {nativeZegoPay, showNativeAlert, showNativeErrorToast} from "../../basic/utils/NativeMethodUtil";
import {getString} from "../../basic/utils/LauguageUtils";
import EmptyView from "../../basic/components/EmptyView";
import PropTypes from 'prop-types'
import {COUPON_CODE_DO_NOT_USE} from "./CouponDialog";

//话费充值
export default class TrafficRecharge extends React.Component{

    static defaultProps = {
        data: null, //充值数据
        couponData: null, //优惠券
        onPaySuccess: null, //支付成功回调
    };

    static propsTypes = {
        data: PropTypes.object,
        couponData: PropTypes.object,
        onPaySuccess: PropTypes.func,
    };

    constructor(props){
        super(props);

        this.trafficData = props.data;
        this.couponData = []; //优惠券信息
        if(props.couponData){
            this.couponData = this.couponData.concat(props.couponData);
        }

        this.usedCouponCode = null; //当前使用的优惠码

        this.state = {
            data: this._getDefaultData(), //充值数据
            selectedIndex: -1, //当前选中的
            hasDetectOperator: false, //是否已识别出运营商
        };

        //是否已匹配到联系人
        this.matchContact = false;
    }

    //运营商改变了
    onOperatorChange(operator, mobile, contactData){
        this.mobile = mobile;
        this.matchContact = contactData !== null;

        if(!operator || operator.length === 0){
            //取消选中
            if(this.state.selectedIndex !== -1 || this.state.hasDetectOperator){
                this.setState({
                    selectedIndex: -1,
                    hasDetectOperator: false,
                    data: this._getDefaultData()
                }, () => {
                    this._onContentChange();
                })
            }
            return null;
        }

        //判断该运营商是否支持充值
        const data = this.trafficData;
        let goodsList = null;
        if(data){
            goodsList = data[operator];
        }

        let selectedIndex = this.state.selectedIndex;

        if(goodsList && selectedIndex === -1){
            selectedIndex = 0;
        }else if(!goodsList){
            selectedIndex = -1;
        }
        this.setState({
            hasDetectOperator: true,
            data: goodsList,
            selectedIndex: selectedIndex
        }, () => {
            this._onContentChange();
        });

        return operator;
    }

    //获取默认的显示数据
    _getDefaultData(){
        let data = null;
        if(this.trafficData){
            let keys = Object.keys(this.trafficData);
            if(keys.length > 0){
                //给个默认显示的数据
                data = this.trafficData[keys[0]];
            }
        }
        return data;
    }

    //点击某个item
    _handleClickItem(index){
        if(!this.state.hasDetectOperator){
            if(!this.mobile){
                showNativeErrorToast(getString().trafficMobileEmptyAlert);
                return;
            }
            if(!this.state.hasDetectOperator){
                showNativeErrorToast(getString().rechargeMobileErrorTip);
                return;
            }
        }

        if(index !== this.state.selectedIndex){
            this.setState({
                selectedIndex: index
            }, () => {
                this._onContentChange();
            })
        }
    }

    //选中的内容变了
    _onContentChange(){
        if(this.rechargeFooter){
            let item = null;

            if(this.state.selectedIndex >= 0){
                item = this.state.data[this.state.selectedIndex];
            }
            this.rechargeFooter.onContentChange(item ? item.price : 0);
        }
    }

    //充值
    _handleRecharge(){
        if(this.matchContact){
            this._recharge();
        }else {
            showNativeAlert({
                subtitle: this.mobile + getString().strangerTip,
                destructiveButtonIndex: 1,
                buttonTitles: [getString().no, getString().yes]
            }, (index) => {
                if(index === 1){
                    this._recharge();
                }
            })
        }
    }

    //充值
    _recharge(){
        const userInfo = getCurrentUserInfo();
        let item = this.state.data[this.state.selectedIndex];
        const query = "goodsType=" + item.goodsType + "&goodsId=" + item.goodsId +
            "&platformId=2&platUserId=" + userInfo.userId + "&userPhone=" + userInfo.mobile;

        post("/zegobird-recharge/recharge/user/submitOrder?" + query, {
            goodsType: item.goodsType,
            goodsId: item.goodsId,
            platformId: 2,
            platUserId: userInfo.userId,
            userPhone: userInfo.mobile,
            account: userInfo.username,
            accessKey: getAccessKey(),
            zegoToken: userInfo.token,
            couponCode: (this.usedCouponCode && this.usedCouponCode !== COUPON_CODE_DO_NOT_USE) ? this.usedCouponCode : '',
            mobile: this.mobile,
            rechargeNum: 1
        }, true, true).then((response) => {
            this._pay(response.data.order);
        }, () => {

        })
    }

    //支付
    _pay(data){
        let params = {
            ticket: data.ticket, //支付ticket
            foid: data.foid, //支付交易号
            goods_name: data.fname,
            mch_id: data.merchantId, //商户号
            notify_url: data.url, //回调地址
            out_trade_no: data.orderNumber, //订号
            total_fee: data.money  //支付金额
        };
        nativeZegoPay(params, (response) => {
            if(response.result === 1){
                if(this.props.onPaySuccess){
                    this.props.onPaySuccess();
                }
            }else {
                if(this.rechargeFooter){
                    this.rechargeFooter.onPayCancel();
                }
            }
        })
    }

    //获取item
    _getItem(item, index){

        let color = index === this.state.selectedIndex ? 'white' : titleTextColor;
        let backgroundColor = index === this.state.selectedIndex ? '#333333' : '#e9e9e9';
        let subtitleView = null;
        if(!isEmpty(item.subtitle)){
            subtitleView = <Text allowFontScaling={false} style={{color: color, fontSize: 14, marginTop: 5}}>{item.subtitle}</Text>;
        }

        return <TouchableOpacity activeOpacity={0.7} onPress={() => {
            this._handleClickItem(index);
        }}>

            <View style={{width: SCREEN_WIDTH - 30, height: 60, flexDirection: 'row', alignItems: 'center',
                justifyContent: 'space-between', backgroundColor: backgroundColor, borderRadius: 10, marginBottom: 15, marginHorizontal: 15}}>
                <View style={{marginLeft: 15}}>
                    <Text allowFontScaling={false} style={{color: color, fontSize: 18}}>{item.title}</Text>
                    {subtitleView}
                </View>
                <View style={{marginRight: 15, alignItems: 'flex-end'}}>
                    <Text allowFontScaling={false} style={{color: color, fontSize: 16}}>{formatMoney(item.price)}</Text>
                    <Text allowFontScaling={false} style={{color: contentLightTextColor, textDecorationLine: 'line-through', fontSize: 12, marginTop: 5}}>{formatMoney(item.value)}</Text>
                </View>
            </View>
        </TouchableOpacity>
    }

    render(){

        let operatorNames = "";
        let keys = null;
        if(this.trafficData){
            keys = Object.keys(this.trafficData);
        }

        if(keys && keys.length > 0){
            for(let i = 0;i < keys.length;i ++){
                operatorNames += keys[i];
                if(i !== keys.length - 1){
                    operatorNames += "，";
                }
            }

            let contentView = null;
            if(this.state.data && this.state.data.length > 0){
                contentView = <FlatList data={this.state.data}
                                        alwaysBounceVertical={false}
                                        keyExtractor={(item, index) => index.toString()}
                                        renderItem={({item, index}) => {
                                            return this._getItem(item, index);
                                        }}/>;
            }else {
                contentView = <EmptyView text={getString().trafficOperatorNotSupport}/>
            }

            return <View style={{flex: 1, width: SCREEN_WIDTH}}>

                <Text allowFontScaling={false} style={{fontSize: 14, color: titleTextColor, marginRight: 15, alignSelf: 'flex-end'}}>Data Package</Text>
                <Text allowFontScaling={false} style={{color: '#999999', fontSize: 12, marginLeft: 15, marginTop: 15, marginBottom: 15}}>Data:</Text>

                {contentView}
                <RechargeFooter ref={ref => this.rechargeFooter = ref}
                                tip={formatString(getString().trafficTip, [operatorNames])}
                                couponData={this.couponData}
                                activeBackgroundColor='#333333'
                                onRecharge={this._handleRecharge.bind(this)}
                                onUseCoupon={(couponItem) => {
                                    this.usedCouponCode = couponItem ? couponItem.couponCode : null;
                                }}/>
            </View>
        }else {
            return <EmptyView style={{flex: 1}} text={getString().trafficNotSupport}/>;
        }
    }
}
