import React from 'react';
import {View, Text, FlatList, TouchableOpacity, Image, Modal} from 'react-native';
import {mainColor, mainTintColor, titleTextColor} from "../../res/Colors";
import {SCREEN_WIDTH} from "../../basic/utils/AppUtil";
import {recharge_text_notice} from "../../res/Image";
import RechargeFooter from "./RechargeFooter";
import MobileRechargeOther from "./MobileRechargeOther";
import {formatMoney} from "../../basic/utils/StringUtil";
import {nativeZegoPay, showNativeAlert, showNativeErrorToast} from "../../basic/utils/NativeMethodUtil";
import {getString} from "../../basic/utils/LauguageUtils";
import EmptyView from "../../basic/components/EmptyView";
import {post} from "../../basic/utils/HttpUtils";
import {getAccessKey, getCurrentUserInfo} from "../../basic/config/AppConfig";
import PropTypes from 'prop-types'
import {COUPON_CODE_DO_NOT_USE} from "./CouponDialog";

//话费充值
export default class MobileRecharge extends React.Component{

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

    constructor(props) {
        super(props);

        this.rechargeData = props.data; //充值信息
        this.couponData = []; //优惠券信息
        if(props.couponData){
            this.couponData = this.couponData.concat(props.couponData);
        }
        this.usedCouponCode = null; //当前使用的优惠码

        this.state = {
            data: this._getDefaultData(), //充值数据
            selectedIndex: -1, //当前选中的
            showOther: false, //是否显示其他
            hasDetectOperator: false, //是否已识别出运营商
        };

        //其他金额购买数量
        this.otherAmountBuyCount = 1;
        this.itemSize = {
            width: (SCREEN_WIDTH - 15 * 4) / 3,
            height: 65
        };

        //是否已匹配到联系人
        this.matchContact = false;
    }

