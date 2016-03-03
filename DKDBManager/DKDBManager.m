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

@implementation DKDBManager

#pragma mark - init method

- (instancetype)init {
    self = [super init];
    if (self) {
        self.storedIdentifiers = [NSMutableDictionary new];
    }
    return self;
}

#pragma mark - DB methods

+ (instancetype _Nonnull)sharedInstance {
    static DKDBManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [DKDBManager new];
    });
    return manager;
}

+ (NSArray * _Nonnull)entityClassNames {
    NSMutableArray *classNames = [NSMutableArray new];
    for (NSEntityDescription *desc in [NSManagedObjectModel MR_defaultManagedObjectModel].entities) {
        if (desc.isAbstract == false) {
			NSString *className = desc.managedObjectClassName;
			[DKDBManager checkClassValidity:className];
			[classNames addObject:className];
        }
    }
    return classNames;
}

+ (void)setupDatabaseWithName:(NSString * _Nonnull)databaseName didResetDatabase:(void (^ _Nullable)())didResetDatabaseBlock {

	// Refresh current/default log level
	self.verbose = self.verbose;

	// Boolean to know if the database has been completely reset
	BOOL didResetDB = NO;
	if (DKDBManager.resetStoredEntities == true) {
		didResetDB = [self eraseDatabaseForStoreName:databaseName];
	}

	// Setup the coredata stack
	[self setupCoreDataStackWithAutoMigratingSqliteStoreNamed:databaseName];

	if (didResetDB == true && didResetDatabaseBlock != nil) {
		didResetDatabaseBlock();
	}

	// Check the validity of all model classes.
	NSArray *classes = self.entityClassNames;
	if (classes.count > 0) {
		CRUDLog(self.verbose, @"The datamodel contains the following classes: %@", classes);
	}
}

+ (void)setupDatabaseWithName:(NSString * _Nonnull)databaseName {
	[self setupDatabaseWithName:databaseName didResetDatabase:nil];
}

+ (void)setup {
	NSString * databaseName = [NSString stringWithFormat:@"%@.sqlite", NSBundle.mainBundle.infoDictionary[@"CFBundleIdentifier"]];
	[self setupDatabaseWithName:databaseName didResetDatabase:nil];
}

+ (void)cleanUp {
	[super cleanUp];

	DKDBManager *manager = [DKDBManager sharedInstance];
	manager.storedIdentifiers = [NSMutableDictionary new];
}

#pragma mark - DELETE

