import React, {Component} from 'react'
import {Image, Keyboard, Platform, TextInput, TouchableOpacity, View} from 'react-native'
import PropTypes from 'prop-types'
import {clear_btn} from "../../res/Image";

//输入框
export class TextField extends Component{

    static defaultProps = {
        onKeyboardShow: null, //键盘显示
        onKeyboardHide: null, //键盘隐藏
    };

    static propTypes = {
        onKeyboardHide: PropTypes.func,
        onKeyboardShow: PropTypes.func,
    };

    constructor(props) {
        super(props);
        this.state = {
            showClear: false, //是否显示删除按钮
        };
        //当前文字
        this.text = this.props.defaultValue;
    }

    componentDidMount(){
        this.keyboardDidHideListener = Keyboard.addListener("keyboardDidHide", () => {
            if(Platform.OS === 'android'){
                //安卓键盘隐藏可能还没有失去焦点
                Keyboard.dismiss();
            }
        });
    }

    componentWillUnmount(){
        this.keyboardDidHideListener.remove();
    }

    //是否有文字
    _hasText(){
        return this.text != null && this.text.length > 0;
    }

    //聚焦
    _handleOnFocus(){
        this.setState({
            showClear: this._hasText()
        });
        requestAnimationFrame(() => {
            if(this.props.onKeyboardShow != null){
                this.props.onKeyboardShow();
            }
        })
    }

    //失去焦点
    _handleOnBlur(){
        this.setState({
            showClear: false
        });
        if(this.props.onKeyboardHide != null){
            this.props.onKeyboardHide();
        }
    }

    //文字输入改变
    _handleOnChangeText(text){
        if(this.props.onChangeText){
            this.props.onChangeText(text);
        }
        this.text = text;
        this.setState({
            showClear: this._hasText()
        })
    }

    //清除
    _handleClear(){
        this.refs.textInput.clear();
        this.text = "";
        this.setState({
            showClear: false
        })
    }

    render(){

        return (
            <View style={[this.props.style, {flexDirection: 'row'}]}>
                <TextInput ref="textInput" style={{flex: 1, fontSize: 14, padding: 0}}
                           allowFontScaling={false}
                           placeholder={this.props.placeholder}
                           returnKeyType={this.props.returnKeyType}
                           placeholderTextColor='#cccccc'
                           ellipsizeMode='tail'
                           defaultValue={this.props.defaultValue}
                           onChangeText={(text) => {
                               this._handleOnChangeText(text);
                           }}
                           underlineColorAndroid='transparent'
                           onFocus={this._handleOnFocus.bind(this)}
                           onBlur={this._handleOnBlur.bind(this)}
                           onSubmitEditing={this.props.onSubmitEditing}
                           blurOnSubmit={this.props.blurOnSubmit}
                           maxLength={this.props.maxLength}
                           autoCapitalize="none"/>
                {this.state.showClear ? <TouchableOpacity onPress={this._handleClear.bind(this)} activeOpacity={0.7} style={{paddingLeft: 10, paddingRight: 10, height: '100%', alignItems: 'center', justifyContent: 'center'}}>
                    <Image source={clear_btn} style={{width: 15, height: 15}}/>
                </TouchableOpacity> : null}
            </View>
        )
    }
}
