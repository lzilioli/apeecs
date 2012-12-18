//  Copyright (c) 2012 Mike Varano & Luke Zilioli. All rights reserved.

/* This class is my lay implementation of having persistant data in an ios app
 * Due to time constraints, I didn't have time to figure out how to coredata or 
 * sqlite for this.
 *
 * The only thing we're persistantly storing is the user's progress for what they've
 * gotten right and wrong. We store it as a 3-d dictionary mapping
 * courseurl > topicidx > questionidx
 * This dictionary is read from and written to a plist using plists for persistant data.
 * I know its bad design, but basically there are refences to this class wherever
 * this data is changed, and every function that changes the data in the plist
 * reads the most recent version of the plist from disk, changes it and writes the changes to disk.
 */

#import <Foundation/Foundation.h>

@interface DataIO : NSObject

@property (strong, nonatomic) NSMutableDictionary *plist;
@property (strong, nonatomic) NSMutableDictionary *totalplist;

- (void)qIsRight:(NSString*)qNum forTopic:(NSString*)topicNum;
- (BOOL)questionWasCorrect:(NSString*)qNum forTopic:(NSString*)topicNum;
- (NSNumber*)getNumRight:(NSInteger)topicNum;
- (void)clearProgressForTopic:(NSString*)topicNum;

@end
