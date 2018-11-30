/*
 * Endless
 * Copyright (c) 2015 joshua stein <jcs@jcs.org>
 *
 * See LICENSE file for redistribution terms.
 */

#import "AppDelegate.h"
#import "MBHostSettings.h"

@implementation MBHostSettings

NSMutableDictionary *_hosts;

+ (NSDictionary *)defaults
{
	return @{
	       HOST_SETTINGS_KEY_TLS: HOST_SETTINGS_TLS_AUTO,
	       HOST_SETTINGS_KEY_CSP: HOST_SETTINGS_CSP_OPEN,
	       HOST_SETTINGS_KEY_BLOCK_LOCAL_NETS: HOST_SETTINGS_VALUE_YES,
	       HOST_SETTINGS_KEY_ALLOW_MIXED_MODE: HOST_SETTINGS_VALUE_NO,
	       HOST_SETTINGS_KEY_WHITELIST_COOKIES: HOST_SETTINGS_VALUE_NO,
	};
}

+ (NSString *)hostSettingsPath
{
	NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	return [path stringByAppendingPathComponent:@"host_settings.plist"];
}

+ (NSMutableDictionary *)hosts
{
	if (!_hosts) {
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if ([fileManager fileExistsAtPath:[self hostSettingsPath]]) {
			NSDictionary *td = [NSMutableDictionary dictionaryWithContentsOfFile:[self hostSettingsPath]];
			
			_hosts = [[NSMutableDictionary alloc] initWithCapacity:[td count]];
			
			for (NSString *k in [td allKeys])
				[_hosts setObject:[[MBHostSettings alloc] initForHost:k withDict:[td objectForKey:k]] forKey:k];
		}
		else
			_hosts = [[NSMutableDictionary alloc] initWithCapacity:20];
		
		/* ensure default host exists */
		if (![_hosts objectForKey:HOST_SETTINGS_DEFAULT]) {
			MBHostSettings *hs = [[MBHostSettings alloc] initForHost:HOST_SETTINGS_DEFAULT withDict:nil];
			[hs save];
			[MBHostSettings persist];
		}
	}
	
	return _hosts;
}

+ (void)persist
{
	if ([(AppDelegate *)[[UIApplication sharedApplication] delegate] areTesting])
		abort();
		
	NSMutableDictionary *td = [[NSMutableDictionary alloc] initWithCapacity:[[self hosts] count]];
	for (NSString *k in [[self hosts] allKeys])
		[td setObject:[[[self hosts] objectForKey:k] dict] forKey:k];

	[td writeToFile:[self hostSettingsPath] atomically:YES];
}

+ (MBHostSettings *)forHost:(NSString *)host
{
	return [[self hosts] objectForKey:host];
}

+ (MBHostSettings *)settingsOrDefaultsForHost:(NSString *)host
{
	MBHostSettings *hs = [self forHost:host];
	if (!hs) {
		/* for a host of x.y.z.example.com, try y.z.example.com, z.example.com, example.com, etc. */
		NSArray *hostp = [host componentsSeparatedByString:@"."];
		for (int i = 1; i < [hostp count]; i++) {
			NSString *wc = [[hostp subarrayWithRange:NSMakeRange(i, [hostp count] - i)] componentsJoinedByString:@"."];
			
			if ((hs = [MBHostSettings forHost:wc])) {
#ifdef TRACE_HOST_SETTINGS
				NSLog(@"[HostSettings] found entry for component %@ in %@", wc, host);
#endif
				break;
			}
		}
	}
	
	if (!hs) {
#ifdef TRACE_HOST_SETTINGS
		NSLog(@"[HostSettings] using default settings for %@", host);
#endif
		hs = [self defaultHostSettings];
	}

	return hs;
}

+ (BOOL)removeSettingsForHost:(NSString *)host
{
	MBHostSettings *h = [self forHost:host];
	if (h && ![h isDefault]) {
		[[self hosts] removeObjectForKey:host];
		return YES;
	}
	
	return NO;
}

