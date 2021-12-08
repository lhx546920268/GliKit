
//店铺满优惠信息
export class FullPreferentialModel {

    constructor(obj){

        this.leastAmount = obj.limitAmount; //满足的金额条件
        this.preferentialAmount = obj.conformPrice; //优惠的金额
    }
}