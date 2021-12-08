
export const getParams=(props = {},key)=>{
    let {navigation} = props;
    if(navigation){
        if(navigation.state){
            if(navigation.state.params){
                if(key){
                    if(navigation.state.params[key] !== null || navigation.state.params[key] !== undefined){
                        return navigation.state.params[key];
                    }
                }else{
                    return navigation.state.params;
                }
            }
        }
    }
    return null;
};