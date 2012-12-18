//  Copyright (c) 2012 Mike Varano & Luke Zilioli. All rights reserved.

#import "APEECSMasterViewController.h"


@interface APEECSMasterViewController ()
@end

@implementation APEECSMasterViewController

@synthesize xmlData = _xmlData;
@synthesize plist = _plist;

- (void)awakeFromNib
{
    self.clearsSelectionOnViewWillAppear = NO;
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
	
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Initialize stuff
    if(!_xmlData) _xmlData = [[iOSSucksAtXML alloc] init];
	if(!_plist) _plist = [[DataIO alloc] init];
	self.questionMaster = (QuestionAsker *)[[self.splitViewController.viewControllers lastObject] topViewController];
	self.questionMaster.xmlData = _xmlData;
	self.questionMaster.plist = _plist;
	self.questionMaster.mvc = self;
	
	// Add the edit button the the menu
	self.navigationItem.leftBarButtonItem = self.editButtonItem;
	
	// Pull to refresh
	UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
	refreshControl.tintColor = [UIColor orangeColor];
	[refreshControl addTarget:self action:@selector(reloadCourse) forControlEvents:UIControlEventValueChanged];
	self.refreshControl = refreshControl;
}

// Called when pull to refresh action is triggered
-(void) reloadCourse
{
	// reload the xml data from the website
	_xmlData = [[iOSSucksAtXML alloc] init];
	self.questionMaster.xmlData = _xmlData;
	
	// reinit the saved data for the course
	_plist = [[DataIO alloc] init];
	self.questionMaster.plist = _plist;
	
	// tell the table to update
	[self.tableView reloadData];
	
	// tell pull to refresh we're all set
	[self.refreshControl endRefreshing];
}

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
	return @"Clear Progress";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (void)updateProgresses
{
	[self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_xmlData numTopics];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TopicCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
	NSString* topicName = [_xmlData getTopicNameFromIdx:[indexPath row]];
    [[cell textLabel] setText:topicName];
	[[cell detailTextLabel] setText:[self getProgress:[indexPath row]]];
    return cell;
}

/* Gets a string indicating the user's progress for the given topic */
- (NSString*)getProgress:(NSInteger)topicNum
{
	NSString* retVal = [[_plist getNumRight:topicNum] stringValue];
	retVal = [retVal stringByAppendingString:@"/"];
	retVal = [retVal stringByAppendingString:[[[NSNumber alloc] initWithInt:[_xmlData getNumQuestionsForTopic:topicNum]] stringValue]];
	return retVal;
}

// All progress can be reset
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Clear the topic's progress
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		[_plist clearProgressForTopic:[[[NSNumber alloc] initWithInt:[indexPath row]] stringValue]];
		[[[self.tableView cellForRowAtIndexPath:indexPath] detailTextLabel] setText:[self getProgress:[indexPath row]]];
		[[self.tableView cellForRowAtIndexPath:indexPath] setEditing:NO animated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.questionMaster.detailItem = [NSNumber numberWithInt:[indexPath row]];//[_xmlData.topics objectAtIndex:[indexPath row]];
}

@end