//  Copyright (c) 2012 Mike Varano & Luke Zilioli. All rights reserved.

#import "StudyView.h"

@interface StudyView ()

@end

@implementation StudyView

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
	
	// load courseurl/study.pdf into the webview
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *path = [defaults objectForKey:@"courseurl"];
	path = [path stringByAppendingString:@"/study.pdf"];
	NSURL *target = [NSURL URLWithString:path];
	NSURLRequest *request = [NSURLRequest requestWithURL:target];
	[self.studyPdfView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/* called when done is hit, dismisses itself */
- (IBAction)dismiss:(id)sender {
	[[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

@end
