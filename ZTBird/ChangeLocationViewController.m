//
//  ChangeLocationViewController.m
//  ZTBird
//
//  Created by Zhuo Tao on 2/15/15.
//  Copyright (c) 2015 Zhuo Tao. All rights reserved.
//

#import "ChangeLocationViewController.h"

@interface ChangeLocationViewController () <UISearchBarDelegate>
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) CLGeocoder *geocoder;

@end

@implementation ChangeLocationViewController
{
    NSArray *_placemarks;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.geocoder = [[CLGeocoder alloc] init];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Search Bar Delegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)exit:(id)sender
{
    if ([self.searchBar isFirstResponder]) {
        [self.searchBar resignFirstResponder];
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.geocoder geocodeAddressString:searchText
                               inRegion:nil
                      completionHandler:^(NSArray *placemarks, NSError *error) {
                          if (error == nil) {
                              _placemarks = placemarks;
                              [self.tableView reloadData];
                          } else if (error.code == kCLErrorNetwork) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Network Error"
                                                                                             message:[error localizedDescription]
                                                                                      preferredStyle:UIAlertControllerStyleAlert];
                                  UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                                                     style:UIAlertActionStyleDefault
                                                                                   handler:^(UIAlertAction * action) {}];
                                  [alert addAction:okAction];
                                  [self presentViewController:alert animated:YES completion:nil];
                              });
                          }
                      }];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _placemarks.count;;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlacemarkCell" forIndexPath:indexPath];
    CLPlacemark *placemark = (CLPlacemark *)_placemarks[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(changeLocationViewController:didUpdateLocation:)]) {
        CLPlacemark *placemark = _placemarks[indexPath.row];
        [self.delegate changeLocationViewController:self didUpdateLocation:placemark];
    }
    [self.searchBar resignFirstResponder];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];

}

@end
