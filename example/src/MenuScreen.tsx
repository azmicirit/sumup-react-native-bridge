import React from 'react';
import { Button, Text, TouchableHighlight, View } from 'react-native';

const MenuScreen = ({ navigation }) => {
  return (
    <View
      style={{
        width: '100%',
        height: '100%',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        backgroundColor: '#fff',
      }}
    >
      <TouchableHighlight onPress={() => {navigation.navigate('Test')}}>
        <View style={{ marginTop: 15, marginBottom: 15 }}>
          <Text>START</Text>
        </View>
      </TouchableHighlight>
    </View>
  );
};

export default MenuScreen;
