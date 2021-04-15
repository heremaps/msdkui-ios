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

#import "MockUtils.h"
#import <OCMock/OCMock.h>
#import "MSDKUI/MSDKUI-Swift.h"

@interface NMARoute (Test)

- (NSTimeInterval)durationWithTraffic;

@end

@implementation MockUtils

+ (UIEvent *)mockEventWithTouches:(NSSet<UITouch *> *)touches timestamp:(NSTimeInterval)timestamp
{
    // In order to avoid OCMock method name collision, declare ret as an UIEvent object
    UIEvent *ret = OCMClassMock([UIEvent class]);
    OCMStub([ret allTouches]).andReturn(touches);
    OCMStub([ret timestamp]).andReturn(timestamp);
    return ret;
}

+ (NMAManeuver *)mockManeuver:(NMAManeuverAction)action withTurn:(NMAManeuverTurn)turn
{
    NMAManeuver *mockManeuver = OCMClassMock([NMAManeuver class]);

    OCMStub([mockManeuver action]).andReturn(action);
    OCMStub([mockManeuver turn]).andReturn(turn);
    OCMStub([mockManeuver mapOrientation]).andReturn(17);

    return mockManeuver;
}

+ (NMAManeuver *)mockManeuver:(NMAGeoCoordinates *)coordinates withAction:(NMAManeuverAction)action
{
    NMAManeuver *mockManeuver = OCMClassMock([NMAManeuver class]);

    OCMStub([mockManeuver coordinates]).andReturn(coordinates);
    OCMStub([mockManeuver action]).andReturn(action);

    return mockManeuver;
}

+ (NMAManeuver *)mockManeuver:(NMAGeoCoordinates *)coordinates
                   withAction:(NMAManeuverAction)action
           withSignpostString:(NSString *)signpostString
{
    NMAManeuver *mockManeuver = OCMClassMock([NMAManeuver class]);

    OCMStub([mockManeuver coordinates]).andReturn(coordinates);
    OCMStub([mockManeuver action]).andReturn(action);
    OCMStub([mockManeuver getStringFromSignpost]).andReturn(signpostString);

    return mockManeuver;
}

+ (NMAManeuver *)mockNextManeuver:(NSUInteger)distance
                         withIcon:(NMAManeuverIcon)icon
                    andNextStreet:(NSString *)nextStreet
{
    NMAManeuver *mockManeuver = OCMClassMock([NMAManeuver class]);
    NSString *iconFile = [@"maneuver_icon_" stringByAppendingFormat:@"%lu", (unsigned long)icon];

    OCMStub([mockManeuver icon]).andReturn(icon);
    OCMStub([mockManeuver getIconFileName]).andReturn(iconFile);
    OCMStub([mockManeuver distanceFromPreviousManeuver]).andReturn(distance);
    OCMStub([mockManeuver getNextStreetWithFallback:[OCMArg isNotNil]]).andReturn(nextStreet);

    return mockManeuver;
}

+ (nonnull NMAManeuver *)mockManeuver:(nullable NSString *)currentStreet
{
    NMAManeuver *mockManeuver = OCMClassMock([NMAManeuver class]);

    OCMStub([mockManeuver getCurrentStreet]).andReturn(currentStreet);

    return mockManeuver;
}

+ (NMARoute *)mockRoute
{
    return [self mockRouteWithBoundingBox: NULL];
}

