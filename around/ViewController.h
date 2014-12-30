//
//  ViewController.h
//  around
//
//  Created by Benjamin McFerren on 5/31/14.
//  Copyright (c) 2014 DePaul University. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <FacebookSDK/FacebookSDK.h>

@interface ViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, FBLoginViewDelegate>

// these are outlets presented in the view
@property (strong, nonatomic) IBOutlet UIView *viewWrapper;
@property (weak, nonatomic) IBOutlet UICollectionView *topHorizontalLane;
@property (weak, nonatomic) IBOutlet UICollectionView *midHorizontalLane;
@property (weak, nonatomic) IBOutlet UICollectionView *lowHorizontalLane;
@property (weak, nonatomic) IBOutlet UICollectionView *leftVerticalLane;
@property (weak, nonatomic) IBOutlet UICollectionView *centerVerticalLane;
@property (weak, nonatomic) IBOutlet UICollectionView *rightVerticalLane;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;


@end
