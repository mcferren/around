//
//  Points_ViewController.m
//  around
//
//  Created by Benjamin McFerren on 6/9/14.
//  Copyright (c) 2014 DePaul University. All rights reserved.
//

#import "Points_ViewController.h"
#import "PointSet_Factory.h"
#import "Profile_Factory.h"
#import <QuartzCore/QuartzCore.h>

@interface Points_ViewController ()

// these are factory objects that we'll use their accesor methods
@property (strong, nonatomic) PointSet_Factory *pointsetFactoryObject;
@property (strong, nonatomic) Profile_Factory *profileFactoryObject;

@end

@implementation Points_ViewController {
    
    // this is the data source associated wiht the UICollection View
    NSMutableArray *friendsArray;
    
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
    
    // populate local factory objects
    self.pointsetFactoryObject = [PointSet_Factory sharedPointSetFactory];
    self.profileFactoryObject = [Profile_Factory sharedProfileFactory];
    
    // populate uicollectionview datasource
    friendsArray = [NSMutableArray arrayWithArray:_profileFactoryObject.profiles];
    
//    NSMutableDictionary *user_pointset = [_pointsetFactoryObject returnPointSetByProfileID:1];
//    
//    for(id key in friendsArray) {
//        
////        NSLog(@"key %@", key);
//        if(user_pointset[key[@"profile_ID"]]) {
//            NSLog(@"user_pointset %lu", (unsigned long)[user_pointset[key[@"profile_ID"]] count]);
////            [key setObject:[NSString stringWithFormat:@"%d",[user_pointset[key[@"profile_ID"]] count]]
////                    forKey:@"sharedpoints"];
//        }
//    }
//    
//    NSLog(@"AFTER-friendArray %@", friendsArray);
    
    // HERE ITERATE AND POPULATE EACH OBJECT IN THE FRIENDSARRAY WITH A POINTS PROPERTY
    
    // SORT ARRAY BY POINTS PROPERTY
}

- (void)viewWillAppear:(BOOL)animated {
    
    // refresh local factory objects
    self.pointsetFactoryObject = [PointSet_Factory sharedPointSetFactory];
    self.profileFactoryObject = [Profile_Factory sharedProfileFactory];
    
    // refresh uicollectionview datasource
    [friendsArray addObjectsFromArray:_profileFactoryObject.profiles];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Collection View Methods
-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    // used by layout view
    return 1;
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    // used by uicollection view to instantiate cells
    return [friendsArray count];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *) collectionViewLayout  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    // use Quartz to customize items in layout
    return CGSizeMake(63.0f, 63.0f);
    
}

// this method programmatically adjust the layout of the uicollectionviews
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return UIEdgeInsetsMake(20.0f, 15.0f, 15.0f, 15.0f);
}

//protocal method to determine makeup of a cell
-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FriendCell" forIndexPath:indexPath];
    
    UIImageView *avatar;
    UILabel *label;
    UIImage *image;
    UILabel *points;
    
    label = (UILabel *)[cell viewWithTag:100];
    avatar = (UIImageView *)[cell viewWithTag:200];
    points = (UILabel *)[cell viewWithTag:300];
    label.text = [friendsArray objectAtIndex:indexPath.row][@"name"];
    image = [UIImage imageNamed:[friendsArray objectAtIndex:indexPath.row][@"avatar"]];
    
    NSString  *friend_id = [friendsArray objectAtIndex:indexPath.row][@"profile_ID"];
    NSDictionary *user_pointset = [_pointsetFactoryObject returnPointSetByProfileID:1];
    
    if(user_pointset[friend_id]) {
        points.text = [NSString stringWithFormat:@"%d",[user_pointset[friend_id] count]];
    } else {
        points.text = @"";
    }
    
    [avatar setImage:image];
    
    // quartz coloring
    [avatar.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [avatar.layer setBorderWidth: 2.0f];
    [avatar.layer setCornerRadius:28.5f];
    
    
    [cell.layer setBorderColor:[UIColor blueColor].CGColor];
    [cell.layer setBorderWidth:2.0f];
    [cell.layer setCornerRadius:31.5f];
    
    return cell;
    
}

@end
