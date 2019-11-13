#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AWSAbstractKinesisRecorder.h"
#import "AWSFirehose.h"
#import "AWSFirehoseModel.h"
#import "AWSFirehoseRecorder.h"
#import "AWSFirehoseResources.h"
#import "AWSFirehoseService.h"
#import "AWSKinesis.h"
#import "AWSKinesisModel.h"
#import "AWSKinesisRecorder.h"
#import "AWSKinesisRequestRetryHandler.h"
#import "AWSKinesisResources.h"
#import "AWSKinesisService.h"

FOUNDATION_EXPORT double AWSKinesisVersionNumber;
FOUNDATION_EXPORT const unsigned char AWSKinesisVersionString[];

