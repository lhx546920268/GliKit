import {StyleSheet} from "react-native";

export const CommonStyles = StyleSheet.create({
    shadow:{
        shadowColor: '#00000066',
        shadowOffset: {height: 1, width: 1},
        shadowRadius: 5,
        shadowOpacity: 0.2,
        elevation: 2,
    },
    navigationBar:{
        height:44,
        flexDirection: "row",
        alignItems: "center",
        backgroundColor:'#2C2D31'
    }
});


