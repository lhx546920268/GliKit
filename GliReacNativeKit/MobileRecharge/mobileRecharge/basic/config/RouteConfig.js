import {Animated, Easing} from "react-native";
import StackViewStyleInterpolator from "react-navigation-stack/src/views/StackView/StackViewStyleInterpolator";
import Recharge from '../../page/Recharge/Recharge';
import OrderList from '../../page/Order/OrderList';
import OrderDetail from "../../page/Order/OrderDetail";

//页面路由配置
export const routeConfig = {
  Recharge: { screen: Recharge },
  OrderList: { screen: OrderList },
  OrderDetail: { screen: OrderDetail },
};

export function getRouterConfig(initPage, params) {

  return {
    initialRouteName: initPage, // 默认显示界面
    initialRouteParams: params,
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
