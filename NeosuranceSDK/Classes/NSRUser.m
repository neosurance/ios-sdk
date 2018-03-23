#import "NSRUser.h"

@implementation NSRUser

@synthesize code,email,firstname,lastname,mobile,fiscalCode,gender,birthday,address,zipCode,city,stateProvince,country,extra;

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (NSDictionary*)dictionary {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    if(code != nil) {
        [dict setObject:code forKey:@"code"];
    }
    if(email != nil) {
        [dict setObject:email forKey:@"email"];
    }
    if(firstname != nil) {
        [dict setObject:firstname forKey:@"firstname"];
    }
    if(lastname != nil) {
        [dict setObject:lastname forKey:@"lastname"];
    }
    if(mobile != nil) {
        [dict setObject:mobile forKey:@"mobile"];
    }
    if(fiscalCode != nil) {
        [dict setObject:fiscalCode forKey:@"fiscalCode"];
    }
    if(gender != nil) {
        [dict setObject:gender forKey:@"gender"];
    }
    if(birthday != nil) {
        [dict setObject:birthday forKey:@"birthday"];
    }
    if(address != nil) {
        [dict setObject:address forKey:@"address"];
    }
    if(zipCode != nil) {
        [dict setObject:zipCode forKey:@"zipCode"];
    }
    if(city != nil) {
        [dict setObject:city forKey:@"city"];
    }
    if(stateProvince != nil) {
        [dict setObject:stateProvince forKey:@"stateProvince"];
    }
    if(country != nil) {
        [dict setObject:country forKey:@"country"];
    }
    if(extra != nil) {
        [dict setObject:extra forKey:@"extra"];
    }
    return dict;
}

- (NSString*)json {
    NSError* error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[self dictionary] options:0 error:&error];
    NSString* jsonAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
     return jsonAsString;
}

@end
