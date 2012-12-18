//  Copyright (c) 2012 Mike Varano & Luke Zilioli. All rights reserved.

/* This object us ised by BinaryQuestion to represent its saved data. This should
 * really be a struct, but I don't know objective C like that, and didn't have time
 * to learn for this project. It's on the list.
 */

#import <Foundation/Foundation.h>

@interface Save : NSObject

@property int numPrompted;
@property NSString* lastAttempted;

@end
