//
//  BSDBox.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/12/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDBox.h"
#import "BSDPortView.h"
#import "BSDPortConnection.h"
#import <QuartzCore/QuartzCore.h>
#import "BSDObjectDescription.h"
#import "BSDCanvas.h"

@interface BSDBox ()

@property (nonatomic,strong)UILongPressGestureRecognizer *longPress;

@end

@implementation BSDBox

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:_panGesture];
        kAllowEdit = YES;
        self.clipsToBounds = NO;
        self.defaultColor = [UIColor colorWithWhite:0.21 alpha:1];
        self.selectedColor = [UIColor colorWithWhite:0.6 alpha:1];
        _currentColor = self.defaultColor;
        self.backgroundColor = _currentColor;
        self.layer.borderWidth = 1.0f;
        self.layer.borderColor = self.defaultColor.CGColor;
        [self setSelected:NO];
        
        _longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
        _longPress.delegate = self;
        _longPress.minimumPressDuration = 1.0;
        _longPress.allowableMovement = 20;
        [self addGestureRecognizer:_longPress];
    }
    
    return self;
}

- (void)handleLongPress:(id)sender
{
    UIGestureRecognizerState state = [(UILongPressGestureRecognizer *)sender state];
    if (state == UIGestureRecognizerStateBegan) {
        [self editingRequested];
    }
    
}

- (void)editingRequested
{
    
}

- (instancetype)initWithDescription:(BSDObjectDescription *)desc
{
    CGRect frame = desc.displayRect.CGRectValue;
    self = [self initWithFrame:frame];
    if (self) {
        
        self.assignedId = desc.uniqueId;
        self.className = desc.className;
        self.creationArguments = desc.creationArguments;
        [self makeObjectInstanceArgs:self.creationArguments];
        
        if ([desc.className isEqualToString:@"BSDMessage"]) {
            if (self.creationArguments != nil) {
                if ([self.creationArguments respondsToSelector:@selector(count)]) {
                    NSInteger count = [self.creationArguments count];
                    if (count == 1) {
                        [[self.object hotInlet]input:@{@"set":[self.creationArguments firstObject]}];
                    }else{
                        [[self.object hotInlet]input:@{@"set":self.creationArguments}];
                    }
                }
            }
            
        }else if ([desc.boxClassName isEqualToString:@"BSDCommentBox"]){
            
            if (self.creationArguments != nil) {
                //NSLog(@"comment box has creations args: %@",self.creationArguments);
                NSArray *arr = self.creationArguments;
                if (arr && [arr isKindOfClass:[NSArray class]]) {
                    NSString *comment = arr.firstObject;
                    [self setValue:comment forKeyPath:@"textField.text"];
                }
            }
        }
    }
    
    return self;
}

- (void)makeConnectionWithDescription:(BSDPortConnectionDescription *)description
{
    if (self.object == NULL || description== nil ) {
        return;
    }
    BSDBox *rb = (BSDBox *)description.receiverPortView.delegate;
    BSDInlet *inlet = (BSDInlet *)[[rb object]inletNamed:description.receiverPortName];
    BSDOutlet *myOutlet = (BSDOutlet *)[self.object outletNamed:description.senderPortName];
    [myOutlet connectToInlet:inlet];
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    if (selected) {
        self.currentColor = self.selectedColor;
    }else{
        self.currentColor = self.defaultColor;
    }
}

- (void)setCurrentColor:(UIColor *)currentColor
{
    _currentColor = currentColor;
    self.backgroundColor = _currentColor;
    
}

- (NSArray *)inlets
{
    if (self.object == NULL) {
        return nil;
    }
    
    NSArray *inlets = [self.object inlets];
    CGRect bounds = self.bounds;
    CGRect frame;
    frame.size.height = 14;
    frame.size.width = 24;

    frame.origin.y = 0;
    CGFloat step = 0;
    if (inlets.count > 1) {
        step = (bounds.size.width - frame.size.width)/(CGFloat)((inlets.count) - 1);
    }
    NSInteger idx = 0;
    NSMutableArray *result = [NSMutableArray array];
    for (BSDInlet *inlet in inlets) {
        frame.origin.x = (CGFloat)idx * step;
        NSString *portName = [NSString stringWithFormat:@"%@-%@",self.className,inlet.name];
        BSDPortView *portView = [self inletViewWithName:portName];
        if (!portView) {
            portView = [[BSDPortView alloc]initWithName:portName delegate:self];
            portView.portName = inlet.name;
            [self addSubview:portView];
        }
        portView.tag = idx;
        portView.frame = frame;
        [result addObject:portView];
        idx ++;
    }
    
    return result;
}

