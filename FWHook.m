//
//  FWHook.m
//  FWModule
//
//  Created by silver on 2018/5/21.
//  Copyright © 2018年 FSilver. All rights reserved.
//

#import "FWHook.h"
#import "FWHookContainer.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NSInvocation+FWArguments.h"

static SEL alias_selector(SEL selector);
static void FWHook_forwardInvocation (NSObject * self ,SEL selector ,NSInvocation *invocation);

@implementation NSObject (FWHook)



+(void)hookSelector:(SEL)selector withOption:(FWHookOption)option usingBlock:(ParamsBlock)block
{
    fwHook(self, selector, option, block);
}

/*
 原理：
 1 创建子类，isa混写，把self 指向子类
 2 替换子类的 forwardInvocation成 FWHook_forwardInvocation，FWHook_forwardInvocation为核心实现
 3 originSelector 实现保存在 alias_selector中
 4 originSelecotr 替换成 _objc_msgForward ，目的是当调用originSelector时，直接出发消息转发，调用FWHook_forwardInvocation。
 5 在FWHook_forwardInvocation中，执行前，alias_selector，后方法
 
 */
-(void)hookSelector:(SEL)selector withOption:(FWHookOption)option usingBlock:(ParamsBlock)block
{
    NSAssert(selector, @"selector 为空"); //条件不成立，就会崩溃，打印原因
    NSAssert(block, @"block 为空");
    fwHook(self, selector, option, block);
}

static void fwHook(id self, SEL selector, FWHookOption option, ParamsBlock block)
{
    //1: 存储相关信息
    FWHookItem *item = [FWHookItem itemWithObject:self selector:selector option:option block:block];
    FWHookContainer *container = [self getContainerForKey:selector];
    [container addHookItem:item];
    
    //2: 创建子类
    Class baseClass = object_getClass(self);
    NSString *className = NSStringFromClass(baseClass);
    
    if(class_isMetaClass(baseClass)){
        NSLog(@"是: 元类 %@",className);
        
    }else{
        NSLog(@"不是: 元类 %@",className);
    }
    
    Class subClass;
    if(![className hasPrefix:@"FWHook_"]){
        const char *subclassName = [@"FWHook_" stringByAppendingString:className].UTF8String;
        Class subClass = objc_getClass(subclassName);
        if(subClass == nil){
            subClass = objc_allocateClassPair(baseClass, subclassName, 0);
            objc_registerClassPair(subClass);
            NSLog(@" class not exist : %@",className);
        }
        //Sets the class of an object. 关键步骤，isa_swwizzle混写技术
        object_setClass(self, subClass);
        NSLog(@"create new class : %@",className);
    }else{
        subClass = baseClass;
    }
    
    //3: 子类的forwardInvocation： 替换成FWHook_forwardInvocation
    class_replaceMethod(subClass, @selector(forwardInvocation:), (IMP)FWHook_forwardInvocation, "v@:@");
    
    //4: 将selector的实现加到 alias_selecotr上
    Method targetMethod = class_getInstanceMethod(subClass, selector);
    const char *typeEncoding = method_getTypeEncoding(targetMethod);
    SEL aliasSelector = alias_selector(selector);
    if (![subClass instancesRespondToSelector:aliasSelector]) {
        class_addMethod(subClass, aliasSelector, method_getImplementation(targetMethod), typeEncoding);
    }
    
    //5:将selecotor替换成 _objc_msgForward
    class_replaceMethod(subClass, selector, _objc_msgForward, typeEncoding);
}


-(FWHookContainer*)getContainerForKey:(SEL)selector
{
    SEL aliasSelector = alias_selector(selector);
    FWHookContainer *container = objc_getAssociatedObject(self, aliasSelector);
    if(!container){
        container =  [[FWHookContainer alloc]init];
        objc_setAssociatedObject(self, aliasSelector, container, OBJC_ASSOCIATION_RETAIN);
    }
    return container;
}

@end


//selector 作为关联对象的key，有可能被占用了。加个前缀更加的安全
static SEL alias_selector(SEL selector)
{
    NSString *selStr = NSStringFromSelector(selector);
    NSString *fullName = [@"FWHook_" stringByAppendingFormat:@"%@",selStr];
    return NSSelectorFromString(fullName);
}


static void FWHook_forwardInvocation (NSObject * self ,SEL selector ,NSInvocation *invocation)
{
    
    NSArray *array = [invocation getParams];
    //这里如果不替换，成aliasSelector，而调用invoke，就会调用_objc_msgForward，调用FWHook_forwardInvocation，死循环。
    SEL aliasSelector = alias_selector(invocation.selector);
    invocation.selector = aliasSelector;
    
    
    FWHookContainer *container = objc_getAssociatedObject(self, aliasSelector);
    
    for (FWHookItem *item in container.beforeArray) {
        [item invokeWithParams:array];
    }
    
    if(container.insteadArray.count == 0){
        //调用原来的方法
        [invocation invoke];
    }else{
        for (FWHookItem *item in container.insteadArray) {
            [item invokeWithParams:array];
        }
    }
    
    for (FWHookItem *item in container.afterArray) {
        [item invokeWithParams:array];
    }
}
