//
//  BSDConstraint.m
//  
//
//  Created by Travis Henspeter on 12/22/14.
//
//

#import "BSDConstraint.h"

@implementation BSDConstraint

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)hotInlet:(BSDInlet *)inlet receivedValue:(id)value
{
    if (inlet == self.hotInlet) {
        if ([value isKindOfClass:[NSString class]]) {
            if ([value isEqualToString:@"attributes"]) {
                
            }else if ([value isEqualToString:@"relations"]){
                
            }
        }
    }
}

- (void)setupWithArguments:(id)arguments
{
    self.viewsInlet = [[BSDInlet alloc]initCold];
    self.viewsInlet.delegate = self;
    self.viewsInlet.name = @"superview";
    [self addPort:self.viewsInlet];
}

- (void)calculateOutput
{
    
}

@end
