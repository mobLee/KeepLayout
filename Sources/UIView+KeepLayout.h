//
//  UIView+KeepLayout.h
//  Geografia
//
//  Created by Martin Kiss on 21.10.12.
//  Copyright (c) 2012 iMartin Kiss. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import "KeepTypes.h"

@class KeepAttribute;




/// Category that provides very easy access to all Auto Layout features through abstraction above NSLayoutConstraints.
@interface UIView (KeepLayout)





#pragma mark Dimensions

/// Attributes representing internal size of the receiver.
- (KeepAttribute *)keepWidth;
- (KeepAttribute *)keepHeight;

/// Grouped proxy attribute for size.
- (KeepAttribute *)keepSize;

/// Convenience methods for setting both dimensions at once.
- (void)keepSize:(CGSize)size; /// Uses Required priority
- (void)keepSize:(CGSize)size priority:(KeepPriority)priority;

/// Attributes representing aspect ratio of receiver's dimensions. Values are multipliers of width/height.
- (KeepAttribute *)keepAspectRatio;

/// Attributes representing relative dimension to other view.
- (KeepAttribute *(^)(UIView *))keepWidthTo;
- (KeepAttribute *(^)(UIView *))keepHeightTo;

/// Grouped proxy attribute for relative size.
- (KeepAttribute *(^)(UIView *))keepSizeTo;



#pragma mark Superview Insets

/// Attributes representing internal inset (margin) of the receive to its superview.
/// Requires superview.
- (KeepAttribute *)keepLeftInset;
- (KeepAttribute *)keepRightInset; /// Automatically inverts values.
- (KeepAttribute *)keepTopInset;
- (KeepAttribute *)keepBottomInset; /// Automatically inverts values.

/// Grouped proxy attributes for insets.
- (KeepAttribute *)keepInsets;
- (KeepAttribute *)keepHorizontalInsets;
- (KeepAttribute *)keepVerticalInsets;

/// Convenience methods for setting all dimensions at once.
- (void)keepInsets:(UIEdgeInsets)insets; /// Uses Required priority
- (void)keepInsets:(UIEdgeInsets)insets priority:(KeepPriority)priority;



#pragma mark Center

/// Attributes representing relative position of the receiver to its superview.
/// Requires superview.
/// Example values: 0 = left edge, 0.5 = middle, 1 = right edge
- (KeepAttribute *)keepHorizontalCenter;
- (KeepAttribute *)keepVerticalCenter;

/// Grouped proxy attribute of the two centers above.
- (KeepAttribute *)keepCenter;

/// Convenience methods for setting both centers at once.
- (void)keepCentered; /// Uses Required priority
- (void)keepCenteredWithPriority:(KeepPriority)priority;
- (void)keepCenter:(CGPoint)center; /// Uses Required priority
- (void)keepCenter:(CGPoint)center priority:(KeepPriority)priority;



#pragma mark Offsets

/// Attributes representing offset (padding, distance) of two views.
/// Requires both views to be in the same hierarchy.
/// Usage `view.keepLeftOffset(anotherView)`
/// Default is “0 required”
- (KeepAttribute *(^)(UIView *))keepLeftOffsetTo;
- (KeepAttribute *(^)(UIView *))keepRightOffsetTo; /// Identical to left offset in reversed direction.
- (KeepAttribute *(^)(UIView *))keepTopOffsetTo;
- (KeepAttribute *(^)(UIView *))keepBottomOffsetTo; /// Identical to top offset in reversed direction.



#pragma mark Alignments

/// Attributes representing edge alignments of two views.
/// Requires both views to be in the same hierarchy.
/// Usage `view.keepLeftAlign(anotherView)`.
/// Optional values specify offset from the alignment line.
/// Default is „0 required”.
- (KeepAttribute *(^)(UIView *))keepLeftAlignTo;
- (KeepAttribute *(^)(UIView *))keepRightAlignTo; /// Automatically inverts values.
- (KeepAttribute *(^)(UIView *))keepTopAlignTo;
- (KeepAttribute *(^)(UIView *))keepBottomAlignTo; /// Automatically inverts values.

/// Convenience methods for setting all edge alignments at once.
- (void)keepEdgeAlignTo:(UIView *)view;
- (void)keepEdgeAlignTo:(UIView *)view insets:(UIEdgeInsets)insets;
- (void)keepEdgeAlignTo:(UIView *)view insets:(UIEdgeInsets)insets withPriority:(KeepPriority)priority;

/// Attributes representing center alignments of two views.
- (KeepAttribute *(^)(UIView *))keepVerticalAlignTo;
- (KeepAttribute *(^)(UIView *))keepHorizontalAlignTo; /// Automatically inverts values.

/// Convenience methods for setting center (both axis) alignment.
- (void)keepCenterAlignTo:(UIView *)view;
- (void)keepCenterAlignTo:(UIView *)view offset:(UIOffset)offset;
- (void)keepCenterAlignTo:(UIView *)view offset:(UIOffset)offset withPriority:(KeepPriority)priority;

/// Attribute representing baseline alignments of two views.
/// Not all views have baseline.
- (KeepAttribute *(^)(UIView *))keepBaselineAlignTo; /// Automatically inverts values.



#pragma mark Animating Constraints

/// Animation methods allowing you to modify all above attributes (or even constraints directly) animatedly.
/// Receiver automatically calls `-layoutIfNeeded` right in the animation block.
/// All animations are scheduled on main queue with given delay. The layout code itself is executed after the delay (this is different than in UIView animation methods)
- (void)keepAnimatedWithDuration:(NSTimeInterval)duration layout:(void(^)(void))animations;
- (void)keepAnimatedWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay layout:(void(^)(void))animations;
- (void)keepAnimatedWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options layout:(void(^)(void))animations completion:(void(^)(BOOL finished))completion;


#pragma mark Common Superview
/// Traverses superviews and returns the first common for both, the receiver and the argument.
- (UIView *)commonSuperview:(UIView *)anotherView;


#pragma mark Convenience Auto Layout
/// Methods not used by Keep Layout directly, but are provided for your convenience.

/// Add/remove single constraint.
- (void)addConstraintToCommonSuperview:(NSLayoutConstraint *)constraint;
- (void)removeConstraintFromCommonSuperview:(NSLayoutConstraint *)constraint;

/// Add/remove collection of constraints.
- (void)addConstraintsToCommonSuperview:(id<NSFastEnumeration>)constraints;
- (void)removeConstraintsFromCommonSuperview:(id<NSFastEnumeration>)constraints;



@end
