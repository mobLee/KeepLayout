//
//  KeepAttribute.m
//  Keep Layout
//
//  Created by Martin Kiss on 28.1.13.
//  Copyright (c) 2013 Triceratops. All rights reserved.
//

#import "KeepAttribute.h"
#import "KeepRule.h"
#import "UIView+KeepLayout.h"



@interface KeepAttribute ()

@property (nonatomic, readwrite, assign) KeepAttributeType type;
@property (nonatomic, readwrite, weak) UIView *relatedView;
@property (nonatomic, readwrite, copy) NSArray *rules;

+ (KeepAttributeType)classType;

@end




@implementation KeepAttribute



#pragma mark Initialization

- (id)initWithType:(KeepAttributeType)type relatedView:(UIView *)view rules:(NSArray *)rules {
    self = [super init];
	if (self) {
		self.type = type;
        self.relatedView = view;
        self.rules = rules;
	}
	return self;
}

- (id)initWithType:(KeepAttributeType)type rules:(NSArray *)rules {
	return [self initWithType:type relatedView:nil rules:rules];
}



#pragma mark Short Syntax

+ (instancetype)rules:(NSArray *)rules {
    return [self to:nil rules:rules];
}

+ (instancetype)to:(UIView *)view rules:(NSArray *)rules {
    return [[self alloc] initWithType:[self classType] relatedView:view rules:rules];
}



#pragma mark Class-Specific

+ (KeepAttributeType)classType {
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Class KeepAttribute does not have implitit attribute type, use one of the subclasses" userInfo:nil];
}



#pragma mark Applying

- (void)applyInView:(UIView *)mainView {
    NSLayoutAttribute mainLayoutAttribute = [self mainLayoutAttribute];
    UIView *relatedLayoutView = [self relatedLayoutViewForMainView:mainView];
    NSLayoutAttribute relatedLayoutAttribute = [self relatedLayoutAttribute];
    
    mainView.translatesAutoresizingMaskIntoConstraints = NO;
    relatedLayoutView.translatesAutoresizingMaskIntoConstraints = NO;
    NSAssert(mainView.superview, @"Must have superview");
    
    for (KeepRule *rule in self.rules) {
        if (rule.relatedView) {
            relatedLayoutView = rule.relatedView;
            relatedLayoutAttribute = mainLayoutAttribute;
        }
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:mainView
                                                                      attribute:mainLayoutAttribute
                                                                      relatedBy:[self layoutRelationForRule:rule]
                                                                         toItem:relatedLayoutView
                                                                      attribute:relatedLayoutAttribute
                                                                     multiplier:[self layoutMultiplierForRule:rule]
                                                                       constant:[self layoutConstantForRule:rule]];
        constraint.priority = rule.priority;
        UIView *commonView = (relatedLayoutView? [mainView commonAncestor:relatedLayoutView] : mainView);
        NSLog(@"KeepLayout: Adding constraint %@", constraint);
        [commonView addConstraint:constraint];
    }
}



#pragma mark Constraint Attribute Mapping

- (NSLayoutAttribute)mainLayoutAttribute {
    switch (self.type) {
        case KeepAttributeTypeWidth:        return NSLayoutAttributeWidth   ;
        case KeepAttributeTypeHeight:       return NSLayoutAttributeHeight  ;
        case KeepAttributeTypeAspectRatio:  return NSLayoutAttributeWidth   ;
        case KeepAttributeTypeTopInset:     return NSLayoutAttributeTop     ;
        case KeepAttributeTypeBottomInset:  return NSLayoutAttributeBottom  ;
        case KeepAttributeTypeLeftInset:    return NSLayoutAttributeLeft    ;
        case KeepAttributeTypeRightInset:   return NSLayoutAttributeRight   ;
        case KeepAttributeTypeHorizontally: return NSLayoutAttributeCenterX ;
        case KeepAttributeTypeVertically:   return NSLayoutAttributeCenterY ;
        case KeepAttributeTypeTopOffset:    return NSLayoutAttributeTop     ;
        case KeepAttributeTypeBottomOffset: return NSLayoutAttributeBottom  ;
        case KeepAttributeTypeLeftOffset:   return NSLayoutAttributeLeft    ;
        case KeepAttributeTypeRightOffset:  return NSLayoutAttributeRight   ;
    }
}

