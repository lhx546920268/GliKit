import React from 'react';
import {KeyboardAvoidingView, FlatList, Text, TouchableOpacity} from 'react-native';
import PropTypes from 'prop-types'
import {contentLightTextColor, titleTextColor} from "../../res/Colors";
import {SCREEN_WIDTH} from "../../basic/utils/AppUtil";

//联系人匹配结果
export default class ContactMatchingResult extends React.Component{

    static defaultProps = {
        contacts: null, //联系人
        onContactSelect: null, //选择某个联系人
    };

    static propsTypes = {
        contacts: PropTypes.array,
        onContactSelect: PropTypes.func,
    };

    constructor(props){
        super(props);

        this.state = {
            contacts: props.contacts, //匹配到的联系人
        }
    }

    //获取item
    _getItem(item, index){

        return <TouchableOpacity activeOpacity={0.7} onPress={() => {
            if(this.props.onContactSelect){
                this.props.onContactSelect(item);
            }
        }} style={{height: 45, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between'}}>

            <Text allowFontScaling={false} style={{color: titleTextColor, fontSize: 16, marginLeft: 15}}>{item.mobile}</Text>
            <Text allowFontScaling={false} style={{color: contentLightTextColor, fontSize: 14, marginRight: 15}}>{item.name}</Text>
        </TouchableOpacity>
    }

    render(){
        return <KeyboardAvoidingView style={{position: 'absolute', height: '100%', width: SCREEN_WIDTH, backgroundColor: 'white'}}>
            <FlatList keyboardShouldPersistTaps="handled"
                      data={this.state.contacts}
                      alwaysBounceVertical={false}
                      keyExtractor={(item, index) => index.toString()}
                      renderItem={({item, index}) => {
                          return this._getItem(item, index);
                      }}/>
        </KeyboardAvoidingView>
    }
}
