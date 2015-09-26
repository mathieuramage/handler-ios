//
//  CLTokenView.h
//  CLTokenInputView
//
//  Created by Rizwan Sattar on 2/24/14.
//  Copyright (c) 2014 Cluster Labs, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CLToken.h"

NS_ASSUME_NONNULL_BEGIN

@class CLTokenView;
@protocol CLTokenViewDelegate <NSObject>

@required
- (void)tokenViewDidRequestDelete:(CLTokenView *)tokenView replaceWithText:(nullable NSString *)replacementText;
- (void)tokenViewDidRequestSelection:(CLTokenView *)tokenView;
@optional
- (UIColor*)textColorForTokenViewWithToken:(CLToken*)token;
@end


@interface CLTokenView : UIView <UIKeyInput>

@property (weak, nonatomic, nullable) NSObject <CLTokenViewDelegate> *delegate;
@property (assign, nonatomic) BOOL selected;
@property (strong, nonatomic) CLToken* token;

- (id)initWithToken:(CLToken *)token andDelegate:(NSObject<CLTokenViewDelegate>*)delegate;
- (void)reload;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

// For iOS 6 compatibility, provide the setter tintColor
- (void)setTintColor:(nullable UIColor *)tintColor;

@end

NS_ASSUME_NONNULL_END
