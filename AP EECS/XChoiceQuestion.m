//  Copyright (c) 2012 Mike Varano & Luke Zilioli. All rights reserved.

#import "XChoiceQuestion.h"

@interface XChoiceQuestion () @end

@implementation XChoiceQuestion

@synthesize responses = _responses;
@synthesize responseButtons = _responseButtons;
@synthesize correctImageIndicator = _correctImageIndicator;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	// Initialize the responses array
	if(_responses == nil) _responses = [[NSMutableArray alloc] init];
    
	// We apply a custom image to most buttons in the app. This loads those images.
	// http://nathanbarry.com/designing-buttons-ios5/
	UIImage *buttonImage = [[UIImage imageNamed:@"blueButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"blueButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];

	// Used for the y location of elements we insert into the scrollview
	int yloc = 0;
	
	// Update the indicator based on if the question was right before.
	_correctImageIndicator.hidden = !self.wasCorrect;
	
	// Set the text for the question prompt
	[_questionText setText:[self.xmlData getMCQuestion:self.index forTopic:self.topicIdx]];
	
	// If the question has an img attribute, then we should get the image to display
	NSString *imageName = [self.xmlData getMCImg:self.index forTopic:self.topicIdx];
	if(imageName != nil) {
		
		/* Build the url from which to download the image, and download it into the imageview*/
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSString *path = [defaults objectForKey:@"courseurl"];
		path = [path stringByAppendingString:@"/"];
		path = [path stringByAppendingString:imageName];
		NSURL *url = [NSURL URLWithString:path];
		NSData *data = [[NSData alloc] initWithContentsOfURL:url];
		UIImage *img = [[UIImage alloc] initWithData:data];
		UIImageView *imageView = [[UIImageView alloc] initWithImage:img];
		
		// center the image as it becomes smaller than the size of the screen
		CGSize boundsSize = _responseButtons.bounds.size;
		CGRect frameToCenter = imageView.frame;
		while(frameToCenter.size.width >= boundsSize.width)
		{
			frameToCenter.size.height *= .9;
			frameToCenter.size.width *= .9;
		}
		// center horizontally
		if (frameToCenter.size.width < boundsSize.width) frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
		imageView.frame = frameToCenter;
		
		yloc += imageView.frame.size.height + 10;
		
		// Add the imageView
		[_responseButtons addSubview:imageView];
	}
	
	/* Iterate through all of the question responses, and add the buttons as choices to the scrollview */
    for(int i = 0; i < [self.xmlData getNumChoicesForMCQuestion:self.index forTopic:self.topicIdx]; i++)
	{
		UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		
		[button addTarget:self action:@selector(pressed:) forControlEvents:UIControlEventTouchDown];
		button.tag = i; // used to determine the index of the pressed button

		// Get the text for the button
		[button setTitle:[self.xmlData getMCChoice:i forQuestion:self.index forTopic:self.topicIdx] forState:UIControlStateNormal];

		[button setBackgroundImage:buttonImage forState:UIControlStateNormal];
		[button setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
		[button setTitleColor:[UIColor colorWithWhite:100.0f alpha:100.0f] forState:UIControlStateNormal];
		[button setTitleColor:[UIColor colorWithWhite:100.0f alpha:100.0f] forState:UIControlStateDisabled];
		button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
		
		button.frame = CGRectMake(50.0, yloc, _responseButtons.frame.size.width - 100, 60.0);
		yloc += 60 + 10;
		[_responseButtons addSubview:button]; // add the button
		[_responses addObject:button];
	}
	
	// Tell the scroll view how much i need it to scroll
	[_responseButtons setScrollEnabled:YES];
	_responseButtons.contentSize = CGSizeMake(_responseButtons.frame.size.width, yloc);
	
	// Set the correct answer to turn green when selected
	buttonImage = [[UIImage imageNamed:@"greenButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
	NSInteger correct = [self.xmlData getWhichAnswerIsCorrectForMCQuestion:self.index forTopic:self.topicIdx];
	[[_responses objectAtIndex:correct] setBackgroundImage:buttonImage forState:UIControlStateDisabled];

	// Load the saved data if need be
	// saveData is just a list of buttons the user attempted already, so we just simulate those attempts
	if(!self.saveData) self.saveData = [[NSMutableArray alloc] initWithCapacity:0];
	for(NSNumber* i in self.saveData) {
		[self buttonHit:[i integerValue] tellDelegate:NO];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

// Gets called when one of the buttons is pressed
- (IBAction)pressed:(UIButton*)sender
{
	[self buttonHit:(NSUInteger)sender.tag tellDelegate:YES];
}

// Checks if the pressed button is the right answer
- (void)buttonHit:(NSUInteger) btnIdx tellDelegate:(BOOL)td
{
	UIButton* btn = [_responses objectAtIndex:btnIdx];
	
	// Add to saveData that this button has been pressed
	if(td) [self.saveData addObject:[[NSNumber alloc] initWithInt:btnIdx]];
	// else, saveData already contains btnIdx
	
	// Determine the index of the correct button
	NSInteger correct = [self.xmlData getWhichAnswerIsCorrectForMCQuestion:self.index forTopic:self.topicIdx];
	// Determine if the correct button was hit
	BOOL isCorrect = correct == btnIdx;
	// Hide or show the correct indicator
	_correctImageIndicator.hidden = !isCorrect;
	
	if(isCorrect)
	{
		// Make the button green
		UIImage *buttonImage = [[UIImage imageNamed:@"greenButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
		UIImage *buttonImageHighlight = [[UIImage imageNamed:@"greenButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
		[btn setBackgroundImage:buttonImage forState:UIControlStateNormal];
		[btn setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
		
		// Disable all of the buttons
		for (UIButton *b in _responses) b.enabled = NO;
		
		// Tell the QuestionAsker to advance to the next question, if we aren't just loading saveData
		if(td) [(QuestionAsker*) self.delegate questionIsRight:[[[NSNumber alloc] initWithUnsignedInt: self.index] stringValue]];
	}
	else
	{
		// Make the button orange (red)
		UIImage *buttonImage = [[UIImage imageNamed:@"orangeButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
		UIImage *buttonImageHighlight = [[UIImage imageNamed:@"orangeButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
		[btn setBackgroundImage:buttonImage forState:UIControlStateNormal];
		[btn setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
	}
}

- (id)retreiveSaveData
{
	return [self.saveData count] > 0 ? [self.saveData copy] : nil;
}

@end
