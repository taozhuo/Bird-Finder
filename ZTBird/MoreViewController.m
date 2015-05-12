//
//  MoreViewController.m
//  ZTBird
//
//  Created by Zhuo Tao on 4/20/15.
//  Copyright (c) 2015 Zhuo Tao. All rights reserved.
//

#import "MoreViewController.h"
#import <MessageUI/MessageUI.h>

@interface MoreViewController () <MFMailComposeViewControllerDelegate>

@end

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of  any resources that can be recreated.
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {  //send email
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        NSArray *toRecipients = [NSArray arrayWithObjects:@"taozhuo@gmail.com", nil];
        [controller setToRecipients:toRecipients];
        [controller setTitle:@"Email"];
        [controller setSubject:@"Feedback"];
        [controller setMessageBody:nil isHTML:NO];
        
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
        {
            controller.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        else
        {
            controller.modalPresentationStyle = UIModalPresentationFullScreen;
        }
        [self presentViewController:controller  animated:YES completion:nil];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

}


#pragma mark -  Mail Compose View Controller Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self becomeFirstResponder];
    NSString *strMailResult;
    switch (result)
    {
        case MFMailComposeResultCancelled:
            strMailResult = NSLocalizedString(@"E-Mail Cancelled",@"");
            break;
        case MFMailComposeResultSaved:
            strMailResult = NSLocalizedString(@"E-Mail Saved",@"");
            break;
        case MFMailComposeResultSent:
            strMailResult = NSLocalizedString(@"E-Mail Sent",@"");
            break;
        case MFMailComposeResultFailed:
            strMailResult = NSLocalizedString(@"E-Mail Failed",@"");
            break;
        default:
            strMailResult = NSLocalizedString(@"E-Mail Not Sent",@"");
            break;
    }
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Message",@"") message:strMailResult delegate:self  cancelButtonTitle:NSLocalizedString(@"OK",@"") otherButtonTitles:nil];
    [alertView show];
    [controller dismissViewControllerAnimated:YES completion:nil];
}


@end
