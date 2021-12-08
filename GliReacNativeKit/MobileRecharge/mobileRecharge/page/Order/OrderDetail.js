import React from 'react';
import {View, Text, FlatList, TouchableOpacity, Image} from 'react-native';
import BasePageComponent, {STATUS_EMPTY, STATUS_FAIL, STATUS_LOADING, STATUS_NORMAL} from "../../basic/components/BasePageComponent";
import {contentLightTextColor, dividerColor, mainBackgroundColor, mainColor, navigationBarBackgroundColor, navigationBarTintColor, titleTextColor} from "../../res/Colors";
import {ImageView} from "../../basic/components/ImageView";
import {back_white} from "../../res/Image";
import {getString} from "../../basic/utils/LauguageUtils";
import PropTypes from 'prop-types'
import {formatMoney, isEmpty} from "../../basic/utils/StringUtil";
import {nativePrintEnable, nativePrintOrder} from "../../basic/utils/NativeMethodUtil";
import {getParams} from "../../basic/utils/NavigationUtil";
import {getCurrentUserInfo} from "../../basic/config/AppConfig";
import {FIRST_PAGE, get} from "../../basic/utils/HttpUtils";
import {NavigationActions} from "react-navigation";
import {getAppCurrentRouterIndex} from "../../basic/components/AppNavigation";
import {OrderModel} from "./OrderModel";

//订单详情
export default class OrderDetail extends BasePageComponent{

    static defaultProps = {
        orderNo: null, //订单号
    };

    static propsTypes = {
        orderNo: PropTypes.string,
    };

    constructor(props) {
        super(props);

        Object.assign({
            data: null,
            printEnable: false,
        });

        const orderData = getParams( props,"orderData");

        if (orderData) {
            this._getOrderDataFromNavigation(orderData);
        }
    }

    //获取从订单列表拿过来的数据
    _getOrderDataFromNavigation(orderData){
        this.state.data = orderData.getOrderDetailList();
        this.orderData = orderData;
    }

    componentDidMount(): void {
        if(!this.orderData){
            this.onReload();
        }

        //获取是否可以打印
        nativePrintEnable((enable) => {
            const printEnable = enable === 1;
            if(printEnable !== this.state.printEnable){
                this.setState({
                    printEnable: printEnable
                })
            }
        })
    }

    onReload() {
        const orderNo = getParams( this.props,"orderNo");

        if(!orderNo){
            this.setPageStatus(STATUS_EMPTY);
            return;
        }

        this.setPageStatus(STATUS_LOADING);

        const userInfo = getCurrentUserInfo();
        let params = {
            userPhone: userInfo.mobile,
            platformId: 2,
            platUserId: userInfo.userId,
            pageNo: FIRST_PAGE,
            account: userInfo.username,
            orderNo: orderNo
        };

        get("/zegobird-recharge/order/app/getOrders", params).then((response) => {
            this._parseOrderData(response.data);
        }, () => {
            this.setPageStatus(STATUS_FAIL);
        })
    }

    //解析订单数据
    _parseOrderData(responseData){
        let list = responseData.list;

        if(list && list.length > 0){
            this._getOrderDataFromNavigation(new OrderModel(list[0]));
            this.setPageStatus(STATUS_NORMAL);
        }else {
            this.setPageStatus(STATUS_EMPTY);
        }
    }

    getContent() {
        let contentView = null;
        if(this.orderData){
            contentView = <View style={{flex: 1, backgroundColor: mainBackgroundColor}}>
                <View style={{backgroundColor: 'white', alignItems: 'center'}}>
                    <ImageView source={{uri: (isEmpty(this.orderData.imageURL) ? "" : this.orderData.imageURL)}} style={{width: 60, height: 60, marginTop: 10}}/>
                    <Text style={{fontSize: 17, fontWeight: 'bold', color: titleTextColor, marginRight: 15, marginTop: 5, marginBottom: 15}}>- {formatMoney(this.orderData.payAmount)}</Text>
                </View>
                <FlatList style={{backgroundColor: mainBackgroundColor, marginTop: 10}}
                          alwaysBounceVertical={false}
                          data={this.state.data}
                          keyExtractor={(item, index) => index.toString()}
                          renderItem={({item, index}) => {
                              return this._getItem(item, index);
                          }}/>
            </View>
        }

        return contentView;
    }

    //获取item
    _getItem(item, index){

        let paddingBottom = 0;
        let paddingTop = 0;
        if(index === this.state.data.length - 1){
            paddingBottom = 10;
        }else if(index === 0){
            paddingTop = 10;
        }

        return <View style={{height: 30 + paddingBottom + paddingTop, paddingTop: paddingTop, paddingBottom: paddingBottom, backgroundColor: 'white',
            flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center'}}>
            <Text allowFontScaling={false} style={{color: contentLightTextColor, fontSize: 12, marginLeft: 15}}>{item.title}</Text>
            <Text allowFontScaling={false} style={{color: contentLightTextColor, fontSize: 12, marginRight: 15}}>{item.content}</Text>
        </View>
    }

    getHeader() {
        //导航栏
        return <View style={{flexDirection: 'row', alignItems:'center', justifyContent: 'center', width: '100%', height: 44, backgroundColor: navigationBarBackgroundColor}}>
             <TouchableOpacity style={{paddingHorizontal: 12, paddingVertical: 12, position: 'absolute', left: 0}} activeOpacity={0.7} onPress={() => {
                if(getAppCurrentRouterIndex() === 0){
                    this.close()
                }else {
                    this.goBack();
                }
            }}>
                <Image source={back_white} style={{width: 11.5, height: 20}}/>
            </TouchableOpacity>
            <Text allowFontScaling={false} style={{color: navigationBarTintColor, fontSize: 18}}>{getString().orderDetailTitle}</Text>
        </View>

    }

    getFooter() {

        let footer = null;
        if(this.orderData){
            let printBtn = null;
            if(this.state.printEnable && this.orderData.printEnable()){
                printBtn = <TouchableOpacity activeOpacity={0.7}
                                             onPress={this._handlePrint.bind(this)}
                                             style={{paddingHorizontal: 25, marginRight: 15, height: 30, alignItems: 'center', justifyContent: 'center',
                                                 borderWidth: 1, borderColor: mainColor, borderRadius: 16}}>
                    <Text allowFontScaling={false} style={{color: mainColor, fontSize: 14}}>Print</Text>
                </TouchableOpacity>;
            }
            footer = <View style={{height: 50, flexDirection:'row-reverse', alignItems: 'center', borderTopWidth: 0.5, borderTopColor: dividerColor}}>
                {printBtn}
                <TouchableOpacity activeOpacity={0.7}
                                  onPress={this._handleBuyAgain.bind(this)}
                                  style={{paddingHorizontal: 25, marginRight: 15, height: 30, alignItems: 'center', justifyContent: 'center',
                                      borderWidth: 1, borderColor: mainColor, borderRadius: 16}}>
                    <Text allowFontScaling={false} style={{color: mainColor, fontSize: 14}}>{getString().buyAgain}</Text>
                </TouchableOpacity>
            </View>;
        }

        return footer;
    }

    //打印
    _handlePrint(){
        nativePrintOrder(this.orderData.getPrintData());
    }

    //再次购买
    _handleBuyAgain(){
        this.props.navigation.reset([NavigationActions.navigate({
            routeName: 'Recharge',
            params: {
                mobile: this.orderData.mobile,
                type: this.orderData.type
            }
        })], 0);
    }
}
