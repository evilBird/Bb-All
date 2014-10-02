//
//  BSDClient.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/16/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDClient.h"
#import "AFNetworking.h"

static NSString *kDefaultBaseURL = @"https://api.foursquare.com/v2/venues/explore";
static NSString *kFourSquareClientID = @"WEPI01NK1TIVICUFAZ50Q2KUGFO3D15VCBERCEOB0AH5TEYD";
static NSString *kFourSquareClientSecret = @"OXJXXOG3IZYHGGFETE2OHLQ0W05NQOEBA0WKY45K3QPK1DQ3";

@interface BSDClient ()

@property (nonatomic,strong)AFHTTPSessionManager *client;
@property (nonatomic,strong)NSMutableDictionary *parameters;

@end

@implementation BSDClient

- (instancetype)initWithBaseURL:(NSString *)baseURL
{
    return [super initWithArguments:baseURL];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"client";
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.hotInlet) {
        [self sendRequest];
    }
}

- (void)sendRequest
{
    NSString *query = self.coldInlet.value;
    if (query == nil || ![query isKindOfClass:[NSString class]]) {
        return;
    }
    
    if (!self.client) {
        self.client = [[AFHTTPSessionManager alloc]init];
    }
    
    __weak BSDClient *weakself = self;
    [self.client GET:query
          parameters:nil
             success:^(NSURLSessionDataTask *task, id responseObject) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [weakself.mainOutlet output:responseObject];
                 });
             } failure:^(NSURLSessionDataTask *task, NSError *error) {
                 [weakself.mainOutlet output:@{@"error":error}];
             }];
}


@end
