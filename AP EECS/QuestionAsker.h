//  Copyright (c) 2012 Mike Varano & Luke Zilioli. All rights reserved.

/* This class is a pageview controller, its responsible for suppluying the
 * appropriate UIViewControllers to be displayed to the user, each one inheriting from
 * QuestionBaseClass, being specified in the xml as a valid question type. */

#import <UIKit/UIKit.h>
#import "SelectATopic.h"
#import "XChoiceQuestion.h"
#import "BinaryQuestion.h"
#import "iOSSucksAtXML.h"
#import "APEECSMasterViewController.h"
#import "DataIO.h"

@class APEECSMasterViewController;

@interface QuestionAsker : UIPageViewController <UIPageViewControllerDelegate, UISplitViewControllerDelegate, UIPageViewControllerDataSource>

@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;

/* To conserve memory, we do not store the entire viewController for a question
 * that is not currently visible to the user. For this reason, we save the state
 * of each question before it leaves memory, and when we recreate it, we give it its
 * saveData back. The inheriting classes from QuestionBaseClass can treat saveData however
 * they wish. This saved data is stored in a dictionary mapping question index to the savedata*/
@property (nonatomic, strong) NSMutableDictionary* viewControllerSavedStates;

/* The index of the topic we're currrently viewing */
@property (strong, nonatomic) id detailItem;

/* The masterviewcontroller that is our parent, we use this to reload the
 * preogress indicators when the user gets a question right. There's probably a better
 * way to do it than this. */
@property (strong, nonatomic) APEECSMasterViewController* mvc;

/* The persistant data storage object
 */
@property (strong, nonatomic) DataIO* plist;

- (void)setXmlData:(iOSSucksAtXML*) data;
- (void)questionIsRight:(NSString*)qNum;
- (void)setParent:(APEECSMasterViewController*)parent;
- (void)reloadCourse;


@end
