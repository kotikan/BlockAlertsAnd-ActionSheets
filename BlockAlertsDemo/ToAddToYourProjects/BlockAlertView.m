//
//  BlockAlertView.m
//
//

#import "BlockAlertView.h"
#import "BlockBackground.h"
#import "BlockUI.h"
#import "BlockAlertViewStyle.h"

@implementation BlockAlertView

@synthesize view = _view;
@synthesize backgroundImage = _backgroundImage;
@synthesize vignetteBackground = _vignetteBackground;
@synthesize alertViewStyle = _alertViewStyle;

static UIImage *background = nil;
static UIFont *titleFont = nil;
static UIFont *messageFont = nil;
static UIFont *buttonFont = nil;

#pragma mark - init

+ (BlockAlertView *)alertWithTitle:(NSString *)title message:(NSString *)message
{
    return [[[BlockAlertView alloc] initWithTitle:title message:message] autorelease];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

- (id)initWithTitle:(NSString *)title message:(NSString *)message
{
    return [self initWithTitle:title message:message style:[[[BlockAlertViewStyle alloc] init] autorelease]];
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message style:(BlockAlertViewStyle *)style
{
    if ((self = [super init]))
    {
        [style retain];
        [_alertViewStyle release];
        _alertViewStyle = style;
        
        background = [UIImage imageNamed:[_alertViewStyle alertViewBackground]];
        background = [[background stretchableImageWithLeftCapWidth:0 topCapHeight:[_alertViewStyle alertViewBackgroundCapHeight]] retain];
        titleFont = [[_alertViewStyle alertViewTitleFont] retain];
        messageFont = [[_alertViewStyle alertViewMessageFont] retain];
        buttonFont = [[_alertViewStyle alertViewButtonFont] retain];
        
        UIWindow *parentView = [BlockBackground sharedInstance];
        CGRect frame = parentView.bounds;
        frame.origin.x = floorf((frame.size.width - background.size.width) * 0.5);
        frame.size.width = background.size.width;
        
        _view = [[UIView alloc] initWithFrame:frame];
        _blocks = [[NSMutableArray alloc] init];
        CGFloat borderSize = [_alertViewStyle alertViewBorder];
        _height = borderSize + 6;

        if (title)
        {
            CGSize size = [title sizeWithFont:titleFont
                            constrainedToSize:CGSizeMake(frame.size.width-borderSize*2, 1000)
                                lineBreakMode:UILineBreakModeWordWrap];

            UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(borderSize, _height, frame.size.width-borderSize*2, size.height)];
            labelView.font = titleFont;
            labelView.numberOfLines = 0;
            labelView.lineBreakMode = UILineBreakModeWordWrap;
            labelView.textColor = [_alertViewStyle alertViewTitleTextColor];
            labelView.backgroundColor = [UIColor clearColor];
            labelView.textAlignment = UITextAlignmentCenter;
            labelView.shadowColor = [_alertViewStyle alertViewTitleShadowColor];
            labelView.shadowOffset = [_alertViewStyle alertViewMessageShadowOffset];
            labelView.text = title;
            [_view addSubview:labelView];
            [labelView release];
            
            _height += size.height + borderSize;
        }
        
        if (message)
        {
            CGSize size = [message sizeWithFont:messageFont
                              constrainedToSize:CGSizeMake(frame.size.width-borderSize*2, 1000)
                                  lineBreakMode:UILineBreakModeWordWrap];
            
            UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(borderSize, _height, frame.size.width-borderSize*2, size.height)];
            labelView.font = messageFont;
            labelView.numberOfLines = 0;
            labelView.lineBreakMode = UILineBreakModeWordWrap;
            labelView.textColor = [_alertViewStyle alertViewMessageTextColor];
            labelView.backgroundColor = [UIColor clearColor];
            labelView.textAlignment = UITextAlignmentCenter;
            labelView.shadowColor = [_alertViewStyle alertViewMessageShadowColor];
            labelView.shadowOffset = [_alertViewStyle alertViewMessageShadowOffset];
            labelView.text = message;
            [_view addSubview:labelView];
            [labelView release];
            
            _height += size.height + borderSize;
        }
        
        _vignetteBackground = NO;
    }
    
    return self;
}

