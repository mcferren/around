//
//  Ask_ViewController.m
//  around
//
//  Created by Benjamin McFerren on 6/9/14.
//  Copyright (c) 2014 DePaul University. All rights reserved.
//

#import "Ask_ViewController.h"
#import "Question_Factory.h"
#import "DAO.h"
#import "User_Session.h"
#import <QuartzCore/QuartzCore.h>
#import <AFNetworking/UIKit+AFNetworking.h>
#import <Nimbus/NIAttributedLabel.h>
#import <SAMCategories/UIScreen+SAMAdditions.h>

@interface Ask_ViewController () <NIAttributedLabelDelegate>

    // this is a factory question object so we can do modifiers to the singleton
    @property (strong, nonatomic) Question_Factory *questionFactoryObject;

    // this is a counter used to populate question id numbers
    @property int question_id_counter;

    @property (nonatomic, strong) NSArray *jsonResponse;

    // singlton access to user's persistent data
    @property (strong, nonatomic) User_Session *userSessionObject;

@end

@implementation Ask_ViewController {
    
    // this questions array will be read by the UITableView
    NSMutableArray *questionsArray;
    
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
    
    // populate the local question factory
    self.questionFactoryObject = [Question_Factory sharedQuestionFactory];
    
    // set the id counter
    _question_id_counter = 9000;
    
    // adjust the view a little
    _submitButton.layer.cornerRadius = 5.0f;
    
    // access the question object and store it in a local variable
    self.questionFactoryObject = [Question_Factory sharedQuestionFactory];
    
    // keep the table view data source up to date
    questionsArray = [_questionFactoryObject returnQuestionsByProfileID:1];
    
    // access to user's persistent data
    self.userSessionObject     = [User_Session sharedUserSession];
    
    // cosmetic adjustments to switch "correct answer" elements in the view
    _correctBoolOne.on = 1;
    [_correctBoolOne setOnTintColor:[UIColor whiteColor]];
    [_correctBoolTwo setOnTintColor:[UIColor whiteColor]];
    [_correctBoolThree setOnTintColor:[UIColor whiteColor]];
    [_correctBoolOne setThumbTintColor:[UIColor blueColor]];
    [_correctBoolTwo setThumbTintColor:[UIColor lightGrayColor]];
    [_correctBoolThree setThumbTintColor:[UIColor lightGrayColor]];
    
    
//    NSDictionary * resultprint = [_userSessionObject getUserFacebookObject];
//    NSLog(@"resultprint %@", resultprint);
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    // refresh local instance from singleton/factory
    self.questionFactoryObject = [Question_Factory sharedQuestionFactory];
    
    // refresh the datasource for the table view
    questionsArray = [_questionFactoryObject returnQuestionsByProfileID:1];
    
    [_questionField becomeFirstResponder];
    _questionPrompt.text = @"Tap here to see all the questions you've asked";
    
    // refresh local instance from singleton/factory
    self.userSessionObject     = [User_Session sharedUserSession];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// this will make the keyboard go away
-(IBAction)textFieldReturn:(id)sender
{
    _questionPrompt.text = @"";
    [sender resignFirstResponder]; // tap outside keyboard to exit
}

//-(IBAction)textFieldEnter:(id)sender
//{
//    _questionPrompt.text = @"Tap here to see all the questions you've asked";
//}

-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    NSLog(@"touch class %@", textField.description);
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    
    if (![touch.view.class isKindOfClass:[UITextField class]]) {
        _questionPrompt.text = @"";
        [self.view endEditing:YES];
    }
    
//    NSLog(@"touch class %@", touch.view.class);
//    
//    if ([touch.view.class isKindOfClass:[UITextField class]]) {
//        _questionPrompt.text = @"Tap here to see all the questions you've asked";
//    }
    
}

- (IBAction)switchValueChange:(id)sender
{
    if ([sender isOn]) {
        [sender setThumbTintColor:[UIColor blueColor]];
    } else {
        [sender setThumbTintColor:[UIColor lightGrayColor]];
    }
}


