//
//  HRPageControl.m
//  Handler
//
//  Created by Guillaume Kermorgant on 26/11/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

#import "HRPageControl.h"

@implementation HRPageControl

@synthesize activeImage;
@synthesize inactiveImage;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        activeImage = [UIImage imageNamed:@"active_dot.png"];
        inactiveImage = [UIImage imageNamed:@"inactive_dot.png"];
    }
    return self;
}

-(void) updateDots
{
    for (int i = 0; i < [self.subviews count]; i++)
    {
        UIImageView * dot = [self imageViewForSubview:  [self.subviews objectAtIndex: i]];
        if (i == self.currentPage) dot.image = activeImage;
        else dot.image = inactiveImage;
    }
}

- (UIImageView *) imageViewForSubview: (UIView *) view
{
    UIImageView * dot = nil;
    if ([view isKindOfClass: [UIView class]])
    {
        for (UIView* subview in view.subviews)
        {
            if ([subview isKindOfClass:[UIImageView class]])
            {
                dot = (UIImageView *)subview;
                break;
            }
        }
        if (dot == nil)
        {
            dot = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, view.frame.size.width, view.frame.size.height)];
            [view addSubview:dot];
        }
    }
    else
    {
        dot = (UIImageView *) view;
    }
    
    return dot;
}

-(void)setCurrentPage:(NSInteger)page
{
    [super setCurrentPage:page];
    [self updateDots];
}

- (void)awakeFromNib
{
    self.pageIndicatorTintColor = [UIColor clearColor];
    self.currentPageIndicatorTintColor = [UIColor clearColor];
}

@end
