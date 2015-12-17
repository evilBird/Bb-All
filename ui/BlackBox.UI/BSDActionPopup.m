//
//  BSDActionPopup.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 11/11/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#define kButtonWidth 66
#define kButtonHeight 33
#define kCornerRadius 5
#define kTailHeight 10
#define kHorizontalPadding 4
#define kVerticalPadding 4

#import "BSDActionPopup.h"

typedef void(^BSDActionPopupCompletionBlock)(NSInteger);

@interface BSDActionPopup ()

@property (nonatomic,strong) UIView *associatedView;
@property (nonatomic,strong) BSDActionPopupCompletionBlock completionBlock;

@end

@implementation BSDActionPopup

+ (BSDActionPopup *)showPopupWithActions:(NSArray *)actions inSuperview:(UIView *)superview anchorPoint:(CGPoint)point completion:(void(^)(NSInteger selectedIndex))completion
{
    if (!actions) {
        return nil;
    }
    
    NSArray *possibleActions = @[@"open",@"help",@"test",@"cancel"];

    CGRect frame;
    frame.size.width = kButtonWidth * possibleActions.count + kHorizontalPadding * (possibleActions.count + 1);
    frame.size.height = kButtonHeight + kVerticalPadding * 2 + kTailHeight;
    frame.origin.x = point.x - frame.size.width/2;
    frame.origin.y = point.y - frame.size.height - kTailHeight;
    BSDActionPopup *popup = [[BSDActionPopup alloc]initWithFrame:frame];
    popup.clipsToBounds = NO;
    popup.backgroundColor = [UIColor clearColor];
    for (NSUInteger index = 0; index < possibleActions.count; index++) {
        CGRect buttonRect;
        NSString *actionName = possibleActions[index];
        buttonRect.origin.x = kHorizontalPadding * (index + 1) + kButtonWidth * index;
        buttonRect.origin.y = kVerticalPadding;
        buttonRect.size.width = kButtonWidth;
        buttonRect.size.height = kButtonHeight;
        UIButton *actionButton = [[UIButton alloc]initWithFrame:buttonRect];
        actionButton.tag = index;
        [actionButton setTitle:actionName forState:UIControlStateNormal];
        [actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [actionButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [actionButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
        [actionButton setBackgroundColor:[UIColor clearColor]];
        if ([actions containsObject:actionName]) {
            actionButton.enabled = YES;
            [actionButton addTarget:popup action:@selector(handleSelection:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            actionButton.enabled = NO;
        }
        [popup addSubview:actionButton];
    }
    
    popup.completionBlock = completion;
    [popup setNeedsDisplay];
    [superview addSubview:popup];
    return popup;
}

+ (BSDActionPopup *)showPopupWithActions:(NSArray *)actions associatedView:(UIView *)associatedView anchorPoint:(CGPoint)point completion:(void(^)(NSInteger selectedIndex))completion
{
    if (!actions) {
        return nil;
    }
    
    NSArray *possibleActions = @[@"open",@"help",@"test",@"cancel"];
    
    CGRect frame;
    frame.size.width = kButtonWidth * possibleActions.count + kHorizontalPadding * (possibleActions.count + 1);
    frame.size.height = kButtonHeight + kVerticalPadding * 2 + kTailHeight;
    frame.origin.x = point.x - frame.size.width/2;
    frame.origin.y = point.y - frame.size.height - kTailHeight;
    BSDActionPopup *popup = [[BSDActionPopup alloc]initWithFrame:frame];
    popup.clipsToBounds = NO;
    popup.backgroundColor = [UIColor clearColor];
    for (NSUInteger index = 0; index < possibleActions.count; index++) {
        CGRect buttonRect;
        NSString *actionName = possibleActions[index];
        buttonRect.origin.x = kHorizontalPadding * (index + 1) + kButtonWidth * index;
        buttonRect.origin.y = kVerticalPadding;
        buttonRect.size.width = kButtonWidth;
        buttonRect.size.height = kButtonHeight;
        UIButton *actionButton = [[UIButton alloc]initWithFrame:buttonRect];
        actionButton.tag = index;
        [actionButton setTitle:actionName forState:UIControlStateNormal];
        [actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [actionButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [actionButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
        [actionButton setBackgroundColor:[UIColor clearColor]];
        if ([actions containsObject:actionName]) {
            actionButton.enabled = YES;
            [actionButton addTarget:popup action:@selector(handleSelection:) forControlEvents:UIControlEventTouchUpInside];
        }else{

            actionButton.enabled = NO;
        }
        [popup addSubview:actionButton];
    }
    
    popup.completionBlock = completion;
    [popup setNeedsDisplay];
    [associatedView.superview addSubview:popup];
    popup.associatedView = associatedView;
    return popup;
}

- (void)setAssociatedView:(UIView *)associatedView
{
    _associatedView = associatedView;
    [associatedView addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)handleSelection:(id)sender
{
    UIButton *button = sender;
    NSInteger selectedIndex = button.tag;
    button.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1];
    self.completionBlock(selectedIndex);
    __weak BSDActionPopup *weakself = self;
    [UIView animateWithDuration:0.2
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         weakself.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                             [weakself removeFromSuperview];
                         });
                     }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == nil) {
        
        [object removeObserver:self forKeyPath:keyPath];
        [self removeFromSuperview];
        self.associatedView = nil;

    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGRect mainRect = self.bounds;
    mainRect.size.height -= kTailHeight;
    UIBezierPath *mainPath = [UIBezierPath bezierPathWithRoundedRect:mainRect cornerRadius:kCornerRadius];
    UIBezierPath *tailPath = [UIBezierPath bezierPath];
    CGPoint point;
    point.x = CGRectGetMidX(mainRect) - 4;
    point.y = CGRectGetMaxY(mainRect);
    [tailPath moveToPoint:point];
    point.x = CGRectGetMidX(mainRect) + 4;
    [tailPath addLineToPoint:point];
    point.y += kTailHeight;
    point.x -= 4;
    [tailPath addLineToPoint:point];
    [tailPath closePath];
    
    [[UIColor blackColor]setFill];
    [mainPath fill];
    [tailPath fill];
}

- (void)dealloc
{
    [self.associatedView removeObserver:self forKeyPath:@"center"];
    [self removeFromSuperview];
    self.associatedView = nil;
}

@end
