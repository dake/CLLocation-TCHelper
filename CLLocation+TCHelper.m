//
//  CLLocation+TCHelper.m
//  SudiyiClient
//
//  Created by cdk on 15/8/11.
//  Copyright (c) 2015年 Sudiyi. All rights reserved.
//

#import "CLLocation+TCHelper.h"

#define LAT_OFFSET_0(x,y) -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(fabs(x))
#define LAT_OFFSET_1 (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0
#define LAT_OFFSET_2 (20.0 * sin(y * M_PI) + 40.0 * sin(y / 3.0 * M_PI)) * 2.0 / 3.0
#define LAT_OFFSET_3 (160.0 * sin(y / 12.0 * M_PI) + 320 * sin(y * M_PI / 30.0)) * 2.0 / 3.0

#define LON_OFFSET_0(x,y) 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(fabs(x))
#define LON_OFFSET_1 (20.0 * sin(6.0 * x * M_PI) + 20.0 * sin(2.0 * x * M_PI)) * 2.0 / 3.0
#define LON_OFFSET_2 (20.0 * sin(x * M_PI) + 40.0 * sin(x / 3.0 * M_PI)) * 2.0 / 3.0
#define LON_OFFSET_3 (150.0 * sin(x / 12.0 * M_PI) + 300.0 * sin(x / 30.0 * M_PI)) * 2.0 / 3.0

#define RANGE_LON_MAX 137.8347
#define RANGE_LON_MIN 72.004
#define RANGE_LAT_MAX 55.8271
#define RANGE_LAT_MIN 0.8293
// jzA = 6378245.0, 1/f = 298.3
// b = a * (1 - f)
// ee = (a^2 - b^2) / a^2;
#define jzA 6378245.0
#define jzEE 0.00669342162296594323


@implementation CLLocation (TCHelper)

+ (CLLocationDegrees)transformLat:(CLLocationDegrees)x bdLon:(CLLocationDegrees)y
{
    CLLocationDegrees ret = LAT_OFFSET_0(x, y);
    ret += LAT_OFFSET_1;
    ret += LAT_OFFSET_2;
    ret += LAT_OFFSET_3;
    return ret;
}

+ (CLLocationDegrees)transformLon:(CLLocationDegrees)x bdLon:(CLLocationDegrees)y
{
    CLLocationDegrees ret = LON_OFFSET_0(x, y);
    ret += LON_OFFSET_1;
    ret += LON_OFFSET_2;
    ret += LON_OFFSET_3;
    return ret;
}

+ (BOOL)outOfChina:(CLLocationDegrees)lat bdLon:(CLLocationDegrees)lon
{
    return (lon < RANGE_LON_MIN || lon > RANGE_LON_MAX)
    || (lat < RANGE_LAT_MIN || lat > RANGE_LAT_MAX);
}

+ (CLLocationCoordinate2D)gcj02Encrypt:(CLLocationDegrees)ggLat bdLon:(CLLocationDegrees)ggLon
{
    if ([self outOfChina:ggLat bdLon:ggLon]) {
        return CLLocationCoordinate2DMake(ggLat, ggLon);
    }
    CLLocationDegrees dLat = [self transformLat:(ggLon - 105.0)bdLon:(ggLat - 35.0)];
    CLLocationDegrees dLon = [self transformLon:(ggLon - 105.0) bdLon:(ggLat - 35.0)];
    CLLocationDegrees radLat = ggLat / 180.0 * M_PI;
    CLLocationDegrees magic = sin(radLat);
    magic = 1 - jzEE * magic * magic;
    CLLocationDegrees sqrtMagic = sqrt(magic);
    dLat = (dLat * 180.0) / ((jzA * (1 - jzEE)) / (magic * sqrtMagic) * M_PI);
    dLon = (dLon * 180.0) / (jzA / sqrtMagic * cos(radLat) * M_PI);
    
    return CLLocationCoordinate2DMake(ggLat + dLat, ggLon + dLon);
}

+ (CLLocationCoordinate2D)gcj02Decrypt:(CLLocationDegrees)gjLat gjLon:(CLLocationDegrees)gjLon
{
    CLLocationCoordinate2D  gPt = [self gcj02Encrypt:gjLat bdLon:gjLon];
    CLLocationDegrees dLon = gPt.longitude - gjLon;
    CLLocationDegrees dLat = gPt.latitude - gjLat;
    return CLLocationCoordinate2DMake(gjLat - dLat, gjLon - dLon);
}

+ (CLLocationCoordinate2D)bd09Decrypt:(CLLocationDegrees)bdLat bdLon:(CLLocationDegrees)bdLon
{
    CLLocationDegrees x = bdLon - 0.0065, y = bdLat - 0.006;
    CLLocationDegrees z = sqrt(x * x + y * y) - 0.00002 * sin(y * M_PI);
    CLLocationDegrees theta = atan2(y, x) - 0.000003 * cos(x * M_PI);
    return CLLocationCoordinate2DMake(z * sin(theta), z * cos(theta));
}

+ (CLLocationCoordinate2D)bd09Encrypt:(CLLocationDegrees)ggLat bdLon:(CLLocationDegrees)ggLon
{
    CLLocationDegrees x = ggLon, y = ggLat;
    CLLocationDegrees z = sqrt(x * x + y * y) + 0.00002 * sin(y * M_PI);
    CLLocationDegrees theta = atan2(y, x) + 0.000003 * cos(x * M_PI);
    return CLLocationCoordinate2DMake(z * sin(theta) + 0.006, z * cos(theta) + 0.0065);
}


+ (CLLocationCoordinate2D)wgs84ToGcj02:(CLLocationCoordinate2D)location
{
    return [self gcj02Encrypt:location.latitude bdLon:location.longitude];
}

+ (CLLocationCoordinate2D)gcj02ToWgs84:(CLLocationCoordinate2D)location
{
    return [self gcj02Decrypt:location.latitude gjLon:location.longitude];
}


+ (CLLocationCoordinate2D)wgs84ToBd09:(CLLocationCoordinate2D)location
{
    CLLocationCoordinate2D gcj02Pt = [self gcj02Encrypt:location.latitude
                                                  bdLon:location.longitude];
    return [self bd09Encrypt:gcj02Pt.latitude bdLon:gcj02Pt.longitude] ;
}

+ (CLLocationCoordinate2D)gcj02ToBd09:(CLLocationCoordinate2D)location
{
    return  [self bd09Encrypt:location.latitude bdLon:location.longitude];
}

+ (CLLocationCoordinate2D)bd09ToGcj02:(CLLocationCoordinate2D)location
{
    return [self bd09Decrypt:location.latitude bdLon:location.longitude];
}

+ (CLLocationCoordinate2D)bd09ToWgs84:(CLLocationCoordinate2D)location
{
    CLLocationCoordinate2D gcj02 = [self bd09ToGcj02:location];
    return [self gcj02Decrypt:gcj02.latitude gjLon:gcj02.longitude];
}

- (instancetype)locationFromWgs84ToGcj02
{
    CLLocationCoordinate2D trans_loc = [self.class wgs84ToGcj02:self.coordinate];
    return [[self.class alloc] initWithCoordinate:trans_loc altitude:self.altitude horizontalAccuracy:self.horizontalAccuracy verticalAccuracy:self.verticalAccuracy timestamp:self.timestamp];
}


@end
