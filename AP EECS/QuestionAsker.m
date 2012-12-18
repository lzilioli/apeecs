//  Copyright (c) 2012 Mike Varano & Luke Zilioli. All rights reserved.

#import "QuestionAsker.h"

@interface QuestionAsker ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (nonatomic, strong) iOSSucksAtXML* xmlData;
-(QuestionBaseClass*)getQuestionForIndex:(NSInteger)idx;

@end

@implementation QuestionAsker

@synthesize toolbar = _toolbar;
@synthesize mvc = _mvc;
@synthesize viewControllerSavedStates = _viewControllerSavedStates;
@synthesize plist = _plist;

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
	
	// Do any additional setup after loading the view.
	self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bkgrcont"]];
	
	// Load the default image until a topic is selected
	SelectATopic* dvc = [[SelectATopic alloc] initWithNibName:@"SelectATopic" bundle:nil];
	dvc.index = -1;
	[self setViewControllers:[NSMutableArray arrayWithObject:dvc] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setXmlData:(iOSSucksAtXML *)data
{
	_xmlData = data;
}

- (void)setParent:(id)parent
{
	_mvc = parent;
}

/* Called by QuestionBaseClass classes when the user got a question qNum for the
 * current topic correct*/
- (void)questionIsRight:(NSString*)qNum
{
	// Get the key for the topic
	NSString *key = [_detailItem stringValue];
	
	// Save this information to the persistant data store
	[_plist qIsRight:qNum forTopic:key];

	/* Get an instance of the view controller that we are about to stop displaying.
	 * Get the save data from that instance of the view controller and save it in
	 * the saved states object for if we ned ti again */
	QuestionBaseClass* s = [[self viewControllers] objectAtIndex:0]; // capture the vc
	id sd = [s retreiveSaveData];
	if(sd) [_viewControllerSavedStates setObject:sd forKey:[[NSNumber alloc] initWithInt:s.index]];
	
	NSInteger qNumInt = [qNum integerValue]; // get the index of the question as an int
	NSInteger numQs = [_xmlData getNumQuestionsForTopic:[_detailItem integerValue]]; // get the total number of questions
	
	[_mvc updateProgresses];
	if(qNumInt+1 >= numQs) return; // Return if there isnt another question
	
	// Show the next question
	[self setViewControllers:[NSMutableArray arrayWithObject:[self getQuestionForIndex:qNumInt+1]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

#pragma mark - Page view controller stuff
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
	QuestionBaseClass* vc = (QuestionBaseClass*) viewController;
	NSInteger numQs = [_xmlData getNumQuestionsForTopic:[_detailItem integerValue]];
	
	if(vc.index+1 >= numQs) return nil;
	else return [self getQuestionForIndex:vc.index+1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
	QuestionBaseClass* vc = (QuestionBaseClass*) viewController;
	
	if(vc.index <= 0) return nil;
	else return [self getQuestionForIndex:vc.index-1];
}

-(void)reloadCourse
{
	[_mvc reloadCourse];
	_detailItem = [[NSNumber alloc] initWithInt:-1];
}

/* Gets the question type from the xml data for the question with the given index,
 * and creates an instance of the appropriate class, returning it. */
-(QuestionBaseClass*) getQuestionForIndex:(NSInteger)idx
{
	QuestionType qt = [_xmlData getTypeOfQuestion:idx forTopic:[_detailItem integerValue]];
	
	QuestionBaseClass* retVal = nil;
	
	NSString* key1 = [[[NSNumber alloc] initWithInt:[_detailItem integerValue]] stringValue];
	NSString* key2 = [[[NSNumber alloc] initWithInt:idx] stringValue];
	BOOL wasCorrect = [_plist questionWasCorrect:key2 forTopic:key1];
	
	switch (qt) {
		case MULTIPLE_CHOICE:
		{
			XChoiceQuestion* mc = [[XChoiceQuestion alloc] initWithNibName:@"XChoiceQuestion" bundle:nil index:idx topic:[_detailItem integerValue] andData:_xmlData andParent:self andWasCorrect:wasCorrect];
			retVal = mc;
			break;
		}
		case BINARY:
		{
			BinaryQuestion* bq = [[BinaryQuestion alloc] initWithNibName:@"BinaryQuestion" bundle:nil index:idx topic:[_detailItem integerValue] andData:_xmlData andParent:self andWasCorrect:wasCorrect];
			retVal = bq;
			break;
		}
		default:
			retVal = [[SelectATopic alloc] initWithNibName:@"MultipleChoiceViewController" bundle:nil index:idx topic:[_detailItem integerValue] andData:_xmlData andParent:self andWasCorrect:wasCorrect];
			break;
	}
	
	retVal.saveData = [_viewControllerSavedStates objectForKey:[[NSNumber alloc] initWithInt:idx]];
	retVal.xmlData = _xmlData;
	retVal.index = idx;
	return retVal;
}

/* Tell the page view controller which dot to have lighter on the botton indicator */
- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
	QuestionBaseClass* uivc = [[pageViewController viewControllers] objectAtIndex:0];
	return uivc.index;
}

/* Tell the page view controller the total number of indicators for the indicator on the bottom */
- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
	return [_xmlData getNumQuestionsForTopic:[_detailItem integerValue]];
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
	self.dataSource = self;
	self.delegate = self;
	
    if (_detailItem != newDetailItem) {
		// If we aren't already showing this topic, show the topic
        _detailItem = newDetailItem;
		_viewControllerSavedStates = nil;
		_viewControllerSavedStates = [[NSMutableDictionary alloc] init];
		[self setTitle:[_xmlData getTopicNameFromIdx:[_detailItem integerValue]]];
		[self setViewControllers:[NSMutableArray arrayWithObject:[self getQuestionForIndex:0]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    }
	
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
	/* This is our last chance to save the data for this controller, so do it */
	QuestionBaseClass* s = [previousViewControllers objectAtIndex:0]; // capture the vc
	id sd = [s retreiveSaveData];
	if(sd) [_viewControllerSavedStates setObject:sd forKey:[[NSNumber alloc] initWithInt:s.index]];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Topics", @"Topics");
    NSMutableArray *items = [[_toolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [_toolbar setItems:items animated:YES];
    
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    //NSMutableArray *items = [_xmlData.topics mutableCopy];
    //[self.toolbar setItems:items animated:YES];
    
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return NO;
}

@end
