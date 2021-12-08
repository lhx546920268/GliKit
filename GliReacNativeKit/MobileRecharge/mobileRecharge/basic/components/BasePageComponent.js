import React from 'react';
import Loading from './Loading';
import {View} from 'react-native';
import FailPage from './FailPage';
import EmptyView from './EmptyView';
import {getString} from '../utils/LauguageUtils';
import IPhoneXTop from './IPhoneXTop';
import IPhoneXBottom from './IPhoneXBottom';
import {goBackToNative} from "../utils/NativeMethodUtil";
import {goods_empty} from "../../res/Image";

export const STATUS_NORMAL = 0; //正常状态
export const STATUS_LOADING = 1; //loading
export const STATUS_FAIL = 2; //页面加载失败
export const STATUS_EMPTY = 3; //显示空视图

//基础页面组件
export default class BasePageComponent extends React.Component{

    constructor(props){
        super(props);

        this.state = {
            pageStatus: STATUS_NORMAL //页面状态
        }
    }

    //设置页面状态
    setPageStatus(status, callback){
        if(status !== this.state.pageStatus) {
            this.setState({
                pageStatus: status
            }, callback)
        }
    }

    render() {
        let content = null;
        switch (this.state.pageStatus) {
            case STATUS_NORMAL : {
                content = this.getContent();
            }
            break;
            case STATUS_LOADING : {
                content = <Loading style={{flex: 1}}/>;
            }
            break;
            case STATUS_FAIL : {
                content = <FailPage style={{flex: 1}} onReload={() => {
                    this.onReload();
                }}/>;
            }
            break;
            case STATUS_EMPTY : {
                content = <EmptyView icon={this.getEmptyIcon()} text={this.getEmptyText()} style={{flex: 1}}/>
            }
        }

        return <View style={{flex: 1}}>
            <IPhoneXTop style={this.getIPhoneXTopStyle()}/>
            {this.getHeader()}
            {content}
            {this.getFooter()}
            <IPhoneXBottom style={this.getIPhoneXBottomStyle()}/>
        </View>
    }

    //返回
    goBack(){
        this.props.navigation.goBack();
    }

    //关闭rn
    close(){
        goBackToNative();
    }

    //重新加载
    onReload(){
        this.setPageStatus(STATUS_LOADING);
    }

    //获取顶部iPhoneX样式
    getIPhoneXTopStyle() {
        return null;
    }

    //获取底部安全区域样式
    getIPhoneXBottomStyle(){
        return {backgroundColor: 'white'};
    }

    //获取头部
    getHeader(){
        return null;
    }

    //获取底部
    getFooter(){
        return null;
    }

    //获取内容视图
    getContent(){
        return null;
    }

    //获取空视图图标
    getEmptyIcon(){
        return goods_empty;
    }

    //获取空视图文字
    getEmptyText(){
        return getString().nothing;
    }
}
