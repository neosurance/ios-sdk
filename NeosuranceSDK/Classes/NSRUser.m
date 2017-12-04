#import "NSRUser.h"

@implementation NSRUser

@synthesize code,email,firstname,lastname,mobile,fiscalCode,gender,birthday,address,zipCode,city,stateProvince,country,extra;

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end
