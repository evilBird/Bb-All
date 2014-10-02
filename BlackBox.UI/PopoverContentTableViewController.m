//
//  SavedPatchesTableViewController.m
//  BlackBox.UI
//
//  Created by Travis Henspeter on 9/16/14.
//  Copyright (c) 2014 birdSound LLC. All rights reserved.
//

#import "PopoverContentTableViewController.h"
static NSString *cellId = @"CellIdentifer";
@interface PopoverContentTableViewController ()

@end

@implementation PopoverContentTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellId];
        self.itemNames = [NSArray array];
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tableView.tableHeaderView = [self tableHeaderView];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return self.itemNames.count;
}

- (UIView *)tableHeaderView
{
    UIView *header = [[UIView alloc]initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                            self.view.bounds.origin.y,
                                                            self.view.bounds.size.width,
                                                            80)];
    header.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1];
    CGRect frame = header.bounds;
    CGFloat inset = header.bounds.size.width * 0.1;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectInset(frame, inset, 10)];
    label.text = self.title;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithWhite:0.3 alpha:1];
    label.font = [UIFont fontWithName:@"Courier-Bold" size:[UIFont systemFontSize]];
    [header addSubview:label];
    frame = header.bounds;
    frame.size.width *= 0.25;
    UIButton *button = [[UIButton alloc]initWithFrame:frame];
    [button setTitle:@"X" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithWhite:0.3 alpha:1] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(tapInCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = 1;
    [header addSubview:button];

    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    // Configure the cell...
    if (indexPath.row < self.itemNames.count) {
        cell.textLabel.text = self.itemNames[indexPath.row];
        cell.textLabel.font = [UIFont fontWithName:@"Courier" size:[UIFont systemFontSize]];
        NSInteger odd = indexPath.row%2;
        if (odd) {
            cell.contentView.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1];
            cell.textLabel.textColor = [UIColor colorWithWhite:0.45 alpha:1];
            cell.textLabel.backgroundColor = [UIColor clearColor];
        }else{
            cell.contentView.backgroundColor = [UIColor whiteColor];
            cell.textLabel.textColor = [UIColor colorWithWhite:0.45 alpha:1];
            cell.textLabel.backgroundColor = [UIColor clearColor];
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[self.delegate ];
    [self.delegate itemWasSelected:self.itemNames[indexPath.row]];
}

- (void)tapInCloseButton:(id)sender
{
    [self.delegate contentTableViewControllerWasDismissed:self];
}

- (void)tapInEditButton:(id)sender
{
    if (self.tableView.editing) {
        [sender setSelected:NO];
        [self setEditing:NO animated:YES];
    }else{
        [sender setSelected:YES];
        [self setEditing:YES animated:YES];
    }
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.editEnabled;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSMutableArray *items = self.itemNames.mutableCopy;
        NSString *itemName = items[indexPath.row];
        [items removeObject:itemName];
        [self.delegate itemWasDeleted:itemName];
        self.itemNames = items;
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        //[tableView reloadData];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
