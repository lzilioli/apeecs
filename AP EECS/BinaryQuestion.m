//  Copyright (c) 2012 Mike Varano & Luke Zilioli. All rights reserved.

#import "BinaryQuestion.h"

@interface BinaryQuestion ()

@property (nonatomic) BOOL toDecimal;
@property (nonatomic) int valToPrompt;

@end

@implementation BinaryQuestion

@synthesize toDecimal = _toDecimal;
@synthesize valToPrompt = _valToPrompt;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Stylize the submit button
	UIImage *buttonImage = [[UIImage imageNamed:@"blueButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"blueButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
	[_submitBtn setBackgroundImage:buttonImage forState:UIControlStateNormal];
	[_submitBtn setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];

	// Determine if were converting binary -> decimal, and display the appropriate prompt
	_toDecimal = [self.xmlData getBinToDecimalForQuestion:self.index forTopic:self.topicIdx];
	_toBaseTen.hidden = !_toDecimal;
	_toBinary.hidden = _toDecimal;
	
	if(!self.saveData) // No save data
	{
		self.saveData = [[Save alloc] init];
		
		// Get the number we should prompt the user with
		NSString* question = [self.xmlData getBinaryQuestion:self.index forTopic:self.topicIdx];
		BOOL randomize = question.length == 0;
		
		// Either get a random number, or the one specified
		if(randomize) _valToPrompt = arc4random() % 128;
		else _valToPrompt = [question integerValue];
	}
	else // Load from save data
	{
		_valToPrompt = ((Save*)self.saveData).numPrompted;
		NSString* prevResponse = ((Save*)self.saveData).lastAttempted;
		if(prevResponse.length != 0)
		{
			[_response setText:prevResponse];
			[self attemptEntry:prevResponse andAdvance:NO];
		}
	}
	
	// At this point, we know what number we're prompting
	((Save*)self.saveData).numPrompted = _valToPrompt;
	
	// Update the prompt to the value in the proper reprensentation
	if(_toDecimal) [_prompt setText:[self convertToBinary:_valToPrompt]];
	else [_prompt setText:[[[NSNumber alloc] initWithInt:_valToPrompt] stringValue]];
	
	_response.delegate = self; // for shouldChangeCharactersInRange, to enforce entry of only digits
	_response.borderStyle = UITextBorderStyleRoundedRect; // because you cant make a roundedrect taller through ib
	_isCorrect.hidden = !self.wasCorrect;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
	// Determine how long the string will be
	NSUInteger newLength = [textField.text length] + [string length] - range.length;
    // Don't let the length exceed 8 characters
	BOOL retval = (newLength > 8) ? NO : YES;
	
	// Only allow 0-9 if converting to decimal, or 0-1 if to binary
	NSCharacterSet* allowedChars;
	if(_toDecimal) allowedChars = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
	else allowedChars = [NSCharacterSet characterSetWithCharactersInString:@"01"];
	NSRange badCharacterRange = [string rangeOfCharacterFromSet:[allowedChars invertedSet]];
	retval &= badCharacterRange.length == 0; // false if there are disallowed characters in string
	return retval;
}

- (NSString*)convertToBinary:(int)val
{
	NSString* retVal = [[NSString alloc] init];
	int mask = 1;
	int tmpval = val;
	while(tmpval > 0)
	{
		int one = tmpval & mask;
		if(one == 1) retVal = [@"1" stringByAppendingString:retVal];
		else if(one == 0) retVal = [@"0" stringByAppendingString:retVal];
		tmpval = tmpval >> 1;
	}
	if(retVal.length == 0) retVal = @"0";
	return retVal;
}

- (int)convertToBaseTen:(NSString*)s
{
	int retval = 0;
	int curplace = 1;
	while(s.length > 0)
	{
		NSRange titties = {s.length-1, 1};
		NSString* doIt = [s substringWithRange:titties];
		
		s = [s substringToIndex:s.length-1];
		
		if([doIt isEqualToString:@"1"]) retval += curplace;
		curplace *= 2;
	}
	return retval;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)attemptEntry:(NSString*)attempt andAdvance:(BOOL) advance
{
	// Save the last attempt
	((Save*)self.saveData).lastAttempted = attempt;
	
	BOOL allGood = NO; // assume theyre wrong, till proven otherwise
	
	// Determine correctness
	if(_toDecimal) allGood = [attempt integerValue] == _valToPrompt;
	else allGood = [self convertToBaseTen:attempt] == _valToPrompt;
	
	if(allGood)
	{
		// go to the next question, if not loading from savedata (advance)
		if(advance) [(QuestionAsker*) self.delegate questionIsRight:[[[NSNumber alloc] initWithUnsignedInt: self.index] stringValue]];
		
		// make the user feel good
		UIImage *buttonImage = [[UIImage imageNamed:@"greenButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
		UIImage *buttonImageHighlight = [[UIImage imageNamed:@"greenButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
		[_submitBtn setBackgroundImage:buttonImage forState:UIControlStateNormal];
		[_submitBtn setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
		[_submitBtn setTitle:@"Nice! b^.^d" forState:UIControlStateNormal];
		_isCorrect.hidden = NO;
		
		_response.enabled = NO;
		_submitBtn.enabled = NO;
	}
	else
	{
		// Make the user feel bad
		UIImage *buttonImage = [[UIImage imageNamed:@"orangeButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
		UIImage *buttonImageHighlight = [[UIImage imageNamed:@"orangeButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
		[_submitBtn setBackgroundImage:buttonImage forState:UIControlStateNormal];
		[_submitBtn setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
		[_submitBtn setTitle:@"Try again :(" forState:UIControlStateNormal];
		
		//[_response selectAll:self]; THIS FUCKS EVERYTHING WAY UP
	}
}

// Called when the submit button is hit.
- (IBAction)submitEntry:(id)sender
{
	[self attemptEntry:_response.text andAdvance:YES];
}

- (id)retreiveSaveData
{
	return self.saveData;
}

@end
