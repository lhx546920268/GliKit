# GliKit

iOS 基础框架，GliKt是基础组件库，GliKitDemo是测试Demo

使用

> pod 'GliKit', :path => '../GliKit'  

## 1. 全局设置 
可通过`Theme`文件夹中的全局变量配置主题

1、	主题色调和对应的着色（比如背景颜色对应的内容颜色）

2、	导航栏样式，包含背景、标题字体和颜色、内容颜色（包含左右按钮图标和文字自动变色）

3、	主要按钮样式、状态栏样式、分割线样式

## 2. 基础框架
1、	基础视图控制器`GKBaseViewController`，app所有界面的基类，包含视图管理（顶部、内容、底部视图设置，导航栏自定义），api管理，与viewModel的交互管理，loading，信息提示

2、	基础列表视图控制器`GKScrollViewController`，app所有可滑动视图的基类，包含下拉刷新、加载更多，回到顶部按钮，键盘管理（可防止键盘弹出时挡住输入框）

3、	翻页视图控制器 `GKPageViewController`，app所有可左右滑动切换界面的基类

4、	网页视图控制器 `GKBaseWebViewController`，app所有显示网页的基类，包含网页显示（支持URL和html纯文本），加载进度条，app和web的交互管理

5、	弹窗扩展`GKViewController+CADialog`，可以让任何视图控制器以弹窗的样式显示，可配置弹窗大小，动画样式（支持自定义动画）

## 3. Api
1、	http任务 `GKBaseHttpTask`，二次封装`AFNetworking`，app所有http请求的基类，支持http请求的基础配置，文件上传，请求回调，自动显示loading，自动提示错误信息，返回的数据解析

2、	http任务队列 `GKHttpMultiTasks`，支持串行和并行

## 4. 交互
1、	提示信息弹窗 `GKAlertController`，app统一使用的信息提示弹窗，支持`alert`和act`ionSheet` 两种显示方式，可显示图标，标题，内容，按钮（支持多个），可设置全局的弹窗样式，也可以单独设置某个弹窗的样式

2、	loading，包含界面加载的loading和 触发某个事件时显示的loading（黑色半透明的），支持全局配置，黑色的loading支持文字样式，提示框大小设置

3、	信息提示框（黑色半透明的），支持全局配置，支持文字样式，图标，提示框大小设置

4、	空视图，默认可显示图标和文字，可设置自定义的视图。普通的界面需要手动设置是否显示，列表视图可自动显示（当列表没内容时）

## 5. 常用组件
1、	Banner，支持循环滚动，item自定义

2、	相册，支持多选，单选，图片裁剪

3、	二维码/条形码扫描，支持摄像头扫码和从相册获取图片识别

4、	倒计时，可防止app进入后台时，计时器被系统终止产生的问题

5、 路由组件`GKRouter`，支持URL参数和对象参数，支持界面跳转动画配置，支持拦截器和重定向

6、 嵌套滑动组件`NestedScroll`，支持垂直方向的两个`UIScrollView`嵌套，通过分类的方式实现，不需要继承任何类，只要配置`ParentScrollView`和`ChildScrollView`的属性即可，支持一个`Parent`和多个`Child`

7、 条形菜单组件`GKMenuBar`，支持高度自定义

8、 气泡弹窗组件`GKPopover`，支持高度自定义

9、 骨架层`Skeleton`，通过分类的方式实现，支持任意View

10、 侧滑删除组件`Swipe`，支持`UITableView`和`UICollectionView`

11、 交错布局组件`GKCollectionViewStaggerLayout`，支持大小不一`Item`错乱显示，支持`Header`置顶悬浮
12、 `GKKVOHelper ` `KVO`组件，支持`Block`的方式，支持同一个属性多个监听，支持同时监听多个属性，自动管理生命周期，让开发者不再需要管理`KVO`的移除，避免崩溃问题

## 6. 第三方组件
1、	http请求框架AFNetworking

2、	下拉刷新，加载更多 MJRefresh

3、	UI自动布局 Masonry

4、	图片加载及图片缓存管理 SDWebImage
