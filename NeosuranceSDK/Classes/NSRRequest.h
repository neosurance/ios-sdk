#import <Foundation/Foundation.h>

@interface NSRRequest : NSObject {
    NSDictionary* event;
}

@property (nonatomic, copy) NSDictionary* event;

-(void)send;

@end
