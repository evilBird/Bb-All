//
//  BSDArr2Dict.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 11/16/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDArr2Dict.h"

@implementation BSDArr2Dict

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"arr2dict";
}

- (BSDInlet *)makeRightInlet
{
    return nil;
}

- (void)calculateOutput
{
    id hot = self.hotInlet.value;
    if (!hot || ![hot isKindOfClass:[NSArray class]]) {
        return;
    }
    
    NSArray *arr = hot;
    if (arr.count == 1 && [arr.firstObject isKindOfClass:[NSArray class]]) {
        arr = arr.firstObject;
    }
    NSDictionary *output = [self dictionaryFromArray:arr.mutableCopy];
    [self.mainOutlet output:output];
}

- (NSDictionary *)dictionaryFromArray:(NSArray *)array
{
    NSMutableDictionary *result = nil;
    NSInteger idx = 0;
    for (id arg in array) {
        NSLog(@"idx = %@, mod = %@",@(idx),@(idx%2));
        NSLog(@"arr count %@: %@",@(array.count),array);
        if (idx%2 == 1) {
            id key = array[idx-1];
            id value = arg;
            if (!result) {
                result = [NSMutableDictionary dictionary];
            }
            result[key] = value;
        }
        idx ++;
    }
    /*
    int count = (int)array.count;
    for (int i = 0; i < count; i++){
        int mod = i%2;
        
        if (mod == 1) {
            id key = array[i-1];
            id value = array[i];
            if (!result) {
                result = [NSMutableDictionary dictionary];
            }
            result[key] = value;
        }
    }
     */
    
    return result;
}


@end
