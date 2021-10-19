import React, { useState, useEffect } from 'react';
import {
  View,
  SafeAreaView,
  NativeModules,
  Alert,
  Text,
  TouchableHighlight,
  Platform,
} from 'react-native';
import axios from 'axios';
import SumupSDK from 'sumup-react-native-bridge';

const App = () => {
  const [accessToken, setAccessToken] = useState(null);

  const apiKey = '28879eef-40f2-49da-8eac-dd99b118f1d0';

  useEffect(() => {
    (async () => {
      if (Platform.OS === 'ios') {
        await SumupSDK.setupAPIKey(apiKey);
      }
    })();
  }, []);

  const uuidv4 = () => {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(
      /[xy]/g,
      function (c) {
        const r = (Math.random() * 16) | 0,
          v = c == 'x' ? r : (r & 0x3) | 0x8;
        return v.toString(16);
      }
    );
  };

  const isLoggedInBtnClicked = async () => {
    const result = await SumupSDK.isLoggedIn();
    Alert.alert('Is Logged In?', result.toString());
  };

  const logoutBtnClicked = async () => {
    await SumupSDK.logout();
    setAccessToken(null);
  };

  const loginBtnClicked = async () => {
    try {
      let result = null;
      if (Platform.OS === 'ios') {
        result = await SumupSDK.login(accessToken);
      } else {
        result = await SumupSDK.login(apiKey, accessToken);
      }
      console.log(result);
    } catch (error) {
      Alert.alert(error.toString());
    }
  };

  const getAccessTokenBtnClicked = async () => {
    const bearer = '<TOKEN>';
    const result = await axios.post(
      'http://192.168.1.90:5000/v1/api/terminals/sumup/token',
      { venue_id: '5fc923fcc1d7c4a1e7a90663' },
      { headers: { Authorization: `Bearer ${bearer}` } }
    );

    if (result && result.data) {
      setAccessToken(result.data.access_token);
    }
  };

  const refreshTokenBtnClicked = async () => {
    const bearer = '<TOKEN>';
    const result = await axios.post(
      'http://192.168.1.90:5000/v1/api/terminals/sumup/token/refresh',
      { venue_id: '5fc923fcc1d7c4a1e7a90663' },
      { headers: { Authorization: `Bearer ${bearer}` } }
    );

    if (result && result.data) {
      setAccessToken(result.data.access_token);
    }
  };

  const preferences = async () => {
    try {
      const result = await SumupSDK.preferences();
      console.log(result);
    } catch (error) {
      Alert.alert('Error', error.toString());
    }
  };

  const checkout = async () => {
    try {
      const payment = await SumupSDK.payment({
        title: 'Test Payment',
        totalAmount: 1.75,
        currencyCode: 'GBP',
        skipScreenOptions: false,
        foreignID: uuidv4(),
      });
      console.log(payment);
    } catch (error) {
      Alert.alert('Error', error.toString());
    }
  };

  return (
    <SafeAreaView>
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
        <Text>{accessToken ? accessToken : '-'}</Text>
        <TouchableHighlight onPress={isLoggedInBtnClicked}>
          <View style={{ marginTop: 15, marginBottom: 15 }}>
            <Text>Is Logged In?</Text>
          </View>
        </TouchableHighlight>
        <TouchableHighlight onPress={loginBtnClicked}>
          <View style={{ marginTop: 15, marginBottom: 15 }}>
            <Text>Login</Text>
          </View>
        </TouchableHighlight>
        <TouchableHighlight onPress={logoutBtnClicked}>
          <View style={{ marginTop: 15, marginBottom: 15 }}>
            <Text>Logout</Text>
          </View>
        </TouchableHighlight>
        <TouchableHighlight onPress={getAccessTokenBtnClicked}>
          <View style={{ marginTop: 15, marginBottom: 15 }}>
            <Text>Get Access Token</Text>
          </View>
        </TouchableHighlight>
        <TouchableHighlight onPress={refreshTokenBtnClicked}>
          <View style={{ marginTop: 15, marginBottom: 15 }}>
            <Text>Refresh Token</Text>
          </View>
        </TouchableHighlight>
        <TouchableHighlight onPress={preferences}>
          <View style={{ marginTop: 15, marginBottom: 15 }}>
            <Text>Preferences</Text>
          </View>
        </TouchableHighlight>
        <TouchableHighlight onPress={checkout}>
          <View style={{ marginTop: 15, marginBottom: 15 }}>
            <Text>Checkout</Text>
          </View>
        </TouchableHighlight>
      </View>
    </SafeAreaView>
  );
};

export default App;
