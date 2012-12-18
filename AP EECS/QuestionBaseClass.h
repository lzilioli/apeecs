//  Copyright (c) 2012 Mike Varano & Luke Zilioli. All rights reserved.

/* This class should be inherited from for any new type of question. For example,
 * XChoiceQuestion and BinaryQuestion both inherit from it. This class contains common
 * items between all questions, such as the xmlData object, the saveData object,
 * etc. Inheriting classes must implement the retreiveSaveData method.
 *
 * When the inheriting class knows the user has their question right, it should
 * call:
 *      [(QuestionAsker*) self.delegate questionIsRight:[[[NSNumber alloc] initWithUnsignedInt: self.index] stringValue]];
 * Which tells the QuestionAsker to mark the question as correct, and advance the
 * user to the next question.
 */

#import <UIKit/UIKit.h>
#import "QuestionBaseClass.h"
#import "iOSSucksAtXML.h"

@interface QuestionBaseClass : UIViewController

@property UIViewController* delegate;

/* Question number within the topic. */
@property (nonatomic, assign) NSInteger index;

/* Index of the topic in which this question resides. */
@property (nonatomic, assign) NSInteger topicIdx;

/* Weather or not, according to the persistent data storage, this question was right or not. */
@property (nonatomic, assign) BOOL wasCorrect;

@property iOSSucksAtXML* xmlData;

/* Used to maintain consistency across the PageViewController. QuestionAsker manages
 * saveData for multiple instances of QuestionBaseClass for swipes between pages. */
@property (nonatomic) id saveData;

/* Returns the saveData. This isnt implemented in this class, rather its implemented
 * in classes that inherit from it. Its a virtual function, which, because I don't
 * know objective-c very well, I just did like this.
 */
- (id)retreiveSaveData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil index:(NSInteger)i topic:(NSInteger)t andData:(iOSSucksAtXML*)xml andParent:(UIViewController*)dlg andWasCorrect:(BOOL) correct;

@end