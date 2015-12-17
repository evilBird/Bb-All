//
//  BSDControl.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 11/12/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDView.h"

@interface BSDControl : BSDView

@property (nonatomic,strong)BSDOutlet *eventOutlet;

- (void)handleAction:(id)sender;

@end
