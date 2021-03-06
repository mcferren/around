//
//  Ask_ViewController.h
//  around
//
//  Created by Benjamin McFerren on 6/9/14.
//  Copyright (c) 2014 DePaul University. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <FacebookSDK/FacebookSDK.h>

@interface Ask_ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, FBLoginViewDelegate>

// these are outlets in the view
@property (weak, nonatomic) IBOutlet UITextField *questionField;
@property (weak, nonatomic) IBOutlet UITextField *optionOneField;
@property (weak, nonatomic) IBOutlet UITextField *optionTwoField;
@property (weak, nonatomic) IBOutlet UITextField *optionThreeField;
@property (weak, nonatomic) IBOutlet UITextField *categoriesField;
@property (weak, nonatomic) IBOutlet UISwitch * correctBoolOne;
@property (weak, nonatomic) IBOutlet UISwitch * correctBoolTwo;
@property (weak, nonatomic) IBOutlet UISwitch * correctBoolThree;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UILabel *questionPrompt;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


// these are public methods accessible from the action
- (IBAction)saveQuestion:(id)sender;
- (IBAction)textFieldReturn:(id)sender;
- (IBAction)switchValueChange:(id)sender;
//-(IBAction)textFieldEnter:(id)sender;

@end
