import {SCREEN_WIDTH} from "../utils/AppUtil";
import {ic_label_down, ic_label_up} from "../constraint/Image";
import React, {Component} from 'react';
import {Image, ScrollView, Text, TouchableOpacity, View} from 'react-native';
import LinearGradient from "react-native-linear-gradient";

//三级分类
export class ThirdCategory extends Component{

    constructor(props){
        super(props);

        this.state = {
            category: props.category, //三级分类
            selectedIndex: 0, //选中的下标
            isShowMoreBtn: false, //是否显示更多按钮
        };

        //滑动视图宽度
        this.scrollViewWidth = 0;

        //分类标题宽度
        this.categoryWidthArr = [];
        this.categoryTotalWidth = 0; //总宽度
    }

    //设置分类
    setCategory(category){
        if(category !== this.state.category){
            this.categoryTotalWidth = 0;
            this.categoryWidthArr = [];
            this.setState({
                category,
                selectedIndex: 0,
                isShowMoreBtn: false
            }, () => {
                if(this.scrollView){
                    this.scrollView.scrollTo({
                        x: 0,
                        animated:false,
                    })
                }
            })
        }
    }

    //设置选中下标
    setSelectedIndex(selectedIndex){
        if(this.state.selectedIndex !== selectedIndex){
            this.setState({
                selectedIndex
            })
        }
    }

    //获取列表item
    _getItem(item, index){
        let {selectedIndex} = this.state;

        let {storeLabelName} = item;
        return <TouchableOpacity
            onLayout={(event) => {
                if(!event)return;
                let itemWidth = event.nativeEvent.layout.width + 4;
                this.categoryTotalWidth += itemWidth;
                this.categoryWidthArr[index] = itemWidth;

                let show = this.categoryTotalWidth + 100 >= SCREEN_WIDTH;
                if(show !== this.state.isShowMoreBtn){
                    this.setState({
                        isShowMoreBtn: show
                    })
                }
            }}
            activeOpacity={0.7} onPress={() => this._clickCategory(index)} key={index}
            style={{
                marginHorizontal: 2,
                height:40,
                maxWidth:120,
                alignItems: 'center',
                justifyContent: 'center',
                paddingHorizontal: 10,
                backgroundColor: index === selectedIndex ? '#C2FFFA' : '#EEEEEE'
            }}>
            <Text allowFontScaling={false} style={{color:index === selectedIndex?'#0FD7C8':'#999999',fontSize: 12,}} numberOfLines={2} ellipsizeMode='tail'>{storeLabelName}</Text>
        </TouchableOpacity>
    }

    //点击分类
    _clickCategory(selectedIndex){

        this.setState({
                selectedIndex,
            }, () => {
            if(this.props.onClickCategory) {
                this.props.onClickCategory(selectedIndex);
            }
        });
    }

    //滑到对应的分类下标
    scrollToCategoryIndex(dy, goodsList){
        if(dy === 0 || this.scrollViewWidth === 0) return;
        let {category} = this.state;
        if(!category || !goodsList)return;

        if(goodsList.length !== category.length) return;

        let itemHeight = 113 + (SCREEN_WIDTH - 100 - 24) / 2.0 + 5 + 8;
        let headerHeight = 32;
        let index = 0;
        let height = 0;
        for(let i = 0;i < goodsList.length;i ++){
            let item = goodsList[i];
            height += item.data.length * itemHeight + headerHeight;
            if(item.data.length === 0){
                height += 200;
            }
            if(height - dy < 1){
                index = i + 1;
            }else {
                break;
            }
        }

        if(index >= goodsList.length){
            index = goodsList.length - 1;
        }
        this.setState({
            selectedIndex: index
        },()=>{
            let dx = 0;
            for(let i = 0;i < index;i++){
                dx += this.categoryWidthArr[i];
            }

            let offset = this.scrollViewWidth / 2 - this.categoryWidthArr[index] / 2;
            if(dx > offset){
                dx -= offset;
            }else {
                dx = 0;
            }

            this.scrollView.scrollTo({
                x: dx,
                animated:true,
            })
        });
    }

