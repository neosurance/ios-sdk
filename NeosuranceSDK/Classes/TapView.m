#import "TapView.h"

@implementation TapView

@synthesize info;

- (id)init {
    if (self = [super init]) {
        previousSize = CGSizeZero;
        self.frame = CGRectZero;
        [self performSelector:@selector(loadUi) withObject:nil afterDelay:0];
        [self performSelector:@selector(needsSetupUi) withObject:nil afterDelay:0];
    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self unloadUi];
}

- (void)needsSetupUi {
    previousSize = CGSizeZero;
    [self layoutSubviews];
}

- (void)layoutSubviews {
    if (!CGSizeEqualToSize(previousSize, self.frame.size)) {
        previousSize = self.frame.size;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TapViewSizeChanged" object:self];
        [self setupUi:self.frame.size];
    }
}

- (void)setupUiAnimated {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    [self setupUi:self.frame.size];
    [UIView commitAnimations];
}

-(void)loadUi {
    [self performSelector:@selector(didLoadUi) withObject:nil afterDelay:0];
}

-(void)setupUi:(CGSize)size {
    [self performSelector:@selector(didSetupUi) withObject:nil afterDelay:0];
}

-(void)unloadUi {
}

- (void)didLoadUi {
}

- (void)didSetupUi {
}

@end
