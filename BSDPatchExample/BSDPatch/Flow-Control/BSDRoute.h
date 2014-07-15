//
//  BSDRoute.h
//  BSDLang
//
//  Created by Travis Henspeter on 7/13/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDObject.h"

@interface BSDRoute : BSDObject


- (void)connectToHot:(BSDObject *)object selector:(NSString *)selector;
- (void)connectToCold:(BSDObject *)object selector:(NSString *)selector;


@end