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
    maven { url 'https://maven.sumup.com/releases' 
  }
}
```

## Usage

Please check out sample project.

```
  setupAPIKey(apiKey: string): Promise<SuccessResultType>; // FOR ONLY IOS
  login(accessToken: string): Promise<SuccessResultType>; // FOR ONLY IOS
  login(apiKey: string, accessToken: string): Promise<SuccessResultType>; // FOR ONLY ANDROID
  logout(): Promise<boolean>;
  isLoggedIn(): Promise<boolean>;
  preferences(): Promise<SuccessResultType>;
  checkout(request: CheckoutRequestType): Promise<SuccessCheckoutType>;
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT
