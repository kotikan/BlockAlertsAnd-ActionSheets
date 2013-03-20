//
//  BlockAlertViewStyle.h
//  Skyscanner_App
//
//  Created by Liam Douglas on 20/03/2013.
//
//

#import <Foundation/Foundation.h>

@interface BlockAlertViewStyle : NSObject

- (CGFloat)alertViewBounce;

- (CGFloat)alertViewBorder;

- (CGFloat)alertViewButtonHeight;

- (UIFont *)alertViewTitleFont;

- (UIColor *)alertViewTitleTextColor;

- (UIColor *)alertViewTitleShadowColor;

- (CGSize)alertViewTitleShadowOffset;

- (UIFont *)alertViewMessageFont;

- (UIColor *)alertViewMessageTextColor;

- (UIColor *)alertViewMessageShadowColor;

- (CGSize)alertViewMessageShadowOffset;

- (UIFont *)alertViewButtonFont;

- (UIColor *)alertViewButtonTextColor;

- (UIColor *)alertViewButtonShadowColor;

- (CGSize)alertViewButtonShadowOffset;

- (NSString *)alertViewBackground;

- (CGFloat)alertViewBackgroundCapHeight;

@end
