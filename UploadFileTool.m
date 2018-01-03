//
//  HomeSchoolTeacher
//
//  Created by zhudou on 2017/12/8.
//  Copyright © 2017年 song. All rights reserved.
//

#import "UploadFileTool.h"
#import "QiniuUploadHelper.h"

@implementation UploadFileTool

#pragma mark - Helpers
//给文件命名

+ (NSString*)getDateTimeString
{

    NSDateFormatter* formatter;
    NSString* dateString;

    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddhhmmss"];

    dateString = [formatter stringFromDate:[NSDate date]];

    return dateString;
}

+ (NSString*)randomStringWithLength:(int)len
{

    NSString* letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

    NSMutableString* randomString = [NSMutableString stringWithCapacity:len];

    for (int i = 0; i < len; i++) {

        [randomString appendFormat:@"%C", [letters characterAtIndex:arc4random_uniform((int)[letters length])]];
    }

    return randomString;
}

//上传单张图片
+ (void)uploadFileData:(NSData*)data fileType:(UploadFileToolType)fileType progress:(QNUpProgressHandler)progress success:(void (^)(NSString*))success failure:(void (^)())failure
{
    if (!data) {
        if (success) {
            success(nil);
        }
        return;
    }
    [UploadFileTool getQiniuUploadToken:^(NSString* token, NSString* prefix) {
        if (!data) {
            if (failure) {
                failure();
            }
            return;
        }
        NSString* fileName = [NSString stringWithFormat:@"%@%@_%@.%@", prefix, [UploadFileTool getDateTimeString], [UploadFileTool randomStringWithLength:8], (fileType == UploadFileToolTypeImage ? @"png" : @"amr")];
        QNUploadOption* opt = [[QNUploadOption alloc] initWithMime:nil
                                                   progressHandler:progress
                                                            params:nil
                                                          checkCrc:NO
                                                cancellationSignal:nil];
        QNUploadManager* uploadManager = [QNUploadManager sharedInstanceWithConfiguration:nil];
        [uploadManager putData:data
                           key:fileName
                         token:token
                      complete:^(QNResponseInfo* info, NSString* key, NSDictionary* resp) {

                          if (info.statusCode == 200 && resp) {
                              NSString* url = [NSString stringWithFormat:@"%@", resp[@"key"]];
                              if (success) {
                                  success(url);
                              }
                          } else {
                              if (failure) {
                                  failure();
                              }
                          }

                      }
                        option:opt];
    }
                                failure:^{

                                }];
}

//上传多张图片
+ (void)uploadFiles:(NSArray<NSData*>*)filesArray fileType:(UploadFileToolType)fileType progress:(void (^)(CGFloat))progress success:(void (^)(NSArray*))success failure:(void (^)())failure
{

    if (filesArray.count == 0) {
        if (success) {
            success(nil);
        }
        return;
    }
    NSMutableArray* array = [[NSMutableArray alloc] init];

    __block CGFloat totalProgress = 0.0f;
    __block CGFloat partProgress = 1.0f / [filesArray count];
    __block NSUInteger currentIndex = 0;

    QiniuUploadHelper* uploadHelper = [QiniuUploadHelper sharedUploadHelper];
    __weak typeof(uploadHelper) weakHelper = uploadHelper;

    uploadHelper.singleFailureBlock = ^() {
        failure();
        return;
    };
    uploadHelper.singleSuccessBlock = ^(NSString* url) {
        [array addObject:url];
        totalProgress += partProgress;
        if (progress) {
            progress(totalProgress);
        }
        currentIndex++;
        if ([array count] == [filesArray count]) {
            success([array copy]);
            return;
        } else {
            NSLog(@"---%ld", (unsigned long)currentIndex);

            if (currentIndex < filesArray.count) {

                [UploadFileTool uploadFileData:filesArray[currentIndex] fileType:fileType progress:nil success:weakHelper.singleSuccessBlock failure:weakHelper.singleFailureBlock];
            }
        }
    };

    [UploadFileTool uploadFileData:filesArray[0] fileType:fileType progress:nil success:weakHelper.singleSuccessBlock failure:weakHelper.singleFailureBlock];
}

//获取七牛的token
+ (void)getQiniuUploadToken:(void (^)(NSString* uptoken, NSString* prefix))success failure:(void (^)())failure
{
    //此处获取七牛上传token及上传目录，服务器返回
    [BPRequest requestWithUrl:@"qnToken"
        arguments:nil
        jsonValidator:nil
        success:^(id json) {
            if (json && json[@"uptoken"] && json[@"prefix"]) {
                if (success) {
                    success(json[@"uptoken"], json[@"prefix"]);
                }
            } else {
                if (failure) {
                    failure();
                }
            }
        }
        failure:^(NSError* error) {

            if (failure) {
                failure();
            }
        }];
}


@end
