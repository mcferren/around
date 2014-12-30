//
//  ViewController.m
//  around
//
//  Created by Benjamin McFerren on 5/31/14.
//  Copyright (c) 2014 DePaul University. All rights reserved.
//

#import "ViewController.h"
#import "Profile_Factory.h"
#import "Profile_DAO.h"
#import "Game_Board.h"
#import "User_Session.h"
#import "Answer_Factory.h"
#import "Question_Factory.h"
#import "PointSet_Factory.h"
#import <QuartzCore/QuartzCore.h>
#import <AFNetworking/UIKit+AFNetworking.h>
#import <Nimbus/NIAttributedLabel.h>
#import <SAMCategories/UIScreen+SAMAdditions.h>

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, NIAttributedLabelDelegate>

    // these are factories and singletons used to persist data from plist files
    @property (strong, nonatomic) Profile_Factory *profileFactoryObject;
    @property (strong, nonatomic) Game_Board *gameBoardObject;
    @property (strong, nonatomic) User_Session *userSessionObject;
    @property (strong, nonatomic) Answer_Factory *answerFactoryObject;
    @property (strong, nonatomic) Question_Factory *questionFactoryObject;
    @property (strong, nonatomic) PointSet_Factory *pointsetFactoryObject;

    @property (strong, nonatomic) IBOutlet UILabel *nameLabel;
    @property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePictureView;
    @property (nonatomic, strong) NSArray *jsonResponse;

@end

@implementation ViewController {
    
    //https://www.youtube.com/watch?v=jiiN9oFH3vE
    
    // these are the datasources for the UICollectionViews
    NSMutableArray *topRowArray;
    NSMutableArray *midRowArray;
    NSMutableArray *lowRowArray;
    NSMutableArray *leftColumnArray;
    NSMutableArray *centerColumnArray;
    NSMutableArray *rightColumnRowArray;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
//    Profile_DAO *client = [Profile_DAO sharedClient];
    
//    [client getShowsForDate:[NSDate date]
//                   username:@"rwtestuser"
//               numberOfDays:3
//                    success:^(NSURLSessionDataTask *task, id responseObject) {
//                        //                        NSLog(@"Success -- %@", responseObject);
//                        
//                        
//                        // Save response object
//                        self.jsonResponse = responseObject;
////                        NSLog(@"AFNET: %@", responseObject);
//                        
//                        
//                    }
//                    failure:^(NSURLSessionDataTask *task, NSError *error) {
//                        NSLog(@"Failure -- %@", error);
//                    }];
    
    FBLoginView *loginView = [[FBLoginView alloc] init];
    [[self.view viewWithTag:888] addSubview:loginView];
    
    [loginView setReadPermissions:@[@"public_profile", @"user_likes", @"user_friends"]];
    [loginView setDelegate:self];
    
    // make sure these objects have the most up to date data
    self.profileFactoryObject  = [Profile_Factory sharedProfileFactory];
    self.gameBoardObject       = [Game_Board sharedGameBoard];
    self.userSessionObject     = [User_Session sharedUserSession];
    self.answerFactoryObject   = [Answer_Factory sharedAnswerFactory];
    self.questionFactoryObject = [Question_Factory sharedQuestionFactory];
    self.pointsetFactoryObject = [PointSet_Factory sharedPointSetFactory];
    
    // randomly add 29 objects
    topRowArray         = [_profileFactoryObject returnProfiles:29];
    midRowArray         = [_profileFactoryObject returnProfiles:29];
    lowRowArray         = [_profileFactoryObject returnProfiles:29];
    leftColumnArray     = [_profileFactoryObject returnProfiles:29];
    centerColumnArray   = [_profileFactoryObject returnProfiles:29];
    rightColumnRowArray = [_profileFactoryObject returnProfiles:29];
    
    // take off the colors used in dev mode
    [_topHorizontalLane  setBackgroundColor:[UIColor whiteColor]];
    [_midHorizontalLane  setBackgroundColor:[UIColor whiteColor]];
    [_lowHorizontalLane  setBackgroundColor:[UIColor whiteColor]];
    [_leftVerticalLane   setBackgroundColor:[UIColor whiteColor]];
    [_centerVerticalLane setBackgroundColor:[UIColor whiteColor]];
    [_rightVerticalLane  setBackgroundColor:[UIColor whiteColor]];
    
    // prepare event listeners for each lane
    [self gesturizer:_topHorizontalLane];
    [self gesturizer:_midHorizontalLane];
    [self gesturizer:_lowHorizontalLane];
    [self gesturizer:_leftVerticalLane];
    [self gesturizer:_centerVerticalLane];
    [self gesturizer:_rightVerticalLane];
    
    // set zposition for each of the lanes
    [self shuffleHorizontalonTop];
}

