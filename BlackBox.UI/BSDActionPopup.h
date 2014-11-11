//
//  BSDActionPopup.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 11/11/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface BSDActionPopup : UIView

+ (BSDActionPopup *)showPopupWithActions:(NSArray *)actions inView:(UIView *)view anchorPoint:(CGPoint)point completion:(void(^)(NSInteger selectedIndex))completion;

@end
