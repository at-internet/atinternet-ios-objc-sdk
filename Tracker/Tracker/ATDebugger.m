/*
 This SDK is licensed under the MIT license (MIT)
 Copyright (c) 2015- Applied Technologies Internet SAS (registration number B 403 261 258 - Trade and Companies Register of Bordeaux – France)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */





//
//  ATDebugger.m
//  Tracker
//

#import "ATDebugger.h"
#import "ATDebuggerWindow.h"
#import "ATDebuggerEvent.h"
#import "ATHit.h"
#import "NSString+Tool.h"
#import "ATTool.h"
#import "ATTracker.h"
#import "ATStorage.h"


@interface ATDebugger()

@property (nonatomic, strong) UIButton *debugButton;
@property (nonatomic, strong) NSString *debugButtonPosition;
@property (nonatomic, strong) NSMutableArray *windows;
@property (nonatomic, strong) UILabel *windowTitleLabel;
@property (nonatomic, strong) NSMutableArray *hits;
@property (nonatomic, strong) UIPanGestureRecognizer *gestureRecogniser;
@property (nonatomic, strong) NSLayoutConstraint *debugButtonConstraint;
@property (nonatomic, strong) NSMutableArray *receivedEvents;
@property (nonatomic, getter=isDebuggerShown) BOOL debuggerShown;
@property (nonatomic, getter=isDebuggerAnimating) BOOL debuggerAnimating;
@property (nonatomic, strong) NSDateFormatter *hourFormatter;
@property (nonatomic, strong) NSDateFormatter *dateHourFormatter;
@property (nonatomic, strong) NSBundle *bundle;
@property (nonatomic, strong) ATStorage *storage;
@property (nonatomic, strong) NSLayoutConstraint *previousConstraintForEvents;

- (instancetype)init;
- (void) initDebugger;
- (void) deinitDebugger;
- (void) updateEventList;
- (void) createDebugButton;
- (void) debuggerTouched;
- (void) animateEventLog;
- (void) debugButtonWasDragged:(UIPanGestureRecognizer *)recogniser;
- (void) createEventViewer;
- (void) getEventsList:(ATDebuggerWindow *)eventViewer;
- (ATDebuggerWindow *) createWindow:(NSString *)windowTitle;
- (void)hidePreviousWindowMenuButtons:(UIView *)window;
- (void) eventRowSelected:(UIPanGestureRecognizer *)recogniser;
- (UIView *)createEventDetailView:(NSString *)hit;
- (void)backButtonWasTouched:(UIButton *)sender;
- (void)createOfflineHitsViewer;
- (void)trashOfflineHits;
- (void)deleteOfflineHit:(UIButton *)sender;
- (void)getOfflineHitsList:(ATDebuggerWindow *)offlineHits;
- (void)refreshOfflineHits;
- (void)offlineHitRowSelected:(UIPanGestureRecognizer *)recogniser;

@end

@implementation ATDebugger

@synthesize viewController = _viewController;

- (UIViewController *)viewController {
    return _viewController;
}

- (void)setViewController:(UIViewController *)viewController {
    if(viewController) {
        if(_viewController) {
            if(viewController != _viewController) {
                _viewController = viewController;
                
                [self deinitDebugger];
                [self initDebugger];
                [self updateEventList];
            }
        } else {
            _viewController = viewController;
            
            [self initDebugger];
        }
    } else {
        [self deinitDebugger];
        
        _viewController = viewController;
    }
}

+ (id)sharedInstance {
    static ATDebugger *sharedDebugger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDebugger = [[self alloc] init];
    });
    return sharedDebugger;
}

- (instancetype)init {
    if (self = [super init]) {
        self.hourFormatter = [[NSDateFormatter alloc] init];
        self.hourFormatter.dateFormat = @"HH':'mm':'ss";
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        self.hourFormatter.locale = locale;
        
        self.dateHourFormatter = [[NSDateFormatter alloc] init];
        self.dateHourFormatter.dateFormat = @"dd'/'MM'/'YYYY' 'HH':'mm':'ss";
        self.dateHourFormatter.locale = locale;
        
        self.debugButtonPosition = @"Right";
        self.debuggerAnimating = NO;
        self.debuggerShown = NO;
        
        self.windows = [[NSMutableArray alloc] init];
        self.receivedEvents = [[NSMutableArray alloc] init];
        
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"ATAssets" ofType:@"bundle"];
        if(!bundlePath){
            bundlePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"ATAssets" ofType:@"bundle"];
        }
        
        self.bundle = [NSBundle bundleWithPath:bundlePath];
    }
    return self;
}


- (void) initDebugger {
    self.storage = [ATStorage sharedInstanceOf:self.offlineMode];
    [self createDebugButton];
    [self createEventViewer];
    
    self.gestureRecogniser = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(debugButtonWasDragged:)];
    
    [self.debugButton addGestureRecognizer:self.gestureRecogniser];
    
    if(self.viewController) {
        [self.viewController.view bringSubviewToFront:self.debugButton];
    }
}

- (void) deinitDebugger {
    self.debuggerShown = NO;
    self.debuggerAnimating = NO;
    [self.debugButton removeFromSuperview];
    
    for (ATDebuggerWindow *window in self.windows) {
        [window.window removeFromSuperview];
    }
    
    [self.windows removeAllObjects];
}

- (void) addEvent:(NSString *)message icon:(NSString *)icon {
    ATDebuggerEvent *event = [[ATDebuggerEvent alloc] init];
    event.type = icon;
    event.message = message;
    
    [self.receivedEvents insertObject:event atIndex:0];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self addEventToList];
    });
    
}

#pragma mark - Debug button

- (void) createDebugButton {
    self.debugButton = [[UIButton alloc] init];
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"ATAssets" ofType:@"bundle"];
    if(!bundlePath){
        bundlePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"ATAssets" ofType:@"bundle"];
    }
    NSBundle* bundle = [NSBundle bundleWithPath:bundlePath];
    
    UIImage* img = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"atinternet-logo" ofType:@"png"]];
    
    [self.debugButton setBackgroundImage:img forState:UIControlStateNormal];
    
    self.debugButton.frame = CGRectMake(0, 0, 94, 73);
    [self.debugButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.debugButton.alpha = 0;
    
    if(self.viewController) {
        [self.viewController.view addSubview:self.debugButton];
        
        if([self.debugButtonPosition isEqualToString:@"Right"]) {
            self.debugButtonConstraint = [NSLayoutConstraint constraintWithItem:self.debugButton
                                                                      attribute:NSLayoutAttributeTrailing
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.viewController.view
                                                                      attribute:NSLayoutAttributeTrailing
                                                                     multiplier:1.0f
                                                                       constant:0];
        } else {
            self.debugButtonConstraint = [NSLayoutConstraint constraintWithItem:self.debugButton
                                                                      attribute:NSLayoutAttributeLeading
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.viewController.view
                                                                      attribute:NSLayoutAttributeLeading
                                                                     multiplier:1.0f
                                                                       constant:0];
        }
        
        [self.viewController.view addConstraint:self.debugButtonConstraint];
        
        [self.viewController.view addConstraint: [NSLayoutConstraint constraintWithItem:self.viewController.bottomLayoutGuide
                                                                              attribute:NSLayoutAttributeTop
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self.debugButton
                                                                              attribute:NSLayoutAttributeBottom
                                                                             multiplier:1.0f
                                                                               constant:10]];
        
        
        
        [self.viewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[debugButton(==94)]"
                                                                                         options:0 metrics:nil
                                                                                           views:@{@"debugButton": self.debugButton}]];
        
        [self.viewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[debugButton(==73)]"
                                                                                         options:0 metrics:nil
                                                                                           views:@{@"debugButton": self.debugButton}]];
        [self.debugButton addTarget:self action:@selector(debuggerTouched) forControlEvents:UIControlEventTouchUpInside];
        
        [UIView animateWithDuration:0.4
                              delay: 0.0
                            options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             self.debugButton.alpha = 1.0;
                         }
                         completion:nil];
        
    }
}