// This method will be called when the user information has been fetched after login
- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user {
    self.profilePictureView.profileID = user.id;
    self.nameLabel.text = user.name;
//    [self makeRequestForUserData];
}

// Implement the loginViewShowingLoggedOutUser: delegate method to modify your app's UI for a logged-out user experience
- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
    NSLog(@"User logged out");
    self.profilePictureView.profileID = nil;
    self.nameLabel.text = @"";
}

- (void) makeRequestForUserData {
    [FBRequestConnection startWithGraphPath:@"/me?fields=name,likes.fields(name,picture.width(300).height(300)).limit(500),friends.fields(name,picture.width(300).height(300)).limit(500)"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              
                              
                              if (!error) {
                                  // Success! Include your code to handle the results here
                                  NSMutableArray *zippy = [result objectForKey:@"data"];
//                                  NSLog(@"user FUNNY info: %@", zippy[@"id"]);
//                                  NSLog(@"user_id %@", result[@"id"]);
                                  
                                  NSError *error;
                                  NSData *jsonData = [NSJSONSerialization dataWithJSONObject:zippy
                                                                                     options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                                                       error:&error];
                                  NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                  
                                  // prepare for post
                                  NSObject * payload = @{ @"userid" : result[@"id"] };
//                                  NSLog(@"user_id %@", result[@"id"]);
                                  
                                  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                                  manager.requestSerializer = [AFJSONRequestSerializer serializer];
//                                  manager.responseSerializer = [AFJSONResponseSerializer serializer];
                                  
                                  
                                  [manager POST:@"https://thawing-mountain-1681.herokuapp.com/funky"
                                     parameters:payload
                                        success:^(AFHTTPRequestOperation *operation, id responseObject)
                                  {
                                      NSLog(@"JSON: %@", responseObject);
                                  }
                                        failure:
                                   ^(AFHTTPRequestOperation *operation, NSError *error) {
                                       NSLog(@"Error: %@", error);
                                   }];
                              } else {
                                  // An error occurred, we need to handle the error
                                  // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                  NSLog(@"error %@", error.description);
                              }
                              
                          }];
}

// You need to override loginView:handleError in order to handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures since that happen outside of the app.
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}


// Implement the loginViewShowingLoggedInUser: delegate method to modify your app's UI for a logged-in user experience
//- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
//    NSLog(@"User logged in");
//
//
//    // We will request the user's public picture and the user's birthday
//    // These are the permissions we need:
//    NSArray *permissionsNeeded = @[@"public_profile", @"user_likes", @"user_friends"];
//
//    // Request the permissions the user currently has
//    [FBRequestConnection startWithGraphPath:@"/me/permissions"
//                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                              if (!error){
//                                  // These are the current permissions the user has
//                                  NSDictionary *currentPermissions= [(NSArray *)[result data] objectAtIndex:0];
//
//                                  // We will store here the missing permissions that we will have to request
//                                  NSMutableArray *requestPermissions = [[NSMutableArray alloc] initWithArray:@[]];
//
//                                  // Check if all the permissions we need are present in the user's current permissions
//                                  // If they are not present add them to the permissions to be requested
//                                  for (NSString *permission in permissionsNeeded){
//                                      if (![currentPermissions objectForKey:permission]){
//                                          [requestPermissions addObject:permission];
//                                      }
//                                  }
//
//                                  // If we have permissions to request
//                                  if ([requestPermissions count] > 0){
//                                      // Ask for the missing permissions
//                                      [FBSession.activeSession
//                                       requestNewReadPermissions:requestPermissions
//                                       completionHandler:^(FBSession *session, NSError *error) {
//                                           if (!error) {
//                                               // Permission granted, we can request the user information
//                                               [self makeRequestForUserData];
//                                           } else {
//                                               // An error occurred, we need to handle the error
//                                               // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
//                                               NSLog(@"error %@", error.description);
//                                           }
//                                       }];
//                                  } else {
//                                      // Permissions are present
//                                      // We can request the user information
//                                      [self makeRequestForUserData];
//                                  }
//
//                              } else {
//                                  // An error occurred, we need to handle the error
//                                  // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
//                                  NSLog(@"error %@", error.description);
//                              }
//                          }];
//
//
//
//
//}

