//
//  HomeSchoolTeacher
//
//  Created by zhudou on 2017/12/8.
//  Copyright © 2017年 song. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QiniuUploadHelper : NSObject


@property (copy, nonatomic) void (^singleSuccessBlock)(NSString *);
@property (copy, nonatomic)  void (^singleFailureBlock)();

+ (instancetype)sharedUploadHelper;
@end