- (UIView *)relatedLayoutViewForMainView:(UIView *)mainView {
    switch (self.type) {
        case KeepAttributeTypeWidth:        return nil                  ; // No related view.
        case KeepAttributeTypeHeight:       return nil                  ; // No related view.
        case KeepAttributeTypeAspectRatio:  return mainView             ;
        case KeepAttributeTypeTopInset:     return mainView.superview   ;
        case KeepAttributeTypeBottomInset:  return mainView.superview   ;
        case KeepAttributeTypeLeftInset:    return mainView.superview   ;
        case KeepAttributeTypeRightInset:   return mainView.superview   ;
        case KeepAttributeTypeHorizontally: return mainView.superview   ;
        case KeepAttributeTypeVertically:   return mainView.superview   ;
        case KeepAttributeTypeTopOffset:    return self.relatedView     ;
        case KeepAttributeTypeBottomOffset: return self.relatedView     ;
        case KeepAttributeTypeLeftOffset:   return self.relatedView     ;
        case KeepAttributeTypeRightOffset:  return self.relatedView     ;
    }
}

- (NSLayoutAttribute)relatedLayoutAttribute {
    switch (self.type) {
        case KeepAttributeTypeWidth:        return NSLayoutAttributeNotAnAttribute  ; // No second attribute.
        case KeepAttributeTypeHeight:       return NSLayoutAttributeNotAnAttribute  ; // No second attribute.
        case KeepAttributeTypeAspectRatio:  return NSLayoutAttributeHeight          ; // Width to height.
        case KeepAttributeTypeTopInset:     return NSLayoutAttributeTop             ;
        case KeepAttributeTypeBottomInset:  return NSLayoutAttributeBottom          ;
        case KeepAttributeTypeLeftInset:    return NSLayoutAttributeLeft            ;
        case KeepAttributeTypeRightInset:   return NSLayoutAttributeRight           ;
        case KeepAttributeTypeHorizontally: return NSLayoutAttributeCenterX         ;
        case KeepAttributeTypeVertically:   return NSLayoutAttributeCenterY         ;
        case KeepAttributeTypeTopOffset:    return NSLayoutAttributeBottom          ; // My top to his bottom.
        case KeepAttributeTypeBottomOffset: return NSLayoutAttributeTop             ; // My bottom to his top.
        case KeepAttributeTypeLeftOffset:   return NSLayoutAttributeRight           ; // My left to his right.
        case KeepAttributeTypeRightOffset:  return NSLayoutAttributeLeft            ; // My right to his left.
    }
}

- (BOOL)swapMaxMinLayoutRelation {
    // Some of the types need to have inverted maximum and mimimum rules.
    // For example BottomInset is inverted on Y axis, so maximum value means view bottom edge is less or equal than superview's bottom + 10.
    switch (self.type) {
        case KeepAttributeTypeWidth:        return NO ;
        case KeepAttributeTypeHeight:       return NO ;
        case KeepAttributeTypeAspectRatio:  return YES;
        case KeepAttributeTypeTopInset:     return YES;
        case KeepAttributeTypeBottomInset:  return NO ;
        case KeepAttributeTypeLeftInset:    return YES;
        case KeepAttributeTypeRightInset:   return NO ;
        case KeepAttributeTypeHorizontally: return YES;
        case KeepAttributeTypeVertically:   return YES;
        case KeepAttributeTypeTopOffset:    return YES;
        case KeepAttributeTypeBottomOffset: return NO ;
        case KeepAttributeTypeLeftOffset:   return YES;
        case KeepAttributeTypeRightOffset:  return NO;
    }
}

- (NSLayoutRelation)layoutRelationForRule:(KeepRule *)rule {
    BOOL swapMaxMin = [self swapMaxMinLayoutRelation];
    switch (rule.type) {
        case KeepRuleTypeEqual: return NSLayoutRelationEqual;
        case KeepRuleTypeMax:   return (swapMaxMin ? NSLayoutRelationLessThanOrEqual    : NSLayoutRelationGreaterThanOrEqual);
        case KeepRuleTypeMin:   return (swapMaxMin ? NSLayoutRelationGreaterThanOrEqual : NSLayoutRelationLessThanOrEqual   );
    }
}

