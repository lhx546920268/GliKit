import React, {Component} from 'react'
import PropTypes from 'prop-types'
import {FlatList} from 'react-native'
import {LoadMoreControl, LOAD_MORE_STATUS_LOADING, LOAD_MORE_STATUS_NO_MORE_DATA, LOAD_MORE_STATUS_NORMAL} from './LoadMoreControl';

//基础列表
export default class BaseFlatList extends Component {

    static defaultProps = {
        getItem: null, //渲染item回调
        loadMoreEnable: false, //是否可以加载更多
        onLoadMore: null, //加载更多回调
        hasMore: false, //是否还有更多
    };

    static propsTypes = {
        getItem: PropTypes.func,
        loadMoreEnable: PropTypes.bool,
        onLoadMore: PropTypes.func,
        hasMore: PropTypes.bool
    };

    constructor(props) {
        super(props);
        this.state = {
            loadMoreStatus: props.hasMore ? LOAD_MORE_STATUS_NORMAL : LOAD_MORE_STATUS_NO_MORE_DATA, //加载更多状态
            data: props.data, //数据
        }
    }

    //是否正在加载更多
    isLoadingMore(){
        return this.props.loadMoreEnable && this.state.loadMoreStatus === LOAD_MORE_STATUS_LOADING;
    }

    //加载更多完成
    stopLoadMore(data, hasMore){
        if (!this.props.loadMoreEnable) {
            return;
        }
        this.setState({
            data: data,
            loadMoreStatus: hasMore ? LOAD_MORE_STATUS_NORMAL : LOAD_MORE_STATUS_NO_MORE_DATA
        })
    }

    //加载更多失败
    stopLoadMoreWithFail(){
        this.stopLoadMore(this.state.data, true);
    }

    //触发加载更多
    _onLoadMore(){
        if (!this.props.loadMoreEnable) {
            return null;
        } else {

            if(this.state.loadMoreStatus === LOAD_MORE_STATUS_NORMAL && (typeof this.props.onLoadMore === 'function')){
                this.setState({
                    loadMoreStatus : LOAD_MORE_STATUS_LOADING
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

    render() {
        return <FlatList
            style={this.props.style}
            data={this.state.data}
            keyExtractor={(item, index) => index.toString()}
            renderItem={this.props.renderItem}
            ListFooterComponent={this._getListFooterComponent.bind(this)}
            onEndReached={this._onLoadMore.bind(this)}
            onEndReachedThreshold={0.05}
        />;
    }
}
