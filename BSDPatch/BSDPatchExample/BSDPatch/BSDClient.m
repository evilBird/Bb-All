//
//  BSDClient.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/16/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDClient.h"
#import "AFNetworking.h"

//static NSString *kAPIKey = @"AIzaSyAC-CxQjkbJWFV84VpkXGRl4bzFnbJ7pe0";
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
    NSString *baseURL = arguments;
    if (baseURL) {
        self.client = [[AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:baseURL]];
    }else{
        self.client = [[AFHTTPSessionManager alloc]initWithBaseURL:[NSURL URLWithString:kDefaultBaseURL]];
        self.parameters = [NSMutableDictionary dictionary];
        //self.parameters[@"radius"] = @(1000);
        self.parameters[@"lat"] = @(45);
        self.parameters[@"lng"] = @(-90);
        self.parameters[@"limit"] = @(5);
        //self.parameters[@"format"] = @"json";
        //self.parameters[@"key"] = kAPIKey;
    }
    
    self.parameterInlet = [[BSDInlet alloc]initHot];
    self.parameterInlet.name = @"parameters";
    self.parameterInlet.delegate = self;
    [self addPort:self.parameterInlet];
}

- (void)hotInlet:(BSDInlet *)inlet receivedValue:(id)value
{
    if (inlet == self.parameterInlet) {
        NSDictionary *dictionary = value;
        [self updateParametersWithDictionary:dictionary];
    }else if (inlet == self.hotInlet && [value isKindOfClass:[BSDBang class]]){
        
    }
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.hotInlet) {
        [self sendRequest];
    }
}
- (void)sendRequest
{
    NSDictionary *parms = self.coldInlet.value;
    [self updateParametersWithDictionary:parms];
    NSString *query = [self queryString];
    NSLog(@"queryString: %@",query);
    [self.client GET:query
          parameters:nil
             success:^(NSURLSessionDataTask *task, id responseObject) {
                 [self.mainOutlet setValue:responseObject];
             } failure:^(NSURLSessionDataTask *task, NSError *error) {
                 [self.mainOutlet setValue:NULL];
             }];
}

- (void)updateParametersWithDictionary:(NSDictionary *)dictionary
{
    if (!self.parameters) {
        self.parameters = [NSMutableDictionary dictionary];
    }
    
    for (NSString *aKey in dictionary.allKeys) {
        self.parameters[aKey] = dictionary[aKey];
    }
}

- (NSString *)queryString
{
    NSMutableString *query = [[NSMutableString alloc]initWithString:@"?"];
    NSString *locStr = [NSString stringWithFormat:@"ll=%@,%@",self.parameters[@"lat"],self.parameters[@"lng"]];
    [query appendString:locStr];
    NSString *ls = [NSString stringWithFormat:@"&limit=%@",self.parameters[@"limit"]];
    [query appendString:ls];
    [query appendFormat:@"&client_id=%@",kFourSquareClientID];
    [query appendFormat:@"&client_secret=%@",kFourSquareClientSecret];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"YYYYMMDD";
    NSDate *now = [NSDate date];
    NSString *dateString = [dateFormatter stringFromDate:now];
    [query appendFormat:@"&v=%@",dateString];
    //NSString *keyString = [NSString stringWithFormat:@"&key=%@",self.parameters[@"key"]];
    //[query appendString:keyString];

    return query;//[query stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
}


@end
