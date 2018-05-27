//
//  FWHookContainer.h
//  FWModule
//
//  Created by silver on 2018/5/21.
//  Copyright © 2018年 FSilver. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FWHookItem.h"

@interface FWHookContainer : NSObject

@property(nonatomic,readonly)NSMutableArray<FWHookItem*> *beforeArray;
@property(nonatomic,readonly)NSMutableArray<FWHookItem*> *insteadArray;
@property(nonatomic,readonly)NSMutableArray<FWHookItem*> *afterArray;

-(void)addHookItem:(FWHookItem*)item;

@end
