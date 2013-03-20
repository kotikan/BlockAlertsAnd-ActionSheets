//
//  BlockActionSheetStyle.m
//  Skyscanner_App
//
//  Created by Liam Douglas on 20/03/2013.
//
//

#import "BlockActionSheetStyle.h"

@implementation BlockActionSheetStyle

- (CGFloat)actionSheetBounce {
    return 10.0;
}

- (CGFloat)actionSheetBorder {
    return 10.0;
}

- (CGFloat)actionSheetButtonHeight {
    return 45.0;
}

- (CGFloat)actionSheetTopMargin {
    return 15.0;
}

- (UIFont *)actionSheetTitleFont {
    return [UIFont systemFontOfSize:18.0];
}

- (UIColor *)actionSheetTitleTextColor {
    return [UIColor whiteColor];
}

- (UIColor *)actionSheetTitleShadowColor {
    return [UIColor blackColor];
}

- (CGSize)actionSheetTitleShadowOffset {
    return CGSizeMake(0, -1);
}

- (UIFont *)actionsheetButtonFont {
    return [UIFont boldSystemFontOfSize:20.0];
}

- (UIColor *)actionSheetButtonTextColor {
    return [UIColor whiteColor];
}

- (UIColor *)actionSheetButtonShadowColor {
    return [UIColor blackColor];
}

- (CGSize)actionSheetButtonShadowOffset {
    return CGSizeMake(0, -1);
}

- (NSString *)actionSheetBackground {
    return @"action-sheet-panel.png";
}

- (CGFloat)actionSheetBackgroundCapHeight {
    return 30.0;
}

@end
