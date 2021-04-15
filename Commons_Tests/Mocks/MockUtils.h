//
// Copyright (C) 2017-2021 HERE Europe B.V.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <Foundation/Foundation.h>
#import <NMAKit/NMAKit.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MockUtils : NSObject

+ (UIEvent *)mockEventWithTouches:(NSSet<UITouch *> *)touches timestamp:(NSTimeInterval)timestamp;

+ (NMAManeuver *)mockManeuver:(NMAManeuverAction)action withTurn:(NMAManeuverTurn)turn;

+ (NMAManeuver *)mockManeuver:(NMAGeoCoordinates *)coordinates withAction:(NMAManeuverAction)action;

+ (NMAManeuver *)mockManeuver:(NMAGeoCoordinates *)coordinates
                   withAction:(NMAManeuverAction)action
           withSignpostString:(NSString *)signpostString;

+ (NMAManeuver *)mockNextManeuver:(NSUInteger)distance
                         withIcon:(NMAManeuverIcon)icon
                    andNextStreet:(nullable NSString *)nextStreet;

+ (NMAManeuver *)mockManeuver:(nullable NSString *)currentStreet;

+ (NMARoute *)mockRoute;

+ (NMARoute *)mockRouteWithBoundingBox:(nullable NMAGeoBoundingBox *)boundingBox;

+ (NMAMapRoute *)mockMapRoute;

+ (NSArray<NMARoute *>*)mockRoutes;

+ (NMARouteResult *)mockRouteResultWithRoutes:(nullable NSArray<NMARoute *>*)routes;

+ (NMANavigationManager *)mockNavigationManager;

+ (NMANavigationManager *)mockNavigationManagerWithoutNextManeuver;

+ (NMAPositioningManager *)mockPositioningManager;

+ (NMAPositioningManager *)mockPositioningManagerWithoutPosition;

+ (NMAReverseGeocodeResult *)mockReverseGeocodeResult:(NSString *)formattedAddress
                                               street:(nullable NSString *)street
                                          houseNumber:(nullable NSString *)houseNumber;

/**
  NMARoadElement mock with stubbed speed limit.

  According to NMAKit, the speed limit of the NMARoadElement in m/s or 0 if the information is not available.

  @return A `NMARoadElement` mock object.
 */
+ (NMARoadElement *)mockRoadElementWithSpeedLimit:(float)speedLimit;

+ (UITapGestureRecognizer *)mockTapGestureRecognizerWithState:(UIGestureRecognizerState)state;

+ (NMARouteResult *)mockCoreResultWithRoutes:(NSArray <NMARoute *>*)routes;

@end

NS_ASSUME_NONNULL_END
