//
//  HRPageControl.h
//  Handler
//
//  Created by Guillaume Kermorgant on 26/11/15.
//  Copyright (c) 2013-2016 Mathieu Ramage - All Rights Reserved.
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
