#import "FKBaseFetchTableViewController.h"
#import "UIViewController+FKAnimatedFetchedResultsController.h"
#import "NSFetchedResultsController+FKAdditions.h"

@interface FKBaseFetchTableViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation FKBaseFetchTableViewController

$synthesize(fetchedResultsController);
$synthesize(updateAnimated);
$synthesize(entityClass);
$synthesize(predicate);
$synthesize(sectionKeyPath);
$synthesize(sortDescriptors);
$synthesize(contentUnavailableView);

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Lifecycle
////////////////////////////////////////////////////////////////////////

- (id)initWithStyle:(UITableViewStyle)style {
    if ((self = [super initWithStyle:style])) {
        updateAnimated_ = YES;
    }
    
    return self;
}

- (void)dealloc {
    fetchedResultsController_.delegate = nil;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController
////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self refetch];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    self.fetchedResultsController.delegate = nil;
    self.fetchedResultsController = nil;
    self.contentUnavailableView = nil;
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark FKBaseViewController
////////////////////////////////////////////////////////////////////////

- (void)updateUI {
    [super updateUI];
    
    // If the tableView has no data, show placeholder instead
    // Subclasses must implement the delegate-method contentUnavailableViewForTableView:
    if (self.fetchedResultsController.fetchedObjects.count == 0) {
        [self.tableView setContentUnavailableViewHidden:NO];
    } else {
        [self.tableView setContentUnavailableViewHidden:YES];
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark FKBaseFetchTableViewController
////////////////////////////////////////////////////////////////////////

- (NSFetchedResultsController *)fetchedResultsController {
    FKAssert(self.entityClass != nil, @"entityClass musn't be nil");
    
    if (fetchedResultsController_ == nil) {
        NSFetchRequest *fetchRequest = [self.entityClass requestAllWithPredicate:self.predicate 
                                                                       inContext:[NSManagedObjectContext defaultContext]];
        
        fetchRequest.sortDescriptors = self.sortDescriptors;
        fetchedResultsController_ = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[NSManagedObjectContext defaultContext]
                                                                          sectionNameKeyPath:self.sectionKeyPath
                                                                                   cacheName:self.cacheName];
        fetchedResultsController_.delegate = self;
    }
    
    return fetchedResultsController_;
}

- (NSString *)cacheName {
    return NSStringFromClass([self class]);
}

- (void)refetch {
    NSError *error = nil;
    
    BOOL updateAnimatedBefore = self.updateAnimated;
    self.updateAnimated = NO;
    
    // delete cache and re-create fetchedResultsController
    [NSFetchedResultsController deleteCacheWithName:self.cacheName];
    fetchedResultsController_ = nil;

    FKAssert([self.fetchedResultsController performFetch:&error],
             @"Unable to perform fetch on NSFetchedResultsController: %@", 
             [error localizedDescription]);
    
    self.updateAnimated = updateAnimatedBefore;
}

- (void)refetchWithPredicate:(NSPredicate *)predicate {
    self.predicate = predicate;
    [self refetch];
}

- (void)setSortDescriptor:(NSSortDescriptor *)sortDescriptor {
    self.sortDescriptors = $array(sortDescriptor);
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITableViewDataSource
////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.fetchedResultsController numberOfRowsInSection:section];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSFetchedResultsController Animated Update
////////////////////////////////////////////////////////////////////////

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller { 
    if (self.viewVisible && self.updateAnimated) {
        [self handleController:controller willChangeContentForTableView:self.tableView];
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller { 
    if (self.viewVisible && self.updateAnimated) {
        [self handleController:controller didChangeContentForTableView:self.tableView];
    } else {
        // reload data and set selected on same cell as before
        UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow];
        [self.tableView reloadData];
        [selectedCell setSelected:YES animated:NO];
    }
    
    [self updateUI];
}

- (void)controller:(NSFetchedResultsController *)controller 
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath { 
    
    if (self.viewVisible && self.updateAnimated) {
        [self handleController:controller
               didChangeObject:anObject
                   atIndexPath:indexPath
                 forChangeType:type
                  newIndexPath:newIndexPath
                     tableView:self.tableView];
    }
}

- (void)controller:(NSFetchedResultsController *)controller 
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex 
     forChangeType:(NSFetchedResultsChangeType)type {
	
    if (self.viewVisible && self.updateAnimated) {
        [self handleController:controller
              didChangeSection:sectionInfo
                       atIndex:sectionIndex
                 forChangeType:type
                     tableView:self.tableView];
    }
}


@end
