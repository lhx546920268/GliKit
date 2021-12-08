import React, {Component} from "react"
import {Image, View} from 'react-native'
import PropTypes from 'prop-types'
import {placeholder_square} from "../../res/Image.js";
import {isEmpty} from "../utils/StringUtil";

//图片
export class ImageView extends Component{

    static defaultProps = {
        source: {}, //要加载的图片资源
    };

    static propTypes = {
        source: PropTypes.object,
    };

    constructor(props){
        super(props);
        this.state = {
            loading: true
        }
    }

    render(){

        let uri = this.props.source.uri;
        if(isEmpty(uri)){
            uri = undefined;
        }

        return (
            <View style={this.props.style}>
                <Image source={{uri: uri}} style={{position: 'absolute', width: '100%', height: '100%'}} onLoad={() => {
                    this.setState({
                        loading: false,
                    })
                }}/>
                {this.state.loading ? <Image source={placeholder_square} style={{position: 'absolute', width: '100%', height: '100%'}}/> : null}
            </View>
        )
    }
}
