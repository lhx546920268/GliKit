import React, {Component} from 'react'
import PropTypes from 'prop-types'
import {ActivityIndicator, Text, View} from 'react-native'
import {getString} from '../constraint/String';

//加载更多状态
export const STATUS_NORMAL = "normal"; //正常状态
export const STATUS_LOADING = "loading"; //加载中
export const STATUS_FAIL = "fail"; //加载失败
export const STATUS_NO_MORE_DATA = "no_more_data"; //没有更多数据

//加载更多
export class LoadMoreControl extends Component{

    static defaultProps = {
        status: STATUS_NO_MORE_DATA, //加载状态
    };

    static propsTypes = {
        status: PropTypes.string,
    };

    constructor(props) {
        super(props);
    }

    render() {
        
        //菊花
        let indicator = null;
        let text = null;
        let leftLine = null;
        let rightLine = null;

        switch (this.props.status) {
            case STATUS_LOADING: {
                text = getString().loading;
                indicator = <ActivityIndicator color="gray" style={{ marginRight: 25 }} />;
            }
                break;
            case STATUS_NO_MORE_DATA: {
                text = getString().noMoreDatas;
                leftLine = <View style={{backgroundColor: '#cccccc', height: 0.5, marginRight: 15, marginLeft: 15, flex: 1}}/>
                rightLine = <View style={{ backgroundColor: '#cccccc', height: 0.5, marginLeft: 15, marginRight: 15, flex: 1}} />
            }
                break;
            case STATUS_FAIL: 
                break;
            default:
                break;
        }

        return (
            <View style={{height: 44, flexDirection: 'row', justifyContent: 'center', alignItems: 'center'}}>
                {indicator}
                {leftLine}
                <Text allowFontScaling={false} style={{color: '#cccccc', fontSize: 14}}>{text}</Text>
                {rightLine}
            </View>
        )
    }
}