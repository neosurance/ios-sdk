#import "TapImageToolbar.h"
#import "TapGalleryPage.h"
#import "TapSettings.h"
#import "Tap.h"
#import <UIColor_Utilities/UIColor+Expanded.h>

@implementation TapGalleryPage

-(void)loadUi {
    [super loadUi];
    self.backgroundColor = [UIColor blackColor];
    self.alpha = 0;
    isOn = NO;
    isFront = NO;
    image = nil;
}

-(void)shareImage:(NSNotification*)notification {
    if(isFront && image != nil && image.localUrl != nil) {
        TapImageToolbar* toolbar = notification.object;
        if([toolbar isKindOfClass:[TapImageToolbar class]]) {
            [[Tap sharedInstance] share:@[ image.localUrl ] sender:toolbar.btnShare];
        }
    }
 }

-(void)setupUi:(CGSize)size {
    [super setupUi:size];
    if(image != nil) {
        image.frame = CGRectMake(0,0,size.width,size.height);
    }
}

-(void)pageOn:(BOOL)front {
    isFront = front;
    if(!isOn) {
        isOn = YES;
        image = [[TapImage alloc] initWithDictionary:info];
        [self addSubview:image];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageReady) name:TapImageReady object:image];
    } else {
        if(isFront && image.localUrl != nil) {
            [self imageReady];
        }
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:[[[TapSettings sharedInstance] number:TapSettingAnimationDuration] floatValue]];
    self.alpha = 1;
    [UIView commitAnimations];
    [self needsSetupUi];
}

-(void)imageReady {
    if(isFront) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TapImageReady object:self];
    }
}

-(void)pageOff {
    if(isOn) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [image removeFromSuperview];
        image = nil;
        isFront = NO;
        isOn = NO;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:[[[TapSettings sharedInstance] number:TapSettingAnimationDuration] floatValue]];
        self.alpha = 0;
        [UIView commitAnimations];
    }
}

@end
