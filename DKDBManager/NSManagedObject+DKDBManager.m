//
//  NSManagedObject+DKDBManager.m
//
//  Created by kevin delord on 20/05/14.
//  Copyright (c) 2014 Kevin Delord. All rights reserved.
//

#import "NSManagedObject+DKDBManager.h"

void        CRUDLog(BOOL logEnabled, NSString * _Nonnull format, ...) {
#if defined (DEBUG)
    if (logEnabled == true) {
        va_list args;
        va_start(args, format);
        NSString *content = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);
        NSLog(@"%@", content);
    }
#else
    // do nothing
#endif
}

@implementation NSManagedObject (DKDBManager)

#pragma mark - CREATE

+ (instancetype _Nullable)createEntityInContext:(NSManagedObjectContext * _Nonnull)savingContext {
	return [self createEntityFromDictionary:NSDictionary.new inContext:savingContext completion:nil];
}

+ (instancetype _Nullable)createEntityFromDictionary:(NSDictionary * _Nullable)dictionary inContext:(NSManagedObjectContext * _Nonnull)savingContext {
    return [self createEntityFromDictionary:dictionary inContext:savingContext completion:nil];
}

+ (instancetype _Nullable)createEntityFromDictionary:(NSDictionary * _Nullable)dictionary inContext:(NSManagedObjectContext * _Nonnull)savingContext completion:(void (^ _Nullable)(id _Nullable entity, DKDBManagedObjectState status))completion {

    // now create, save or update an entity
    DKDBManagedObjectState status = DKDBManagedObjectStateSave;

    // If the entity already exist then update it
	id entity = [self MR_findFirstWithPredicate:[self primaryPredicateWithDictionary:dictionary] inContext:savingContext];
    // Else create a new entity in the given context.
    if (entity == nil) {
		entity = [self MR_createEntityInContext:savingContext];
        [entity updateWithDictionary:dictionary inContext:savingContext];
        status = DKDBManagedObjectStateCreate;
    } else if (DKDBManager.needForcedUpdate || (DKDBManager.allowUpdate && [entity shouldUpdateEntityWithDictionary:dictionary inContext:savingContext])) {
        // update attributes
        [entity updateWithDictionary:dictionary inContext:savingContext];
        status = DKDBManagedObjectStateUpdate;
    }
    // Just keeping the valid and managed entities and ignored the unvalid, disabled, non-managed ones.
    if ([entity deleteIfInvalidInContext:savingContext] == true) {
        status = DKDBManagedObjectStateDelete;
	}
	// Log and save as not deprecated. Entity reset if .Delete
	entity = [self saveEntityAfterCreation:entity status:status];

	if (completion != nil) {
		completion(entity, status);
	}

    return entity;
}

+ (NSArray * _Nullable)createEntitiesFromArray:(NSArray * _Nonnull)array inContext:(NSManagedObjectContext * _Nonnull)savingContext {

	if (array == nil || array.count == 0) {
		return nil;
	}

    NSMutableArray *entities = [NSMutableArray new];
    for (NSDictionary *dictionary in array) {
        id entity = [self createEntityFromDictionary:dictionary inContext:savingContext];
        if (entity != nil) {
            [entities addObject:entity];
        }
    }
    return entities;
}

#pragma mark - SAVE

+ (instancetype _Nullable)saveEntityAfterCreation:(id _Nullable)entity status:(DKDBManagedObjectState)status {
	// Log the current status and save the entity as not deprecated.
	// Does not save in case of `.Delete`
	switch (status) {
		case DKDBManagedObjectStateSave:
			CRUDLog(DKDBManager.verbose && [self verbose], @"Saving %@ %@", NSStringFromClass([self class]), entity);
		case DKDBManagedObjectStateCreate:
			CRUDLog(DKDBManager.verbose && [self verbose], @"Creating %@ %@", NSStringFromClass([self class]), entity);
		case DKDBManagedObjectStateUpdate:
			CRUDLog(DKDBManager.verbose && [self verbose], @"Updating %@ %@", NSStringFromClass([self class]), entity);
		case DKDBManagedObjectStateDelete:
			// Commented out as this event is already logged by the function `deleteEntityWithReason:inContext`
//			CRUDLog(DKDBManager.verbose && [self verbose], @"Deleting %@ %@", NSStringFromClass([self class]), entity);
			break;
	}
	if (status == DKDBManagedObjectStateDelete) {
		return nil;
	}
	[entity saveEntityAsNotDeprecated];
	return entity;
}

