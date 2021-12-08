
//订单信息
import {formatMoney, formatTimeStamp} from "../../basic/utils/StringUtil";
import {getString} from "../../basic/utils/LauguageUtils";
import {printOrder} from "../../basic/utils/NativeMethodUtil";

//订单时间格式
const ORDER_TIME_FORMAT = "yyyy-MM-dd hh:mm:ss";

//订单类型
export const ORDER_TYPE_MOBILE = 1; //话费充值
export const ORDER_TYPE_TRAFFIC = 2; //流量充值

//订单状态
export const ORDER_STATUS_PENDING_PAY = 1; //待支付
export const ORDER_STATUS_PAYED = 2; //已支付
export const ORDER_STATUS_CANCELED = 3; //已取消
export const ORDER_STATUS_RECHARGE_SUCCESS = 4; //充值成功
export const ORDER_STATUS_RECHARGE_FAIL = 5; //充值失败
export const ORDER_STATUS_PAY_AMOUNT_ERROR = 6; //付金额不正确异常单
export const ORDER_STATUS_RECHARGE_MULTI_TIMES_ERROR = 7; //多次充值失败异常单
export const ORDER_STATUS_RECHARGE_SUCCESS_BY_ADMIN = 8; //手工充值成功


export class OrderModel {

    constructor(item){

        this.orderNo = item.orderNo; //订单号
        this.imageURL = item.lightLogUrl; //商品图片
        this.payAmount = item.payMoney; //支付金额
        this.rechargeAmount = item.rechargeMoney; //充值金额
        this.status = item.orderStatus; //订单状态
        this.statusString = this._getOrderStatusString(item.orderStatus); //订单状态文字
        this.operator = item.operatorName; //运营商
        this.mobile = item.mobile; //充值手机号
        this.createTime = formatTimeStamp(item.orderCreateTime, ORDER_TIME_FORMAT); // 订单创时间
        this.payTime = formatTimeStamp(item.payTime, ORDER_TIME_FORMAT); //订单支付时间
        this.rechargeTime = formatTimeStamp(item.thirdRechargeTime, ORDER_TIME_FORMAT); //第三方平台充值成功时间
        this.type = item.type; //订单类型
        this.goodsName = item.goodsName; //商品名称
        this.goodsDesc = item.goodsDesc; //商品描述
    }

    //获取订单状态文字
    _getOrderStatusString(status){
        switch (status) {
            case ORDER_STATUS_PENDING_PAY :
                return getString().orderStatusPendingPay;
            case ORDER_STATUS_PAYED :
                return getString().orderStatusPayed;
            case ORDER_STATUS_CANCELED :
                return getString().orderStatusCanceled;
            case ORDER_STATUS_RECHARGE_SUCCESS :
                return getString().orderStatusRechargeSuccess;
            case ORDER_STATUS_RECHARGE_FAIL :
                return getString().orderStatusRechargeFail;
            case ORDER_STATUS_PAY_AMOUNT_ERROR :
                return getString().orderStatusPayAmountError;
            case ORDER_STATUS_RECHARGE_MULTI_TIMES_ERROR :
                return getString().orderStatusRechargeMultiTimesError;
            case ORDER_STATUS_RECHARGE_SUCCESS_BY_ADMIN :
                return getString().orderStatusRechargeSuccessByAdmin;
        }
        return getString().orderStatusRechargeFail;
    }

    //获取订单详情列表
    getOrderDetailList(){
        let data = [
            {
                title: getString().orderStatus,
                content: this.statusString
            },
            {
                title: getString().orderAmount,
                content: formatMoney(this.payAmount)
            },
            {
                title: getString().mobileOperator,
                content: this.operator
            },
            {
                title: getString().rechargeAmount,
                content: formatMoney(this.rechargeAmount)
            },
            {
                title: getString().rechargeMobile,
                content: this.mobile
            },
            {
                title: getString().orderNumber,
                content: this.orderNo
            },
            {
                title: getString().createTime,
                content: this.createTime
            }
        ];

        if(this.payTime){
            data.push({
                title: getString().payTime,
                content: this.payTime
            });
        }
        if(this.rechargeTime){
            data.push({
                title: getString().rechargeTime,
                content: this.rechargeTime
            })
        }

        return data;
    }

    //获取打印数据
    getPrintData(){
        const type = this.type === ORDER_TYPE_TRAFFIC ? 2 : 1;
        let data = {};
        if(type === 1){
            data["orderSn"] = this.orderNo;
            data["createTime"] = this.createTime;
            data["operator"] = this.operator;
            data["mobile"] = this.mobile;
            data["value"] = this.rechargeAmount;
            data["buyCount"] = 1;
        }else {
            data["orderSn"] = this.orderNo;
            data["createTime"] = this.createTime;
            data["goodsName"] = this.goodsName;
            data["mobile"] = this.mobile;
            data["value"] = this.rechargeAmount;
            data["data"] = this.goodsName;
            data["desc"] = this.goodsDesc;
            data["buyCount"] = 1;
        }

        return {
            type,
            data
        }
    }

    //是否可以打印
    printEnable(){
        return true;
    }
}
