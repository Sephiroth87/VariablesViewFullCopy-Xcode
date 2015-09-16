//
//  VariablesViewFullCopy.h
//  VariablesViewFullCopy
//
//  Created by Fabio Ritrovato on 20/08/2015.
//  Copyright (c) 2015 orange in a day. All rights reserved.
//

#import <AppKit/AppKit.h>

extern NSString * const VariablesViewFullCopyNewVersionNotification;

@class VariablesViewFullCopy;

static VariablesViewFullCopy *sharedPlugin;

@interface VariablesViewFullCopy : NSObject

@property (nonatomic, strong, readonly) NSBundle* bundle;

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;


@end