/*
 * Endless
 * Copyright (c) 2015 joshua stein <jcs@jcs.org>
 *
 * See LICENSE file for redistribution terms.
 */

#import <UIKit/UIKit.h>

#import "OrderedDictionary.h"
#import "MBSSLCertificate.h"

@interface MBSSLCertificateViewController : UITableViewController <UITableViewDelegate> {
	MutableOrderedDictionary *certInfo;
}

@property (strong) MBSSLCertificate *certificate;

- (id)initWithSSLCertificate:(MBSSLCertificate *)cert;

@end
