//  Copyright (c) 2012 Mike Varano & Luke Zilioli. All rights reserved.

#import "iOSSucksAtXML.h"

@interface iOSSucksAtXML ()

@property NSMutableArray *topics;
@property NSMutableArray *topicNames;
@property NSArray *resultNodes;

@property CXMLDocument* rssParser;

@end

@implementation iOSSucksAtXML

@synthesize topics = topics_;
@synthesize topicNames = topicNames_;
@synthesize resultNodes = resultNodes_;
@synthesize rssParser = rssParser_;

-(id) init
{
    [self grabQuestions];
    return [super init];
}

// Grabs the questions xml data from courseurl/input.xml
-(void) grabQuestions {
    
    // Initialize the blogEntries MutableArray that we declared in the header
    topics_ = [[NSMutableArray alloc] init];
    topicNames_ = [[NSMutableArray alloc] init];
    
//    NSString* path = [[NSBundle mainBundle] pathForResource:@"input" ofType:@"xml"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *path = [defaults objectForKey:@"courseurl"];
	path = [path stringByAppendingString:@"/input.xml"];
    
    NSString* content = [NSString stringWithContentsOfURL:[NSURL URLWithString:path] encoding:NSUTF8StringEncoding error:NULL];
    rssParser_ = [[CXMLDocument alloc] initWithXMLString:content options:0 error:nil];
    
    // Set the resultNodes Array to contain an object for every instance of
    resultNodes_ = [rssParser_ nodesForXPath:@"//topic" error:nil];
    
    //blogEntries_ = [[NSMutableArray alloc] initWithArray:resultNodes];
    for(CXMLElement *theTopic in resultNodes_)
    {
        NSString *topicName = [[theTopic attributeForName:@"n"] stringValue];
        [topicNames_ addObject:topicName];
		[topics_ addObject:theTopic];
    }
}

-(NSString*) getTopicNameFromIdx:(NSInteger)idx
{
	return [topicNames_ objectAtIndex:idx];
}

-(NSInteger) numTopics {
    return [topicNames_ count];
}

-(NSInteger) getNumQuestionsForTopic:(NSInteger)topicIdx
{
	return [[[topics_ objectAtIndex:topicIdx] nodesForXPath:@".//question" error:nil] count];
}

-(QuestionType) getTypeOfQuestion:(NSInteger)qIdx forTopic:(NSInteger)topicIdx
{
	NSString* qType = [[[[[topics_ objectAtIndex:topicIdx] nodesForXPath:@".//question" error:nil] objectAtIndex:qIdx] attributeForName:@"type"] stringValue];

	if([qType isEqualToString:@"xchoice"]) return MULTIPLE_CHOICE;
	else if([qType isEqualToString:@"bin"]) return BINARY;
	
	return NOT_DEFINED;
}

// MC STUFF
-(NSInteger) getNumChoicesForMCQuestion:(NSInteger)qIdx forTopic:(NSInteger)topicIdx
{
	return [[[[[topics_ objectAtIndex:topicIdx] nodesForXPath:@".//question" error:nil] objectAtIndex:qIdx] nodesForXPath:@".//response" error:nil] count];
}

-(NSInteger) getWhichAnswerIsCorrectForMCQuestion:(NSInteger)qIdx forTopic:(NSInteger)topicIdx
{
	NSArray* responses = [[[[topics_ objectAtIndex:topicIdx] nodesForXPath:@".//question" error:nil] objectAtIndex:qIdx] nodesForXPath:@".//response" error:nil];
	int i = 0;
	for(CXMLElement *response in responses)
	{
		if([[[response attributeForName:@"correct"] stringValue] isEqualToString:@"true"])
			return i;
		i++;
	}
	return 0;
}

-(NSString*) getMCQuestion:(NSInteger)qIdx forTopic:(NSInteger)topicIdx
{
	return [[[[[topics_ objectAtIndex:topicIdx] nodesForXPath:@".//question" error:nil] objectAtIndex:qIdx] attributeForName:@"q"] stringValue];
}

-(NSString*) getMCImg:(NSInteger)qIdx forTopic:(NSInteger)topicIdx
{
	return [[[[[topics_ objectAtIndex:topicIdx] nodesForXPath:@".//question" error:nil] objectAtIndex:qIdx] attributeForName:@"img"] stringValue];
}

- (NSString*)getMCChoice:(NSInteger)choiceNum forQuestion:(NSInteger)qNum forTopic:(NSInteger)topicIdx
{
	NSArray* responses = [[[[topics_ objectAtIndex:topicIdx] nodesForXPath:@".//question" error:nil] objectAtIndex:qNum] nodesForXPath:@".//response" error:nil];
	CXMLElement* responseInQ = [responses objectAtIndex:choiceNum];
	return [responseInQ stringValue];
}

-(BOOL) getBinToDecimalForQuestion:(NSInteger)qNum forTopic:(NSInteger)topicIdx
{
	return [[[[[[topics_ objectAtIndex:topicIdx] nodesForXPath:@".//question" error:nil] objectAtIndex:qNum] attributeForName:@"toDec"] stringValue] isEqualToString:@"true"];
}

-(NSString*) getBinaryQuestion:(NSInteger)qNum forTopic:(NSInteger)topicIdx
{
	CXMLElement* q = [[[topics_ objectAtIndex:topicIdx] nodesForXPath:@".//question" error:nil] objectAtIndex:qNum];
	return [q stringValue];
}

@end
