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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self createRunners];
    [self createSecondRunners];
    [Runner deleteAllEntities];
    [self createRunners];
}

- (void)createRunners {
    NSArray * array = @[@{@"name":@"John", @"position":@13}, @{@"name":@"Toto", @"position":@14}];
    [Runner createEntitiesFromArray:array];
    [Runner countEntity];
    [DKDBManager saveToPersistentStoreAndWait];
}

- (void)createSecondRunners {
    NSArray * array = @[@{@"name":@"Alea", @"position":@16}, @{@"name":@"Proost", @"position":@17}];
    [Runner createEntitiesFromArray:array];
    [Runner countEntity];
    [DKDBManager saveToPersistentStoreAndWait];
}


@end