- (void) debugButtonWasDragged:(UIPanGestureRecognizer *)recogniser {
    UIButton *button = (UIButton *)recogniser.view;
    CGPoint translation = [recogniser translationInView:button];
    CGPoint velocity = [recogniser velocityInView:button];
    
    if(recogniser.state == UIGestureRecognizerStateChanged) {
        button.center = CGPointMake(button.center.x + translation.x, button.center.y);
        [recogniser setTranslation:CGPointZero inView:button];
    } else if(recogniser.state == UIGestureRecognizerStateEnded) {
        if(velocity.x < 0) {
            [UIView animateWithDuration:0.2
                                  delay: 0.0
                                options: UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.debugButtonConstraint.constant = (self.viewController.view.frame.size.width - button.frame.size.width) * -1;
                                 [self.viewController.view layoutIfNeeded];
                                 [self.viewController.view updateConstraints];
                             }
                             completion:^(BOOL finished){
                                 self.debugButtonPosition = @"Left";
                                 
                                 [self.viewController.view removeConstraint:self.debugButtonConstraint];
                                 
                                 self.debugButtonConstraint = [NSLayoutConstraint constraintWithItem:self.debugButton
                                                                                           attribute:NSLayoutAttributeLeading
                                                                                           relatedBy:NSLayoutRelationEqual
                                                                                              toItem:self.viewController.view
                                                                                           attribute:NSLayoutAttributeLeading
                                                                                          multiplier:1.0f
                                                                                            constant:0];
                                 
                                 [self.viewController.view addConstraint:self.debugButtonConstraint];
                             }];
        } else {
            [UIView animateWithDuration:0.2
                                  delay: 0.0
                                options: UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.debugButtonConstraint.constant = (self.viewController.view.frame.size.width - button.frame.size.width);
                                 [self.viewController.view layoutIfNeeded];
                                 [self.viewController.view updateConstraints];
                             }
                             completion:^(BOOL finished){
                                 self.debugButtonPosition = @"Right";
                                 
                                 [self.viewController.view removeConstraint:self.debugButtonConstraint];
                                 
                                 self.debugButtonConstraint = [NSLayoutConstraint constraintWithItem:self.debugButton
                                                                                           attribute:NSLayoutAttributeTrailing
                                                                                           relatedBy:NSLayoutRelationEqual
                                                                                              toItem:self.viewController.view
                                                                                           attribute:NSLayoutAttributeTrailing
                                                                                          multiplier:1.0f
                                                                                            constant:0];
                                 
                                 [self.viewController.view addConstraint:self.debugButtonConstraint];
                             }];
            
        }
    }
}

- (void) debuggerTouched {
    for(int i = 0; i < [self.windows count]; i++) {
        ((ATDebuggerWindow *)self.windows[i]).window.hidden = NO;
    }
    
    if(self.isDebuggerShown == YES && self.isDebuggerAnimating == NO) {
        self.debuggerAnimating = YES;
        
        [UIView animateWithDuration:0.2
                              delay: 0.0
                            options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             for(int i = 0; i < [self.windows count]; i++) {
                                 ((ATDebuggerWindow *)self.windows[i]).content.alpha = 0.0f;
                                 ((ATDebuggerWindow *)self.windows[i]).menu.alpha = 0.0f;
                             }
                         }
                         completion:^(BOOL finished){
                             [self animateEventLog];
                         }];
    } else {
        self.debuggerAnimating = YES;
        
        [self animateEventLog];
    }
}

- (void) animateEventLog {
    [UIView animateWithDuration:0.2
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         if(self.isDebuggerShown == YES) {
                             if(self.debugButtonConstraint.constant == 0) {
                                 for(int i = 0; i < [self.windows count]; i++) {
                                     ((ATDebuggerWindow *)self.windows[i]).window.frame = CGRectMake(self.viewController.view.frame.size.width - 47, self.viewController.view.frame.size.height - (self.viewController.bottomLayoutGuide.length + 93), 0, 0);
                                 }
                             } else {
                                 for(int i = 0; i < [self.windows count]; i++) {
                                     ((ATDebuggerWindow *)self.windows[i]).window.frame = CGRectMake(47, self.viewController.view.frame.size.height - (self.viewController.bottomLayoutGuide.length + 93), 0, 0);
                                 }
                             }
                         } else {
                             for(int i = 0; i < [self.windows count]; i++) {
                                 ((ATDebuggerWindow *)self.windows[i]).window.frame = CGRectMake(10, (self.viewController.topLayoutGuide.length + 10), self.viewController.view.frame.size.width - 20, self.viewController.view.frame.size.height - (self.viewController.bottomLayoutGuide.length + 93) - (self.viewController.topLayoutGuide.length + 10));
                             }
                         }
                     }
                     completion:^(BOOL finished){
                         if(self.isDebuggerShown == NO) {
                             [UIView animateWithDuration:0.2
                                                   delay: 0.0
                                                 options: UIViewAnimationOptionCurveLinear
                                              animations:^{
                                                  for(int i = 0; i < [self.windows count]; i++) {
                                                      ((ATDebuggerWindow *)self.windows[i]).content.alpha = 1.0f;
                                                      ((ATDebuggerWindow *)self.windows[i]).menu.alpha = 1.0f;
                                                      
                                                  }
                                              }
                                              completion:nil];
                             
                             [self.viewController.view bringSubviewToFront:((ATDebuggerWindow *)self.windows[[self.windows count] - 1]).window];
                         } else {
                             for(int i = 0; i < [self.windows count]; i++) {
                                 ((ATDebuggerWindow *)self.windows[i]).window.hidden = YES;
                             }
                         }
                         
                         self.debuggerShown = !self.debuggerShown;
                         self.debuggerAnimating = NO;
                     }];
}

#pragma mark - Event viewer

