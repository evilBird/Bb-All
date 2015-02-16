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
    
    if (arguments) {
        self.name = [NSString stringWithFormat:@"log %@",[arguments toString]];
        [self.coldInlet input:[arguments toString]];
    }
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    __weak BbLog *weakself = self;
    return ^(id hotValue, NSArray *inlets){
        id valueCopy = [hotValue copy];
        NSDateFormatter *df = [[NSDateFormatter alloc]init];
        df.dateStyle = NSDateFormatterShortStyle;
        df.timeStyle = NSDateIntervalFormatterFullStyle;
        NSString *timeString = [df stringFromDate:[NSDate date]];
        NSString *tagCopy = [[weakself.inlets[1] getValue]copy];
        NSString *log = [NSString stringWithFormat:@"\n%@ Bb %@: %@\n",timeString,tagCopy,valueCopy];
        NSLog(@"%@",log);
        return hotValue;
    };
}

@end
