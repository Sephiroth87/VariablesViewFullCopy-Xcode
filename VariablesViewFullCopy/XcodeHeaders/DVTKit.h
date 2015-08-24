//
//  DVTKit.h
//  VariablesViewFullCopy
//
//  Created by Fabio Ritrovato on 20/08/2015.
//  Copyright (c) 2015 orange in a day. All rights reserved.
//

@protocol DVTInvalidation <NSObject>

@property(readonly, nonatomic, getter=isValid) BOOL valid;
- (void)invalidate;

@end

@interface DVTOutlineView: NSOutlineView

@property(readonly) NSIndexSet *contextMenuSelectedRowIndexes;

@end
