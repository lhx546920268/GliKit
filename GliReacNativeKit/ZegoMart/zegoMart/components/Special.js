import React, {Component} from 'react'
import {Image, Text, TouchableOpacity, View} from 'react-native'
import {mainBackgroundColor} from "../constraint/Colors";
import {CommonStyles} from "../constraint/Styles";
import {back_white} from "../constraint/Image";
import {GoodsListItem} from "./widgets/GoodsListItem";
import {SCREEN_WIDTH} from "../utils/AppUtil";
import {AD_TYPE_BANNER, AD_TYPE_IMAGE, AD_TYPE_IMAGE_GOODS, AD_TYPE_IMAGE_LEFT_1, AD_TYPE_IMAGE_LEFT_2, AD_TYPE_IMAGE_RIGHT_2, adModelFromObject} from "../model/AdSectionModel";
import {Banner} from "./Banner";
import BaseSectionList from "../widgets/BaseSectionList";
import {get} from "../utils/HttpUtils";
import {isEmpty} from "../utils/StringUtil";
import {getParams} from "../utils/NavigationUtil";


//专题页
export class Special extends Component{

    constructor(props){
        super(props);
        this.state = {
            specialId: getParams(props, "specialId"), //专题编号
        };
        this.models = [];
    }

    componentDidMount() {
        this._reloadData();
    }

    //加载数据
    _reloadData(){
        this.refs.list.setLoading(true);
        this._loadSpecial();
    }

    //加载专题信息
    _loadSpecial(){
        get("zegomart/query/special", {
            specialId: this.state.specialId
        }).then(response => {
            let data = response.data;

            //专题标题
            let title = "";
            if(data.storeMobileSpecial != null){
                title = data.storeMobileSpecial.specialDesc;
            }
            this.refs.navigationBar.setTitle(title);

            //专题数据
            let itemList = data.storeMobileSpecialItemList;
            if(itemList != null && itemList.length > 0){
                for(let i = 0;i < itemList.length;i ++){
                    let model = adModelFromObject(itemList[i]);
                    if(model){
                        this.models.push(model);
                    }
                }
            }

            this.refs.list.reloadData(this.models);

        }, () => {
            this.refs.list.setLoadFail(true);
        })
    }

    ///点击广告
    _handleTouchAd(item){
         item.open(this.props.navigation);
    }

