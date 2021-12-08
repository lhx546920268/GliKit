import React, {Component} from 'react'
import PropTypes from 'prop-types'
import {Platform, SectionList} from 'react-native'
import EmptyView from "../components/widgets/EmptyView";
import Loading from "../components/widgets/Loading";
import {LoadMoreControl, STATUS_LOADING, STATUS_NO_MORE_DATA, STATUS_NORMAL} from './LoadMoreControl';
import FailPage from '../components/widgets/FailPage';
import {goods_empty} from "../constraint/Image";
import {getString} from '../constraint/String';

//基础列表
export default class BaseSectionList extends Component {

    static defaultProps = {
        onReload: null, //重新加载回调
        getItem: null, //渲染item回调
        emptyIcon: goods_empty, //空视图图标
        emptyText: getString().noMoreDatas, //空视图文字
        loadMoreEnable: false, //是否可以加载更多
        onLoadMore: null, //加载更多回调
    };

    static propsTypes = {
        onReload: PropTypes.func,
        getItem: PropTypes.func,
        emptyIcon: PropTypes.object,
        emptyText: PropTypes.string,
        loadMoreEnable: PropTypes.bool,
        onLoadMore: PropTypes.func,
    };

    constructor(props) {
        super(props);
        this.state = {
            loading: false, //加载中
            loadFail: false, //失败
            loadMoreStatus: STATUS_NORMAL, //加载更多状态
            data: null, //数据
        }
    }

    //刷新列表
    reloadData(newData, hasMore = false, loading = false, callback){

        this.setState({
            data: newData,
            loadMoreStatus: hasMore ? STATUS_NORMAL : STATUS_NO_MORE_DATA,
            loading : loading,
            loadFail: false
        }, () => {
            this.scrollToLocation({
                animated: false,
                sectionIndex: 0,
                itemIndex: 0,
            });
            if(callback && typeof  callback === "function"){
               callback();
            }
        });
    }

    //加载失败
    setLoadFail(fail) {
        this.setState({loading: false, loadFail: fail});
    }

    //加载中
    setLoading(loading) {
        this.setState({loading: loading, loadFail: false});
    }

    //是否正在加载更多
    isLoadingMore(){
        return this.props.loadMoreEnable && this.state.loadingStatus === STATUS_LOADING;
    }

    //加载更多完成
    stopLoadMore(hasMore){
        if (!this.props.loadMoreEnable) {
            return;
        }

        this.setState({
            loadMoreStatus: hasMore ? STATUS_NORMAL : STATUS_NO_MORE_DATA
        })
    }

    //加载更多失败
    stopLoadMoreWithFail(){
        this.stopLoadMore(true);
    }

    //触发加载更多
    _onLoadMore(){
        if (!this.props.loadMoreEnable) {
            return null;
        } else {

            if(this.state.loadMoreStatus === STATUS_NORMAL && (typeof this.props.onLoadMore === 'function')){
                this.setState({
                    loadMoreStatus : STATUS_LOADING
                });
                this.props.onLoadMore();
            }
        }
    }

    //获取底部视图
    _getListFooterComponent(){
        if (!this.props.loadMoreEnable){
            return null;
        }else{
            return <LoadMoreControl status={this.state.loadMoreStatus} />
        }
    }

    getSectionList(){
        return this.refs.list;
    }

    scrollToLocation(params){
        if(this.refs.list){
            try{
                this.refs.list.scrollToLocation(params);
            }catch {

            }
        }
    }

    render() {

        let contentView = null; //内容视图

        if (this.state.loading) {
            contentView = <Loading style={this.props.style}/>
        } else if (this.state.loadFail) {
            contentView = <FailPage style={this.props.style} onReload={this.props.onReload}/>
        } else {
            let data = this.state.data;

            if (data != null && data.length > 0) {
                contentView = <SectionList
                    {...this.props}
                    ref = "list"
                    style={this.props.style}
                    sections={data}
                    keyExtractor={(item, index) => item + index}
                    renderItem={this.props.getItem}
                    ListFooterComponent={this.props.ListFooterComponent ? this.props.ListFooterComponent : this._getListFooterComponent.bind(this)}
                    onEndReached={this._onLoadMore.bind(this)}
                    onEndReachedThreshold={0.2}
                />
            } else {
                contentView = <EmptyView icon={this.props.emptyIcon} text={this.props.emptyText}/>
            }
        }
        return contentView;
    }
}