- (void) createEventViewer {
    ATDebuggerWindow* eventViewer = [self createWindow:@"Event viewer"];
    
    UIButton* offlineButton = [[UIButton alloc] init];
    [offlineButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [offlineButton setBackgroundImage:[UIImage imageWithContentsOfFile:[self.bundle pathForResource:@"database64" ofType:@"png"]] forState:UIControlStateNormal];
    [offlineButton addTarget:self action:@selector(createOfflineHitsViewer) forControlEvents:UIControlEventTouchUpInside];
    
    [eventViewer.menu addSubview:offlineButton];
    
    [eventViewer.menu addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[offlineButton(==32)]"
                                                                             options:0 metrics:nil
                                                                               views:@{@"offlineButton": offlineButton}]];
    
    [eventViewer.menu addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[offlineButton(==32)]"
                                                                             options:0 metrics:nil
                                                                               views:@{@"offlineButton": offlineButton}]];
    
    [eventViewer.menu addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-14-[offlineButton]"
                                                                             options:0 metrics:nil
                                                                               views:@{@"offlineButton": offlineButton}]];
    
    [eventViewer.menu addConstraint: [NSLayoutConstraint constraintWithItem:offlineButton
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:eventViewer.menu
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1.0f
                                                                   constant:0.0f]];
    self.windowTitleLabel = [[UILabel alloc] init];
    self.windowTitleLabel.textColor = [UIColor whiteColor];
    [self.windowTitleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.windowTitleLabel.text = eventViewer.windowTitle;
    [eventViewer.menu addSubview:self.windowTitleLabel];
    
    [eventViewer.menu addConstraint: [NSLayoutConstraint constraintWithItem:self.windowTitleLabel
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:eventViewer.menu
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1.0f
                                                                   constant:0.0f]];
    
    [eventViewer.menu addConstraint: [NSLayoutConstraint constraintWithItem:self.windowTitleLabel
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:eventViewer.menu
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1.0f
                                                                   constant:0.0f]];
    
    UIButton* trashButton = [[UIButton alloc] init];
    [trashButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [eventViewer.menu addSubview:trashButton];
    
    [trashButton setBackgroundImage:[UIImage imageWithContentsOfFile:[self.bundle pathForResource:@"trash64" ofType:@"png"]] forState:UIControlStateNormal];
    [trashButton addTarget:self action:@selector(trashEvents) forControlEvents:UIControlEventTouchUpInside];
    
    [eventViewer.menu addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[trashButton(==32)]"
                                                                             options:0 metrics:nil
                                                                               views:@{@"trashButton": trashButton}]];
    
    [eventViewer.menu addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[trashButton(==32)]"
                                                                             options:0 metrics:nil
                                                                               views:@{@"trashButton": trashButton}]];
    
    [eventViewer.menu addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[trashButton]-10-|"
                                                                             options:0 metrics:nil
                                                                               views:@{@"trashButton": trashButton}]];
    
    [eventViewer.menu addConstraint: [NSLayoutConstraint constraintWithItem:trashButton
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:eventViewer.menu
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1.0f
                                                                   constant:0.0f]];
    
    [self getEventsList:eventViewer];
    
}

- (void) getEventsList:(ATDebuggerWindow *)eventViewer {
    NSArray* scrollViews = [eventViewer.content.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self isKindOfClass: %@", [UIScrollView class]]];
    
    NSPredicate *emptyEventListPredicate = [NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        if([object isKindOfClass:[UIView class]]) {
            return(((UIView *)object).tag == -2);
        } else {
            return NO;
        }
    }];
    
    NSArray* emptyEventList = [eventViewer.content.subviews filteredArrayUsingPredicate:emptyEventListPredicate];
    
    if([scrollViews count] > 0) {
        for (UIView *row in [scrollViews[0] subviews]) {
            row.tag = 9999;
            [row removeFromSuperview];
        }
        [scrollViews[0] removeFromSuperview];
    }
    
    if([emptyEventList count] > 0) {
        [emptyEventList[0] removeFromSuperview];
    }
    
    UIScrollView* scrollView = [[UIScrollView alloc] init];
    [scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    scrollView.showsVerticalScrollIndicator = YES;
    scrollView.scrollEnabled = YES;
    scrollView.userInteractionEnabled = YES;
    scrollView.tag = -100;
    
    [eventViewer.content addSubview:scrollView];
    
    [eventViewer.content addConstraint: [NSLayoutConstraint constraintWithItem:scrollView
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:eventViewer.content
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0f
                                                                      constant:0.0f]];
    
    [eventViewer.content addConstraint: [NSLayoutConstraint constraintWithItem:scrollView
                                                                     attribute:NSLayoutAttributeBottom
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:eventViewer.content
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0f
                                                                      constant:0.0f]];
    
    [eventViewer.content addConstraint: [NSLayoutConstraint constraintWithItem:scrollView
                                                                     attribute:NSLayoutAttributeLeading
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:eventViewer.content
                                                                     attribute:NSLayoutAttributeLeading
                                                                    multiplier:1.0f
                                                                      constant:0.0f]];
    
    [eventViewer.content addConstraint: [NSLayoutConstraint constraintWithItem:scrollView
                                                                     attribute:NSLayoutAttributeTrailing
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:eventViewer.content
                                                                     attribute:NSLayoutAttributeTrailing
                                                                    multiplier:1.0f
                                                                      constant:0.0f]];
    
    if([self.receivedEvents count] == 0) {
        UIView* emptyContentView = [[UIView alloc] init];
        emptyContentView.tag = -2;
        [emptyContentView setTranslatesAutoresizingMaskIntoConstraints:NO];
        emptyContentView.layer.cornerRadius = 4.0f;
        emptyContentView.backgroundColor = [UIColor colorWithRed:139/255.0f green:139/255.0f blue:139/255.0f alpha:1.0f];
        
        [eventViewer.content addSubview:emptyContentView];
        
        [eventViewer.content addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[emptyContentView(==50)]"
                                                                                    options:0 metrics:nil
                                                                                      views:@{@"emptyContentView": emptyContentView}]];
        
        [eventViewer.content addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-30-[emptyContentView]-30-|"
                                                                                    options:0 metrics:nil
                                                                                      views:@{@"emptyContentView": emptyContentView}]];
        
        [eventViewer.content addConstraint: [NSLayoutConstraint constraintWithItem:emptyContentView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:eventViewer.content
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0f
                                                                          constant:0.0f]];
        
        UILabel* emptyContentLabel = [[UILabel alloc] init];
        [emptyContentLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        emptyContentLabel.text = @"No event detected";
        emptyContentLabel.textColor = [UIColor whiteColor];
        [emptyContentLabel sizeToFit];
        
        [emptyContentView addSubview:emptyContentLabel];
        
        [emptyContentView addConstraint: [NSLayoutConstraint constraintWithItem:emptyContentLabel
                                                                      attribute:NSLayoutAttributeCenterY
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:emptyContentView
                                                                      attribute:NSLayoutAttributeCenterY
                                                                     multiplier:1.0f
                                                                       constant:0.0f]];
        
        [emptyContentView addConstraint: [NSLayoutConstraint constraintWithItem:emptyContentLabel
                                                                      attribute:NSLayoutAttributeCenterX
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:emptyContentView
                                                                      attribute:NSLayoutAttributeCenterX
                                                                     multiplier:1.0f
                                                                       constant:0.0f]];
    } else {
        self.previousConstraintForEvents = nil;
        int i = 0;
        UIView *previous = nil;
        for(ATDebuggerEvent* event in self.receivedEvents) {
            previous = [self buildEventRow:event withTag:i usingScrollView:scrollView andPreviousRow:previous];
            i += 1;
        }
    }
}

