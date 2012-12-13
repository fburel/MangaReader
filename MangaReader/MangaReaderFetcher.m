//
//  MangaReaderFetcher.m
//  MangaReader
//
//  Created by florian BUREL on 12/12/12.
//  Copyright (c) 2012 florian BUREL. All rights reserved.
//

#import "MangaReaderFetcher.h"
#import "TFHpple.h"
#import "Manga.h"

#define kWebServiceURL @"http://www.mangareader.net/103/one-piece.html"

@implementation MangaReaderFetcher

+ (NSSet *) chaperList
{
    NSMutableArray * array = [NSMutableArray array];
    
    NSURL * webURL = [NSURL URLWithString:kWebServiceURL];
    
    NSData * chapterData = [NSData dataWithContentsOfURL:webURL];
    
    TFHpple * mangaParser = [TFHpple hppleWithHTMLData:chapterData];
    
    NSString  * mangaXPathQuery = @"//table[@id='listing']/tr/td/a";
    NSArray * chapterNode = [mangaParser searchWithXPathQuery:mangaXPathQuery];
    
//    TFHppleElement * table = [chapterNode lastObject];
    
    
    for (TFHppleElement *element in chapterNode)
    {
       
        Manga * manga = [[Manga alloc]init];
        
        manga.link = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.mangareader.net%@", [element objectForKey:@"href"]]];
        
        manga.title = [[element firstChild] content];
        
        [array addObject:manga];
        
        [manga release];
    }
    
    return [NSSet setWithArray:array];
    
    
}


@end
