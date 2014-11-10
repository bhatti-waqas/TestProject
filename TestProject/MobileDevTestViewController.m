//
//  MobileDevTestViewController.m
//  TestProject
//
//  Created by Waqas Bhatti on 11/7/14.
//  Copyright (c) 2014 Muhammad Zubair. All rights reserved.
//


#import "MobileDevTestViewController.h"
#import "Constants.h"
#import <AFNetworking/AFHTTPRequestOperationManager.h>
#import <ActionSheetPicker-3.0/AbstractActionSheetPicker.h>
#import <ActionSheetPicker-3.0/ActionSheetDatePicker.h>
#import <CoreLocation/CoreLocation.h>

@interface MobileDevTestViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,CLLocationManagerDelegate>
{
    
    __weak IBOutlet UITextField *startLocField_;
    __weak IBOutlet UITextField *endLocField_;
    __weak IBOutlet UITextField *dateTxtField_;
    UITableView *autoCompleteTableView_;
    AbstractActionSheetPicker *actionSheetPicker_;
    NSMutableArray *foundLocationsArray_;
    CGRect startLocFrame_;
    CGRect endLocFrame_;
    CLLocation *currentLocation_;
    //getting current location
    CLLocationManager *locationManager_;
}

@end

@implementation MobileDevTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    startLocFrame_ = CGRectMake(startLocField_.frame.origin.x, startLocField_.frame.origin.y+startLocField_.frame.size.height+2  , 250, 100);
    
    endLocFrame_ = CGRectMake(startLocField_.frame.origin.x, endLocField_.frame.origin.y+endLocField_.frame.size.height+2  , 200, 100);
    
    autoCompleteTableView_ = [[UITableView alloc] initWithFrame:startLocFrame_ style:UITableViewStylePlain];
    
    autoCompleteTableView_.dataSource = self;
    autoCompleteTableView_.delegate = self;

    [autoCompleteTableView_ setHidden:YES];
    [autoCompleteTableView_ setBackgroundColor:[UIColor grayColor]];
    [self.view addSubview:autoCompleteTableView_];

    [self clearAllData];
    
    locationManager_ = [[CLLocationManager alloc] init];
    locationManager_.delegate = self;
    locationManager_.distanceFilter = kCLDistanceFilterNone;
    locationManager_.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([locationManager_ respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        
        [locationManager_ requestWhenInUseAuthorization];
    }
    
    [locationManager_ startUpdatingLocation];
    
}
-(void)clearAllData
{
    [startLocField_ setText:@""];
    [startLocField_ setText:@""];
    [startLocField_ setText:@""];
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == dateTxtField_) {
        
        [self showDatePicker];
    }
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *urlString = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *createdURL = [NSString stringWithFormat:@"%@%@",BASE_URL,urlString];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:createdURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
       
        
        [self sortArrayByDistanceWithArrayOfPlaces:responseObject];
        
        
        if (foundLocationsArray_.count > 0) {
            if (textField == startLocField_) {
                
                [autoCompleteTableView_ setFrame:startLocFrame_];
            }
            else
            {
                [autoCompleteTableView_ setFrame:endLocFrame_];
            }
            [autoCompleteTableView_ setHidden:NO];
            [autoCompleteTableView_ reloadData];
        }
        else
        {
            [autoCompleteTableView_ setHidden:YES];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [autoCompleteTableView_ setHidden:YES];
        NSLog(@"No data returned");
    }];
    
    return YES;
}
-(void)showDatePicker
{
    
    ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"Select Date" datePickerMode:UIDatePickerModeDate selectedDate:[NSDate date] doneBlock:^(ActionSheetDatePicker *picker, id selectedDate, id origin) {
        
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateFormat:@"MMMM dd, yyyy"];
        
        NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [outputFormatter setLocale:usLocale];
        
        [dateTxtField_ setText:[outputFormatter stringFromDate:selectedDate]];
        
        [dateTxtField_ resignFirstResponder];
        
    } cancelBlock:^(ActionSheetDatePicker *picker) {
        
        [dateTxtField_ resignFirstResponder];
        
    } origin:dateTxtField_];
    
    [datePicker showActionSheetPicker];
}
- (IBAction)pickDate:(id)sender {
    
    [self showDatePicker];
}
- (IBAction)searchButtonPressed:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:@"Seach is not implemented yet" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
    
    [locationManager_ startUpdatingLocation];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CELL_IDENTIFIER";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    NSDictionary *currentLoc = foundLocationsArray_[indexPath.row];
    
    cell.textLabel.text = [currentLoc objectForKey:@"fullName"];
    
    cell.backgroundColor = [UIColor grayColor];
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (foundLocationsArray_) {
        return foundLocationsArray_.count;
    }
    return 0;
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    currentLocation_ = [locations lastObject];
    
    
    NSLog(@"Current location is :%@",[locations lastObject]);
    
}
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"failed ");
}
-(void)sortArrayByDistanceWithArrayOfPlaces:(NSArray *)places
{
    if (places.count <= 0) {
        
        return;
    }
    if (currentLocation_.coordinate.latitude == 0.0 && currentLocation_.coordinate.longitude == 0.0) {
        
        return;
    }
    NSMutableArray *sortedLocations = [NSMutableArray arrayWithArray:places];
    
    BOOL finito = NO;
    __strong NSDictionary *riga1, *riga2;
    
    while (!finito) {
        for (int i = 0; i < [sortedLocations count] - 1; i++) {
            
            finito = YES;
            riga1 = [sortedLocations objectAtIndex: i];
            riga2 = [sortedLocations objectAtIndex: i+1];
            
            NSDictionary *geoPosition1 = [riga1 objectForKey:@"geo_position"];
            NSDictionary *geoPosition2 = [riga1 objectForKey:@"geo_position"];
            CLLocationDistance distanceA = [currentLocation_ distanceFromLocation:
                                            [[CLLocation alloc]initWithLatitude:[[geoPosition1 valueForKey:@"latitude"] doubleValue]
                                                                      longitude:[[geoPosition1 valueForKey:@"longitude"] doubleValue]]];
            CLLocationDistance distanceB = [currentLocation_ distanceFromLocation:
                                            [[CLLocation alloc]initWithLatitude:[[geoPosition2 valueForKey:@"latitude"] doubleValue]
                                                                      longitude:[[geoPosition1 valueForKey:@"longitude"] doubleValue]]];
            if (distanceA > distanceB) {
                
                
                [sortedLocations replaceObjectAtIndex:i+1 withObject:riga2];
                [sortedLocations replaceObjectAtIndex:i withObject:riga1];
                
                finito = NO;
            }
        }
    }
 
    if (foundLocationsArray_.count > 0) {
        
        [foundLocationsArray_ removeAllObjects];
    }
    foundLocationsArray_ = sortedLocations;
}
@end
