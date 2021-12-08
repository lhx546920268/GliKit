import {Animated, Easing} from "react-native";
import StackViewStyleInterpolator from "react-navigation-stack/src/views/StackView/StackViewStyleInterpolator";
import OrderDetail from "../../page/OrderDetail";

//页面路由配置
export const routeConfig = {

  OrderDetail: { screen: OrderDetail },
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
