/**
 @file          BNCApplication.m
 @package       Branch-SDK
 @brief         Current application and extension info.

 @author        Edward Smith
 @date          January 8, 2018
 @copyright     Copyright © 2018 Branch. All rights reserved.
*/

#import "BNCApplication.h"
#import "BNCLog.h"
#import "BNCKeyChain.h"

static NSString*const kBranchKeychainService          = @"BranchKeychainService";
static NSString*const kBranchKeychainDevicesKey       = @"BranchKeychainDevices";
static NSString*const kBranchKeychainFirstBuildKey    = @"BranchKeychainFirstBuild";
static NSString*const kBranchKeychainFirstInstalldKey = @"BranchKeychainFirstInstall";

#pragma mark - BNCApplication

@implementation BNCApplication

// BNCApplication checks a few values in keychain
// Checking keychain from main thread early in the app lifecycle can deadlock.  INTENG-7291
+ (void)loadCurrentApplicationWithCompletion:(void (^)(BNCApplication *application))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BNCApplication *tmp = [BNCApplication currentApplication];
        if (completion) {
            completion(tmp);
        }
    });
}

+ (BNCApplication*) currentApplication {
    static BNCApplication *bnc_currentApplication = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        bnc_currentApplication = [BNCApplication createCurrentApplication];
    });
    return bnc_currentApplication;
}

+ (BNCApplication*) createCurrentApplication {
    BNCApplication *application = [[BNCApplication alloc] init];
    if (!application) return application;
    NSDictionary *info = [NSBundle mainBundle].infoDictionary;

    application->_bundleID = [NSBundle mainBundle].bundleIdentifier;
    application->_displayName = info[@"CFBundleDisplayName"];
    application->_shortDisplayName = info[@"CFBundleName"];

    application->_displayVersionString = info[@"CFBundleShortVersionString"];
    application->_versionString = info[@"CFBundleVersion"];

    application->_firstInstallBuildDate = [BNCApplication firstInstallBuildDate];
    application->_currentBuildDate = [BNCApplication currentBuildDate];

    application->_firstInstallDate = [BNCApplication firstInstallDate];
    application->_currentInstallDate = [BNCApplication currentInstallDate];

    NSString*group =  [BNCKeyChain securityAccessGroup];
    if (group) {
        NSRange range = [group rangeOfString:@"."];
        if (range.location != NSNotFound) {
            application->_teamID = [[group substringToIndex:range.location] copy];
        }
    }

    return application;
}

+ (NSDate*) currentBuildDate {
    NSURL *appURL = nil;
    NSURL *bundleURL = [NSBundle mainBundle].bundleURL;
    NSDictionary *info = [NSBundle mainBundle].infoDictionary;
    NSString *appName = info[(__bridge NSString*)kCFBundleExecutableKey];
    if (appName.length > 0 && bundleURL) {
        appURL = [bundleURL URLByAppendingPathComponent:appName];
    } else {
        NSString *path = [[NSProcessInfo processInfo].arguments firstObject];
        if (path) appURL = [NSURL fileURLWithPath:path];
    }
    if (appURL == nil)
        return nil;

    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *attributes = [fileManager attributesOfItemAtPath:appURL.path error:&error];
    if (error) {
        BNCLogError(@"Can't get build date: %@.", error);
        return nil;
    }
    NSDate * buildDate = [attributes fileCreationDate];
    if (buildDate == nil || [buildDate timeIntervalSince1970] <= 0.0) {
        BNCLogError(@"Invalid build date: %@.", buildDate);
    }
    return buildDate;
}

+ (NSDate*) firstInstallBuildDate {
    NSError *error = nil;
    NSDate *firstBuildDate =
        [BNCKeyChain retrieveValueForService:kBranchKeychainService
            key:kBranchKeychainFirstBuildKey
            error:&error];
    if (firstBuildDate)
        return firstBuildDate;

    firstBuildDate = [self currentBuildDate];
    error = [BNCKeyChain storeValue:firstBuildDate
        forService:kBranchKeychainService
        key:kBranchKeychainFirstBuildKey
        cloudAccessGroup:nil];
    if (error) BNCLogError(@"Keychain store: %@.", error);
    return firstBuildDate;
}

+ (NSDate *) currentInstallDate {
    NSDate *installDate = [NSDate date];
    
    #if !TARGET_OS_TV
    // tvOS always returns a creation date of Unix epoch 0 on device
    installDate = [self creationDateForLibraryDirectory];
    #endif
    
    if (installDate == nil || [installDate timeIntervalSince1970] <= 0.0) {
        BNCLogWarning(@"Invalid install date, using [NSDate date].");
    }
    return installDate;
}

+ (NSDate *)creationDateForLibraryDirectory {
    NSError *error = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *directoryURL = [[fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] firstObject];
    NSDictionary *attributes = [fileManager attributesOfItemAtPath:directoryURL.path error:&error];
    if (error) {
        BNCLogError(@"Can't get creation date for Library directory: %@", error);
       return nil;
    }
    return [attributes fileCreationDate];
}

+ (NSDate*) firstInstallDate {
    // check keychain for stored install date, on iOS this is lost on app deletion.
    NSError *error = nil;
    NSDate* firstInstallDate = [BNCKeyChain retrieveValueForService:kBranchKeychainService key:kBranchKeychainFirstInstalldKey error:&error];
    if (firstInstallDate) {
        return firstInstallDate;
    }
    
    // check filesytem for creation date
    firstInstallDate = [self currentInstallDate];
    
    // save filesystem time to keychain
    error = [BNCKeyChain storeValue:firstInstallDate forService:kBranchKeychainService key:kBranchKeychainFirstInstalldKey cloudAccessGroup:nil];
    if (error) {
        BNCLogError(@"Keychain store: %@.", error);
    }
    return firstInstallDate;
}

- (NSDictionary*) deviceKeyIdentityValueDictionary {
    @synchronized (self.class) {
        NSError *error = nil;
        NSDictionary *deviceDictionary =
            [BNCKeyChain retrieveValueForService:kBranchKeychainService
                key:kBranchKeychainDevicesKey
                error:&error];
        if (error) BNCLogWarning(@"While retrieving deviceKeyIdentityValueDictionary: %@.", error);
        if (!deviceDictionary) deviceDictionary = @{};
        return deviceDictionary;
    }
}

@end

@implementation BNCApplication (BNCTest)

- (void) setAppOriginalInstallDate:(NSDate*)originalInstallDate
        firstInstallDate:(NSDate*)firstInstallDate
        lastUpdateDate:(NSDate*)lastUpdateDate {
    self->_currentInstallDate = firstInstallDate;        // latest_install_time
    self->_firstInstallDate = originalInstallDate;       // first_install_time
    self->_currentBuildDate = lastUpdateDate;            // lastest_update_time
}

@end