    //创建专题广告UI
    _getSpecialAd(models, index, model){

        switch (model.adType) {
            case AD_TYPE_BANNER : {
                return <Banner banner={model.models}/>
            }
            case AD_TYPE_IMAGE_LEFT_1 :
            case AD_TYPE_IMAGE_RIGHT_2 : {
                return (
                    <View style={{flexDirection: 'row'}}>
                        <TouchableOpacity disabled={isEmpty(model.models[0].data)} ref={f => model.models[0].ref = f} activeOpacity={0.7} onPress={() => {
                            this._handleTouchAd(model.models[0]);
                        }}>
                            <Image source={{uri : model.models[0].imageURL}} style={{ width: model.models[0].width, height: model.models[0].height}}/>
                        </TouchableOpacity>
                        <View>
                            <TouchableOpacity disabled={isEmpty(model.models[1].data)} ref={f => model.models[1].ref = f} activeOpacity={0.7} onPress={() => {
                                this._handleTouchAd(model.models[1]);
                            }}>
                                <Image source={{uri : model.models[1].imageURL}} style={{height: model.models[1].height, width: model.models[1].width}}/>
                            </TouchableOpacity>
                            <TouchableOpacity disabled={isEmpty(model.models[2].data)} ref={f => model.models[2].ref = f} activeOpacity={0.7} onPress={() => {
                                this._handleTouchAd(model.models[2]);
                            }}>
                                <Image source={{uri : model.models[2].imageURL}} style={{height: model.models[2].height, width: model.models[2].width}}/>
                            </TouchableOpacity>
                        </View>
                    </View>
                )
            }
            case AD_TYPE_IMAGE_LEFT_2 : {
                return (
                    <View style={{flexDirection: 'row'}}>
                        <View>
                            <TouchableOpacity disabled={isEmpty(model.models[0].data)} ref={f => model.models[0].ref = f} activeOpacity={0.7} onPress={() => {
                                this._handleTouchAd(model.models[0]);
                            }}>
                                <Image source={{uri : model.models[0].imageURL}} style={{height: model.models[0].height, width: model.models[0].width}}/>
                            </TouchableOpacity>
                            <TouchableOpacity disabled={isEmpty(model.models[1].data)} ref={f => model.models[1].ref = f} activeOpacity={0.7} onPress={() => {
                                this._handleTouchAd(model.models[1]);
                            }}>
                                <Image source={{uri : model.models[1].imageURL}} style={{height: model.models[1].height, width: model.models[2].width}}/>
                            </TouchableOpacity>
                        </View>
                        <TouchableOpacity disabled={isEmpty(model.models[2].data)} ref={f => model.models[2].ref = f} activeOpacity={0.7} onPress={() => {
                            this._handleTouchAd(model.models[2]);
                        }}>
                            <Image source={{uri : model.models[2].imageURL}} style={{width: model.models[2].width, height: model.models[2].height}}/>
                        </TouchableOpacity>
                    </View>
                )
            }
            case AD_TYPE_IMAGE : {
                return (
                    <View style={{flexWrap: 'wrap', flexDirection: 'row'}}>
                        {model.models.map((item, idx) => {
                            return <TouchableOpacity key={idx} disabled={isEmpty(item.data)} ref={f => item.ref = f} activeOpacity={0.7} onPress={() => {this._handleTouchAd(item)}}>
                                <Image source={{uri : item.imageURL}} style={{height: item.height, width: item.width}}/>
                            </TouchableOpacity>;
                        })}
                    </View>
                )
            }
            case AD_TYPE_IMAGE_GOODS : {
                return (
                    <View style={{flexDirection: 'row'}}>
                        <GoodsListItem addIconSize={25} style={{marginLeft: 8, marginBottom: 8, marginTop: (index === 0 ? 8 : 0)}} item={models[0]} width={(SCREEN_WIDTH - 24) / 2.0}/>
                        {models.length > 1 ? <GoodsListItem addIconSize={25} style={{marginLeft: 8, marginBottom: 8, marginTop: (index === 0 ? 8 : 0)}} item={models[1]} width={(SCREEN_WIDTH - 24) / 2.0}/> : null}
                    </View>
                )
            }
        }
        return null;
    }

    render(){
        return (
            <View style={{backgroundColor: mainBackgroundColor, flex: 1}}>
                <NavigationBar ref="navigationBar" navigation={this.props.navigation}/>
                <BaseSectionList style={{flex: 1}}
                              ref="list"
                              getItem={({item, index, section}) => {
                                  return this._getSpecialAd(item, index, section)
                              }}
                              onReload={this._reloadData.bind(this)}/>
            </View>
        )
    }
}

class NavigationBar extends Component{

    constructor(props){
        super(props);
        this.state = {
            title: "", //标题
        }
    }

    //返回
    _handleBack() {
        this.props.navigation.goBack();
    }

    //设置标题
    setTitle(title){
        this.setState({title});
    }

    render() {
        return (
            <View style={[CommonStyles.navigationBar, {justifyContent:"flex-start", flexDirection: 'row'}]}>
                <TouchableOpacity activeOpacity={0.7} style={{padding:15}} onPress={() => this._handleBack()}>
                    <Image style={{
                        width:11,
                        height:18}}
                           source={back_white}/>
                </TouchableOpacity>
                <Text allowFontScaling={false} style={{color: 'white', fontSize: 17, alignSelf: 'center', marginRight: 41, flex: 1, textAlign: 'center'}}>{this.state.title}</Text>
            </View>
        )
    }
}
