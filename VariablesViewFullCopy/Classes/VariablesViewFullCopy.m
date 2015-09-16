//
//  VariablesViewFullCopy.m
//  VariablesViewFullCopy
//
//  Created by Fabio Ritrovato on 20/08/2015.
//  Copyright (c) 2015 orange in a day. All rights reserved.
//

#import "VariablesViewFullCopy.h"
#import "DVTFoundation.h"

NSString * const VariablesViewFullCopyNewVersionNotification = @"VariablesViewFullCopyNewVersionNotification";

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
        NSString *currentVersion = [plugin objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSString *lastVersion = [[NSUserDefaults standardUserDefaults] stringForKey:@"VariablesViewFullCopyLastVersion"];
        if (lastVersion == nil || [lastVersion compare:currentVersion options:NSNumericSearch] == NSOrderedDescending) {
            NSUserNotification *notification = [NSUserNotification new];
            notification.title = [NSString stringWithFormat:@"VariablesViewFullCopy updated to %@", currentVersion];
            notification.informativeText = @"View release notes";
            notification.userInfo = @{VariablesViewFullCopyNewVersionNotification: @(YES)};
            notification.actionButtonTitle = @"View";
            [notification setValue:@YES forKey:@"_showsButtons"];
            
            [[DVTUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
            
            [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:@"VariablesViewFullCopyLastVersion"];
        }
    }
    return self;
}

@end
