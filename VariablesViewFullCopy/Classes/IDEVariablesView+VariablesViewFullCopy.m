//
//  IDEVariablesView+VariablesViewFullCopy.m
//  VariablesViewFullCopy
//
//  Created by Fabio Ritrovato on 20/08/2015.
//  Copyright (c) 2015 orange in a day. All rights reserved.
//

#import "IDEVariablesView+VariablesViewFullCopy.h"
#import "DVTKit.h"
#import "DebuggerLLDB.h"
#import <objc/runtime.h>

@interface IDEVariablesView (VariablesViewFullCopy)

@property (nonatomic) NSButton *cancelButton;
@property (nonatomic, assign, getter=isCancelled) BOOL cancelled;

@end

@implementation IDEVariablesView (VariablesViewFullCopy)

+ (void)load
{
    [self jr_swizzleMethod:@selector(viewDidLoad) withMethod:@selector(vvfc_viewDidLoad) error:NULL];
    [self jr_swizzleMethod:@selector(menuNeedsUpdate:) withMethod:@selector(vvfc_menuNeedsUpdate:) error:NULL];
}

- (void)vvfc_viewDidLoad
{
    [self vvfc_viewDidLoad];
    NSButton *button = [NSButton new];
    button.title = @"Cancel";
    button.bezelStyle = NSRoundedBezelStyle;
    button.hidden = YES;
    [button setButtonType:NSMomentaryLightButton];
    [[self.loadingIndicator superview] addSubview:button];
    [button setTranslatesAutoresizingMaskIntoConstraints:NO];
    [button.superview addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.loadingIndicator attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f]];
    [button.superview addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.loadingIndicator attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:40.0f]];
    button.target = self;
    button.action = @selector(cancel);
    self.cancelButton = button;
}

- (void)vvfc_menuNeedsUpdate:(NSMenu *)menu
{
    [self vvfc_menuNeedsUpdate:menu];
    
    __block BOOL canShowMenu = NO;
    NSIndexSet *indexSet = [[self outlineView] contextMenuSelectedRowIndexes];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        IDEVariablesViewNode *root = [[self outlineView] itemAtRow:idx];
        if ([root isKindOfClass:[IDEVariablesViewNode class]]) {
            canShowMenu = YES;
        }
    }];
    
    if (canShowMenu) {
        NSInteger copyItemIndex = NSNotFound;
        NSInteger fullCopyItemIndex = NSNotFound;
        
        for (NSMenuItem *item in menu.itemArray) {
            if ([NSStringFromSelector(item.action) isEqualToString:@"copy:"]) {
                copyItemIndex = [menu.itemArray indexOfObject:item];
            } else if ([NSStringFromSelector(item.action) isEqualToString:@"fullCopy"]) {
                fullCopyItemIndex = [menu.itemArray indexOfObject:item];
            }
        }
        
        if (fullCopyItemIndex == NSNotFound && copyItemIndex != NSNotFound) {
            [menu insertItemWithTitle:@"Full copy" action:@selector(fullCopy) keyEquivalent:@"" atIndex:copyItemIndex + 1];
        }
    }
}

- (NSString *)recursiveDescription:(DBGLLDBDataValue *)root depthPrefix:(NSString *)depthPrefix visitedValues:(NSMutableSet *)visitedValues
{
    if (self.isCancelled) {
        return nil;
    }
    [root _fetchSummaryFromLLDBOnSessionThreadIfNecessary];
    NSMutableString *description = [NSMutableString stringWithFormat:@"%@%@\t%@\t%@\t%@\n", depthPrefix, root.name, root.type, root.logicalValue, root.value];
    if (root && ![root representsNilObjectiveCObject] && ![root representsNullObjectPointer]) {
        if (!root.childValuesCountValid) {
            [root _fetchChildValuesFromLLDBOnSessionThreadIfNecessary];
            while (!root.childValuesCountValid) {
            }
        }
        BOOL visited = [visitedValues containsObject:root.value];
        if ([root.value length] == 0 || [root.logicalValue isEqualToString:@"0x0"] || !visited) {
            [visitedValues addObject:root.value];
            for (DBGLLDBDataValue *child in root.childValues) {
                NSString *childDescription = [self recursiveDescription:child depthPrefix:[depthPrefix stringByAppendingString:@"\t"] visitedValues:visitedValues];
                if (childDescription) {
                    [description appendString:childDescription];
                }
            }
        } else if (visited && [root.childValues count]) {
            [description appendFormat:@"%@\t[...]\n", depthPrefix];
        }
    }
    return [NSString stringWithString:description];
}

- (void)fullCopy
{
    NSIndexSet *indexSet = [[self outlineView] contextMenuSelectedRowIndexes];
    [[NSPasteboard generalPasteboard] clearContents];
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        IDEVariablesViewNode *root = [[self outlineView] itemAtRow:idx];
        if ([root isKindOfClass:[IDEVariablesViewNode class]]) {
            DBGLLDBDataValue *value = [root dataValue];
            DBGLLDBSession *session = [value _lldbSession];
            [self _showLoadingIndicatorIfNecessary];
            self.cancelButton.hidden = NO;
            self.cancelled = NO;
            [session addSessionThreadAction:^{
                NSMutableSet *visitedValues = [NSMutableSet set];
                NSString *description = [self recursiveDescription:root.dataValue depthPrefix:@"" visitedValues:visitedValues];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self _hideLoadingIndicatorIfNecessary];
                    self.cancelButton.hidden = YES;
                    [[NSPasteboard generalPasteboard] writeObjects:@[description]];
                });
            }];
        }
    }];
}

- (void)cancel
{
    self.cancelled = YES;
}

#pragma mark - Properties

- (NSButton *)cancelButton
{
    return objc_getAssociatedObject(self, @selector(cancelButton));
}

- (void)setCancelButton:(NSButton *)cancelButton
{
    objc_setAssociatedObject(self, @selector(cancelButton), cancelButton, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isCancelled
{
    return [objc_getAssociatedObject(self, @selector(isCancelled)) boolValue];
}

- (void)setCancelled:(BOOL)cancelled
{
    objc_setAssociatedObject(self, @selector(isCancelled), [NSNumber numberWithBool:cancelled], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
