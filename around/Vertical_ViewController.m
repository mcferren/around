//
//  Vertical_ViewController.m
//  around
//
//  Created by Benjamin McFerren on 6/1/14.
//  Copyright (c) 2014 DePaul University. All rights reserved.
//

#import "Vertical_ViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface Vertical_ViewController ()

@end

@implementation Vertical_ViewController {
    
    NSMutableArray *array;
    //https://www.youtube.com/watch?v=jiiN9oFH3vE
    
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
	
    array = [[NSMutableArray alloc] init];
    
    [array addObject:@"Apple"];
    [array addObject:@"Is"];
    [array addObject:@"The"];
    [array addObject:@"Best"];
    [array addObject:@".com"];
    [array addObject:@":)"];
    [array addObject:@":)"];
    [array addObject:@":)"];
    [array addObject:@":)"];
    [array addObject:@":)"];
    [array addObject:@":)"];
    [array addObject:@":)"];
    [array addObject:@"Ben"];
    [array addObject:@"Is"];
    [array addObject:@"The"];
    [array addObject:@"Best"];
    [array addObject:@".com"];
    [array addObject:@":)"];
    [array addObject:@":)"];
    [array addObject:@":)"];
    [array addObject:@":)"];
    [array addObject:@":)"];
    [array addObject:@":)"];
    [array addObject:@":)"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Collection View Methods
-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    //    return 12;
    return [array count];
    
}


//https://www.youtube.com/watch?v=dqM2vIvr71I

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *) collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake(75.0f, 75.0f);
    
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return UIEdgeInsetsMake(20.0f, 15.0f, 15.0f, 15.0f);
    
}


//http://stackoverflow.com/questions/18649920/uicollectionview-current-visible-cell-index/18650210#18650210

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    NSLog(@"%@",@"boits");
    
    
    //    [collectionView]
    
    //    UICollectionView *coltView = (UICollectionView *)[NSObject viewWithTag:300];
    
    //    UICollectionView *coltView = (UICollectionView *)[cell viewWithTag:300];
    
    //    for (UICollectionViewCell *cell in [collectionView visibleCells]) {
    //        NSIndexPath *indexPath = [collectionView indexPathForCell:cell];
    //        NSLog(@"%@",indexPath);
    //    }
}

-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    UILabel *label = (UILabel *)[cell viewWithTag:100];
    UIImageView *avatar = (UIImageView *)[cell viewWithTag:200];
    
    label.text = [array objectAtIndex:indexPath.row];
    
    UIImage *image = [UIImage imageNamed:@"couise"];
    [avatar setImage:image];
    
    [avatar.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [avatar.layer setBorderWidth: 2.0f];
    [avatar.layer setCornerRadius:34.5f];
    
    [cell.layer setBorderWidth:2.0f];
    [cell.layer setBorderColor:[UIColor blueColor].CGColor];
    [cell.layer setCornerRadius:37.5f];
    
    return cell;
    
}


@end

