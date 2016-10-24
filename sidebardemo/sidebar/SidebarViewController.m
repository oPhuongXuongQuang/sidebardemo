//
//  SidebarViewController.m
//  ghinhap
//
//  Created by Quang Phuong on 7/19/15.
//  Copyright © 2015 fsoft. All rights reserved.
//

#import "SidebarViewController.h"
#import "SWRevealViewController.h"
#import "ViewController.h"
#import "TableCell.h"
#import "NhapItem.h"

@interface SidebarViewController (){
    NSString *homeNhapName;
}

@property NSInteger index;
- (void)getAllData;

@end

@implementation SidebarViewController

@synthesize nhapIndexOnMainView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nhapList = [[NSMutableArray alloc]init];
    
    [self.nhapList addObject: [[NhapItem alloc] initWithName:@"http://www.google.com" createDate:[NSDate date] isLocal:false owner:@""]];
    [self.nhapList addObject: [[NhapItem alloc] initWithName:@"http://www.apple.com" createDate:[NSDate date] isLocal:false owner:@""]];
    [self.nhapList addObject: [[NhapItem alloc] initWithName:@"http://www.microsoft.com" createDate:[NSDate date] isLocal:false owner:@""]];
    
    nhapIndexOnMainView = -1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableWithNotification:) name:@"RefreshSidebarView" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setMainViewNhapName:) name:@"SetMainViewAddressBar" object:nil];
    
    //Add long press event
    UILongPressGestureRecognizer* longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    [self.tableView addGestureRecognizer:longPressRecognizer];
    
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTap:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    [self.tableView addGestureRecognizer:doubleTapRecognizer];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"ResetBadge" object:nil userInfo:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.nhapList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TableCell *cell =[tableView dequeueReusableCellWithIdentifier:@"tableCell"];
    
    if ((cell==nil) || (![cell isKindOfClass: TableCell.class]))
    {
        [tableView registerNib:[UINib nibWithNibName:@"TableCell" bundle:nil] forCellReuseIdentifier:@"tableCell"];
        
        cell = (TableCell *) [tableView dequeueReusableCellWithIdentifier:@"tableCell"];
        
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(TableCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NhapItem *nhapItem = [self.nhapList objectAtIndex:indexPath.row];
    
    cell.nhapName.text = nhapItem.name;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    NSCalendar* calender = [NSCalendar currentCalendar];
    NSDateComponents* today = [calender components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:[NSDate date]];
    NSDateComponents* currentDate = [calender components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:nhapItem.createDate];
    NSString *dayPrefix = @"";
    if([today year] == [currentDate year] && [today month] == [currentDate month]){
        NSInteger diff = ([today day] - [currentDate day]);
        if(diff < 1){
            [dateFormat setDateFormat:@"hh:mm a"];
            dayPrefix = @"Today ";
        } else if(diff >= 1 || diff < 2){
            [dateFormat setDateFormat:@"hh:mm a"];
            dayPrefix = @"Yesterday ";
        } else {
            [dateFormat setDateFormat:@"dd/MM/yyyy hh:mm a"];
        }
    } else {
        [dateFormat setDateFormat:@"dd/MM/yyyy hh:mm a"];
    }
    cell.createDate.text = [dayPrefix stringByAppendingString:[dateFormat stringFromDate:nhapItem.createDate]];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // rows in section 0 should not be selectable
//    if ( indexPath.row == 0 ) return nil;
    
    return indexPath;
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NhapItem *nhapItem = [self.nhapList objectAtIndex:indexPath.row];
    if (nhapIndexOnMainView == indexPath.row) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ToggleTheMenuView" object:nil];
    } else {
        _index = indexPath.row;
        [self performSegueWithIdentifier:@"reloadWebview" sender:nhapItem.name];
    }
}

/* Add long-press event to cell
 */
-(void)onLongPress:(UILongPressGestureRecognizer*)pGesture
{
    if (pGesture.state == UIGestureRecognizerStateEnded) {
        UITableView* tableView = (UITableView*)self.view;
        CGPoint touchPoint = [pGesture locationInView:self.view];
        NSIndexPath* indexPath = [tableView indexPathForRowAtPoint:touchPoint];
        
        NhapItem *nhapItem = [self.nhapList objectAtIndex:indexPath.row];
        _index = indexPath.row;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"reloadWebview" sender:nhapItem.name];
        });
    }
}

/* Add long-press event to cell
 */
-(void)onDoubleTap:(UITapGestureRecognizer*)pGesture
{
    if (pGesture.state == UIGestureRecognizerStateEnded) {
        UITableView* tableView = (UITableView*)self.view;
        CGPoint touchPoint = [pGesture locationInView:self.view];
        NSIndexPath* indexPath = [tableView indexPathForRowAtPoint:touchPoint];
        
        NhapItem *nhapItem = [self.nhapList objectAtIndex:indexPath.row];
        _index = indexPath.row;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"reloadWebview" sender:nhapItem.name];
        });
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setMainViewNhapName:(NSNotification *)notification
{
    NSDictionary* userInfo = notification.userInfo;
    NSNumber *index = (NSNumber *)userInfo[@"index"];
    nhapIndexOnMainView = index.intValue;
}

- (void)refreshTableWithNotification:(NSNotification *)notification
{
    [self getAllData];
    [self.tableView reloadData];
    NSDictionary* userInfo = notification.userInfo;
    NSNumber *index = (NSNumber *)userInfo[@"index"];
    nhapIndexOnMainView = index.intValue;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"reloadWebview"]){
        UINavigationController *navCon = segue.destinationViewController;
        ViewController *viewController = [navCon viewControllers][0];
        viewController.selectedIndex = _index;
        viewController.currentAddress = sender;
    }
}

@end