    //运营商改变了
    onOperatorChange(operator, mobile, contactData){
        this.mobile = mobile;
        this.otherAmountBuyCount = 1;
        this.matchContact = contactData !== null;

        if(!operator || operator.length === 0){
            //取消选中
            if(this.state.selectedIndex !== -1){
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
        const data = this.rechargeData;
        let result = null;
        let goodsList = null;
        if(data){
            goodsList = data[operator];
            if(goodsList && goodsList.length > 0){
                result = operator;
            }
        }

        let selectedIndex = this.state.selectedIndex;

        if(result && selectedIndex === -1){
            selectedIndex = 1;
        }else if(!result){
            selectedIndex = -1;
        }
        this.setState({
            hasDetectOperator: result !== null,
            data: goodsList ? goodsList : this._getDefaultData(),
            selectedIndex: selectedIndex
        }, () => {
            this._onContentChange();
        });

        return result;
    }

    //获取默认的显示数据
    _getDefaultData(){
        let data = null;
        if(this.rechargeData){
            let keys = Object.keys(this.rechargeData);
            if(keys.length > 0){
                //给个默认显示的数据
                data = this.rechargeData[keys[0]];
            }
        }
        return data;
    }

    //点击某个item
    _handleClickItem(index){

        if(!this.state.hasDetectOperator){
            if(!this.mobile){
                showNativeErrorToast(getString().rechargeMobileEmpty);
                return;
            }
            if(!this.state.hasDetectOperator){
                showNativeErrorToast(getString().rechargeMobileErrorTip);
                return;
            }
        }

        const item = this.state.data[index];
        if(item.value === 0){
            this.setState({
                showOther: true,
                selectedIndex: index
            }, () => {
                this._onContentChange();
            });
        }else {
            if(index !== this.state.selectedIndex){
                this.setState({
                    selectedIndex: index
                }, () => {
                    this._onContentChange();
                })
            }
        }
    }

    //选中的内容变了
    _onContentChange(){
        if(this.rechargeFooter){
            let item = null;
            if(this.state.selectedIndex >= 0){
                item = this.state.data[this.state.selectedIndex];
            }
            let buyCount = 1;
            if(item && item.value === 0){
                buyCount = this.otherAmountBuyCount;
            }
            this.rechargeFooter.onContentChange(item ? item.price * buyCount : 0);
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

        let buyCount = 1;
        if(item && item.value === 0){
            buyCount = this.otherAmountBuyCount;
        }

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
            rechargeNum: buyCount
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

        let color = index === this.state.selectedIndex ? mainTintColor : titleTextColor;
        let backgroundColor = index === this.state.selectedIndex ? mainColor : '#e9e9e9';
        let value = item.value;
        let price = item.price;

        if(!this.state.hasDetectOperator){
            price = null;
        }

        let last = value === 0;
        if(last){
            value = "Other";
            price = "Amount";
        }else if(price > 0) {
            price = formatMoney(price);
        }

        let priceView = null;
        if(price){
            priceView = <Text allowFontScaling={false} style={{color: color, fontSize: (last ? 22 : 14), fontWeight: (last ? '600' : 'normal'), marginTop: (last ? 0 : 5)}}>{price}</Text>;
        }

        return <TouchableOpacity activeOpacity={0.7} onPress={() => {
            this._handleClickItem(index);
        }}>

            <View style={{width: this.itemSize.width, height: this.itemSize.height, alignItems: 'center',
                justifyContent: 'center', backgroundColor: backgroundColor, borderRadius: 10, marginTop: 15, marginLeft: 15}}>

                <Text allowFontScaling={false} style={{color: color, fontSize: 22, fontWeight: '600'}}>{value}</Text>
                {priceView}
            </View>
        </TouchableOpacity>
    }

    render(){

        if(!this.state.data || this.state.data.length === 0){
            return <EmptyView style={{flex: 1}}/>;
        }

        let otherAmountPrice = 0;
        if(this.state.selectedIndex !== -1){
            otherAmountPrice = this.state.data[this.state.selectedIndex].price;
        }

        return <View style={{width: SCREEN_WIDTH}}>

            <Text allowFontScaling={false} style={{fontSize: 14, color: titleTextColor, marginLeft: 15}}>Phone Top Up</Text>
            <Text allowFontScaling={false} style={{color: '#999999', fontSize: 12, marginLeft: 15, marginTop: 15}}>Amount:</Text>

            <FlatList numColumns={3} data={this.state.data}
                      alwaysBounceVertical={false}
                      keyExtractor={(item, index) => index.toString()}
                      ListFooterComponent={() => {
                          //底部提示文字
                          let width = SCREEN_WIDTH - 15 * 2;
                          return <Image source={recharge_text_notice} style={{width: width, height: (width * 263 / 694), marginHorizontal: 15, marginVertical: 15}}/>
                      }}
                      renderItem={({item, index}) => {
                          return this._getItem(item, index);
                      }}/>
            <RechargeFooter ref={ref => this.rechargeFooter = ref}
                            couponData={this.couponData}
                            onRecharge={this._handleRecharge.bind(this)} onUseCoupon={(couponItem) => {
                                this.usedCouponCode = couponItem ? couponItem.couponCode : null;
                            }
            }/>
            <Modal animationType="fade"
                   visible={this.state.showOther}
                   transparent={true}
                   onDismiss={() => {
                       if(this.rechargeAfterDismiss){
                           this.rechargeAfterDismiss = false;
                           this._handleRecharge();
                       }
                   }}
                   onRequestClose={() => {
                       this.state.showOther = false;
                   }}>
                <MobileRechargeOther price={otherAmountPrice} buyCount={this.otherAmountBuyCount} onClose={() => {
                    this.setState({
                        showOther: false
                    })
                }} onRecharge={(buyCount) => {

                    this.rechargeAfterDismiss = true;
                    this.otherAmountBuyCount = buyCount;
                    this.setState({
                        showOther: false
                    });

                }} onBuyCountChange={(buyCount) => {
                    this.otherAmountBuyCount = buyCount;
                    this._onContentChange();
                }}/>
            </Modal>
        </View>
    }
}
