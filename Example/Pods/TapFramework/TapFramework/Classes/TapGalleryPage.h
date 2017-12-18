#import "TapView.h"
#import "TapImage.h"

@interface TapGalleryPage : TapView {
    BOOL isOn;
    BOOL isFront;
    TapImage* image;
}

-(void)pageOn:(BOOL)front;
-(void)pageOff;

@end