- (CGFloat)layoutMultiplierForRule:(KeepRule *)rule {
    // Rule value may be interpreted different ways depending on attribute type.
    switch (self.type) {
        case KeepAttributeTypeWidth:        return 1                ;
        case KeepAttributeTypeHeight:       return 1                ;
        case KeepAttributeTypeAspectRatio:  return rule.value       ; // Rule specified the multiplier.
        case KeepAttributeTypeTopInset:     return 1                ;
        case KeepAttributeTypeBottomInset:  return 1                ;
        case KeepAttributeTypeLeftInset:    return 1                ;
        case KeepAttributeTypeRightInset:   return 1                ;
        case KeepAttributeTypeHorizontally: return rule.value * 2   ; // One in constraint multiplier mean 0.5 of the whole width.
        case KeepAttributeTypeVertically:   return rule.value * 2   ; // One in constraint multiplier mean 0.5 of the whole height.
        case KeepAttributeTypeTopOffset:    return 1                ;
        case KeepAttributeTypeBottomOffset: return 1                ;
        case KeepAttributeTypeLeftOffset:   return 1                ;
        case KeepAttributeTypeRightOffset:  return 1                ;
    }
}

- (CGFloat)layoutConstantForRule:(KeepRule *)rule {
    switch (self.type) {
        case KeepAttributeTypeWidth:        return  rule.value  ;
        case KeepAttributeTypeHeight:       return  rule.value  ;
        case KeepAttributeTypeAspectRatio:  return  0           ; // No constant.
        case KeepAttributeTypeTopInset:     return  rule.value  ;
        case KeepAttributeTypeBottomInset:  return -rule.value  ; // Bottom inset is inverted on Y axis.
        case KeepAttributeTypeLeftInset:    return  rule.value  ;
        case KeepAttributeTypeRightInset:   return -rule.value  ; // Right inset is inverted on X axis.
        case KeepAttributeTypeHorizontally: return  0           ; // No constant.
        case KeepAttributeTypeVertically:   return  0           ; // No constant.
        case KeepAttributeTypeTopOffset:    return  rule.value  ;
        case KeepAttributeTypeBottomOffset: return -rule.value  ;
        case KeepAttributeTypeLeftOffset:   return  rule.value  ;
        case KeepAttributeTypeRightOffset:  return -rule.value  ;
    }
}



@end





@implementation KeepWidth           + (KeepAttributeType)classType { return KeepAttributeTypeWidth          ; }     @end
@implementation KeepHeight          + (KeepAttributeType)classType { return KeepAttributeTypeHeight         ; }     @end
@implementation KeepAspectRatio     + (KeepAttributeType)classType { return KeepAttributeTypeAspectRatio    ; }     @end
@implementation KeepTopInset        + (KeepAttributeType)classType { return KeepAttributeTypeTopInset       ; }     @end
@implementation KeepBottomInset     + (KeepAttributeType)classType { return KeepAttributeTypeBottomInset    ; }     @end
@implementation KeepLeftInset       + (KeepAttributeType)classType { return KeepAttributeTypeLeftInset      ; }     @end
@implementation KeepRightInset      + (KeepAttributeType)classType { return KeepAttributeTypeRightInset     ; }     @end
@implementation KeepHorizontally    + (KeepAttributeType)classType { return KeepAttributeTypeHorizontally   ; }     @end
@implementation KeepVertically      + (KeepAttributeType)classType { return KeepAttributeTypeVertically     ; }     @end
@implementation KeepTopOffset       + (KeepAttributeType)classType { return KeepAttributeTypeTopOffset      ; }     @end
@implementation KeepBottomOffset    + (KeepAttributeType)classType { return KeepAttributeTypeBottomOffset   ; }     @end
@implementation KeepLeftOffset      + (KeepAttributeType)classType { return KeepAttributeTypeLeftOffset     ; }     @end
@implementation KeepRightOffset     + (KeepAttributeType)classType { return KeepAttributeTypeRightOffset    ; }     @end
