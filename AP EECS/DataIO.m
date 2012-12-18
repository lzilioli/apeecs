//  Copyright (c) 2012 Mike Varano & Luke Zilioli. All rights reserved.

#import "DataIO.h"

@implementation DataIO

@synthesize plist = _plist;
@synthesize totalplist = _totalplist;

/* Write it out */
- (void)savePlist
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
	NSString *documentsDirectory = [paths objectAtIndex:0]; //2
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"data.plist"]; //3
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if (![fileManager fileExistsAtPath: path]) //4
	{
		NSString *bundle = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"]; //5
		
		[fileManager copyItemAtPath:bundle toPath: path error:nil]; //6
	}
	
	NSData *xmlData;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *courseurl = [defaults objectForKey:@"courseurl"];
	[_totalplist setObject:_plist forKey:courseurl];
	
	NSDictionary* actualPlist = [[NSDictionary alloc] initWithDictionary:_totalplist copyItems:YES];
	
	xmlData = [NSPropertyListSerialization dataFromPropertyList:actualPlist
														 format:NSPropertyListXMLFormat_v1_0
											   errorDescription:nil];
	if(xmlData) {
		//NSLog(@"No error creating XML data.");
		[xmlData writeToFile:path atomically:YES];
	}
}

/* read it in */
- (void)getPlist
{
	NSError *error;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //1
	NSString *documentsDirectory = [paths objectAtIndex:0]; //2
	NSString *path = [documentsDirectory stringByAppendingPathComponent:@"data.plist"]; //3
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	if (![fileManager fileExistsAtPath: path]) //4
	{
		NSString *bundle = [[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"]; //5
		[fileManager copyItemAtPath:bundle toPath: path error:&error]; //6
	}
	_totalplist = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *courseurl = [defaults objectForKey:@"courseurl"];
	_plist = [_totalplist objectForKey:courseurl];
	if(_plist == nil)
		_plist = [[NSMutableDictionary alloc] init];
}

/* marks the question qnum for the topic topicnum as correct */
- (void)qIsRight:(NSString*)qNum forTopic:(NSString*)topicNum
{
	[self getPlist];
	if(![_plist objectForKey:topicNum])
		[_plist setObject:[[NSMutableDictionary alloc] init] forKey:topicNum];
	
	if(![[_plist objectForKey:topicNum] objectForKey:qNum])
	{
		[[_plist objectForKey:topicNum] setObject:[NSNumber numberWithBool:YES] forKey:qNum];
	}
	[self savePlist];
}

/* determines if the question was correct at any point */
- (BOOL)questionWasCorrect:(NSString*)qNum forTopic:(NSString*)topicNum
{
	[self getPlist];
	BOOL wasCorrect = NO;
	
	NSMutableDictionary* tmp = [_plist objectForKey:topicNum];
	if(tmp)
	{
		// topic been asked
		NSNumber* tmp2 = [tmp objectForKey:qNum];
		wasCorrect = tmp2 != nil && tmp2 == [[NSNumber alloc] initWithBool:YES];
	}

	return wasCorrect;
}

/* returns the number of correct questions for the given topic */
- (NSNumber*)getNumRight:(NSInteger)topicNum
{
	[self getPlist];
	NSString* key = [[[NSNumber alloc] initWithInt:topicNum] stringValue];
	NSMutableDictionary *topic = [_plist objectForKey:key];
	NSUInteger numQsCorrect = [[topic allKeysForObject:[NSNumber numberWithBool:YES]] count];
	
	return [[NSNumber alloc] initWithUnsignedInt:numQsCorrect];
}

/* forgets about the users progress for the given topic */
- (void)clearProgressForTopic:(NSString*)topicNum
{
	[self getPlist];
	[_plist removeObjectForKey:topicNum];
	[self savePlist];
}

@end
