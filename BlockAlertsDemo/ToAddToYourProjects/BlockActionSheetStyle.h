//
//  BlockActionSheetStyle.h
//  Skyscanner_App
//
//  Created by Liam Douglas on 20/03/2013.
//
//

#import <Foundation/Foundation.h>

@interface BlockActionSheetStyle : NSObject

- (CGFloat)actionSheetBounce;

- (CGFloat)actionSheetBorder;

- (CGFloat)actionSheetButtonHeight;

- (CGFloat)actionSheetTopMargin;

- (UIFont *)actionSheetTitleFont;

- (UIColor *)actionSheetTitleTextColor;

- (UIColor *)actionSheetTitleShadowColor;

- (CGSize)actionSheetTitleShadowOffset;

- (UIFont *)actionsheetButtonFont;

- (UIColor *)actionSheetButtonTextColor;

- (UIColor *)actionSheetButtonShadowColor;

- (CGSize)actionSheetButtonShadowOffset;

- (NSString *)actionSheetBackground;

- (CGFloat)actionSheetBackgroundCapHeight;

@end
