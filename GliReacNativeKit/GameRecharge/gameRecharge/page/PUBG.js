import React from 'react';
import {Keyboard, View, Text, Image, FlatList, TouchableOpacity, ImageBackground, TextInput} from 'react-native';
import {Artboard, money_icon} from "../res/Image";

import {
    AppConfig,
    NativeMethodUtil,
    HttpUtil,
    StringUtil,
    IPhoneXBottom,
    ZegobirdButton,
    ic_back_white,
    AppUtil, BasePageComponent,
} from "react-native-zego-framework";

//绝地求生充值
export default class PUBG extends BasePageComponent{

    constructor(props){
        super(props);

        Object.assign(this.state, {
            data: null, //充值数据
            selectedIndex: 0, //当前选中的
        });

        //充值的账号id
        this.playerId = null;
    }

    componentDidMount(): void {
        this.onReload();
    }

    onReload() {
        this.setPageLoadingStatus();
        HttpUtil.get("/v1/getGameListV2/16").then((response) => {

            const data = response.data;
            if(data && data.length > 0){
                this.state.data = data;
                this.setPageNormalStatus();
            }else {
                this.setPageEmptyStatus();
            }

        }, () => {
            this.setPageFailStatus();
        })
    }

    getContainerStyle() {
        return {backgroundColor: '#0b121c'};
    }

    getContent() {
        if(!this.state.data)
            return null;
        return <View style={{flex: 1}}>
            <View style={{marginHorizontal: 20, marginTop: -20, backgroundColor: '#1d2228'}}>
                <Text style={{color: '#e1c76f', fontSize: 16, marginLeft: 10, marginTop: 15}}>Player ID</Text>
                <TextInput allowFontScaling={false}
                           inputAccessoryViewTitle="OK"
                           ref={ref => this.textInput = ref}
                           underlineColorAndroid='transparent'
                           style={{height: 35, flexGrow: 1, marginHorizontal: 15, paddingVertical: 0, marginVertical: 15, borderColor: '#999999', borderWidth: 1, borderRadius: 3,
                               paddingHorizontal: 10, fontSize: 15, color: 'white'}}
                           maxLength={100} onChangeText={(text) => {
                    this._handleTChangeText(text);
                }}/>
            </View>
            <View style={{flex: 1, marginHorizontal: 20, marginTop: 10}}>
                <Text style={{color: '#e1c76f', backgroundColor: '#1d2228', fontSize: 16, paddingLeft: 10, paddingVertical: 15}}>Select an amount</Text>

                <FlatList style={{flex: 1}} data={this.state.data}
                          keyboardShouldPersistTaps="handled"
                          alwaysBounceVertical={false}
                          showsVerticalScrollIndicator={false}
                          ListFooterComponent={this._getRechargeButton.bind(this)}
                          keyExtractor={(item, index) => index.toString()}
                          renderItem={({item, index}) => {
                              return this._getItem(item, index);
                          }}/>
            </View>

        </View>
    }

    //点击某个item
    _handleClickItem(index){
        this.setState({
            selectedIndex: index
        })
    }

    //获取item
    _getItem(item, index){

        let borderColor = this.state.selectedIndex === index ? "#e1c76f" : "#999999";
        return <View style={{backgroundColor: '#1d2228'}}>
                     <TouchableOpacity style={{height: 35, flexDirection: 'row', alignItems: 'center', marginTop: 10, marginHorizontal: 15,
                         borderColor: borderColor, borderWidth: 1}} activeOpacity={0.9} onPress={() => {
                             this._handleClickItem(index);
                     }}>

                    <Image source={money_icon} style={{width: 18, height: 17, marginLeft: 15}}/>
                         <Text allowFontScaling={false} style={{color: 'white', fontSize: 14, marginLeft: 5}}>x{item.title}</Text>
                         <Text allowFontScaling={false}
                               ellipsizeMode='tail'
                               style={{fontSize: 15, color: 'white', marginRight: 15, flexGrow: 1, textAlign: 'right'}}>{StringUtil.formatMoney(item.money)}</Text>
                     </TouchableOpacity>
            </View>
    }

    getHeader() {
        //导航栏
        return <ImageBackground source={Artboard} style={{width: AppConfig.SCREEN_WIDTH, height: AppConfig.SCREEN_WIDTH * 43 / 75}}>
            <TouchableOpacity style={{paddingHorizontal: 15, paddingVertical: 12, position: 'absolute', left: 0, top: AppUtil.getIphoneXTopHeight()}}
                              activeOpacity={0.7}
                              onPress={() => {
                                  this.close();
                              }}>
                <Image source={ic_back_white} style={{width: 11.5, height: 20}}/>
            </TouchableOpacity>
        </ImageBackground>
    }

    //获取底部按钮
    _getRechargeButton(){
        const title = StringUtil.formatMoney(this.state.data[this.state.selectedIndex].money) + " Recharge";
        return <View style={{backgroundColor: '#1d2228'}}>
            <ZegobirdButton title={title} style={{height: 40, marginVertical: 10, marginHorizontal: 15}} onPress={() => {
                this._handleRecharge();
            }}/>
            <IPhoneXBottom style={{backgroundColor: this.getContainerStyle().backgroundColor}}/>
        </View>
    }

    //充值
    _handleRecharge(){
        if(StringUtil.isEmpty(this.playerId)){
            this.textInput.focus();
            return;
        }

        Keyboard.dismiss();
        if(AppConfig.isLogin()){
            this._recharge();
        }else {
            NativeMethodUtil.loginNative(() => {
                this._recharge();
            }, () => {})
        }
    }

    //充值
    _recharge(){
        const userInfo = AppConfig.getCurrentUserInfo();
        let item = this.state.data[this.state.selectedIndex];

        HttpUtil.post("v1/ZegobridAnswerV2", {
            token: userInfo.token,
            sku: item.sku,
            menberGameID: this.playerId
        }, true, true).then((response) => {

            this._pay(response.data);
        }, () => {
        })
    }

    //支付
    _pay(data){
        NativeMethodUtil.nativeZegoPay(data, (response) => {

        })
    }

    //输入内容改变
    _handleTChangeText(text){
        this.playerId = text;
    }
}
