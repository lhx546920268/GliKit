import React, {Component} from 'react';
import {Image, Keyboard, LayoutAnimation, Platform, ScrollView, Text, TouchableOpacity, UIManager, View} from 'react-native';

import {CommonStyles} from "../constraint/Styles";
import {back_white, mart_logo, search_gray} from '../constraint/Image'
import {isEmpty} from "../utils/StringUtil";
import {getString} from "../constraint/String";
import {goBackToNative, setNativeStatusBarStyle, showNativeErrorToast} from "../utils/NativeMethodUtil"
import CouponView from "./CouponView";
import RecommendGoodsList from "./RecommendGoodsList";
import {Banner} from "./Banner";
import {TextField} from "../widgets/TextField";
import {get} from "../utils/HttpUtils";
import {AdModel} from "../model/AdModel";
import {GoodsModel} from "../model/GoodsModel";
import Loading from "./widgets/Loading";
import FailPage from "./widgets/FailPage";
import ZegoMartCategory from "./ZegoMartCategory";

export default class ZegoMart extends Component {
    constructor(props) {
        super(props);
        this.state = {
            isLoading:true,
            loadFail: false,
            contentHeight: 0,
        };

        //状态栏改成白色
        setNativeStatusBarStyle('white');
    }

    componentDidMount(): void {
        this._getIndexData();
    }

    _setScrollViewEnabled(isScroll) {
        this.category.setSectionListScrollEnabled(!isScroll, this.scrollView);
    }

    _getIndexData(){
        this.setState({
            isLoading: true, //加载中
            loadFail: false, //加载失败
        });

        Promise.all([get('zegomart/index'),
            get('zegomart/store/promotions'),
            get('zegomart/recommendGoods',{pageNo:1,pageSize:100})
        ,])
            .then(([bannerResponse,promotionsResponse,recommendGoodsResponse])=>{
                let banner = JSON.parse(bannerResponse.data.index);

                let adModelList = banner.map(item=> new AdModel(item));
                let conformList = promotionsResponse.data.conformList;

                let couponList = promotionsResponse.data.voucherTemplateList;
                let {pageEntity} = recommendGoodsResponse.data;
                let recommendGoodsList = [];
                if(pageEntity){
                    pageEntity.list.map(item=>{
                        recommendGoodsList.push(new GoodsModel(item));
                    })
                }

                this.setState({isLoading:false,banner:adModelList,conformList,couponList,recommendGoodsList})

        },()=>{
                this.setState({
                    isLoading: false,
                    loadFail: true,
                });
            })
    }

    _getContent(){
        let {isLoading,loadFail, recommendGoodsList,couponList,conformList,banner} = this.state;
        if(isLoading){
            return <Loading/>
        }else if(loadFail){
            return <FailPage onReload={() => {
                this._getIndexData();
            }}/>
        }

        let bannerView = null;
        if(banner && banner.length > 0){
            bannerView = <Banner navigation={this.props.navigation} banner={banner}/>;
        }

        let couponView = null;
        if(couponList && couponList.length > 0){
            couponView = <CouponView couponList={couponList} conformList={conformList}/>;
        }

        let recommend = null;
        if(recommendGoodsList && recommendGoodsList.length > 0){
            recommend = <RecommendGoodsList goodsList={recommendGoodsList}/>;
        }

        return <ScrollView  ref={f => this.scrollView = f}
                            onLayout={(event) => {
                                let contentHeight = event.nativeEvent.layout.height;
                                if (contentHeight !== this.state.contentHeight) {
                                    this.setState({
                                        contentHeight: contentHeight
                                    })
                                }
                            }}
                           iosNestedScrollEnable={true}
                           tag = {1001}
                           nestedChildTags={[1010, 1011]}
                           style={{flex: 1}}
                           showsVerticalScrollIndicator={false}
                           stickyHeaderIndices={[0, 1]}
                           onMomentumScrollEnd={(event) => {

                               let y = Math.floor(event.nativeEvent.contentOffset.y);
                               if(Platform.OS === 'android'){

                                   // console.log('ZEGOMART', event.nativeEvent.contentOffset.y)
                                   if (y === 0) {
                                       this._setScrollViewEnabled(true)
                                   } else {
                                       if (y >= Math.floor(this.scrollTopViewHeight)) {
                                           this._setScrollViewEnabled(false)
                                       } else {
                                           this._setScrollViewEnabled(true)
                                       }
                                   }
                               }
                               if(this.category){
                                   this.category.setContainerScrollToEnd(y >= Math.floor(this.scrollTopViewHeight));
                               }
                               this.category.setOnMomentumScrollEnd();
                           }}
                           scrollEventThrottle={16}
                           onScroll={(event) => {
                               // console.warn(Platform.OS);
                               let y = Math.floor(event.nativeEvent.contentOffset.y);
                               if(Platform.OS === 'android'){

                                   if (y === 0) {
                                       this._setScrollViewEnabled(true);
                                   } else {
                                       if (y >= Math.floor(this.scrollTopViewHeight)) {
                                           this._setScrollViewEnabled(false);
                                       } else {
                                           this._setScrollViewEnabled(true);
                                       }
                                   }
                               }
                           }}
    >
            
            <View onLayout={(event) => {
                this.scrollTopViewHeight = event.nativeEvent.layout.height
            }}>
                {bannerView}
                {couponView}
                {recommend}
            </View>
            <ZegoMartCategory shouldScrollToEnd={() => {
                this.scrollView.scrollToEnd({
                    animated: true,
                    duration: 200
                });

                //安卓不触发onScroll
                if(Platform.OS === 'android'){
                    setTimeout(() => {
                        if(this.category){
                            this.category.setContainerScrollToEnd(true);
                        }
                        this.category.setOnMomentumScrollEnd();
                    }, 200);
                }
            }} ref={f => this.category = f} onScrollToTop={(isTop,dy) => {
                this._setScrollViewEnabled(isTop)
            }} contentHeight={this.state.contentHeight}/>
        </ScrollView>
    }

