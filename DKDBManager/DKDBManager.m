//
//  DKDBManager.m
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

#pragma mark - DB methods

+ (instancetype)sharedInstance {
    static DKDBManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [DKDBManager new];
    });
    return manager;
}

+ (NSArray *)entities {
    NSDictionary * dict = [NSManagedObjectModel MR_defaultManagedObjectModel].entitiesByName;
    return dict.allKeys;
}

+ (NSUInteger)count {
    // This method is needed to make the compiler understands this method exists for the NSManagedObject classes.
    // See: DKDBManager::dump and DKDBManager::dumpCount
    return 0;
}

+ (NSArray *)all {
    // This method is needed to make the compiler understands this method exists for the NSManagedObject classes.
    // See: DKDBManager::dump and DKDBManager::dumpCount
    return nil;
}

+ (void)cleanUp {
    [MagicalRecord cleanUp];
}

+ (BOOL)setupDatabaseWithName:(NSString *)databaseName {

    // Boolean to know if the database has been completely reset
    BOOL didResetDB = NO;
    if (DKDBManager.resetStoredEntities) {
        didResetDB = [self eraseDatabaseForStoreName:databaseName];
    }

    // setup the coredata stack
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:databaseName];

    return didResetDB;
}

#pragma mark - Delete methods

+ (BOOL)eraseDatabaseForStoreName:(NSString *)databaseName {

    DKLog(DKDBManager.verbose, @"erase database: %@", databaseName);
    // do some cleanUp of MagicalRecord
    [self cleanUp];

    // remove the sqlite file
    BOOL didResetDB = YES;
    NSError *error;
    NSURL *fileURL = [NSPersistentStore MR_urlForStoreName:databaseName];
    [[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error];
    if (error && error.code != NSFileNoSuchFileError) {
        [[[UIAlertView alloc] initWithTitle:@"Error - cannot erase DB" message:error.localizedDescription delegate:nil cancelButtonTitle:nil otherButtonTitles:@"ok", nil] show];
        didResetDB = NO;
    }
    return didResetDB;
}

+ (void)removeDeprecatedEntities {
    DKDBManager *manager = [DKDBManager sharedInstance];

    DKLog(self.verbose, @"-------------- Removing deprecated entities -----------------");

    for (NSString *className in self.entities) {
        Class class = NSClassFromString(className);
        [class removeDeprecatedEntitiesFromArray:[manager->_entities objectForKey:className]];
    }
}

+ (void)deleteAllEntities {
    for (NSString *className in self.entities) {
        Class class = NSClassFromString(className);
        [class deleteAllEntities];
    }
}

+ (void)deleteAllEntitiesForClass:(Class)class {
    if ([self.entities containsObject:NSStringFromClass(class)]){
        [class deleteAllEntities];
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
