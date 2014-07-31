//
//  BlockActionSheet.m
//
//

#import "BlockActionSheet.h"
#import "BlockBackground.h"
#import "BlockUI.h"
#import "BlockActionSheetStyle.h"

@interface NSString (Sizing)

- (CGSize)safeSizeWithFont:(UIFont*)font
         constrainedToSize:(CGSize)size
             lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end

@implementation NSString (Sizing)

- (CGSize)safeSizeWithFont:(UIFont*)font
         constrainedToSize:(CGSize)size
             lineBreakMode:(NSLineBreakMode)lineBreakMode  {
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = lineBreakMode;
    NSDictionary * attributes = @{NSFontAttributeName: font,
                                  NSParagraphStyleAttributeName: paragraphStyle};
    CGRect textRect = [self boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:attributes
                                         context:nil];
    CGSize exactSize = textRect.size;
    CGSize roundedUpSize = CGSizeMake(ceilf(exactSize.width), ceilf(exactSize.height));
    return roundedUpSize;
}

@end

@interface BlockActionSheet ()

@property (nonatomic, readwrite) BOOL isVisible;

@end

@implementation BlockActionSheet {
    BOOL isClosing;
    UIView *headerView;
    int transparentBackgroundRegionOffset;
    UILabel *labelView;
}

@synthesize view = _view;
@synthesize vignetteBackground = _vignetteBackground;
@synthesize actionSheetStyle = _actionSheetStyle;

static UIImage *background = nil;
static UIFont *titleFont = nil;
static UIFont *buttonFont = nil;

#pragma mark - init

+ (id)sheetWithTitle:(NSString *)title
{
    return [[[BlockActionSheet alloc] initWithTitle:title] autorelease];
}

+ (id)sheetWithTitle:(NSString *)title andStyle:(BlockActionSheetStyle *)style
{
    return [[[BlockActionSheet alloc] initWithTitle:title andStyle:style] autorelease];
}

- (id)initWithTitle:(NSString *)title
{
    BlockActionSheetStyle *style = [[[BlockActionSheetStyle alloc] init] autorelease];
    return [self initWithTitle:title andStyle:style];
}

- (id)initWithTitle:(NSString *)title andStyle:(BlockActionSheetStyle *)style
{
    return [self initWithTitle:title titleAccessibilityLabel:title andStyle:style];
}

- (id)initWithTitle:(NSString *)title titleAccessibilityLabel:(NSString *)accLabel andStyle:(BlockActionSheetStyle *)style {
    if ((self = [super init]))
    {
        [style retain];
        [_actionSheetStyle release];
        _actionSheetStyle = style;
        
        background = [UIImage imageNamed:[_actionSheetStyle actionSheetBackground]];
        background = [[background stretchableImageWithLeftCapWidth:0 topCapHeight:[_actionSheetStyle actionSheetBackgroundCapHeight]] retain];
        titleFont = [[_actionSheetStyle actionSheetTitleFont] retain];
        buttonFont = [[_actionSheetStyle actionsheetButtonFont] retain];

        UIWindow *parentView = [BlockBackground sharedInstance];
        CGRect frame = parentView.bounds;
        
        _view = [[UIView alloc] initWithFrame:frame];
        _buttons = [[NSMutableArray alloc] init];
        _height = [_actionSheetStyle actionSheetTopMargin];

        if (title)
        {
            CGFloat actionSheetBorder = [_actionSheetStyle actionSheetBorder];
            CGSize size = [title safeSizeWithFont:titleFont
                                constrainedToSize:CGSizeMake(frame.size.width-actionSheetBorder*2, 1000)
                                    lineBreakMode:NSLineBreakByWordWrapping];
            
            labelView = [[UILabel alloc] initWithFrame:CGRectMake(actionSheetBorder, _height, frame.size.width-actionSheetBorder*2, size.height)];
            labelView.font = titleFont;
            labelView.numberOfLines = 0;
            labelView.lineBreakMode = NSLineBreakByWordWrapping;
            labelView.textColor = [_actionSheetStyle actionSheetTitleTextColor];
            labelView.backgroundColor = [UIColor clearColor];
            labelView.textAlignment = NSTextAlignmentCenter;
            labelView.shadowColor = [_actionSheetStyle actionSheetTitleShadowColor];
            labelView.shadowOffset = [_actionSheetStyle actionSheetTitleShadowOffset];
            labelView.text = title;
            labelView.accessibilityLabel = accLabel;
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
                labelView.accessibilityTraits = UIAccessibilityTraitHeader;
            }
            
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

- (void)addHeaderView:(UIView *)aHeaderView withTransparentBackgroundRegionOffset:(int)offset {
    [aHeaderView retain];
    headerView = aHeaderView;
    transparentBackgroundRegionOffset = offset;
}

- (void)showInView:(UIView *)view
{
    self.isVisible = YES;
    NSUInteger tag = 1;
    
    if (headerView) {
        [_view addSubview:headerView];
        _height += CGRectGetHeight(headerView.frame);
        
        CGRect frame = headerView.frame;
        frame.origin.y += transparentBackgroundRegionOffset;
        headerView.frame = frame;
    }
    
    for (NSDictionary *buttonProperties in _buttons)
    {
        CGFloat actionSheetBorder = [_actionSheetStyle actionSheetBorder];
        UIButton *button = [self buttonWithProperties:buttonProperties tag:tag++];
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_view addSubview:button];
        button.frame = CGRectMake(actionSheetBorder, _height, _view.bounds.size.width-actionSheetBorder*2, [_actionSheetStyle actionSheetButtonHeight]);
        _height += [_actionSheetStyle actionSheetButtonHeight] + actionSheetBorder;
    }
    
    CGRect backgroundBounds = _view.bounds;
    
    if (headerView) {
        backgroundBounds.origin.y = CGRectGetHeight(headerView.frame);
        
        CGRect frame = labelView.frame;
        frame.origin.y += CGRectGetHeight(headerView.frame);
        labelView.frame = frame;
    }
    
    UIImageView *modalBackground = [[UIImageView alloc] initWithFrame:backgroundBounds];
    modalBackground.image = background;
    modalBackground.contentMode = UIViewContentModeScaleToFill;
    [_view insertSubview:modalBackground atIndex:0];
    [modalBackground release];
    
    CGFloat actionSheetBounce = [_actionSheetStyle actionSheetBounce];
    [BlockBackground sharedInstance].vignetteBackground = _vignetteBackground;
    [[BlockBackground sharedInstance] addToMainWindow:_view];
    CGRect frame = _view.frame;
    frame.origin.y = [BlockBackground sharedInstance].bounds.size.height;
    frame.size.height = _height + actionSheetBounce;
    _view.frame = frame;
    
    __block CGPoint center = _view.center;
    center.y -= _height + actionSheetBounce;
    
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
                                              center.y += actionSheetBounce;
                                              _view.center = center;
                                          } completion:^(BOOL finished) {
                                              if (UIAccessibilityIsVoiceOverRunning()) {
                                                  UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification,
                                                                                  labelView);
                                              }
                                          }];
                     }];
    
    [self retain];
}