- (UIView *) buildEventRow:(ATDebuggerEvent *)event withTag:(NSInteger)tag usingScrollView:(UIScrollView*) scrollView andPreviousRow: (UIView *)previousRow {
    UIView* rowView = [[UIView alloc] init];
    [rowView setTranslatesAutoresizingMaskIntoConstraints:NO];
    rowView.userInteractionEnabled = YES;
    rowView.tag = tag;
    
    [rowView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(eventRowSelected:)]];
    
    [scrollView addSubview:rowView];
    
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[rowView]-0-|"
                                                                       options:0 metrics:nil
                                                                         views:@{@"rowView": rowView}]];
    
    if(tag == 0) {
        [scrollView addConstraint: [NSLayoutConstraint constraintWithItem:rowView
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:scrollView
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1.0f
                                                                 constant:0.0f]];
        
        [scrollView addConstraint: [NSLayoutConstraint constraintWithItem:rowView
                                                                attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:scrollView
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:1.0f
                                                                 constant:0.0f]];
    } else {
        [scrollView addConstraint: [NSLayoutConstraint constraintWithItem:rowView
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:previousRow
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1.0f
                                                                 constant:0.0f]];
    }
    
    if(tag % 2 == 0) {
        rowView.backgroundColor = [UIColor colorWithRed:214/255.0f green:214/255.0f blue:214/255.0f alpha:1];
    } else {
        rowView.backgroundColor = [UIColor whiteColor];
    }
    
    if(tag == [self.receivedEvents count] - 1) {
        if (self.previousConstraintForEvents) {
            [scrollView removeConstraint:self.previousConstraintForEvents];
        }
        self.previousConstraintForEvents = [NSLayoutConstraint constraintWithItem:rowView
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:scrollView
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0f
                                                                         constant:0.0f];
        [scrollView addConstraint: self.previousConstraintForEvents];
    }
    
    UIImageView* iconView = [[UIImageView alloc] init];
    UILabel* dateLabel = [[UILabel alloc] init];
    UILabel* messageLabel = [[UILabel alloc] init];
    UIImageView* hitTypeView = [[UIImageView alloc] init];
    
    [iconView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [dateLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [messageLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [hitTypeView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [rowView addSubview:iconView];
    [rowView addSubview:dateLabel];
    [rowView addSubview:messageLabel];
    [rowView addSubview:hitTypeView];
    iconView.image =[UIImage imageWithContentsOfFile:[self.bundle pathForResource:[NSString stringWithFormat:@"%@", event.type] ofType:@"png"]];
    
    [rowView addConstraint: [NSLayoutConstraint constraintWithItem:iconView
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:rowView
                                                         attribute:NSLayoutAttributeLeft
                                                        multiplier:1.0f
                                                          constant:5.0f]];
    
    [rowView addConstraint: [NSLayoutConstraint constraintWithItem:iconView
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:rowView
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0f
                                                          constant:-1.0f]];
    
    [rowView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[iconView(==24)]"
                                                                    options:0 metrics:nil
                                                                      views:@{@"iconView": iconView}]];
    
    [rowView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[iconView(==24)]"
                                                                    options:0 metrics:nil
                                                                      views:@{@"iconView": iconView}]];
    
    dateLabel.text = [self.hourFormatter stringFromDate:event.date];
    [dateLabel sizeToFit];
    
    [rowView addConstraint: [NSLayoutConstraint constraintWithItem:dateLabel
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:iconView
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0f
                                                          constant:5.0f]];
    
    [rowView addConstraint: [NSLayoutConstraint constraintWithItem:dateLabel
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:rowView
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0f
                                                          constant:0.0f]];
    
    messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    messageLabel.baselineAdjustment = UIBaselineAdjustmentNone;
    messageLabel.text = event.message;
    
    [rowView addConstraint: [NSLayoutConstraint constraintWithItem:messageLabel
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:dateLabel
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0f
                                                          constant:10.0f]];
    
    [rowView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-12-[messageLabel]-12-|"
                                                                    options:0 metrics:nil
                                                                      views:@{@"messageLabel": messageLabel}]];
    
    NSURL* URL = [[NSURL alloc] initWithString:event.message];
    
    if(URL) {
        hitTypeView.hidden = NO;
        
        ATHit* hit = [[ATHit alloc] init:URL.absoluteString];
        
        switch([hit hitType]) {
            case ATHitTypeTouch:
                hitTypeView.image = [UIImage imageNamed:@"ATAssets.bundle/touch48"];
                break;
            case ATHitTypeAdTracking:
                hitTypeView.image = [UIImage imageNamed:@"ATAssets.bundle/tv48"];
                break;
            case ATHitTypeAudio:
                hitTypeView.image = [UIImage imageNamed:@"ATAssets.bundle/audio48"];
                break;
            case ATHitTypeVideo:
                hitTypeView.image = [UIImage imageNamed:@"ATAssets.bundle/video48"];
                break;
            case ATHitTypeProductDisplay:
                hitTypeView.image = [UIImage imageNamed:@"ATAssets.bundle/product48"];
                break;
            default:
                hitTypeView.image = [UIImage imageNamed:@"ATAssets.bundle/smartphone48"];
                break;
        }
    } else {
        hitTypeView.hidden = YES;
    }
    
    [rowView addConstraint: [NSLayoutConstraint constraintWithItem:hitTypeView
                                                         attribute:NSLayoutAttributeLeft
                                                         relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                            toItem:messageLabel
                                                         attribute:NSLayoutAttributeRight
                                                        multiplier:1.0f
                                                          constant:10.0f]];
    
    [rowView addConstraint: [NSLayoutConstraint constraintWithItem:hitTypeView
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:messageLabel
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0f
                                                          constant:-1.0f]];
    
    [rowView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[hitTypeView(==24)]"
                                                                    options:0 metrics:nil
                                                                      views:@{@"hitTypeView": hitTypeView}]];
    
    [rowView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[hitTypeView(==24)]"
                                                                    options:0 metrics:nil
                                                                      views:@{@"hitTypeView": hitTypeView}]];
    
    [rowView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[hitTypeView]-5-|"
                                                                    options:0 metrics:nil
                                                                      views:@{@"hitTypeView": hitTypeView}]];
    
    return rowView;
}

- (void) updateEventList {
    ATDebuggerWindow* window =  (ATDebuggerWindow *)self.windows[0];
    
    [self getEventsList:window];
}

- (void) addEventToList {
    ATDebuggerWindow* window =  (ATDebuggerWindow *)self.windows[0];
    [[window.content viewWithTag:-2] removeFromSuperview];
    UIScrollView *scrollView = [window.content viewWithTag:-100];
    [self buildEventRow:self.receivedEvents[self.receivedEvents.count - 1] withTag:(self.receivedEvents.count - 1) usingScrollView:scrollView andPreviousRow:[scrollView viewWithTag:(self.receivedEvents.count-2)]];
}

- (void) eventRowSelected:(UIPanGestureRecognizer *)recogniser {
    ((ATDebuggerWindow *)self.windows[0]).content.hidden = YES;
    
    if(recogniser.view) {
        UIView* window = [self createEventDetailView:((ATDebuggerEvent *)self.receivedEvents[recogniser.view.tag]).message];
        
        [self hidePreviousWindowMenuButtons:window];
    }
}

- (void)trashEvents {
    [self.receivedEvents removeAllObjects];
    [self updateEventList];
}

#pragma mark - Event detail