- (void) gesturizer:(UICollectionView*)lane {
    
    // listen for vertical swipes to happen on the horizontal lanes
    UISwipeGestureRecognizer *upSwipe_on_lane    = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(reportUpSwipe:)];
    UISwipeGestureRecognizer *downSwipe_on_lane  = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(reportDownSwipe:)];
    UISwipeGestureRecognizer *leftSwipe_on_lane  = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(reportLeftSwipe:)];
    UISwipeGestureRecognizer *rightSwipe_on_lane = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(reportRightSwipe:)];
    
    upSwipe_on_lane.direction    = UISwipeGestureRecognizerDirectionUp;
    downSwipe_on_lane.direction  = UISwipeGestureRecognizerDirectionDown;
    leftSwipe_on_lane.direction  = UISwipeGestureRecognizerDirectionLeft;
    rightSwipe_on_lane.direction = UISwipeGestureRecognizerDirectionRight;
    
    [lane addGestureRecognizer:upSwipe_on_lane];
    [lane addGestureRecognizer:downSwipe_on_lane];
    [lane addGestureRecognizer:leftSwipe_on_lane];
    [lane addGestureRecognizer:rightSwipe_on_lane];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    // refresh local instance from singleton/factory
    self.profileFactoryObject  = [Profile_Factory sharedProfileFactory];
    self.answerFactoryObject   = [Answer_Factory sharedAnswerFactory];
    self.questionFactoryObject = [Question_Factory sharedQuestionFactory];
    self.pointsetFactoryObject = [PointSet_Factory sharedPointSetFactory];
    self.gameBoardObject       = [Game_Board sharedGameBoard];
    self.userSessionObject     = [User_Session sharedUserSession];
    
    // center the elements inside the scrollers
    [_topHorizontalLane scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:(NSInteger)15 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    [_midHorizontalLane scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:(NSInteger)15 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    [_lowHorizontalLane scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:(NSInteger)15 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    [_leftVerticalLane scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:(NSInteger)15 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    [_centerVerticalLane scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:(NSInteger)15 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    [_rightVerticalLane scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:(NSInteger)15 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    
    // set zposition for each of the lanes
    [self shuffleHorizontalonTop];
    
}


- (void) flick:(UICollectionView *)lane :(int)direction {
    
    NSArray *visibleItems = [lane indexPathsForVisibleItems];
    NSIndexPath *currentItem = [visibleItems objectAtIndex:0];
    NSIndexPath *nextItem;
    
    if(direction == 1) { // up
        nextItem = [NSIndexPath indexPathForItem:currentItem.item + 6 inSection:currentItem.section];
        [lane scrollToItemAtIndexPath:nextItem atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
        
        
    } else if(direction == 2) { // down
        nextItem = [NSIndexPath indexPathForItem:currentItem.item - 6 inSection:currentItem.section];
        [lane scrollToItemAtIndexPath:nextItem atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
        
        
    } else if(direction == 3) { // left
        nextItem = [NSIndexPath indexPathForItem:currentItem.item + 6 inSection:currentItem.section];
        [lane scrollToItemAtIndexPath:nextItem atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        
        
    } else if(direction == 4) { // right
        nextItem = [NSIndexPath indexPathForItem:currentItem.item - 6 inSection:currentItem.section];
        [lane scrollToItemAtIndexPath:nextItem atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
        
        
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"Touches Began %@", touches);
}


- (void)reportUpSwipe:(UIGestureRecognizer *)recognizer {
    
    CGPoint pt = [recognizer locationOfTouch:0 inView:_viewWrapper];
    
    switch (recognizer.view.tag) {
            
        case 300:
        case 400:
        case 500:

            if(pt.x > 25 && pt.x < 115) {
                
                [self flick:_leftVerticalLane :1];
                [self shuffleVerticalonTop];
                
            } else if(pt.x > 115 && pt.x < 205) {
                
                [self flick:_centerVerticalLane :1];
                [self shuffleVerticalonTop];
                
            } else if(pt.x > 205 && pt.x < 295) {
                
                [self flick:_rightVerticalLane :1];
                [self shuffleVerticalonTop];
                
            }
            break;
            
        case 600:
            [self flick:_leftVerticalLane :1];
            [self shuffleVerticalonTop];
            break;
          
        case 700:
            [self flick:_centerVerticalLane :1];
            [self shuffleVerticalonTop];
            break;
          
        case 800:
            [self flick:_rightVerticalLane :1];
            [self shuffleVerticalonTop];
            break;
          
        default:
            break;
            
    }
}


- (void)reportDownSwipe:(UIGestureRecognizer *)recognizer {
    
    CGPoint pt = [recognizer locationOfTouch:0 inView:_viewWrapper];
    
    switch (recognizer.view.tag) {
            
        case 300:
        case 400:
        case 500:
            
            if(pt.x > 25 && pt.x < 115) {
                
                [self flick:_leftVerticalLane :2];
                [self shuffleVerticalonTop];
                
            } else if(pt.x > 115 && pt.x < 205) {
                
                [self flick:_centerVerticalLane :2];
                [self shuffleVerticalonTop];
                
            } else if(pt.x > 205 && pt.x < 295) {
                
                [self flick:_rightVerticalLane :2];
                [self shuffleVerticalonTop];
                
            }
            break;
            
        case 600:
            [self flick:_leftVerticalLane :2];
            [self shuffleVerticalonTop];
            break;
            
        case 700:
            [self flick:_centerVerticalLane :2];
            [self shuffleVerticalonTop];
            break;
            
        case 800:
            [self flick:_rightVerticalLane :2];
            [self shuffleVerticalonTop];
            break;
            
        default:
            break;
            
    }
}


- (void)reportLeftSwipe:(UIGestureRecognizer *)recognizer {
    
    CGPoint pt = [recognizer locationOfTouch:0 inView:_viewWrapper];
    
    switch (recognizer.view.tag) {
            
        case 300:
            [self flick:_topHorizontalLane :3];
            [self shuffleHorizontalonTop];
            break;
            
        case 400:
            [self flick:_midHorizontalLane :3];
            [self shuffleHorizontalonTop];
            break;
            
        case 500:
            [self flick:_lowHorizontalLane :3];
            [self shuffleHorizontalonTop];
            break;
            
        case 600:
        case 700:
        case 800:
            
            if(pt.y > 90 && pt.y < 180) {
                
                [self flick:_topHorizontalLane :3];
                [self shuffleHorizontalonTop];
                
            } else if(pt.y > 180 && pt.y < 270) {
                
                [self flick:_midHorizontalLane :3];
                [self shuffleHorizontalonTop];
                
            } else if(pt.y > 270 && pt.y < 360) {
                
                [self flick:_lowHorizontalLane :3];
                [self shuffleHorizontalonTop];
                
            }
            break;
            
        default:
            break;
            
    }

}


- (void)reportRightSwipe:(UIGestureRecognizer *)recognizer {
    
    CGPoint pt = [recognizer locationOfTouch:0 inView:_viewWrapper];
    
    switch (recognizer.view.tag) {
            
        case 300:
            [self flick:_topHorizontalLane :4];
            [self shuffleHorizontalonTop];
            break;
            
        case 400:
            [self flick:_midHorizontalLane :4];
            [self shuffleHorizontalonTop];
            break;
            
        case 500:
            [self flick:_lowHorizontalLane :4];
            [self shuffleHorizontalonTop];
            break;
            
        case 600:
        case 700:
        case 800:
            
            if(pt.y > 90 && pt.y < 180) {
                
                [self flick:_topHorizontalLane :4];
                [self shuffleHorizontalonTop];
                
            } else if(pt.y > 180 && pt.y < 270) {
                
                [self flick:_midHorizontalLane :4];
                [self shuffleHorizontalonTop];
                
            } else if(pt.y > 270 && pt.y < 360) {
                
                [self flick:_lowHorizontalLane :4];
                [self shuffleHorizontalonTop];
                
            }
            break;
            
        default:
            break;
            
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)shuffleVerticalonTop {

    [_viewWrapper bringSubviewToFront:_leftVerticalLane];
    [_viewWrapper bringSubviewToFront:_centerVerticalLane];
    [_viewWrapper bringSubviewToFront:_rightVerticalLane];
    
    [_viewWrapper sendSubviewToBack:_topHorizontalLane];
    [_viewWrapper sendSubviewToBack:_midHorizontalLane];
    [_viewWrapper sendSubviewToBack:_lowHorizontalLane];
}

- (void)shuffleHorizontalonTop {

    [_viewWrapper bringSubviewToFront:_topHorizontalLane];
    [_viewWrapper bringSubviewToFront:_midHorizontalLane];
    [_viewWrapper bringSubviewToFront:_lowHorizontalLane];
    
    [_viewWrapper sendSubviewToBack:_leftVerticalLane];
    [_viewWrapper sendSubviewToBack:_centerVerticalLane];
    [_viewWrapper sendSubviewToBack:_rightVerticalLane];
}


#pragma mark Collection View Methods

// triggers at first scroll so we can judge if horizontal motion on vertical object
// and vice versa. This is used to determine the z-position
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
//    NSLog(@"POOOOOS");
}


-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    // need for view to render
    return 1;
}

// protocal method used to determine how many elements for the UICollection view to work with
-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    //http://stackoverflow.com/questions/3080540/finding-maximum-numeric-value-in-nsarray
    
//    Would like to analyze one viewcolelciton in the future as a way to ensure
//    that all array's maintain the same size.
    
//    NSMutableArray *compareArray = [[NSMutableArray alloc] init];
//    
//    [compareArray addObject:[NSNumber numberWithInteger:[topRowArray count]]];
//    [compareArray addObject:[NSNumber numberWithInteger:[midRowArray count]]];
//    [compareArray addObject:[NSNumber numberWithInteger:[bottomRowArray count]]];
//    
//    NSLog(@"kortz %d", [[compareArray valueForKeyPath:@"@max.intValue"] intValue]);
//    return [[compareArray valueForKeyPath:@"@max.intValue"] intValue];

    
    switch (collectionView.tag)
    {
        case 300:
            return [topRowArray count];
            break;
        case 400:
            return [midRowArray count];
            break;
        case 500:
            return [lowRowArray count];
            break;
        case 600:
            return [leftColumnArray count];
            break;
        case 700:
            return [centerColumnArray count];
            break;
        case 800:
            return [rightColumnRowArray count];
            break;
        default:
            return 1;
            break;
    }
}


// this method programmatically adjust the layout of the uicollectionviews using Quartz
//https://www.youtube.com/watch?v=dqM2vIvr71I

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *) collectionViewLayout  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    // size of profile coins
    return CGSizeMake(70.0f, 70.0f);
    
}

// this method programmatically adjust the layout of the uicollectionviews
//-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForItemAtIndexPath:(NSIndexPath *)indexPath{
//    
//    return UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
//    
//}


// this is used to communicate with the Game_Board singleton and update the piece positions
- (void)updateLane:(UICollectionView *)collectionView :(int)laneStartIndex {
    
    NSArray * dataSource = @[];
    
           if(laneStartIndex == 0) {
               dataSource = topRowArray;
    } else if(laneStartIndex == 3) {
               dataSource = midRowArray;
    } else if(laneStartIndex == 6) {
               dataSource = lowRowArray;
    }
    
    // set of three pieces
    NSMutableDictionary *lane = [[NSMutableDictionary alloc] init];
    
    NSIndexPath *indexPath;
    NSString *cellProfileID;
    UICollectionViewCell *minCell = nil;
    NSInteger minCellIndexPath = 0;
    
    // visible cells are indexed by their position in the datasource array
    for (UICollectionViewCell *cell in [collectionView visibleCells]) {
        
        indexPath = [collectionView indexPathForCell:cell];
        cellProfileID = [dataSource objectAtIndex:indexPath.row][@"profile_ID"];
        
        // need to establish mincell so we can walk the index later when we reach the gameboard
        if(minCell == nil) {
            minCell = cell;
            minCellIndexPath = [collectionView indexPathForCell:cell].row;
        } else if((long)[collectionView indexPathForCell:cell].row <
                  (long)[collectionView indexPathForCell:minCell].row) {
            minCell = cell;
            minCellIndexPath = [collectionView indexPathForCell:cell].row;
        }
        
        [lane setObject:[NSNumber numberWithInteger:[cellProfileID intValue]]
                 forKey:[NSString stringWithFormat:@"%d",indexPath.row]];
    }
    
    // send the lane information packaged in an object
    [_gameBoardObject updateBoard:lane :minCellIndexPath :laneStartIndex];
    
    [lane removeAllObjects];
    
}

// clean up so we can get rid of previously matched coins
- (void)deleteCellsfromUICollectionView:(int)boardClue :(int)landIndex {
    
    if(boardClue < 3) { // we must determine when row to deal with
        [topRowArray removeObjectAtIndex:landIndex];
        [_topHorizontalLane deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:landIndex inSection:0]]];
    } else if(boardClue >= 3 && boardClue < 6) {
        [midRowArray removeObjectAtIndex:landIndex]; // update datasource and view cells
        [_midHorizontalLane deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:landIndex inSection:0]]];
    } else if(boardClue >= 6) {
        [lowRowArray removeObjectAtIndex:landIndex];
        [_lowHorizontalLane deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:landIndex inSection:0]]];
    }
    
}



    //http://stackoverflow.com/questions/18649920/uicollectionview-current-visible-cell-index/18650210#18650210

