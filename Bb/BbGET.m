//
//  BbGET.m
//  Visual Cocoa
//
//  Created by Travis Henspeter on 2/21/15.
//  Copyright (c) 2015 birdSound. All rights reserved.
//

#import "BbGET.h"
#import "AFNetworking.h"

@implementation BbGET

- (NSSet *)allowedTypesForPort:(BbPort *)port
{
    if (port == self.hotInlet) {
        return [NSSet setWithObject:@(BbValueType_Dictionary)];
    }else if (port == self.coldInlet){
        return [NSSet setWithObject:@(BbValueType_String)];
    }else{
        return nil;
    }
}

- (void)setupWithArguments:(id)arguments
{
    [super setupWithArguments:arguments];
    self.name = @"GET";
    if (arguments) {
        [self.coldInlet input:[arguments toString]];
    }
}

- (BbCalculateOutputBlock)calculateOutputForOutletAtIndex:(NSInteger)index
{
    __weak BbGET *weakself = self;
    return ^(id hotValue, NSArray *inlets){
        id result = nil;
        NSString *baseURLString = [inlets[1]getValue];
        AFHTTPSessionManager *client = [[AFHTTPSessionManager alloc]init];
        [client GET:baseURLString
         parameters:hotValue
            success:^(NSURLSessionDataTask *task, id responseObject) {
                [[weakself mainOutlet]output:responseObject];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [[weakself mainOutlet]output:error.debugDescription];
            }];
        
        return result;
    };
}

@end
