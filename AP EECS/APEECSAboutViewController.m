//  Copyright (c) 2012 Mike Varano & Luke Zilioli. All rights reserved.

#import "APEECSAboutViewController.h"

@interface APEECSAboutViewController ()

@end

@implementation APEECSAboutViewController

@synthesize entry = _entry;
@synthesize saveBtn = _saveBtn;

- (void)viewDidLoad
{
    [super viewDidLoad];
	//self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bkgr.png"]];
	
	/* Find the user setting for this string, and put it in the prompt */
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *path = [defaults objectForKey:@"courseurl"];
	[_entry setText:path];
	
	// Make the submit button pretty
	UIImage *buttonImage = [[UIImage imageNamed:@"blueButton.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
    UIImage *buttonImageHighlight = [[UIImage imageNamed:@"blueButtonHighlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
	[_saveBtn setBackgroundImage:buttonImage forState:UIControlStateNormal];
	[_saveBtn setBackgroundImage:buttonImageHighlight forState:UIControlStateHighlighted];
	[_saveBtn setTitleColor:[UIColor colorWithWhite:100.0f alpha:100.0f] forState:UIControlStateNormal];
	[_saveBtn setTitleColor:[UIColor colorWithWhite:100.0f alpha:100.0f] forState:UIControlStateDisabled];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/* When the user saves a new url, we have to save the users new preference, making
 * sure its a seemingly valid input string. If it is, we save it and tell the 
 * masterviewcontroller to reload the course. */
- (IBAction)saveHit:(id)sender {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	NSString *path = _entry.text;
	
	// Strip trailing '/'
	if([path characterAtIndex:[path length]-1] == '/')
		path = [path substringToIndex:[path length]-1];
	
	// Ensure http/https
	if(![path hasPrefix:@"http://"] && ![path hasPrefix:@"https://"])
		path = [@"http://" stringByAppendingString:path];
	
	// Save the preference
	[defaults setObject:path forKey:@"courseurl"];
	[defaults synchronize];
	
	// Reload the course
	[(QuestionAsker*)[[self.parentViewController.splitViewController.viewControllers lastObject] topViewController] reloadCourse];
	_entry.text = path;
}

@end
