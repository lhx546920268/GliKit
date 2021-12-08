import React from 'react';
import {View, Text, TextInput, TouchableOpacity, Image, Keyboard} from 'react-native';
import BasePageComponent, {STATUS_EMPTY, STATUS_FAIL, STATUS_LOADING, STATUS_NORMAL} from "../../basic/components/BasePageComponent";
import {contentLightTextColor, dividerColor, navigationBarBackgroundColor, navigationBarTintColor, titleTextColor} from "../../res/Colors";
import {back_white, search_black} from "../../res/Image";
import {getString} from "../../basic/utils/LauguageUtils";
import {ImageView} from "../../basic/components/ImageView";
import {FIRST_PAGE, get} from "../../basic/utils/HttpUtils";
import {getCurrentUserInfo} from "../../basic/config/AppConfig";
import {formatMoney, isEmpty} from "../../basic/utils/StringUtil";
import BaseFlatList from "../../basic/components/BaseFlatList";
import {OrderModel} from "./OrderModel";
import {TextField} from "../../basic/components/TextField";
import {SCREEN_WIDTH} from "../../basic/utils/AppUtil";

//订单列表
export default class OrderList extends BasePageComponent{

    constructor(props){
        super(props);

        Object.assign(this.state, {
            data: [], //充值数据
            selectedIndex: 0, //当前选中的
        });

        this.curPage = FIRST_PAGE; //页码
        this.hasMore = false; //是否还有更多

        //当前输入的内容
        this.currentInputContent = null;

        //搜索内容
        this.searchKey = null;
    }

    componentDidMount(): void {
        this.onReload();
    }

    onReload() {
        this.setPageStatus(STATUS_LOADING);
        this._loadOrderList();
    }

    //加载订单列表
    _loadOrderList(){
        const userInfo = getCurrentUserInfo();
        let params = {
            userPhone: userInfo.mobile,
            platformId: 2,
            platUserId: userInfo.userId,
            pageNo: this.curPage,
            account: userInfo.username
        };
        if(!isEmpty(this.searchKey)){
            params["orderNo"] = this.searchKey;
        }
        get("/zegobird-recharge/order/app/getOrders", params).then((response) => {
            this._parseOrderData(response.data);
        }, () => {
            if(this.flatList && this.flatList.isLoadingMore()){
                this.curPage --;
                this.flatList.stopLoadMore();
            }else {
                this.setPageStatus(STATUS_FAIL);
            }
        })
    }

    //解析订单数据
    _parseOrderData(responseData){
        let list = responseData.list;
        const loadingMore = this.flatList && this.flatList.isLoadingMore();

        let {data} = this.state;

        if(list && list.length > 0){
            for(let item of list){
                data.push(new OrderModel(item))
            }
            this.state.data = data;
            this.hasMore = responseData.total > data.length;
            this.setPageStatus(STATUS_NORMAL);
            if(loadingMore){
                this.flatList.stopLoadMore(data, this.hasMore);
            }
        }else if(loadingMore){
            this.hasMore = false;
            this.flatList.stopLoadMore(data, this.hasMore);
        }else {
            this.setPageStatus(STATUS_EMPTY);
        }
    }

    getContent() {
        return <BaseFlatList ref={ref => this.flatList = ref}
                             loadMoreEnable={true}
                             hasMore={this.hasMore}
                             onLoadMore={() => {

                                 this.curPage ++;
                                 this._loadOrderList();
                             }}
                             style={{flex: 1}}
                             data={this.state.data}
                             renderItem={({item, index}) => {
                                 return this._getItem(item, index);
                             }}/>
    }

    //点击某个item
    _handleClickItem(index){
        this.props.navigation.navigate("OrderDetail", {
            orderData: this.state.data[index]
        });
    }

    //获取item
    _getItem(item, index){

        return <TouchableOpacity style={{height: 90, flexDirection: 'row', backgroundColor: 'white', justifyContent: 'space-between',
            borderBottomWidth: 0.5, borderBottomColor: dividerColor}} activeOpacity={0.7} onPress={() => {
            this._handleClickItem(index);
        }}>

            <ImageView source={{uri: (isEmpty(item.imageURL) ? "" : item.imageURL)}}  style={{width: 70, height: 70, marginLeft: 15, marginTop: 10}}/>
            <View style={{height: 70, marginTop: 10, flexGrow: 1, justifyContent: 'space-between', marginHorizontal: 10, flexShrink: 2}}>
                <Text allowFontScaling={false} ellipsizeMode='tail' numberOfLines={1} style={{color: titleTextColor, fontSize: 15, marginRight: 5}}>{item.operator}-{item.mobile}</Text>
                <Text allowFontScaling={false} style={{color: contentLightTextColor, fontSize: 12, marginTop: 2}}>{item.createTime}</Text>
                <Text allowFontScaling={false} style={{color: contentLightTextColor, fontSize: 14}}>{item.statusString}</Text>
            </View>
            <Text style={{fontSize: (SCREEN_WIDTH <= 320 ? 14 : 17), fontWeight: 'bold', color: titleTextColor, marginRight: 15, marginTop: 10}}>- {formatMoney(item.payAmount)}</Text>
        </TouchableOpacity>
    }

    getHeader() {
        //导航栏
        return <View>
                <View style={{flexDirection: 'row', alignItems:'center', justifyContent: 'center', width: '100%', height: 44, backgroundColor: navigationBarBackgroundColor}}>
                    <TouchableOpacity style={{paddingHorizontal: 12, paddingVertical: 12, position: 'absolute', left: 0}} activeOpacity={0.7} onPress={() => {
                        this.goBack();
                    }}>
                        <Image source={back_white} style={{width: 11.5, height: 20}}/>
                    </TouchableOpacity>
                    <Text allowFontScaling={false} style={{color: navigationBarTintColor, fontSize: 18}}>{getString().orderListTitle}</Text>
                </View>
                <View style={{height: 50, backgroundColor: 'white', flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center',
                    borderBottomWidth: 0.5, borderBottomColor: dividerColor}}>
                    <TextField placeholder={getString().orderSearchHint}
                               inputAccessoryViewTitle="OK"
                               returnKeyType="search"
                               showClear={true}
                               onSubmitEditing={this._handleSearch.bind(this)}
                               style={{height: 35, flexGrow: 1, marginLeft: 15, borderRadius: 5, paddingHorizontal: 10, paddingVertical: 0, fontSize: 15, backgroundColor: '#F7F7F7'}}
                               maxLength={50}
                               onChangeText={this._handleTChangeText.bind(this)}/>
                     <TouchableOpacity style={{paddingHorizontal: 15, paddingVertical: 12}} activeOpacity={0.7} onPress={this._handleSearch.bind(this)}>
                         <Image source={search_black} style={{width: 20, height: 20}}/>
                     </TouchableOpacity>
                </View>
            </View>

    }

    //搜索
    _handleSearch(){
        Keyboard.dismiss();
        if(this.searchKey !== this.currentInputContent){
            this.searchKey = this.currentInputContent;
            if(this.flatList && this.flatList.isLoadingMore()){
                this.flatList.stopLoadMore(null, false);
            }
            this.setState({
                data: []
            });
            this.curPage = FIRST_PAGE;
            this.onReload();
        }
    }

    //输入内容改变
    _handleTChangeText(text){
        this.currentInputContent = text;
    }
}
