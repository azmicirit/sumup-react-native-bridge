import { NativeModules } from 'react-native';

const { SumupReactNativeBridge } = NativeModules;

type LoginResponseType = {
  success: boolean;
  code?: number;
  message?: string;
  invalidToken?: boolean;
};

type CheckoutRequestType = {
  title: string;
  totalAmount: number;
  currencyCode: string;
  foreignID: string;
  skipScreenOptions?: boolean;
};

type ResponseType = {
  success: boolean;
  code?: number;
  message?: string;
  transactionCode?: string;
  transactionInfo?: string;
  invalidToken?: boolean;
  notLoggedIn?: boolean;
};

interface SumupReactNativeBridgeInterface {
  setupAPIKey(apiKey: string): Promise<boolean>; // FOR ONLY IOS
  login(accessToken: string): Promise<LoginResponseType>; // FOR ONLY IOS
  login(apiKey: string, accessToken: string): Promise<LoginResponseType>; // FOR ONLY ANDROID
  logout(): Promise<boolean>;
  isLoggedIn(): Promise<boolean>;
  preferences(): Promise<ResponseType>;
  payment(request: CheckoutRequestType): Promise<ResponseType>;
}

export default SumupReactNativeBridge as SumupReactNativeBridgeInterface;
