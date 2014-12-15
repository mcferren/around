//
//  Ask_ViewController.m
//  around
//
//  Created by Benjamin McFerren on 6/9/14.
//  Copyright (c) 2014 DePaul University. All rights reserved.
//

#import "Ask_ViewController.h"
#import "Question_Factory.h"
#import <QuartzCore/QuartzCore.h>

@interface Ask_ViewController ()

// this is a factory question object so we can do modifiers to the singleton
@property (strong, nonatomic) Question_Factory *questionFactoryObject;

// this is a counter used to populate question id numbers
@property int question_id_counter;

@end

@implementation Ask_ViewController

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
    
    // populate the local question factory
    self.questionFactoryObject = [Question_Factory sharedQuestionFactory];
    
    // set the id counter
    _question_id_counter = 9000;
    
    // adjust the view a little
    _submitButton.layer.cornerRadius = 5.0f;
}

- (void)viewWillAppear:(BOOL)animated {
    
    // refresh local instance from singleton/factory
    self.questionFactoryObject = [Question_Factory sharedQuestionFactory];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// this will make the keyboard go away
-(IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder]; // tap outside keyboard to exit
}


// controller listener for when buttons are pushed in view
- (IBAction)saveQuestion:(id)sender {
    
    // validate input
    if((_questionField.text.length < 1 || _questionField.text.length > 30) ||
       (_optionOneField.text.length < 1 || _optionOneField.text.length > 30) ||
       (_optionTwoField.text.length < 1 || _optionTwoField.text.length > 30) ||
       (_optionThreeField.text.length < 1 || _optionThreeField.text.length > 30)
       )
    {
        
        NSString *msg = nil;
        
        msg = @"dude! you can only use between one and 30 characters and you must fill out a question for ALL THREE ANSWER OPTIONS";
        
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"INVALID INPUT"
                              message:msg
                              delegate:self
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
//    NSLog(@"BEFORE addQuestion %@", _questionFactoryObject.questions);
    
    [_questionFactoryObject addQuestion:@{
                                          @"author_id" : @"1",
                                          @"category" : @"",
                                          @"correct_answer" : @"-1",
                                          @"options" :         @[
                                                                _optionOneField.text,
                                                                _optionTwoField.text,
                                                                _optionThreeField.text
                                                             ],
                                          @"question" : _questionField.text,
                                          @"question_id" : [NSString stringWithFormat:@"%d",_question_id_counter]
                                        }];
    
    
    // refresh so we have the most up to date question list and we populate ids correctly
    ++_question_id_counter;
    self.questionFactoryObject = [Question_Factory sharedQuestionFactory];
    
//    NSLog(@"AFTER addQuestion %@", _questionFactoryObject.questions);
    
    
    NSString *msg = nil;
    
    msg = @"Thanks for asking the question!";
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@""
                          message:msg
                          delegate:self
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil];
    [alert show];
    
    // refresh the inputs in the view
    _questionField.text = @"";
    _optionOneField.text = @"";
    _optionTwoField.text = @"";
    _optionThreeField.text = @"";
    
}

@end