// this triggers a series of events, updates the board, and checks if there is a three in a row match
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [self updateLane:_topHorizontalLane :0];
    [self updateLane:_midHorizontalLane :3];
    [self updateLane:_lowHorizontalLane :6];
    
    // if match, it returns inof on positioning nad the profile associated with the coin
    NSArray *matchArray = [_gameBoardObject checkBoard];
    
    if([matchArray count] > 0){ // else 0
        
        NSLog(@"!!!!!!!!Eureka!!!!!!!!!");
        
        NSMutableArray *matchProfile_ids = [[NSMutableArray alloc] init];
        // an array just in case we need to operate on multiple matches later
        
        for(int i = 0; i < [matchArray count]; ++i) {

            [matchProfile_ids addObject:matchArray[i][@"profileid"]];
            
            for(int j = [matchArray[i][@"indextriple"] count]; j > 0; --j ) { // needs to decrement backwards to preserve indices
                
                [self deleteCellsfromUICollectionView:[matchArray[i][@"indextriple"][j - 1][@"boardindex"] intValue]
                                                     :[matchArray[i][@"indextriple"][j - 1][@"laneindex"] intValue] - 1];
            }
        }
        
        [self handleEurekaTrigger:[matchProfile_ids[0][0] intValue]]; // temp - we'll eventually loop to handle muliple matches
        return;
    }
    
    // this is used to dynamically generate new coins and pop them on the right when scroll the opposite direction and vice versa
