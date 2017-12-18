#import "TapImage.h"
#import "TapData.h"
#import "Tap.h"
#import "TapSettings.h"
#import "TapImageToolbar.h"
#import <UIColor_Utilities/UIColor+Expanded.h>
#import <MMMaterialDesignSpinner/MMMaterialDesignSpinner.h>

@implementation TapImage

@synthesize localUrl, imageStyle;


- (id)initWithDictionary:(NSDictionary *)info {
    if (self = [super initWithDictionary:info]) {
        imageStyle = TapImageStyleDefault;
    }
    return self;
}

-(void)loadUi {
    [super loadUi];
    imageView = nil;
    scrollView = [[TapScrollView alloc] init];
    scrollView.delegate = self;
    [self addSubview:scrollView];
    scrollView.maximumZoomScale = 4;
    container = [[UIView alloc] init];
    [scrollView addSubview:container];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animatedResizeImage) name:TapResizeFull object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animatedResizeImage) name:TapResizeSmall object:nil];
    self.localUrl = nil;
    if([info[@"url"] hasSuffix:@"pdf"]) {
        [TapData downloadPdf:[NSURL URLWithString:[NSString stringWithFormat:@"%@", info[@"url"]]] completionHandler:^(NSURL *fileURL) {
            self.localUrl = fileURL;
            [self performSelectorOnMainThread:@selector(showImage) withObject:nil waitUntilDone:NO];
        }];
    } else {
        [TapData downloadImage:[NSURL URLWithString:[NSString stringWithFormat:@"%@", info[@"url"]]] completionHandler:^(NSURL *fileURL) {
            self.localUrl = fileURL;
            [self performSelectorOnMainThread:@selector(showImage) withObject:nil waitUntilDone:NO];
        }];
    }
}

-(void)shareImage:(NSNotification*)notification {
    TapImageToolbar* toolbar = notification.object;
    if([toolbar isKindOfClass:[TapImageToolbar class]]) {
        [[Tap sharedInstance] share:@[ self.localUrl ] sender:toolbar.btnShare];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return container;
}

-(void)showImage {
    UIImage* image = nil;
    if([info[@"url"] hasSuffix:@"pdf"]) {
        CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)self.localUrl);
        CGPDFPageRef pdfPage = CGPDFDocumentGetPage(pdf, 1);
        CGRect pdfPageRect = CGPDFPageGetBoxRect(pdfPage, kCGPDFMediaBox);
        float scale = 1024 / pdfPageRect.size.height;
        pdfPageRect = CGRectMake(0, 0, pdfPageRect.size.width * scale, pdfPageRect.size.height * scale);
        UIGraphicsBeginImageContext(pdfPageRect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
        CGContextFillRect(context, pdfPageRect);
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, 0.0, pdfPageRect.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextScaleCTM(context, scale, scale);
        CGContextDrawPDFPage(context, pdfPage);
        CGContextRestoreGState(context);
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        CGPDFDocumentRelease(pdf);
    } else {
        image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:self.localUrl]];;
    }
    [imageView removeFromSuperview];
    imageView = [[UIImageView alloc] initWithImage:image];
    imageView.alpha = 0;
    [container addSubview:imageView];
    [self needsSetupUi];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:[[[TapSettings sharedInstance] number:TapSettingAnimationDuration] floatValue]];
    imageView.alpha = 1;
    [UIView commitAnimations];
    [[NSNotificationCenter defaultCenter] postNotificationName:TapImageReady object:self];
}

-(void)setupUi:(CGSize)size {
    [super setupUi:size];
    container.frame = CGRectMake(0,0,size.width,size.height);
    scrollView.frame = CGRectMake(0,0,size.width,size.height);
    scrollView.zoomScale = 1;
    [self resizeImage];
}

-(void)resizeImage {
    CGSize size = self.frame.size;
    if(imageView != nil) {
        float w = imageView.image.size.width;
        float h = imageView.image.size.height;
        @try {
            if(imageStyle == TapImageStyleDefault) {
                BOOL resizeFullOn = [[Tap sharedInstance] resizeFull];
                if((w/h < size.width/size.height && resizeFullOn) || (w/h > size.width/size.height && !resizeFullOn) ) {
                    imageView.frame = CGRectMake(0, (size.height-h*size.width/w)/2, size.width, h*size.width/w);
                } else {
                    imageView.frame = CGRectMake((size.width-w*size.height/h)/2, 0, w*size.height/h, size.height);
                }
            }
            if(imageStyle == TapImageStyleContainsLeft) {
                if(w/h > size.width/size.height) {
                    imageView.frame = CGRectMake(0, (size.height-h*size.width/w)/2, size.width, h*size.width/w);
                } else {
                    imageView.frame = CGRectMake(0, 0, w*size.height/h, size.height);
                }
            }
            if(imageStyle == TapImageStyleContains) {
                if(w/h > size.width/size.height) {
                    imageView.frame = CGRectMake(0, (size.height-h*size.width/w)/2, size.width, h*size.width/w);
                } else {
                    imageView.frame = CGRectMake((size.width-w*size.height/h)/2, 0, w*size.height/h, size.height);
                }
            }
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
    }
}

-(void)animatedResizeImage {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:[[[TapSettings sharedInstance] number:TapSettingAnimationDuration] floatValue]];
    [self resizeImage];
    scrollView.zoomScale = 1;
    [UIView commitAnimations];
}

@end
