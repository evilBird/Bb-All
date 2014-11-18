//
//  BSDVideoStream.m
//  BSDPatchExample
//
//  Created by Travis Henspeter on 8/12/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDVideoLayer.h"
#import <AVFoundation/AVFoundation.h>

@interface BSDVideoLayer ()
{
    NSInteger kState;
}

@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic,strong) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic,strong) UIImage *croppedImageWithoutOrientation;

@end

@implementation BSDVideoLayer

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    [super setupWithArguments:arguments];
    self.name = @"video layer";
    
}

- (void)inletReceievedBang:(BSDInlet *)inlet
{
    if (inlet == self.layerInlet) {
        if (self.captureVideoPreviewLayer) {
            [self.mainOutlet output:self.captureVideoPreviewLayer];
        }
    }
}

- (void)hotInlet:(BSDInlet *)inlet receivedValue:(id)value
{
    if (inlet == self.layerInlet)
    {
        [self updateLayer];
        [self.mainOutlet output:self.layerInlet.value];
        
    }else if (inlet == self.setterInlet)
    {
        [self updateLayer];
    }else if (inlet == self.animationInlet)
    {
        [self doAnimation];
    }else if (inlet == self.selectorInlet)
    {
        [self doSelector];
    }else if (inlet == self.getterInlet)
    {
        NSDictionary *dictionary = [self propertiesForObject:self.layerInlet.value];
        id key = self.getterInlet.value;
        if (dictionary && key && [dictionary.allKeys containsObject:key])
        {
            id val = [self.layerInlet.value valueForKeyPath:key];
            NSDictionary *output = @{key:val};
            [self.getterOutlet output:output];
        }
    }
}

- (void)doSelector
{
    id selector = self.selectorInlet.value;
    if ([selector isKindOfClass:[NSString class]]) {
        if ([selector isEqualToString:@"captureImage"] && kState == 1) {
            [self captureImage];
        }else if ([selector isEqualToString:@"start"] && kState == 0){
            [self beginVideoSession];
            kState = 1;
        }else if ([selector isEqualToString:@"stop"] && kState == 1){
            [self endVideoSession];
            kState = 0;
        }
        return;
    }
    
    [super doSelector];
}

- (void)beginVideoSession
{
    if (self.session != nil) { self.session = nil; };
    
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    CGRect frame;
    
    if (self.captureVideoPreviewLayer) {
        frame = self.captureVideoPreviewLayer.frame;
    }else{
        frame = CGRectMake(0, 0, 300, 300);
    }

    if (self.captureVideoPreviewLayer != nil) { self.captureVideoPreviewLayer = nil; };
    self.captureVideoPreviewLayer = (AVCaptureVideoPreviewLayer *)[self makeMyLayerWithFrame:frame];
    
    NSArray *devices = [AVCaptureDevice devices];
    AVCaptureDevice *frontCamera=nil;
    AVCaptureDevice *backCamera=nil;
    NSError *error = nil;
    
    for (AVCaptureDevice *device in devices) {
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionBack) {
                backCamera = device;
            }
            else {
                frontCamera = device;
            }
        }
    }
    
    
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
    if (!input) {
        NSLog(@"ERROR: trying to open camera: %@", error);
    }
    
    [self.session addInput:input];
    
    if (self.stillImageOutput != nil){ self.stillImageOutput = nil; };
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    [self.session addOutput:self.stillImageOutput];
    [self.session startRunning];
    [self.layerInlet input:self.captureVideoPreviewLayer];
}

- (void)endVideoSession
{
    [self.session stopRunning];
    [self.session removeOutput:self.stillImageOutput];
    self.stillImageOutput = nil;
    [self.session removeInput:self.session.inputs.firstObject];
    [self.captureVideoPreviewLayer removeFromSuperlayer];
    self.captureVideoPreviewLayer = nil;
    self.session = nil;
    self.mainOutlet.value = nil;
    self.layerInlet.value = nil;
}

- (void) captureImage {
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:self.stillImageOutput.connections.firstObject completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        
        if (imageSampleBuffer != NULL) {
            
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            UIImage *output = [UIImage imageWithData:imageData];
            [self.getterOutlet output:@{@"captureImage":output}];
        }
    }];
}

- (CALayer *)makeMyLayerWithFrame:(CGRect)frame
{
    AVCaptureVideoPreviewLayer *myLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    myLayer.frame = frame;
    [myLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    return myLayer;
}

- (void)tearDown
{
    if (kState == 1) {
        [self endVideoSession];
    }
    
    [super tearDown];
}

@end
