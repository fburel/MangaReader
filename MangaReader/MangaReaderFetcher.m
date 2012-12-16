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

#define kWebServiceURL @"http://www.mangareader.net/"

const NSString * kMangaURLDictionaryURLKey = @"kMangaURLDictionaryURLKey";
const NSString * kMangaURLDictionaryDescriptionKey = @"kMangaURLDictionaryDescriptionKey";

@implementation MangaReaderFetcher

+ (NSSet *) chaperListForMangaURL:(NSURL *)mangaMainPageURL
{
 
    mangaMainPageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@103/one-piece.html", kWebServiceURL]];
    
    NSMutableArray * chapterListURL = [NSMutableArray array];
    
    // Parsing
    TFHpple * mangaParser = [TFHpple hppleWithHTMLData:[NSData dataWithContentsOfURL:mangaMainPageURL]];
    
    NSString  * mangaXPathQuery = @"//table[@id='listing']/tr/td/a";
    NSArray * chapterNode = [mangaParser searchWithXPathQuery:mangaXPathQuery];
        
    for (TFHppleElement *element in chapterNode)
    {
       
        NSString * mangaURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.mangareader.net%@", [element objectForKey:@"href"]]];
        
        NSString * description = [[element firstChild] content];
        
        
        NSDictionary * dic = @{kMangaURLDictionaryURLKey : mangaURL, kMangaURLDictionaryDescriptionKey : description};
        [chapterListURL addObject:dic];
    }
    
    return [NSSet setWithArray:chapterListURL];
    
    
}


+ (NSArray *) imagesURLFromMainPage:(NSURL *)mangaURL;
{
    NSData * mangaData = [NSData dataWithContentsOfURL:mangaURL];
    
    TFHpple * mangaParser = [TFHpple hppleWithHTMLData:mangaData];

    NSString  * mangaXPathQuery = @"//select[@id='pageMenu']";
    NSArray * chapterNode = [mangaParser searchWithXPathQuery:mangaXPathQuery];
    
    TFHppleElement *node = [chapterNode lastObject];
    
    NSMutableArray * urls = [NSMutableArray array];
    
    for (TFHppleElement *element in [node children])
    {
        
        NSString * stringURL = [NSString stringWithFormat:@"http://www.mangareader.net%@", [element objectForKey:@"value"]];
        
        
        [urls addObject:[NSURL URLWithString:stringURL]];
    }

    NSMutableArray * datas = [NSMutableArray array];
    
    for (NSURL * url in urls)
    {
        NSLog(@"%@", url);
        
        NSData * imagePageData = [NSData dataWithContentsOfURL:url];
        
        TFHpple * imagePageParser = [TFHpple hppleWithHTMLData:imagePageData];
        
        NSString  * xPath = @"//div[@id='imgholder']/a";
        
        NSArray * imagesInfo = [imagePageParser searchWithXPathQuery:xPath];
        
        TFHppleElement * imageElement = [imagesInfo lastObject];
        
        NSLog(@"%@", [[imageElement firstChild]objectForKey:@"src"]);

        [datas addObject:[NSURL URLWithString:[[imageElement firstChild]objectForKey:@"src"]]];
    }
    
    return datas;
}

@end
