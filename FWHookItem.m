//
//  FWHookItem.m
//  FWModule
//
//  Created by silver on 2018/5/21.
//  Copyright © 2018年 FSilver. All rights reserved.
//

#import "FWHookItem.h"

static NSMethodSignature *aspect_blockMethodSignature(id block, NSError **error);


@implementation FWHookItem

+(instancetype)itemWithObject:(id)object selector:(SEL)selector option:(FWHookOption)option block:(id)block
{
    NSMethodSignature *blockSignature = aspect_blockMethodSignature(block,NULL);
    FWHookItem *item = nil;
    if(blockSignature){
        item = [[FWHookItem alloc]init];
        item.object = object;
        item.selector = selector;
        item.option = option;
        item.block = block;
        item.blockSignature = blockSignature;
    }
    return item;
}

-(void)invokeWithParams:(NSArray*)params
{
    NSInvocation *blockInvocation  = [NSInvocation invocationWithMethodSignature:self.blockSignature];
    NSUInteger numberOfArguments = self.blockSignature.numberOfArguments;
    if (numberOfArguments > 1) {
        [blockInvocation setArgument:&params atIndex:1];
    }
    [blockInvocation invokeWithTarget:self.block];
}

@end


#pragma mark - block 签名

typedef NS_OPTIONS(int, AspectBlockFlags) {
    AspectBlockFlagsHasCopyDisposeHelpers = (1 << 25),
    AspectBlockFlagsHasSignature          = (1 << 30)
};

typedef struct _AspectBlock {
    __unused Class isa;
    AspectBlockFlags flags;
    __unused int reserved;
    void (__unused *invoke)(struct _AspectBlock *block, ...);
    struct {
        unsigned long int reserved;
        unsigned long int size;
        // requires AspectBlockFlagsHasCopyDisposeHelpers
        void (*copy)(void *dst, const void *src);
        void (*dispose)(const void *);
        // requires AspectBlockFlagsHasSignature
        const char *signature;
        const char *layout;
    } *descriptor;
    // imported variables
} *AspectBlockRef;


static NSMethodSignature *aspect_blockMethodSignature(id block, NSError **error) {
    AspectBlockRef layout = (__bridge void *)block;
    if (!(layout->flags & AspectBlockFlagsHasSignature)) {
        NSString *description = [NSString stringWithFormat:@"The block %@ doesn't contain a type signature.", block];
        return nil;
    }
    void *desc = layout->descriptor;
    desc += 2 * sizeof(unsigned long int);
    if (layout->flags & AspectBlockFlagsHasCopyDisposeHelpers) {
        desc += 2 * sizeof(void *);
    }
    if (!desc) {
        NSString *description = [NSString stringWithFormat:@"The block %@ doesn't has a type signature.", block];
        return nil;
    }
    const char *signature = (*(const char **)desc);
    return [NSMethodSignature signatureWithObjCTypes:signature];
}
