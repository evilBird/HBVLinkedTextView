//
//  HBVLinkedTextView.m
//  HBVLinkedTextView
//
//  Created by Travis Henspeter on 9/11/14.
//  Copyright (c) 2014 herbivore. All rights reserved.
//

#import "HBVLinkedTextView.h"

@interface HBVLinkedTextView ()

@property (nonatomic, strong)NSDictionary *tappableStringsDictionary;
@property (nonatomic, strong)NSMutableDictionary *handlers;
@property (nonatomic, strong)NSDictionary *rangeDictionary;
@property (nonatomic, strong)NSMutableDictionary *linkedTextTapHandlerDictionary;
@property (nonatomic, strong)NSMutableDictionary *linkedTextRangeDictionary;
@property (nonatomic, strong)NSMutableDictionary *linkedTextHighlightAttributeDictionary;
@property (nonatomic, strong)NSMutableDictionary *linkedTextDefaultAttributeDictionary;
@property (nonatomic, strong)NSString *activeString;
@property (nonatomic, strong)NSMutableArray *linkedStringsAndAttributes;
@property (nonatomic, strong)NSValue *initialTouchLocation;
@property (nonatomic,strong)UIColor *linkedTextDefaultColor;
@property (nonatomic,strong)UIFont *linkedTextDefaultFont;
@property (nonatomic,strong)UIColor *linkedTextHighlightedColor;
@property (nonatomic,strong)UIFont *linkedTextHighlightedFont;

@end

@implementation HBVLinkedTextView

#pragma mark - Public Methods

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

// Link individual strings with specifically defined linked text attributes

- (void)linkString:(NSString *)string defaultAttributes:(NSDictionary *)defaultAttributes highlightedAttributes:(NSDictionary *)highlightedAttributes tapHandler:(LinkedStringTapHandler)tapHandler
{
    if (!string || !defaultAttributes || !highlightedAttributes || tapHandler == NULL) {
        return;
    }
    
    NSDictionary *linkedStringDictionary = [self dictionaryForLinkedString:string
                                                         defaultAttributes:defaultAttributes
                                                     highlightedAttributes:highlightedAttributes
                                                                tapHandler:tapHandler];
    if (self.linkedStringsAndAttributes.count > 0) {
        [self addLinkedStringAndAttributes:linkedStringDictionary];
    }else{
        [self setLinkedStringsAndAttributes:@[linkedStringDictionary].mutableCopy];
    }
}

// Link an array of strings with specifically defined linked text attributes

- (void)linkStrings:(NSArray *)strings defaultAttributes:(NSDictionary *)defaultAttributes highlightedAttributes:(NSDictionary *)highlightedAttributes tapHandler:(LinkedStringTapHandler)tapHandler
{
    if (!strings || !defaultAttributes || !highlightedAttributes || tapHandler == NULL) {
        return;
    }
    
    for (NSString *aString in strings) {
        [self linkString:aString defaultAttributes:defaultAttributes highlightedAttributes:highlightedAttributes
              tapHandler:tapHandler];
    }
}

