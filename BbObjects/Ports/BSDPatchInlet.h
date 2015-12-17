//
//  BSDPatchInlet.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/17/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDInlet.h"
@class BSDOutlet;
@interface BSDPatchInlet : BSDInlet

@property (nonatomic,strong)BSDOutlet *outputElement;

- (instancetype)initWithArguments:(id)args;

@property (nonatomic,strong) NSMutableArray *inlets;
@property (nonatomic,strong) NSMutableArray *outlets;

- (id)inletNamed:(NSString *)inletName;
- (id)outletNamed:(NSString *)outletName;

- (void)tearDown;

@end
