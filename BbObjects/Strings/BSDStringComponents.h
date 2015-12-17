//
//  BSDStringComponents.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 12/10/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDObject.h"
#import "BSDStringInlet.h"

@interface BSDStringComponents : BSDObject

- (NSString *)stringFromArray:(NSArray *)array withSeparator:(NSString *)separator;

@end
