//
//  BSDLoadBang.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 10/1/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDObject.h"

static NSString *kLoadBangNotification = @"com.bb.LoadBang";

@interface BSDLoadBang : BSDObject

- (void)parentPatchFinishedLoading;

@end
