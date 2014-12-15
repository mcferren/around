//
//  Questions_ViewController.m
//  around
//
//  Created by Benjamin McFerren on 6/9/14.
//  Copyright (c) 2014 DePaul University. All rights reserved.
//

#import "Questions_ViewController.h"
#import "Question_Factory.h"

@interface Questions_ViewController ()

// this is the DataSource we'll use to populate the questions array
@property (strong, nonatomic) Question_Factory *questionFactoryObject;

@end

@implementation Questions_ViewController {
    
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
    
    // access the question object and store it in a local variable
    self.questionFactoryObject = [Question_Factory sharedQuestionFactory];
    
    // keep the table view data source up to date
    questionsArray = [_questionFactoryObject returnQuestionsByProfileID:1];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    // refresh the local object
    self.questionFactoryObject = [Question_Factory sharedQuestionFactory];
    
    // refresh the datasource for the table view
    questionsArray = [_questionFactoryObject returnQuestionsByProfileID:1];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
