//
//  FavoritiesViewController.m
//  MiClima
//
//  Created by Ignacio Monge on 5/31/16.
//  Copyright © 2016 IMS. All rights reserved.
//

#import "FavoritiesViewController.h"

@interface FavoritiesViewController () {
    NSMutableArray *results;
    BOOL edit;
}

@end

@implementation FavoritiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    results = [NSMutableArray arrayWithArray:[[DCCoreDataManager sharedInstance] getEntities:@"Ciudad"]];
    edit = NO;
    [_tableView setEditing:edit animated:YES];
    [_tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)editFavorites:(id)sender {
    edit = !edit;
    [_tableView setEditing:edit animated:YES];
}

#pragma mark - Table View Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [results count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    Ciudad *ciudad = [results objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", ciudad.name];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Ciudad *ciudad = [results objectAtIndex:indexPath.row];
    
    UINavigationController *nav = [self.tabBarController.viewControllers objectAtIndex:0];
    
    ViewController *viewController = (ViewController*) [nav.viewControllers objectAtIndex:0];

    viewController.cityId = [ciudad id];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.tabBarController.selectedIndex = 0;
}

- (UITableViewCellEditingStyle)tableView: (UITableView*)tableView editingStyleForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        Ciudad *ciudad = [results objectAtIndex:indexPath.row];
        [results removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [[DCCoreDataManager sharedInstance] deleteEntity:ciudad];
        [[DCCoreDataManager sharedInstance] saveContext];
    }
}

@end
