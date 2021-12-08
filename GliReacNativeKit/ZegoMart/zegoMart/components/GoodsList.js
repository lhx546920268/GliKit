import React, {Component} from 'react';
import {Image, Keyboard, LayoutAnimation, Platform, Text, TouchableOpacity, UIManager, View} from 'react-native';
import {mainBackgroundColor} from "../constraint/Colors";
import {CommonStyles} from "../constraint/Styles";
import {back_white, goods_empty, search_gray} from '../constraint/Image'
import {getParams} from "../utils/NavigationUtil";
import {GoodsListItem} from "./widgets/GoodsListItem";
import {getString} from "../constraint/String";
import {GoodsModel} from "../model/GoodsModel";
import {SCREEN_WIDTH} from "../utils/AppUtil";
import {FIRST_PAGE, get} from "../utils/HttpUtils";
import BaseFlatList from '../widgets/BaseFlatList';
import {transferToMm3IfNeeded} from '../utils/LauguageUtils';
import {callNativeMethod} from "../utils/NativeMethodUtil";
import {isEmpty} from "../utils/StringUtil";
import {getZegoMartShopId} from "../config/AppConfig";
import {TextField} from "../widgets/TextField";

//商品列表
export default class GoodsList extends Component{

    constructor(props){
        super(props);

        this.state = {
            searchKey: getParams(props, "searchKey"), //搜索关键字
            showShopCartDialog: false, //是否显示购物车弹窗
            goodsData: null, //商品信息
            curPage: FIRST_PAGE, //页码
        }
    }

    componentDidMount(){
        this._reloadData();
    }

    //重新加载
    _reloadData(){
        this.state.goodsData = [];
        this.refs.goodsList.reloadData(this.state.goodsData, false, true);
        this.state.curPage = FIRST_PAGE;
        this._loadGoodsList();
    }

    //加载更多
    _onLoadMore(){
        this.state.curPage ++;
        this._loadGoodsList();
    }

    //加载商品列表
    _loadGoodsList(){
        get('store/search/goods', {
            storeId: getZegoMartShopId(),
            keyword: transferToMm3IfNeeded(this.state.searchKey),
            page: this.state.curPage,
            client: Platform.select({
                ios: 'ios',
                android: 'android'
            })
        }).then((response) => {

            let data = response.data;
            let array = data.goodsCommonList;
            let goodsData = this.state.goodsData;
            for(let i = 0;i < array.length;i ++){
                goodsData.push(new GoodsModel(array[i]));
            }

            this.state.goodsData = goodsData;
            this.refs.goodsList.reloadData(goodsData, response.hasMore);
        }, () => {
            if(this.refs.goodsList.isLoadingMore()){
                this.state.curPage --;
                this.refs.goodsList.stopLoadMoreWithFail();
            }else {
                this.refs.goodsList.setLoadFail(true);
            }
        })
    }

    //搜索
    _handleSearch(searchKey){
        this.state.searchKey = searchKey;
        this._reloadData();
    }

    render(){

        return(
            <View style={{flex: 1, backgroundColor: mainBackgroundColor}}>
             <GoodsListNavigationBar searchKey={this.state.searchKey} handleSearch={this._handleSearch.bind(this)} navigation={this.props.navigation}/>
                <BaseFlatList ref="goodsList"
                              style={{ flex: 1 }}
                              numColumns={2}
                              getItem={({item, index}) => {
                                  return <GoodsListItem addIconSize={25} style={{marginLeft: 8, marginBottom: 8, marginTop: (index < 2 ? 8 : 0)}} item={item} width={(SCREEN_WIDTH - 24) / 2.0}/>
                              }}
                              loadMoreEnable={true}
                              onReload={this._reloadData.bind(this)}
                              emptyIcon={goods_empty}
                              emptyText={getString().goodsSearchEmptyTip}
                              onLoadMore={this._onLoadMore.bind(this)}/>
        </View>
        )
    }
}

//导航栏
class GoodsListNavigationBar extends Component {

    constructor(props){
        super(props);

        if (Platform.OS === 'android') {//android平台需要开启允许LayoutAnimation ios默认开启
            UIManager.setLayoutAnimationEnabledExperimental && UIManager.setLayoutAnimationEnabledExperimental(true);
        }

        this.state = {
            keyboardShow : false, //键盘是否显示
            searchKey: props.searchKey, //搜索关键字
        };

        this.animation = {
            duration:250,//动画执行的时间 毫秒
            update:{//布局更新时的动画
                type:LayoutAnimation.Types.easeInEaseOut,//动画类型
                property:LayoutAnimation.Properties.scaleXY,//动画作用的元素属性
            }
        };
    }

    //返回
    _handleBack() {
        this.props.navigation.goBack();
    }

    //取消
    _handleCancel(){
        Keyboard.dismiss();
    }

    //搜索
    _handleSearch(searchKey){
        if (isEmpty(searchKey)) {
            callNativeMethod('reactNativeInteraction','showErrorToast', getString().goodsSearchEmptyAlert);
            return;
        }
        Keyboard.dismiss();
        if(searchKey !== this.state.searchKey){
            this.state.searchKey = searchKey;
            this.props.handleSearch(searchKey);
        }
    }

    //键盘显示
    _keyboardDidShow(){
        LayoutAnimation.configureNext(this.animation);
        this.setState({
            keyboardShow : true
        })
    }

    //键盘消失
    _keyboardDidHide(){
        LayoutAnimation.configureNext(this.animation);
        this.setState({
            keyboardShow: false
        })
    }

    render() {
        let button = null;
        if(this.state.keyboardShow){
            button = <TouchableOpacity activeOpacity={0.7} style={{marginRight:12}} onPress={this._handleCancel}>
                <Text allowFontScaling={false} style={{color:'white', fontSize:14}}>Cancel</Text>
            </TouchableOpacity>
        }

        return (
        <View style={[CommonStyles.navigationBar, {justifyContent:"flex-start"}]}>
            <TouchableOpacity activeOpacity={0.7} style={{padding:15}} onPress={() => this._handleBack()}>
                <Image style={{
                    width:11, 
                    height:18}} 
                    source={back_white}/>
            </TouchableOpacity>
            <View style={{flex:1, marginRight:12, flexDirection:"row", alignItems:"center",justifyContent:"flex-start", backgroundColor:"white"}}>
                <Image style={{width:15, height:15, marginLeft:10, marginRight:10}} source={search_gray}/>
                <TextField style={{height:30, flex: 1}}
                    placeholder={getString().zegoMartSearchHint} 
                    returnKeyType="search"
                           onKeyboardShow={this._keyboardDidShow.bind(this)}
                           onKeyboardHide={this._keyboardDidHide.bind(this)}
                    onSubmitEditing={(event) => this._handleSearch(event.nativeEvent.text)}
                    maxLength={50}
                    defaultValue={this.state.searchKey}/>
            </View>
            {button}
        </View>
        )
    }
}
