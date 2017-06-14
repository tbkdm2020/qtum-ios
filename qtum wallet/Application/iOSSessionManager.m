//
//  iOSSessionManager.m
//  qtum wallet
//
//  Created by Sharaev Vladimir on 06.06.17.
//  Copyright © 2017 PixelPlex. All rights reserved.
//

#import "iOSSessionManager.h"
#import <WatchConnectivity/WatchConnectivity.h>
#import "QRCodeManager.h"

NSString *MainMessageKey = @"message_key";
NSString *GetQRCodeMessageKey = @"get_qr_code";
NSString *GetWalletInformation = @"get_wallet_information";
NSString *StatusKey = @"status";

@interface iOSSessionManager() <WCSessionDelegate>

@property (nonatomic) WCSessionActivationState currentState;

@end

@implementation iOSSessionManager

+ (instancetype)sharedInstance
{
    static iOSSessionManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[super alloc] initUniqueInstance];
    });
    return manager;
}

- (instancetype)initUniqueInstance
{
    self = [super init];
    
    if (self != nil) {
        if ([WCSession isSupported]) {
            WCSession *session = [WCSession defaultSession];
            session.delegate = self;
            [session activateSession];
            NSLog(@"WCSession is supported");
        }else{
            NSLog(@"WCSession is NOT supported");
        }
    }
    
    return self;
}

- (void)sendMessage:(NSString *)message{
    if (self.currentState == WCSessionActivationStateActivated) {
        WCSession *session = [WCSession defaultSession];
        [session sendMessage:@{@"hello" : message} replyHandler:^(NSDictionary<NSString *,id> * _Nonnull replyMessage) {
            NSLog(@"WCSession activationDidCompleteWithState :  %@", replyMessage);
        } errorHandler:^(NSError * _Nonnull error) {
            NSLog(@"Error send message");
        }];
    }
}

#pragma mark - WCSessionDelegate

/** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
- (void)session:(WCSession *)session activationDidCompleteWithState:(WCSessionActivationState)activationState error:(nullable NSError *)error{
    self.currentState = activationState;
    NSLog(@"WCSession activationDidCompleteWithState :  %ld", (long)activationState);
}

/** ------------------------- iOS App State For Watch ------------------------ */

/** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
- (void)sessionDidBecomeInactive:(WCSession *)session{
    self.currentState = session.activationState;
    NSLog(@"sessionDidBecomeInactive");
}

/** Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession. */
- (void)sessionDidDeactivate:(WCSession *)session{
    self.currentState = session.activationState;
    NSLog(@"sessionDidDeactivate");
}

/** Called when any of the Watch state properties change. */
- (void)sessionWatchStateDidChange:(WCSession *)session{
    self.currentState = session.activationState;
    NSLog(@"sessionWatchStateDidChange : state = %ld", (long)session.activationState);
}

/** ------------------------- Interactive Messaging ------------------------- */

/** Called when the reachable state of the counterpart app changes. The receiver should check the reachable property on receiving this delegate callback. */
- (void)sessionReachabilityDidChange:(WCSession *)session{
    NSLog(@"sessionReachabilityDidChange");
}

/** Called on the delegate of the receiver. Will be called on startup if the incoming message caused the receiver to launch. */
- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message{
    NSLog(@"sessionReachabilityDidChange : message : %@", message);
}

/** Called on the delegate of the receiver when the sender sends a message that expects a reply. Will be called on startup if the incoming message caused the receiver to launch. */
- (void)session:(WCSession *)session didReceiveMessage:(NSDictionary<NSString *, id> *)message replyHandler:(void(^)(NSDictionary<NSString *, id> *replyMessage))replyHandler{
    NSLog(@"didReceiveMessage with reply : message : %@", message);
    
    NSString *key = message[MainMessageKey];
    if ([key isEqualToString:GetQRCodeMessageKey]) {
        CGFloat width = [message[@"width"] floatValue];
        NSString *address = [WalletManager sharedInstance].getCurrentWallet.mainAddress;
        
        [QRCodeManager createQRCodeFromString:address forSize:CGSizeMake(width, width) withCompletionBlock:^(UIImage *image) {
            NSDictionary *dictionary = @{@"data" : UIImagePNGRepresentation(image),
                                         @"key" : address};
            
            replyHandler(dictionary);
        }];
    } else if ([key isEqualToString:GetWalletInformation]) {
        
        [[WalletManager sharedInstance].getCurrentWallet updateBalanceWithHandler:^(BOOL success) {
            if (success) {
                [[WalletManager sharedInstance].getCurrentWallet updateHistoryWithHandler:^(BOOL success) {
                    if (success) {
                        Wallet *wallet = [WalletManager sharedInstance].getCurrentWallet;
                        NSString *address = wallet.mainAddress;
                        NSNumber *availableBalance = @(wallet.balance);
                        NSNumber *unconfirmedBalance = @(wallet.unconfirmedBalance);
                        NSArray *history = wallet.historyStorage.historyPrivate;
                        NSMutableArray *historyDictionary = [NSMutableArray new];
                        for (HistoryElement *element in history) {
                            [historyDictionary addObject:[element dictionaryFromElementForWatch]];
                        }
                        NSDictionary *dictionary = @{@"address" : address,
                                                     @"availableBalance" : availableBalance,
                                                     @"unconfirmedBalance" : unconfirmedBalance,
                                                     @"history" : historyDictionary};
                        
                        replyHandler(dictionary);
                    } else {
                        NSDictionary *dictionary = @{StatusKey : @(NO)};
                        replyHandler(dictionary);
                    }
                } andPage:0];
            }else {
                NSDictionary *dictionary = @{StatusKey : @(NO)};
                replyHandler(dictionary);
            }
        }];
    }
}

@end