- (UIButton *)buttonWithProperties:(NSDictionary *)buttonProperties tag:(NSUInteger)tag {
    NSString *title = [buttonProperties objectForKey:BlockActionSheet_ButtonProperty_Title];
    BlockActionSheetButtonType type = (BlockActionSheetButtonType)[(NSNumber *) [buttonProperties objectForKey:BlockActionSheet_ButtonProperty_Type] intValue];

    UIImage *image = [UIImage imageNamed:[self imageNameForType:type]];
    image = [image stretchableImageWithLeftCapWidth:(int)(image.size.width)>>1 topCapHeight:0];
    
    CGFloat actionSheetBorder = [_actionSheetStyle actionSheetBorder];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(actionSheetBorder, _height, _view.bounds.size.width-actionSheetBorder*2, [_actionSheetStyle actionSheetButtonHeight]);
    button.titleLabel.font = buttonFont;
    button.titleLabel.minimumScaleFactor = 0.5f;
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.shadowOffset = [_actionSheetStyle actionSheetButtonShadowOffset];
    button.backgroundColor = [UIColor clearColor];
    button.tag = tag;

    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setTitleColor:[_actionSheetStyle actionSheetButtonTextColor] forState:UIControlStateNormal];
    [button setTitleShadowColor:[_actionSheetStyle actionSheetButtonShadowColor] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    button.accessibilityLabel = title;

    return button;
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
    if (animated) {
        CGPoint center = _view.center;
        center.y += _view.bounds.size.height;
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationCurveEaseIn
                         animations:^{
                             _view.center = center;
                             [[BlockBackground sharedInstance] reduceAlphaIfEmpty];
                         }
                         completion:^(BOOL finished) {
                             [self tearDownSheet];
                             [self performBlockForButtonIndex:buttonIndex];
                         }
        ];
    }
    else {
        [self tearDownSheet];
    }
}

- (void)performBlockForButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex >= 0 && buttonIndex < [_buttons count])
    {
        id obj = [[_buttons objectAtIndex:buttonIndex] objectForKey:BlockActionSheet_ButtonProperty_ActionBlock];
        if (![obj isEqual:[NSNull null]])
        {
            ((void (^)())obj)();
        }
    }
}

- (void)tearDownSheet {
    if (isClosing) {
        return;
    }
    isClosing = YES;
    [[BlockBackground sharedInstance] removeView:_view];
    [headerView release];
    headerView = nil;
    [_actionSheetStyle release];
    _actionSheetStyle = nil;
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
