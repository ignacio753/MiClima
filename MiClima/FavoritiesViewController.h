//
//  FavoritiesViewController.h
//  MiClima
//
//  Created by Ignacio Monge on 5/31/16.
//  Copyright © 2016 IMS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCCoreDataManager.h"
#import "Ciudad.h"
#import "ViewController.h"

@interface FavoritiesViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
