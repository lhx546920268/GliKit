import React, {Component} from 'react';
import {Platform, Text, View} from 'react-native';
import {SCREEN_WIDTH} from "../utils/AppUtil";
import {GoodsListItem} from "./widgets/GoodsListItem";
import {GoodsModel} from "../model/GoodsModel";
import PropTypes from "prop-types";
import {get} from '../utils/HttpUtils';
import {goods_empty} from "../constraint/Image";
import {getString} from "../constraint/String";
import Loading from "./widgets/Loading";
import {descTextColor} from "../constraint/Colors";
import BaseSectionList from "../widgets/BaseSectionList";
import FailPage from "./widgets/FailPage";
import {CommonStyles} from "../constraint/Styles";
import EmptyView from "./widgets/EmptyView";
import SecondCategory from "./SecondCategory";
import FirstCategory from "./FirstCategory";
import {ExpandedThirdCategory, ThirdCategory} from "./ThirdCategory";

//分类
export default class ZegoMartCategory extends Component{

    constructor(props) {
        super(props);
        this.state = {
            isLoading: true, //加载中
            loadFail: false, //加载失败
            loadingGoods: true, //加载商品
            contentHeight:500,
            secondCategoryEmpty: false, //二级分类是否为空
        };

        this.goodsListHeight = this.state.contentHeight - 45;
        this.firstCategory = []; //一级分类
        this.secondCategory = []; //二级分类
        this.secondSelectedIndex = 0; //二级分类选中下标

        this.thirdCategory = []; //三级分类
        this.thirdSelectedIndex = 0; //选中的三级分类

        this.cateGoodsList = []; //当前商品

        //外部容器到底部了
        this.containerScrollToEnd = false;
    }

    static defaultProps={
        onScrollToTop: undefined,
        shouldScrollToEnd: undefined, //通知外层的滑动到底部
    };

    static propTypes={
        onScrollToTop: PropTypes.func,
        shouldScrollToEnd: PropTypes.func,
    };


    componentDidMount(): void {
        this.shouldScrollToSection = false;
        this._reloadData();
    }

    //加载数据
    _reloadData(){
        if(this.firstCategory.length > 0){
            this._loadGoodsList();
        }else {
            if(!this.state.isLoading){
                this.setState({
                    isLoading: true,
                    loadFail: false
                });
            }
            this._loadCateList();
        }
    }

    //加载分类信息
    _loadCateList(){
        get('zegomart/labelList')
            .then(response => {
                let firstCategory = JSON.parse(response.data.labelList);
                let secondCategory = [];
                let thirdCategory = [];

                if(firstCategory && firstCategory.length > 0){
                    secondCategory = firstCategory[0].storeLabelList;
                }
                if(secondCategory && secondCategory.length > 0){
                    thirdCategory = secondCategory[0].storeLabelList;
                }

                this.firstCategory = firstCategory;
                this.secondCategory = secondCategory;
                this.thirdCategory = thirdCategory;

                this.setState({
                        isLoading: false,
                    }, () => {
                    if(firstCategory && firstCategory.length > 0){
                        this._loadGoodsList();
                    }
                })
            },() => {
                this.setState({
                    isLoading: false,
                    loadFail: true
                });
            })
    }

