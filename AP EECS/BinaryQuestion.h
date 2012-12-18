//  Copyright (c) 2012 Mike Varano & Luke Zilioli. All rights reserved.

#import "QuestionBaseClass.h"
#import "QuestionAsker.h"
#import "Save.h"

@interface BinaryQuestion : QuestionBaseClass <UITextFieldDelegate>

/* One should be hiddin, and the other showing, depending on which way we're converting. */
@property (weak, nonatomic) IBOutlet UILabel *toBaseTen;
@property (weak, nonatomic) IBOutlet UILabel *toBinary;

/* The label through which we ask the user what number to convert */
@property (weak, nonatomic) IBOutlet UILabel *prompt;

/* The UITextField into which the user inputs their response */
@property (weak, nonatomic) IBOutlet UITextField *response;

/* The button the user presses to submit their response. */
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;

/* The image that indicates weather this has been right before */
@property (weak, nonatomic) IBOutlet UIImageView *isCorrect;

@end
