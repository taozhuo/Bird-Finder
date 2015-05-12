//
//  WikiWebViewController.m
//  ZTBird
//
//  Created by Zhuo Tao on 8/8/14.
//  Copyright (c) 2014 Zhuo Tao. All rights reserved.
//

#import "WikiWebViewController.h"

@interface WikiWebViewController ()
@property (nonatomic,weak) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic,weak) IBOutlet UINavigationItem *barItem;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *activityIndicator;

-(IBAction)dismissWiki:(id)sender;
@end

@implementation WikiWebViewController

- (IBAction)dismissWiki:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.barItem.title = self.pageTitle;
    [self.webView loadRequest:
                  [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIWebView Delegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
}

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
