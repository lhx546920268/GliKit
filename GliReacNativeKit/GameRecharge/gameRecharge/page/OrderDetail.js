import React from 'react';
import {View, Text, TouchableOpacity, Image, FlatList} from "react-native";

import PropTypes from 'prop-types'

import {HttpUtil,IPhoneXTop,AppColor,ic_back_white,BasePageComponent,} from "react-native-zego-framework";
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
        });
    }

    componentDidMount(): void {
        this.onReload();
    }

    onReload() {
        const orderNo = this.props.orderNo;

        if(!orderNo){
            this.setPageEmptyStatus();
            return;
        }

        this.setPageLoadingStatus();
        HttpUtil.get("/v1/getOrderInfoV2", {
            orderId: orderNo
        }).then((response) => {
            const data = response.data;
            this.state.data = [
                {title: "Type", content: data.type},
                {title: "Date", content: data.date},
                {title: "Phone", content: data.phone},
                {title: "Order Number", content: data.orderNumber},
                {title: "Pay Number", content: data.payNumber},
                {title: "Money", content: data.money},
                {title: "Player ID", content: data.playerId},
                {title: "Amount", content: data.amount},
            ];

            this.setPageNormalStatus();
        }, () => {
            this.setPageFailStatus();
        })
    }


    getContent() {
        return  <View style={{marginTop: 30, backgroundColor: 'white', borderRadius: 20, paddingHorizontal: 15, marginHorizontal: 20,
            shadowColor: 'gray', shadowOffset: {height: 0, width: 0}, shadowRadius: 20, shadowOpacity: 0.3, elevation: 2}}>
            <FlatList
                      alwaysBounceVertical={false}
                      data={this.state.data}
                      keyExtractor={(item, index) => index.toString()}
                      renderItem={({item, index}) => {
                          return this._getItem(item, index);
                      }}/>
        </View>
    }

    //获取item
    _getItem(item, index){

        let paddingBottom = 0;
        let paddingTop = 0;
        if(index === this.state.data.length - 1){
            paddingBottom = 15;
        }else if(index === 0){
            paddingTop = 20;
        }

        return <View style={{paddingTop: paddingTop, paddingBottom: paddingBottom + 10}}>
            <Text allowFontScaling={false} style={{color: AppColor.titleTextColor, fontSize: 19, fontWeight: 'bold'}}>{item.title}:</Text>
            <Text allowFontScaling={false} style={{color: AppColor.titleTextColor, fontSize: 15, marginTop: 5}}>{item.content}</Text>
        </View>
    }

    getHeader() {
        //导航栏
        return <View>
            <IPhoneXTop/>
            <View style={{flexDirection: 'row', alignItems:'center', justifyContent: 'center', width: '100%', height: 44, backgroundColor: AppColor.navigationBarBackgroundColor}}>
                <TouchableOpacity style={{paddingHorizontal: 12, paddingVertical: 12, position: 'absolute', left: 0}} activeOpacity={0.7} onPress={() => {
                    this.close()
                }}>
                    <Image source={ic_back_white} style={{width: 11.5, height: 20}}/>
                </TouchableOpacity>
                <Text allowFontScaling={false} style={{color: AppColor.navigationBarTintColor, fontSize: 18}}>Order</Text>
            </View>
        </View>

    }

}
