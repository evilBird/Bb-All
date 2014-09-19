//
//  BSDNumberBox.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/12/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDNumberBox.h"
#import "BSDBang.h"

@implementation BSDNumberBox

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.className = @"BSDNumber";
        [self makeObjectInstance];
        NSArray *inletViews = [self inlets];
        self.inletViews = [NSMutableArray arrayWithArray:inletViews];
        NSArray *outletViews = [self outlets];
        self.outletViews = [NSMutableArray arrayWithArray:outletViews];
        _stepper = [[UIStepper alloc]init];
        _stepper.tintColor = [UIColor whiteColor];
        _stepper.minimumValue = -1e10;
        _stepper.maximumValue = 1e10;
        CGRect frame = _stepper.frame;
        frame.origin.y = CGRectGetMaxY(self.bounds) - frame.size.height - 5;
        frame.origin.x = (CGRectGetWidth(self.bounds) - frame.size.width)/2 + 9;
        _stepper.frame = frame;
        [_stepper addTarget:self action:@selector(stepperValueDidChange:) forControlEvents:UIControlEventValueChanged];
        [self insertSubview:_stepper atIndex:0];
        NSString *notificationName = [NSString stringWithFormat:@"BSDBox%@ValueShouldChangeNotification",[self uniqueId]];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleObjectValueShouldChangeNotification:) name:notificationName object:nil];
        [_stepper setBackgroundImage:self.emptyImageForStepper forState:UIControlStateNormal];
        [_stepper setBackgroundImage:self.emptyImageForStepper forState:UIControlStateHighlighted];

        _label = [[UILabel alloc]initWithFrame:frame];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.text = [NSString stringWithFormat:@"%@",@(0)];
        _label.textColor = self.backgroundColor;
        frame = _label.frame;
        frame.origin.y -= frame.size.height + 10;
        _label.frame = frame;
        [self insertSubview:_label belowSubview:_stepper];
        [self setSelected:NO];

    }
    
    return self;
}
/*
- (NSArray *)inlets
{
    CGRect bounds = self.bounds;
    CGRect frame;
    frame.origin = bounds.origin;
    frame.size.width = bounds.size.width * 0.25;
    frame.size.height = bounds.size.height * 0.35;
    BSDPortView *hotInletView = [[BSDPortView alloc]initWithName:@"hot" delegate:self];
    hotInletView.frame = frame;
    [self addSubview:hotInletView];
    return @[hotInletView];
}

- (NSArray *)outlets
{
    CGRect bounds = self.bounds;
    CGRect frame;
    frame.origin = bounds.origin;
    frame.size.width = bounds.size.width * 0.25;
    frame.size.height = bounds.size.height * 0.35;
    BSDPortView *mainOutletView = [[BSDPortView alloc]initWithName:@"main" delegate:self];
    frame.origin.x = 0;
    frame.origin.y = bounds.size.height - frame.size.height;
    mainOutletView.frame = frame;
    [self addSubview:mainOutletView];
    return @[mainOutletView];
}
*/
- (void)senderValueChanged:(id)value
{
    self.label.text = [NSString stringWithFormat:@"%@",value];
    //[[self.object hotInlet]input:value];
    //[[self.object outletNamed:@"main"]setValue:value];
}

- (void)stepperValueDidChange:(id)sender
{
    UIStepper *stepper = sender;
    self.label.text = [NSString stringWithFormat:@"%@",@(stepper.value)];
    [[self.object hotInlet]input:@(stepper.value)];
    //[[self.object inletNamed:@"cold"]input:@(stepper.value)];
    //[[self.object inletNamed:@"hot"]input:[BSDBang bang]];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [_stepper setBackgroundImage:self.emptyImageForStepper forState:UIControlStateNormal];
    [_stepper setBackgroundImage:self.emptyImageForStepper forState:UIControlStateHighlighted];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)handleObjectValueShouldChangeNotification:(NSNotification *)notification
{
    NSDictionary *changeInfo = notification.object;
    NSNumber *val = changeInfo[@"value"];
    if (val) {
        NSLog(@"stepper value should change to %@",val);
        self.stepper.value = val.doubleValue;
        self.label.text = [NSString stringWithFormat:@"%@",val];
    }
}

- (UIImage *)emptyImageForStepper
{
    UIGraphicsBeginImageContext(CGSizeMake(1, 1));
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIColor *color = [UIColor clearColor];
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
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
