//
//  BSDSuperview.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/30/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDView.h"

static NSString *kScreenDelegateChannel = @"com.bb.BSDScreenDelegate";

@protocol BSDScreenDelegate <NSObject>

- (UIView *)canvasScreen;

@end

@interface BSDScreen : BSDView

@property (nonatomic,weak)id<BSDScreenDelegate>delegate;

+ (NSString *)listeningChannel;

@end
