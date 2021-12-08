import React, {Component} from 'react';
import {ActivityIndicator, FlatList, Image, Platform, StyleSheet, Text, TouchableOpacity, View} from "react-native";
import {ic_coupon_received, ic_discount, ic_get_now} from "../constraint/Image";
import {CommonStyles} from "../constraint/Styles";
import {formatMoney} from "../utils/StringUtil";
import {get, post} from "../utils/HttpUtils";
import {EVENT_ON_LOGIN, EVENT_ON_LOGOUT, getZegoMartShopId} from "../config/AppConfig";
import {isLogin, loginNative, showNativeSuccessToast} from "../utils/NativeMethodUtil";
import {getString} from "../constraint/String";
import {registerEvent} from "../utils/EventUtil";
import PropTypes from "prop-types";

export default class CouponView extends Component{
    constructor(props) {
        super(props);

        this.state = {
            isLoadCoupon:false,
            couponList:props.couponList,
            conformList:props.conformList,
        }
    }

    static defaultProps = {
        couponList:[],
        conformList:[],
    };

    static propTypes = {
        couponList: PropTypes.array,
        conformList: PropTypes.array,
    };

    componentDidMount(): void {

        this.loginListener = registerEvent(EVENT_ON_LOGIN,()=>{this.setState({isLoadCoupon:true},()=>this._getCoupon())});
        this.logoutListener = registerEvent(EVENT_ON_LOGOUT,()=>{this.setState({isLoadCoupon:true},()=>this._getCoupon())});
    }

    componentWillUnmount(): void {
        this.loginListener.remove();
        this.logoutListener.remove();
    }

    _receiveCoupon(item,index){

        if(isLogin()){
            let {templateId} = item;
            post('member/voucher/receive/free',{templateId},true, true)
                .then(response=>{
                    showNativeSuccessToast(getString().receiveSuccess);
                    item.memberIsReceive = 1;
                    let couponList = [];
                    this.state.couponList.map((data,i)=>{
                        if(index === i){
                            couponList.push(item);
                        }else{
                            couponList.push(data);
                        }
                    });

                    this.setState({couponList});
                },()=>{

                })
        }else{
            loginNative(() => {

            })
        }

    }

    _getCoupon(){
        if(isLogin()){
            post('member/voucher/template/free',{storeId: getZegoMartShopId()})
                .then((response) => {
                    // console.log('member/voucher/template/free',response.data);
                    this.setState({
                        isLoadCoupon:false,
                        couponList:response.data.voucherTemplateList,
                    })
                }, (response) => {
                    // console.log('member/voucher/template/response',response.data);
                })
        }else{
            get('store/voucher',{storeId: getZegoMartShopId()})
                .then((response) => {
                    this.setState({
                        isLoadCoupon:false,
                        couponList:response.data.voucherTemplateList,
                    })
                }, (response) => {})
        }
    }

    _getCouponItem(item, index) {

        let {limitAmount,templatePrice,storeName,memberIsReceive} =item;
        let couponColor = "#FFC22D";//memberIsReceive ? '#FFC22D' : '#0FD7C8';
        return <TouchableOpacity
            activeOpacity={0.7}
            onPress={()=>{this._receiveCoupon(item,index)}}
            disabled={!!memberIsReceive}
            style={[{
            marginVertical: 10,
            marginLeft: index === 0 ? 10 : 5,
            marginRight: 5,
            backgroundColor: 'white',
            borderRadius: 2
        }, CommonStyles.shadow]}>
            <View style={{
                borderRadius: 2,
                width: 190,
                height: 65,
                // height:'100%',
                flexDirection: 'row',
                overflow: 'hidden'
            }}>
                <View style={{backgroundColor: couponColor, flex: 1, padding: 5}}>
                    <Text allowFontScaling={false} style={{color: 'white', alignSelf: 'flex-end', fontSize: 10}}>{storeName}</Text>
                    {/*<View style={{flex: 1}}/>*/}
                    <Text allowFontScaling={false} style={Platform.select({ios:styles.iosCouponTextStyle,android:styles.androidCouponTextStyle})}>{formatMoney(templatePrice)}</Text>
                    <Text allowFontScaling={false} style={{color: 'white', fontSize: 12}}>OFF {formatMoney(limitAmount)}+ </Text>
                </View>
                <View style={{
                    borderWidth: 0.5,
                    borderTopRightRadius: 2,
                    borderBottomRightRadius: 2,
                    borderStyle: 'dashed',
                    borderColor: couponColor,
                    alignItems: 'center',
                    justifyContent: 'center',
                    width: 65, height: 65
                }}>
                    {memberIsReceive ? <Image source={ic_coupon_received} style={{width: 50, height: 50}}/> :
                        <Image source={ic_get_now} style={{width: 50, height: 14}} resizeMode={'stretch'}/>}
                </View>
            </View>
        </TouchableOpacity>
    }

    _getLoadingView(){
        return <View style={{flex:1,height:100,alignItems: 'center',justifyContent: 'center'}}>
            <ActivityIndicator size={'small'}/>
        </View>
    }


    _getCouponList(){
        return <FlatList
            data={this.state.couponList}
            horizontal={true}
            showsHorizontalScrollIndicator={false}
            keyExtractor={(item, index) => index.toString()}
            renderItem={({item, index}) => this._getCouponItem(item, index)}/>
    }

    _getConformList(){
        return <View style={{
            flexDirection: 'row',
            paddingTop: 10,
            paddingHorizontal: 10,
            marginBottom: 5,
            borderTopColor: '#DEDEDE',
            borderTopWidth: 1
        }}>
            <Image source={ic_discount} style={{width: 60, height: 12}}/>
            <View style={{marginHorizontal: 10}}>
                {this.state.conformList.map((item,index)=><Text allowFontScaling={false} key={index} style={{color: '#39362b', fontSize: 12}}>{item.conformName}</Text>)}
            </View>
        </View>
    }

    render(){
        let {isLoadCoupon} = this.state;
        return <View>
            {isLoadCoupon?this._getLoadingView():this._getCouponList()}
            {this._getConformList()}

        </View>
    }

}

const styles = StyleSheet.create({
    androidCouponTextStyle:{
        fontSize:18,
        color:'white'
    },
    iosCouponTextStyle:{
        color: 'white',
        fontSize: 22,
    }

});
