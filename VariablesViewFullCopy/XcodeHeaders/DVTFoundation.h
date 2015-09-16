//
//  DVTFoundation.h
//  VariablesViewFullCopy
//
//  Created by Fabio on 18/09/2015.
//  Copyright © 2015 orange in a day. All rights reserved.
//

@interface DVTUserNotificationCenter : NSObject <NSUserNotificationCenterDelegate>

+ (id)defaultUserNotificationCenter;
- (void)deliverNotification:(id)arg1;

@end
