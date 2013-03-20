//
//  BlockAlertViewStyle.m
//  Skyscanner_App
//
//  Created by Liam Douglas on 20/03/2013.
//
//

#import "BlockAlertViewStyle.h"

@implementation BlockAlertViewStyle

- (CGFloat)alertViewBounce {
    return 20.0;
}

- (CGFloat)alertViewBorder {
    return 10.0;
}

- (CGFloat)alertViewButtonHeight {
    return 44.0;
}

- (UIFont *)alertViewTitleFont {
    return [UIFont boldSystemFontOfSize:20];
}

- (UIColor *)alertViewTitleTextColor {
    return [UIColor colorWithWhite:244.0/255.0 alpha:1.0];
}

- (UIColor *)alertViewTitleShadowColor {
    return [UIColor blackColor];
}

- (CGSize)alertViewTitleShadowOffset {
    return CGSizeMake(0, -1);
}

- (UIFont *)alertViewMessageFont {
    return [UIFont systemFontOfSize:18.0];
}

- (UIColor *)alertViewMessageTextColor {
    return [UIColor colorWithWhite:244.0/255.0 alpha:1.0];
}

- (UIColor *)alertViewMessageShadowColor {
    return [UIColor blackColor];
}

- (CGSize)alertViewMessageShadowOffset {
    return CGSizeMake(0, -1);
}

- (UIFont *)alertViewButtonFont {
    return [UIFont systemFontOfSize:18.0];
}

- (UIColor *)alertViewButtonTextColor {
    return [UIColor whiteColor];
}

- (UIColor *)alertViewButtonShadowColor {
    return [UIColor blackColor];
}

- (CGSize)alertViewButtonShadowOffset {
    return CGSizeMake(0, -1);
}

- (NSString *)alertViewBackground {
    return @"alert-window.png";
}

- (CGFloat)alertViewBackgroundCapHeight {
    return 38.0;
}

@end
