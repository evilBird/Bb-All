//
//  BSDGradientLayer.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/30/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDGradientLayer.h"
#import "NSValue+BSD.h"

@implementation BSDGradientLayer

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    [super setupWithArguments:arguments];
    self.name = @"gradient";
}

- (void)updateLayer
{
    id hot = self.setterInlet.value;
    id layer = (CAGradientLayer *)self.layerInlet.value;
    if (!hot || !layer || ![hot isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSMutableDictionary *setters = [(NSDictionary *)hot mutableCopy];
    NSDictionary *properties = [self propertiesForObject:layer];
    
    for (id aKey in setters.allKeys) {
        id aVal = setters[aKey];
        if ([properties.allKeys containsObject:aKey]) {
            if ([aKey isEqualToString:@"colors"] && [aVal isKindOfClass:[NSArray class]]) {
                NSMutableArray *colors = [NSMutableArray array];
                for (UIColor *aColor in aVal) {
                    [colors addObject:(id)aColor.CGColor];
                }
                
                [layer setValue:colors forKey:aKey];
            }else{
                
                [layer setValue:aVal forKey:aKey];
            }
            
        }else{
            NSLog(@"layer does not have property %@",aKey);
        }
    }
    
    [layer setNeedsDisplay];
}


- (CALayer *)makeMyLayerWithFrame:(CGRect)frame
{
    CAGradientLayer *layer = [[CAGradientLayer alloc]init];
    layer.frame = frame;
    return layer;
}

@end
