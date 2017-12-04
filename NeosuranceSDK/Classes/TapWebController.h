#import "TapViewController.h"
#import "TapWeb.h"
#import "TapHeader.h"

@interface TapWebControllerView : TapView {
    __weak id <TapWebDelegate> webDelegate;
     float marginTop;
}

@property (nonatomic, weak) id <TapWebDelegate> webDelegate;
@property (nonatomic, copy) NSURL* url;
@property (nonatomic, copy) NSString* extension;
@property (nonatomic, readonly) TapWeb* web;
@property BOOL needsFileLocally;
@property float marginTop;

@end

@interface TapWebController : TapViewController {
    __weak id <TapWebDelegate> webDelegate;
   TapWebControllerView* controllerView;
  }

@property (nonatomic, weak) id <TapWebDelegate> webDelegate;
@property (nonatomic, readonly) TapWebControllerView* controllerView;
@property (nonatomic, copy) NSURL* url;
@property (nonatomic, copy) NSString* extension;
@property BOOL needsFileLocally;

@end

