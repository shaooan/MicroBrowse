/*
 * Endless
 * Copyright (c) 2014-2015 joshua stein <jcs@jcs.org>
 *
 * See LICENSE file for redistribution terms.
 */

#import <UIKit/UIKit.h>
#import "IASKAppSettingsViewController.h"
#import "MBWebViewTab.h"
#import "WYPopoverController.h"

@interface MBWebViewController : UIViewController <UITableViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, IASKSettingsDelegate, WYPopoverControllerDelegate>

@property BOOL toolbarOnBottom;
@property BOOL darkInterface;

- (NSMutableArray *)webViewTabs;
- (__strong MBWebViewTab *)curWebViewTab;

- (id)settingsButton;

- (void)viewIsVisible;

- (MBWebViewTab *)addNewTabForURL:(NSURL *)url;
- (void)removeTab:(NSNumber *)tabNumber andFocusTab:(NSNumber *)toFocus;
- (void)removeTab:(NSNumber *)tabNumber;
- (void)removeAllTabs;

- (void)webViewTouched;
- (void)updateProgress;
- (void)updateSearchBarDetails;
- (void)refresh;
- (void)forceRefresh;
- (void)dismissPopover;
- (void)prepareForNewURLFromString:(NSString *)url;

@end
