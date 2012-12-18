//  Copyright (c) 2012 Mike Varano & Luke Zilioli. All rights reserved.

#import "QuestionBaseClass.h"

@interface QuestionBaseClass ()
@end

@implementation QuestionBaseClass

@synthesize delegate = _delegate;
@synthesize index = _index;
@synthesize topicIdx = _topicIdx;
@synthesize xmlData = _xmlData;
@synthesize saveData = _saveData;
@synthesize wasCorrect = _wasCorrect;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bkgr"]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil index:(NSInteger)i topic:(NSInteger)t andData:(iOSSucksAtXML*)xml andParent:(UIViewController*)dlg andWasCorrect:(BOOL) correct
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		_index = i;
		_topicIdx = t;
		_xmlData = xml;
		_delegate = dlg;
		_saveData = nil;
		_wasCorrect = correct;
    }
    return self;
}

-(void)setSaveData:(id)saveData
{
	_saveData = saveData;
}


@end
