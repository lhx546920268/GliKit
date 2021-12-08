import accounting from 'accounting';

//判断字符串是否为空
export function isEmpty(str) {
  if (str === null || typeof str !== 'string' || str.length === 0) {
    return true;
  }
  return str.replace(/\s*/g, '').length === 0;
}

//格式化字符串 把 Difference {0} discount {1} 中 {0},{1} 替换成指定字符串
export function formatString(string, args) {
  if (!isEmpty(string)) {
    let result = string;
    if (args !== null && args.length > 0) {
      for (let i = 0; i < args.length; i++) {
        if (args[i] !== undefined) {
          let reg = new RegExp('({)' + i + '(})', 'g');
          result = result.replace(reg, args[i]);
        }
      }
    }

    return result;
  }
  return '';
}

/**
 * 格式化钱，增加千分位,保留两位小数
 * @param money
 */
export function formatMoney(money) {
  let newMoney = String(money);
  return accounting.formatMoney(newMoney, 'Ks ', 0, ',', '.');
}


Date.prototype.format = function(fmt){
  let o = {
    "M+" : this.getMonth()+1,                 //月份
    "d+" : this.getDate(),                    //日
    "h+" : this.getHours(),                   //小时
    "m+" : this.getMinutes(),                 //分
    "s+" : this.getSeconds(),                 //秒
    "q+" : Math.floor((this.getMonth()+3)/3), //季度
    "S"  : this.getMilliseconds()             //毫秒
  };

  if(/(y+)/.test(fmt)){
    fmt = fmt.replace(RegExp.$1, (this.getFullYear()+"").substr(4 - RegExp.$1.length));
  }

  for(let k in o){
    if(new RegExp("("+ k +")").test(fmt)){
      fmt = fmt.replace(
          RegExp.$1, (RegExp.$1.length === 1) ? (o[k]) : (("00"+ o[k]).substr((""+ o[k]).length)));
    }
  }

  return fmt;
};

/**
 * 格式化时间戳
 * @param timeStamp 时间戳
 * @param format 格式
 * @returns 格式化后的时间
 */
export function formatTimeStamp(timeStamp, format) {
  if(!timeStamp)
    return null;
  return new Date(timeStamp).format(format);
}
