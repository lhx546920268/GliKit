
import React from 'react';
import {View, Text, Image, TouchableOpacity, ScrollView, Animated} from 'react-native';
import BasePageComponent, {STATUS_EMPTY, STATUS_FAIL, STATUS_LOADING, STATUS_NORMAL} from '../../basic/components/BasePageComponent';
import {navigationBarBackgroundColor, navigationBarTintColor} from "../../res/Colors";
import {back_white, order_btn, mobile_recharge, traffic_recharge} from "../../res/Image";
import RechargeHeader from "./RechargeHeader";
import MobileRecharge from "./MobileRecharge";
import TrafficRecharge from "./TrafficRecharge";
import {SCREEN_WIDTH} from "../../basic/utils/AppUtil";
import ContactMatchingResult from "./ContactMatchingResult";
import {get} from "../../basic/utils/HttpUtils";
import {isLogin,initContact, loginNative, searchContact} from "../../basic/utils/NativeMethodUtil";
import {getAccessKey, getCurrentUserInfo, setAccessKey} from "../../basic/config/AppConfig";
import {formatTimeStamp, isEmpty} from "../../basic/utils/StringUtil";
import PropTypes from 'prop-types'
import {ORDER_TYPE_TRAFFIC} from "../Order/OrderModel";
import {getParams} from "../../basic/utils/NavigationUtil";

export default class Recharge extends BasePageComponent{

    static defaultProps = {
        mobile: null, //要充值的手机号
        type: null, //充值类型
    };

    static propsTypes = {
        mobile: PropTypes.string,
        type: PropTypes.number
    };


    constructor(props){
        super(props);

        let mobile = props.mobile;
        if(isEmpty(mobile)){
            mobile = getParams(props, "mobile");
        }

        let type = props.type;
        if(type === null || type === undefined){
            type = getParams(props, "type");
        }

        this.isTraffic = type === ORDER_TYPE_TRAFFIC; //是否在显示流量充值
        Object.assign(this.state, {
            mobileRechargeAnimateLeft: new Animated.Value(this.isTraffic ? 1 : 0), //左边动画
            trafficRechargeAnimateRight: new Animated.Value(this.isTraffic ? 1 : 0), //右边动画
            contacts: null, //匹配到的联系人
            mobile: mobile, //手机号
            contactName: null, //联系人名称
        });

        //是否有内容
        this.hasContent = !isEmpty(mobile);
    }

    componentDidMount() {
        //预加载app联系人
        this._preloadContact();
        this.onReload();
    }

    //预加载app联系人
    _preloadContact(){
        if(isLogin()){
            initContact();
            searchContact("0978", () => {});
        }
    }

    onReload() {
        this.setPageStatus(STATUS_LOADING);
        if(!getAccessKey()){
            this._loadAccessKey();
        }else {
            this._loadRechargeData();
        }
    }

    //加载授权码
    _loadAccessKey(){
        //电商登录后才能获取授权码
        if(isLogin()){
            this._getAccessKey();
        }else {
            loginNative(() => {
                this._preloadContact();
                this._getAccessKey();
            }, () => {
                this.close();
            })
        }
    }

    //获取授权
    _getAccessKey(){
        const userInfo = getCurrentUserInfo();
        get("/zegobird-recharge/getAccessKey", {
            account: userInfo.username,
            plat: 2,
            mobile: userInfo.mobile,
            memberId: userInfo.userId
        }).then((response) => {
            setAccessKey(response.data);
            this._loadRechargeData();
        }, () => {
            this.setPageStatus(STATUS_FAIL);
        })
    }

    //加载充值数据
    _loadRechargeData(){

        //获取充值的商品和优惠券
        const userInfo = getCurrentUserInfo();
        Promise.all([get("/zegobird-recharge/recharge/goods/userGoods", {
            plat: 2
        }), get("/zegobird-recharge/coupon/findAvailableCouponsByUserId", {
            platUserId: userInfo.userId,
            account: userInfo.username,
            accessKey: getAccessKey()
        })]).then(([goodsResponse, couponResponse]) => {

            this._parseRechargeData(goodsResponse.data);
            this._parseCouponData(couponResponse.data);

            if((this.mobileRechargeData)
                || (this.trafficRechargeData)){
                this.setPageStatus(STATUS_NORMAL);
            }else {
                this.setPageStatus(STATUS_EMPTY);
            }
        }, () => {
            this.setPageStatus(STATUS_FAIL);
        })
    }

