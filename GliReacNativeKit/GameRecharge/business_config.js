const config = require('./metro_config_unpacking');
const pathSep = require('path').sep;
const moduleIds = require('./moduleMapping/basicModuleIds.json');

function createModuleIdFactory() {

  return (path) => {
     return config.getModuleId(path);
  };
}

function processModuleFilter(module) {

  //过滤掉path为__prelude__的一些模块（基础包内已有）
  const path = module.path;

   if (path.indexOf("__prelude__") >= 0 ||
    path.indexOf("/node_modules/react-native/Libraries/polyfills") >= 0 ||
    path.indexOf("source-map") >= 0 ||
    path.indexOf("/node_modules/metro/src/lib/polyfills/") >= 0) {
    return false;
  }
 // 过滤掉node_modules内的模块（基础包内已有）
  if (path.indexOf(pathSep + 'node_modules' + pathSep) > 0) {
    /*
      但输出类型为js/script/virtual的模块不能过滤，一般此类型的文件为核心文件，
      如InitializeCore.js。每次加载bundle文件时都需要用到。
    */
    if ('js' + pathSep + 'script' + pathSep + 'virtual' === module['output'][0]['type']) {
      return true;
    }

    const moduleId = config.getModuleId(path);

  if(moduleIds.indexOf(moduleId) >= 0){
    return false;
  }else{
 // console.log(moduleId, path)
  }
  }
//  console.log(module.path)
  //其他就是应用代码
  return true;
}

module.exports = {

  serializer: {
    createModuleIdFactory: createModuleIdFactory,
    processModuleFilter: processModuleFilter
    /* serializer options */
  }
};
