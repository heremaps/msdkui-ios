# HERE Mobile SDK UI Kit - iOS Demo Application

Along with the Developer's Guide, accompanying example apps and code snippets, we also provide a more complex demo app showing a complete and fully functional flow.

## Environment
The demo app has been developed with Xcode 9.4 and Swift 4.1. Note that the minimum deployment target is iOS 10.0.

## How to Build the Demo
In order to build the demo app with Xcode, you need to integrate the HERE Mobile SDK (Premium), version 3.8 or newer. Additionally you need to integrate the HERE Mobile SDK UI Kit library.

### Integrate the HERE Mobile SDK
At the moment, there are two options available to add the HERE iOS SDK to your Xcode project, either by using CocoaPods - or by manually importing it. For the first option, we provide a CocoaPods podspec file in the root folder of the demo app. CocoaPods is a dependency manager for external libraries.

If you are new to CocoaPods or need to install it via Terminal, please follow the steps as described on [guides.cocoapods.org](https://guides.cocoapods.org/using/getting-started.html). If you have CocaPods installed, open the Terminal and execute the following:

1. In the demo root folder (where the Podfile is located) run:
pod install --repo-update

2. Open *.xcworkspace (NOT *.xcodeproj) to launch Xcode.

Alternatively, you can download the HERE iOS SDK package from http://developer.here.com and manually import the HERE Mobile SDK. Please read this [tutorial](https://developer.here.com/documentation/ios-premium/topics/app-create-simple.html) for more information.

### Authenthicate the HERE Mobile SDK
The HERE Mobile SDK needs credentials to verify your account and license key. Please open the `MSDKUI_Demo/NMACredentials.swift` file. The file should look like shown below. Please fill in your credentials. Plus, you need to set the `Bundle Identifier` appropriately.

```swift
import Foundation

enum NMACredentials {
    static let appID = "YOUR_APP_ID"
    static let appCode = "YOUR_APP_CODE"
    static let licenseKey = "YOUR_LICENSE_KEY"
}
```

### Integrate the HERE Mobile SDK UI Kit
If you are building the demo app from within the downloaded package, you do not need to do anything, as the `MSDKUI.framework` is already included. If you move the project elsewhere, or if you want to create your own project, please make sure to copy the `MSDKUI.framework` file to your project folder. In the _General_ settings of the _App_ target add `MSDKUI.framework` to the _Embedded Binaries_ section ("Add other..." -> "Create folder references").

## Run the demo
Choose the `MSDKUI_Demo` (Swift) target and build the project.

For more informtion please refer to the Developer's Guide.
