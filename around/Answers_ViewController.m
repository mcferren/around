//
//  Answers_ViewController.m
//  around
//
//  Created by Benjamin McFerren on 6/9/14.
//  Copyright (c) 2014 DePaul University. All rights reserved.
//

#import "Answers_ViewController.h"
#import "Answer_Factory.h"
#import "Question_Factory.h"
#import <QuartzCore/QuartzCore.h>

@interface Answers_ViewController ()

// this is the DataSource we'll use to populate the answers array
@property (strong, nonatomic) Answer_Factory *answerFactoryObject;


// this is the delegate we use to do question lookups
@property (strong, nonatomic) Question_Factory *questionFactoryObject;

@end

@implementation Answers_ViewController {
    
    // this is the data source associated wiht the Table View
    NSMutableArray *answersArray;
    
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
    
    // populate the factory objects
    self.answerFactoryObject = [Answer_Factory sharedAnswerFactory];
    self.questionFactoryObject = [Question_Factory sharedQuestionFactory];
    
    // ppoulate the data source
    answersArray = [_answerFactoryObject returnAnswersArrayByProfileID:1];
}

- (void)viewWillAppear:(BOOL)animated {
    
    // refresh the local factory objects
    self.answerFactoryObject = [Answer_Factory sharedAnswerFactory];
    self.questionFactoryObject = [Question_Factory sharedQuestionFactory];
    
    // refresh the table view data source
    answersArray = [_answerFactoryObject returnAnswersArrayByProfileID:1];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Table View Methods
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    // affects the view layout
    return 1;
}

-(NSInteger) tableView:(UITableView *)collectionView numberOfRowsInSection:(NSInteger)section {
    // used by table view to instantiate rows
    return [answersArray count];
}

// populates rows in the table
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AnswerRow" forIndexPath:indexPath];
    
    UIImageView *avatar;
    UILabel *label;
    UIImage *image;
    UIView *wrapper;
    label = (UILabel *)[cell viewWithTag:100];
    avatar = (UIImageView *)[cell viewWithTag:200];
    wrapper = (UIImageView *)[cell viewWithTag:300];
    // access outlet with tag
    
    int question_id = [[answersArray objectAtIndex:indexPath.row] intValue];
    NSDictionary * questionObject = [_questionFactoryObject returnQuestionByQuestionID:question_id];
    
    label.text = questionObject[@"question"];
    image = [UIImage imageNamed:[NSString stringWithFormat:@"%@_image",questionObject[@"author_id"]]];
    
    [avatar setImage:image];
    
    [avatar.layer setBorderColor: [[UIColor whiteColor] CGColor]];
    [avatar.layer setBorderWidth: 1.0f];
    [avatar.layer setCornerRadius:20.0f];
    
    [wrapper.layer setBorderColor:[UIColor blueColor].CGColor];
    [wrapper.layer setBorderWidth:1.0f];
    [wrapper.layer setCornerRadius:20.0f];
    // add image and text content
    
    return cell;
    
}

@end
