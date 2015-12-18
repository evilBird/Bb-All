//
//  BbObjectView.h
//  Pods
//
//  Created by Travis Henspeter on 12/17/15.
//
//

#import <UIKit/UIKit.h>
#import "BbTouchView.h"

@protocol BbObjectView <NSObject>

@end

@protocol BbObjectViewDelegate <NSObject>

- (BOOL)canvasIsEditing;

@end

@class BSDObject;

@interface BbObjectView : UIView

@property (nonatomic,weak)          BSDObject                           *object;
@property (nonatomic,weak)          id<BbObjectViewDelegate>            delegate;

- (instancetype)initWithObject:(BSDObject *)object delegate:(id<BbObjectViewDelegate>)delegate;
- (void)setupLayout;

@end
