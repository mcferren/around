//
//  Ask_ViewController.h
//  around
//
//  Created by Benjamin McFerren on 6/9/14.
//  Copyright (c) 2014 DePaul University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Ask_ViewController : UIViewController

// these are outlets in the view
@property (weak, nonatomic) IBOutlet UITextField *questionField;
@property (weak, nonatomic) IBOutlet UITextField *optionOneField;
@property (weak, nonatomic) IBOutlet UITextField *optionTwoField;
@property (weak, nonatomic) IBOutlet UITextField *optionThreeField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

// these are public methods accessible from the action
- (IBAction)saveQuestion:(id)sender;
- (IBAction)textFieldReturn:(id)sender;

@end
