# Welcome to LikeMindsFeed SDK!

LikeMindsFeed SDK offers an Instagram-like feed integration for your iOS applications, making it easy to add a social feed feature with minimal setup. The SDK is composed of two main components:

- **LikeMindsFeedUI:** Contains all the reusable UI components.
- **LikeMindsFeedCore:** Houses the actual implementation and business logic, and relies on `LikeMindsFeedUI` for UI components.

## Requirements

- iOS 13.0 or later

## Installation

### Cocoapods

You can easily integrate LikeMindsFeed into your project using Cocoapods. Add the following lines to your Podfile:

```ruby
platform :ios, '13.0'
use_frameworks!
target 'MyApp' do
    pod 'LikeMindsFeedCore'
end
```

> **Note:** Support for Swift Package Manager (SPM) is on the way!

## Integration

To integrate `LikeMindsFeedCore` into your app, you need to implement two required functions:

### 1. Setup LikeMindsFeed

```swift
func setupLikeMindsFeed(apiKey: String, analytics: LMFeedAnalyticsProtocol? = nil)
```

Use this function to set the API key for the SDK. It's recommended to call this as early as possible in your app's lifecycle.

**Example:** In your `AppDelegate.swift`:

```swift
func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
    LMFeedCore.shared.setupLikeMindsFeed(apiKey: "Your_API_Key", analytics: nil)
    return true
}
```

### 2. Initiate LikeMindsFeed

```swift
func initiateLikeMindsFeed(username: String, userId: String, completionHandler: ((Result<Void, LMFeedError>) -> Void)?)
```

This function initiates the SDK. Initiating the feed is crucial as you won't be able to access the feed without this step.

**Example:** In your `ViewController.swift`:

```swift
LMFeedCore.shared.initiateLikeMindsFeed(username: "username", userId: "userId") { [weak self] result in
    switch result {
    case .success(_):
        guard let viewController = LMUniversalFeedViewModel.createModule() else { return }
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = UINavigationController(rootViewController: viewController)
            window.makeKeyAndVisible()
        }

    case .failure(let error):
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self?.present(alert, animated: true)
    }
}
```

Ensure you replace `"Your_API_Key"`, `"username"`, and `"userId"` with actual values for your application. With these steps, you should be able to integrate LikeMindsFeed into your iOS app seamlessly.