+ (BOOL)eraseDatabaseForStoreName:(NSString * _Nonnull)databaseName {

    CRUDLog(DKDBManager.verbose, @"------ Erasing database: %@ ------", databaseName);
    // do some MagicalRecord clean up
    [self cleanUp];

    // remove the sqlite file
    BOOL didResetDB = YES;
    NSError *error;
    NSURL *fileURL = [NSPersistentStore MR_urlForStoreName:databaseName];
    [[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error];
    if (error && error.code != NSFileNoSuchFileError) {
		NSAssert(false, @"Error - cannot erase DB");
        didResetDB = NO;
    }
    return didResetDB;
}

+ (void)removeDeprecatedEntitiesInContext:(NSManagedObjectContext * _Nonnull)context {
    DKDBManager *manager = [DKDBManager sharedInstance];

    CRUDLog(self.verbose, @"-------------- Removing deprecated entities -----------------");

    for (NSString *className in self.entityClassNames) {
        Class class = NSClassFromString(className);
        [class removeDeprecatedEntitiesFromArray:manager.storedIdentifiers[className] inContext:(NSManagedObjectContext * _Nonnull)context];
    }
}

+ (void)removeDeprecatedEntitiesInContext:(NSManagedObjectContext * _Nonnull)context forClass:(Class _Nonnull)class {
	DKDBManager *manager = [DKDBManager sharedInstance];

	CRUDLog(self.verbose, @"-------------- Removing deprecated entities for class -----------------");

	NSString *className = NSStringFromClass(class);
	[class removeDeprecatedEntitiesFromArray:manager.storedIdentifiers[className] inContext:(NSManagedObjectContext * _Nonnull)context];
}

+ (void)deleteAllEntitiesInContext:(NSManagedObjectContext * _Nonnull)context {
    for (NSString *className in self.entityClassNames) {
        Class class = NSClassFromString(className);
        [class deleteAllEntitiesInContext:context];
    }
    [self dumpInContext:context];
}

+ (void)removeAllStoredIdentifiers {

    DKDBManager *manager = [DKDBManager sharedInstance];

	[manager.storedIdentifiers removeAllObjects];
}

+ (void)removeAllStoredIdentifiersForClass:(Class _Nonnull)class {

	DKDBManager *manager = [DKDBManager sharedInstance];

	NSString *className = NSStringFromClass(class);
	[manager.storedIdentifiers removeObjectForKey:className];
}

+ (void)deleteAllEntitiesForClass:(Class)class inContext:(NSManagedObjectContext * _Nonnull)context {
    if ([self.entityClassNames containsObject:NSStringFromClass(class)]) {
		[class deleteAllEntitiesInContext:context];
    }
    [self dumpInContext:context];
}

#pragma mark - SAVE

+ (void)saveEntityAsNotDeprecated:(id _Nonnull)entity {

    DKDBManager *manager = [DKDBManager sharedInstance];

    NSString *className = NSStringFromClass([entity class]);

    if (!manager.storedIdentifiers[className]) {
        [manager.storedIdentifiers setValue:[NSMutableArray new] forKey:className];
    }

    if ([entity respondsToSelector:@selector(uniqueIdentifier)]) {
        [manager.storedIdentifiers[className] addObject:[entity performSelector:@selector(uniqueIdentifier)]];
    }
}

+ (void)saveWithBlock:(void(^ _Nullable )(NSManagedObjectContext * _Nonnull context))block {
    [super saveWithBlock:^(NSManagedObjectContext *savingContext) {
        if (block != nil) {
            block(savingContext);
        }
        [self dumpInContext:savingContext];
    }];
}

+ (void)saveWithBlock:(void(^ _Nullable)(NSManagedObjectContext * _Nonnull savingContext))block completion:(MRSaveCompletionHandler _Nullable)completion {
	[super saveWithBlock:^(NSManagedObjectContext *savingContext) {
		if (block != nil) {
			block(savingContext);
		}
		[self dumpInContext:savingContext];

	} completion:^(BOOL contextDidSave, NSError *error) {
        if (completion != nil) {
            completion(contextDidSave, error);
        }
    }];
}

+ (void)saveWithBlockAndWait:(void(^ _Nullable)(NSManagedObjectContext * _Nonnull savingContext))block {
    [super saveWithBlockAndWait:^(NSManagedObjectContext *savingContext) {
        if (block != nil) {
            block(savingContext);
        }
        [self dumpInContext:savingContext];
    }];
}

#pragma mark - DEBUG methods

// verbose
+ (void)setVerbose:(BOOL)verbose {
    _verbose = verbose;

    NSUInteger logLevel = MagicalRecordLoggingLevelOff;
    if (_verbose == true) {
#ifdef DEBUG
        logLevel = MagicalRecordLoggingLevelDebug;
#else
        logLevel = MagicalRecordLoggingLevelError;
#endif
    }
    [MagicalRecord setLoggingLevel:logLevel];
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

+ (void)dumpCountInContext:(NSManagedObjectContext * _Nonnull)context {

	if (self.verbose == false) {
		return ;
	}

	NSString *count = @"";

	for (NSString *className in self.entityClassNames) {
		Class class = NSClassFromString(className);
		unsigned long value = (unsigned long)[class performSelector:@selector(countInContext:) withObject:context];
		count = [NSString stringWithFormat:@"%@%ld %@, ", count, value, className];
	}

	if ([count isEqualToString:@""] == false) {
		CRUDLog(self.verbose, @"-------------------------------------");
		CRUDLog(self.verbose, @"%@", count);
		CRUDLog(self.verbose, @"-------------------------------------");
	}
}

+ (void)dumpCount {
	[self dumpInContext:NSManagedObjectContext.MR_defaultContext];
}

+ (void)dumpInContext:(NSManagedObjectContext * _Nonnull)context {

	if (self.verbose == false) {
		return ;
	}

	[self dumpCountInContext:context];

	for (NSString *className in self.entityClassNames) {
		Class class = NSClassFromString(className);
		BOOL didLogSomething = false;
		if (class.verbose == true) {
			NSArray * allValues = (NSArray *)[class performSelector:@selector(allInContext:) withObject:context];
			if (allValues != nil) {
				for (id entity in allValues) {
					NSLog(@"%@ %@", className, entity);
					didLogSomething = true;
				}
			}
		}
		CRUDLog((self.verbose && didLogSomething == true), @"-------------------------------------");
	}
}

+ (void)dump {
	[self dumpInContext:NSManagedObjectContext.MR_defaultContext];
}

#pragma mark - Log

+ (void)checkClassValidity:(NSString *)className {
	if ([className isEqualToString:NSStringFromClass([NSManagedObject class])] == true) {
		NSAssert(false, @"ERROR: Invalid Datamodel: One of the model class in the datamodel is not configure as a custom class but as a default NSManagedObject one.");
	}
}

@end