    render() {
        return (

            <View style={{flex: 1, backgroundColor: 'white'}}>
                <ZegoMartNavigationBar navigation={this.props.navigation} ref={f => this.titleBar = f}/>
                {this._getContent()}
            </View>
        )
    }

}

//导航栏
class ZegoMartNavigationBar extends Component {

    constructor(props) {
        super(props);
        if (Platform.OS === 'android') {//android平台需要开启允许LayoutAnimation ios默认开启
            UIManager.setLayoutAnimationEnabledExperimental(true);
        }
        this.state = {
            keyboardShow: false,

        };

        this.animation = {
            duration: 250,//动画执行的时间 毫秒
            update: {//布局更新时的动画
                type: LayoutAnimation.Types.easeInEaseOut,//动画类型
                property: LayoutAnimation.Properties.scaleXY,//动画作用的元素属性
            }
        };
    }

    //取消
    _handleCancel() {
        Keyboard.dismiss();
    }

    //搜索
    _handleSearch(searchKey) {
        if (isEmpty(searchKey)) {
            showNativeErrorToast(getString().goodsSearchEmptyAlert);
            return;
        }
        Keyboard.dismiss();
        this.props.navigation.navigate('GoodsList', {
            'searchKey': searchKey
        })
    }

    //键盘显示
    _keyboardDidShow() {
        LayoutAnimation.configureNext(this.animation);
        this.setState({
            keyboardShow: true
        })
    }

    //键盘消失
    _keyboardDidHide() {
        LayoutAnimation.configureNext(this.animation);
        this.setState({
            keyboardShow: false
        })
    }

    render() {
        let logo = null;
        let button = null;
        if (!this.state.keyboardShow) {
            logo = <Image style={{width: 90, height: 30, marginLeft: 12, marginRight: 12}}
                          source={mart_logo}/>;
        } else {
            button = <TouchableOpacity activeOpacity={0.7} style={{paddingRight: 12, height: 40, justifyContent:'center', alignItems:'center'}} onPress={this._handleCancel.bind(this)}>
                <Text allowFontScaling={false} style={{color: 'white', fontSize: 14}}>Cancel</Text>
            </TouchableOpacity>
        }

        return (
            <View style={[CommonStyles.navigationBar, {justifyContent: "flex-start"}]}>
                <TouchableOpacity activeOpacity={0.7} style={{padding: 15}} onPress={() => {
                    goBackToNative();
                }}>
                    <Image style={{width: 11, height: 18}} source={back_white}/>
                </TouchableOpacity>
                {logo}
                <View style={{
                    flex: 1,
                    marginRight: 12,
                    flexDirection: "row",
                    height: 30,
                    alignItems: "center",
                    justifyContent: "flex-start",
                    backgroundColor: "white"
                }}>
                    <Image style={{width: 15, height: 15, marginLeft: 10, marginRight: 10}} source={search_gray}/>
                    <TextField style={{flex: 1, height: 30}}
                               placeholder={getString().zegoMartSearchHint}
                               returnKeyType="search"
                               onKeyboardShow={this._keyboardDidShow.bind(this)}
                               onKeyboardHide={this._keyboardDidHide.bind(this)}
                               onSubmitEditing={(event) => this._handleSearch(event.nativeEvent.text)}
                               maxLength={50}/>
                </View>
                {button}
            </View>
        )
    }
}