//    NSMutableArray *newbatch = [_profileFactoryObject returnProfiles:3];
    
//    for(int i = 0; i < [newbatch count]; ++i) {
//        [topRowArray addObject:newbatch[i]];
//    }
    
//    NSLog(@"BEFORErally %lu", (unsigned long)[topRowArray count]);
    
    NSMutableArray *newbatch = [_profileFactoryObject returnProfiles:1];
    
    // for now I just create three generic in order for the user to successfully spawn a match and receive a question
    [topRowArray addObject:@{@"profile_ID":newbatch[0][@"profile_ID"],
                             @"name":newbatch[0][@"name"],
                             @"avatar":newbatch[0][@"avatar"]
                             }];
    [midRowArray addObject:@{@"profile_ID":newbatch[0][@"profile_ID"],
                             @"name":newbatch[0][@"name"],
                             @"avatar":newbatch[0][@"avatar"]
                             }];
    [lowRowArray addObject:@{@"profile_ID":newbatch[0][@"profile_ID"],
                             @"name":newbatch[0][@"name"],
                             @"avatar":newbatch[0][@"avatar"]
                             }];
    
    
//    NSLog(@"AFTERrally %lu", (unsigned long)[topRowArray count]);
//    NSLog(@"ItemCount %lu", (long)[_topHorizontalLane numberOfItemsInSection:0]);
    
    // updates the view one at a time because I couldn't figure out how to do them all together in one batch
    [_topHorizontalLane insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:[topRowArray count]-1 inSection:0]]];
    [_midHorizontalLane insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:[midRowArray count]-1 inSection:0]]];
    [_lowHorizontalLane insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:[lowRowArray count]-1 inSection:0]]];
    
    //http://stackoverflow.com/questions/12656648/uicollectionview-performing-updates-using-performbatchupdates
    //http://stackoverflow.com/questions/15572462/how-to-insert-cell-in-uicollectionview-programatically
    
