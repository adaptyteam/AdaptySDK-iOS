//
//  BNCAppleReceipt.m
//  Branch
//
//  Created by Ernest Cho on 7/11/19.
//  Copyright © 2019 Branch, Inc. All rights reserved.
//

#import "BNCAppleReceipt.h"

@interface BNCAppleReceipt()

/*
 Simulator - no receipt, isSandbox = NO
 Testflight or developer side load - no receipt, isSandbox = YES
 App Store installed - receipt, isSandbox = NO
 */
@property (nonatomic, copy, readwrite) NSString *receipt;
@property (nonatomic, assign, readwrite) BOOL isSandboxReceipt;

@end

@implementation BNCAppleReceipt

+ (BNCAppleReceipt *)sharedInstance {
    static BNCAppleReceipt *singleton;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [BNCAppleReceipt new];
    });
    return singleton;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.receipt = nil;
        self.isSandboxReceipt = NO;
        
        [self readReceipt];
    }
    return self;
}

- (void)readReceipt {
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    if (receiptURL) {
        self.isSandboxReceipt = [receiptURL.lastPathComponent isEqualToString:@"sandboxReceipt"];
        
        NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
        if (receiptData) {
            self.receipt = [receiptData base64EncodedStringWithOptions:0];
        }
    }
}

- (nullable NSString *)installReceipt {
    return self.receipt;
}

- (BOOL)isTestFlight {
    // sandbox receipts are from testflight or side loaded development devices
    return self.isSandboxReceipt;
}

@end
