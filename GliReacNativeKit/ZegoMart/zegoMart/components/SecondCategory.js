import React, {Component} from 'react';
import {ScrollView, Text, TouchableOpacity, View} from 'react-native';

//二级分类
export default class SecondCategory extends Component{

    constructor(props){
        super(props);

        this.state = {
            category: props.category, //二级分类
            selectedIndex: 0, //选中的下标
        };
    }

    //设置分类
    setCategory(category){
        if(category !== this.state.category){
            this.setState({
                category,
                selectedIndex: 0
            })
        }
    }

    //获取滑动视图
    getScrollView(){
        return this.scrollView;
    }

    //点击分类
    _clickCategory(selectedIndex){
        if(selectedIndex === this.state.selectedIndex)
            return;

        this.setState({
            selectedIndex
        });

        if(this.props.onClickCategory) {
            this.props.onClickCategory(selectedIndex);
        }
    }

    //获取item
    _getItem(item,index){
        let {selectedIndex} = this.state;
        let {storeLabelName} = item;
        return <TouchableOpacity key={index} onPress={()=>this._clickCategory(index)} activeOpacity={0.7} style={{
            alignItems: 'center',
            justifyContent: 'center',
            minHeight: 60,
            padding: 10,
            borderBottomWidth: 0.5,
            borderBottomColor: '#DEDEDE',
            borderLeftWidth: 4,
            borderLeftColor: index === selectedIndex ? '#0FD7C8' : '#F2F2F2',
            backgroundColor: index === selectedIndex ? 'white' : '#F2F2F2'
        }}>
            <Text allowFontScaling={false} numberOfLines={2} ellipsizeMode='tail' style={{
                color: index === selectedIndex ? '#0FD7C8' : '#39362B',
                textAlign: 'center',
                fontSize: 11
            }}>{storeLabelName}</Text>
        </TouchableOpacity>
    }

    render(){
        let {category} = this.state;
        if(!category) return null;
        return <View style={{width: 100,backgroundColor:'#F2F2F2',height:'100%'}}>
            <ScrollView iosNestedScrollEnable={true}
                        tag = {1011}
                        nestedParentTag={1001} ref={f=>this.scrollView=f} nestedScrollEnabled={true}  showsVerticalScrollIndicator={false}>
                {category.map((item,index)=>this._getItem(item,index))}
            </ScrollView>
        </View>
    }
}
