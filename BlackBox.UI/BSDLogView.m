//
//  BSDLogView.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 10/15/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDLogView.h"
#import <QuartzCore/QuartzCore.h>

@implementation BSDLogView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView  = [[UIScrollView alloc]initWithFrame:self.bounds];
        _textView = [[UITextView alloc]initWithFrame:_scrollView.bounds];
        [_scrollView addSubview:_textView];
        [self addSubview:_scrollView];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handlePrintNotification:) name:kPrintNotificationChannel object:nil];
        _textView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        UIEdgeInsets insets = _textView.textContainerInset;
        insets.left = 10;
        insets.right = 10;
        insets.bottom = 10;
        insets.top = 10;
        _textView.textContainerInset = insets;
        _textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        _textView.layer.borderWidth = 1;
        _textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _textView.editable = NO;
    }
    
    return self;
}

- (void)handlePrintNotification:(NSNotification *)notification
{
    NSString *toPrint = notification.object;
    NSString *existingText = self.textView.text;
    NSString *toDisplay = nil;
    if (existingText) {
        toDisplay = [existingText stringByAppendingFormat:@"%@\n",toPrint];
    }else{
        toDisplay = [toPrint stringByAppendingFormat:@"%@\n",toPrint];
    }
    
    [self updateTextView:self.textView andScrollView:self.scrollView withText:toDisplay];
}

- (void)updateTextView:(UITextView *)textView andScrollView:(UIScrollView *)scrollview withText:(NSString *)text
{
    textView.text = text;
    scrollview.contentSize = textView.frame.size;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
