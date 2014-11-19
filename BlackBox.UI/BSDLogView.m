//
//  BSDLogView.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 10/15/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDLogView.h"
#import <QuartzCore/QuartzCore.h>

@interface BSDLogView ()

@property (nonatomic,strong)NSLayoutConstraint *textViewHeightConstraint;

@end

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
        _textView.autoresizingMask = UIViewAutoresizingFlexibleHeight&UIViewAutoresizingFlexibleWidth;
        _textView.layer.borderWidth = 1;
        _textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _textView.editable = NO;
        _textView.font = [UIFont fontWithName:@"Courier" size:[UIFont systemFontSize] + 1];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _scrollView  = [[UIScrollView alloc]initWithFrame:self.bounds];
        _scrollView.contentSize = self.bounds.size;
        _textView = [[UITextView alloc]initWithFrame:self.bounds];
        [_scrollView addSubview:_textView];
        _scrollView.backgroundColor = [UIColor redColor];
        [self addSubview:_scrollView];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handlePrintNotification:) name:kPrintNotificationChannel object:nil];
        _textView.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1];
        //_textView.backgroundColor = [UIColor blueColor];
        UIEdgeInsets insets = _textView.textContainerInset;
        insets.left = 10;
        insets.right = 10;
        insets.bottom = 10;
        insets.top = 10;
        _textView.textContainerInset = insets;
        /*
        _textView.autoresizingMask = UIViewAutoresizingFlexibleHeight&UIViewAutoresizingFlexibleWidth;
         */
        _textView.layer.borderWidth = 1;
        _textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _textView.editable = NO;
        //_textView.font = [UIFont fontWithName:@"Courier" size:[UIFont systemFontSize]];
        
        _textView.font = [UIFont fontWithName:@"Courier" size:[UIFont systemFontSize] + 1];
        [self configureConstraints];
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
    [[NSOperationQueue mainQueue]addOperationWithBlock:^{
        [self updateTextView:self.textView andScrollView:self.scrollView withText:toDisplay];
    }];
    
}

- (void)updateTextView:(UITextView *)textView andScrollView:(UIScrollView *)scrollview withText:(NSString *)text
{
    CGFloat height = [self heightForText:text];
    NSLog(@"height for text: %@",@(height));
    textView.text = text;
    CGSize size = scrollview.contentSize;
    NSLayoutConstraint *constraint = nil;
    size.height = height;
    scrollview.contentSize = size;
    constraint = [NSLayoutConstraint
                  constraintWithItem:self.textView
                  attribute:NSLayoutAttributeHeight
                  relatedBy:NSLayoutRelationEqual
                  toItem:self.scrollView
                  attribute:NSLayoutAttributeHeight
                  multiplier:0
                  constant:height];
    self.textViewHeightConstraint = constraint;
    [self setNeedsLayout];
    
}

- (void)configureConstraints
{
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *constraint = nil;
    
    constraint = [NSLayoutConstraint
                  constraintWithItem:self.textView
                  attribute:NSLayoutAttributeTop
                  relatedBy:NSLayoutRelationEqual
                  toItem:self.scrollView
                  attribute:NSLayoutAttributeTop
                  multiplier:1.0
                  constant:0.0];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint
                  constraintWithItem:self.textView
                  attribute:NSLayoutAttributeLeading
                  relatedBy:NSLayoutRelationEqual
                  toItem:self.scrollView
                  attribute:NSLayoutAttributeLeading
                  multiplier:1.0
                  constant:0.0];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint
                  constraintWithItem:self.textView
                  attribute:NSLayoutAttributeTrailing
                  relatedBy:NSLayoutRelationEqual
                  toItem:self.scrollView
                  attribute:NSLayoutAttributeTrailing
                  multiplier:1.0
                  constant:0.0];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint
                  constraintWithItem:self.textView
                  attribute:NSLayoutAttributeWidth
                  relatedBy:NSLayoutRelationEqual
                  toItem:self.scrollView
                  attribute:NSLayoutAttributeWidth
                  multiplier:1.0
                  constant:0.0];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint
                  constraintWithItem:self.scrollView
                  attribute:NSLayoutAttributeBottom
                  relatedBy:NSLayoutRelationEqual
                  toItem:self
                  attribute:NSLayoutAttributeBottom
                  multiplier:1.0
                  constant:0.0];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint
                  constraintWithItem:self.scrollView
                  attribute:NSLayoutAttributeTop
                  relatedBy:NSLayoutRelationEqual
                  toItem:self
                  attribute:NSLayoutAttributeTop
                  multiplier:1.0
                  constant:0.0];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint
                  constraintWithItem:self.scrollView
                  attribute:NSLayoutAttributeLeading
                  relatedBy:NSLayoutRelationEqual
                  toItem:self
                  attribute:NSLayoutAttributeLeading
                  multiplier:1.0
                  constant:0.0];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint
                  constraintWithItem:self.scrollView
                  attribute:NSLayoutAttributeTrailing
                  relatedBy:NSLayoutRelationEqual
                  toItem:self
                  attribute:NSLayoutAttributeTrailing
                  multiplier:1.0
                  constant:0.0];
    [self addConstraint:constraint];
    
    
    self.textViewHeightConstraint = [NSLayoutConstraint
                                     constraintWithItem:self.textView
                                     attribute:NSLayoutAttributeHeight
                                     relatedBy:NSLayoutRelationEqual
                                     toItem:self.scrollView
                                     attribute:NSLayoutAttributeHeight
                                     multiplier:1.0
                                     constant:0.0];
    [self addConstraint:self.textViewHeightConstraint];
    
}

- (CGFloat)heightForText:(NSString *)text
{
    UITextView *textView = [[UITextView alloc]initWithFrame:self.bounds];
    textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    UIEdgeInsets insets = _textView.textContainerInset;
    insets.left = 10;
    insets.right = 10;
    insets.bottom = 10;
    insets.top = 10;
    textView.textContainerInset = insets;
    textView.font = [UIFont fontWithName:@"Courier" size:[UIFont systemFontSize] + 1];
    textView.text = text;
    [textView sizeToFit];
    return textView.frame.size.height;
}

- (void)dealloc
{
   [[NSNotificationCenter defaultCenter]removeObserver:self name:kPrintNotificationChannel object:nil];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
