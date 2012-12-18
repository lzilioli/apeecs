//  Copyright (c) 2012 Mike Varano & Luke Zilioli. All rights reserved.

#import <UIKit/UIKit.h>
#import "QuestionBaseClass.h"
#import "QuestionAsker.h"

@interface XChoiceQuestion : QuestionBaseClass

/* Outlet for the label that contains the question we should ask the user.
 */
@property (weak, nonatomic) IBOutlet UILabel *questionText;

/* Array that contains all of the buttons that are response choices.
 */
@property (strong, nonatomic) NSMutableArray *responses;

/* Outlet for scroll view to which we add buttons and images
 */
@property (weak, nonatomic) IBOutlet UIScrollView *responseButtons;

/* Outlet for the image that indicates weather this question has been correct or not.
 */
@property (weak, nonatomic) IBOutlet UIImageView *correctImageIndicator;

@end
