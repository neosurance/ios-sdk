# NeosuranceSDK

- Collects info from device sensors and from the hosting app
- Exchanges info with the AI engines
- Sends the push notification
- Displays a landing page
- Displays the list of the purchased policies

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements


```plist
    <key>NSAppTransportSecurity</key>
    <dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
    </dict>
    <key>NSLocationAlwaysUsageDescription</key>
    <string>Always...</string>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>When in use...</string>
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>Always and when in use...</string>
    <key>NSMotionUsageDescription</key>
    <string>Motion...</string>
    <key>UIBackgroundModes</key>
    <array>
    <string>audio</string>
    <string>fetch</string>
    <string>location</string>
    <string>remote-notification</string>
    </array>
```


## Installation

NeosuranceSDK is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```xcode
pod 'NeosuranceSDK'
```


1. Init

```objc
    NSMutableDictionary* settings = [[NSMutableDictionary alloc] init];
    [settings setObject:@"https://sandbox.neosurancecloud.net/sdk/api/v1.0/" forKey:@"base_url"];
    [settings setObject:@"xxxx" forKey:@"code"];
    [settings setObject:@"xxxx" forKey:@"secret_key"];
    [[NeosuranceSDK sharedInstance] setupWithDictionary:settings];
    [[NeosuranceSDK sharedInstance] stayInBackground];
```
2. setUser

```objc
    NSRUser* user = [[NSRUser alloc] init];
    user.email = @"jhon.doe@acme.com";
    user.code = @"jhon.doe@acme.com";
    user.firstname = @"Jhon";
    user.lastname = @"Doe";
    [[NeosuranceSDK sharedInstance] registerUser:user];
```
3. -(BOOL)forwardNotification

```objc
    - (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler  {
        if(![[NeosuranceSDK sharedInstance] forwardNotification:response withCompletionHandler:(void(^)(void))completionHandler]) {
            //TODO: handle your notification
        }
        completionHandler();
    }
```
4. -(void)showApp

```objc
    [[NeosuranceSDK sharedInstance] showApp];
```

5. -(void)customEvent:(NSDictionary*)

 ```objc          
    NSMutableDictionary* payload = [[NSMutableDictionary alloc] init];
    [payload setObject:@"custom" forKey:@"type"];
    [[NeosuranceSDK sharedInstance] sendEvent:@"custom" payload:payload];
```

6. -(void)setSecurityDelegate:(NSRSecurityDelegate*)

 ```objc          
   @protocol NSRSecurityDelegate <NSObject>
   -(void)secureRequest:(NSString* _Nullable)endpoint payload:(NSDictionary* _Nullable)payload headers:(NSDictionary* _Nullable)headers completionHandler:(void (^)(NSDictionary* responseObject, NSError *error))completionHandler;
   @end

   [[NeosuranceSDK sharedInstance] setSecurityDelegate:[[MySecurityDelegate alloc] init]];
```

## Author

info@neosurance.eu

## License

NeosuranceSDK is available under the MIT license. See the LICENSE file for more info.
