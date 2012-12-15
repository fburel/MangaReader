//
//  MangaReaderFetcher.h
//  MangaReader
//
//  Created by florian BUREL on 12/12/12.
//  Copyright (c) 2012 florian BUREL. All rights reserved.
//

#import <Foundation/Foundation.h>

const NSString * kMangaURLDictionaryURLKey;
const NSString * kMangaURLDictionaryDescriptionKey;

@interface MangaReaderFetcher : NSObject

// Retourne une NSSet de NSDictionnary correspondant aux chapitres disponibles
+ (NSSet *) chaperListForMangaURL:(NSURL *)mangaMainPageURL;


// Retourne la liste des URL pour les images d'un chapitre donnée
+ (NSArray *) imagesURLFromMainPage:(NSURL *)mangaURL;

@end