- (NSArray *)outlets
{
    if (self.object == NULL) {
        return nil;
    }
    
    NSArray *outlets = [self.object outlets];
    CGRect bounds = self.bounds;
    CGRect frame;
    frame.size.width = 24;
    frame.size.height = 14;
    frame.origin.y = bounds.size.height - frame.size.height;
    CGFloat step = 0;
    if (outlets.count > 1) {
        step = (bounds.size.width - frame.size.width)/(CGFloat)((outlets.count) - 1);
    }
    NSInteger idx = 0;
    NSMutableArray *result = [NSMutableArray array];
    for (BSDOutlet *outlet in outlets) {
        frame.origin.x = (CGFloat)idx * step;
        NSString *portName = [NSString stringWithFormat:@"%@-%@",self.className,outlet.name];
        BSDPortView *portView = [self outletViewWithName:portName];
        if (!portView) {
            portView = [[BSDPortView alloc]initWithName:portName delegate:self];
            portView.portName = outlet.name;
            [self addSubview:portView];
        }
        portView.frame = frame;
        portView.tag = idx;
        [result addObject:portView];
        idx ++;
    }
    
    return result;
}

- (BSDPortView *)inletViewWithName:(NSString *)name
{
    if (!name || !self.inletViews) {
        return nil;
    }
    
    for (BSDPortView *inletView in self.inletViews) {
        if ([inletView.portName isEqualToString:name]) {
            return inletView;
        }
    }
    return nil;
}

- (BSDPortView *)outletViewWithName:(NSString *)name
{
    if (!name || !self.outletViews) {
        return nil;
    }
    
    for (BSDPortView *outletView in self.outletViews) {
        if ([outletView.portName isEqualToString:name]) {
            return outletView;
        }
    }
    
    return nil;
}

- (void)updateInletViews
{
    self.inletViews = [self inlets].mutableCopy;
}

- (void)updateOutletViews
{
    self.outletViews = [self outlets].mutableCopy;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)handlePan:(id)sender
{
    static CGPoint initLoc;
    static CGPoint initCenter;
    UIPanGestureRecognizer *recognizer = sender;
    CGPoint loc = [recognizer locationInView:self.superview];
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        initLoc = loc;
        initCenter = self.center;
        self.translation = nil;
    }
    
    if (selectedPort == nil) {
        __weak BSDBox *weakself = self;
        [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            CGFloat dx = loc.x - initLoc.x;
            CGFloat dy = loc.y - initLoc.y;
            CGPoint trans = CGPointMake(dx, dy);
            self.translation = [NSValue valueWithCGPoint:trans];
            CGPoint newCenter;
            newCenter.x = initCenter.x + dx;
            newCenter.y = initCenter.y + dy;
            weakself.center = newCenter;
            [weakself.delegate boxDidMove:self];
        }];

    }else{
        
        switch (recognizer.state) {
            case UIGestureRecognizerStateBegan:
            {
                
            }
                break;
            case UIGestureRecognizerStateChanged:
            {
                __weak BSDBox *weakself = self;
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                    [weakself.delegate box:weakself portView:selectedPort drawLineToPoint:loc];
                }];
            }
                break;
            case UIGestureRecognizerStateEnded:
            {
                __weak BSDBox *weakself = self;
                [[NSOperationQueue mainQueue]addOperationWithBlock:^{
                    [weakself.delegate box:weakself portView:selectedPort endedAtPoint:loc];
                }];
            }
                break;
                
            default:
                break;
        }
        
    }
}


- (NSString *)parentClass
{
    return self.className;
}

- (NSString *)parentId
{
    if (self.assignedId) {
        return self.assignedId;
    }
    
    return [self uniqueId];
}

- (NSString *)uniqueId
{
    if (self.assignedId) {
        return self.assignedId;
    }
    
    return [NSString stringWithFormat:@"%p",self];
}

