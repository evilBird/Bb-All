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

- (void)hotInlet:(BSDInlet *)inlet receivedValue:(id)value
{
    if (inlet == self.hotInlet) {
        NSNumber *value = inlet.value;
        NSInteger newStatus = value.integerValue;
        if (newStatus == 1 && !kLocating) {
            [self beginLocationUpdates];
            return;
        }
        
        if (newStatus == 0 && kLocating) {
            [self endLocationUpdates];
            return;
        }
    }
}

- (void)beginLocationUpdates
{
    kLocating = YES;
    self.locationManager = nil;
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

- (void)endLocationUpdates
{
    kLocating = NO;
    [self.locationManager stopUpdatingLocation];
}

- (BSDInlet *)makeRightInlet
{
    return nil;
}

- (void)sendOutput:(id)output
{
    CLLocation *loc = (CLLocation *)output;
    CGPoint pt = CGPointMake(loc.coordinate.latitude, loc.coordinate.longitude);
    NSValue *wrapped = [NSValue wrapPoint:pt];
    [self.mainOutlet setValue:wrapped];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self sendOutput:locations.lastObject];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    SEL requestSelector = NSSelectorFromString(@"requestWhenInUseAuthorization");
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined &&
        [self.locationManager respondsToSelector:requestSelector]) {
        [self.locationManager performSelector:requestSelector withObject:NULL];
    } else {
        [self.locationManager startUpdatingLocation];
    }
}

@end