+ (NMARoute *)mockRouteWithBoundingBox:(nullable NMAGeoBoundingBox *)boundingBox
{
    NMARoute *mockRoute = OCMClassMock([NMARoute class]);

    NMAManeuver *mockManeuver0 = OCMClassMock([NMAManeuver class]);
    NMAManeuver *mockManeuver1 = OCMClassMock([NMAManeuver class]);

    OCMStub([mockManeuver0 distanceToNextManeuver]).andReturn(200);
    OCMStub([mockManeuver0 distanceFromPreviousManeuver]).andReturn(0);
    OCMStub([mockManeuver0 action]).andReturn(NMAManeuverActionEnterHighway);
    OCMStub([mockManeuver0 turn]).andReturn(NMAManeuverTurnKeepLeft);
    OCMStub([mockManeuver0 roadNumber]).andReturn(@"10");
    NSArray<NSString *> *roadNames1 = [NSArray arrayWithObjects:@"Current road", nil];
    OCMStub([[mockManeuver0 roadNames] firstObject]).andReturn(roadNames1);
    OCMStub([mockManeuver0 nextRoadNumber]).andReturn(@"11");
    NSArray<NSString *> *nextRoadNames1 = [NSArray arrayWithObjects:@"Next road", nil];
    OCMStub([[mockManeuver0 nextRoadNames] firstObject]).andReturn(nextRoadNames1);
    OCMStub([mockManeuver0 coordinates]).andReturn([NMAGeoCoordinates geoCoordinatesWithLatitude:1.0f longitude:2.0f]);
    OCMStub([mockManeuver0 getIconFileName]).andReturn(@"maneuver_icon_0");

    OCMStub([mockManeuver1 distanceToNextManeuver]).andReturn(0);
    OCMStub([mockManeuver1 distanceFromPreviousManeuver]).andReturn(200);
    OCMStub([mockManeuver1 action]).andReturn(NMAManeuverActionEnd);
    OCMStub([mockManeuver1 turn]).andReturn(NMAManeuverTurnNone);
    OCMStub([mockManeuver1 roadNumber]).andReturn(@"12");
    NSArray<NSString *> *roadNames2 = [NSArray arrayWithObjects:@"End", nil];
    OCMStub([[mockManeuver1 roadNames] firstObject]).andReturn(roadNames2);
    OCMStub([mockManeuver1 nextRoadNumber]).andReturn(@"116");
    NSArray<NSString *> *nextRoadNames2 = [NSArray arrayWithObjects:@"Invalidenstr.", nil];
    OCMStub([[mockManeuver1 nextRoadNames] firstObject]).andReturn(nextRoadNames2);
    OCMStub([mockManeuver1 coordinates]).andReturn([NMAGeoCoordinates geoCoordinatesWithLatitude:3.0f longitude:4.0f]);
    OCMStub([mockManeuver1 getIconFileName]).andReturn(@"maneuver_icon_1");

    NSArray<NMAManeuver *> *maneuvers = [NSArray arrayWithObjects:mockManeuver0, mockManeuver1, nil];
    OCMStub([mockRoute maneuvers]).andReturn(maneuvers);

    OCMStub([mockRoute boundingBox]).andReturn(boundingBox);

    NMARoutingMode *mockRoutingMode = OCMClassMock([NMARoutingMode class]);
    OCMStub([mockRoutingMode transportMode]).andReturn(NMATransportModeCar);
    OCMStub([mockRoute routingMode]).andReturn(mockRoutingMode);

    // Invalidenstraße 116, 10115 Berlin, Germany
    NMAGeoCoordinates *waypointCoordinates = [[NMAGeoCoordinates alloc] initWithLatitude:52.530800 longitude:13.384898];
    NMAWaypoint *waypoint = OCMClassMock([NMAWaypoint class]);
    OCMStub([waypoint originalPosition]).andReturn(waypointCoordinates);

    OCMStub([mockRoute start]).andReturn(waypoint);
    OCMStub([mockRoute destination]).andReturn(waypoint);

    return mockRoute;
}

+ (NMAMapRoute *)mockMapRoute
{
    NMAMapRoute *mockMapRoute = OCMClassMock([NMAMapRoute class]);

    OCMStub([mockMapRoute isTrafficEnabled]).andReturn(FALSE);
    OCMStub([mockMapRoute route]).andReturn([MockUtils mockRoute]);
    OCMStub([mockMapRoute uniqueId]).andReturn(0);

    return mockMapRoute;
}

+ (NSArray<NMARoute *>*)mockRoutes
{
    NMARoutingMode *mockRoutingMode = OCMClassMock([NMARoutingMode class]);
    OCMStub([mockRoutingMode transportMode]).andReturn(NMATransportModeCar);

    NMARouteTta *mockTta0 = OCMClassMock([NMARouteTta class]);
    NMARouteTta *mockTta1 = OCMClassMock([NMARouteTta class]);

    NMARoute *mockRoute0 = OCMClassMock([NMARoute class]);
    NMARoute *mockRoute1 = OCMClassMock([NMARoute class]);

    OCMStub([mockRoute0 routingMode]).andReturn(mockRoutingMode);
    OCMStub([mockRoute1 routingMode]).andReturn(mockRoutingMode);

    OCMStub([mockRoute0 ttaIncludingTrafficForSubleg:NMARouteSublegWhole]).andReturn(mockTta0);
    OCMStub([mockRoute1 ttaIncludingTrafficForSubleg:NMARouteSublegWhole]).andReturn(mockTta1);

    OCMStub([mockRoute0 ttaExcludingTrafficForSubleg:NMARouteSublegWhole]).andReturn(mockTta0);
    OCMStub([mockRoute1 ttaExcludingTrafficForSubleg:NMARouteSublegWhole]).andReturn(mockTta1);

    // The first route has a smaller duration
    OCMStub([mockRoute0 durationWithTraffic]).andReturn(540);
    OCMStub([mockRoute1 durationWithTraffic]).andReturn(711);

    // The first route has a larger length
    OCMStub([mockRoute0 length]).andReturn(50);
    OCMStub([mockRoute1 length]).andReturn(35);

    return [NSArray arrayWithObjects:mockRoute0, mockRoute1, nil];
}

+ (nonnull NMARouteResult *)mockRouteResultWithRoutes:(nullable NSArray<NMARoute *>*)routes
{
    NMARouteResult *routeResultMock = OCMClassMock([NMARouteResult class]);

    OCMStub([routeResultMock routes]).andReturn(routes);

    return routeResultMock;
}