// controller listener for when buttons are pushed in view
- (IBAction)saveQuestion:(id)sender {
    
    // make keyboard disappear
    [self.view endEditing:YES];
    //[[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) target:nil forEvent:nil];
    
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
    
    // prepare question object to post to clojure datastore
    NSMutableDictionary *questionObject = [[NSMutableDictionary alloc] init];
    [questionObject setObject:_questionField.text forKey:@"question"];
//    [questionObject setObject:[_userSessionObject getUserFacebookObject][@"id"] forKey:@"author_id"];
    [questionObject setObject:@[
                                _optionOneField.text,
                                _optionTwoField.text,
                                _optionThreeField.text
                                ] forKey:@"options"];
    [questionObject setObject:@[
                                [NSNumber numberWithBool:_correctBoolOne.isOn],
                                [NSNumber numberWithBool:_correctBoolTwo.isOn],
                                [NSNumber numberWithBool:_correctBoolThree.isOn]
                                ] forKey:@"correct_answer"];
    [questionObject setObject:@[] forKey:@"categories"];
    [questionObject setObject:_userSessionObject.getUserID forKey:@"author"];
//    NSLog(@"fb-id: %@", _userSessionObject.getUserID);
    
    
    // post questionObject to dataStore and perform local updates upon success
    DAO *client = [DAO sharedClient];
    
    [client postQuestion:^(id responseObject, NSError *error){
        if (!responseObject) {
            NSLog(@"failed: %@", error);
            return;
        }
        
        NSLog(@"RESPONSEOBJECT: %@", responseObject);
        
        // update questionObject with returned question_id variable
        [questionObject setObject:responseObject[@"_id"] forKey:@"question_id"];
        
        // send to update local factoryStore
        [_questionFactoryObject addQuestion:questionObject];
        
        // update local variable
        [questionsArray insertObject:questionObject atIndex:0];
        
        // refresh local storage
        [_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        
        
        // refresh so we have the most up to date question list and we populate ids correctly
        ++_question_id_counter;
        self.questionFactoryObject = [Question_Factory sharedQuestionFactory];
        
        
        // prepare and display a "thank you for your contribution" message
        NSString *msg = nil;
        
        msg = @"Thanks for asking a question!";
        
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
        _categoriesField.text = @"";
        
    } withObject:questionObject];
}

#pragma mark Table View Methods
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    // this controls the table view layout
    return 1;
}


-(NSInteger) tableView:(UITableView *)collectionView numberOfRowsInSection:(NSInteger)section {
    
    // this controls how the table view divees row object indices
    return [questionsArray count];
}

// this is a protocal method used to instatiate row objects
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QuestionRow" forIndexPath:indexPath];
    
    UILabel *label;
    //find the outlet with a tag
    label = (UILabel *)[cell viewWithTag:100];
    //populate the question text
    label.text = [questionsArray objectAtIndex:indexPath.row][@"question"];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    UIAlertView *messageAlert = [[UIAlertView alloc]
//                                 initWithTitle:@"Row Selected" message:@"You've selected a row" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    
//    // Display Alert Message
//    [messageAlert show];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    
    NSDictionary * targetQuestionObject = [questionsArray objectAtIndex:indexPath.row];
    
    
//    NSLog(@"touch class %@", cellQuestion);
    
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

    [actionSheet addButtonWithTitle:@"Delete Question"];
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons -1;
    
    // Set cancel button index to the one we just added so that we know which one it is in delegate call
    actionSheet.destructiveButtonIndex = actionSheet.numberOfButtons-1;
    
    [actionSheet showInView:self.view];
    
}



-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
    NSLog(@"boots %ld", (long)buttonIndex);
    //    [self performSelector:@selector(OtherOperations) withObject:nil afterDelay:0.0];
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet dismissWithClickedbuttonIndex:(NSInteger)buttonIndex{
    
    [actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
    NSLog(@"barts %ld", (long)buttonIndex);
    //    [self performSelector:@selector(OtherOperations) withObject:nil afterDelay:0.0];
    
}

@end
