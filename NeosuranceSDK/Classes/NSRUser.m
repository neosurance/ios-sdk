#import "NSRUser.h"

@implementation NSRUser

@synthesize code,email,firstname,lastname,mobile,fiscalCode,gender,birthday,address,zipCode,city,stateProvince,country,extra;

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (BOOL)valid {
    return code != nil;
}

- (void)load {
    NSDictionary* nsruser = [[NSUserDefaults standardUserDefaults] objectForKey:@"nsruser"];
    if(nsruser != nil) {
        [self fill:nsruser];
    }
}

- (void)save {
    [[NSUserDefaults standardUserDefaults] setObject:[self dictionary] forKey:@"nsruser"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(void)clear {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"nsruser"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)fill:(NSDictionary*)dict {
    if([dict objectForKey:@"code"] != nil) {
        code = [dict objectForKey:@"code"];
    }
    if([dict objectForKey:@"email"] != nil) {
        email = [dict objectForKey:@"email"];
    }
    if([dict objectForKey:@"firstname"] != nil) {
        firstname = [dict objectForKey:@"firstname"];
    }
    if([dict objectForKey:@"lastname"] != nil) {
        lastname = [dict objectForKey:@"lastname"];
    }
    if([dict objectForKey:@"mobile"] != nil) {
        mobile = [dict objectForKey:@"mobile"];
    }
    if([dict objectForKey:@"fiscalCode"] != nil) {
        fiscalCode = [dict objectForKey:@"fiscalCode"];
    }
    if([dict objectForKey:@"gender"] != nil) {
        gender = [dict objectForKey:@"gender"];
    }
    if([dict objectForKey:@"birthday"] != nil) {
        birthday = [dict objectForKey:@"birthday"];
    }
    if([dict objectForKey:@"address"] != nil) {
        address = [dict objectForKey:@"address"];
    }
    if([dict objectForKey:@"zipCode"] != nil) {
        zipCode = [dict objectForKey:@"zipCode"];
    }
    if([dict objectForKey:@"city"] != nil) {
        city = [dict objectForKey:@"city"];
    }
    if([dict objectForKey:@"stateProvince"] != nil) {
        stateProvince = [dict objectForKey:@"stateProvince"];
    }
    if([dict objectForKey:@"country"] != nil) {
        country = [dict objectForKey:@"country"];
    }
    if([dict objectForKey:@"extra"] != nil) {
        extra = [dict objectForKey:@"extra"];
    }
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
