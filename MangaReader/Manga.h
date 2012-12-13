//
//  Manga.h
//  MangaReader
//
//  Created by florian BUREL on 13/12/12.
//  Copyright (c) 2012 florian BUREL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Manga : NSObject

@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString *subTitle;
@property (nonatomic, strong) NSURL * link;
@property (nonatomic, strong) NSArray * imagesData;

@end
