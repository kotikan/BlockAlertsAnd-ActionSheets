//
//  BlockAlertView.h
//
//

#import <UIKit/UIKit.h>
@class BlockAlertViewStyle;

@interface BlockAlertView : NSObject {
@protected
    UIView *_view;
    NSMutableArray *_blocks;
    CGFloat _height;
}

+ (BlockAlertView *)alertWithTitle:(NSString *)title message:(NSString *)message;

- (id)initWithTitle:(NSString *)title message:(NSString *)message;
- (id)initWithTitle:(NSString *)title message:(NSString *)message style:(BlockAlertViewStyle *)style;

- (void)setDestructiveButtonWithTitle:(NSString *)title block:(void (^)())block;
- (void)setCancelButtonWithTitle:(NSString *)title block:(void (^)())block;
- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block;

- (void)show;
- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;

@property (nonatomic, retain) UIImage *backgroundImage;
@property (nonatomic, readonly) UIView *view;
@property (nonatomic, readwrite) BOOL vignetteBackground;
@property (nonatomic, retain) BlockAlertViewStyle *alertViewStyle;

@end
