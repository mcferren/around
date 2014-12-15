//
//  Game_Board.m
//  around
//
//  Created by Benjamin McFerren on 6/6/14.
//  Copyright (c) 2014 DePaul University. All rights reserved.
//

#import "Game_Board.h"
#include <stdlib.h>

@interface Game_Board ()

@property(strong, nonatomic) NSMutableArray *board;

@end

@implementation Game_Board

// this method declares the core components needed for the singlton to deliver the correct type of information
- (instancetype)init {
    self = [super init];
    if (self) {
        NSUserDefaults *defaults =
        [NSUserDefaults standardUserDefaults];
        NSArray *storedPieces = [defaults objectForKey:@"pieceobjects"];
        if (storedPieces) { // mutable means can change
            self.board = [storedPieces mutableCopy];
        } else {
            self.board = [NSMutableArray array];
        }
        
        [self populatePieces];
    }
    
    return self;
}

// this conditionally checks whether the object has once been created and rreturns the original if it already has
+ (instancetype)sharedGameBoard {
    
    static Game_Board *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ // also used in threading
        shared = [[self alloc] init];
    });
    return shared;
}

// this utility method prepopulates the piece elements with certain key value pairs
- (void)populatePieces {
    [_board removeAllObjects];
    
    for(int i = 0; i < 9; ++i) {
        
        int pieceDataSourceIndex;
        if(i % 3 == 0) {
            pieceDataSourceIndex = 14;
        } else if (i % 3 == 1) {
            pieceDataSourceIndex = 15;
        } else if (i % 3 == 2) {
            pieceDataSourceIndex = 16;
        }
        
        [self addPiece:@{@"pieceDataSourceIndex" : [NSString stringWithFormat:@"%d",pieceDataSourceIndex],
                         @"pieceProfileID" : [NSString stringWithFormat:@"%d",0]}];
    }
}

// this utility method allow to add a piece element at a specific index
- (void)addPieceAtIndex:(id)item :(int)itemnumber {
    
    [_board removeObjectAtIndex:itemnumber];
    [_board insertObject:item atIndex:itemnumber];
    [self savePieces];
    
}


// this is a general go to purpose method used to insert the object it recevies into the class property array. It forces intent by invokeng the save method
- (void)addPiece:(id)item {
    [_board insertObject:item atIndex:0];
    [self savePieces];
}


// this is a general go to purpose method used to remove the object it recevies into the class property array. It forces intent by invokeng the save method
- (void)removePiece:(int)itemnumber {
    [_board removeObjectAtIndex:itemnumber];
    [self savePieces];
}


// this method ensures the NSUser Defaults are kept up to date when changing the elements in the class array property
- (void)savePieces {
    NSUserDefaults *defaults =
    [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.board forKey:@"pieceobjects"];
    [defaults synchronize];
}


// this is a simple swapping method
- (void)movePieceAtIndex:(NSInteger)from toIndex:(NSInteger)to {
    id item = _board[from];
    [_board removeObjectAtIndex:from];
    [_board insertObject:item atIndex:to];
    [self savePieces];
}

// this method takes a NSMutableDictionary as an object as well as a min key that we will iterate upon. The purpose is to update the board one batch of pieces (lanes) at a time
- (void)updateBoard:(NSMutableDictionary *)lane
                   :(NSInteger) minCellIndexPath
                   :(int)laneStartIndex {
    
    [self addPieceAtIndex
        :@{@"pieceDataSourceIndex" : [NSString stringWithFormat:@"%d",(int)minCellIndexPath],
           @"pieceProfileID"       : lane[[NSString stringWithFormat:@"%d",(int)minCellIndexPath]]}
     :laneStartIndex];
    
    [self addPieceAtIndex
     :@{@"pieceDataSourceIndex" : [NSString stringWithFormat:@"%d",(int)(minCellIndexPath + 1)],
        @"pieceProfileID"       : lane[[NSString stringWithFormat:@"%d",(int)(minCellIndexPath + 1)]]}
     :laneStartIndex + 1];
    
    [self addPieceAtIndex
     :@{@"pieceDataSourceIndex" : [NSString stringWithFormat:@"%d",(int)(minCellIndexPath + 2)],
        @"pieceProfileID"       : lane[[NSString stringWithFormat:@"%d",(int)(minCellIndexPath + 2)]]}
     :laneStartIndex + 2];
}

