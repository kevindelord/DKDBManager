//
//  DKDBManager.m
//  WhiteWall
//
//  Created by kevin delord on 21/02/14.
//  Copyright (c) 2014 Kevin Delord. All rights reserved.
//

#import "DKDBManager.h"

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

 + (NSUInteger)count {
     return 0;
 }

 + (NSArray *)all {
     return nil;
 }

+ (NSArray *)entities {
    return nil;
}

+ (void)cleanUp {
    [MagicalRecord cleanUp];
}

#pragma mark - Delete methods

+ (void)removeDeprecatedEntities {
    DKDBManager *manager = [DKDBManager sharedInstance];

    DKLog(self.verbose, @"-------------- Removing deprecated entities -----------------");

    for (NSString *className in self.entities) {
        Class class = NSClassFromString(className);
        [class removeDeprecatedEntitiesFromArray:[manager->_entities objectForKey:className]];
    }
}

#pragma mark - Save methods

+ (void)saveEntity:(id)entity {

    DKDBManager *manager = [DKDBManager sharedInstance];

    NSString *className = NSStringFromClass([entity class]);

    if (![manager->_entities objectForKey:className]) {
        [manager->_entities setValue:[NSMutableArray new] forKey:className];
    }

    if ([entity respondsToSelector:@selector(uniqueIdentifier)]) {
        [[manager->_entities objectForKey:className] addObject:[entity performSelector:@selector(uniqueIdentifier)]];
    }
}

+ (void)save {
    [self saveToPersistentStoreWithCompletion:nil];
}

+ (void)saveToPersistentStoreWithCompletion:(void (^)(BOOL success, NSError *error))completionBlock {
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (self.verbose)
            [self dump];
        if (completionBlock)
            completionBlock(success, error);
    }];
}

+ (void)saveToPersistentStoreAndWait {
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
    if (self.verbose)
        [self dump];
}

#pragma mark - Setup

+ (BOOL)setupDatabaseWithName:(NSString *)databaseName identifier:(NSString *)identifier forKey:(NSString *)storingKey {

    // Boolean to know if the database has been completely reset
    BOOL didResetDB = NO;

    // check if the DB's identifier has changed. If so erase the database and create a new one.
    NSString *storedIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:storingKey];
    BOOL newIdentifier = (storedIdentifier && ![storedIdentifier isEqualToString:identifier]);

    if (DKDBManager.resetStoredEntities || newIdentifier || !storedIdentifier) {
        // remove the sqlite file
        DKLog(DKDBManager.verbose, @"reset database: %@", databaseName);
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

#pragma mark - Log

+ (void)dumpCount {

    if (!self.verbose) return ;

    NSString *count = @"";

    for (NSString *className in self.entities) {
        Class class = NSClassFromString(className);
        count = [NSString stringWithFormat:@"%@%ld %@, ", count, cUL(class.count), className];
    }

    DKLog(self.verbose, @"-------------------------------------");
    DKLog(self.verbose, @"%@", count);
    DKLog(self.verbose, @"-------------------------------------");
}

+ (void)dump {

    if (!self.verbose) return ;

    [self dumpCount];

    for (NSString *className in self.entities) {
        Class class = NSClassFromString(className);
        if (class.verbose) {
            for (id entity in class.all)
                NSLog(@"%@ %@", className, entity);
            DKLog(self.verbose, @"-------------------------------------");
        }
    }
}

@end
