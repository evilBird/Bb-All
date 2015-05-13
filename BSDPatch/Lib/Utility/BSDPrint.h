//
//  BSDPrint.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/15/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDObject.h"

static NSString *kPrintNotificationChannel = @"com.birdsound.bb.bsdprint";

@interface BSDPrint : BSDObject

@property (nonatomic,strong)NSString *text;

@end
