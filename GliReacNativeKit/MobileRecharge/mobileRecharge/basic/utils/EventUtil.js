import {DeviceEventEmitter, NativeEventEmitter, NativeModules,} from 'react-native';
import {NATIVE_MODULE} from './NativeMethodUtil';

export const postEvent = (event, value) => {
  DeviceEventEmitter.emit(event, value);
};

export const registerEvent = (event, callback) => {
  return DeviceEventEmitter.addListener(event, value => {
    if (callback) {
      callback(value);
    }
  });
};

export const registerEventToNative = (event, callback) => {
  if (!NativeModules[NATIVE_MODULE]) {
    return;
  }
  return new NativeEventEmitter(NativeModules[NATIVE_MODULE]).addListener(
    event,
    value => {
      if (callback) {
        callback(value);
      }
    },
  );
};

export const EVENT_ON_LOGIN = 'EVENT_ON_LOGIN'; //登录成功
export const EVENT_ON_LOGOUT = 'EVENT_ON_LOGOUT'; //退出登录
