import zawgyi from './strings/zawgyi'
import mm3 from './strings/mm3'
import en from './strings/en'
import zh_Hans from './strings/zh_Hans'
import {getLanguage, LANG_CHINESE, LANG_ENGLISH, LANG_MM3, LANG_ZAWGYI} from "../config/AppConfig";

export const getStringByKey=(key)=>{
    return getString()[key]
};

export const getString=()=>{
    switch (getLanguage()) {
        case LANG_MM3:return mm3;
        case LANG_ZAWGYI:return zawgyi;
        case LANG_CHINESE: return zh_Hans;
        case LANG_ENGLISH: return en;
    }
    return {};
};