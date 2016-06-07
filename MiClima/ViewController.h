//
//  ViewController.h
//  MiClima
//
//  Created by Ignacio Monge on 5/24/16.
//  Copyright © 2016 IMS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPSessionManager.h"
#import <CoreLocation/CoreLocation.h>
#import "Ciudad.h"
#import "DCCoreDataManager.h"
#import "MBProgressHUD.h"
#import <Social/Social.h>
#import "Constants.h"

@interface ViewController : UIViewController <CLLocationManagerDelegate,UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *pressureLabel;
@property (weak, nonatomic) IBOutlet UILabel *windSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *windDirectionLabel;
@property (weak, nonatomic) IBOutlet UILabel *humidityLabel;
@property (weak, nonatomic) IBOutlet UIImageView *weatherIconImage;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) NSString *cityId;
@end