- (UIView *)createEventDetailView:(NSString *)hit {
    ATDebuggerWindow* eventDetail = [self createWindow:@"Hit Detail"];
    eventDetail.window.alpha = 0.0f;
    eventDetail.window.hidden = NO;
    eventDetail.content.alpha = 1.0f;
    eventDetail.menu.alpha = 1.0f;
    
    UIButton* backButton = [[UIButton alloc] init];
    [backButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [eventDetail.menu addSubview:backButton];
    
    [backButton setBackgroundImage:[UIImage imageWithContentsOfFile:[self.bundle pathForResource:@"back64" ofType:@"png"]] forState:UIControlStateNormal];
    backButton.tag = [self.windows count] - 1;
    [backButton addTarget:self action:@selector(backButtonWasTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    [eventDetail.menu addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[backButton(==32)]"
                                                                             options:0 metrics:nil
                                                                               views:@{@"backButton": backButton}]];
    
    [eventDetail.menu addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[backButton(==32)]"
                                                                             options:0 metrics:nil
                                                                               views:@{@"backButton": backButton}]];
    
    [eventDetail.menu addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-14-[backButton]"
                                                                             options:0 metrics:nil
                                                                               views:@{@"backButton": backButton}]];
    
    [eventDetail.menu addConstraint: [NSLayoutConstraint constraintWithItem:backButton
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:eventDetail.menu
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1.0f
                                                                   constant:0.0f]];
    
    UIScrollView* scrollView = [[UIScrollView alloc] init];
    [scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    scrollView.showsVerticalScrollIndicator = YES;
    scrollView.scrollEnabled = YES;
    scrollView.userInteractionEnabled = YES;
    
    [eventDetail.content addSubview:scrollView];
    
    [eventDetail.content addConstraint: [NSLayoutConstraint constraintWithItem:scrollView
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:eventDetail.content
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0f
                                                                      constant:0.0f]];
    
    [eventDetail.content addConstraint: [NSLayoutConstraint constraintWithItem:scrollView
                                                                     attribute:NSLayoutAttributeBottom
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:eventDetail.content
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0f
                                                                      constant:0.0f]];
    
    [eventDetail.content addConstraint: [NSLayoutConstraint constraintWithItem:scrollView
                                                                     attribute:NSLayoutAttributeLeading
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:eventDetail.content
                                                                     attribute:NSLayoutAttributeLeading
                                                                    multiplier:1.0f
                                                                      constant:0.0f]];
    
    [eventDetail.content addConstraint: [NSLayoutConstraint constraintWithItem:scrollView
                                                                     attribute:NSLayoutAttributeTrailing
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:eventDetail.content
                                                                     attribute:NSLayoutAttributeTrailing
                                                                    multiplier:1.0f
                                                                      constant:0.0f]];
    
    NSURL* URL = [[NSURL alloc] initWithString:hit];
    
    if(URL) {
        eventDetail.windowTitle = @"Hit detail";
        self.windowTitleLabel.text = eventDetail.windowTitle;
        
        NSMutableArray* urlComponents = [[NSMutableArray alloc] init];
        
        NSDictionary* sslComponent = @{@"ssl":(URL.scheme && [URL.scheme isEqualToString:@"http"]) ? @"Off" : @"On" };
        [urlComponents addObject:sslComponent];
        
        NSDictionary* logComponent = @{@"log": URL.host };
        [urlComponents addObject:logComponent];
        
        NSArray* queryStringComponents = [URL.query componentsSeparatedByString:@"&"];
        
        for(NSString* component in queryStringComponents) {
            NSArray* pairComponents = [component componentsSeparatedByString:@"="];
            
            [urlComponents addObject:@{(NSString *)pairComponents[0]: [((NSString *)pairComponents[1]) percentDecodedString] }];
        }
        
        int i = 0;
        UIView* previousRow;
        
        for(NSDictionary* dict in urlComponents) {
            NSString* key = dict.allKeys[0];
            NSString* value = dict.allValues[0];
            
            UIView* rowView = [[UIView alloc] init];
            [rowView setTranslatesAutoresizingMaskIntoConstraints:NO];
            
            [scrollView addSubview:rowView];
            
            [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[rowView]-0-|"
                                                                               options:0 metrics:nil
                                                                                 views:@{@"rowView": rowView}]];
            
            if(i == 0) {
                [scrollView addConstraint: [NSLayoutConstraint constraintWithItem:rowView
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:scrollView
                                                                        attribute:NSLayoutAttributeTop
                                                                       multiplier:1.0f
                                                                         constant:0.0f]];
                
                [scrollView addConstraint: [NSLayoutConstraint constraintWithItem:rowView
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:scrollView
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1.0f
                                                                         constant:0.0f]];
            } else {
                [scrollView addConstraint: [NSLayoutConstraint constraintWithItem:rowView
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:previousRow
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0f
                                                                         constant:0.0f]];
            }
            
            if(i % 2 == 0) {
                rowView.backgroundColor = [UIColor colorWithRed:214/255.0f green:214/255.0f blue:214/255.0f alpha:1];
            } else {
                rowView.backgroundColor = [UIColor whiteColor];
            }
            
            if(i == [urlComponents count] - 1) {
                [scrollView addConstraint: [NSLayoutConstraint constraintWithItem:rowView
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:scrollView
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0f
                                                                         constant:0.0f]];
            }
            
            UILabel* variableLabel = [[UILabel alloc] init];
            [variableLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            variableLabel.text = key;
            variableLabel.textAlignment = NSTextAlignmentRight;
            variableLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            
            [rowView addSubview:variableLabel];
            
            [rowView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[variableLabel(==100)]"
                                                                            options:0 metrics:nil
                                                                              views:@{@"variableLabel": variableLabel}]];
            
            [rowView addConstraint: [NSLayoutConstraint constraintWithItem:variableLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:rowView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0f
                                                                  constant:12.0f]];
            
            [rowView addConstraint: [NSLayoutConstraint constraintWithItem:rowView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                    toItem:variableLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0f
                                                                  constant:12.0f]];
            
            [rowView addConstraint: [NSLayoutConstraint constraintWithItem:variableLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:rowView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0f
                                                                  constant:0.0f]];
            
            UIView* columnSeparator = [[UIView alloc] init];
            [columnSeparator setTranslatesAutoresizingMaskIntoConstraints:NO];
            columnSeparator.backgroundColor = [UIColor colorWithRed:80/255.0f green:80/255.0f blue:80/255.0f alpha:1.0f];
            
            [rowView addSubview:columnSeparator];
            
            [rowView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[columnSeparator(==1)]"
                                                                            options:0 metrics:nil
                                                                              views:@{@"columnSeparator": columnSeparator}]];
            
            [rowView addConstraint: [NSLayoutConstraint constraintWithItem:columnSeparator
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:variableLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0f
                                                                  constant:10.0f]];
            
            [rowView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[columnSeparator]-0-|"
                                                                            options:0 metrics:nil
                                                                              views:@{@"columnSeparator": columnSeparator}]];
            
            
            UILabel* valueLabel = [[UILabel alloc] init];
            [valueLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            
            id JSON = [value parseJSONString];
            
            if(JSON) {
                if([key isEqualToString:@"stc"]) {
                    valueLabel.text = [ATTool JSONStringify:JSON prettyPrinted:YES];
                } else {
                    valueLabel.text = value;
                }
            } else {
                valueLabel.text = value;
            }
            
            valueLabel.textAlignment = NSTextAlignmentLeft;
            valueLabel.lineBreakMode = NSLineBreakByWordWrapping;
            valueLabel.numberOfLines = 0;
            
            [rowView addSubview:valueLabel];
            
            [rowView addConstraint: [NSLayoutConstraint constraintWithItem:valueLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:columnSeparator
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0f
                                                                  constant:10.0f]];
            
            [rowView addConstraint: [NSLayoutConstraint constraintWithItem:valueLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:rowView
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0f
                                                                  constant:10.0f]];
            
            [rowView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-12-[valueLabel]-12-|"
                                                                            options:0 metrics:nil
                                                                              views:@{@"valueLabel": valueLabel}]];
            
            previousRow = rowView;
            
            i++;
        }
    } else {
        eventDetail.windowTitle = @"Event Detail";
        _windowTitleLabel.text = eventDetail.windowTitle;
        UILabel *eventMessageLabel = [[UILabel alloc] init];
        eventMessageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        eventMessageLabel.text = hit;
        eventMessageLabel.textAlignment = NSTextAlignmentLeft;
        eventMessageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        eventMessageLabel.numberOfLines = 0;
        [scrollView addSubview:eventMessageLabel];
        [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:eventMessageLabel
                                                               attribute:NSLayoutAttributeLeading
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:scrollView
                                                               attribute:NSLayoutAttributeLeading
                                                              multiplier:1.0
                                                                constant:10]];
        [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:eventMessageLabel
                                                               attribute:NSLayoutAttributeTrailing
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:scrollView
                                                               attribute:NSLayoutAttributeTrailing
                                                              multiplier:1.0
                                                                constant:10]];
        [scrollView addConstraint:[NSLayoutConstraint constraintWithItem:eventMessageLabel
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:scrollView
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.0
                                                                constant:10]];
        [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[eventMessageLabel]-10-|"
                                                                           options:NSLayoutFormatAlignAllLeft
                                                                           metrics:nil
                                                                             views:@{@"eventMessageLabel":eventMessageLabel}]];
    }
    
    return eventDetail.window;
}

