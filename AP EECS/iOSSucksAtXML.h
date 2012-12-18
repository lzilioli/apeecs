//  Copyright (c) 2012 Mike Varano & Luke Zilioli. All rights reserved.

/* This class exists because iOS seems to have no good implementation of an xml parser
 * I ended up using touchXML, the documentation for which can be found in that directory
 * This class is just a wrapper for that so I can make specific calls to find things out.
 * The function names explain way more than i feel like doing right now. Its hard and
 * ugly code to write, but once you add what you need, you can forget about it.
 * good luck. */

#import <Foundation/Foundation.h>
#import "TouchXML.h"

typedef enum qTypes
{
	MULTIPLE_CHOICE,
	BINARY,
	NOT_DEFINED
} QuestionType;

@interface iOSSucksAtXML : NSObject

-(QuestionType) getTypeOfQuestion:(NSInteger)qIdx forTopic:(NSInteger)topicIdx;
-(NSInteger) getNumQuestionsForTopic:(NSInteger)topicIdx;
-(NSInteger) getNumChoicesForMCQuestion:(NSInteger)qIdx forTopic:(NSInteger)topicIdx;
-(NSInteger) numTopics;
-(NSInteger) getWhichAnswerIsCorrectForMCQuestion:(NSInteger)qIdx forTopic:(NSInteger)topicIdx;
-(NSString*) getTopicNameFromIdx:(NSInteger)idx;

-(NSString*) getMCChoice:(NSInteger)choiceNum forQuestion:(NSInteger)qNum forTopic:(NSInteger)topicIdx;
-(NSString*) getMCQuestion:(NSInteger)qIdx forTopic:(NSInteger)topicIdx;
-(NSString*) getMCImg:(NSInteger)qIdx forTopic:(NSInteger)topicIdx;

-(BOOL) getBinToDecimalForQuestion:(NSInteger)qNum forTopic:(NSInteger)topicIdx;
-(NSString*) getBinaryQuestion:(NSInteger)qNum forTopic:(NSInteger)topicIdx;

@end
