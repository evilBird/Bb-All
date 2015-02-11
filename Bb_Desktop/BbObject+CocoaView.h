//
//  BbObject+CocoaView.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbObject.h"

@interface BbObject (CocoaView)

+ (BbObject *)objectAndViewWithText:(NSString *)text;

- (void)setView:(id<BbEntityView>)view;

@end
