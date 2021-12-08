import {Animated, Easing} from "react-native";
import StackViewStyleInterpolator from "react-navigation-stack/src/views/StackView/StackViewStyleInterpolator";
import ZegoMart from "../components/ZegoMart";
import GoodsList from "../components/GoodsList"
import {Special} from "../components/Special";

export const routeConfig = {
  ZegoMart: { screen: ZegoMart },
  GoodsList: {screen: GoodsList},
  Special: {screen: Special},
};

export function getRouterConfig(initPage) {
  return {
    initialRouteName: initPage, // 默认显示界面
    headerMode: 'none',
    mode: 'card',
    navigationOptions: {
      gesturesEnabled: true
    },
    transitionConfig: () => ({
      transitionSpec: {
        duration: 250,
        easing: Easing.out(Easing.poly(3)),
        timing: Animated.timing
      },
      screenInterpolator: StackViewStyleInterpolator.forHorizontal
    })
  };
}
