//
//  Page.h
//  MangaReader
//
//  Created by florian BUREL on 26/12/12.
//  Copyright (c) 2012 florian BUREL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Page : NSManagedObject

@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSString * serverURL;
@property (nonatomic, retain) NSString * localURL;
@property (nonatomic, retain) NSManagedObject *chapter;

@end
