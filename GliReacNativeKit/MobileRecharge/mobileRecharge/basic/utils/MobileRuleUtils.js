
//手机号规则

const mobileRules = [
    {
        operator: "MPT",
        rules: [
            {pre: '0951', len: 9}, {pre: '0952', len: 9}, {pre: '0953', len: 9},
            {pre: '0954', len: 9}, {pre: '0955', len: 9}, {pre: '0956', len: 9},
            {pre: '0920', len: 9}, {pre: '0921', len: 9}, {pre: '0922', len: 9},
            {pre: '0923', len: 9}, {pre: '0924', len: 9}, {pre: '0941', len: 10},
            {pre: '0943', len: 10}, {pre: '0925', len: 11}, {pre: '0926', len: 11},
            {pre: '0940', len: 11}, {pre: '0941', len: 11}, {pre: '0942', len: 11},
            {pre: '0943', len: 11}, {pre: '0944', len: 11}, {pre: '0945', len: 11},
            {pre: '0989', len: 11},
        ]
    },
    {
        operator: "Ooredoo",
        rules: [
            {pre: '0995', len:11}, {pre: '0996', len:11}, {pre: '0997', len:11}
        ]
    },
    {
        operator: "Telenor",
        rules: [
            {pre: '0975', len:11}, {pre: '0976', len:11}, {pre: '0977', len:11},
            {pre: '0978', len:11}, {pre: '0979', len:11}
        ]
    },
    {
        operator: "Mytel",
        rules: [
            {pre: '0966', len:11}, {pre: '0967', len:11}, {pre: '0968', len:11},
            {pre: '0969', len:11}
        ]
    },
    {
        operator: "Mectel",
        rules: [
            {pre: "0930", len: 10}, {pre: "0931", len: 10}, {pre: "0932", len: 10},
            {pre: "0933", len: 10}, {pre: "0934", len: 11}, {pre: "0936", len: 10},
        ]
    },
    {
        operator: "CDMA",
        rules: [
            {pre: "0963", len: 9}, {pre: "0964", len: 9}, {pre: "0965", len: 9},
            {pre: "0968", len: 9}, {pre: "0983", len: 9}, {pre: "0985", len: 9},
            {pre: "0986", len: 9}, {pre: "0987", len: 9}, {pre: "0947", len: 10},
            {pre: "0949", len: 10}, {pre: "0973", len: 10}, {pre: "0991", len: 10},
        ]
    }
];

/**
 * 获取手机运营商名称
 */
export function operatorForMobile(mobile) {
    if(mobile && typeof mobile === 'string'){
        if(mobile.length >= 9 && mobile.length <= 11){
            for(let obj of mobileRules){
                for(let rule of obj.rules){
                    if(mobile.length === rule.len && mobile.indexOf(rule.pre) === 0){
                        return  obj.operator;
                    }
                }
            }
        }
    }
    return null;
}
