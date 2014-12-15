//
//  Game_Board.h
//  around
//
//  Created by Benjamin McFerren on 6/6/14.
//  Copyright (c) 2014 DePaul University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Game_Board : NSObject

// this is a singlton object that uses thread checking to ensure that it is only invoked once and subsequant requests return the previously instantiated object
+ (instancetype)sharedGameBoard;

// array property that holds a fixed amount of the user's answers and the user's questions
- (NSArray *)board;

// these are public methods accessible from the static object
- (void)addPieceAtIndex:(id)item :(int)itemnumber;
- (NSArray *)checkBoard;
- (void)updateBoard:(NSMutableDictionary*)lane
                   :(NSInteger) minCellIndexPath
                   :(int)laneStartIndex;


@end
