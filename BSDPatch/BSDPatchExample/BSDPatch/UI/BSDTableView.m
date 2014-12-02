//
//  BSDTableView.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 12/1/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDTableView.h"
static NSString *kCellId = @"cellId";

@interface BSDTableView ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong)NSArray *data;

@end

@implementation BSDTableView

- (instancetype)initWithArguments:(id)arguments
{
    return [super initWithArguments:arguments];
}

- (void)setupWithArguments:(id)arguments
{
    [super setupWithArguments:arguments];
    self.name = @"tableview";
    
}

- (void)hotInlet:(BSDInlet *)inlet receivedValue:(id)value
{
    if (inlet == self.viewInlet && [value isKindOfClass:[UITableView class]]) {
        
        [(UITableView *)value setDelegate:self];
        [(UITableView *)value setDataSource:self];
        [(UITableView *)value registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellId];
    }
    
    [super hotInlet:inlet receivedValue:value];
}

- (void)doSelector
{
    id sel = self.viewSelectorInlet.value;
    id first = nil;
    if ([sel isKindOfClass:[NSArray class]]) {
        first = [(NSArray *)sel firstObject];
    }else if ([sel isKindOfClass:[NSDictionary class]]){
        first = [(NSDictionary *)sel allKeys].firstObject;
    }
    
    if (first && [first isKindOfClass:[NSString class]] && [first isEqualToString:@"data"]) {
        NSArray *data = nil;
        if ([sel isKindOfClass:[NSArray class]]) {
            NSMutableArray *copy = [sel mutableCopy];
            [copy removeObjectAtIndex:0];
            data = copy;
        }else{
            data = [(NSDictionary *)sel valueForKey:first];
        }
        
        self.data = data;
        [self.viewInlet.value reloadData];
        return;
    }
    
    [super doSelector];
}

- (UIView *)makeMyViewWithFrame:(CGRect)frame
{
    return nil;
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.data){
        return self.data.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellId forIndexPath:indexPath];
    if (indexPath.row < self.data.count) {
        NSDictionary *cellData = self.data[indexPath.row];
        if (cellData && [cellData isKindOfClass:[NSDictionary class]]) {
            if ([cellData.allKeys containsObject:@"text"]) {
                cell.textLabel.text = cellData[@"text"];
            }
            
            if ([cellData.allKeys containsObject:@"image"]) {
                cell.imageView.image = cellData[@"image"];
            }
            
            if ([cellData.allKeys containsObject:@"label"]) {
                NSDictionary *label = cellData[@"label"];
                for (NSString *aKey in label.allKeys) {
                    id val = label[aKey];
                    [cell.textLabel setValue:val forKey:aKey];
                }
            }
            
            if ([cellData.allKeys containsObject:@"imageView"]) {
                NSDictionary *imageView = cellData[@"imageView"];
                for (NSString *aKey in imageView.allKeys) {
                    id val = imageView[aKey];
                    [cell.imageView setValue:val forKey:aKey];
                }
            }
            
            if ([cellData.allKeys containsObject:@"contentView"]) {
                NSDictionary *contentView = cellData[@"contentView"];
                for (NSString *aKey in contentView.allKeys) {
                    id val = contentView[aKey];
                    [cell.contentView setValue:val forKey:aKey];
                }
            }
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.data.count) {
        NSDictionary *cellData = self.data[indexPath.row];
        NSArray *output = @[@"cell",@(indexPath.row),cellData.mutableCopy];
        [self.getterOutlet output:output];
    }
}

@end
