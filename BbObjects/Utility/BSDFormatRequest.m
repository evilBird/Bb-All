//
//  BSDFormatRequest.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/29/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDFormatRequest.h"
#import "BSDStringInlet.h"
#import "BSDDictionaryInlet.h"

@implementation BSDFormatRequest

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"format request";
    
    self.baseURLInlet = [[BSDStringInlet alloc]initCold];
    self.baseURLInlet.name = @"url";
    [self addPort:self.baseURLInlet];
    
    self.parametersInlet = [[BSDDictionaryInlet alloc]initCold];
    self.parametersInlet.name = @"parameters";
    [self addPort:self.parametersInlet];
    
}


- (BSDInlet *)makeRightInlet
{
    return nil;
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.hotInlet) {
        [self calculateOutput];
    }
}

- (void)calculateOutput
{
    NSString *url = self.baseURLInlet.value;
    if (!url || ![url isKindOfClass:[NSString class]]) {
        return;
    }
    
    NSDictionary *parms = self.parametersInlet.value;
    if (!parms || ![parms isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSMutableDictionary *copy = parms.mutableCopy;
    NSMutableString *result = [[NSMutableString alloc]initWithString:url];
    [result appendString:@"/?"];
    NSInteger idx = 0;
    for (NSString *aKey in copy.allKeys) {
        if (idx > 0) {
            [result appendString:@"&"];
        }
        
        [result appendFormat:@"%@=%@",aKey,copy[aKey]];
        idx++;
    }
    NSRange range;
    range.location = 0;
    range.length = result.length;
    [result replaceOccurrencesOfString:@" " withString:@"%20" options:0 range:range];
    NSString *output = [[NSString alloc]initWithString:result];
    
    [self.mainOutlet output:output];
}

@end
