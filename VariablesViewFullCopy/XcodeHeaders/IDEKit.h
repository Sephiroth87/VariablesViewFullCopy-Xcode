//
//  IDEKit.h
//  VariablesViewFullCopy
//
//  Created by Fabio Ritrovato on 20/08/2015.
//  Copyright (c) 2015 orange in a day. All rights reserved.
//

@class DVTOutlineView;

@interface IDEVariablesView : NSViewController

@property __weak NSProgressIndicator *loadingIndicator;
@property(retain) DVTOutlineView *outlineView;

- (void)menuNeedsUpdate:(id)arg1;
- (void)_hideLoadingIndicatorIfNecessary;
- (void)_showLoadingIndicatorIfNecessary;

@end

@interface IDEVariablesViewNode : NSObject

@property(readonly) id dataValue;

@end
