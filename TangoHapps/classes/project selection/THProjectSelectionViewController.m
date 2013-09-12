//
//  TFProjectSelectionViewController.m
//  TangoFramework
//
//  Created by Juan Haladjian on 10/17/12.
//  Copyright (c) 2012 Juan Haladjian. All rights reserved.
//

#import "THProjectSelectionViewController.h"
#import "THProjectProxy.h"
#import "THProjectCell.h"
#import "THProjectDraggableCell.h"
#import "THCustomProject.h"

@implementation THProjectSelectionViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.projectProxies = [THDirector sharedDirector].projectProxies;
    
    CCDirector *director = [CCDirector sharedDirector];
    if([director isViewLoaded] == NO) {
        director.view = [self createDirectorGLView];
        [self didInitializeDirector];
    }
    
    
    self.editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonTapped:)];
    
    self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped:)];
    
    self.navigationItem.leftBarButtonItem = self.editButton;
}

#pragma  mark - init cocos2d

- (CCGLView *)createDirectorGLView {

    float navBarHeight = self.navigationController.navigationBar.frame.size.height;
    float statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    
    CCGLView *glView = [CCGLView viewWithFrame:CGRectMake(0, 0, 1024, 768 - navBarHeight - statusBarHeight)
                                   pixelFormat:kEAGLColorFormatRGB565
                                   depthFormat:0
                            preserveBackbuffer:NO
                                    sharegroup:nil
                                 multiSampling:NO
                               numberOfSamples:0];
    return glView;
}

- (void)didInitializeDirector
{
    CCDirector *director = [CCDirector sharedDirector];
    
    [director setAnimationInterval:1.0f/60.0f];
    [director enableRetinaDisplay:YES];
}

-(void) viewWillAppear:(BOOL)animated{
    
    [self.collectionView reloadData];
    [self loadGestureRecognizers];
    
    [self updateEditButtonEnabledState];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString*) title{
    return @"Projects";
}

-(void) loadGestureRecognizers{
    ///tap
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    tapRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapRecognizer];
    
    //move
    panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moved:)];
    panRecognizer.delegate = self;
    [self.view addGestureRecognizer:panRecognizer];
    
    //long Press
    longpressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressedLong:)];
    longpressRecognizer.delegate = self;
    [self.view addGestureRecognizer:longpressRecognizer];
}

-(void) removeGestureRecognizers{
    [self.view removeGestureRecognizer: tapRecognizer];
    [self.view removeGestureRecognizer: panRecognizer];
    [self.view removeGestureRecognizer: longpressRecognizer];
    
    tapRecognizer = nil;
    panRecognizer = nil;
    longpressRecognizer = nil;
}

-(void) viewWillDisappear:(BOOL)animated{
    
    [self stopEditingScenes];
    [self removeGestureRecognizers];
}

#pragma mark - Private

- (void)reloadData {
    [self.collectionView reloadData];
}

- (void)proceedToProject:(THCustomProject*) project{

    [THDirector sharedDirector].currentProject = project;
    [self performSegueWithIdentifier:@"segueToProjectView" sender:self];
}


#pragma mark - Collection DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return [THDirector sharedDirector].projectProxies.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    THProjectProxy * proxy = [[THDirector sharedDirector].projectProxies objectAtIndex:indexPath.row];

    THProjectCell * cell = (THProjectCell*) [collectionView dequeueReusableCellWithReuseIdentifier:@"projectCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.title = proxy.name;
    cell.imageView.image = proxy.image;
    cell.editing = NO;
    cell.titleTextField.hidden = NO;
    
    return cell;
}

#pragma mark - Editing

-(void) startEditingScenes{
    
    for(int i = 0 ; i < self.projectProxies.count ; i++){
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        THProjectCell * cell =  (THProjectCell*) [self.collectionView cellForItemAtIndexPath:indexPath];
        cell.editing = YES;
    }
    
    self.editButton.title = @"Done";
    self.editingScenes = YES;
    self.editingOneScene = NO;
    
    self.navigationItem.leftBarButtonItem = self.doneButton;
}

-(void) stopEditingScenes{
    
    for(int i = 0 ; i < self.projectProxies.count ; i++){
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        THProjectCell * cell =  (THProjectCell*) [self.collectionView cellForItemAtIndexPath:indexPath];
        cell.editing = NO;
    }
    
    self.editButton.title = @"Edit";
    self.editingScenes = NO;
    self.editingOneScene = NO;
    
    self.navigationItem.leftBarButtonItem = self.editButton;
}

#pragma mark - Gestures

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    if([touch.view isKindOfClass:[UIControl class]]){
        return NO;
    }
    return YES;
}

-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if((self.editingScenes || self.editingOneScene) && currentProject && (gestureRecognizer == panRecognizer || otherGestureRecognizer == panRecognizer)) {
        
        return NO;
    }
    
    if((gestureRecognizer == tapRecognizer && otherGestureRecognizer == longpressRecognizer) || (gestureRecognizer == longpressRecognizer && otherGestureRecognizer == tapRecognizer)){
        return (self.editingScenes || self.editingOneScene);
    }

    return YES;
}