- (NSArray *)connections
{
    NSMutableArray *temp = [NSMutableArray array];
    NSMutableArray *portviews = [NSMutableArray array];
    [portviews addObjectsFromArray:self.outletViews];
    for (BSDPortView *portView in self.outletViews) {
        if (portView.connectedPortViews.count > 0) {
            
            for (BSDPortView *connectedPortView in portView.connectedPortViews) {
                UIView *superview = connectedPortView.superview;
                if (superview) {
                    
                    BSDPortConnection *connection = [BSDPortConnection connectionWithOwner:portView target:connectedPortView];
                    [temp addObject:connection];
                }else{
                    [portView.connectedPortViews removeObject:connectedPortView];
                }

            }
        }
    }
    
    return temp;
}

- (NSArray *)connectionVectors
{
    NSMutableArray *temp = [NSMutableArray array];
    for (BSDPortView *portView in self.outletViews) {
        if (portView.connectedPortViews.count > 0) {
            
            for (BSDPortView *connectedPortView in portView.connectedPortViews) {
                UIView *superview = connectedPortView.superview;
                if (superview) {
                    
                    CGPoint o = portView.center;
                    CGPoint d = connectedPortView.center;
                    CGPoint ao = [self.superview convertPoint:o fromView:portView.superview];
                    CGPoint ad = [self.superview convertPoint:d fromView:connectedPortView.superview];
                    NSArray *points = @[[NSValue valueWithCGPoint:ao],[NSValue valueWithCGPoint:ad]];
                    NSDictionary *portviews = @{@"sender":portView,
                                                @"receiver":connectedPortView
                                                };
                    
                    NSDictionary *vec = @{@"points":points,
                                          @"ports":portviews
                                          };
                    [temp addObject:vec];
                }else{
                    id obj1 = self.object;
                    id obj2 = [(BSDBox *)connectedPortView.delegate object];
                    BSDOutlet *outlet = [obj1 outletNamed:portView.portName];
                    BSDInlet *inlet = [obj2 inletNamed:connectedPortView.portName];
                    [outlet disconnectFromInlet:inlet];
                    [portView.connectedPortViews removeObject:connectedPortView];
                    NSLog(@"connected portview has no superview");
                }
            }
        }
    }
    
    return temp;
}

- (void)connectOutlet:(NSInteger)outletIndex toInlet:(NSInteger)inletIndex inBox:(BSDBox *)box
{
    BSDObject *sender = self.object;
    BSDOutlet *outlet = sender.outlets[outletIndex];
    BSDObject *receiver = box.object;
    BSDInlet *inlet = receiver.inlets[inletIndex];
    BSDPortView *senderPortView = self.outletViews[outletIndex];
    BSDPortView *receiverPortView = box.inletViews[inletIndex];
    [outlet connectToInlet:inlet];
    [senderPortView addConnectionToPortView:receiverPortView];
}

- (void)setSelectedPortView:(BSDPortView *)portview
{
    if (portview == nil) {
        if (selectedPort) {
            selectedPort.selected = NO;
        }
        
        selectedPort = nil;
    }else{
        
        if (selectedPort) {
            selectedPort.selected = NO;
        }
        
        selectedPort = portview;
        selectedPort.selected = YES;
    }
}

- (void)tapInPortView:(id)sender
{
    BSDPortView *newPort = sender;
    
    if (newPort.isSelected) {
        if (selectedPort) {
            selectedPort.selected = NO;
        }
        
        selectedPort = newPort;
        
    }else{
        
        if (selectedPort) {
            selectedPort.selected = NO;
        }
        
        selectedPort = nil;
    }
}

- (void)makeObjectInstance
{
    [self makeObjectInstanceArgs:NULL];
}

- (void)makeObjectInstanceArgs:(id)args
{
    if (!self.className || [self.className isEqualToString:@"(null)"]) {
        return;
    }
    
    const char *class = [self.className UTF8String];
    id c = objc_getClass(class);
    id instance = [c alloc];
    SEL aSelector = NSSelectorFromString(@"initWithArguments:");
    if (![instance respondsToSelector:aSelector]) {
        return;
    }
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[c instanceMethodSignatureForSelector:aSelector]];
    invocation.target = instance;
    invocation.selector = aSelector;
    
    if (args && ![args isKindOfClass:[NSArray class]]) {
        id a = args;
        args = [NSArray arrayWithObject:a];
    }
    
    if (args != NULL) {
        NSArray *a = args;
        if (a.count == 1) {
            id arg = a.firstObject;
            [invocation setArgument:&arg atIndex:2];
        }else{
            
            [invocation setArgument:&a atIndex:2];
        }
    }
    
    [invocation invoke];
    self.object = instance;
    NSString *notificationName = [NSString stringWithFormat:@"BSDBox%@ValueShouldChangeNotification",[self.object objectId]];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleObjectValueShouldChangeNotification:) name:notificationName object:nil];
}

