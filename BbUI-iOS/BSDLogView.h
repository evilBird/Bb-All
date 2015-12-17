//
//  BSDLogView.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 10/15/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSDPrint.h"

@interface BSDLogView : UIView

@property (nonatomic,strong)UIScrollView *scrollView;
@property (nonatomic,strong)UITextView *textView;

- (void)handlePrintNotification:(NSNotification *)notification;
- (void)clear;

@end