    //解析充值数据
    _parseRechargeData(response){

        let goodsList = null;
        let dataPackages = null;
        if(response){
            goodsList = response.goodsList;
            dataPackages = response.dataPackages;
        }

        if(goodsList && goodsList.length > 0){

            this.mobileRechargeData = {};
            for(let obj of goodsList){
                const operator = obj.operatorName;
                let datas = this.mobileRechargeData[operator];
                if(!datas){
                    datas = [];
                    this.mobileRechargeData[operator] = datas;
                }
                datas.push({
                    goodsId: obj.id,
                    goodsType: obj.type,
                    value: obj.rechargeMoney,
                    price: obj.relatedPrice
                })
            }
        }

        if(dataPackages && dataPackages.length > 0){

            this.trafficRechargeData = {};
            for(let obj of dataPackages){
                const operator = obj.operatorName;
                let datas = this.trafficRechargeData[operator];
                if(!datas){
                    datas = [];
                    this.trafficRechargeData[operator] = datas;
                }
                datas.push({
                    goodsId: obj.id,
                    goodsType: obj.type,
                    title: obj.goodsName,
                    subtitle: obj.goodsDesc,
                    value: obj.rechargeMoney,
                    price: obj.relatedPrice
                })
            }
        }
    }

    //解析优惠券数据
    _parseCouponData(response){
        let couponList = null;
        if(response){
            couponList = response.couponItems;
        }
        if(couponList && couponList.length > 0){
            this.couponData = [];
            for(let item of couponList){
                this.couponData.push({
                    couponCode: item.couponCode,
                    discountAmount: item.discountAmount,
                    conditionAmount: item.monetary,
                    title: item.couponName,
                    endTimeStamp: item.endTime,
                    endTime: formatTimeStamp(item.endTime, "yyyy-MM-dd")
                })
            }
        }
    }

    //点击流量充值
    _handleTrafficRecharge(animate){
        this.scrollView.scrollTo({
            x: SCREEN_WIDTH,
            y: 0,
            duration: 250,
            animated: animate
        });
        if(animate){
            Animated.parallel([Animated.timing(
                this.state.mobileRechargeAnimateLeft,
                {
                    toValue: 1,
                    duration: 250
                }
            ), Animated.timing(
                this.state.trafficRechargeAnimateRight,
                {
                    toValue: 1,
                    duration: 250
                }
            )]).start();
            setTimeout(() => {
                this.isTraffic = true;
                this.rechargeHeader.setTraffic(true);
            }, 250);
        }else {
            this.isTraffic = true;
            this.rechargeHeader.setTraffic(true);
        }
    }

    //点击话费充值
    _handleMobileRecharge(){
        this.scrollView.scrollTo({
            x: 0,
            y: 0,
            duration: 250
        });
        Animated.parallel([Animated.timing(
            this.state.mobileRechargeAnimateLeft,
            {
                toValue: 0,
                duration: 250
            }
        ), Animated.timing(
            this.state.trafficRechargeAnimateRight,
            {
                toValue: 1,
                duration: 250
            }
        )]).start();
        setTimeout(() => {
            this.isTraffic = false;
            this.rechargeHeader.setTraffic(false);
        }, 250);
    }