- (void)linkStringsWithRegEx:(NSRegularExpression *)regex defaultAttributes:(NSDictionary *)defaultAttributes highlightedAttributes:(NSDictionary *)highlightedAttributes tapHandler:(LinkedStringTapHandler)tapHandler
{
    if (!self.text) {
        return;
    }
    NSString *text = self.text;
    NSError *error = nil;
    NSArray *matches = [regex matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    if (error) {
        NSLog(@"\nHBVLinkedTextView Regex Error: %@",error.debugDescription);
        return;
    }
    
    NSMutableArray *results = [NSMutableArray array];
    for (NSTextCheckingResult *match in matches) {
        NSRange wordRange = [match rangeAtIndex:1];
        NSString* stringToLink = [text substringWithRange:wordRange];
        [results addObject:stringToLink];
    }
    
    if (results.count) {
        [self linkStrings:results defaultAttributes:defaultAttributes highlightedAttributes:highlightedAttributes tapHandler:tapHandler];
    }
}

- (void)reset
{
    self.activeString = nil;
    self.attributedText = nil;
    [self commonInit];
}

#pragma mark - Private Methods

- (NSDictionary *)dictionaryForLinkedString:(NSString *)linkedString defaultAttributes:(NSDictionary *)defaultAttributes highlightedAttributes:(NSDictionary *)highlightedAttributes tapHandler:(LinkedStringTapHandler)handler
{
    if (!defaultAttributes) {
        return nil;
    }
    
    if (!highlightedAttributes) {
        highlightedAttributes = defaultAttributes.copy;
    }
    
    return @{@"string": linkedString,
             @"defaultAttributes": defaultAttributes,
             @"highlightedAttributes":highlightedAttributes,
             @"handler":handler
             };
}

- (void)setRange:(NSRange)range forLinkedString:(NSString *)linkedString
{
    if (linkedString && range.length) {
        NSValue *rangeValue = [NSValue valueWithRange:range];
        self.linkedTextRangeDictionary[linkedString] = rangeValue;
    }
}

- (void)setDefaultAttributes:(NSDictionary *)attributes forLinkedString:(NSString *)linkedString
{
    if (attributes && linkedString) {
        self.linkedTextDefaultAttributeDictionary[linkedString] = attributes;
    }
}

- (void)setHighlightedAttributes:(NSDictionary *)attributes forLinkedString:(NSString *)linkedString
{
    if (attributes && linkedString) {
        self.linkedTextHighlightAttributeDictionary[linkedString] = attributes;
    }
}

- (void)setTapHandler:(LinkedStringTapHandler)tapHandler forLinkedString:(NSString *)linkedString
{
    if (tapHandler != NULL && linkedString) {
        self.linkedTextTapHandlerDictionary[linkedString] = [tapHandler copy];
    }
}

- (void)addLinkedStringAndAttributes:(NSDictionary *)linkedStringDictionary
{
    if (!self.text) {
        return;
    }
    
    NSString *text = self.text;
    NSAttributedString *attributedString = self.attributedText;
    NSString *string = linkedStringDictionary[@"string"];
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc]initWithAttributedString:attributedString];
    [mutableAttributedString beginEditing];
    NSRange rangeOfString = [text rangeOfString:string];
    if (rangeOfString.length) {
        [self setRange:rangeOfString forLinkedString:string];
        [self setDefaultAttributes:linkedStringDictionary[@"defaultAttributes"] forLinkedString:string];
        [mutableAttributedString addAttributes:linkedStringDictionary[@"defaultAttributes"] range:rangeOfString];
        [self setHighlightedAttributes:linkedStringDictionary[@"highlightedAttributes"] forLinkedString:string];
        [self setTapHandler:linkedStringDictionary[@"handler"] forLinkedString:string];
    }
    [mutableAttributedString endEditing];
    self.attributedText = mutableAttributedString;
    self.scrollEnabled = NO;
    
}

- (void)setLinkedStringsAndAttributes:(NSMutableArray *)linkedStringsAndAttributes
{
    if (!linkedStringsAndAttributes || !self.text) {
        return;
    }
    
    _linkedStringsAndAttributes = linkedStringsAndAttributes;
    
    NSString *text = self.text;
    NSAttributedString *attributedString = self.attributedText;
    
    if (!attributedString) {
        attributedString = [[NSAttributedString alloc]initWithString:text];
    }
    
    NSRange allTextRange;
    allTextRange.location = 0;
    allTextRange.length = text.length;
    
    if (!allTextRange.length) {
        return;
    }
    
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc]initWithAttributedString:attributedString];
    [mutableAttributedString beginEditing];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
    [paragraphStyle setAlignment:self.textAlignment];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    
    
    [mutableAttributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:allTextRange];
    
    for (NSDictionary *linkedStringDictionary in linkedStringsAndAttributes) {
        NSString *string = linkedStringDictionary[@"string"];
        NSRange rangeOfString = [text rangeOfString:string];
        if (rangeOfString.length) {
            [self setRange:rangeOfString forLinkedString:string];
            [self setDefaultAttributes:linkedStringDictionary[@"defaultAttributes"] forLinkedString:string];
            [mutableAttributedString addAttributes:linkedStringDictionary[@"defaultAttributes"] range:rangeOfString];
            [self setHighlightedAttributes:linkedStringDictionary[@"highlightedAttributes"] forLinkedString:string];
            [self setTapHandler:linkedStringDictionary[@"handler"] forLinkedString:string];
        }
    }
    
    [mutableAttributedString endEditing];
    self.attributedText = mutableAttributedString;
}

#pragma mark - Utility methods

- (void)setAttributes:(NSDictionary *)attributes forLinkedString:(NSString *)linkedString
{
    if (!attributes || !linkedString) {
        return;
    }
    
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc]initWithAttributedString:self.attributedText];
    NSRange linkedStringRange = [self.text rangeOfString:linkedString];
    [mutableAttributedString beginEditing];
    [mutableAttributedString addAttributes:attributes range:linkedStringRange];
    [mutableAttributedString endEditing];
    self.attributedText = mutableAttributedString;
}

- (void)setTextColor:(UIColor *)textColor forLinkedString:(NSString *)linkedString
{
    if (!textColor || !linkedString) {
        return;
    }
    
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc]initWithAttributedString:self.attributedText];
    NSRange linkedStringRange = [self.text rangeOfString:linkedString];
    [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:textColor range:linkedStringRange];
    self.attributedText = mutableAttributedString;
}


#pragma mark - Touch handling methods

