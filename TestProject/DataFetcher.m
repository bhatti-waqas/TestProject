//
//  DataFetcher.m
//  TestProject
//
//  Created by Waqas Bhatti on 11/7/14.
//  Copyright (c) 2014 Muhammad Zubair. All rights reserved.
//

#import "DataFetcher.h"

@implementation DataFetcher


+(DataFetcher *)sharedFetcher
{
    static DataFetcher *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[self alloc] init];
        
    });
    return sharedInstance;
}
-(id)init
{
    if (self = [super init]) {
        
        
    }
    return self;
}
-(NSArray *)fetchListMatchingKeyWord
{
    
    return nil;
}
@end