    getContent(){

        let contactsView = null;
        if(this.state.contacts && this.state.contacts.length > 0){
            contactsView = this._getContactMatchingResult();
        }
        return<View style={{flex: 1}}>
            <RechargeHeader mobile={this.state.mobile}
                            contactName={this.state.name}
                            isTraffic={this.isTraffic}
                            ref={ref => this.rechargeHeader = ref}
                            onOperatorChange={this._onOperatorChange.bind(this)}
                            onContactsMatch={(contacts) => {
                this._isContactsChange(contacts);
            }}/>
            <View style={{flex: 1}}>
                <ScrollView keyboardShouldPersistTaps="handled" ref={(ref) => this.scrollView = ref}
                            pagingEnabled={true}
                            horizontal={true}
                            scrollEnabled={false}
                            onContentSizeChange={(contentWidth, contentHeight) => {

                                if(this.hasContent){
                                    this.hasContent = false;
                                    //如果传进来的手机号不为空，要
                                    if(!isEmpty(this.state.mobile)){
                                        this.rechargeHeader.handleChangeText(this.state.mobile);
                                        if(this.isTraffic){
                                            this._handleTrafficRecharge(false);
                                        }
                                    }
                                }
                            }}
                            style={{marginTop: 20}} >
                    <MobileRecharge ref={ref => this.mobileRecharge = ref}
                                    data={this.mobileRechargeData} couponData={this.couponData} onPaySuccess={() => {
                                        this.rechargeHeader.reset();
                    }}/>
                    <TrafficRecharge ref={ref => this.trafficRecharge = ref}
                                     data={this.trafficRechargeData} couponData={this.couponData} onPaySuccess={() => {
                                         this.rechargeHeader.reset();
                    }}/>
                </ScrollView>
                <View style={{width: '100%', position: 'absolute', top: 10}}>
                    <Animated.View style={{position: 'absolute', left: this.state.mobileRechargeAnimateLeft.interpolate({
                            inputRange: [0, 1],
                            outputRange: [- 140.5, 0]
                        })}}>
                        <TouchableOpacity activeOpacity={0.7} onPress={this._handleMobileRecharge.bind(this)}>
                            <Image source={mobile_recharge} style={{width: 140.5, height: 40}}/>
                        </TouchableOpacity>
                    </Animated.View>
                    <Animated.View style={{position: 'absolute', right: this.state.mobileRechargeAnimateLeft.interpolate({
                            inputRange: [0, 1],
                            outputRange: [0, - 140.5]
                        })}}>
                        <TouchableOpacity activeOpacity={0.7} onPress={() => {
                            this._handleTrafficRecharge(true);
                        }}>
                            <Image source={traffic_recharge} style={{width: 140.5, height: 40}}/>
                        </TouchableOpacity>
                    </Animated.View>
                </View>

                {contactsView}
            </View>
        </View>
    }

    //运营商改变了
    _onOperatorChange(operator, mobile, contactData){
        if(this.isTraffic){
            return this.trafficRecharge.onOperatorChange(operator, mobile, contactData);
        }else {
            return this.mobileRecharge.onOperatorChange(operator, mobile, contactData);
        }
    }

    getHeader() {
        //导航栏
        return <View style={{flexDirection: 'row', alignItems:'center', justifyContent:'space-between', width: '100%', height: 44, backgroundColor: navigationBarBackgroundColor}}>
            <TouchableOpacity style={{paddingHorizontal: 12, paddingVertical: 12}} activeOpacity={0.7} onPress={() => {
                this.close();
            }}>
                <Image source={back_white} style={{width: 11.5, height: 20}}/>
            </TouchableOpacity>
            <Text allowFontScaling={false} style={{alignSelf: 'center', color: navigationBarTintColor, fontSize: 18}}>E-load</Text>
            <TouchableOpacity style={{paddingHorizontal: 15, paddingVertical: 12}} activeOpacity={0.7} onPress={this._handleOrder.bind(this)}>
                <Image source={order_btn} style={{width: 20, height: 20}}/>
            </TouchableOpacity>
        </View>
    }

    //点击订单
    _handleOrder(){
        this.props.navigation.navigate("OrderList");
    }

    //获取联系人匹配结果视图
    _getContactMatchingResult(){
        return <ContactMatchingResult contacts={this.state.contacts}
                               onContactSelect={(item) => {

                                   this.setState({
                                       contacts: null
                                   });
                                   this.rechargeHeader.setContact(item);
                               }}/>;
    }

    //判断匹配到的联系人是否变了
    _isContactsChange(contacts){

        const preContacts = this.state.contacts;
        let change = false;
        if(contacts){
            if(!preContacts || preContacts.length !== contacts.length){
                change = true;
            }else {
                for(let i = 0;i < contacts.length;i ++){
                    let contact1 = contacts[i];
                    let contact2 = preContacts[i];
                    if(contact1.name !== contact2.name || contact1.mobile !== contact2.mobile){
                        change = true;
                        break;
                    }
                }
            }
        }else {
            if(preContacts){
                change = true;
            }
        }

        if(change){
            this.setState({
                contacts: contacts
            })
        }
    }
}
