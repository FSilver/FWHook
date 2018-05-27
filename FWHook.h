//
//  FWHook.h
//  FWModule
//
//  Created by silver on 2018/5/21.
//  Copyright © 2018年 FSilver. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FWHookItem.h"

typedef void (^ParamsBlock)(NSArray *params);

@interface NSObject (FWHook)

/*
 selector : 需要监听的方法
 option ： 决定 block 执行时机,在selector的之前，之后，替代。 
 block ：执行的代码块 返回的params就是，selector中的参数
 */
-(void)hookSelector:(SEL)selector withOption:(FWHookOption)option usingBlock:(ParamsBlock)block;
+(void)hookSelector:(SEL)selector withOption:(FWHookOption)option usingBlock:(ParamsBlock)block;


@end
