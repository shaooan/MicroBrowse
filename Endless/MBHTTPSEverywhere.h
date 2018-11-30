/*
 * Endless
 * Copyright (c) 2014-2015 joshua stein <jcs@jcs.org>
 *
 * See LICENSE file for redistribution terms.
 */

#import <Foundation/Foundation.h>
#import "MBHTTPSEverywhereRule.h"

@interface MBHTTPSEverywhere : NSObject

+ (NSDictionary *)rules;
+ (NSDictionary *)targets;
+ (NSMutableDictionary *)disabledRules;
+ (void)saveDisabledRules;

+ (MBHTTPSEverywhereRule *)cachedRuleForName:(NSString *)name;
+ (NSArray *)potentiallyApplicableRulesForHost:(NSString *)host;
+ (NSURL *)rewrittenURI:(NSURL *)URL withRules:(NSArray *)rules;
+ (BOOL)needsSecureCookieFromHost:(NSString *)fromHost forHost:(NSString *)forHost cookieName:(NSString *)cookie;
+ (void)noteInsecureRedirectionForURL:(NSURL *)URL;
+ (BOOL)ruleNameIsDisabled:(NSString *)name;
+ (void)enableRuleByName:(NSString *)name;
+ (void)disableRuleByName:(NSString *)name withReason:(NSString *)reason;

@end
