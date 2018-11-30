/*
 * Endless
 * Copyright (c) 2014-2015 joshua stein <jcs@jcs.org>
 *
 * See LICENSE file for redistribution terms.
 */

#import "MBHTTPSEverywhereRuleController.h"
#import "MBHTTPSEverywhere.h"
#import "MBHTTPSEverywhereRule.h"

@implementation MBHTTPSEverywhereRuleController

- (id)initWithStyle:(UITableViewStyle)style
{
	self = [super initWithStyle:style];
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self.navigationController action:@selector(dismissModalViewControllerAnimated:)];

	self.sortedRuleNames = [[NSMutableArray alloc] initWithCapacity:[[MBHTTPSEverywhere rules] count]];
	
	if ([[self.appDelegate webViewController] curWebViewTab] != nil) {
		self.inUseRuleNames = [[NSMutableArray alloc] initWithArray:[[[[[self.appDelegate webViewController] curWebViewTab] applicableHTTPSEverywhereRules] allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
	}
	else {
		self.inUseRuleNames = [[NSMutableArray alloc] init];
	}
	
	for (NSString *k in [[MBHTTPSEverywhere rules] allKeys]) {
		if (![self.inUseRuleNames containsObject:k])
			[self.sortedRuleNames addObject:k];
	}
	
	self.sortedRuleNames = [NSMutableArray arrayWithArray:[self.sortedRuleNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
	self.searchResult = [NSMutableArray arrayWithCapacity:[self.sortedRuleNames count]];
	
	self.title = @"HTTPS Everywhere Rules";
	
	return self;
}

- (NSString *)ruleDisabledReason:(NSString *)rule
{
	return [[MBHTTPSEverywhere disabledRules] objectForKey:rule];
}

- (void)disableRuleByName:(NSString *)rule withReason:(NSString *)reason
{
	[MBHTTPSEverywhere disableRuleByName:rule withReason:reason];
}

- (void)enableRuleByName:(NSString *)rule
{
	[MBHTTPSEverywhere enableRuleByName:rule];
}

@end
