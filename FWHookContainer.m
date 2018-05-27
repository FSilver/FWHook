//
//  FWHookContainer.m
//  FWModule
//
//  Created by silver on 2018/5/21.
//  Copyright © 2018年 FSilver. All rights reserved.
//

#import "FWHookContainer.h"

@implementation FWHookContainer

-(id)init
{
    self = [super init];
    if(self){
        _beforeArray = [NSMutableArray array];
        _insteadArray = [NSMutableArray array];
        _afterArray = [NSMutableArray array];
    }
    return self;
}


-(void)addHookItem:(FWHookItem*)item
{
    switch (item.option) {
        case FWHookOptionAfter:
        {
            [_afterArray addObject:item];
        }
            break;
        case FWHookOptionInstead:
        {
            [_insteadArray addObject:item];
        }
            break;
        case FWHookOptionBefore:
        {
            [_beforeArray addObject:item];
        }
            break;
            
        default:
            break;
    }
}


@end