#pragma mark - Offline hits
- (void)createOfflineHitsViewer {
    ATDebuggerWindow* offlineHits = [self createWindow:@"Offline Hits"];
    offlineHits.window.alpha = 0.0f;
    offlineHits.window.hidden = NO;
    offlineHits.content.alpha = 1.0f;
    offlineHits.menu.alpha = 1.0f;
    
    self.windowTitleLabel.text = offlineHits.windowTitle;
    
    UIButton* backButton = [[UIButton alloc] init];
    [backButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [offlineHits.menu addSubview:backButton];
    
    [backButton setBackgroundImage:[UIImage imageWithContentsOfFile:[self.bundle pathForResource:@"back64" ofType:@"png"]] forState:UIControlStateNormal];
    backButton.tag = [self.windows count] - 1;
    [backButton addTarget:self action:@selector(backButtonWasTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    [offlineHits.menu addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[backButton(==32)]"
                                                                             options:0 metrics:nil
                                                                               views:@{@"backButton": backButton}]];
    
    [offlineHits.menu addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[backButton(==32)]"
                                                                             options:0 metrics:nil
                                                                               views:@{@"backButton": backButton}]];
    
    [offlineHits.menu addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-14-[backButton]"
                                                                             options:0 metrics:nil
                                                                               views:@{@"backButton": backButton}]];
    
    [offlineHits.menu addConstraint: [NSLayoutConstraint constraintWithItem:backButton
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:offlineHits.menu
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1.0f
                                                                   constant:0.0f]];
    
    UIButton* trashButton = [[UIButton alloc] init];
    [trashButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [offlineHits.menu addSubview:trashButton];
    
    [trashButton setBackgroundImage:[UIImage imageWithContentsOfFile:[self.bundle pathForResource:@"trash64" ofType:@"png"]] forState:UIControlStateNormal];
    [trashButton addTarget:self action:@selector(trashOfflineHits) forControlEvents:UIControlEventTouchUpInside];
    
    [offlineHits.menu addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[trashButton(==32)]"
                                                                             options:0 metrics:nil
                                                                               views:@{@"trashButton": trashButton}]];
    
    [offlineHits.menu addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[trashButton(==32)]"
                                                                             options:0 metrics:nil
                                                                               views:@{@"trashButton": trashButton}]];
    
    [offlineHits.menu addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[trashButton]-10-|"
                                                                             options:0 metrics:nil
                                                                               views:@{@"trashButton": trashButton}]];
    
    [offlineHits.menu addConstraint: [NSLayoutConstraint constraintWithItem:trashButton
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:offlineHits.menu
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1.0f
                                                                   constant:0.0f]];
    
    UIButton* refreshButton = [[UIButton alloc] init];
    [refreshButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [offlineHits.menu addSubview:refreshButton];
    
    [refreshButton setBackgroundImage:[UIImage imageWithContentsOfFile:[self.bundle pathForResource:@"refresh64" ofType:@"png"]] forState:UIControlStateNormal];
    [refreshButton addTarget:self action:@selector(refreshOfflineHits) forControlEvents:UIControlEventTouchUpInside];
    
    [offlineHits.menu addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[refreshButton(==32)]"
                                                                             options:0 metrics:nil
                                                                               views:@{@"refreshButton": refreshButton}]];
    
    [offlineHits.menu addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[refreshButton(==32)]"
                                                                             options:0 metrics:nil
                                                                               views:@{@"refreshButton": refreshButton}]];
    
    [offlineHits.menu addConstraint: [NSLayoutConstraint constraintWithItem:trashButton
                                                                  attribute:NSLayoutAttributeLeading
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:refreshButton
                                                                  attribute:NSLayoutAttributeTrailing
                                                                 multiplier:1.0f
                                                                   constant:10.0f]];
    
    [offlineHits.menu addConstraint: [NSLayoutConstraint constraintWithItem:refreshButton
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:offlineHits.menu
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1.0f
                                                                   constant:0.0f]];
    
    [self getOfflineHitsList:offlineHits];
    
    [self hidePreviousWindowMenuButtons:offlineHits.window];
}

- (void)refreshOfflineHits {
    [self getOfflineHitsList:(ATDebuggerWindow *)self.windows[[self.windows count] - 1]];
}

