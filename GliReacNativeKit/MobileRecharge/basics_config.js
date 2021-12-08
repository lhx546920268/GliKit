const config = require('./metro_config_unpacking');

const pathSep = require('path').sep;
const fs = require("fs");

const moduleMapDir = "moduleMapping";
const moduleIdsFile = "basicModuleIds.json";
const moduleIds = [];

function createModuleIdFactory() {
    //获取命令行执行的目录，__dirname是nodejs提供的变量
    const projectRootPath = __dirname;
    return (path) => {

        let moduleId = config.getModuleId(path);
        if (moduleIds.indexOf(moduleId) < 0) {
            moduleIds.push(moduleId);
            const dir = projectRootPath + pathSep + moduleMapDir;
            if (!fs.existsSync(dir)) {
                fs.mkdirSync(dir);
            }
            const moduleIdsPath = dir + pathSep + moduleIdsFile;
            fs.writeFileSync(moduleIdsPath, JSON.stringify(moduleIds));
        }

        return moduleId;
    };
}

module.exports = {

    serializer: {
        createModuleIdFactory: createModuleIdFactory,
        /* serializer options */
    }
};