//    [self.collectionView performBatchUpdates:^{
//        for (id item in newbatch) {
//            [_topHorizontalLane insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:[topRowArray count]-1 inSection:0]]];
//        }
//    }];
//    [self.collectionView insertItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
    
    
//    [self.collectionView performBatchUpdates:^{
//        // Insert the cut/copy items into data source as well as collection view
//        for (id item in self.selectedItems) {
//            // update your data source array
//            [self.images insertObject:item atIndex:indexPath.row];
//            
//            [self.collectionView insertItemsAtIndexPaths:
//             [NSArray arrayWithObject:indexPath]];
//        }
//    }
    
     
     //
     //    if(self.collectionView.tag==300){
     //
     //        
     //    } else {
     //        
     //        
     //    }
    
    
//    
//    //http://stackoverflow.com/questions/19199985/invalid-update-invalid-number-of-items-on-uicollectionview
//    if ([topRowArray count] == 1) {
//        [_topHorizontalLane reloadData];
//    } else {
//        [_topHorizontalLane insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:   ([topRowArray count] -1) inSection:0]]];
//    }
     
}

// this method fulfills the protocal and tells the UICollectionView how to build a cell
-(UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    
    UIImageView *avatar;
    UILabel *label;
    UIImage *image;
    
    // identify outlets from view
    label = (UILabel *)[cell viewWithTag:100];
    avatar = (UIImageView *)[cell viewWithTag:200];
    
    //http://stackoverflow.com/questions/15813623/multiple-collectionviews-on-same-screen-in-ios
//    if(collectionView.tag==300){
//        label.text = [topRowArray objectAtIndex:indexPath.row][@"name"];
//        [cell.layer setBorderColor:[UIColor blueColor].CGColor];
//        image = [UIImage imageNamed:[topRowArray objectAtIndex:indexPath.row][@"avatar"]];
//    } else {
//        label.text = [topRowArray objectAtIndex:indexPath.row][@"name"];
//        [cell.layer setBorderColor:[UIColor redColor].CGColor];
//        image = [UIImage imageNamed:@"1236_image"];
//    }
    
    switch (collectionView.tag) // testing on which UICollectionView
    {
        case 300:
            label.text = [topRowArray objectAtIndex:indexPath.row][@"name"];
            image = [UIImage imageNamed:[topRowArray objectAtIndex:indexPath.row][@"avatar"]];
            break;
        case 400:
            label.text = [midRowArray objectAtIndex:indexPath.row][@"name"];
            image = [UIImage imageNamed:[midRowArray objectAtIndex:indexPath.row][@"avatar"]];
            break;
        case 500:
            label.text = [lowRowArray objectAtIndex:indexPath.row][@"name"];
            image = [UIImage imageNamed:[lowRowArray objectAtIndex:indexPath.row][@"avatar"]];
            break;
        case 600:
            label.text = [leftColumnArray objectAtIndex:indexPath.row][@"name"];
            image = [UIImage imageNamed:[leftColumnArray objectAtIndex:indexPath.row][@"avatar"]];
            break;
        case 700:
            label.text = [centerColumnArray objectAtIndex:indexPath.row][@"name"];
            image = [UIImage imageNamed:[centerColumnArray objectAtIndex:indexPath.row][@"avatar"]];
            break;
        case 800:
            label.text = [rightColumnRowArray objectAtIndex:indexPath.row][@"name"];
            image = [UIImage imageNamed:[rightColumnRowArray objectAtIndex:indexPath.row][@"avatar"]];
            break;
        default:
            label.text = [topRowArray objectAtIndex:indexPath.row][@"name"];
            image = [UIImage imageNamed:[topRowArray objectAtIndex:indexPath.row][@"avatar"]];
            break;
    }
    
    [avatar setImage:image];
    
    // some Quartz editing
    [avatar.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [avatar.layer setBorderWidth: 2.0f];
    [avatar.layer setCornerRadius:31.5f];
    
    // decorating the coins circle
    [cell.layer setBorderColor:[UIColor blueColor].CGColor];
    [cell.layer setBorderWidth:2.0f];
    [cell.layer setCornerRadius:34.5f];
    
    return cell;
    
}



// this is a simple action sheet return that is invoked from the conditions above
- (IBAction)handleEurekaTrigger:(int)matchprofileid {
    
    // get object from answers singleton to match this profile id - - return questionID
    // use questionid to get question string and multipl choice strings
    
    NSDictionary *matchAnswers = [_answerFactoryObject returnAnswersByProfileID:matchprofileid];
    NSDictionary *matchProfileObject = [_profileFactoryObject returnProfilebyId:matchprofileid];
    
    int question_id = [_userSessionObject findQuestion_ID:matchAnswers];
    
    
    // simple lookup with the question id to create a local question object
    NSDictionary *targetQuestionObject;
    if(question_id == 0) {
        targetQuestionObject = nil;
    } else {
        targetQuestionObject = [_questionFactoryObject returnQuestionByQuestionID:question_id];
    }
    
//    
//    NSLog(@"question %@", targetQuestionObject[@"question"]);
//    
//    NSLog(@"question_id %d", question_id);
//    NSLog(@"HAOWDYHOE %@", matchAnswers[@"1124"]);
//    NSLog(@"Neighbor %@", matchProfileObject[@"name"]);
//    NSLog(@"RIGHT_ANSWER %@", targetQuestionObject[@"correct_answer"]);
//    NSLog(@"FRIENDS_ANSWER %@", matchAnswers[[NSString stringWithFormat:@"%d",question_id]]);
    
    // fire off action sheet with data from targetQuestionObject
    if(targetQuestionObject != nil) {
        
        UIActionSheet *actionSheet =
        [[UIActionSheet alloc]
         initWithTitle:targetQuestionObject[@"question"]
         delegate:self
         cancelButtonTitle:nil
         destructiveButtonTitle:nil
         otherButtonTitles:nil];
        
        for(NSString *key in targetQuestionObject[@"options"]) {
            [actionSheet addButtonWithTitle:key];
        }
        
        [actionSheet addButtonWithTitle:@"I'd rather not answer"];
        // Set cancel button index to the one we just added so that we know which one it is in delegate call
        actionSheet.destructiveButtonIndex = actionSheet.numberOfButtons-1;
        
        // concatenate question id and match_answer and pass to the responder
        NSString *friendsAnswer = matchAnswers[[NSString stringWithFormat:@"%d",question_id]];
        NSString *compressedArgumentVariable = [NSString stringWithFormat:@"%d%d%@",
                                                    question_id,
                                                    matchprofileid,
                                                    friendsAnswer];
        
        actionSheet.tag = [compressedArgumentVariable intValue];

        [actionSheet showInView:self.view];
        
    } else {
        
        NSString *msg = nil;
        
        msg = [NSString stringWithFormat:@"%@ doesn't have any questions that you haven't answered yet",matchProfileObject[@"name"]];
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@""
                              message:msg
                              delegate:self
                              cancelButtonTitle:@"Ok, I'll keep playing"
                              otherButtonTitles:nil];
        [alert show];
        
    }
    
}


