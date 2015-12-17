//
//  BSDDisplayManager.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 1/14/15.
//  Copyright (c) 2015 birdSound LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BSDDisplayManager : NSObject

+ (BSDDisplayManager *)sharedInstance;

- (void)addDisplayViewController:(UIViewController *)viewController;
- (void)removeDisplayViewController:(UIViewController *)viewController;

@end
