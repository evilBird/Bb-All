//
//  BbCocoaMessageView.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/16/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbCocoaEntityView+TextDelegate.h"
#import "BbCocoaObjectView.h"

@interface BbCocoaMessageView : BbCocoaObjectView

+ (NSDictionary *)textAttributes;
@property (nonatomic)       BOOL        sending;

@end