- (NSString *)findLinkedStringAtPoint:(CGPoint)point inDictionary:(NSDictionary *)dictionary
{
    if (!dictionary) {
        return nil;
    }
    
    NSUInteger characterIndex;
    characterIndex = [self.layoutManager
                      characterIndexForPoint:point
                      inTextContainer:self.textContainer fractionOfDistanceBetweenInsertionPoints:NULL];
    
    __block NSString *result = nil;
    
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSValue *value = (NSValue *)obj;
        NSRange rangeToCheck = [value rangeValue];
        NSUInteger min = rangeToCheck.location;
        NSUInteger max = min + rangeToCheck.length;
        
        if (characterIndex >= min && characterIndex < max){
            
            result = key;
            *stop = YES;
        }
        
    }];
    
    return result;
    
}

- (NSString *)handleTouches:(NSSet *)touches
{
    CGPoint location = [touches.allObjects.lastObject locationInView:self];
    location.x -= self.textContainerInset.left;
    location.y -= self.textContainerInset.top;
    return [self findLinkedStringAtPoint:location inDictionary:self.linkedTextRangeDictionary];
}


- (NSValue *)locationOfTouches:(NSSet *)touches
{
    CGPoint location = [touches.allObjects.lastObject locationInView:self];
    location.x -= self.textContainerInset.left;
    location.y -= self.textContainerInset.top;
    return [NSValue valueWithCGPoint:location];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.initialTouchLocation = [self locationOfTouches:touches];
    NSString *tappedString = [self handleTouches:touches];
    NSDictionary *highlightAttributes = self.linkedTextHighlightAttributeDictionary[tappedString];
    if (tappedString && highlightAttributes) {
        self.activeString = tappedString;
        [self setAttributes:highlightAttributes forLinkedString:tappedString];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSString *tappedString = [self handleTouches:touches];
    if (tappedString != self.activeString) {
        if (self.activeString) {
            NSDictionary *defaultAttributes = self.linkedTextDefaultAttributeDictionary[self.activeString];
            [self setAttributes:defaultAttributes forLinkedString:self.activeString];
        }
        self.activeString = tappedString;
        NSDictionary *highlightedAttributes = self.linkedTextHighlightAttributeDictionary[tappedString];
        [self setAttributes:highlightedAttributes forLinkedString:tappedString];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSString *tappedString = [self handleTouches:touches];
    NSDictionary *defaultAttributes = self.linkedTextDefaultAttributeDictionary[tappedString];
    
    if (tappedString && defaultAttributes) {
        [self setAttributes:defaultAttributes forLinkedString:tappedString];
        if ([self continueTrackingTouches:touches]) {
            LinkedStringTapHandler tapHandler = self.linkedTextTapHandlerDictionary[tappedString];
            tapHandler(tappedString);
        }
        self.activeString = nil;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSString *tappedString = [self handleTouches:touches];
    NSDictionary *defaultAttributes = self.linkedTextDefaultAttributeDictionary[tappedString];
    if (tappedString && defaultAttributes) {
        [self setAttributes:defaultAttributes forLinkedString:tappedString];
        if ([self continueTrackingTouches:touches]) {
            LinkedStringTapHandler tapHandler = self.linkedTextTapHandlerDictionary[tappedString];
            tapHandler(tappedString);
        }
        self.activeString = nil;
    }
}

- (CGFloat)distanceFromInitialPoint:(NSValue *)point1 toNewPoint:(NSValue *)point2
{
    CGPoint start = point1.CGPointValue;
    CGPoint end = point2.CGPointValue;
    CGFloat dx = start.x - end.x;
    CGFloat dy = start.y - end.y;
    return sqrtf((dx * dx) + (dy * dy));
}

- (BOOL)continueTrackingTouches:(NSSet *)touches
{
    NSValue *currentLocation = [self locationOfTouches:touches];
    CGFloat distance = [self distanceFromInitialPoint:self.initialTouchLocation toNewPoint:currentLocation];
    
    return distance < 20;
}

#pragma mark - initializer

- (void)commonInit
{
    _linkedTextDefaultColor = [UIColor lightGrayColor];
    _linkedTextDefaultFont = [UIFont boldSystemFontOfSize:self.font.pointSize];
    _linkedTextHighlightedColor = [UIColor blackColor];
    _linkedTextHighlightedFont = [UIFont boldSystemFontOfSize:self.font.pointSize + 1.0f];
    
    _linkedTextTapHandlerDictionary = [NSMutableDictionary dictionary];
    _linkedTextRangeDictionary = [NSMutableDictionary dictionary];
    _linkedTextDefaultAttributeDictionary = [NSMutableDictionary dictionary];
    _linkedTextHighlightAttributeDictionary = [NSMutableDictionary dictionary];
    _handlers = [NSMutableDictionary dictionary];
    
    self.scrollEnabled = NO;
    self.allowsEditingTextAttributes = NO;
    self.selectable = NO;
    self.editable = NO;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
