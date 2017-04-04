//
//  RequestManagerAdapter.h
//  qtum wallet
//
//  Created by Никита Федоренко on 21.03.17.
//  Copyright © 2017 Designsters. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RequestManagerAdapter <NSObject>

@required
- (id)adaptiveDataForHistory:(id) data;
- (id)adaptiveDataForOutputs:(id) data;
- (CGFloat)adaptiveDataForBalance:(CGFloat) balance;


@end