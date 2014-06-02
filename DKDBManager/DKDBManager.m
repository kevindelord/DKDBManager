//
//  DKDBManager.m
//  WhiteWall
//
//  Created by kevin delord on 21/02/14.
//  Copyright (c) 2014 smartmobilefactory. All rights reserved.
//

#import "DKDBManager.h"

// models
//#import "xxx+Helpers.h"

// defines
//#import "xxHelpers.h"

/*
 
 How to use MagicalRecord :
 
 #1
 NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"title contains[cd] %@", query];
 NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"keywords contains[cd] %@", query];
 NSPredicate *predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[predicate1, predicate2]];
 NSArray *result = [Note findAllWithPredicate:predicate];
 
 #2
 NSArray *result = [Note findAllSortedBy:@"date" ascending:YES];
 
 #3
 NSFetchRequest *fr = [[NSFetchRequest alloc] init];
 NSEntityDescription *ed = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:[NSManagedObjectContext defaultContext]];
 [fr setEntity:ed];
 NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
 [fr setSortDescriptors:@[sd]];
 NSError *error = nil;
 NSArray *result = [[NSManagedObjectContext defaultContext] executeFetchRequest:fr error:&error];
 
 http://yannickloriot.com/2012/03/magicalrecord-how-to-make-programming-with-core-data-pleasant/#sthash.H89Qlrfm.tnJxdlS4.dpbs
 http://mobile.tutsplus.com/tutorials/iphone/easy-core-data-fetching-with-magical-record/
 
 */

static BOOL _allowUpdate = YES;
static BOOL _verbose = NO;
static BOOL _resetStoredEntities = NO;
static BOOL _needForcedUpdate = NO;

@interface DKDBManager () {
    NSMutableDictionary *   _entities;
    NSManagedObjectContext *_context;
}

@end

@implementation DKDBManager

#pragma mark - init method

- (id)init {
    self = [super init];
    if (self) {
        _entities = [NSMutableDictionary new];
        _context = nil;
    }
    return self;
}

#pragma mark - static methods

+ (instancetype)sharedInstance {
    static DKDBManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [DKDBManager new];
    });
    return manager;
}

#pragma mark - DB methods

//
// create an array of all identifiers for each entity
// In each entity don't forget to save the ID of each child relation.
// A saved child will be checked if deprecated and remove.
// It will also be removed if the parent is removed.
//
+ (void)saveId:(NSString *)id forEntity:(NSString *)entity {
    DKDBManager *manager = [DKDBManager sharedInstance];

    if (![manager->_entities objectForKey:entity])
        [manager->_entities setValue:[NSMutableArray new] forKey:entity];

    [[manager->_entities objectForKey:entity] addObject:id];
}

//
//
//
- (NSArray *)savedEntitiesForKey:(NSString *)key {
    return [_entities objectForKey:key];
}

//
// Remove deprecated entities.
// i.e: not stored in the manager anymore
//
+ (void)removeDeprecatedEntities {
// blabla child
}

//
// Save the current context
// This method should be called when minor changes have been done
// It does NOT clean the database, just save the new changes.
//
+ (void)save {
    [self saveToPersistentStoreWithCompletion:nil];
}

+ (void)saveToPersistentStoreWithCompletion:(void (^)(BOOL success, NSError *error))completionBlock {
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        [DKDBManager dump];
        if (completionBlock)
            completionBlock(success, error);
    }];
}

+ (void)saveToPersistentStoreAndWait {
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
}

//
// Setup the core data stack
// Reset it if needed.
//
+ (BOOL)setupDatabaseWithName:(NSString *)databaseName identifier:(NSString *)identifier forKey:(NSString *)storingKey {

    // Boolean to know if the database has been completely reset
    BOOL didResetDB = NO;

    // check if the DB's identifier has changed. If so erase the database and create a new one.
    NSString *storedIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:storingKey];
    BOOL newIdentifier = (storedIdentifier && ![storedIdentifier isEqualToString:identifier]);

    if (DKDBManager.resetStoredEntities || newIdentifier || !storedIdentifier) {
        // remove the sqlite file
        DKLog(DKDBManager.verbose, @"reset database: %@", K_DATABASE_NAME);
        // do some cleanUp of MagicalRecord
        [MagicalRecord cleanUp];
        NSError *error;
        // remove the sqlit file
        NSURL *fileURL = [NSPersistentStore MR_urlForStoreName:databaseName];
        [[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error];
        if (error && error.code != NSFileNoSuchFileError) {
            [[[UIAlertView alloc] initWithTitle:@"Error - cannot reset DB" message:error.localizedDescription delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil] show];
        }
        didResetDB = YES;
    }

    // save the current API base URL
    [[NSUserDefaults standardUserDefaults] setObject:identifier forKey:storingKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // setup the coredata stack
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:databaseName];

    return didResetDB;
}

#pragma mark - DEBUG methods

// verbose
+ (void)setVerbose:(BOOL)verbose {
    _verbose = verbose;
}

+ (BOOL)verbose {
    return _verbose;
}

// allow update
+ (BOOL)allowUpdate {
    return _allowUpdate;
}

+ (void)setAllowUpdate:(BOOL)allowUpdate {
    _allowUpdate = allowUpdate;
}

// reset stored entities
+ (BOOL)resetStoredEntities {
    return _resetStoredEntities;
}

+ (void)setResetStoredEntities:(BOOL)resetStoredEntities {
    _resetStoredEntities = resetStoredEntities;
}

// need forced update
+ (BOOL)needForcedUpdate {
    return _needForcedUpdate;
}

+ (void)setNeedForcedUpdate:(BOOL)needForcedUpdate {
    _needForcedUpdate = needForcedUpdate;
}

// log
+ (void)dump {
// blablabla child
}

@end
