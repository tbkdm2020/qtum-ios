//
//  EnableFingerprintOutputDelegate.h
//  qtum wallet
//
//  Created by Vladimir Lebedevich on 10.07.17.
//  Copyright © 2017 QTUM. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EnableFingerprintOutputDelegate <NSObject>

- (void)didEnableFingerprint:(BOOL) enabled;

- (void)didCancelEnableFingerprint;

@end
