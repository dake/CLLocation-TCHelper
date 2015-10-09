//
//  CLLocation+TCHelper.h
//  Dake
//
//  Created by Dake on 15/8/11.
//  Copyright (c) 2015年 Dake. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface CLLocation (TCHelper)

/**
 @brief	世界标准地理坐标(WGS-84) 转换成 中国国测局地理坐标（GCJ-02）<火星坐标>
 
 ####只在中国大陆的范围的坐标有效，以外直接返回世界标准坐标
 
 @param location [IN] 世界标准地理坐标(WGS-84)
 
 @return 中国国测局地理坐标（GCJ-02）<火星坐标>
 */
+ (CLLocationCoordinate2D)wgs84ToGcj02:(CLLocationCoordinate2D)location;
- (instancetype)locationFromWgs84ToGcj02;


/**
 @brief	中国国测局地理坐标（GCJ-02） 转换成 世界标准地理坐标（WGS-84）
 
 ####此接口有1－2米左右的误差，需要精确定位情景慎用
 
 @param location [IN] 中国国测局地理坐标（GCJ-02）
 
 @return 世界标准地理坐标（WGS-84）
 */
+ (CLLocationCoordinate2D)gcj02ToWgs84:(CLLocationCoordinate2D)location;


/**
 @brief	世界标准地理坐标(WGS-84) 转换成 百度地理坐标（BD-09)
 
 @param location [IN] 世界标准地理坐标(WGS-84)
 
 @return 百度地理坐标（BD-09)
 */
+ (CLLocationCoordinate2D)wgs84ToBd09:(CLLocationCoordinate2D)location;


/**
 @brief	中国国测局地理坐标（GCJ-02）<火星坐标> 转换成 百度地理坐标（BD-09)
 
 @param location [IN] 中国国测局地理坐标（GCJ-02）<火星坐标>
 
 @return 百度地理坐标（BD-09)
 */
+ (CLLocationCoordinate2D)gcj02ToBd09:(CLLocationCoordinate2D)location;


/**
 @brief	百度地理坐标（BD-09) 转换成 中国国测局地理坐标（GCJ-02）<火星坐标>
 
 @param location [IN] 百度地理坐标（BD-09)
 
 @return 中国国测局地理坐标（GCJ-02）<火星坐标>
 */
+ (CLLocationCoordinate2D)bd09ToGcj02:(CLLocationCoordinate2D)location;


/**
 @brief	百度地理坐标（BD-09) 转换成 世界标准地理坐标（WGS-84）
 
 ####此接口有1－2米左右的误差，需要精确定位情景慎用
 
 @param location [IN] 百度地理坐标（BD-09)
 
 @return 世界标准地理坐标（WGS-84）
 */
+ (CLLocationCoordinate2D)bd09ToWgs84:(CLLocationCoordinate2D)location;


/**
 @brief	取模到100米精度
 */
+ (CLLocationCoordinate2D)precision100mFloor:(CLLocationCoordinate2D)location;

@end
