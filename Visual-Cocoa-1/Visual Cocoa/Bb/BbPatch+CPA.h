//
//  BbPatch+CPA.h
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/26/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbPatch.h"

@interface BbPatch (CPA)

- (NSString *)copySelected;
- (void)pasteCopied:(NSString *)copied;
- (BbPatch *)abstractSelected;

@end
