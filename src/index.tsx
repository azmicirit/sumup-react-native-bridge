import { NativeModules } from 'react-native';

const { SumupReactNativeBridge } = NativeModules;

type SuccessResultType = {
  success: boolean;
};

type CheckoutRequestType = {
  title: string;
  totalAmount: number;
  currencyCode: string;
  foreignID: string;
  skipScreenOptions?: boolean;
};

type SuccessCheckoutType = {
  success: boolean;
  transactionCode: string;
};

interface SumupReactNativeBridgeInterface {
  setupAPIKey(apiKey: string): Promise<SuccessResultType>; // FOR ONLY IOS
  login(accessToken: string): Promise<SuccessResultType>; // FOR ONLY IOS
  login(apiKey: string, accessToken: string): Promise<SuccessResultType>; // FOR ONLY ANDROID
  logout(): Promise<boolean>;
  isLoggedIn(): Promise<boolean>;
  preferences(): Promise<SuccessResultType>;
  checkout(request: CheckoutRequestType): Promise<SuccessCheckoutType>;
}

export default SumupReactNativeBridge as SumupReactNativeBridgeInterface;
