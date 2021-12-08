import React, {Component} from 'react';
import {ScrollView, Text, TouchableOpacity, View} from 'react-native';
import LinearGradient from "react-native-linear-gradient";
import {SCREEN_WIDTH} from "../utils/AppUtil";

//一级分类
export default class FirstCategory extends Component{

    constructor(props){
        super(props);
        this.state = {
            containerScrollToEnd: false, //外部容器是否已回到底部
            category: props.category,  //一级分类信息
            selectedIndex: 0, //选中的下标
        };

        //分类标题宽度
        this.categoryWidthArr = [];

        //分类背景颜色
        this.bgColorList = [['#3DE4AD','#23D7D1'],['#BFC2E6','#91A2D0'],['#60E3FF','#41B8FD'],['#A298FF','#EE8BFF'],['#FF98E1','#FF8B9F']];
    }

    //外部容器滑动到底部
    setContainerScrollToEnd(end){
        if(this.state.containerScrollToEnd === end)
            return;
        this.setState({
            containerScrollToEnd: end
        })
    }

    _getBgColor(index){
        return this.bgColorList[index % this.bgColorList.length]
    }

    //获取列表item
    _getItem(item,index){
        let {groupName} = item;
        let {selectedIndex} = this.state;
        return <TouchableOpacity key={index} activeOpacity={0.7} onLayout={event=>{
            if(!event)return;
            this.categoryWidthArr[index] = event.nativeEvent.layout.width;

        }} onPress={()=>this._clickCategory(index)}>
            <LinearGradient
                style={{paddingHorizontal:10,height:35,alignItems:'center',justifyContent:'center',borderRadius:5,marginLeft:5,marginVertical:5}}
                colors={this._getBgColor(index)} start={{ x: 0, y: 0 }} end={{ x: 1, y: 1 }} locations={[0, 0.5]}>
                <Text allowFontScaling={false} style={{color:'white', fontSize: 14, fontWeight: 'bold'}}>{groupName}</Text>
                {selectedIndex === index ? <View style={{marginHorizontal:10,width:'100%',height:2,backgroundColor:'white',position:'absolute',bottom:3}}/>:null}
            </LinearGradient>
        </TouchableOpacity>
    }

    //点击分类
    _clickCategory(selectedIndex){
        if(selectedIndex === this.state.selectedIndex)
            return;

        this.setState({
            selectedIndex
        }, () => {
            let dx = 0;
            for(let i = 0;i <= selectedIndex;i ++){
                let width = this.categoryWidthArr[i];
                if(i < selectedIndex){
                    dx += width;
                }else {
                    dx += width / 2;
                }
            }
            dx -= SCREEN_WIDTH / 2;
            if(dx < 0){
                dx = 0;
            }
            this.scrollView.scrollTo({
                x: dx,
                animated: true
            });
        });

        if(this.props.onClickCategory){
            this.props.onClickCategory(selectedIndex);
        }
    }

    render(){
        let {category} = this.state;
        let shadow = this.state.containerScrollToEnd ? {shadowColor: '#00000033',shadowOffset: {height: 2, width: 0},shadowRadius: 5,shadowOpacity: 0.5, elevation: 2} : null;
        return <View style={[{position: 'absolute', width: '100%', backgroundColor: 'white'}, shadow]}>
            <ScrollView ref={f=>this.scrollView = f} horizontal={true} showsHorizontalScrollIndicator={false}>

                {category.map((item,index)=>this._getItem(item,index))}
                <View style={{width:5}}/>
            </ScrollView>
        </View>
    }
}
