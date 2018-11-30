/*
 * Endless
 * Copyright (c) 2014-2015 joshua stein <jcs@jcs.org>
 *
 * See LICENSE file for redistribution terms.
 */

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "MBCookieJar.h"
#import "MBHSTSCache.h"
#import "MBWebViewController.h"

#define STATE_RESTORE_TRY_KEY @"state_restore_lock"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, atomic) MBWebViewController *webViewController;
@property (strong, atomic) MBCookieJar *cookieJar;
@property (strong, atomic) MBHSTSCache *hstsCache;

@property (readonly, strong, nonatomic) NSMutableDictionary *searchEngines;

@property (strong, atomic) NSString *defaultUserAgent;

- (BOOL)areTesting;

@end

