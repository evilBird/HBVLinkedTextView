//
//  ViewController.m
//  HBVLinkedTextViewExample
//
//  Created by Travis Henspeter on 9/12/14.
//  Copyright (c) 2014 herbivore. All rights reserved.
//

#import "ViewController.h"
#import "HBVLinkedTextView.h"
#import "UIColor+HBVHarmonies.h"

@interface ViewController ()
            
@property (strong, nonatomic) IBOutlet HBVLinkedTextView *linkedTextView1;

@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self doTheDemo];
}

- (void)doTheDemo
{
    //Example text
    NSString *theText = @"This is some example text which helps to demonstrate the use of the HBVLinkedTextView class. Set default/highlighted text attributes and a block to be #executed when a tap gesture is @detected in a specified substring of the textview's text. You can set attributes and tap handling #blocks for #linked strings individually, by @passing in an array of strings, or with a @regular #expression.";
    
    //Set the text view's text property before linking substrings
    self.linkedTextView1.text = theText;
    
    //Create 2 dictionaries to pass in the text attributes for default / highlighted states
    NSMutableDictionary *defaultAttributes = [self exampleAttributes];
    NSMutableDictionary *highlightedAttributes = [self exampleAttributes];
    
    //The first string we're going to link
    NSString *stringToLink = @"This";
    
    //Pass in the string, attributes, and a tap handling block
    [self.linkedTextView1 linkString:stringToLink
                   defaultAttributes:defaultAttributes
               highlightedAttributes:highlightedAttributes
                          tapHandler:[self exampleHandlerWithTitle:@"Link a single string"]];
    
    //create an array of strings to link, which will all use the same attributes and tap handling block
    NSArray *arrayOfStrings = @[@"example",@"demonstrate",@"HBVLinkedTextView"];
    
    //Pass in the array, attribute dictionaries, and tap handler
    [self.linkedTextView1 linkStrings:arrayOfStrings
                    defaultAttributes:[self exampleAttributes]
                highlightedAttributes:[self exampleAttributes]
                           tapHandler:[self exampleHandlerWithTitle:@"Link an array of strings"]];
    
    //Create a regex to find & link hashtags
    NSError *err = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"#(\\w+)" options:0 error:&err];
    //Pass in regex, attributes, and tap handler
    [self.linkedTextView1 linkStringsWithRegEx:regex
                             defaultAttributes:defaultAttributes
                         highlightedAttributes:highlightedAttributes
                                    tapHandler:[self exampleHandlerWithTitle:@"Link with regex"]];
    
    //Alter our regex to link strings prefixed with a '@' character
    regex = [NSRegularExpression regularExpressionWithPattern:@"@(\\w+)" options:0 error:&err];
    
    //And pass in the parameters
    [self.linkedTextView1 linkStringsWithRegEx:regex
                             defaultAttributes:[self exampleAttributes]
                         highlightedAttributes:[self exampleAttributes]
                                    tapHandler:[self exampleHandlerWithTitle:@"Link with regex"]];
    
}

- (NSMutableDictionary *)exampleAttributes
{
    return [@{NSFontAttributeName:[UIFont boldSystemFontOfSize:[UIFont systemFontSize]],
             NSForegroundColorAttributeName:[UIColor randomColor]}mutableCopy];
}


- (LinkedStringTapHandler)exampleHandlerWithTitle:(NSString *)title
{
    LinkedStringTapHandler exampleHandler = ^(NSString *linkedString) {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title
                                                       message:[NSString stringWithFormat:@"Handle tap in linked string '%@'",linkedString]
                                                      delegate:nil
                                             cancelButtonTitle:@"Dismiss"
                                             otherButtonTitles:nil, nil];
        [alert show];
    };
    
    return exampleHandler;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
