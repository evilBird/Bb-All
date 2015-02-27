//
//  BbCompiledPatch.h
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/24/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbPatch+Connections.h"

@interface BbCompiledPatch : BbPatch

- (void)createChildObjectsWithText:(NSString *)text;
- (NSArray *)filterDescriptions:(NSArray *)descriptions;

@end
