//
//  ViewController.m
//  MiClima
//
//  Created by Ignacio Monge on 5/24/16.
//  Copyright © 2016 IMS. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    NSString *cityName;
    NSString *cityWeather;
    NSString *cityTemp;
}

@end

@implementation ViewController

CLLocationManager *locationManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    locationManager = [[CLLocationManager alloc] init];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.dateTimeLabel.text = [self getCurrentDate];
    _searchBar.text = @"";
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if (_cityId != nil) {
        [self getWeatherByCityId];
    } else {
        [self getCurrentLocation];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - CLLocationManagerDelegate

- (void)getCurrentLocation {
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [self displayAlert:(@"Error")withMessage:@"Failed to get your location"];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        [self getWeatherInCurrentLocation:(currentLocation.coordinate)];
    }
    
    [locationManager stopUpdatingLocation];
}

- (void) getWeatherInCurrentLocation:(CLLocationCoordinate2D) coordinate {
    
    NSString *latitude = [NSString stringWithFormat:@"%f", coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f", coordinate.longitude];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:latitude, @"lat", longitude, @"lon", @"metric", @"units", WEATHER_API_KEY, @"appid", nil];
    
    [self getWeather:(params)];
}

#pragma mark - Weather API Call

- (void) getWeather:(NSDictionary*) params {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:WEATHER_API_URL parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSArray *weather = [responseObject objectForKey:@"weather"];
            NSDictionary *main = [responseObject objectForKey:@"main"];
            NSDictionary *wind = [responseObject objectForKey:@"wind"];
            
            NSString *cityNameRes = [responseObject objectForKey:@"name"];
            NSString *description = [((NSDictionary *)[weather objectAtIndex:0]) objectForKey:@"description"];
            NSString *iconId = [((NSDictionary *)[weather objectAtIndex:0]) objectForKey:@"icon"];
            NSString *temperature = [main objectForKey:@"temp"];
            NSString *humidity = [main objectForKey:@"humidity"];
            NSString *pressure = [main objectForKey:@"pressure"];
            
            NSString *windSpeed = [wind objectForKey:@"speed"];
            NSString *windDeg = [wind objectForKey:@"deg"];
            
            _cityId = [responseObject objectForKey:@"id"];
            cityName = cityNameRes;
            cityWeather = [description capitalizedString];
            cityTemp = [NSString stringWithFormat:@"%i%@",[temperature intValue], @"°C"];
            
            self.cityLabel.text = cityName;
            self.weatherDescriptionLabel.text = cityWeather;
            self.temperatureLabel.text = cityTemp;
            self.humidityLabel.text = [NSString stringWithFormat:@"%@ %@",humidity, @"%"];
            
            self.pressureLabel.text = [NSString stringWithFormat:@"%@ hPa", [self getRoundedValue:(pressure)]];
            self.windSpeedLabel.text = [NSString stringWithFormat:@"%@ meter/sec", [self getRoundedValue:(windSpeed)]];
            self.windDirectionLabel.text = [NSString stringWithFormat:@"%@ degrees", [self getRoundedValue:(windDeg)]];
            
            NSString *iconUrl = [NSString stringWithFormat:WEATHER_API_IMAGE_URL, iconId];
            
            NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: iconUrl]];
            self.weatherIconImage.image = [UIImage imageWithData: imageData];
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"%@", error);
        
    }];
    
}

#pragma mark - Search Bar

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString* query = searchBar.text;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self getWeatherByQuery:(query)];
    [self.view endEditing:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([searchText length] == 0) {
        [self getCurrentLocation];
    }
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - Add Favorite City

- (IBAction)addFavoriteCity:(id)sender {
    if (_cityId != nil) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", @"id", _cityId];
        NSArray *results = [[DCCoreDataManager sharedInstance] getEntities:@"Ciudad" withPredicate:predicate];
        
        if ([results count] > 0) {
            [self displayAlert:([[results objectAtIndex:0] name])withMessage:@"This city is already in your favorites!"];
        } else {
            NSMutableDictionary *entityValues = [NSMutableDictionary dictionary];
            [entityValues setObject:_cityId forKey:@"id"];
            [entityValues setObject:cityName forKey:@"name"];
            [[DCCoreDataManager sharedInstance]saveEntity:@"Ciudad" withValues:entityValues];
            [[DCCoreDataManager sharedInstance] saveContext];
            
            [self displayAlert:(@"Success" )withMessage:@"Your city has been saved!"];
        }
    }
}

#pragma mark - Share to Facebook

- (IBAction)shareToFacebook:(id)sender {
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Share"
                                  message:@"Select the social network you would like to share the weather with:"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* fbButton = [UIAlertAction
                               actionWithTitle:@"Facebook"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   
                                   SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                                   
                                   NSString *sharingText = [NSString stringWithFormat:@"Current weather in %@: %@ with %@", cityName, cityTemp, cityWeather];
                                   [controller setInitialText:sharingText];
                                   [self presentViewController:controller animated:YES completion:Nil];
                                   
                               }];
    
    UIAlertAction* twitterButton = [UIAlertAction
                                    actionWithTitle:@"Twitter"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        
                                        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                                        
                                        NSString *sharingText = [NSString stringWithFormat:@"Current weather in %@: %@ with %@", cityName, cityTemp, cityWeather];
                                        [controller setInitialText:sharingText];
                                        [self presentViewController:controller animated:YES completion:Nil];
                                        
                                    }];
    
    UIAlertAction* cancelButton = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) { }];
    
    [alert addAction:fbButton];
    [alert addAction:twitterButton];
    [alert addAction:cancelButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Utils

-(void) displayAlert:(NSString*) title withMessage: (NSString*) message  {
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:@"Ok"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) { }];
    
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSString*)getCurrentDate {
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"h:mm a, EEEE d"];
    
    return [NSString stringWithFormat:@"%@th", [dateFormatter stringFromDate:[NSDate date]] ];
}

- (void) getWeatherByCityId {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:_cityId, @"id", @"metric", @"units", WEATHER_API_KEY, @"appid", nil];
    
    [self getWeather:(params)];
}

- (void) getWeatherByQuery:(NSString*) query {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:query, @"q", @"metric", @"units", WEATHER_API_KEY, @"appid", nil];
    
    [self getWeather:(params)];
}

- (NSString*) getRoundedValue:(NSString*) value {
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    [fmt setPositiveFormat:@"0.##"];
    
    return [fmt stringFromNumber:[NSNumber numberWithFloat:[value floatValue]]];
}

@end
