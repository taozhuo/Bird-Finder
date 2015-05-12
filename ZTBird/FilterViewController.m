//
//  FilterViewController.m
//  ZTBird
//
//  Created by Zhuo Tao on 3/2/15.
//  Copyright (c) 2015 Zhuo Tao. All rights reserved.
//

#import "FilterViewController.h"

@interface FilterViewController () <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, assign) BOOL revealPickerView;
@property (nonatomic, strong) NSArray *pickerData;
@property (nonatomic, weak) IBOutlet UILabel *distanceLabel;
@property (nonatomic, weak) IBOutlet UILabel *backdaysLabel;
@property (nonatomic, weak) IBOutlet UISlider *distanceSlider;
@property (nonatomic, weak) IBOutlet UISlider *backdaysSlider;

- (IBAction)distanceChanged:(UISlider *)sender;
- (IBAction)backdaysChanged:(UISlider *)sender;

@end

@implementation FilterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.allowsSelection = YES;
    self.revealPickerView = NO;
    self.distanceLabel.text = [NSString stringWithFormat:@"%d", self.distance];
    self.backdaysLabel.text = [NSString stringWithFormat:@"%d", self.backdays];
    [self.distanceSlider setValue:(float)self.distance animated:YES];
    [self.backdaysSlider setValue:(float)self.backdays animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)exit:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)done:(id)sender
{
    [self.delegate filterViewController:self
                               distance:self.distance
                                backday:self.backdays];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Picker view delegate and data souce

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.pickerData.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.pickerData[row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
}

#pragma mark - Sliders

- (void)distanceChanged:(UISlider *)sender
{
    int intValue = roundl(sender.value);
    sender.value = intValue;
    self.distanceLabel.text = [NSString stringWithFormat:@"%d", intValue];
    self.distance = intValue;
}

- (void)backdaysChanged:(UISlider *)sender
{
    int intValue = roundl(sender.value);
    sender.value = intValue;
    self.backdaysLabel.text = [NSString stringWithFormat:@"%d", intValue];
    self.backdays = intValue;
}

#pragma mark - UISegmented Control

-(void)typeChanged:(UISegmentedControl *)sender
{
}

@end
