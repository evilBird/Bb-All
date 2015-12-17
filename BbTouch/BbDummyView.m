//
//  BbDummyView.m
//  Bb Gesture Engine
//
//  Created by Travis Henspeter on 12/15/15.
//  Copyright © 2015 birdSound. All rights reserved.
//

#import "BbDummyView.h"
#import "UIView+Layout.h"
#import "UIView+PortViews.h"

@interface BbDummyView ()

@property (nonatomic,strong)        UILabel     *classLabel;
@property (nonatomic,strong)        UIView      *dummyHotInlet;
@property (nonatomic,strong)        UIView      *dummyColdInlet;
@property (nonatomic,strong)        UIView      *dummyOutlet;

@end

@implementation BbDummyView

- (void)commonInit
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundColor = [UIColor blackColor];
    self.classLabel = [UILabel new];
    self.classLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.classLabel.textAlignment = NSTextAlignmentCenter;
    self.classLabel.textColor = [UIColor whiteColor];
    [self addSubview:self.classLabel];
    self.classLabel.text = self.dummyClass;
    [self.classLabel sizeToFit];
    [self addConstraint:[self pinEdge:LayoutEdge_Top toEdge:LayoutEdge_Top ofView:self.classLabel withInset:-30]];
    [self addConstraint:[self pinEdge:LayoutEdge_Left toEdge:LayoutEdge_Left ofView:self.classLabel withInset:-30]];
    [self addConstraint:[self pinEdge:LayoutEdge_Bottom toEdge:LayoutEdge_Bottom ofView:self.classLabel withInset:30]];
    [self addConstraint:[self pinEdge:LayoutEdge_Right toEdge:LayoutEdge_Right ofView:self.classLabel withInset:30]];
    [self addAndLayoutInletViews:[UIView createPortViews:2]];
    [self addAndLayoutOutletViews:[UIView createPortViews:1]];
    [self layoutIfNeeded];
}

- (instancetype)initWithDummyClass:(NSString *)dummyClass
{
    self = [super init];
    if ( self ) {
        _dummyClass = dummyClass;
        [self commonInit];
    }
    
    return self;
}

- (NSUInteger)canRecognizeGesture:(BbGestureType)gesture givenTouchPhase:(NSUInteger)touchPhase
{
    NSUInteger result;
    switch ( gesture ) {
        case BbGestureType_Tap:
            result = ( touchPhase == 3 ) ? 1 : 0;
            break;
        case BbGestureType_LongPress:
            return 1;
            break;
        case BbGestureType_Pan:
            result = 1;
            break;
            
        default:
            result = 0;
            break;
    }
    
    return result;
}

- (NSUInteger)canRecognizeGesture:(BbGestureType)gesture givenCanvasEditingState:(NSUInteger)editingState
{
    NSUInteger result;
    switch ( gesture ) {
        case BbGestureType_Tap:
            result = 1;
            break;
        case BbGestureType_LongPress:
            result = ( editingState == 0 ) ? 1 : 0;
            break;
        case BbGestureType_Pan:
            result = 1;
            break;
            
        default:
            result = 0;
            break;
    }
    
    return result;
}

- (NSUInteger)canRecognizeGesture:(BbGestureType)gesture givenGestureRepeatCount:(NSUInteger)repeatCount
{
    return 1;
}

- (NSUInteger)canRecognizeGesture:(BbGestureType)gesture givenOutletIsActiveInCanvas:(BOOL)outletIsActive
{
    return 1;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
