//
// Copyright (C) 2017-2018 HERE Europe B.V.
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

+ (UIEvent *)mockEventWithTouches:(NSSet<UITouch *> *)touches timestamp:(NSTimeInterval)timestamp {
    // In order to avoid OCMock method name collision, declare ret as an UIEvent object
    UIEvent *ret = OCMClassMock([UIEvent class]);
    OCMStub([ret allTouches]).andReturn(touches);
    OCMStub([ret timestamp]).andReturn(timestamp);
    return ret;
}

+ (NMAManeuver *)mockManeuver:(NMAManeuverAction)action withTurn:(NMAManeuverTurn)turn {
    NMAManeuver *mockManeuver = OCMClassMock([NMAManeuver class]);

    OCMStub([mockManeuver action]).andReturn(action);
    OCMStub([mockManeuver turn]).andReturn(turn);
    OCMStub([mockManeuver mapOrientation]).andReturn(17);

    return mockManeuver;
}

+ (NMAManeuver *)mockManeuver:(NMAGeoCoordinates *)coordinates withAction:(NMAManeuverAction)action {
    NMAManeuver *mockManeuver = OCMClassMock([NMAManeuver class]);

    OCMStub([mockManeuver coordinates]).andReturn(coordinates);
    OCMStub([mockManeuver action]).andReturn(action);

    return mockManeuver;
}

+ (NMAManeuver *)mockManeuver:(NMAGeoCoordinates *)coordinates
                   withAction:(NMAManeuverAction)action
           withSignpostString:(NSString *)signpostString {
    NMAManeuver *mockManeuver = OCMClassMock([NMAManeuver class]);

    OCMStub([mockManeuver coordinates]).andReturn(coordinates);
    OCMStub([mockManeuver action]).andReturn(action);
    OCMStub([mockManeuver getStringFromSignpost]).andReturn(signpostString);

    return mockManeuver;
}

+ (NMARoute *)mockRoute {
    NMARoute *mockRoute = OCMClassMock([NMARoute class]);
    NMAManeuver *mockManeuver0 = OCMClassMock([NMAManeuver class]);
    NMAManeuver *mockManeuver1 = OCMClassMock([NMAManeuver class]);

    OCMStub([mockManeuver0 distanceToNextManeuver]).andReturn(200);
    OCMStub([mockManeuver0 distanceFromPreviousManeuver]).andReturn(0);
    OCMStub([mockManeuver0 action]).andReturn(NMAManeuverActionEnterHighway);
    OCMStub([mockManeuver0 turn]).andReturn(NMAManeuverTurnKeepLeft);
    OCMStub([mockManeuver0 roadNumber]).andReturn(@"10");
    OCMStub([mockManeuver0 roadName]).andReturn(@"Current road");
    OCMStub([mockManeuver0 nextRoadNumber]).andReturn(@"11");
    OCMStub([mockManeuver0 nextRoadName]).andReturn(@"Next road");
    OCMStub([mockManeuver0 coordinates]).andReturn([NMAGeoCoordinates geoCoordinatesWithLatitude: 1.0f longitude: 2.0f]);

    OCMStub([mockManeuver1 distanceToNextManeuver]).andReturn(0);
    OCMStub([mockManeuver1 distanceFromPreviousManeuver]).andReturn(200);
    OCMStub([mockManeuver1 action]).andReturn(NMAManeuverActionEnd);
    OCMStub([mockManeuver1 turn]).andReturn(NMAManeuverTurnNone);
    OCMStub([mockManeuver1 roadNumber]).andReturn(@"12");
    OCMStub([mockManeuver1 roadName]).andReturn(@"End");
    OCMStub([mockManeuver1 nextRoadNumber]).andReturn(@"116");
    OCMStub([mockManeuver1 nextRoadName]).andReturn(@"Invalidenstr.");
    OCMStub([mockManeuver0 coordinates]).andReturn([NMAGeoCoordinates geoCoordinatesWithLatitude: 3.0f longitude: 4.0f]);

    NSArray<NMAManeuver *> *maneuvers = [NSArray arrayWithObjects: mockManeuver0, mockManeuver1, nil];
    OCMStub([mockRoute maneuvers]).andReturn(maneuvers);
    return mockRoute;
};

