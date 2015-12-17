//
//  BbPatch+CPA.m
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/26/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbPatch+CPA.h"
#import "NSMutableString+Bb.h"
#import "BbCocoaPatchView+Helpers.h"

@implementation BbPatch (CPA)

- (NSString *)copySelected
{
    BbCocoaPatchView *patchView = (BbCocoaPatchView *)self.view;
    return [patchView copySelected];
}

- (void)pasteCopied:(NSString *)copied
{

}
- (BbPatch *)abstractSelected
{
    return nil;
}

@end
