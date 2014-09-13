//
//  HBVLinkedTextView.h
//  HBVLinkedTextView
//
//  Created by Travis Henspeter on 9/11/14.
//  Copyright (c) 2014 herbivore. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  Block to be executed when a tap gesture is detected in a linked string
 *
 *  @param linkedString the string in which a tap gesture occurred
 */

typedef void (^LinkedStringTapHandler)(NSString *linkedString);

@interface HBVLinkedTextView : UITextView

/**
 *  Detect a tap gesture on a specified string and perform a block
 *
 *  @param string                any substring of the textview's text property
 *  @param defaultAttributes     an NSDictionary representing attributes to be applied to a linked string
 *  @param highlightedAttributes an NSDictionary representing attributes to be applied to a linked string when it is tapped
 *  @param tapHandler            a block of type ^LinkedStringTapHandler to be executed when the specified string is tapped.
 */

- (void)linkString:(NSString *)string defaultAttributes:(NSDictionary *)defaultAttributes highlightedAttributes:(NSDictionary *)highlightedAttributes tapHandler:(LinkedStringTapHandler)tapHandler;

- (void)linkStrings:(NSArray *)strings defaultAttributes:(NSDictionary *)defaultAttributes highlightedAttributes:(NSDictionary *)highlightedAttributes tapHandler:(LinkedStringTapHandler)tapHandler;

- (void)linkStringsWithRegEx:(NSRegularExpression *)regex defaultAttributes:(NSDictionary *)defaultAttributes highlightedAttributes:(NSDictionary *)highlightedAttributes tapHandler:(LinkedStringTapHandler)tapHandler;

- (void)reset;


@end
