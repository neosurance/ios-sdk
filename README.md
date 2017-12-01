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
  [settings setObject:@"****-****-****-****" forKey:@"secret_key"];
  [settings setObject:@"****-****-****-****" forKey:@"community_code"];
  [[NSR sharedInstance] setupWithDictionary:settings];
  [[NSR sharedInstance] forceBackgroundWithSilenceAudio];
```
2. setUser

```objc
  NSRUser* user = [[NSRUser alloc] init];
  user.email = responseObject[@"email"];
  user.code = responseObject[@"code"];
  user.firstname = responseObject[@"firstname"];
  user.lastname = responseObject[@"lastname"];
  [[NSR sharedInstance] setUser:user];
```
3. -(BOOL)forwardNotification

4. -(void)showApp

5. -(void)customEvent:(NSDictionary*)

## Author

Tonino Mendicino, tonino@clickntap.com

## License

NeosuranceSDK is available under the MIT license. See the LICENSE file for more info.
