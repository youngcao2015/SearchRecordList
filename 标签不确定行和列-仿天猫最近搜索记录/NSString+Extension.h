//
//  NSString+Extension.h
//
//
//  Created by young on 14-3-7.
//  Copyright (c) 2014年 young. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#pragma mark - Extension
@interface NSString (Extension)

- (CGFloat)textWidth;

@end


#pragma mark - Regex
@interface NSString (Regex)

/***************** 正则表达式相关 ******************/

/** 邮箱验证 */
- (BOOL)isValidEmail;

/** 手机号码验证 */
- (BOOL)isValidPhoneNum;

/** 车牌号验证 */
- (BOOL)isValidCarNo;

/** 网址验证 */
- (BOOL)isValidUrl;

/** 邮政编码 */
- (BOOL)isValidPostalcode;

/** 纯汉字 */
- (BOOL)isValidChinese;

/** 是否包含汉字 */
- (BOOL)isContainChinese;

/**
 @brief     是否符合IP格式，xxx.xxx.xxx.xxx
 */
- (BOOL)isValidIP;

/** 身份证验证 refer to http://blog.csdn.net/afyzgh/article/details/16965107*/
- (BOOL)isValidIdCardNum;

/**
 @brief     是否符合最小长度、最长长度，是否包含中文,首字母是否可以为数字
 @param     minLenth 账号最小长度
 @param     maxLenth 账号最长长度
 @param     containChinese 是否包含中文
 @param     firstCannotBeDigtal 首字母不能为数字
 @return    正则验证成功返回YES, 否则返回NO
 */
- (BOOL)isValidWithMinLenth:(NSInteger)minLenth
                   maxLenth:(NSInteger)maxLenth
             containChinese:(BOOL)containChinese
        firstCannotBeDigtal:(BOOL)firstCannotBeDigtal;

/**
 @brief     是否符合最小长度、最长长度，是否包含中文,数字，字母，其他字符，首字母是否可以为数字
 @param     minLenth 账号最小长度
 @param     maxLenth 账号最长长度
 @param     containChinese 是否包含中文
 @param     containDigtal   包含数字
 @param     containLetter   包含字母
 @param     containOtherCharacter   其他字符
 @param     firstCannotBeDigtal 首字母不能为数字
 @return    正则验证成功返回YES, 否则返回NO
 */
- (BOOL)isValidWithMinLenth:(NSInteger)minLenth
                   maxLenth:(NSInteger)maxLenth
             containChinese:(BOOL)containChinese
              containDigtal:(BOOL)containDigtal
              containLetter:(BOOL)containLetter
      containOtherCharacter:(NSString *)containOtherCharacter
        firstCannotBeDigtal:(BOOL)firstCannotBeDigtal;

/** 去掉两端空格和换行符 */
- (NSString *)stringByTrimmingBlank;

/** 去掉html格式 */
- (NSString *)removeHtmlFormat;

/** 工商税号 */
- (BOOL)isValidTaxNo;

@end


#pragma mark - RegexOfClassMethod
@interface NSString (RegexOfClassMethod)

/** 字符串文字的长度 */
+(CGFloat)widthOfString:(NSString *)string font:(UIFont*)font height:(CGFloat)height;

/** 字符串文字的高度 */
+(CGFloat)heightOfString:(NSString *)string font:(UIFont*)font width:(CGFloat)width;

/** 获取今天的日期：年月日 */
+(NSDictionary *)getTodayDate;

/** 邮箱 */
+ (BOOL) justEmail:(NSString *)email;

/** 手机号码验证 */
+ (BOOL) justMobile:(NSString *)mobile;

/** 车牌号验证 */
+ (BOOL) justCarNo:(NSString *)carNo;

/** 车型 */
+ (BOOL) justCarType:(NSString *)CarType;

/** 用户名 */
+ (BOOL) justUserName:(NSString *)name;

/** 密码 */
+ (BOOL) justPassword:(NSString *)passWord;

/** 昵称 */
+ (BOOL) justNickname:(NSString *)nickname;

/** 身份证号 */
+ (BOOL) justIdentityCard: (NSString *)identityCard;

@end
