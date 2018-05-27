//
//  FWHookItem.h
//  FWModule
//
//  Created by silver on 2018/5/21.
//  Copyright © 2018年 FSilver. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    FWHookOptionBefore = 0,
    FWHookOptionInstead = 1,
    FWHookOptionAfter = 2,
} FWHookOption;


@interface FWHookItem : NSObject

@property (nonatomic, weak) id object;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, assign) FWHookOption option;
@property (nonatomic, strong) id block;
@property (nonatomic, strong) NSMethodSignature *blockSignature;

+(instancetype)itemWithObject:(id)object selector:(SEL)selector option:(FWHookOption)option block:(id)block;

/*
 方法调用
 */
-(void)invokeWithParams:(NSArray*)params;

@end