+ (NMANavigationManager *)mockNavigationManager
{
    NMANavigationManager *mockNavigationManager = OCMClassMock([NMANavigationManager class]);

    NMAManeuver *currentManeuver = OCMClassMock([NMAManeuver class]);
    NSArray<NSString *> *nextRoadNames1 = [NSArray arrayWithObjects:@"Invalidenstr.", nil];
    OCMStub([[currentManeuver nextRoadNames] firstObject]).andReturn(nextRoadNames1);
    OCMStub([currentManeuver icon]).andReturn(NMAManeuverIconKeepRight);
    OCMStub([currentManeuver getIconFileName]).andReturn(@"maneuver_icon_4");
    OCMStub([currentManeuver getSignpostExitNumber]).andReturn(nil);
    OCMStub([currentManeuver getNextStreetWithFallback:[OCMArg isNotNil]]).andReturn(@"Invalidenstr.");
    OCMStub(mockNavigationManager.currentManeuver).andReturn(currentManeuver);

    NMAManeuver *nextManeuver = OCMClassMock([NMAManeuver class]);
    NSArray<NSString *> *nextRoadNames2 = [NSArray arrayWithObjects:@"Chausseestr.", nil];
    OCMStub([[nextManeuver nextRoadNames] firstObject]).andReturn(nextRoadNames2);
    OCMStub([nextManeuver nextRoadNumber]).andReturn(@"58");
    OCMStub([nextManeuver icon]).andReturn(NMAManeuverIconKeepLeft);
    OCMStub([nextManeuver getIconFileName]).andReturn(@"maneuver_icon_9");
    OCMStub([nextManeuver getSignpostExitNumber]).andReturn(nil);
    OCMStub([nextManeuver getNextStreetWithFallback:[OCMArg isNotNil]]).andReturn(@"Chausseestr.");
    OCMStub([nextManeuver distanceFromPreviousManeuver]).andReturn(175);
    OCMStub(mockNavigationManager.nextManeuver).andReturn(nextManeuver);

    NMAUint64 distanceToCurrentManeuver = 300;
    OCMStub(mockNavigationManager.distanceToCurrentManeuver).andReturn(distanceToCurrentManeuver);

    return mockNavigationManager;
}

+ (NMANavigationManager *)mockNavigationManagerWithoutNextManeuver
{
    NMANavigationManager *mockNavigationManager = OCMClassMock([NMANavigationManager class]);

    OCMStub(mockNavigationManager.nextManeuver).andReturn(NULL);

    return mockNavigationManager;
}

+ (NMAPositioningManager *)mockPositioningManager
{
    NMAPositioningManager *mockPositioningManager = OCMClassMock([NMAPositioningManager class]);

    NMAGeoCoordinates * coordinates = [[NMAGeoCoordinates alloc] initWithLatitude:52.52 longitude:13.405];
    NMAGeoPosition *position = [[NMAGeoPosition alloc] initWithCoordinates:coordinates speed:0 course:0 accuracy:0];
    OCMStub(mockPositioningManager.currentPosition).andReturn(position);

    return mockPositioningManager;
}

+ (NMAPositioningManager *)mockPositioningManagerWithoutPosition
{
    NMAPositioningManager *mockPositioningManager = OCMClassMock([NMAPositioningManager class]);

    OCMStub(mockPositioningManager.currentPosition).andReturn(NULL);

    return mockPositioningManager;
}

+ (NMARoadElement *)mockRoadElementWithSpeedLimit:(float)speedLimit
{
    NMARoadElement *mockRouteElement = OCMClassMock([NMARoadElement class]);

    OCMStub([mockRouteElement speedLimit]).andReturn(speedLimit);

    return mockRouteElement;
}

+ (UITapGestureRecognizer *)mockTapGestureRecognizerWithState:(UIGestureRecognizerState)state
{
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] init];
    UITapGestureRecognizer *mockTapGestureRecognizer = OCMPartialMock(gesture);

    OCMStub([mockTapGestureRecognizer state]).andReturn(state);

    return mockTapGestureRecognizer;
}

+ (NMARouteResult *)mockCoreResultWithRoutes:(NSArray <NMARoute *>*)routes
{
    NMARouteResult *result = OCMClassMock([NMARouteResult class]);

    OCMStub([result routes]).andReturn(routes);

    return result;
}

+ (NMAReverseGeocodeResult *)mockReverseGeocodeResult:(NSString *)formattedAddress
                                               street:(nullable NSString *)street
                                          houseNumber:(nullable NSString *)houseNumber
{
    NMAAddress *mockAddress = OCMClassMock([NMAAddress class]);

    OCMStub([mockAddress formattedAddress]).andReturn(formattedAddress);
    OCMStub([mockAddress street]).andReturn(street);
    OCMStub([mockAddress houseNumber]).andReturn(houseNumber);

    NMAPlaceLocation *mockLocation = OCMClassMock([NMAPlaceLocation class]);

    OCMStub([mockLocation address]).andReturn(mockAddress);

    NMAReverseGeocodeResult *result = OCMClassMock([NMAReverseGeocodeResult class]);

    OCMStub([result location]).andReturn(mockLocation);

    return result;
}

@end
