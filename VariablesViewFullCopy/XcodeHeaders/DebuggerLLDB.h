//
//  DebuggerLLDB.h
//  VariablesViewFullCopy
//
//  Created by Fabio Ritrovato on 23/08/2015.
//  Copyright (c) 2015 orange in a day. All rights reserved.
//

@interface DBGLLDBSession : NSObject

- (void)addSessionThreadAction:(void(^)())arg1;

@end

@interface DBGDataValue : NSObject

@property(readonly, copy) NSString *type;
@property(copy) NSString *value;
@property(readonly, copy) NSString *logicalValue;

@end

@interface DBGLLDBDataValue : DBGDataValue

@property(copy, nonatomic) NSString *name;

@property(retain, nonatomic) NSArray *childValues;
@property BOOL childValuesCountValid;

- (void)_fetchSummaryFromLLDBOnSessionThreadIfNecessary;
- (void)_fetchChildValuesFromLLDBOnSessionThreadIfNecessary;
- (id)_lldbSession;
- (BOOL)representsNullObjectPointer;
- (BOOL)representsNilObjectiveCObject;
- (id)value;

@end