+ (NSArray<NMARoute *>*)mockRoutes {
    NMARoutingMode *mockRoutingMode = OCMClassMock([NMARoutingMode class]);
    OCMStub([mockRoutingMode transportMode]).andReturn(NMATransportModeCar);

    NMARouteTta *mockTta0 = OCMClassMock([NMARouteTta class]);
    NMARouteTta *mockTta1 = OCMClassMock([NMARouteTta class]);

    NMARoute *mockRoute0 = OCMClassMock([NMARoute class]);
    NMARoute *mockRoute1 = OCMClassMock([NMARoute class]);

    OCMStub([mockRoute0 routingMode]).andReturn(mockRoutingMode);
    OCMStub([mockRoute1 routingMode]).andReturn(mockRoutingMode);

    OCMStub([mockRoute0 ttaWithTraffic: NMATrafficPenaltyModeDisabled]).andReturn(mockTta0);
    OCMStub([mockRoute1 ttaWithTraffic: NMATrafficPenaltyModeDisabled]).andReturn(mockTta1);

    // The first route has a smaller duration
    OCMStub([mockRoute0 durationWithTraffic]).andReturn(540);
    OCMStub([mockRoute1 durationWithTraffic]).andReturn(711);

    // The first route has a larger length
    OCMStub([mockRoute0 length]).andReturn(50);
    OCMStub([mockRoute1 length]).andReturn(35);

    return [NSArray arrayWithObjects: mockRoute0, mockRoute1, nil];
}

+ (nonnull NMARouteResult *)mockRouteResultWithRoutes: (nullable NSArray<NMARoute *>*)routes {
    NMARouteResult *routeResultMock = OCMClassMock([NMARouteResult class]);

    OCMStub([routeResultMock routes]).andReturn(routes);

    return routeResultMock;
}

+ (NMANavigationManager *)mockNavigationManager {
    NMANavigationManager *mockNavigationManager = OCMClassMock([NMANavigationManager class]);

    NMAManeuver *currentManeuver = OCMClassMock([NMAManeuver class]);
    OCMStub([currentManeuver nextRoadName]).andReturn(@"Invalidenstr.");
    OCMStub([currentManeuver icon]).andReturn(NMAManeuverIconKeepRight);
    OCMStub([currentManeuver getIconFileName]).andReturn(@"maneuver_icon_4");
    OCMStub([currentManeuver getSignpostExitNumber]).andReturn(nil);
    OCMStub([currentManeuver getNextStreetWithFallback: [OCMArg isNotNil]]).andReturn(@"Invalidenstr.");
    OCMStub(mockNavigationManager.currentManeuver).andReturn(currentManeuver);

    NMAManeuver *nextManeuver = OCMClassMock([NMAManeuver class]);
    OCMStub([nextManeuver nextRoadName]).andReturn(@"Chausseestr.");
    OCMStub([nextManeuver nextRoadNumber]).andReturn(@"58");
    OCMStub([nextManeuver icon]).andReturn(NMAManeuverIconKeepLeft);
    OCMStub([nextManeuver getIconFileName]).andReturn(@"maneuver_icon_9");
    OCMStub([nextManeuver getSignpostExitNumber]).andReturn(nil);
    OCMStub([nextManeuver getNextStreetWithFallback: [OCMArg isNotNil]]).andReturn(@"Chausseestr.");
    OCMStub([nextManeuver distanceFromPreviousManeuver]).andReturn(175);
    OCMStub(mockNavigationManager.nextManeuver).andReturn(nextManeuver);

    NMAUint64 distanceToCurrentManeuver = 300;
    OCMStub(mockNavigationManager.distanceToCurrentManeuver).andReturn(distanceToCurrentManeuver);

    return mockNavigationManager;
}

+ (NMANavigationManager *)mockNavigationManagerWithoutNextManeuver {
    NMANavigationManager *mockNavigationManager = OCMClassMock([NMANavigationManager class]);

    OCMStub(mockNavigationManager.nextManeuver).andReturn(NULL);

    return mockNavigationManager;
}

+ (NMAPositioningManager *)mockPositioningManager {
    NMAPositioningManager *mockPositioningManager = OCMClassMock([NMAPositioningManager class]);

    NMAGeoCoordinates * coordinates = [[NMAGeoCoordinates alloc] initWithLatitude:52.52 longitude:13.405];
    NMAGeoPosition *position = [[NMAGeoPosition alloc] initWithCoordinates:coordinates speed:0 course:0 accuracy:0];
    OCMStub(mockPositioningManager.currentPosition).andReturn(position);

    return mockPositioningManager;
}

+ (NMAPositioningManager *)mockPositioningManagerWithoutPosition {
    NMAPositioningManager *mockPositioningManager = OCMClassMock([NMAPositioningManager class]);

    OCMStub(mockPositioningManager.currentPosition).andReturn(NULL);

    return mockPositioningManager;
}

@end