-(void) handleStartedMoving:(CGPoint) position{
    
    NSIndexPath * indexPath = [self.collectionView indexPathForItemAtPoint:position];
    
    if(indexPath){
        
        currentProjectCell = (THProjectCell*) [self.collectionView cellForItemAtIndexPath:indexPath];
        currentProject = [self.projectProxies objectAtIndex:indexPath.row];
        
        if(currentProjectCell.editing){
            
            currentDraggableCell = [[THProjectDraggableCell alloc] initWithFrame:currentProjectCell.frame];
            currentDraggableCell.imageView.image = currentProjectCell.imageView.image;
            currentDraggableCell.imageView.frame = currentProjectCell.imageView.frame;
            
            [self.projectProxies removeObject:currentProject];
            NSArray * indexPaths = [NSArray arrayWithObjects:indexPath, nil];
            [self.collectionView deleteItemsAtIndexPaths:indexPaths];
            
            [self.view addSubview:currentDraggableCell];
            
        }
    }
}

-(void) handleStoppedMoving{
    
    if(currentProjectCell){
        
        NSIndexPath * indexPath = [self.collectionView indexPathForItemAtPoint:currentDraggableCell.center];
        
        if(!indexPath){
            indexPath = [NSIndexPath indexPathForRow:self.projectProxies.count inSection:0];
        }
        
        [self.projectProxies insertObject:currentProject atIndex:indexPath.row];
        [currentDraggableCell removeFromSuperview];
        
        NSArray * indexPaths = [NSArray arrayWithObject:indexPath];
        [self.collectionView insertItemsAtIndexPaths:indexPaths];
        
        currentProject = nil;
        currentProjectCell = nil;
        currentDraggableCell = nil;
        
        [self stopEditingScenes];
        
    }
}

-(void) moved:(UIPanGestureRecognizer*) recognizer{
    
    if(self.editingScenes || self.editingOneScene){
        
        CGPoint position = [recognizer locationInView:self.collectionView];
        
        if(recognizer.state == UIGestureRecognizerStateBegan){
            
            [self handleStartedMoving:position];
            
        } else if(recognizer.state == UIGestureRecognizerStateChanged){
            
            currentDraggableCell.center = position;
            
        } else if(recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled || recognizer.state == UIGestureRecognizerStateEnded){
            
            [self handleStoppedMoving];
        }
    }
}

-(void) startEditingScene{
    
    self.editingOneScene = YES;
    currentProjectCell.editing = YES;
}

-(void) pressedLong:(UILongPressGestureRecognizer*) recognizer{
    
    if(recognizer.state == UIGestureRecognizerStateBegan &&  !self.editingScenes){
        
        CGPoint position = [recognizer locationInView:self.collectionView];
        NSIndexPath * indexPath = [self.collectionView indexPathForItemAtPoint:position];
        THProjectCell * cell = (THProjectCell*) [self.collectionView cellForItemAtIndexPath: indexPath];
        
        if(cell){
            [cell scaleEffect];
            currentProjectCell = cell;
            [NSTimer scheduledTimerWithTimeInterval:kProjectCellScaleEffectDuration target:self selector:@selector(startEditingScene) userInfo:nil repeats:NO];
            
        }
    }
}

-(void) tapped:(UITapGestureRecognizer*) recognizer{
    
    if(self.editingScenes || self.editingOneScene){
        
        [self stopEditingScenes];

    } else {
        
        CGPoint position = [recognizer locationInView:self.collectionView];
        NSIndexPath * indexPath = [self.collectionView indexPathForItemAtPoint:position];
        
        if(indexPath){
            THProjectProxy * projectProxy = [self.projectProxies objectAtIndex:indexPath.row];
            THCustomProject * project = (THCustomProject*) [THCustomProject projectSavedWithName:projectProxy.name];
            
            [self proceedToProject:project];
        }
    }
}

#pragma mark - Segue

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

}

#pragma mark - GridItem Delegate

-(void) didDeleteProjectCell:(THProjectCell*) cell {
    
    NSIndexPath * indexPath = [self.collectionView indexPathForCell:cell];
    if(indexPath){
        
        THProjectProxy * projectProxy = [self.projectProxies objectAtIndex:indexPath.row];
        [self.projectProxies removeObjectAtIndex:indexPath.row];
        
        NSArray * indexPaths = [NSArray arrayWithObject:indexPath];
        [self.collectionView deleteItemsAtIndexPaths:indexPaths];
        
        [TFFileUtils deleteDataFile:projectProxy.name fromDirectory:kProjectsDirectory];
        
        NSString * imageName = [projectProxy.name stringByAppendingString:@".png"];
        [TFFileUtils deleteDataFile:imageName fromDirectory:kProjectImagesDirectory];
        
        if(self.projectProxies.count == 0){
            [self stopEditingScenes];
            [self updateEditButtonEnabledState];
        }
    }
}

#pragma mark - UI Interaction

-(void) updateEditButtonEnabledState{
    if(self.projectProxies.count == 0){
        self.editButton.enabled = NO;
    } else{
        self.editButton.enabled = YES;
    }
}

- (IBAction)addButtonTapped:(id)sender {
    THCustomProject * newProject = [THCustomProject newProject];
    
    [self proceedToProject:newProject];
}

- (IBAction)filterControlChanged:(id)sender {
}

- (IBAction)orderControlChanged:(id)sender {
}

- (void) editButtonTapped:(id)sender {
    [self startEditingScenes];
}

- (void) doneButtonTapped:(id)sender {
    
    [self stopEditingScenes];
}


@end