- (void)getOfflineHitsList:(ATDebuggerWindow *)offlineHits {
    NSArray* scrollViews = [offlineHits.content.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self isKindOfClass: %@", [UIScrollView class]]];
    
    NSPredicate *emptyEventListPredicate = [NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
        if([object isKindOfClass:[UIView class]]) {
            return(((UIView *)object).tag == -2);
        } else {
            return NO;
        }
    }];
    
    NSArray* emptyEventList = [offlineHits.content.subviews filteredArrayUsingPredicate:emptyEventListPredicate];
    
    if([scrollViews count] > 0) {
        [scrollViews[0] removeFromSuperview];
    }
    
    if([emptyEventList count] > 0) {
        [emptyEventList[0] removeFromSuperview];
    }
    
    UIScrollView* scrollView = [[UIScrollView alloc] init];
    [scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    scrollView.showsVerticalScrollIndicator = YES;
    scrollView.scrollEnabled = YES;
    scrollView.userInteractionEnabled = YES;
    
    [offlineHits.content addSubview:scrollView];
    
    [offlineHits.content addConstraint: [NSLayoutConstraint constraintWithItem:scrollView
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:offlineHits.content
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1.0f
                                                                      constant:0.0f]];
    
    [offlineHits.content addConstraint: [NSLayoutConstraint constraintWithItem:scrollView
                                                                     attribute:NSLayoutAttributeBottom
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:offlineHits.content
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1.0f
                                                                      constant:0.0f]];
    
    [offlineHits.content addConstraint: [NSLayoutConstraint constraintWithItem:scrollView
                                                                     attribute:NSLayoutAttributeLeading
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:offlineHits.content
                                                                     attribute:NSLayoutAttributeLeading
                                                                    multiplier:1.0f
                                                                      constant:0.0f]];
    
    [offlineHits.content addConstraint: [NSLayoutConstraint constraintWithItem:scrollView
                                                                     attribute:NSLayoutAttributeTrailing
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:offlineHits.content
                                                                     attribute:NSLayoutAttributeTrailing
                                                                    multiplier:1.0f
                                                                      constant:0.0f]];
    
    UIView* previousRow;
    
    self.hits = [[NSMutableArray alloc] initWithArray: [[self.storage hits] sortedArrayUsingComparator:^NSComparisonResult(ATHit* a, ATHit* b) {
        NSDate *first = b.creationDate;
        NSDate *second = a.creationDate;;
        return [first compare:second];
    }]];
    
    if([self.hits count] == 0) {
        UIView* noOfflineHitsView = [[UIView alloc] init];
        noOfflineHitsView.tag = -2;
        [noOfflineHitsView setTranslatesAutoresizingMaskIntoConstraints:NO];
        noOfflineHitsView.layer.cornerRadius = 4.0f;
        noOfflineHitsView.backgroundColor = [UIColor colorWithRed:139/255.0f green:139/255.0f blue:139/255.0f alpha:1.0f];
        
        [offlineHits.content addSubview:noOfflineHitsView];
        
        [offlineHits.content addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[emptyContentView(==50)]"
                                                                                    options:0 metrics:nil
                                                                                      views:@{@"emptyContentView": noOfflineHitsView}]];
        
        [offlineHits.content addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-30-[emptyContentView]-30-|"
                                                                                    options:0 metrics:nil
                                                                                      views:@{@"emptyContentView": noOfflineHitsView}]];
        
        [offlineHits.content addConstraint: [NSLayoutConstraint constraintWithItem:noOfflineHitsView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:offlineHits.content
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0f
                                                                          constant:0.0f]];
        
        UILabel* emptyContentLabel = [[UILabel alloc] init];
        [emptyContentLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        emptyContentLabel.text = @"No event detected";
        emptyContentLabel.textColor = [UIColor whiteColor];
        [emptyContentLabel sizeToFit];
        
        [noOfflineHitsView addSubview:emptyContentLabel];
        
        [noOfflineHitsView addConstraint: [NSLayoutConstraint constraintWithItem:emptyContentLabel
                                                                       attribute:NSLayoutAttributeCenterY
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:noOfflineHitsView
                                                                       attribute:NSLayoutAttributeCenterY
                                                                      multiplier:1.0f
                                                                        constant:0.0f]];
        
        [noOfflineHitsView addConstraint: [NSLayoutConstraint constraintWithItem:emptyContentLabel
                                                                       attribute:NSLayoutAttributeCenterX
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:noOfflineHitsView
                                                                       attribute:NSLayoutAttributeCenterX
                                                                      multiplier:1.0f
                                                                        constant:0.0f]];
    } else {
        int i = 0;
        
        for(ATHit* hit in self.hits) {
            UIView* rowView = [[UIView alloc] init];
            [rowView setTranslatesAutoresizingMaskIntoConstraints:NO];
            rowView.userInteractionEnabled = YES;
            rowView.tag = i;
            
            [rowView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(offlineHitRowSelected:)]];
            
            [scrollView addSubview:rowView];
            
            [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[rowView]-0-|"
                                                                               options:0 metrics:nil
                                                                                 views:@{@"rowView": rowView}]];
            
            if(i == 0) {
                [scrollView addConstraint: [NSLayoutConstraint constraintWithItem:rowView
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:scrollView
                                                                        attribute:NSLayoutAttributeTop
                                                                       multiplier:1.0f
                                                                         constant:0.0f]];
                
                [scrollView addConstraint: [NSLayoutConstraint constraintWithItem:rowView
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:scrollView
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1.0f
                                                                         constant:0.0f]];
            } else {
                [scrollView addConstraint: [NSLayoutConstraint constraintWithItem:rowView
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:previousRow
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0f
                                                                         constant:0.0f]];
            }
            
            if(i % 2 == 0) {
                rowView.backgroundColor = [UIColor colorWithRed:214/255.0f green:214/255.0f blue:214/255.0f alpha:1];
            } else {
                rowView.backgroundColor = [UIColor whiteColor];
            }
            
            if(i == [self.hits count] - 1) {
                [scrollView addConstraint: [NSLayoutConstraint constraintWithItem:rowView
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:scrollView
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0f
                                                                         constant:0.0f]];
            }
            
            
            UILabel* dateLabel = [[UILabel alloc] init];
            UILabel* messageLabel = [[UILabel alloc] init];
            UIImageView* hitTypeView = [[UIImageView alloc] init];
            UIButton* deleteButton = [[UIButton alloc] init];
            
            [dateLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            [messageLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
            [hitTypeView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [deleteButton setTranslatesAutoresizingMaskIntoConstraints:NO];
            
            [rowView addSubview:dateLabel];
            [rowView addSubview:messageLabel];
            [rowView addSubview:hitTypeView];
            [rowView addSubview:deleteButton];
            
            dateLabel.text = [self.dateHourFormatter stringFromDate:hit.creationDate];
            [dateLabel sizeToFit];
            
            [rowView addConstraint: [NSLayoutConstraint constraintWithItem:dateLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:rowView
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0f
                                                                  constant:5.0f]];
            
            [rowView addConstraint: [NSLayoutConstraint constraintWithItem:dateLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:rowView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0f
                                                                  constant:0.0f]];
            
            messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            messageLabel.baselineAdjustment = UIBaselineAdjustmentNone;
            messageLabel.text = hit.url;
            
            [rowView addConstraint: [NSLayoutConstraint constraintWithItem:messageLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:dateLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0f
                                                                  constant:10.0f]];
            
            [rowView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-12-[messageLabel]-12-|"
                                                                            options:0 metrics:nil
                                                                              views:@{@"messageLabel": messageLabel}]];
            
            switch([hit hitType]) {
                case ATHitTypeTouch:
                    hitTypeView.image = [UIImage imageWithContentsOfFile:[self.bundle pathForResource:@"touch48" ofType:@"png"]];
                    break;
                case ATHitTypeAdTracking:
                    hitTypeView.image = [UIImage imageWithContentsOfFile:[self.bundle pathForResource:@"tv48" ofType:@"png"]];
                    break;
                case ATHitTypeAudio:
                    hitTypeView.image = [UIImage imageWithContentsOfFile:[self.bundle pathForResource:@"audio48" ofType:@"png"]];
                    break;
                case ATHitTypeVideo:
                    hitTypeView.image = [UIImage imageWithContentsOfFile:[self.bundle pathForResource:@"video48" ofType:@"png"]];
                    break;
                case ATHitTypeProductDisplay:
                    hitTypeView.image = [UIImage imageWithContentsOfFile:[self.bundle pathForResource:@"product48" ofType:@"png"]];
                    break;
                default:
                    hitTypeView.image = [UIImage imageWithContentsOfFile:[self.bundle pathForResource:@"smartphone48" ofType:@"png"]];
                    break;
            }
            
            [rowView addConstraint: [NSLayoutConstraint constraintWithItem:hitTypeView
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                    toItem:messageLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                multiplier:1.0f
                                                                  constant:10.0f]];
            
            [rowView addConstraint: [NSLayoutConstraint constraintWithItem:hitTypeView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:messageLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0f
                                                                  constant:-1.0f]];
            
            [rowView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[hitTypeView(==24)]"
                                                                            options:0 metrics:nil
                                                                              views:@{@"hitTypeView": hitTypeView}]];
            
            [rowView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[hitTypeView(==24)]"
                                                                            options:0 metrics:nil
                                                                              views:@{@"hitTypeView": hitTypeView}]];
            
            
            
            [deleteButton setBackgroundImage:[UIImage imageWithContentsOfFile:[self.bundle pathForResource:@"trash48" ofType:@"png"]] forState:UIControlStateNormal];
            deleteButton.tag = i;
            [deleteButton addTarget:self action:@selector(deleteOfflineHit:) forControlEvents:UIControlEventTouchUpInside];
            
            [rowView addConstraint: [NSLayoutConstraint constraintWithItem:deleteButton
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:hitTypeView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1.0f
                                                                  constant:10.0f]];
            
            [rowView addConstraint: [NSLayoutConstraint constraintWithItem:deleteButton
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:rowView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0f
                                                                  constant:-1.0f]];
            
            [rowView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[deleteButton(==24)]"
                                                                            options:0 metrics:nil
                                                                              views:@{@"deleteButton": deleteButton}]];
            
            [rowView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[deleteButton(==24)]"
                                                                            options:0 metrics:nil
                                                                              views:@{@"deleteButton": deleteButton}]];
            
            [rowView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[deleteButton]-5-|"
                                                                            options:0 metrics:nil
                                                                              views:@{@"deleteButton": deleteButton}]];
            
            
            
            previousRow = rowView;
            
            i++;
        }
    }
}

