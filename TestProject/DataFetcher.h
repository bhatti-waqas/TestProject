//
//  DataFetcher.h
//  TestProject
//
//  Created by Waqas Bhatti on 11/7/14.
//  Copyright (c) 2014 Muhammad Zubair. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataFetcher : NSObject

+(DataFetcher *)sharedFetcher;

-(NSArray *)fetchListMatchingKeyWord;
@end
