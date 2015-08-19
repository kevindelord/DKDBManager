//
//  DBTViewController.m
//  DBTest
//
//  Created by kevin delord on 16/06/14.
//  Copyright (c) 2014 kevin delord. All rights reserved.
//

#import "DBTViewController.h"
#import "Runner+Helpers.h"

@interface DBTViewController ()

@end

@implementation DBTViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self createRunners];
    [self createSecondRunners];
    [Runner countEntity];
    [Runner deleteAllEntities];
    [self createRunners];
    [Runner countEntity];

    [self async_createRunners:^{
        [Runner countEntity];
    }];
}

- (void)async_createRunners:(void(^)())completion {
    NSArray * array = @[@{@"name":@"Philip", @"position":@1}, @{@"name":@"Adrien", @"position":@2}];
    NSArray * second_array = @[@{@"name":@"Marc", @"position":@3}, @{@"name":@"Julien", @"position":@4}];

    [DKDBManager saveWithBlock:^(NSManagedObjectContext *localContext) {
        [Runner createEntitiesFromArray:array context:localContext];
    } completion:^(BOOL contextDidSave, NSError *error) {

        [DKDBManager saveWithBlock:^(NSManagedObjectContext *localContext) {
            [Runner createEntitiesFromArray:second_array context:localContext];
        } completion:^(BOOL contextDidSave, NSError *error) {

            [Runner deleteAllEntities];

            [DKDBManager saveWithBlock:^(NSManagedObjectContext *localContext) {
                [Runner createEntitiesFromArray:array context:localContext];

            } completion:^(BOOL contextDidSave, NSError *error) {
                completion();
            }];
        }];
    }];
}

- (void)createRunners {
    NSArray * array = @[@{@"name":@"John", @"position":@13}, @{@"name":@"Toto", @"position":@14}];

    [DKDBManager saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        [Runner createEntitiesFromArray:array context:localContext];
    }];
    // Deprecated methods
//    [DKDBManager saveToPersistentStoreAndWait];
}

- (void)createSecondRunners {
    NSArray * array = @[@{@"name":@"Alea", @"position":@16}, @{@"name":@"Proost", @"position":@17}];

    [DKDBManager saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        [Runner createEntitiesFromArray:array context:localContext];
    }];
    // Deprecated methods
//    [DKDBManager saveToPersistentStoreAndWait];
}


@end
