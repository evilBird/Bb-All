//
//  BSDGPUImage.h
//  BlackBox.UI
//
//  Created by Travis Henspeter on 11/26/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//
#import "BSDObject.h"
#import "GPUImage.h"
#import <objc/runtime.h>

@interface BSDGPUImage : BSDObject

@property (nonatomic,strong)BSDOutlet *rightOutlet;
@property (nonatomic,strong)BSDInlet *parameterInlet;

@property (nonatomic,strong)GPUImagePicture *picture;
@property (nonatomic,strong)GPUImageFilter *myFilter;

@property (nonatomic,strong)UIImage *previousImage;
@property (nonatomic,strong)NSString *prevFilterKey;

- (void)filterImage:(UIImage *)sourceImage withFilterKey:(NSString *)filterKey;
- (GPUImageFilter *)filterWithName:(NSString *)filterName;

@end
