//
//  BlockActionSheet.h
//
//

#import <UIKit/UIKit.h>
@class BlockActionSheetStyle;

typedef enum {
    BlockActionSheetButtonTypeNormal,
    BlockActionSheetButtonTypeCancel,
    BlockActionSheetButtonTypeDestructive
} BlockActionSheetButtonType;

#define BlockActionSheet_ButtonProperty_Type @"Type"
#define BlockActionSheet_ButtonProperty_Title @"Title"
#define BlockActionSheet_ButtonProperty_ActionBlock @"ActionBlock"

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
@property (nonatomic, readonly) BOOL isVisible;
@property (nonatomic, retain) BlockActionSheetStyle *actionSheetStyle;

+ (id)sheetWithTitle:(NSString *)title;
+ (id)sheetWithTitle:(NSString *)title andStyle:(BlockActionSheetStyle *)style;

- (id)initWithTitle:(NSString *)title;
- (id)initWithTitle:(NSString *)title andStyle:(BlockActionSheetStyle *)style;

- (void)setCancelButtonWithTitle:(NSString *) title block:(ActionBlock) block;
- (void)setDestructiveButtonWithTitle:(NSString *) title block:(ActionBlock) block;
- (void)addButtonWithTitle:(NSString *) title block:(ActionBlock) block;

- (void)addButtonWithProperties:(NSDictionary *)buttonProperties atIndex:(NSInteger)index;

- (void)setCancelButtonWithTitle:(NSString *) title atIndex:(NSInteger)index block:(ActionBlock) block;
- (void)setDestructiveButtonWithTitle:(NSString *) title atIndex:(NSInteger)index block:(ActionBlock) block;
- (void)addButtonWithTitle:(NSString *) title atIndex:(NSInteger)index block:(ActionBlock) block;

- (void)addHeaderView:(UIView *)headerView withTransparentBackgroundRegionOffset:(int)offset;

- (void)showInView:(UIView *)view;
- (NSUInteger)buttonCount;
- (void)tearDownSheet;

/**
* Subclasses can override this method to provide a custom style of button
*/
- (UIButton *)buttonWithProperties:(NSDictionary *)buttonProperties tag:(NSUInteger)tag;

@end
