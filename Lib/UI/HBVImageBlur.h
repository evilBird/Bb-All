//
//  HBVImageBlur.h
//  Herbivore
//
//  Created by Travis Henspeter on 5/9/14.
//  Copyright (c) 2014 Herbivore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HBVImageBlurType){
    
    HBVImageBlurTypeCoreImage,
    HBVImageBlurTypevImage
};

@interface HBVImageBlur : NSObject

+ (UIImage *)applyBlurType:(HBVImageBlurType)type onImage:(UIImage *)imageToBlur withRadius:(CGFloat)blurRadius;

@end