    //加载商品信息
    _loadGoodsList(){

        //二级分类有时候是空的，不加载商品数据
        if(!this.secondCategory || this.secondCategory.length === 0){
            this._reloadGoods([]);
            if(!this.state.secondCategoryEmpty){
                this.setState({
                    secondCategoryEmpty: true
                });
            }
            return;
        }else {
            if(this.state.secondCategoryEmpty){
                this.setState({
                    secondCategoryEmpty: false
                });
            }
        }

        let cate = this.secondCategory[this.secondSelectedIndex];

        //取消以前的请求
        if(this.goodsListRequests){
            this.goodsListRequests.map(request => {
                request.cancel();
            })
        }

        //先拿缓存的
        if(cate.cateGoodsList){
            this.cateGoodsList = cate.cateGoodsList;

            this._reloadGoods(cate.cateGoodsList);
            if(this.thirdCategoryContainer){
                this.thirdCategoryContainer.setCategory(this.thirdCategory);
                this.expandedThirdCategoryContainer.setCategory(this.thirdCategory);
            }else {
                if(this.thirdCategory && this.thirdCategory.length > 0){
                    this.setState({
                        loadingGoods: false
                    })
                }
            }

            return;
        }

        this._reloadGoods([], false, true);

        let requests = [];
        if(this.thirdCategory && this.thirdCategory.length > 0){
            this.thirdCategory.map(item=>{
                requests.push(get('zegomart/labelGoods',{
                    labelId : item.storeLabelId,
                    pageNo : 1,
                    pageSize : 100
                }))
            });
        }else{
            requests.push(get('zegomart/labelGoods',{
                labelId : cate.storeLabelId,
                pageNo : 1,
                pageSize : 100
            }))
        }
        this.goodsListRequests = requests;

        this.cateGoodsList = [];

        Promise.all(requests)
            .then(responses=>{

                responses.map((response, index)=>{
                    let goodsList = [];

                    let list = response.data.pageEntity.list;
                    if(list && list.length > 0){
                        for(let i = 0;i < list.length;i += 2){
                            let array = [];
                            array.push(new GoodsModel(list[i]));
                            if(i + 1 < list.length){
                                array.push(new GoodsModel(list[i + 1]));
                            }
                            goodsList.push(array);
                        }
                    }

                    let listItem = null;
                    if(this.thirdCategory && this.thirdCategory.length > 0){
                        listItem = {
                            cateId : this.thirdCategory[index].storeLabelId,
                            title : this.thirdCategory[index].storeLabelName,
                            data : goodsList,
                        };
                    }else {
                        if(goodsList.length > 0){
                            listItem = {
                                cateId : cate.storeLabelId,
                                title : cate.storeLabelName,
                                data : goodsList,
                            };
                        }
                    }

                    if(listItem !== null){
                        this.cateGoodsList.push(listItem);
                    }
                });

                this.goodsListRequests = null;
                cate.cateGoodsList = this.cateGoodsList;

                this._reloadGoods(this.cateGoodsList);
                if(this.thirdCategoryContainer){
                    this.thirdCategoryContainer.setCategory(this.thirdCategory);
                    this.expandedThirdCategoryContainer.setCategory(this.thirdCategory);
                }
            }, () => {
                this.goodsListRequests = null;
                this.sectionList.setLoadFail(true);
        })
    }

    //刷新商品数据
    _reloadGoods(goods, loadFail = false, loading = false){

        if(loading){
            if(!this.state.loadingGoods){
                this.setState({
                    loadingGoods: true
                })
            }
        }else {
            if(this.state.loadingGoods){
                this.setState({
                    loadingGoods: false
                })
            }
        }

        if(this.sectionList) {
            this.sectionList.reloadData(goods, loadFail, loading, () => {
                if (Platform.OS === 'android') {
                    if (this.containerScrollToEnd && this.props.onScrollToTop) {
                        let empty = false;
                        if (!this.cateGoodsList || this.cateGoodsList.length === 0) {
                            empty = true;
                        } else {
                            let lastItem = this.cateGoodsList[this.cateGoodsList.length - 1];
                            empty = !lastItem.data || lastItem.data.length === 0;
                        }
                        this.props.onScrollToTop(empty);
                    }
                }
            });
        }
    }

    /**
     * 点击一级分类
     */
    _clickFirstCategory(index){

        this.secondCategory = this.firstCategory[index].storeLabelList;

        this.secondSelectedIndex = 0;

        this.thirdCategory = [];
        this.thirdSelectedIndex = 0;
        if(this.secondCategory.length > 0){
            this.thirdCategory = this.secondCategory[0].storeLabelList;
        }

        if(this.secondCategoryContainer){
            this.secondCategoryContainer.setCategory(this.secondCategory);
        }
        this._loadGoodsList();

        if(!this.containerScrollToEnd && this.props.shouldScrollToEnd){
            this.props.shouldScrollToEnd();
        }
    }

