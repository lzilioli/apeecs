//  Copyright (c) 2012 Mike Varano & Luke Zilioli. All rights reserved.

#import <UIKit/UIKit.h>
#import "iOSSucksAtXML.h"
#import "QuestionAsker.h"
#import "DataIO.h"

@class QuestionAsker;
@interface APEECSMasterViewController : UITableViewController

/* The controller in charge of which questions get asked when. */
@property (strong, nonatomic) QuestionAsker *questionMaster;

/* Our persistant data store object */
@property (strong, nonatomic) DataIO *plist;

/* The xml data for the course */
@property (nonatomic, strong) iOSSucksAtXML* xmlData;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)updateProgresses;
- (void)reloadCourse;

@end