- (void)deleteOfflineHit:(UIButton *)sender {
    [self.storage delete:((ATHit *)self.hits[sender.tag]).url];
    [self getOfflineHitsList:(ATDebuggerWindow *)self.windows[[self.windows count] - 1]];
}

- (void)trashOfflineHits {
    [self.storage deleteAll];
    [self getOfflineHitsList:(ATDebuggerWindow *)self.windows[[self.windows count] - 1]];
}

- (void)offlineHitRowSelected:(UIPanGestureRecognizer *)recogniser {
    ((ATDebuggerWindow *)self.windows[1]).content.hidden = YES;
    
    if(recogniser.view) {
        UIView* window = [self createEventDetailView:((ATHit *)self.hits[recogniser.view.tag]).url];
        
        [self hidePreviousWindowMenuButtons:window];
    }
}

#pragma mark - Window Management

- (ATDebuggerWindow *) createWindow:(NSString *)windowTitle {
    UIView *window = [[UIView alloc] init];
    
    if([self.windows count] == 0) {
        window.backgroundColor = [UIColor whiteColor];
        window.layer.shadowOffset = CGSizeMake(1, 1);
        window.layer.shadowRadius = 4.0f;
        window.layer.shadowColor = [UIColor blackColor].CGColor;
        window.layer.shadowOpacity = 0.2f;
    } else {
        window.backgroundColor = [UIColor clearColor];
    }
    
    window.frame = CGRectMake(self.viewController.view.frame.size.width - 47, self.viewController.view.frame.size.height - 138, 0, 0);
    window.layer.borderColor = [UIColor colorWithRed:211/255.0f green:211/255.0f blue:211/255.0f alpha:1.0f].CGColor;
    window.layer.borderWidth = 1.0f;
    window.layer.cornerRadius = 4.0f;
    
    [window setTranslatesAutoresizingMaskIntoConstraints:NO];
    window.hidden = YES;
    
    [self.viewController.view addSubview:window];
    
    if([self.windows count] == 0) {
        [self.viewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[window]-10-|"
                                                                                         options:0 metrics:nil
                                                                                           views:@{@"window": window}]];
        
        [self.viewController.view addConstraint: [NSLayoutConstraint constraintWithItem:window
                                                                              attribute:NSLayoutAttributeTop
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self.viewController.topLayoutGuide
                                                                              attribute:NSLayoutAttributeBottom
                                                                             multiplier:1.0f
                                                                               constant:10.0f]];
        
        [self.viewController.view addConstraint: [NSLayoutConstraint constraintWithItem:self.debugButton
                                                                              attribute:NSLayoutAttributeTop
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:window
                                                                              attribute:NSLayoutAttributeBottom
                                                                             multiplier:1.0f
                                                                               constant:10.0f]];
    } else {
        [self.viewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[window]-10-|"
                                                                                         options:0 metrics:nil
                                                                                           views:@{@"window": window}]];
        
        [self.viewController.view addConstraint: [NSLayoutConstraint constraintWithItem:window
                                                                              attribute:NSLayoutAttributeTop
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self.viewController.topLayoutGuide
                                                                              attribute:NSLayoutAttributeBottom
                                                                             multiplier:1.0f
                                                                               constant:10.0f]];
        
        [self.viewController.view addConstraint: [NSLayoutConstraint constraintWithItem:window
                                                                              attribute:NSLayoutAttributeWidth
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:((ATDebuggerWindow *)self.windows[0]).window
                                                                              attribute:NSLayoutAttributeWidth
                                                                             multiplier:1.0f
                                                                               constant:0.0f]];
        
        [self.viewController.view addConstraint: [NSLayoutConstraint constraintWithItem:window
                                                                              attribute:NSLayoutAttributeHeight
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:((ATDebuggerWindow *)self.windows[0]).window
                                                                              attribute:NSLayoutAttributeHeight
                                                                             multiplier:1.0f
                                                                               constant:0.0f]];
    }
    
    ATDebuggerTopBar* menu = [[ATDebuggerTopBar alloc] init];
    menu.alpha = 0.0f;
    [menu setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    if([self.windows count] == 0) {
        menu.backgroundColor = [UIColor colorWithRed:7/255.0f green:39/255.0f blue:80/255.0f alpha:1.0f];
    } else {
        menu.backgroundColor = [UIColor clearColor];
    }
    
    [window addSubview:menu];
    
    [window addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[menu]-0-|"
                                                                   options:0 metrics:nil
                                                                     views:@{@"menu": menu}]];
    
    [window addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[menu]"
                                                                   options:0 metrics:nil
                                                                     views:@{@"menu": menu}]];
    
    [window addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[menu(==60)]"
                                                                   options:0 metrics:nil
                                                                     views:@{@"menu": menu}]];
    
    UIView* content = [[UIView alloc] init];
    content.frame = window.frame;
    content.backgroundColor = [UIColor whiteColor];
    content.alpha = 0.0f;
    [content setTranslatesAutoresizingMaskIntoConstraints:NO];
    [window addSubview:content];
    
    [window addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[content]-0-|"
                                                                   options:0 metrics:nil
                                                                     views:@{@"content": content}]];
    
    [window addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[content]-3-|"
                                                                   options:0 metrics:nil
                                                                     views:@{@"content": content}]];
    
    
    [window addConstraint: [NSLayoutConstraint constraintWithItem:content
                                                        attribute:NSLayoutAttributeTop
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:menu
                                                        attribute:NSLayoutAttributeBottom
                                                       multiplier:1.0f
                                                         constant:0.0f]];
    
    ATDebuggerWindow* debugWindow = [[ATDebuggerWindow alloc] init];
    debugWindow.window = window;
    debugWindow.menu = menu;
    debugWindow.content = content;
    debugWindow.windowTitle = windowTitle;
    
    [self.windows addObject:debugWindow];
    
    return debugWindow;
}

- (void)hidePreviousWindowMenuButtons:(UIView *)window {
    [UIView animateWithDuration:0.2
                          delay: 0.0
                        options: UIViewAnimationOptionCurveLinear
                     animations:^{
                         for(UIView* view in ((ATDebuggerWindow *)self.windows[[self.windows count] - 2]).menu.subviews) {
                             if([view isKindOfClass:[UIButton class]]) {
                                 view.hidden = YES;
                             }
                         }
                         
                         window.alpha = 1.0f;
                     }
                     completion:nil];
    
}

- (void)backButtonWasTouched:(UIButton *)sender {
    for(UIView* view in ((ATDebuggerWindow *)self.windows[sender.tag - 1]).menu.subviews) {
        if([view isKindOfClass:[UIButton class]]) {
            view.hidden = NO;
        }
    }
    
    self.windowTitleLabel.text = ((ATDebuggerWindow *)self.windows[sender.tag - 1]).windowTitle;
    ((ATDebuggerWindow *)self.windows[sender.tag - 1]).content.hidden = NO;
    
    [((ATDebuggerWindow *)self.windows[sender.tag]).window removeFromSuperview];
    [self.windows removeObjectAtIndex:sender.tag];
}

@end
