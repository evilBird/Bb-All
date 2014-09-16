//
//  BSDColor.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/20/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDColor.h"
#import "BSDObjects.h"

@interface BSDColor ()

@property (nonatomic)CGFloat red;
@property (nonatomic)CGFloat blue;
@property (nonatomic)CGFloat green;
@property (nonatomic)CGFloat alpha;
@property (nonatomic)BSDRoute *route;
@property (nonatomic, strong)BSDValue *redValue;
@property (nonatomic, strong)BSDValue *blueValue;
@property (nonatomic, strong)BSDValue *greenValue;
@property (nonatomic, strong)BSDValue *alphaValue;

@end

@implementation BSDColor

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"color";
    //[self.coldInlet setHot:YES];
    //self.coldInlet.delegate = self;
    
    self.redValue = [[BSDValue alloc]initWithValue:@(0)];
    self.blueValue = [[BSDValue alloc]initWithValue:@(0)];
    self.greenValue = [[BSDValue alloc]initWithValue:@(0)];
    self.alphaValue = [[BSDValue alloc]initWithValue:@(1)];
    self.route = [[BSDRoute alloc]initWithRouteKeys:@[@"red",@"blue",@"green",@"alpha"]];
    [[self.route outletForRouteKey:@"red"]connectToInlet:self.redValue.coldInlet];
    [[self.route outletForRouteKey:@"blue"]connectToInlet:self.blueValue.coldInlet];
    [[self.route outletForRouteKey:@"green"]connectToInlet:self.greenValue.coldInlet];
    [[self.route outletForRouteKey:@"alpha"]connectToInlet:self.alphaValue.coldInlet];
    [self.coldInlet forwardToPort:self.route.hotInlet];
    
    
    NSArray *args = arguments;
    
    if ([args isKindOfClass:[NSArray class]] && args.count == 4) {
     
        [self.redValue.coldInlet input:args[0]];
        [self.blueValue.coldInlet input:args[1]];
        [self.greenValue.coldInlet input:args[2]];
        [self.alphaValue.coldInlet input:args[3]];
        
    }
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.hotInlet) {
        [self calculateOutput];
    }
}

- (void)calculateOutput
{
    self.mainOutlet.value = [self currentColor];
}

- (void)updateColorWithDictionary:(NSDictionary *)dictionary
{
    
    for (NSString *aKey in dictionary.allKeys) {
        if ([aKey isEqualToString:@"red"]) {
            self.red = [dictionary[@"red"]floatValue];
        }else if ([aKey isEqualToString:@"blue"]){
            self.blue = [dictionary[@"blue"]floatValue];
        }else if ([aKey isEqualToString:@"green"]){
            self.green = [dictionary[@"green"]floatValue];
        }else if ([aKey isEqualToString:@"alpha"]){
            self.alpha = [dictionary[@"alpha"]floatValue];
        }
    }
}

- (UIColor *)currentColor
{
    [self.redValue.hotInlet input:[BSDBang bang]];
    [self.blueValue.hotInlet input:[BSDBang bang]];
    [self.greenValue.hotInlet input:[BSDBang bang]];
    [self.alphaValue.hotInlet input:[BSDBang bang]];
    NSNumber *red = self.redValue.mainOutlet.value;
    NSNumber *blue = self.blueValue.mainOutlet.value;
    NSNumber *green = self.greenValue.mainOutlet.value;
    NSNumber *alpha = self.alphaValue.mainOutlet.value;
    UIColor *result = [UIColor colorWithRed:red.doubleValue
                                      green:green.doubleValue
                                       blue:blue.doubleValue
                                      alpha:alpha.doubleValue];
    return result;
}

@end
