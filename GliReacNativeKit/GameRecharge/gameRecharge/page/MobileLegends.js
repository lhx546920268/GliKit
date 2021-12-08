import React from 'react';
import {Keyboard, View, Text, Image, FlatList, TouchableOpacity, TextInput} from 'react-native';
import {legends_logo, legends_tip} from "../res/Image";
import {
    IPhoneXBottom,
    IPhoneXTop,
    AppConfig,
    NativeMethodUtil,
    HttpUtil,
    StringUtil,
    AppUtil,
    LanguageUtil,
    ic_back_white,
    AppColor,
    BasePageComponent
} from "react-native-zego-framework";

//绝地求生充值
export default class MobileLegends extends BasePageComponent{

    constructor(props){
        super(props);

        Object.assign(this.state, {
            data: null, //充值数据
            selectedIndex: {
                section: 0,
                column: 0
            }, //当前选中的
            rechargeTitle: "Recharge", //充值标题
        });

        //充值用户用户id
        this.playerId1 = null;
        this.playerId2 = null;
    }

    componentDidMount(): void {
        this.onReload();
    }

    onReload() {
        this.setPageLoadingStatus();
        HttpUtil.get("/v1/getGameListV2/15").then((response) => {

            const data = response.data;
            if(data && data.length > 0){
                let result = [];
                for(let i = 0;i < data.length;i += 2){
                    let subData = [];
                    subData.push(data[i]);
                    if(i + 1 < data.length){
                        subData.push(data[i + 1]);
                    }
                    result.push(subData);
                }
                this.state.data = result;
                this.setPageNormalStatus();
            }else {
                this.setPageEmptyStatus();
            }

        }, () => {
            this.setPageFailStatus();
        })
    }

    getContainerStyle() {
        return {backgroundColor: '#f66c1b'};
    }

    getContent() {
        if(!this.state.data)
            return null;
        return <View style={{flex: 1}}>

            {/*顶部*/}
            <View style={{marginHorizontal: 10, marginTop: 10, backgroundColor: 'white'}}>

                {/*标题*/}
                <View style={{flexDirection: 'row'}}>
                    <View style={{width: 26, height: 26, backgroundColor: this.getContainerStyle().backgroundColor, marginLeft: 20, marginTop: -8,
                        alignItems: 'center', justifyContent: 'center', borderRadius: 13, borderColor: 'white', borderWidth: 0.5}}>
                        <Text style={{color: 'white'}}>1</Text>
                    </View>
                    <Text style={{color: 'black', fontSize: 15, marginLeft: 10, marginTop: 5}}>{LanguageUtil.getString().enterUserId}</Text>
                </View>

                {/*2个输入框*/}
                <View style={{flexDirection: 'row', marginHorizontal: 20, marginTop: 10}}>
                    <TextInput allowFontScaling={false}
                               inputAccessoryViewTitle="OK"
                               ref={ref => this.textInput = ref}
                               underlineColorAndroid='transparent'
                               style={{height: 35, flex: 3, borderColor: '#999999', borderWidth: 1, borderRadius: 3,
                                   paddingHorizontal: 10, paddingVertical: 0, fontSize: 15}}
                               maxLength={100} onChangeText={this._handleChangeText1.bind(this)}/>
                    <View style={{height: 35, flex: 2, borderColor: '#999999', borderWidth: 1, borderRadius: 3,
                        paddingHorizontal: 10, marginLeft: 20, flexDirection: 'row', alignItems: 'center'}}>
                        <Text allowFontScaling={false} style={{fontSize: 16}}>(</Text>
                        <TextInput allowFontScaling={false}
                                   inputAccessoryViewTitle="OK"
                                   ref={ref => this.textInput = ref}
                                   underlineColorAndroid='transparent'
                                   maxLength={100}
                                   style={{fontSize: 15, flexGrow: 1, paddingHorizontal: 5, paddingVertical: 0}}
                                   onChangeText={this._handleChangeText2.bind(this)}/>
                        <Text allowFontScaling={false} style={{fontSize: 16}}>)</Text>
                    </View>
                </View>
                {/*文字提示*/}
                <Image source={legends_tip} style={{width: AppConfig.SCREEN_WIDTH - 40, height: (AppConfig.SCREEN_WIDTH - 40) * 10 / 33, marginHorizontal: 10, marginVertical: 10}}/>
            </View>
            <View style={{flex: 1, marginHorizontal: 10, marginTop: 10}}>
                {/*标题*/}
                <View style={{flexDirection: 'row', backgroundColor: 'white'}}>
                    <View style={{width: 26, height: 26, backgroundColor: this.getContainerStyle().backgroundColor, marginLeft: 20, marginTop: -8,
                        alignItems: 'center', justifyContent: 'center', borderRadius: 13, borderColor: 'white', borderWidth: 0.5}}>
                        <Text style={{color: 'white'}}>2</Text>
                    </View>
                    <Text style={{color: 'black', fontSize: 15, marginLeft: 10, marginTop: 5}}>{LanguageUtil.getString().selectRechargeAmount}</Text>
                </View>

                <FlatList style={{flex: 1}} data={this.state.data}
                          alwaysBounceVertical={false}
                          showsVerticalScrollIndicator={false}
                          ListFooterComponent={this._getRechargeButton.bind(this)}
                          keyboardShouldPersistTaps="handled"
                          keyExtractor={(item, index) => index.toString()}
                          renderItem={({item, index}) => {
                              return this._getItem(item, index);
                          }}/>
            </View>

        </View>
    }

