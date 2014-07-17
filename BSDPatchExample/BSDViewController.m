//
//  BSDViewController.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/14/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDViewController.h"
#import "BSDPatch.h"
#import "BSDTestVariable.h"

@interface BSDViewController ()

@property(nonatomic,strong)BSDDistance2D *distance;

@property(nonatomic,strong)UILabel *label1;
@property(nonatomic,strong)UILabel *label2;
@property(nonatomic,strong)UILabel *label3;
@property(nonatomic,strong)UIPanGestureRecognizer *gestureRecognizer;

@end

@implementation BSDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //Configure the BSDObjects
    //distance object will measure the distance between touches in the view
    self.distance = [BSDCreate distance2D];
    
    //Set up our labels, which will display the output from the BSDObjects
    [self addLabels];

    //Set up our gesture recognizer, which will feed input to the distance object
    self.view.multipleTouchEnabled = YES;
    
    __weak BSDViewController *WEAK_SELF = self;
    self.distance.mainOutlet.outputBlock = ^(BSDObject *object, BSDOutlet *outlet){
        WEAK_SELF.label1.text = [outlet.value stringValue];
    };

    [self test];

}
- (void)test
{
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self handleTouches:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self handleTouches:touches];
}

- (void)handleTouches:(NSSet *)touches
{
    //Feed the BSDDistance object, which takes an array in the hot inlet. The array consists of a selector(String) and a value. In this case, the strings "xf" and yf" refer to the x and y values, respectively, of the touch location. These strings are used internally by BSDDistance to appropriately route the values.
    
    if (touches.count == 2) {
        //Set a reference point for BSDDistance object, from which distance will be measured
        CGPoint ref = [touches.allObjects[0] locationInView:self.view];
        [self.distance.hotInlet input:@[@"x0",@(ref.x)]];
        [self.distance.hotInlet input:@[@"y0",@(ref.y)]];
        CGPoint pt = [touches.allObjects[1] locationInView:self.view];
        [self.distance.hotInlet input:@[@"xf",@(pt.x)]];
        [self.distance.hotInlet input:@[@"yf",@(pt.y)]];
    }
}

#pragma mark - Convenience methods

- (void)indicateSignificance:(BOOL)significant
{
    if (significant) {
        self.view.backgroundColor = [UIColor blueColor];
    }else{
        self.view.backgroundColor = [UIColor whiteColor];
    }
}

- (void)addLabels
{
    CGPoint origin = self.view.bounds.origin;
    self.label1 = [self newLabelWithOrigin:origin];
    [self.view addSubview:self.label1];
    origin.y = CGRectGetMaxY(self.label1.frame);
    self.label2 = [self newLabelWithOrigin:origin];
    [self.view addSubview:self.label2];
    origin.y = CGRectGetMaxY(self.label2.frame);
    self.label3 = [self newLabelWithOrigin:origin];
    [self.view addSubview:self.label3];
}

- (UILabel *)newLabelWithOrigin:(CGPoint)origin
{
    CGRect frame;
    frame.origin = origin;
    frame.size.width = CGRectGetWidth(self.view.bounds);
    frame.size.height = CGRectGetHeight(self.view.bounds)/3;
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 2;
    return label;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
