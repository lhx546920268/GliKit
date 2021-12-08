import {SCREEN_HEIGHT, SCREEN_WIDTH} from "../utils/AppUtil";
import {mainBackgroundColor, mainColor} from "../constraint/Colors";
import {CommonStyles} from "../constraint/Styles";
import PropTypes from "prop-types";
import Carousel from "react-native-snap-carousel";
import React, {Component} from 'react';
import {Image, TouchableOpacity, View,} from 'react-native';
import {ic_banner_bg} from "../constraint/Image";

//轮播图
export class Banner extends Component {

    static defaultProps = {
        banner: [], //轮播图数据
    };

    static propTypes = {
        banner: PropTypes.array,
    };

    constructor(props) {
        super(props);

        this.state = {
            // isLoading:true,
            bannerIndex: 0,
            banner: this.props.banner,
        }
    }

    //点击轮播图广告
    _handleTouchBannerAd(item) {
        item.open(this.props.navigation);
    }

    _getContent(itemWidth) {

        let {banner} = this.state;
        return <View style={{flex: 1}}>
            <View style={{position: 'absolute', top: 80 - SCREEN_HEIGHT / 2, height: SCREEN_HEIGHT / 2,}}>
                <View>
                    <View style={{
                        backgroundColor: '#2C2D31',
                        width: SCREEN_WIDTH,
                        height: SCREEN_HEIGHT / 2 - 30,
                        alignItems: "center",
                        justifyContent: "center"
                    }}/>
                    <Image source={ic_banner_bg} style={{width: SCREEN_WIDTH, height: SCREEN_WIDTH * 0.072}}/>
                </View>
            </View>
            <Carousel
                inactiveSlideOpacity={1}
                ref="carousel"
                data={banner}
                renderItem={({item, index}) => {
                    return <TouchableOpacity key={index} activeOpacity={1} onPress={() => {
                        item.ref = this.refs.carousel;
                        this._handleTouchBannerAd(item);
                    }}
                                             style={{
                                                 width: itemWidth,
                                                 height: itemWidth * 0.5,
                                                 alignItems: 'center',
                                                 justifyContent: 'center'
                                             }}>
                        <View style={[{borderRadius: 5, backgroundColor: mainBackgroundColor,}, CommonStyles.shadow]}>
                            <Image source={{uri: item.imageURL}} style={{
                                height: itemWidth * 0.5,
                                width: itemWidth,
                                borderRadius: 5
                            }}/>
                        </View>
                    </TouchableOpacity>
                }}
                sliderWidth={SCREEN_WIDTH}
                autoplay={true}
                loop={true}
                onSnapToItem={index => {
                    this.setState({bannerIndex: index})
                }}
                itemWidth={itemWidth}
            />
            <View style={{
                flexDirection: 'row',
                position: 'absolute',
                width: '100%',
                bottom: 0,
                alignItems: 'center',
                justifyContent: 'center'
            }}>
                {banner.map((item, index) => <View key={index} style={{
                    marginHorizontal: 5,
                    width: 8,
                    height: 8,
                    borderRadius: 4,
                    backgroundColor: this.state.bannerIndex === index ? mainColor : '#cccccc'
                }}/>)}
            </View>
        </View>
    }

    render() {
        let itemWidth = SCREEN_WIDTH - 60;
        return <View style={{width: '100%', height: itemWidth * 0.55, marginTop: 10}}>
            {this._getContent(itemWidth)}
        </View>
    }
}