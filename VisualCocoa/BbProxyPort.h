//
//  BbPortProxy.h
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/24/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbObject.h"

@interface BbProxyPort : BbObject <BbPortProxy>

@property (nonatomic,strong)BbPort *parentPort;

- (NSUInteger)index;

@end

@interface BbProxyInlet : BbProxyPort;

@end

@interface BbProxyOutlet : BbProxyPort;

@end