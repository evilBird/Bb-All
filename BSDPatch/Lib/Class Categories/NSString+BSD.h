//
//  NSString+BSD.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 1/13/15.
//  Copyright (c) 2015 birdSound LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (BSD)

- (BOOL)isStringLiteral;
- (NSString *)stringFromLiteral;

@end
