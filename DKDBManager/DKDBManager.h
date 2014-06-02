//
//  DKDBManager.h
//  WhiteWall
//
//  Created by kevin delord on 21/02/14.
//  Copyright (c) 2014 smartmobilefactory. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSManagedObject+DKDBManager.h"

@interface DKDBManager : NSObject

#pragma mark - DEBUG

// verbose
+ (BOOL)verbose;
+ (void)setVerbose:(BOOL)verbose;

// force update
+ (BOOL)allowUpdate;
+ (void)setAllowUpdate:(BOOL)allowUpdate;

// reset stored entities
+ (BOOL)resetStoredEntities;
+ (void)setResetStoredEntities:(BOOL)resetStoredEntities;

// need forced update
+ (BOOL)needForcedUpdate;
+ (void)setNeedForcedUpdate:(BOOL)needForcedUpdate;

// log
+ (void)dump;

#pragma mark - DB methods

+ (instancetype)sharedInstance;

+ (void)save;
+ (void)saveToPersistentStoreAndWait;
+ (void)saveToPersistentStoreWithCompletion:(void (^)(BOOL success, NSError *error))completionBlock;

+ (BOOL)setupDatabaseWithName:(NSString *)databaseName identifier:(NSString *)identifier forKey:(NSString *)storingKey;
+ (void)removeDeprecatedEntities;
+ (void)saveId:(NSString *)id forEntity:(NSString *)entity;
- (NSArray *)savedEntitiesForKey:(NSString *)key;

@end