    //点击二级分类
    _clickSecondCategory(index){

        this.thirdCategory = this.secondCategory[index].storeLabelList;
        if(this.thirdCategoryContainer){
            this.thirdCategoryContainer.setCategory(this.thirdCategory);
            this.expandedThirdCategoryContainer.setCategory(this.thirdCategory);
        }

        this.secondSelectedIndex = index;
        this.thirdSelectedIndex = 0;
        this._loadGoodsList();

        if(!this.containerScrollToEnd && this.props.shouldScrollToEnd){
            this.props.shouldScrollToEnd();
        }
    }

    //点击三级分类
    _clickThirdCategory(index, isExpanded){

        this.thirdSelectedIndex = index;
        if(isExpanded){
            this.expandedThirdCategoryContainer.setShow(false);
            this.thirdCategoryContainer.setSelectedIndex(index);
        }
        this._afterClickThirdCategory();
    }

    //点击三级分类完成
    _afterClickThirdCategory(){

        if(this.containerScrollToEnd){
            this._scrollToSelectedSection();
        }else {
            this.shouldScrollToSection = true;
            if(this.props.shouldScrollToEnd){
                this.props.shouldScrollToEnd();
            }
        }
    }

    //滑动到某个section
    _scrollToSelectedSection(){
        this.shouldScrollToSection = false;

        if(this.sectionList){
            let cateId = this.thirdCategory[this.thirdSelectedIndex].storeLabelId;
            let index = this.cateGoodsList.findIndex((item) => item.cateId === cateId);

            this.sectionList.scrollToLocation({
                animated: false,
                sectionIndex: index,
                itemIndex: 0,
            });
        }
    }

    /**
     * 设置商品列表是否滚动
     */
    setSectionListScrollEnabled(isScroll, scrollViewContainer){
        if(this.sectionList && this.sectionList.getSectionList()){
            this.sectionList.getSectionList().setNativeProps({
                scrollEnabled: isScroll,
                nestedScrollEnabled: isScroll
            });
        }

        if(scrollViewContainer){
            let empty = false;
            if(!this.cateGoodsList || this.cateGoodsList.length === 0){
                empty = true;
            }else {
                let lastItem = this.cateGoodsList[this.cateGoodsList.length - 1];
                empty = !lastItem.data || lastItem.data.length === 0;
            }

            let enable = !isScroll || !this.secondCategory || this.secondCategory.length === 0 || empty;
            if(!enable){
                //当可滚动范围大于 商品列表高度时 才设置父容器不能滚动
                enable = this._getGoodsContentHeight() <= this.goodsListHeight;
            }

            scrollViewContainer.setNativeProps({
                scrollEnabled: enable
            });
        }
    }

    //设置外层scrollView是否滑动底部了
    setContainerScrollToEnd(end){

        this.containerScrollToEnd = end;
        if(this.firstCategoryContainer){
            this.firstCategoryContainer.setContainerScrollToEnd(end);
        }
        if(Platform.OS === 'ios' && this.secondCategoryContainer && this.secondCategoryContainer.getScrollView()){

            this.secondCategoryContainer.getScrollView().setNativeProps({
                nestedChildRefreshEnable: end
            })
        }
    }

    //获取商品滑动范围高度
    _getGoodsContentHeight(){

        let height = 0;
        if((!this.thirdCategory || this.thirdCategory.length === 0)){
            height = 8;
        }

        if(this.cateGoodsList && this.cateGoodsList.length > 0){
            let itemHeight = 113 + (SCREEN_WIDTH - 100 - 24) / 2.0 + 5 + 8;
            let headerHeight = 32;
            for(let i = 0;i < this.cateGoodsList.length;i ++){
                let item = this.cateGoodsList[i];
                height += headerHeight;
                height += itemHeight * (item.data.length - 1);
                if(item.data.length === 0){
                    height += 200;
                }
            }
        }
        return height;
    }

