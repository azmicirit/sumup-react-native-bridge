# sumup-react-native-bridge

SumUp SDK Bridge

## Installation

```sh
npm install sumup-react-native-bridge
```

Add maven repository into build.gradle *(./android/bundle.gradle)*

```
allprojects {
  ...
  repositories {
    maven { url 'https://maven.sumup.com/releases' }
}
```

## Usage

Please check out example project.

```
  setupAPIKey(apiKey: string): Promise<boolean>; // FOR ONLY IOS
  login(accessToken: string): Promise<LoginResponseType>; // FOR ONLY IOS
  login(apiKey: string, accessToken: string): Promise<LoginResponseType>; // FOR ONLY ANDROID
  loginWithoutToken(String affiliateKey, Promise promise); // FOR ONLY ANDROID
  logout(): Promise<boolean>;
  isLoggedIn(): Promise<boolean>;
  preferences(): Promise<ResponseType>;
  payment(request: CheckoutRequestType): Promise<ResponseType>;
```

##### External Error Codes: #####

**404**
: RootView cannot be null (for only iOS)

**500**
: Fatal Error

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
