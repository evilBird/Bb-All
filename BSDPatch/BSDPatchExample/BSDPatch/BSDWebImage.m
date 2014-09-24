//
//  BSDWebImage.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/23/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDWebImage.h"
#import "UIImageView+AFNetworking.h"

@implementation BSDWebImage

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    self.name = @"web image";
}

- (void)calculateOutput
{
    self.hotInlet.open = NO;
    NSString *urlString = self.hotInlet.value;
    if (urlString && [urlString isKindOfClass:[NSString class]]) {
        NSURL *url = [NSURL URLWithString:urlString];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        UIImageView *imageView = [UIImageView new];
        __weak BSDWebImage *weakself = self;
        [imageView setImageWithURLRequest:request
                         placeholderImage:nil
                                  success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                      [weakself.mainOutlet output:image];
                                      [weakself.hotInlet setOpen:YES];
                                  } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                      [weakself.mainOutlet setOpen:YES];
                                  }];
    }
}

- (BSDInlet *)makeRightInlet
{
    return nil;
}

@end
