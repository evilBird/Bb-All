//
//  BSDFormatString.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 7/20/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDFormatString.h"

@implementation BSDFormatString

- (instancetype)initWithFormatString:(NSString *)formatString
{
    return [super initWithArguments:formatString];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"formatString";
    NSString *formatString = (NSString *)arguments;
    if (arguments) {
        self.coldInlet.value = formatString;
    }
}

- (void)calculateOutput
{
    id hot = self.hotInlet.value;
    id cold = self.coldInlet.value;
    
    if (!hot || ![hot isKindOfClass:[NSArray class]]) {
        return;
    }
    
    if (!cold || ![cold isKindOfClass:[NSString class]]) {
        return;
    }
    NSString *formatString = [NSString stringWithString:cold];
    NSMutableArray *args = [hot mutableCopy];
    
    NSString *output = [self stringWithFormatString:formatString arguments:args];
    [self.mainOutlet output:output];
}

- (NSString *)stringWithFormatString:(NSString *)formatString arguments:(NSArray *)args
{
    NSString *result = nil;
    if (!formatString || !args) {
        return nil;
    }
    
    if (args.count > 5) {
        NSLog(@"\nBSDFORMATSTRING ERROR:\nToo many input arguments. 5 or less, buddy");
        return nil;
    }
    
    NSUInteger count = args.count;
    switch (count) {
        case 1:
            result = [NSString stringWithFormat:formatString,args.firstObject];
            break;
        case 2:
            result = [NSString stringWithFormat:formatString,args.firstObject,args.lastObject];
            break;
        case 3:
            result = [NSString stringWithFormat:formatString,args.firstObject,args[1],args.lastObject];
            break;
        case 4:
            result = [NSString stringWithFormat:formatString,args.firstObject,args[1],args[2],args.lastObject];
            break;
        case 5:
            result = [NSString stringWithFormat:formatString,args.firstObject,args[1],args[2],args[3],args.lastObject];
            break;
        default:
            break;
    }
    
    return result;
    
}
/*
- (void)calculateOutput
{
    NSArray *args = self.hotInlet.value;
    NSString *formatString = self.coldInlet.value;
    NSUInteger specs = [self countFormatSpecifiersInString:formatString];
    if (args && formatString && (args.count == specs) && args.count < 9) {
        
        switch (args.count) {
            case 1:
                self.mainOutlet.value = [NSString stringWithFormat:formatString,args[0]];

                break;
            case 2:
                self.mainOutlet.value = [NSString stringWithFormat:formatString,args[0],args[1]];

                break;
            case 3:
                self.mainOutlet.value = [NSString stringWithFormat:formatString,args[0],args[1],args[2]];

                break;
            case 4:
                self.mainOutlet.value = [NSString stringWithFormat:formatString,args[0],args[1],args[2],args[3]];

                break;
            case 5:
                self.mainOutlet.value = [NSString stringWithFormat:formatString,args[0],args[1],args[2],args[3],args[4]];

                break;
            case 6:
                self.mainOutlet.value = [NSString stringWithFormat:formatString,args[0],args[1],args[2],args[3],args[4],args[5]];
                
                break;
            case 7:
                self.mainOutlet.value = [NSString stringWithFormat:formatString,args[0],args[1],args[2],args[3],args[4],args[5],args[6]];
                
                break;
            case 8:
                self.mainOutlet.value = [NSString stringWithFormat:formatString,args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7]];
                break;
                
            default:
                self.mainOutlet.value = [NSString stringWithFormat:@"%lu args is too many!!",(unsigned long)args.count];

                break;
        }
    }
}
*/
- (void)formatArray:(NSArray *)args
{
    
}

- (NSUInteger)countFormatSpecifiersInString:(NSString *)string
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"%@" options:NSRegularExpressionCaseInsensitive error:&error];
    return [regex numberOfMatchesInString:string options:0 range:NSMakeRange(0, [string length])];
}

- (void)test
{
    self.debug = YES;
    self.coldInlet.value = @"%@/%@?val1=%@&val2=%@&val3=%@";
    self.hotInlet.value = @[@"http://test.com",@"testformat",@"cat",@"hat",@"splat"];
    self.hotInlet.value = @[@"http://test.com",@"testformat",@"cat",@"hat",@"splat",@"splort"];
    self.hotInlet.value = @[@"http://test.com",@"testformat",@"cat",@"hat"];


}

@end
