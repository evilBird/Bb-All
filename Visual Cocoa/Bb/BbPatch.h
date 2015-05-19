//
//  BbPatch.h
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/10/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbObject+EntityParent.h"
#import "BbObject+Encoder.h"
#import "BbParsers.h"
#import "BbConnection.h"
#import "BbProxyPort.h"

@interface BbPatch : BbObject;

- (void)addProxyPort:(id)port;

@property (nonatomic,strong)NSMutableDictionary *connections;

- (NSString *)textDescription;
- (NSArray *)UISize;

@end


@interface BbPatch (ProxyPorts)

- (void)addInlet:(BbInlet *)inlet withProxy:(BbProxyInlet *)proxy;
- (void)addOutlet:(BbOutlet *)outlet withProxy:(BbProxyOutlet *)proxy;

@end


