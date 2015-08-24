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

@implementation IDEVariablesView (VariablesViewFullCopy)

+ (void)load
{
    [self jr_swizzleMethod:@selector(menuNeedsUpdate:) withMethod:@selector(vvfc_menuNeedsUpdate:) error:NULL];
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

- (NSString *)recursiveDescription:(IDEVariablesViewNode *)root depthPrefix:(NSString *)depthPrefix visitedValues:(NSMutableSet *)visitedValues
{
    DBGLLDBDataValue *dataValue = [root dataValue];
    [dataValue _fetchSummaryFromLLDBOnSessionThreadIfNecessary];
    NSMutableString *description = [NSMutableString stringWithFormat:@"%@%@\n", depthPrefix, [root pasteboardPropertyListForType:NSPasteboardTypeString]];
    if (![dataValue representsNilObjectiveCObject] && ![dataValue representsNullObjectPointer]) {
        NSString *value = [[root dataValue] value];
        if (!dataValue.childValuesCountValid) {
            for (DBGLLDBDataValue *child in [[root dataValue] childValues]) {
                if (child.isValid) {
                    [child invalidate];
                }
            }
            [[root dataValue] _setChildValuesToArrayOfActualChildren];
        }
        BOOL visited = [visitedValues containsObject:value];
        if ([value length] == 0 || [dataValue.logicalValue isEqualToString:@"0x0"] || !visited) {
            [visitedValues addObject:[[root dataValue] value]];
            for (IDEVariablesViewNode *child in root.children) {
                [description appendString:[self recursiveDescription:child depthPrefix:[depthPrefix stringByAppendingString:@"\t"] visitedValues:visitedValues]];
            }
        } else if (visited && [root.children count]) {
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
            [session addSessionThreadAction:^{
                NSMutableSet *visitedValues = [NSMutableSet set];
                NSString *description = [self recursiveDescription:root depthPrefix:@"" visitedValues:visitedValues];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self _hideLoadingIndicatorIfNecessary];
                    [[NSPasteboard generalPasteboard] writeObjects:@[description]];
                });
            }];
        }
    }];
}

@end