- (void)saveEntityAsNotDeprecated {
	// Method to save/store the current object and all its child relations as not deprecated.
	[DKDBManager saveEntityAsNotDeprecated:self];
}

#pragma mark - READ

- (id _Nonnull)uniqueIdentifier {
    return self.objectID;
}

- (NSString * _Nullable)invalidReason {
    // Check if the current entity is valid.
    // Return a NSString containing the reason, nil if the object is valid
    return nil;
}

- (BOOL)shouldUpdateEntityWithDictionary:(NSDictionary * _Nullable)dictionary inContext:(NSManagedObjectContext * _Nonnull)savingContext {
    // will be ignored if needForcedUpdate == true OR if allowUpdate == true
    return true;
}

+ (BOOL)verbose {
    return false;
}

+ (NSPredicate * _Nullable)primaryPredicateWithDictionary:(NSDictionary * _Nullable)dictionary {
    // If returns nil will only take the first entity created (if any) and update it. By doing so only ONE entity will ever be created.
    // If returns a `false predicate` a new entity will always be created.
	// If returns a `true predicate` a random entity will be retrieved.
    // Otherwise the CRUD process use the entity found by the predicate.
    return [NSPredicate predicateWithFormat:@"FALSEPREDICATE"];
}

+ (NSString * _Nullable)sortingAttributeName {
    return nil;
}

+ (NSInteger)countInContext:(NSManagedObjectContext * _Nonnull)context {
    return [self MR_countOfEntitiesWithContext:context];
}

+ (NSInteger)count {
	return [self countInContext:NSManagedObjectContext.MR_defaultContext];
}

+ (NSArray * _Nullable)allInContext:(NSManagedObjectContext * _Nonnull)context {
	if (self.sortingAttributeName != nil) {
		return [self MR_findAllSortedBy:self.sortingAttributeName ascending:YES inContext:context];
	}
    return [self MR_findAllInContext:context];
}

+ (NSArray * _Nullable)all {
	return [self allInContext:NSManagedObjectContext.MR_defaultContext];
}

- (instancetype _Nullable)entityInContext:(NSManagedObjectContext * _Nonnull)context {
	return [self MR_inContext:context];
}

- (instancetype _Nullable)entityInDefaultContext {
	return [self MR_inContext:NSManagedObjectContext.MR_defaultContext];
}

#pragma mark - UPDATE

- (void)updateWithDictionary:(NSDictionary * _Nullable)dictionary inContext:(NSManagedObjectContext * _Nonnull)savingContext {
    // this method should be overridden on the subclass
}

#pragma mark - DELETE

- (BOOL)deleteIfInvalidInContext:(NSManagedObjectContext * _Nonnull)savingContext {
    NSString *reason = [self invalidReason];
    if (reason != nil) {
        [self deleteEntityWithReason:reason inContext:savingContext];
        return true;
    }
    return false;
}

- (void)deleteEntityWithReason:(NSString * _Nullable)reason inContext:(NSManagedObjectContext * _Nonnull)context {
	CRUDLog(DKDBManager.verbose && self.class.verbose, @"Deleting %@ %@ Reason: %@", [self class], self, (reason != nil ? reason : @"n/a"));
    
    // remove the current object
	[self MR_deleteEntityInContext:context];
}

+ (void)deleteAllEntitiesInContext:(NSManagedObjectContext *)savingContext {
    CRUDLog(DKDBManager.verbose && self.class.verbose, @"delete all %@ entities in context %@", [self class], savingContext);
	NSPredicate *truePredicate = [NSPredicate predicateWithFormat:@"TRUEPREDICATE"];
    [self MR_deleteAllMatchingPredicate:truePredicate inContext:savingContext];
}

+ (void)removeDeprecatedEntitiesFromArray:(NSArray *)array inContext:(NSManagedObjectContext * _Nonnull)savingContext {
    // check if all entities are still in the dictionary
    NSArray *allEntities = [self MR_findAllInContext:savingContext];
    for (id entity in allEntities) {
        // if the entity is deprecated (no longer in the dictionary) then remove it !
        if ([entity respondsToSelector:@selector(uniqueIdentifier)]) {
            if ([array containsObject:[entity performSelector:@selector(uniqueIdentifier)]] == false) {
                [entity deleteEntityWithReason:@"deprecated" inContext:savingContext];
            }
        }
    }
}

@end
