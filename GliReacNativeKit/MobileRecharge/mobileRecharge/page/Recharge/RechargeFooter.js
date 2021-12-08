import React from 'react';
import {View, Text, TouchableOpacity, Image, Modal} from 'react-native';
import {contentLightTextColor, dividerColor, mainColor, titleTextColor} from "../../res/Colors";
import PropTypes from 'prop-types'
import {getString} from "../../basic/utils/LauguageUtils";
import {arrow_up} from "../../res/Image";
import {SCREEN_WIDTH} from "../../basic/utils/AppUtil";
import CouponDialog, {COUPON_CODE_DO_NOT_USE} from "./CouponDialog";
import {formatMoney, isEmpty} from "../../basic/utils/StringUtil";

//充值底部
export default class RechargeFooter extends React.Component{

    static defaultProps = {
        couponData: null, //优惠券信息
        activeBackgroundColor: mainColor, //可点击时的背景颜色
        enabled: false, //是否可以点击
        title: "Recharge", //标题
        subtitle: null, //副标题
        tip: null, //文字提示
        onRecharge: null, //充值
        onUseCoupon: null, //使用某个优惠券 参数为空 表示不使用
    };

    static propsTypes = {
        couponData: PropTypes.object,
        activeBackgroundColor: PropTypes.string,
        enabled: PropTypes.bool,
        title: PropTypes.string,
        subtitle: PropTypes.string,
        tip: PropTypes.string,
        onRecharge: PropTypes.func,
        onUseCoupon: PropTypes.func,
    };

    constructor(props){
        super(props);
        this.state = {
            showCoupon: false, //是否显示优惠券
            enabled: props.enabled,
            title: props.title,
            subtitle: props.subtitle,
            couponContent: getString().noPromotionAvailable, //优惠内容
            tip: props.tip,
            selectedCouponItem: null, //当前使用的优惠券
        };

        this.orderAmount = 0; //当前订单金额，不减去优惠
    }

    //点击优惠券
    _handleClickCoupon(){
        this.setState({
            showCoupon: true
        })
    }

    //内容变了
    onContentChange(price){

        this.orderAmount = price;
        let selectedItem = this._getAvailableCoupon(price);
        this._calculateTotalPrice(selectedItem);
    }

    //获取可使用的优惠券
    _getAvailableCoupon(price){
        let selectedItem = null;

        //获取面额最大 并且结束时间最早的
        if(this.props.couponData){
            for(let item of this.props.couponData){

                if(price >= item.conditionAmount && (!selectedItem || item.discountAmount >= selectedItem.discountAmount)){
                    if(selectedItem && item.discountAmount === selectedItem.discountAmount){
                        if(item.endTimeStamp < selectedItem.endTimeStamp){
                            selectedItem = item;
                        }
                    }else{
                        selectedItem = item;
                    }
                }
            }
        }

        return selectedItem;
    }

    //计算价格
    _calculateTotalPrice(couponItem){
        if(this.props.onUseCoupon){
            this.props.onUseCoupon(couponItem);
        }

        let orderAmount = this.orderAmount;
        let enable = orderAmount > 0;
        const hasCoupon = couponItem && !isEmpty(couponItem.couponCode) && couponItem.couponCode !== COUPON_CODE_DO_NOT_USE;

        if(hasCoupon){
            orderAmount -= couponItem.discountAmount;
            if(orderAmount < 0){
                orderAmount = 0;
            }
        }

        let title = enable ? (formatMoney(orderAmount) + " Recharge") : "Recharge";
        if(this.state.enabled !== enable || this.state.title !== title || this.state.selectedCouponItem !== couponItem){
            let couponContent = null;
            if(couponItem){
                if(hasCoupon){
                    couponContent = formatMoney(couponItem.discountAmount) + " off " + formatMoney(couponItem.conditionAmount) + "+";
                }else {
                    couponContent = getString().doNotUseCoupons;
                }
            }else {
                couponContent = getString().noPromotionAvailable;
            }
            this.setState({
                enable,
                title,
                selectedCouponItem: couponItem,
                couponContent
            })
        }
    }

    //支付取消
    onPayCancel(){

        //清除已使用的优惠券
        if(this.props.couponData){
            let {selectedCouponItem} = this.state;
            if(selectedCouponItem && selectedCouponItem.couponCode !== COUPON_CODE_DO_NOT_USE) {
                let index = this.props.couponData.findIndex((item) => {
                    return selectedCouponItem.couponCode === item.couponCode;
                });

                let count = this.props.couponData.length;
                this.props.couponData.splice(index, 1);
                //如果是输入的优惠券 重新添加
                if(index === count - 1){
                    this.props.couponData.push({});
                }
                this._calculateTotalPrice(null);
            }
        }
    }

    render(){
        const {subtitle, tip, selectedCouponItem} = this.state;
        let subtitleView = null;
        if(!isEmpty(subtitle)){
            subtitleView = <Text allowFontScaling={false} style={{fontSize: 12, color: 'white'}}>{subtitle}</Text>;
        }
        let tipView = null;
        if(!isEmpty(tip)) {
            tipView = <Text allowFontScaling={false}
                            style={{fontSize: 12, color: contentLightTextColor, marginHorizontal: 17, marginTop: 10, textAlign: 'center', alignSelf: 'center'}}>{tip}</Text>;
        }

        return <View style={{borderTopWidth: 0.5, borderTopColor: dividerColor}}>
            {tipView}

            <View style={{height: 45, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between'}}>
                <Text allowFontScaling={false} style={{marginLeft: 15, fontSize: 14, color: titleTextColor}}>{getString().coupon}</Text>
                <TouchableOpacity activeOpacity={0.7} onPress={this._handleClickCoupon.bind(this)} style={{paddingRight: 10, paddingVertical: 5, flexDirection: 'row', alignItems: 'center'}}>
                    <Text allowFontScaling={false} style={{fontSize: 14, color: 'red'}}>{this.state.couponContent}</Text>
                    <Image source={arrow_up} style={{width: 20, height: 20}}/>
                </TouchableOpacity>
            </View>

            <TouchableOpacity activeOpacity={0.7}
                              onPress={this.props.onRecharge}
                              disabled={!this.state.enable}
                              style={{marginVertical: 15, marginHorizontal: 22, height: 40, width: SCREEN_WIDTH - 44, borderRadius: 20,
                                  backgroundColor: this.state.enable ? this.props.activeBackgroundColor : '#cccccc', justifyContent: 'center', alignItems: 'center'}}>

                <Text style={{fontSize: 16, color: 'white'}}>{this.state.title}</Text>
                {subtitleView}
            </TouchableOpacity>

            <Modal animationType="none" visible={this.state.showCoupon} transparent={true} onRequestClose={() => {
                this.couponDialog.dismissDialog();
            }}>
                <CouponDialog ref={ref => this.couponDialog = ref}
                              couponData={this.props.couponData}
                              usedCouponCode={selectedCouponItem ? selectedCouponItem.couponCode : null}
                              orderAmount={this.orderAmount}
                              onUseCoupon={this._calculateTotalPrice.bind(this)}
                              onClose={() => {
                               this.setState({
                                   showCoupon: false
                               })
                }}/>
            </Modal>
        </View>
    }
}
