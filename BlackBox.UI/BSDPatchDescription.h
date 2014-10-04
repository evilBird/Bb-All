//
//  BSDPatchDescription.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 10/3/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BSDPatchDescription : NSObject

- (NSUInteger)addObjectClassName:(NSString *)className args:(NSString *)args position:(CGPoint)position;

@end
