//
//  BlockActionSheet.m
//
//

#import "BlockActionSheet.h"
#import "BlockBackground.h"
#import "BlockUI.h"

@interface BlockActionSheet ()

@property (nonatomic, readwrite) BOOL isVisible;

@end

@implementation BlockActionSheet {
    BOOL isClosing;
}

@synthesize view = _view;
@synthesize vignetteBackground = _vignetteBackground;

static UIImage *background = nil;
static UIFont *titleFont = nil;
static UIFont *buttonFont = nil;

#pragma mark - init

+ (void)initialize
{
    if (self == [BlockActionSheet class])
    {
        background = [UIImage imageNamed:kActionSheetBackground];
        background = [[background stretchableImageWithLeftCapWidth:0 topCapHeight:kActionSheetBackgroundCapHeight] retain];
        titleFont = [kActionSheetTitleFont retain];
        buttonFont = [kActionSheetButtonFont retain];
    }
}

+ (id)sheetWithTitle:(NSString *)title
{
    return [[[BlockActionSheet alloc] initWithTitle:title] autorelease];
}

- (id)initWithTitle:(NSString *)title 
{
    if ((self = [super init]))
    {
        UIWindow *parentView = [BlockBackground sharedInstance];
        CGRect frame = parentView.bounds;
        
        _view = [[UIView alloc] initWithFrame:frame];
        _buttons = [[NSMutableArray alloc] init];
        _height = kActionSheetTopMargin;

        if (title)
        {
            CGSize size = [title sizeWithFont:titleFont
                            constrainedToSize:CGSizeMake(frame.size.width-kActionSheetBorder*2, 1000)
                                lineBreakMode:UILineBreakModeWordWrap];
            
            UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(kActionSheetBorder, _height, frame.size.width-kActionSheetBorder*2, size.height)];
            labelView.font = titleFont;
            labelView.numberOfLines = 0;
            labelView.lineBreakMode = UILineBreakModeWordWrap;
            labelView.textColor = kActionSheetTitleTextColor;
            labelView.backgroundColor = [UIColor clearColor];
            labelView.textAlignment = UITextAlignmentCenter;
            labelView.shadowColor = kActionSheetTitleShadowColor;
            labelView.shadowOffset = kActionSheetTitleShadowOffset;
            labelView.text = title;
            [_view addSubview:labelView];
            [labelView release];
            
            _height += size.height + 5;
        }
        _vignetteBackground = NO;
    }
    
    return self;
}

- (void) dealloc 
{
    [_view release];
    [_buttons release];
    [super dealloc];
}

- (NSUInteger)buttonCount
{
    return _buttons.count;
}

- (void)addButtonWithTitle:(NSString *)title type:(BlockActionSheetButtonType)type block:(void (^)())block atIndex:(NSInteger)index
{
    NSDictionary *buttonProperties = [NSDictionary dictionaryWithObjectsAndKeys:
            block ? [[block copy] autorelease] : [NSNull null], BlockActionSheet_ButtonProperty_ActionBlock,
            [NSNumber numberWithInt:type], BlockActionSheet_ButtonProperty_Type,
            title, BlockActionSheet_ButtonProperty_Title,
            nil];

    [self addButtonWithProperties:buttonProperties atIndex:index];
}

- (void)addButtonWithProperties:(NSDictionary *)buttonProperties atIndex:(NSInteger)index {
    if (index >= 0)
    {
        [_buttons insertObject:buttonProperties
                       atIndex:index];
    }
    else
    {
        [_buttons addObject:buttonProperties];
    }
}

- (void)setDestructiveButtonWithTitle:(NSString *)title block:(void (^)())block
{
    [self addButtonWithTitle:title type:BlockActionSheetButtonTypeDestructive block:block atIndex:-1];
}

- (void)setCancelButtonWithTitle:(NSString *)title block:(void (^)())block
{
    [self addButtonWithTitle:title type:BlockActionSheetButtonTypeCancel block:block atIndex:-1];
}

- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block 
{
    [self addButtonWithTitle:title type:BlockActionSheetButtonTypeNormal block:block atIndex:-1];
}

- (void)setDestructiveButtonWithTitle:(NSString *)title atIndex:(NSInteger)index block:(void (^)())block
{
    [self addButtonWithTitle:title type:BlockActionSheetButtonTypeDestructive block:block atIndex:index];
}

- (void)setCancelButtonWithTitle:(NSString *)title atIndex:(NSInteger)index block:(void (^)())block
{
    [self addButtonWithTitle:title type:BlockActionSheetButtonTypeCancel block:block atIndex:index];
}

