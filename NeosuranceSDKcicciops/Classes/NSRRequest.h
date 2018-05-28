#import <Foundation/Foundation.h>
#import <TapFramework/TapData.h>

@interface NSRRequest : NSObject {
    NSDictionary* event;
}

@property (nonatomic, copy) NSDictionary* event;

-(void)send;

@end