// this method checks for combinations of pieces on the board and returns the profile
// id object if there is a three in a row match. If no match, then it returns and object with a zero property. Zero can be interpretted as false
- (NSArray *)checkBoard {
    
    int b0 = [_board[0][@"pieceProfileID"] intValue];
    int b1 = [_board[1][@"pieceProfileID"] intValue];
    int b2 = [_board[2][@"pieceProfileID"] intValue];
    int b3 = [_board[3][@"pieceProfileID"] intValue];
    int b4 = [_board[4][@"pieceProfileID"] intValue];
    int b5 = [_board[5][@"pieceProfileID"] intValue];
    int b6 = [_board[6][@"pieceProfileID"] intValue];
    int b7 = [_board[7][@"pieceProfileID"] intValue];
    int b8 = [_board[8][@"pieceProfileID"] intValue];
    
    if(b0 == b1 && b1 == b2 && b0 != 0) {
        NSLog(@"Top Horizontal Match");        // Top Horizontal Match
        return @[@{@"profileid" : @[[NSString stringWithFormat:@"%d",b0]],
                   @"indextriple" : @[
                                        @{@"boardindex" : @"0",
                                          @"laneindex" : _board[0][@"pieceDataSourceIndex"]},
                                        @{@"boardindex" : @"1",
                                          @"laneindex" : _board[1][@"pieceDataSourceIndex"]},
                                        @{@"boardindex" : @"2",
                                          @"laneindex" : _board[2][@"pieceDataSourceIndex"]}
                                    ]
                                    
                   }];
    } else if(b3 == b4 && b4 == b5 && b3 != 0) {
        NSLog(@"Mid Horizontal Match");        // Mid Horizontal Match
        return @[@{@"profileid" : @[[NSString stringWithFormat:@"%d", b3]],
                   @"indextriple" : @[
                                        @{@"boardindex" : @"3",
                                          @"laneindex" : _board[3][@"pieceDataSourceIndex"]},
                                        @{@"boardindex" : @"4",
                                          @"laneindex" : _board[4][@"pieceDataSourceIndex"]},
                                        @{@"boardindex" : @"5",
                                          @"laneindex" : _board[5][@"pieceDataSourceIndex"]}
                                    ]
                   }];
    } else if(b6 == b7 && b7 == b8 && b6 != 0) {
        NSLog(@"Low Horizontal Match");        // Low Horizontal Match
        return @[@{@"profileid" : @[[NSString stringWithFormat:@"%d", b6]],
                   @"indextriple" : @[
                           @{@"boardindex" : @"6",
                             @"laneindex" : _board[6][@"pieceDataSourceIndex"]},
                           @{@"boardindex" : @"7",
                             @"laneindex" : _board[7][@"pieceDataSourceIndex"]},
                           @{@"boardindex" : @"8",
                             @"laneindex" : _board[8][@"pieceDataSourceIndex"]}
                                    ]
                   }];
    } else if(b0 == b3 && b3 == b6 && b0 != 0) {
        NSLog(@"Left Vertical Match");          // Left Vertical Match
        return @[@{@"profileid" : @[[NSString stringWithFormat:@"%d", b0]],
                   @"indextriple" : @[
                           @{@"boardindex" : @"0",
                             @"laneindex" : _board[0][@"pieceDataSourceIndex"]},
                           @{@"boardindex" : @"3",
                             @"laneindex" : _board[3][@"pieceDataSourceIndex"]},
                           @{@"boardindex" : @"6",
                             @"laneindex" : _board[6][@"pieceDataSourceIndex"]}
                                    ]
                   }];
    } else if(b1 == b4 && b4 == b7 && b1 != 0) {
        NSLog(@"Mid Vertical Match");            // Mid Vertical Match
        return @[@{@"profileid" : @[[NSString stringWithFormat:@"%d", b1]],
                   @"indextriple" : @[
                           @{@"boardindex" : @"1",
                             @"laneindex" : _board[1][@"pieceDataSourceIndex"]},
                           @{@"boardindex" : @"4",
                             @"laneindex" : _board[4][@"pieceDataSourceIndex"]},
                           @{@"boardindex" : @"7",
                             @"laneindex" : _board[7][@"pieceDataSourceIndex"]}
                                    ]
                   }];
    } else if(b2 == b5 && b5 == b8 && b2 != 0) {
        NSLog(@"Right Vertical Match");        // Right Vertical Match
        return @[@{@"profileid" : @[[NSString stringWithFormat:@"%d", b2]],
                   @"indextriple" : @[
                           @{@"boardindex" : @"2",
                             @"laneindex" : _board[2][@"pieceDataSourceIndex"]},
                           @{@"boardindex" : @"5",
                             @"laneindex" : _board[5][@"pieceDataSourceIndex"]},
                           @{@"boardindex" : @"8",
                             @"laneindex" : _board[8][@"pieceDataSourceIndex"]}
                                    ]
                   }];
    } else if(b0 == b4 && b4 == b8 && b0 != 0) {
        NSLog(@"Negative Diagnal Match");    // Negative Diagnal Match
        return @[@{@"profileid" : @[[NSString stringWithFormat:@"%d", b0]],
                   @"indextriple" : @[
                           @{@"boardindex" : @"0",
                             @"laneindex" : _board[0][@"pieceDataSourceIndex"]},
                           @{@"boardindex" : @"4",
                             @"laneindex" : _board[4][@"pieceDataSourceIndex"]},
                           @{@"boardindex" : @"8",
                             @"laneindex" : _board[8][@"pieceDataSourceIndex"]}
                                    ]
                   }];
    } else if(b6 == b4 && b4 == b2 && b6 != 0) {
        NSLog(@"Positive Diagnal Match");    // Positive Diagnal Match
        return @[@{@"profileid" : @[[NSString stringWithFormat:@"%d", b6]],
                   @"indextriple" : @[
                           @{@"boardindex" : @"6",
                             @"laneindex" : _board[6][@"pieceDataSourceIndex"]},
                           @{@"boardindex" : @"4",
                             @"laneindex" : _board[4][@"pieceDataSourceIndex"]},
                           @{@"boardindex" : @"2",
                             @"laneindex" : _board[2][@"pieceDataSourceIndex"]}
                                    ]
                   }];
    }

    return @[];
}

@end
