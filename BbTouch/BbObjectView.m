//
//  BbObjectView.m
//  Pods
//
//  Created by Travis Henspeter on 12/17/15.
//
//

#import "BbObjectView.h"
#import "BSDObject.h"
#import "UIView+Layout.h"
#import "UIView+PortViews.h"

@interface BbObjectView ()

@property (nonatomic,strong)            UILabel             *label;
@property (nonatomic,strong)            NSMutableArray      *inletViews;
@property (nonatomic,strong)            NSMutableArray      *outletViews;

@end

@implementation BbObjectView

- (instancetype)initWithObject:(BSDObject *)object delegate:(id<BbObjectViewDelegate>)delegate
{
    self = [super initWithFrame:CGRectZero];
    if ( self ) {
        _object = object;
        _delegate = delegate;
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.backgroundColor = [UIColor blackColor];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.label = [UILabel new];
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    self.label.textColor = [UIColor whiteColor];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.text = self.object.name;
    [self addSubview:self.label];
}

- (void)setupLayout
{
    NSDictionary *inlets = [UIView createPortViews:self.object.inlets.count];
    
    [self addConstraint:[self pinEdge:LayoutEdge_Top toEdge:LayoutEdge_Top ofView:self.label withInset:-30]];
    [self addConstraint:[self pinEdge:LayoutEdge_Bottom toEdge:LayoutEdge_Bottom ofView:self.label withInset:30]];
    
    if ( nil != inlets ) {
        self.inletViews = inlets[kPortViewsKey];
        [self addAndLayoutInletViews:inlets];
    }
    
    NSDictionary *outlets = [UIView createPortViews:self.object.outlets.count];
    if ( nil != outlets ) {
        self.outletViews = outlets[kPortViewsKey];
        [self addAndLayoutOutletViews:outlets];
    }
    
    [self addConstraint:[self.label alignCenterXToSuperOffset:0.0]];
    [self addConstraint:[self.label alignCenterYToSuperOffset:0.0]];
    
}

#pragma mark - BbTouchView

- (NSUInteger)canRecognizeGesture:(BbGestureType)gesture givenTouchPhase:(NSUInteger)touchPhase
{
    NSUInteger result;
    switch (gesture) {
        case BbGestureType_Tap:
        case BbGestureType_LongPress:
        case BbGestureType_Pan:
            result = 1;
            break;
            
        default:
            result = 0;
            break;
    }
    return 0;
}

- (NSUInteger)canRecognizeGesture:(BbGestureType)gesture givenCanvasEditingState:(NSUInteger)editingState
{
    NSUInteger result;
    switch (gesture) {
        case BbGestureType_LongPress:
            result = ( editingState == 0 ) ? 1 : 0;
            break;
            
        default:
            result = 1;
            break;
    }
    
    return 1;
}

- (NSUInteger)canRecognizeGesture:(BbGestureType)gesture givenGestureRepeatCount:(NSUInteger)repeatCount
{
    return 1;
}

- (NSUInteger)canRecognizeGesture:(BbGestureType)gesture givenOutletIsActiveInCanvas:(BOOL)outletIsActive{
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
