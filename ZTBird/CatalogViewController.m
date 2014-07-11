//
//  CatalogViewController.m
//  ZTBird
//
//  Created by Zhuo Tao on 7/2/14.
//  Copyright (c) 2014 Zhuo Tao. All rights reserved.
//

#import "CatalogViewController.h"
#import "BirdInfo.h"
#import "BirdDetailViewController.h"

@interface CatalogViewController ()

@end

@implementation CatalogViewController
{
    NSArray *_birds;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"BirdInfo"
                                              inManagedObjectContext:self.managedOjbectContext];
    [fetchRequest setEntity:entity];
    
    NSError *error;
    NSArray *foundObjs = [self.managedOjbectContext executeFetchRequest:fetchRequest
                                                                  error:&error];
    if (foundObjs == nil) {
        NSLog(@"Error fetching:");
    } else {
        _birds = foundObjs;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_birds count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BirdInfo"
                                                            forIndexPath:indexPath];
    BirdInfo *birdInfo = _birds[indexPath.row];
    UILabel *comNameLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *sciNameLabel = (UILabel *)[cell viewWithTag:200];
    
    comNameLabel.text = birdInfo.com_name;
    sciNameLabel.text = birdInfo.sci_name;
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"RevealDetail"]) {
        BirdDetailViewController *detailViewController = (BirdDetailViewController*)[segue destinationViewController];
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        BirdInfo *info = _birds[path.row];
        detailViewController.birdName = info.com_name;
    }
}


@end
