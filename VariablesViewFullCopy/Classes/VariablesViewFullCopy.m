//
//  VariablesViewFullCopy.m
//  VariablesViewFullCopy
//
//  Created by Fabio Ritrovato on 20/08/2015.
//  Copyright (c) 2015 orange in a day. All rights reserved.
//

#import "VariablesViewFullCopy.h"

@interface VariablesViewFullCopy()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@end

@implementation VariablesViewFullCopy

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[VariablesViewFullCopy alloc] initWithBundle:plugin];
        });
    }
}

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        self.bundle = plugin;
    }
    return self;
}

@end