    ///外层
    setOnMomentumScrollEnd(){
        if(this.shouldScrollToSection){
            this._scrollToSelectedSection();
        }
    }

    // componentWillReceiveProps(nextProps: Readonly<P>, nextContext: any): void {
    //
    //     if(nextProps.contentHeight !== this.state.contentHeight){
    //         this.setState({
    //             contentHeight: nextProps.contentHeight
    //         })
    //     }
    // }

    static getDerivedStateFromProps(nextProps, prevState) {
        const {contentHeight} = nextProps;
        if (contentHeight !== prevState.contentHeight) {
            return {
                contentHeight,
            };
        }
        // 否则，对于state不进行任何操作
        return null;
    }

    //获取商品列表section头部
    _getGoodsListSectionHeader(item){

        if(this.thirdCategory && this.thirdCategory.length > 0){
            let emptyView = null;
            if(!item.section.data || item.section.data.length === 0){
                emptyView = <EmptyView text={getString().categoryNoGoods} icon={goods_empty} style={{height: 200}}/>
            }
            return <View style={{ paddingHorizontal: 10, justifyContent: 'center'}}>
                <View style={{justifyContent: 'center', height: 32}}>
                    <Text allowFontScaling={false} style={{color: '#39362B', fontSize: 12}}>{item.section.title}</Text>
                </View>
                {emptyView}
            </View>
        }else{
            return null;
        }
    }

    //获取商品item
    _getGoodsListItem(item, index, section){

        let marginTop = 0;
        if(index < 2 && (!this.thirdCategory || this.thirdCategory.length === 0)){
            marginTop = 8;
        }
        return (
            <View style={{flexDirection: 'row'}}>
                <GoodsListItem style={[{marginLeft: 8, marginBottom: 8, marginTop: marginTop}, CommonStyles.shadow]} item={item[0]} width={(SCREEN_WIDTH - 100 - 24) / 2.0}/>
                {item.length > 1 ? <GoodsListItem style={[{marginLeft: 8, marginBottom: 8, marginTop: marginTop}, CommonStyles.shadow]} item={item[1]} width={(SCREEN_WIDTH - 100 - 24) / 2.0}/> : null}
            </View>
        )
    }

    //获取商品列表布局item
    _getGoodsListItemLayout(items, index){

        let marginTop = 0;
        if(index < 2 && (!this.thirdCategory || this.thirdCategory.length === 0)){
            marginTop = 8;
        }

        let itemHeight = 113 + (SCREEN_WIDTH - 100 - 24) / 2.0 + 5 + 8;
        let headerHeight = 32;
        let offset = marginTop;
        let idx = index;
        let length = marginTop;
        for(let i = 0;i < items.length;i ++){
            let item = items[i];
            if(idx < item.data.length + 2){
                if(idx === 0){
                    length = headerHeight;
                    if(item.data.length === 0){
                        length += 200;
                    }
                }else if(idx < item.data.length + 1) {
                    length = itemHeight;
                    offset += headerHeight;
                    if(item.data.length === 0){
                        offset += 200;
                    }
                    offset += (idx - 1) * itemHeight;
                }else {
                    //footer 忽略高度
                    offset += headerHeight;
                    if(item.data.length === 0){
                        offset += 200;
                    }
                    offset += (idx - 1) * itemHeight;
                }
                break;
            }else {
                offset += headerHeight + itemHeight * item.data.length;
                if(item.data.length === 0){
                    offset += 200;
                }
                idx -= 2;
                idx -= item.data.length;
            }
        }
        return {
            length,
            offset,
            index
        }
    }

    /**
     * 获取没有更多的view
     * @returns {*}
     * @private
     */
    _getNoMoreView(){

        if(this.cateGoodsList && this.cateGoodsList.length > 0){
            let lastItem = this.cateGoodsList[this.cateGoodsList.length - 1];
            if(lastItem.data && lastItem.data.length > 0){
                return <View style={{height: 50, alignItems: 'center', justifyContent: 'center'}}>
                    <Text allowFontScaling={false} style={{color:descTextColor}}>{getString().noMoreCategoryGoods}</Text>
                </View>
            }
        }
        return null;
    }

