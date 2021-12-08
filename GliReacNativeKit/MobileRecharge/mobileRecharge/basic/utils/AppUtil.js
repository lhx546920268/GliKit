import {Dimensions, Platform, StatusBar} from 'react-native';
import {isIphoneX} from 'react-native-iphone-x-helper';

export function getIphoneXBottomHeight() {
  if (isIphoneX()) {
    return 34;
  }
  return 0;
}

export function getIphoneXTopHeight() {
  if (Platform.OS === 'android') {
    return StatusBar.currentHeight;
  } else {
    if (isIphoneX()) {
      return 44;
    } else {
      return 20;
    }
  }
}

const {height, width} = Dimensions.get('screen');
export const SCREEN_WIDTH = width;
export const SCREEN_HEIGHT = height;
