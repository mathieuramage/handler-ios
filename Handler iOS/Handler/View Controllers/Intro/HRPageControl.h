//
//  HRPageControl.h
//  Handler
//
//  Created by Guillaume Kermorgant on 26/11/15.
//  Copyright © 2015 Handler, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HRPageControl : UIPageControl
{
    UIImage* activeImage;
    UIImage* inactiveImage;
}
@property(nonatomic, retain) UIImage* activeImage;
@property(nonatomic, retain) UIImage* inactiveImage;

@end