//http://ajnaware.wordpress.com/2011/02/26/dynamically-adding-uiactionsheet-buttons/

// simple method to respond to action sheet button taps and gage if nswer is a match
- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.cancelButtonIndex) { return; }
    
    NSString *argumentOperator = [NSString stringWithFormat:@"%d",actionSheet.tag];
    
    int questionID = [[argumentOperator substringToIndex:[argumentOperator length] - 5] intValue];
    NSDictionary *targetQuestionObject = [_questionFactoryObject returnQuestionByQuestionID:questionID];
    
    NSString *temp = [argumentOperator substringFromIndex:[argumentOperator length] - 5];
    int friendID = [[temp substringToIndex:[argumentOperator length] - 5] intValue];
    NSDictionary *matchProfileObject = [_profileFactoryObject returnProfilebyId:friendID];
    
    int friendsAnswer = [[argumentOperator substringFromIndex:[argumentOperator length] - 1] intValue];
    int userAnswer = buttonIndex;
    int correctAnswer = [targetQuestionObject[@"correct_answer"] intValue];
    
    // update the user's answers list
    [_userSessionObject addAnswer:questionID :userAnswer];
    
    //[_answerFactoryObject returnQuestionFromClipboard]
    if(userAnswer == friendsAnswer) {
        
        // <- <- <- HERE IS WHERE YOU UPDATE USER's STATS and MATCHES STATS
        NSDictionary *point = @{
                                @"child" : @"1",
                                @"matching_answer" : [NSString stringWithFormat:@"%d",friendsAnswer],
                                @"parent" : [NSString stringWithFormat:@"%d",friendID],
                                @"point_type" : @"0",
                                @"point_value" : @"1",
                                @"question_id" : [NSString stringWithFormat:@"%d",questionID]
                              };
        
        // be sure to update the singleton factory so other views can be up to date
        [_pointsetFactoryObject pushPoint:point :1 :friendID];
        [_pointsetFactoryObject pushPoint:point :friendID :1];
        
        NSString *msg = nil;
        NSString *title = nil;
        
        title = [NSString stringWithFormat:@"Earned %d points", 2];

        msg = [NSString stringWithFormat:@"YAH! You and %@ both answered: %@",
                                        matchProfileObject[@"name"],
                                        targetQuestionObject[@"options"][friendsAnswer]];
        // fire off congrats alert
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"hoopla"
                              message:msg
                              delegate:self
                              cancelButtonTitle:@"Great - Let's Keep Playing"
                              otherButtonTitles:nil];
        [alert show];
    }
    
    // perhaps for more points in the future
    if(userAnswer == correctAnswer) {
        
//        NSString *msg = nil;
//        NSString *title = nil;
//        
//        title = [NSString stringWithFormat:@"Earned %d points", 3];
//        
//        msg = [NSString stringWithFormat:@"BINGO! You answered correctly! %@",
//               targetQuestionObject[@"options"][friendsAnswer]];
//        
//        UIAlertView *alert = [[UIAlertView alloc]
//                              initWithTitle:title
//                              message:msg
//                              delegate:self
//                              cancelButtonTitle:@"Great - Let's Keep Playing"
//                              otherButtonTitles:nil];
//        [alert show];
    }
    
}

// this responds to an actionsheet button tap
//- (void)actionSheet:(UIActionSheet *)actionSheet
//didDismissWithButtonIndex:(NSInteger)buttonIndex {
//    if (buttonIndex != [actionSheet cancelButtonIndex]) {
//        
//        
//        NSString *msg = nil;
//        
//        msg = @"confirming that the current operation has been stopped and the requested operation proceeds";
//        UIAlertView *alert = [[UIAlertView alloc]
//                              initWithTitle:@"Force Complete"
//                              message:msg
//                              delegate:self
//                              cancelButtonTitle:@"Ok"
//                              otherButtonTitles:nil];
//        [alert show];
//    }
//}


// this responds to the alert / / I want to test these for future use
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == [alertView cancelButtonIndex]) {
        
        //- (void)populateAnswers from USER_SESSION after you addnewanswers to the AnswerFactory object
        
    }
    
}


@end
