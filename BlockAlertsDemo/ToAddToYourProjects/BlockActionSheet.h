//
//  BlockActionSheet.h
//
//

#import <UIKit/UIKit.h>

typedef enum {
    BlockActionSheetButtonTypeNormal,
    BlockActionSheetButtonTypeCancel,
    BlockActionSheetButtonTypeDestructive
} BlockActionSheetButtonType;

typedef void (^ActionBlock)();

/**
 * A simple block-enabled API wrapper on top of UIActionSheet.
 */
@interface BlockActionSheet : NSObject {
@private
    UIView *_view;
    NSMutableArray *_buttons;
    CGFloat _height;
}

@property (nonatomic, readonly) UIView *view;
@property (nonatomic, readwrite) BOOL vignetteBackground;

+ (id)sheetWithTitle:(NSString *)title;

- (id)initWithTitle:(NSString *)title;

- (void)setCancelButtonWithTitle:(NSString *) title block:(ActionBlock) block;
- (void)setDestructiveButtonWithTitle:(NSString *) title block:(ActionBlock) block;
- (void)addButtonWithTitle:(NSString *) title block:(ActionBlock) block;

- (void)setCancelButtonWithTitle:(NSString *) title atIndex:(NSInteger)index block:(ActionBlock) block;
- (void)setDestructiveButtonWithTitle:(NSString *) title atIndex:(NSInteger)index block:(ActionBlock) block;
- (void)addButtonWithTitle:(NSString *) title atIndex:(NSInteger)index block:(ActionBlock) block;

- (void)showInView:(UIView *)view;

- (NSUInteger)buttonCount;

@end
