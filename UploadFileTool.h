//
//  HomeSchoolTeacher
//
//  Created by zhudou on 2017/12/8.
//  Copyright © 2017年 song. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Qiniu/QiniuSDK.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, UploadFileToolType) {
    UploadFileToolTypeImage = 0,
    UploadFileToolTypeAmr
};

@interface UploadFileTool : NSObject
/**
 上传单个文件

 @param image 图片
 @param progress 进度
 @param success 成功
 @param failure 失败
 */
+ (void)uploadFileData:(NSData*)data fileType:(UploadFileToolType)fileType progress:(QNUpProgressHandler)progress success:(void (^)(NSString* url))success failure:(void (^)())failure;

// 上传多个文件,按队列依次上传
+ (void)uploadFiles:(NSArray<NSData*>*)filesArray fileType:(UploadFileToolType)fileType progress:(void (^)(CGFloat))progress success:(void (^)(NSArray*))success failure:(void (^)())failure;
@end