- (NSString *)boxClassName
{
    return NSStringFromClass([self class]);
}

- (id)objectDescription
{
    BSDObjectDescription *desc = [[BSDObjectDescription alloc]init];
    desc.className = self.className;
    desc.boxClassName = [self boxClassName];
    desc.uniqueId = self.uniqueId;
    desc.creationArguments = self.creationArguments;
    desc.displayRect = [NSValue valueWithCGRect:self.frame];
    return desc;
}

- (id)makeCreationArgs
{
    return self.creationArguments;
}

- (NSArray *)connectionDescriptions
{
    NSMutableArray *result = nil;
    
    for (BSDPortView *outletView in self.outletViews) {
        NSArray *connectedInletViews = outletView.connectedPortViews;
        for (BSDPortView *inletView in connectedInletViews) {
            BSDPortConnectionDescription *desc = [[BSDPortConnectionDescription alloc]init];
            desc.senderPortName = [outletView portName];
            desc.senderParentId = [outletView.delegate parentId];
            desc.receiverPortName = [inletView portName];
            desc.receiverParentId = [inletView.delegate parentId];
            BSDPortConnection *connection = [BSDPortConnection connectionWithOwner:outletView target:inletView];
            CGPoint o = [connection origin];
            CGPoint d = [connection destination];
            CGPoint ao = [self.superview convertPoint:o fromView:outletView.superview];
            CGPoint ad = [self.superview convertPoint:d fromView:inletView.superview];
            NSArray *points = @[[NSValue valueWithCGPoint:ao],[NSValue valueWithCGPoint:ad]];
            desc.initialPoints = points;
            if (!result) {
                result = [NSMutableArray array];
            }
            
            [result addObject:[desc dictionaryRespresentation]];
        }
    }
    
    return result;
}

- (CGSize)minimumSize
{
    CGSize size;
    size.height = self.bounds.size.height;
    CGFloat multiplier = 3;
    if (self.object) {
        CGFloat i = [self.object inlets].count;
        CGFloat o = [self.object outlets].count;
        
        if (i > 3 && i > o) {
            multiplier = i + ((i - 1) * 0.1);
        }
        if (o > 3 && o > i) {
            multiplier = o + ((o - 1) * 0.1);
        }
    }
    
    size.width = multiplier * 24;
    return size;
}

- (void)handleObjectValueShouldChangeNotification:(NSNotification *)notification
{

}

- (UIView *)superviewForCompiledPatch:(id)sender
{
    return [self.delegate displayViewForBox:self];
}

- (CALayer *)superlayerForCompiledPatch:(id)sender
{
    return [self.delegate displayViewForBox:self].layer;
}

- (void)tearDown
{
    for (BSDPortView *inletView in self.inletViews) {
        [inletView removeFromSuperview];
        [inletView tearDown];
        [[NSNotificationCenter defaultCenter]removeObserver:inletView];
    }
    for (BSDPortView *outletView in self.outletViews) {
        [outletView tearDown];
        [outletView removeFromSuperview];
    }
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.object tearDown];
    self.object = nil;
    self.inletViews = nil;
    self.outletViews = nil;
    self.delegate = nil;
    self.creationArguments = nil;
}

- (void)initializeWithText:(NSString *)text
{
    [self makeObjectInstance];
    [self createPortViewsForObject:self.object];
}

- (void)createPortViewsForObject:(id)object
{
    NSArray *inletViews = [self inlets];
    self.inletViews = [NSMutableArray arrayWithArray:inletViews];
    NSArray *outletViews = [self outlets];
    self.outletViews = [NSMutableArray arrayWithArray:outletViews];
}

- (NSString *)getDescription
{
    return nil;
}

- (void)dealloc
{
    [self tearDown];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