- (void)dealloc 
{
    [_backgroundImage release];
    [_alertViewStyle release];
    [_view release];
    [_blocks release];
    [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public

- (void)addButtonWithTitle:(NSString *)title color:(NSString*)color block:(void (^)())block 
{
    [_blocks addObject:[NSArray arrayWithObjects:
                        block ? [[block copy] autorelease] : [NSNull null],
                        title,
                        color,
                        nil]];
}

- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block 
{
    [self addButtonWithTitle:title color:@"gray" block:block];
}

- (void)setCancelButtonWithTitle:(NSString *)title block:(void (^)())block 
{
    [self addButtonWithTitle:title color:@"black" block:block];
}

- (void)setDestructiveButtonWithTitle:(NSString *)title block:(void (^)())block
{
    [self addButtonWithTitle:title color:@"red" block:block];
}

- (void)show
{
    BOOL isSecondButton = NO;
    NSUInteger index = 0;
    for (NSUInteger i = 0; i < _blocks.count; i++)
    {
        NSArray *block = [_blocks objectAtIndex:i];
        NSString *title = [block objectAtIndex:1];
        NSString *color = [block objectAtIndex:2];

        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"alert-%@-button.png", color]];
        image = [image stretchableImageWithLeftCapWidth:(int)(image.size.width+1)>>1 topCapHeight:0];
        
        CGFloat borderSize = [_alertViewStyle alertViewBorder];
        CGFloat maxHalfWidth = floorf((_view.bounds.size.width-borderSize*3)*0.5);
        CGFloat width = _view.bounds.size.width-borderSize*2;
        CGFloat xOffset = borderSize;
        if (isSecondButton)
        {
            width = maxHalfWidth;
            xOffset = width + borderSize * 2;
            isSecondButton = NO;
        }
        else if (i + 1 < _blocks.count)
        {
            // In this case there's another button.
            // Let's check if they fit on the same line.
            CGSize size = [title sizeWithFont:buttonFont 
                                  minFontSize:10 
                               actualFontSize:nil
                                     forWidth:_view.bounds.size.width-borderSize*2 
                                lineBreakMode:UILineBreakModeClip];
            
            if (size.width < maxHalfWidth - borderSize)
            {
                // It might fit. Check the next Button
                NSArray *block2 = [_blocks objectAtIndex:i+1];
                NSString *title2 = [block2 objectAtIndex:1];
                size = [title2 sizeWithFont:buttonFont 
                                minFontSize:10 
                             actualFontSize:nil
                                   forWidth:_view.bounds.size.width-borderSize*2 
                              lineBreakMode:UILineBreakModeClip];
                
                if (size.width < maxHalfWidth - borderSize)
                {
                    // They'll fit!
                    isSecondButton = YES;  // For the next iteration
                    width = maxHalfWidth;
                }
            }
        }
        else if (_blocks.count  == 1)
        {
            // In this case this is the ony button. We'll size according to the text
            CGSize size = [title sizeWithFont:buttonFont 
                                  minFontSize:10 
                               actualFontSize:nil
                                     forWidth:_view.bounds.size.width-borderSize*2 
                                lineBreakMode:UILineBreakModeClip];

            size.width = MAX(size.width, 80);
            if (size.width + 2 * borderSize < width)
            {
                width = size.width + 2 * borderSize;
                xOffset = floorf((_view.bounds.size.width - width) * 0.5);
            }
        }
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(xOffset, _height, width, [_alertViewStyle alertViewButtonHeight]);
        button.titleLabel.font = buttonFont;
        button.titleLabel.minimumFontSize = 10;
        button.titleLabel.textAlignment = UITextAlignmentCenter;
        button.titleLabel.shadowOffset = [_alertViewStyle alertViewButtonShadowOffset];
        button.backgroundColor = [UIColor clearColor];
        button.tag = i+1;
        
        [button setBackgroundImage:image forState:UIControlStateNormal];
        [button setTitleColor:[_alertViewStyle alertViewButtonTextColor] forState:UIControlStateNormal];
        [button setTitleShadowColor:[_alertViewStyle alertViewButtonShadowColor] forState:UIControlStateNormal];
        [button setTitle:title forState:UIControlStateNormal];
        button.accessibilityLabel = title;
        
        [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [_view addSubview:button];
        
        if (!isSecondButton)
            _height += [_alertViewStyle alertViewButtonHeight] + borderSize;
        
        index++;
    }
    
    _height += 10;  // Margin for the shadow
    
    if (_height < background.size.height)
    {
        CGFloat offset = background.size.height - _height;
        _height = background.size.height;
        CGRect frame;
        for (NSUInteger i = 0; i < _blocks.count; i++)
        {
            UIButton *btn = (UIButton *)[_view viewWithTag:i+1];
            frame = btn.frame;
            frame.origin.y += offset;
            btn.frame = frame;
        }
    }

    CGRect frame = _view.frame;
    frame.origin.y = - _height;
    frame.size.height = _height;
    _view.frame = frame;
    
    UIImageView *modalBackground = [[UIImageView alloc] initWithFrame:_view.bounds];
    modalBackground.image = background;
    modalBackground.contentMode = UIViewContentModeScaleToFill;
    [_view insertSubview:modalBackground atIndex:0];
    [modalBackground release];
    
    if (_backgroundImage)
    {
        [BlockBackground sharedInstance].backgroundImage = _backgroundImage;
        [_backgroundImage release];
        _backgroundImage = nil;
    }
    [BlockBackground sharedInstance].vignetteBackground = _vignetteBackground;
    [[BlockBackground sharedInstance] addToMainWindow:_view];

    __block CGPoint center = _view.center;
    center.y = floorf([BlockBackground sharedInstance].bounds.size.height * 0.5) + [_alertViewStyle alertViewBounce];
    
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options:UIViewAnimationCurveEaseOut
                     animations:^{
                         [BlockBackground sharedInstance].alpha = 1.0f;
                         _view.center = center;
                     } 
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.1
                                               delay:0.0
                                             options:0
                                          animations:^{
                                              center.y -= [_alertViewStyle alertViewBounce];
                                              _view.center = center;
                                          } 
                                          completion:^(BOOL finished) {
                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"AlertViewFinishedAnimations" object:nil];
                                          }];
                     }];
    
    [self retain];
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated 
{
    if (buttonIndex >= 0 && buttonIndex < [_blocks count])
    {
        id obj = [[_blocks objectAtIndex: buttonIndex] objectAtIndex:0];
        if (![obj isEqual:[NSNull null]])
        {
            ((void (^)())obj)();
        }
    }
    
    if (animated)
    {
        [UIView animateWithDuration:0.1
                              delay:0.0
                            options:0
                         animations:^{
                             CGPoint center = _view.center;
                             center.y += 20;
                             _view.center = center;
                         } 
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.4
                                                   delay:0.0 
                                                 options:UIViewAnimationCurveEaseIn
                                              animations:^{
                                                  CGRect frame = _view.frame;
                                                  frame.origin.y = -frame.size.height;
                                                  _view.frame = frame;
                                                  [[BlockBackground sharedInstance] reduceAlphaIfEmpty];
                                              } 
                                              completion:^(BOOL finished) {
                                                  [[BlockBackground sharedInstance] removeView:_view];
                                                  [_view release]; _view = nil;
                                                  [self autorelease];
                                              }];
                         }];
    }
    else
    {
        [[BlockBackground sharedInstance] removeView:_view];
        [_view release]; _view = nil;
        [self autorelease];
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Action

- (void)buttonClicked:(id)sender 
{
    /* Run the button's block */
    int buttonIndex = [sender tag] - 1;
    [self dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

@end
