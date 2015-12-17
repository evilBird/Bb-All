//
//  BbLog.m
//  Bb_Desktop
//
//  Created by Travis Henspeter on 2/16/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbLog.h"

@implementation BbLog

- (void)setupWithArguments:(id)arguments
{
    [super setupWithArguments:arguments];
    self.name = @"Log";
    if (arguments) {
        [self.coldInlet input:[arguments toString]];
    }
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    return ^(id hotValue, NSArray *inlets){
        id valueCopy = [hotValue copy];
        NSDateFormatter *df = [[NSDateFormatter alloc]init];
        df.dateStyle = NSDateFormatterShortStyle;
        df.timeStyle = NSDateIntervalFormatterMediumStyle;
        NSString *timeString = [df stringFromDate:[NSDate date]];
        NSString *tagCopy = [[inlets[1] getValue]copy];
        NSString *log = [NSString stringWithFormat:@"\n%@ Bb %@: %@\n",timeString,tagCopy,valueCopy];
        NSLog(@"%@",log);
        return hotValue;
    };
}

@end