    _getGoodsListView(){

        return <BaseSectionList iosNestedScrollEnable={true}
                                onLayout={(event) => {
                                    this.goodsListHeight = event.nativeEvent.layout.height
                                }}
                                tag = {1010}
                                nestedParentTag={1001}
                                style={{flex:1}}
                                bounces={true}
                                ref={f => this.sectionList = f}
                                onReload={this._reloadData.bind(this)}
                                scrollEventThrottle={16}
                                emptyText={getString().categoryNoGoods}
                                onScroll={(event)=>{
                                    //console.log('SectionList',event.nativeEvent.contentOffset.y);
                                    let y = event.nativeEvent.contentOffset.y;
                                    if(y < 0){
                                        y = 0;
                                    }
                                    if(this.thirdCategoryContainer){
                                        this.thirdCategoryContainer.scrollToCategoryIndex(y, this.cateGoodsList);
                                    }

                                    if(Platform.OS === 'android'){
                                        if(this.containerScrollToEnd && this.props.onScrollToTop){
                                            this.props.onScrollToTop(y === 0);
                                        }
                                    }
                                }}
                                getItemLayout={this._getGoodsListItemLayout.bind(this)}
                                stickySectionHeadersEnabled={false}
                                showsVerticalScrollIndicator={true}
                                scrollEnabled={true}
                                nestedScrollEnabled={false}
                                ListFooterComponent={()=>this._getNoMoreView()}
                                getItem={({item, index, section}) => {
                                    return this._getGoodsListItem(item, index, section)
                                }}
                                renderSectionHeader={this._getGoodsListSectionHeader.bind(this)}
                                keyExtractor={(item, index) => index.toString()}/>
    }



    render(){

        let {isLoading,loadFail} = this.state;
        if(isLoading){
            return <Loading style={{height: this.state.contentHeight}}/>
        }else if(loadFail){
            return <FailPage style={{height: this.state.contentHeight}} onReload={this._reloadData.bind(this)}/>
        }

        if(!this.firstCategory || this.firstCategory.length === 0){
            return <EmptyView style={{height: this.state.contentHeight}} icon={goods_empty} text={getString().goodsSearchEmptyTip} />
        }

        let thirdCategoryView = null;
        let expandedThirdCategoryView = null;

        if(!this.state.loadingGoods && this.thirdCategory && this.thirdCategory.length > 0){
            thirdCategoryView = <ThirdCategory ref={f => this.thirdCategoryContainer = f} onClickCategory={(index) => {
                this._clickThirdCategory(index, false)
            }} category={this.thirdCategory} onClickMore={() => {
                this.expandedThirdCategoryContainer.setShow(true, this.thirdSelectedIndex);
            }}/>;
            expandedThirdCategoryView = <ExpandedThirdCategory ref={f => this.expandedThirdCategoryContainer = f} onClickCategory={(index) => {
                this._clickThirdCategory(index, true)
            }} category={this.thirdCategory} />
        }

        let secondCategoryView = null;

        if(!this.state.secondCategoryEmpty){
            secondCategoryView = <SecondCategory ref={f => this.secondCategoryContainer = f} onClickCategory={(index) => {
                    this._clickSecondCategory(index)
                }} category={this.secondCategory}/>
        }

        return <View style={{flex:1,backgroundColor:'white'}}>
            <View style={{flexDirection:'row',height:this.state.contentHeight - 45, marginTop: 45}}>
                {secondCategoryView}
                <View style={{flex:1}}>
                    {thirdCategoryView}
                    {this._getGoodsListView()}
                    {expandedThirdCategoryView}
                </View>
            </View>
            <FirstCategory ref={f => this.firstCategoryContainer = f} onClickCategory={(index) => {
                this._clickFirstCategory(index)
            }} category={this.firstCategory}/>
        </View>
    }
}

