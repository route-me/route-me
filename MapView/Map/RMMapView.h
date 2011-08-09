//
//  RMMapView.h
//
// Copyright (c) 2008-2009, Route-Me Contributors
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

/*! \mainpage Route-Me Map Framework 

\section intro_sec Introduction

Route-Me is an open source Objective-C framework for displaying maps on Cocoa Touch devices 
(the iPhone, and the iPod Touch). It was written in 2008 by Joseph Gentle as the basis for a transit
routing app. The transit app was not completed, because the government agencies involved chose not to release
the necessary data under reasonable licensing terms. The project was released as open source under the New BSD license (http://www.opensource.org/licenses/bsd-license.php) 
in September, 2008, and
is hosted on github (https://github.com/route-me/route-me).

 Route-Me provides a UIView subclass with a panning, zooming map. Zoom level, source of map data, map center,
 marker overlays, and path overlays are all supported.
 \section license_sec License
 Route-Me is licensed under the New BSD license.
 
 In any app that uses the Route-Me library, include the following text on your "preferences" or "about" screen: "Uses Route-Me map library, (c) 2008-2011 Route-Me Contributors". 
 
\section install_sec Installation

As Route-Me is undergoing some significant changes, the recommended course of action is to clone a copy of the repository: 
\verbatim
git clone git://github.com/route-me/route-me.git
\endverbatim

 There are three subdirectories - MapView, Proj4, and samples. Proj4 is a support class used to do map projections. The MapView project contains only the route-me map library. "samples" contains some ready-to-build projects which you may use as starting points for your own applications, and also some engineering test cases. samples/SampleMap and samples/ProgrammaticMap are the best places to look, to see how to embed a Route-Me map in your application.

 Also see https://github.com/route-me/route-me/wiki/Embedding-Guide
 
\section maps_sec Map Data
 
 Route-Me supports map data served from many different sources:
 - the Open Street Map project's server.
 - CloudMade, which provides commercial servers delivering Open Street Map data.
 - Microsoft Virtual Earth.
 - Open Aerial Map.
 - Yahoo! Maps.
 
 Each of these data sources has different license restrictions and fees. In particular, Yahoo! Maps are 
 effectively unusable in Route-Me due to their license terms; the Yahoo! access code is provided for demonstration
 purposes only.
 
 You must contact the data vendor directly and arrange licensing if necessary, including obtaining your own
 access key. Follow their rules.
 
 If you have your own data you'd like to use with Route-Me, serving it through your own Mapnik installation
 looks like the best bet. Mapnik is an open source web-based map delivery platform. For more information on
 Mapnik, see http://www.mapnik.org/ .
 
 \section news_sec Project News and Updates
 For the most current information on Route-Me, see these sources:
 - wiki: https://github.com/route-me/route-me/wiki
 - project email reflector: http://groups.google.com/group/route-me-map
 - list of all project RSS feeds: http://code.google.com/p/route-me/feeds
 - applications using Route-Me: http://code.google.com/p/route-me/wiki/RoutemeApplications
 
 */

#import <UIKit/UIKit.h>
#import <CoreGraphics/CGGeometry.h>

#import "RMNotifications.h"
#import "RMFoundation.h"
#import "RMLatLong.h"
#import "RMMapViewDelegate.h"
#import "RMMapContents.h"

/*! 
 \struct RMGestureDetails
 iPhone-specific mapview stuff. Handles event handling, whatnot.
 */
typedef struct {
	CGPoint center;
	CGFloat angle;
	float averageDistanceFromCenter;
	int numTouches;
} RMGestureDetails;

@class RMMapContents;

/*! 
 \brief Wrapper around RMMapContents for the iPhone.
 
 It implements event handling; but that's about it. All the interesting map
 logic is done by RMMapContents. There is exactly one RMMapView instance for each RMMapContents instance.
 
 A -forwardInvocation method exists for RMMap, and forwards all unhandled messages to the RMMapContents instance.
 
 \bug No accessors for enableDragging, enableZoom, deceleration, decelerationFactor. Changing enableDragging does not change multitouchEnabled for the view.
 */
@interface RMMapView : UIView <RMMapContentsFacade, RMMapContentsAnimationCallback>
{
	RMMapContents *contents;
	id<RMMapViewDelegate> delegate;
	BOOL enableDragging;
	BOOL enableZoom;
        BOOL enableRotate;
	RMGestureDetails lastGesture;
	float decelerationFactor;
	BOOL deceleration;
        CGFloat rotation;
	
@private
   	BOOL _delegateHasBeforeMapMove;
	BOOL _delegateHasAfterMapMove;
	BOOL _delegateHasBeforeMapZoomByFactor;
	BOOL _delegateHasAfterMapZoomByFactor;
	BOOL _delegateHasMapViewRegionDidChange;
	BOOL _delegateHasBeforeMapRotate;
	BOOL _delegateHasAfterMapRotate;
	BOOL _delegateHasDoubleTapOnMap;
	BOOL _delegateHasSingleTapOnMap;
	BOOL _delegateHasTapOnMarker;
	BOOL _delegateHasTapOnLabelForMarker;
	BOOL _delegateHasAfterMapTouch;
	BOOL _delegateHasShouldDragMarker;
	BOOL _delegateHasDidDragMarker;
	BOOL _delegateHasDragMarkerPosition;
	
	NSTimer *_decelerationTimer;
	CGSize _decelerationDelta;
	
	BOOL _constrainMovement;
	RMProjectedPoint NEconstraint, SWconstraint;
	
	BOOL _contentsIsSet; // "contents" must be set, but is initialized lazily to allow apps to override defaults in -awakeFromNib
}

/// Any other functionality you need to manipulate the map you can access through this
/// property. The RMMapContents class holds the actual map bits.
@property (nonatomic, retain) RMMapContents *contents;

// View properties
@property (readwrite) BOOL enableDragging;
@property (readwrite) BOOL enableZoom;
@property (readwrite) BOOL enableRotate;

@property (nonatomic, retain, readonly) RMMarkerManager *markerManager;

// do not retain the delegate so you can let the corresponding controller implement the
// delegate without circular references
@property (assign) id<RMMapViewDelegate> delegate;
@property (readwrite) float decelerationFactor;
@property (readwrite) BOOL deceleration;

@property (readonly) CGFloat rotation;

- (id)initWithFrame:(CGRect)frame WithLocation:(CLLocationCoordinate2D)latlong;

/// recenter the map on #latlong, expressed as CLLocationCoordinate2D (latitude/longitude)
- (void)moveToLatLong: (CLLocationCoordinate2D)latlong;
/// recenter the map on #aPoint, expressed in projected meters
- (void)moveToProjectedPoint: (RMProjectedPoint)aPoint;

- (void)moveBy: (CGSize) delta;

-(void)setConstraintsSW:(CLLocationCoordinate2D)sw NE:(CLLocationCoordinate2D)ne;
- (void)setProjectedContraintsSW:(RMProjectedPoint)sw NE:(RMProjectedPoint)ne;

- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) aPoint;
- (void)zoomByFactor: (float) zoomFactor near:(CGPoint) aPoint animated:(BOOL)animated;

- (void)didReceiveMemoryWarning;

- (void)setRotation:(CGFloat)angle;


@end
