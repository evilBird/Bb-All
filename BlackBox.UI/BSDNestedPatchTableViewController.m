//
//  BSDNestedPatchTableViewController.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 11/18/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "BSDNestedPatchTableViewController.h"

static NSString *kCellId = @"PatchCell";
static NSString *kNestedCellId = @"PatchCellNested";

@interface BSDNestedPatchTableViewController ()

@property (nonatomic,strong)NSDictionary *leafPatches;
@property (nonatomic,strong)NSDictionary *subpatches;


@end

@implementation BSDNestedPatchTableViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!self.patches) {
        return 0;
    }
    
    if (section == 0) {
        return self.leafPatches.allKeys.count;
    }
    return self.subpatches.allKeys.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.patches) {
        return 0;
    }
    if (self.subpatches) {
        return 2;
    }
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    UITableViewCell *result = nil;
    if (section == 0) {
        result = [tableView dequeueReusableCellWithIdentifier:kCellId forIndexPath:indexPath];
        NSArray *sortedNames = [self.leafPatches.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        NSString *patchTitle = [self patchTitleForName:sortedNames[indexPath.row]];
        result.textLabel.text = patchTitle;
    }else if (section == 1){
        result = [tableView dequeueReusableCellWithIdentifier:kNestedCellId forIndexPath:indexPath];
        NSArray *sortedNames = [self.subpatches.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        NSString *folderName = sortedNames[indexPath.row];
        result.textLabel.text = [self pathForSubpatchFolder:folderName];
        result.imageView.image = [UIImage imageNamed:@"toolbar_load"];
    }
    
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    if (section == 0) {
        NSArray *sortedNames = [self.leafPatches.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        NSString *patchName = sortedNames[indexPath.row];
        NSString *patchText = self.leafPatches[patchName];
        NSString *patchTitle = [self patchTitleForName:patchName];
        [self.delegate patchTableViewController:self selectedPatchWithName:patchTitle patchText:patchText];
    }else{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        BSDNestedPatchTableViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"NestedPatchTableViewController"];
        NSArray *sortedNames = [self.subpatches.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        NSString *subPatchName = sortedNames[indexPath.row];
        NSDictionary *patches = self.subpatches[subPatchName];
        vc.patches = patches;
        vc.path = [self pathForSubpatchFolder:subPatchName];
        vc.delegate = self.delegate;
        vc.title = vc.path;
        [self.navigationController showViewController:vc sender:self];
    }
}

- (void)setPatches:(NSDictionary *)patches
{
    _patches = patches;
    NSArray *allKeys = [patches allKeys];
    NSMutableDictionary *leaves = nil;
    NSMutableDictionary *branches = nil;
    for (NSString *aKey in allKeys) {
        if ([aKey hasSuffix:@".bb"]) {
            if (!leaves) {
                leaves = [NSMutableDictionary dictionary];
            }
            leaves[aKey] = patches[aKey];
        }else{
            if (!branches) {
                branches = [NSMutableDictionary dictionary];
            }
            branches[aKey] = patches[aKey];
        }
    }
    
    self.leafPatches = leaves;
    self.subpatches = branches;
}

- (NSString *)patchTitleForName:(NSString *)name
{
    return [NSString stringWithFormat:@"%@.bb",self.title];
}

- (NSString *)pathForSubpatchFolder:(NSString *)folderName
{
    if (self.path.length == 0) {
        return folderName;
    }
    
    return [self.path stringByAppendingPathExtension:folderName];
}

@end
