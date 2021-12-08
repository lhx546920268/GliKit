const pathSep = require('path').sep;
const md5 = require('js-md5');
const fs = require("fs");

//是否加密
const isEncrypt = true;
const moduleMapDir = "moduleMapping";
const moduleMapFile = "moduleMapping.json";
const moduleMap = {};

function getModuleId(path) {
  //获取命令行执行的目录，__dirname是nodejs提供的变量
  const projectRootPath = __dirname;
  //    console.log('');
//    console.log(path);
    let name = '';

    // 如果需要去除react-native/Libraries路径去除可以放开下面代码
    // if (path.indexOf('node_modules' + pathSep + 'react-native' + pathSep + 'Libraries' + pathSep) > 0) {
    //   //这里是react native 自带的库，因其一般不会改变路径，所以可直接截取最后的文件名称
    //   name = path.substr(path.lastIndexOf(pathSep) + 1);
    //   console.log('react libraries:' + name);
    // }
    if (path.indexOf(projectRootPath) === 0) {
      /*
        这里是react native 自带库以外的其他库，因是绝对路径，带有设备信息，
        为了避免重复名称,可以保留node_modules直至结尾
        如/{User}/{username}/{userdir}/node_modules/xxx.js 需要将设备信息截掉
      */
      name = path.substr(projectRootPath.length + 1);
    //  console.log('root libraries:' + name);
    }
    //js png字符串 文件的后缀名可以去掉
    // name = name.replace('.js', '');
    // name = name.replace('.png', '');
//    console.log('replace name:' + name);
    //最后在将斜杠替换为空串或下划线
    let regExp = pathSep === '\\' ? new RegExp('\\\\', "gm") : new RegExp(pathSep, "gm");
    name = name.replace(regExp, '_');
    // console.log('regExp name:' + name);
    //名称加密
    if (isEncrypt) {
      name = md5(name);
     // console.log('encryptName:' + name);
    }


  //   let moduleId = moduleMap[name];
  // if (!moduleId) {
  //     let keys = Object.keys(moduleMap);
  //   moduleId = keys.length;
  //   moduleMap[name] = moduleId;
  //
  //   const dir = projectRootPath + pathSep + moduleMapDir;
  //   if (!fs.existsSync(dir)) {
  //     fs.mkdirSync(dir);
  //   }
  //   const moduleMapPath = dir + pathSep + moduleMapFile;
  //   fs.writeFileSync(moduleMapPath, JSON.stringify(moduleMap));
  // }
  //
  //   return moduleId;
    return name;
}

module.exports = {
  getModuleId,
};

