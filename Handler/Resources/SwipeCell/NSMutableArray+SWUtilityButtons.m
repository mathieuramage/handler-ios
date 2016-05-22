//
//  NSMutableArray+SWUtilityButtons.m
//  SWTableViewCell
//
//  Created by Matt Bowman on 11/27/13.
//  Copyright (c) 2013 Chris Wendel. All rights reserved.
//

#import "NSMutableArray+SWUtilityButtons.h"
#import "Handler-Swift.h"

@implementation CenteringButton

- (void)centerImageAndTitle:(float)spacing
{
	// get the size of the elements here for readability
	CGSize imageSize = self.imageView.frame.size;
	CGSize titleSize = self.titleLabel.frame.size;
	
	// get the height they will take up as a unit
	CGFloat totalHeight = (imageSize.height + titleSize.height + spacing);
	
	// raise the image and push it right to center it
	self.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0.0, 0.0, - titleSize.width);
	
	// lower the text and push it left to center it
	self.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (totalHeight - titleSize.height),0.0);
}

- (void)centerImageAndTitle
{
	const int DEFAULT_SPACING = 6.0f;
	[self centerImageAndTitle:DEFAULT_SPACING];
}

- (void)setBounds:(CGRect)bounds{
	[super setBounds:bounds];
	
	[self centerImageAndTitle];

}

@end

@implementation NSMutableArray (SWUtilityButtons)

- (void)sw_addUtilityButtonWithColor:(UIColor *)color title:(NSString *)title
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = color;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button.titleLabel setAdjustsFontSizeToFitWidth:YES];
    [self addObject:button];
}

- (void)sw_addUtilityButtonWithColor:(UIColor *)color attributedTitle:(NSAttributedString *)title
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = color;
    [button setAttributedTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self addObject:button];
}

- (void)sw_addUtilityButtonWithColor:(UIColor *)color icon:(UIImage *)icon andTitle:(NSString*)title
{
	CenteringButton *button = [CenteringButton buttonWithType:UIButtonTypeCustom];
	button.backgroundColor = color;
	[button setImage:icon forState:UIControlStateNormal];
	[button setTitle:title forState:UIControlStateNormal];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button.titleLabel setAdjustsFontSizeToFitWidth:YES];
	[button centerImageAndTitle];
	
	[self addObject:button];
}

- (void)sw_addUtilityButtonWithColor:(UIColor *)color icon:(UIImage *)icon attributedTitle:(NSAttributedString*)title
{
	CenteringButton *button = [CenteringButton buttonWithType:UIButtonTypeCustom];
	button.backgroundColor = color;
	[button setImage:icon forState:UIControlStateNormal];
	[button setAttributedTitle:title forState:UIControlStateNormal];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[button.titleLabel setAdjustsFontSizeToFitWidth:YES];
	[button centerImageAndTitle];
	
	[self addObject:button];
}

- (void)sw_addUtilityButtonWithColor:(UIColor *)color icon:(UIImage *)icon
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = color;
    [button setImage:icon forState:UIControlStateNormal];
    [self addObject:button];
}

- (void)sw_addUtilityButtonWithColor:(UIColor *)color normalIcon:(UIImage *)normalIcon selectedIcon:(UIImage *)selectedIcon {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = color;
    [button setImage:normalIcon forState:UIControlStateNormal];
    [button setImage:selectedIcon forState:UIControlStateHighlighted];
    [button setImage:selectedIcon forState:UIControlStateSelected];
    [self addObject:button];
}

@end


@implementation NSArray (SWUtilityButtons)

- (BOOL)sw_isEqualToButtons:(NSArray *)buttons
{
    buttons = [buttons copy];
    if (!buttons || self.count != buttons.count) return NO;
    
    for (NSUInteger idx = 0; idx < self.count; idx++) {
        id buttonA = self[idx];
        id buttonB = buttons[idx];
        if (![buttonA isKindOfClass:[UIButton class]] || ![buttonB isKindOfClass:[UIButton class]]) return NO;
        if (![[self class] sw_button:buttonA isEqualToButton:buttonB]) return NO;
    }
    
    return YES;
}

+ (BOOL)sw_button:(UIButton *)buttonA isEqualToButton:(UIButton *)buttonB
{
    if (!buttonA || !buttonB) return NO;
    
    UIColor *backgroundColorA = buttonA.backgroundColor;
    UIColor *backgroundColorB = buttonB.backgroundColor;
    BOOL haveEqualBackgroundColors = (!backgroundColorA && !backgroundColorB) || [backgroundColorA isEqual:backgroundColorB];
    
    NSString *titleA = [buttonA titleForState:UIControlStateNormal];
    NSString *titleB = [buttonB titleForState:UIControlStateNormal];
    BOOL haveEqualTitles = (!titleA && !titleB) || [titleA isEqualToString:titleB];
    
    UIImage *normalIconA = [buttonA imageForState:UIControlStateNormal];
    UIImage *normalIconB = [buttonB imageForState:UIControlStateNormal];
    BOOL haveEqualNormalIcons = (!normalIconA && !normalIconB) || [normalIconA isEqual:normalIconB];
    
    UIImage *selectedIconA = [buttonA imageForState:UIControlStateSelected];
    UIImage *selectedIconB = [buttonB imageForState:UIControlStateSelected];
    BOOL haveEqualSelectedIcons = (!selectedIconA && !selectedIconB) || [selectedIconA isEqual:selectedIconB];
    
    return haveEqualBackgroundColors && haveEqualTitles && haveEqualNormalIcons && haveEqualSelectedIcons;
}

@end