    render(){
        let {category} = this.state;
        if(!category || category.length === 0)
            return null;

        let moreBtn = null;
        if(this.state.isShowMoreBtn){
            moreBtn = <TouchableOpacity
                activeOpacity={1}
                onPress={this.props.onClickMore}
                style={{
                    position: 'absolute',
                    right: 0,
                }}>
                <LinearGradient
                    style={{height: 45,
                        marginTop:2,
                        width: 30,
                        alignItems: 'center',
                        justifyContent: 'center'}}
                    colors={['rgba(255,255,255,00)','#FFFFFF']} start={{ x: 0, y: 1 }} end={{ x: 1, y: 1 }} locations={[0, 0.5]}>

                    <Image source={ic_label_down} style={{width:8,height:6}}/>
                </LinearGradient>
            </TouchableOpacity>;
        }
        return <View style={{height:50, backgroundColor: 'white'}}>
            <ScrollView onLayout={(event) => {
                this.scrollViewWidth = event.nativeEvent.layout.width - 30;
            }} ref={f=>this.scrollView=f} style={{flexDirection:'row', marginTop: 5}} horizontal={true} showsHorizontalScrollIndicator={false}>
                {category.map((item,index)=>this._getItem(item,index))}
                <View style={{height:30,width:30}}/>
            </ScrollView>
            {moreBtn}
        </View>
    }
}

//展开的三级分类
export class ExpandedThirdCategory extends Component{

    constructor(props){
        super(props);
        this.state = {
            category: props.category, //三级分类
            selectedIndex: props.selectedIndex, //选中的下标
            show: false, //显示
        };
    }

    setShow(show, selectedIndex = 0){
        if(this.state.show !== show){
            this.setState({
                show,
                selectedIndex,
            })
        }
    }

    //设置分类
    setCategory(category){
        if(category !== this.state.category){
            this.setState({
                category,
                selectedIndex: 0,
            })
        }
    }

    //获取列表item
    _getItem(item, index){
        let {selectedIndex} = this.state;

        let {storeLabelName} = item;
        return <TouchableOpacity
            activeOpacity={0.7} onPress={() => this._clickCategory(index)} key={index}
            style={{
                marginHorizontal: 2,
                height:40,
                maxWidth:120,
                alignItems: 'center',
                justifyContent: 'center',
                paddingHorizontal: 10,
                marginTop: 4,
                backgroundColor: index === selectedIndex ? '#C2FFFA' : '#EEEEEE'
            }}>
            <Text allowFontScaling={false} style={{color:index === selectedIndex?'#0FD7C8':'#999999',fontSize: 12,}} numberOfLines={2} ellipsizeMode='tail'>{storeLabelName}</Text>
        </TouchableOpacity>
    }

    //点击分类
    _clickCategory(selectedIndex){

        this.setState({
            selectedIndex,
        }, () => {
            if(this.props.onClickCategory) {
                this.props.onClickCategory(selectedIndex);
            }
        });
    }

    render(){
        if(!this.state.show)
            return null;
        let {category} = this.state;
        return <TouchableOpacity activeOpacity={1} onPress={() => {
            this.setShow(false, this.state.selectedIndex);
        }} style={{position:'absolute',backgroundColor:'rgba(0,0,0,0.6)',width:'100%',height:'100%'}}>
            <View style={{backgroundColor:'white'}}>
                <View style={{flexDirection: 'row',flexWrap:'wrap'}}>
                    {category.map((item,index)=>this._getItem(item,index,false))}
                </View>
                <View style={{alignItems:'center',justifyContent:'center'}}>
                    <TouchableOpacity activeOpacity={1} style={{height:30,width:30,alignItems:'center',justifyContent:'center'}} onPress={()=> {
                        this.setShow(false, this.state.selectedIndex);
                    }}>
                        <Image source={ic_label_up} style={{width:8,height:6}}/>
                    </TouchableOpacity>
                </View>
            </View>

        </TouchableOpacity>
    }
}
