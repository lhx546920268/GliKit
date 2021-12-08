import React, {Component} from "react"
import {Image, View} from 'react-native'
import PropTypes from 'prop-types'
import {placeholder_square} from "../constraint/Image";

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
        return (
            <View style={this.props.style}>
                <Image source={this.props.source} style={{position: 'absolute', width: '100%', height: '100%'}} onLoad={() => {
                    this.setState({
                        loading: false,
                    })
                }}/>
                {this.state.loading ? <Image source={placeholder_square} style={{position: 'absolute', width: '100%', height: '100%'}}/> : null}
            </View>
        )
    }
}