- (void)addButtonWithTitle:(NSString *)title atIndex:(NSInteger)index block:(void (^)())block 
{
    [self addButtonWithTitle:title type:BlockActionSheetButtonTypeNormal block:block atIndex:index];
}

- (NSString *)imageNameForType:(BlockActionSheetButtonType)type {
    NSString *color = nil;
    switch (type) {
        case BlockActionSheetButtonTypeNormal:
            color = @"gray";
            break;
        case BlockActionSheetButtonTypeCancel:
            color = @"black";
            break;
        case BlockActionSheetButtonTypeDestructive:
            color = @"red";
            break;
    }
    return [NSString stringWithFormat:@"action-%@-button.png", color];
}

- (void)showInView:(UIView *)view
{
    self.isVisible = YES;
    NSUInteger tag = 1;
    for (NSDictionary *buttonProperties in _buttons)
    {
        UIButton *button = [self buttonWithProperties:buttonProperties tag:tag++];
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:button];
        button.frame = CGRectMake(kActionSheetBorder, _height, _view.bounds.size.width-kActionSheetBorder*2, kActionSheetButtonHeight);
        _height += kActionSheetButtonHeight + kActionSheetBorder;
    }
    
    UIImageView *modalBackground = [[UIImageView alloc] initWithFrame:_view.bounds];
    modalBackground.image = background;
    modalBackground.contentMode = UIViewContentModeScaleToFill;
    [_view insertSubview:modalBackground atIndex:0];
    [modalBackground release];
    
    [BlockBackground sharedInstance].vignetteBackground = _vignetteBackground;
    [[BlockBackground sharedInstance] addToMainWindow:_view];
    CGRect frame = _view.frame;
    frame.origin.y = [BlockBackground sharedInstance].bounds.size.height;
    frame.size.height = _height + kActionSheetBounce;
    _view.frame = frame;
    
    __block CGPoint center = _view.center;
    center.y -= _height + kActionSheetBounce;
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         [BlockBackground sharedInstance].alpha = 1.0f;
                         _view.center = center;
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.1
                                               delay:0.0
                                             options:UIViewAnimationOptionAllowUserInteraction
                                          animations:^{
                                              center.y += kActionSheetBounce;
                                              _view.center = center;
                                          } completion:nil];
                     }];
    
    [self retain];
}

- (UIButton *)buttonWithProperties:(NSDictionary *)buttonProperties tag:(NSUInteger)tag {
    NSString *title = [buttonProperties objectForKey:BlockActionSheet_ButtonProperty_Title];
    BlockActionSheetButtonType type = (BlockActionSheetButtonType)[(NSNumber *) [buttonProperties objectForKey:BlockActionSheet_ButtonProperty_Type] intValue];

    UIImage *image = [UIImage imageNamed:[self imageNameForType:type]];
    image = [image stretchableImageWithLeftCapWidth:(int)(image.size.width)>>1 topCapHeight:0];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(kActionSheetBorder, _height, _view.bounds.size.width-kActionSheetBorder*2, kActionSheetButtonHeight);
    button.titleLabel.font = buttonFont;
    button.titleLabel.minimumFontSize = 6;
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.titleLabel.textAlignment = UITextAlignmentCenter;
    button.titleLabel.shadowOffset = kActionSheetButtonShadowOffset;
    button.backgroundColor = [UIColor clearColor];
    button.tag = tag;

    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setTitleColor:kActionSheetButtonTextColor forState:UIControlStateNormal];
    [button setTitleShadowColor:kActionSheetButtonShadowColor forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    button.accessibilityLabel = title;

    return button;
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated 
{
    if (buttonIndex >= 0 && buttonIndex < [_buttons count])
    {
        id obj = [[_buttons objectAtIndex:buttonIndex] objectForKey:BlockActionSheet_ButtonProperty_ActionBlock];
        if (![obj isEqual:[NSNull null]])
        {
            ((void (^)())obj)();
        }
    }
    
    if (animated)
    {
        CGPoint center = _view.center;
        center.y += _view.bounds.size.height;
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             _view.center = center;
                             [[BlockBackground sharedInstance] reduceAlphaIfEmpty];
                         } completion:^(BOOL finished) {
                             [self tearDownSheet];
                         }];
    }
    else
    {
        [self tearDownSheet];
    }
}

- (void)tearDownSheet {
    if (isClosing) {
        return;
    }
    isClosing = YES;
    [[BlockBackground sharedInstance] removeView:_view];
    [_view release];
    _view = nil;
    [self autorelease];
    self.isVisible = NO;
}

#pragma mark - Action

- (void)buttonClicked:(id)sender 
{
    /* Run the button's block */
    int buttonIndex = [sender tag] - 1;
    [self dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

@end