+ (MBHostSettings *)defaultHostSettings
{
	return [self forHost:HOST_SETTINGS_DEFAULT];
}

#ifdef DEBUG
/* just for testing */
+ (void)overrideHosts:(NSMutableDictionary *)hosts
{
	_hosts = hosts;
}
#endif

+ (NSArray *)sortedHosts
{
	NSMutableArray *sorted = [[NSMutableArray alloc] initWithArray:[[self hosts] allKeys]];
	[sorted removeObject:HOST_SETTINGS_DEFAULT];
	[sorted sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	[sorted insertObject:HOST_SETTINGS_DEFAULT atIndex:0];
	
	return [[NSArray alloc] initWithArray:sorted];
}

- (MBHostSettings *)initForHost:(NSString *)host withDict:(NSDictionary *)dict
{
	self = [super init];
	
	host = [host lowercaseString];

	if (dict)
		_dict = [[NSMutableDictionary alloc] initWithDictionary:dict];
	else
		_dict = [[NSMutableDictionary alloc] initWithCapacity:10];
	
	[_dict setObject:host forKey:HOST_SETTINGS_KEY_HOST];

	return self;
}

- (void)save
{
	[[MBHostSettings hosts] setObject:self forKey:[[self dict] objectForKey:HOST_SETTINGS_KEY_HOST]];
}

- (BOOL)isDefault
{
	return ([[[self dict] objectForKey:HOST_SETTINGS_KEY_HOST] isEqualToString:HOST_SETTINGS_DEFAULT]);
}

- (NSString *)setting:(NSString *)setting
{
	NSString *val = [[self dict] objectForKey:setting];
	if (val != NULL && ![val isKindOfClass:[NSString class]]) {
		NSLog(@"[HostSettings] setting %@ for %@ was %@, not NSString", setting, [self hostname], [val class]);
		val = nil;
	}

	if (val != nil && ![val isEqualToString:@""] && ![val isEqualToString:HOST_SETTINGS_DEFAULT])
		return val;

	if (val == nil && [self isDefault])
		/* default host entries must have a value for every setting */
		return [[MBHostSettings defaults] objectForKey:setting];

	return nil;
}

- (NSString *)settingOrDefault:(NSString *)setting
{
	NSString *val = [self setting:setting];
	if (val == nil)
		/* try default host settings */
		val = [[MBHostSettings defaultHostSettings] setting:setting];
	
	return val;
}

- (BOOL)boolSettingOrDefault:(NSString *)setting
{
	NSString *val = [self settingOrDefault:setting];
	if (val != nil && [val isEqualToString:HOST_SETTINGS_VALUE_YES])
		return YES;
	else
		return NO;
}

- (void)setSetting:(NSString *)setting toValue:(NSString *)value
{
	if (value == nil || [value isEqualToString:HOST_SETTINGS_DEFAULT]) {
		[[self dict] removeObjectForKey:setting];
		return;
	}
	
	if ([setting isEqualToString:HOST_SETTINGS_KEY_TLS]) {
		if (!([value isEqualToString:HOST_SETTINGS_TLS_12] || [value isEqualToString:HOST_SETTINGS_TLS_AUTO]))
			return;
	}
	
	[[self dict] setObject:value forKey:setting];
}

- (NSString *)hostname
{
	if ([self isDefault])
		return HOST_SETTINGS_HOST_DEFAULT_LABEL;
	else
		return [[self dict] objectForKey:HOST_SETTINGS_KEY_HOST];
}

- (void)setHostname:(NSString *)hostname
{
	if ([self isDefault] || !hostname || [hostname isEqualToString:@""])
		return;
	
	hostname = [hostname lowercaseString];
	
	[[MBHostSettings hosts] removeObjectForKey:[[self dict] objectForKey:HOST_SETTINGS_KEY_HOST]];
	[[self dict] setObject:hostname forKey:HOST_SETTINGS_KEY_HOST];
	[[MBHostSettings hosts] setObject:self forKey:hostname];
}

@end
