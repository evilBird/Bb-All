//
//  BSDPatchOutlet.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/17/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDOutlet.h"
@class BSDInlet;
@interface BSDPatchOutlet : BSDOutlet

@property (nonatomic,strong)BSDInlet *inputElement;

- (instancetype)initWithArguments:(id)arguments;

@property (nonatomic,strong) NSMutableArray *inlets;
@property (nonatomic,strong) NSMutableArray *outlets;

- (id)inletNamed:(NSString *)inletName;
- (id)outletNamed:(NSString *)outletName;

- (void)tearDown;


@end