    //点击某个item
    _handleClickItem(section, column){
        this.setState({
            selectedIndex: {
                section,
                column
            }
        })
    }

    //获取item
    _getItem(item, index){

        const section = index;
        const {selectedIndex} = this.state;

        let width = (AppConfig.SCREEN_WIDTH - 10 * 2 - 20 * 3) / 2;

        let view2 = null;
        if(item.length > 1){
            const color = (selectedIndex.section === section && selectedIndex.column === 1) ? this.getContainerStyle().backgroundColor : AppColor.titleTextColor;
            view2 = <TouchableOpacity style={{width: width, height: 35, alignItems: 'center', justifyContent: 'center', marginTop: 10, marginLeft: 20,
                borderColor: "#999999", borderWidth: 1}} activeOpacity={0.9} onPress={() => {
                this._handleClickItem(section, 1);
            }}>
                <Text allowFontScaling={false}
                      ellipsizeMode='tail'
                      style={{fontSize: 15, color: color}}>{item[1].title}</Text>
            </TouchableOpacity>;
        }

        const color = (selectedIndex.section === section && selectedIndex.column === 0) ? this.getContainerStyle().backgroundColor : AppColor.titleTextColor;
        return <View style={{backgroundColor: 'white', flexDirection: 'row'}}>
            <TouchableOpacity style={{width: width, height: 35, alignItems: 'center', justifyContent: 'center', marginTop: 10, marginLeft: 20,
                borderColor: "#999999", borderWidth: 1}} activeOpacity={0.9} onPress={() => {
                this._handleClickItem(section, 0);
            }}>
                <Text allowFontScaling={false}
                      ellipsizeMode='tail'
                      style={{fontSize: 15, color: color}}>{item[0].title}</Text>
            </TouchableOpacity>
            {view2}
        </View>
    }

    getHeader() {
        //导航栏
        return <View style={{alignItems: 'center', justifyContent: 'center'}}>
            <IPhoneXTop/>
            <Image source={legends_logo} style={{width: 210, height: 101, marginTop: 10}}/>
            <TouchableOpacity style={{paddingHorizontal: 15, paddingVertical: 12, position: 'absolute', left: 0, top: AppUtil.getIphoneXTopHeight()}}
                              activeOpacity={0.7}
                              onPress={() => {
                                  this.close();
                              }}>
                <Image source={ic_back_white} style={{width: 11.5, height: 20}}/>
            </TouchableOpacity>
        </View>
    }

    //获取底部按钮
    _getRechargeButton(){

        const {selectedIndex} = this.state;
        const title = StringUtil.formatMoney(this.state.data[selectedIndex.section][selectedIndex.column].money) + " Recharge";
        return <View style={{backgroundColor: 'white'}}>
            <TouchableOpacity style={{height: 40, backgroundColor: '#0f446e', alignItems: 'center', justifyContent: 'center',
                marginVertical: 10, marginHorizontal: 15}}
                              activeOpacity={0.7}
                              onPress={() => {
                                    this._handleRecharge();
                              }}>
                <Text style={{color: 'white', fontSize: 16}}>{title}</Text>
            </TouchableOpacity>
            <IPhoneXBottom style={{backgroundColor: this.getContainerStyle().backgroundColor}}/>
        </View>
    }

    //输入内容改变
    _handleChangeText1(text){
        this.playerId1 = text;
    }

    _handleChangeText2(text){
        this.playerId2 = text;
    }

    //充值
    _handleRecharge(){
        if(StringUtil.isEmpty(this.playerId1) || StringUtil.isEmpty(this.playerId2)){
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
        const {selectedIndex} = this.state;
        let item = this.state.data[selectedIndex.section][selectedIndex.column];

        HttpUtil.post("v1/ZegobridAnswerV2", {
            token: userInfo.token,
            sku: item.sku,
            menberGameID: this.playerId1 + "(" + this.playerId2 + ")"
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
}
