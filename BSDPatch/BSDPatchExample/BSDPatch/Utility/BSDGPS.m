//
//  BSDGPS.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/16/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDGPS.h"
#import "NSValue+BSD.h"
#import <CoreLocation/CoreLocation.h>

@interface BSDGPS ()<CLLocationManagerDelegate>
{
    
    BOOL kLocating;
}

@property (nonatomic,strong)CLLocationManager *locationManager;

@end

@implementation BSDGPS

- (void)setupWithArguments:(id)arguments
{
    self.name = @"GPS";
    kLocating = NO;
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.hotInlet) {
        if (!kLocating) {
            self.locationManager = nil;
            if (!self.locationManager) {
                self.locationManager = [[CLLocationManager alloc]init];
                self.locationManager = [[CLLocationManager alloc]init];
                self.locationManager.delegate = self;
            }
            
            [self.locationManager startUpdatingLocation];
            kLocating = YES;
        }else{
            [self.locationManager stopUpdatingLocation];
            kLocating = NO;
        }
        
        //[self calculateOutput];
    }
}

- (void)calculateOutput{
    
    CLLocation *loc = self.locationManager.location;
    CGPoint pt = CGPointMake(loc.coordinate.latitude, loc.coordinate.longitude);
    NSValue *wrapped = [NSValue wrapPoint:pt];
    [self.mainOutlet setValue:wrapped];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self calculateOutput];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    
}

@end
