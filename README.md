# NeosuranceSDK

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

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
    [[NeosuranceSDK sharedInstance] setupWithDictionary:settings navigationController:navigationController];
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

## Author

Giovanni Tigli, giovanni.tigli@neosurance.eu
Tonino Mendicino, tonino.mendicino@clickntap.com

## License

NeosuranceSDK is available under the MIT license. See the LICENSE file for more info.
