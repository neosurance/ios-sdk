#import "TapView.h"


typedef NS_ENUM(NSInteger, TapButtonIcon) {
    TapButtonIconPlay = 0,
    TapButtonIconStop,
    TapButtonIconPause,
    TapButtonIconRecord,
    TapButtonIconFastForward,
    TapButtonIconFastBackward,
    TapButtonIconCancel,
    TapButtonIconLeftOpen,
    TapButtonIconRightOpen,
    TapButtonIconNetwork,
    TapButtonIconShare,
    TapButtonIconLeft,
    TapButtonIconRight,
    TapButtonIconCw,
	TapButtonIconDocText,
	TapButtonIconNewspaper,
	TapButtonIconVideo,
	TapButtonIconArchive,
    TapButtonIconTrash,
};

@interface TapButton : TapView {
    UILabel* icon;
    UIButton* btn;
}

- (_Nonnull id)initWithIcon:(TapButtonIcon)buttonIcon;
- (_Nonnull id)initWithIcon:(TapButtonIcon)buttonIcon iconScale:(float)scale;
- (void)addTarget:(nullable id)target action:(nullable SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end
