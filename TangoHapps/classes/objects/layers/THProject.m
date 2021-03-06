/*
THProject.m
Interactex Designer

Created by Juan Haladjian on 05/10/2013.

Interactex Designer is a configuration tool to easily setup, simulate and connect e-Textile hardware with smartphone functionality. Interactex Client is an app to store and replay projects made with Interactex Designer.

www.interactex.org

Copyright (C) 2013 TU Munich, Munich, Germany; DRLab, University of the Arts Berlin, Berlin, Germany; Telekom Innovation Laboratories, Berlin, Germany
	
Contacts:
juan.haladjian@cs.tum.edu
katharina.bredies@udk-berlin.de
opensource@telekom.de

    
The first version of the software was designed and implemented as part of "Wearable M2M", a joint project of UdK Berlin and TU Munich, which was founded by Telekom Innovation Laboratories Berlin. It has been extended with funding from EIT ICT, as part of the activity "Connected Textiles".

Interactex is built using the Tango framework developed by TU Munich.

In the Interactex software, we use the GHUnit (a test framework for iOS developed by Gabriel Handford) and cocos2D libraries (a framework for building 2D games and graphical applications developed by Zynga Inc.). 
www.cocos2d-iphone.org
github.com/gabriel/gh-unit

Interactex also implements the Firmata protocol. Its software serial library is based on the original Arduino Firmata library.
www.firmata.org

All hardware part graphics in Interactex Designer are reproduced with kind permission from Fritzing. Fritzing is an open-source hardware initiative to support designers, artists, researchers and hobbyists to work creatively with interactive electronics.
www.frizting.org

Martijn ten Bhömer from TU Eindhoven contributed PureData support. Contact: m.t.bhomer@tue.nl.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 
You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

#import "THProject.h"
#import "THViewEditableObject.h"
#import "THHardwareComponentEditableObject.h"
#import "THiPhoneEditableObject.h"
#import "THClothe.h"
#import "THLilypadEditable.h"

#import "THClientProject.h"
#import "THConditionEditableObject.h"
#import "THElementPinEditable.h"
#import "THHardwareComponent.h"
#import "THView.h"
#import "THConditionObject.h"
#import "THNumberValue.h"
#import "THNumberValueEditable.h"
#import "THBoolValueEditable.h"
#import "THStringValueEditable.h"
#import "THBoolValue.h"
#import "THStringValue.h"

#import "THElementPin.h"
#import "THLilyPad.h"

#import "THiPhone.h"
#import "THAssetCollection.h"
#import "TFEventActionPair.h"

#import "THBoardPinEditable.h"
#import "THElementPinEditable.h"
#import "THWire.h"
#import "THInvocationConnectionLine.h"
#import "THBoard.h"
#import "THElementPinEditable.h"

@implementation THProject

#pragma mark - Static Methods

+(BOOL) doesProjectExistWithName:(NSString*) name{
    return [TFFileUtils dataFile:name existsInDirectory:kProjectsDirectory];
}

+(NSString*) nextProjectNameForName:(NSString*) name{

    int i = 2;
    NSString * finalName = name;
    while([self doesProjectExistWithName:finalName]){
        finalName = [NSString stringWithFormat:@"%@ %d",name,i];
        i++;
    }
    return finalName;
}

+(NSString*) newProjectName{
    return [self nextProjectNameForName:@"New Project"];
}

+(BOOL) renameProjectNamed:(NSString*) name toName:(NSString*) newName{
    if([newName isEqualToString:@""] || [TFFileUtils dataFile:newName existsInDirectory:kProjectsDirectory])
        return NO;
    
    return [TFFileUtils renameDataFile:name to:newName inDirectory:kProjectsDirectory];
}

#pragma mark - Static Constructors

+(THProject*) emptyProject {
    return [[THProject alloc] init];
}

+(THProject*) projectSavedWithName:(NSString*) name{
    
    NSString *filePath = [TFFileUtils dataFile:name inDirectory:kProjectsDirectory];
    return [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
}

+(id) newProject{
    NSString * newProjectName = [self newProjectName];
    
    return [THProject projectNamed:newProjectName];
}

+(id) projectNamed:(NSString*) name{
    return [[THProject alloc] initWithName:name];
}

#pragma mark - Initialization

-(void) loadCustomProject{
    
    _clothes = [NSMutableArray array];
    _boards = [NSMutableArray array];
    _hardwareComponents = [NSMutableArray array];
    _otherHardwareComponents = [NSMutableArray array];
    _iPhoneObjects = [NSMutableArray array];
    _visualProgrammingObjects = [NSMutableArray array];
    _wires = [NSMutableArray array];
    _invocationConnections = [NSMutableArray array];
    
    _assetCollection = [[THAssetCollection alloc] initWithLocalFiles];
    
    _eventActionPairs = [NSMutableArray array];
    
    _objectCountPerClass = [NSMutableDictionary dictionary];
}

-(void) initCustomProject{
    
    [self loadCustomProject];
    
    // nazmus uncommented the following lines
    THiPhoneEditableObject * iPhone = [THiPhoneEditableObject iPhoneWithDefaultView];
    iPhone.position = kDefaultiPhonePosition;
    [self addiPhone:iPhone];
    ////
}

-(id) init{
    self = [super init];
    if(self){
        [self initCustomProject];
    }
    return self;
}

-(id) initWithName:(NSString*) name{
    self = [super init];
    if(self){
        
        _name = name;
        [self initCustomProject];
    }
    return self;
}

#pragma mark - Archiving
    
-(id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(self){
        
        [self loadCustomProject];
        
        _name = [decoder decodeObjectForKey:@"name"];
        
        NSArray * eventActionPairs = [decoder decodeObjectForKey:@"eventActionPairs"];
        
        THiPhoneEditableObject * iPhone = [decoder decodeObjectForKey:@"iPhone"];
        
        NSArray * boards = [decoder decodeObjectForKey:@"boards"];
        NSArray * hardwareComponents = [decoder decodeObjectForKey:@"hardwareComponents"];
        NSArray * otherHardwareComponents = [decoder decodeObjectForKey:@"otherHardwareComponents"];
        NSArray * clothes = [decoder decodeObjectForKey:@"clothes"];
        NSArray * iPhoneObjects = [decoder decodeObjectForKey:@"iPhoneObjects"];
        NSArray * visualProgrammingObjects = [decoder decodeObjectForKey:@"visualProgrammingObjects"];
        THLilyPadEditable * lilypad = [decoder decodeObjectForKey:@"lilypad"];
        
        NSArray * wires = [decoder decodeObjectForKey:@"wires"];
        NSArray * invocationConnections = [decoder decodeObjectForKey:@"invocationConnections"];
        
        for(TFEventActionPair * pair in eventActionPairs){
            [self registerAction:pair.action forEvent:pair.event];
        }
        
        if(iPhone != nil)
            [self addiPhone:iPhone];
        
        for(THClothe* clothe in clothes){
            [self addClothe:clothe];
        }
    
        
        for(THBoardEditable * board in boards){
            [self addBoard:board];
        }
        
        for(THHardwareComponentEditableObject* hardwareComponent in hardwareComponents){
            [self addHardwareComponent:hardwareComponent];
        }
        
        for(THHardwareComponentEditableObject* hardwareComponent in otherHardwareComponents){
            [self addOtherHardwareComponent:hardwareComponent];
        }
        
        for(THViewEditableObject* iphoneObject in iPhoneObjects){
            [self addiPhoneObject:iphoneObject];
        }
        
        for(TFEditableObject* visualProgrammingObject in visualProgrammingObjects){
            [self addVisualProgrammingObject:visualProgrammingObject];
        }
        
        for(THWire * wire in wires){
            [self addWire:wire];
        }
        
        for(THInvocationConnectionLine * connection in invocationConnections){
            [self addInvocationConnection:connection animated:NO];
        }
        
        if(lilypad != nil){
            [self addBoard:lilypad];
        }
        
        [self countObjects];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
    
    [coder encodeObject:_name forKey:@"name"];
    [coder encodeObject:_eventActionPairs forKey:@"eventActionPairs"];
    
    [coder encodeObject:self.boards forKey:@"boards"];
    [coder encodeObject:self.hardwareComponents forKey:@"hardwareComponents"];
    [coder encodeObject:self.clothes forKey:@"clothes"];
    [coder encodeObject:self.iPhoneObjects forKey:@"iPhoneObjects"];
    if(self.iPhone != nil)
        [coder encodeObject:self.iPhone forKey:@"iPhone"];
    [coder encodeObject:self.visualProgrammingObjects forKey:@"visualProgrammingObjects"];
    [coder encodeObject:self.wires forKey:@"wires"];
    [coder encodeObject:self.invocationConnections forKey:@"invocationConnections"];
}

#pragma mark - Notifications

-(void) notifyObjectAdded:(TFEditableObject*) object{
    [self checkAddNameToObject:object];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationObjectAdded object:object];
}

-(void) notifyObjectRemoved:(TFEditableObject*) object{
    [self removeCountForObject:object];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationObjectRemoved object:object];
}

#pragma mark - Saving and renaming

-(void) save{
    
    NSString * filePath = [TFFileUtils dataFile:self.name inDirectory:kProjectsDirectory];
    [NSKeyedArchiver archiveRootObject:self toFile:filePath];
}

-(BOOL) renameTo:(NSString*) newName{
    
    BOOL success = [THProject renameProjectNamed:self.name toName:newName];
    if(success){
        self.name = newName;
    }
    
    return YES;
}

#pragma mark - Objects name

-(void) checkAddNameToObject:(TFEditableObject*) object{
    //if([object isKindOfClass:[THHardwareComponentEditableObject class]]){
        TFEditableObject * editableObject = (TFEditableObject*) object;
        if(editableObject.objectName == nil || [editableObject.objectName isEqualToString:@""]){
            [self addCountForObject:object];

            NSString * className = object.description;
            //NSNumber * classCount = [self.objectCountPerClass valueForKey:className];
            
            //editableObject.objectName = [NSString stringWithFormat:@"%@ %ld",className,(long)classCount.integerValue];
            editableObject.objectName = [NSString stringWithFormat:@"%@",className];
        }
    //}
}

-(void) countObjects{
    [self resetObjectsCount];
    
    for (TFEditableObject * object in self.allObjects) {
        [self addCountForObject:object];
    }
}

-(void) addCountForObject:(TFEditableObject*) object add:(NSInteger) addValue {
    
    //NSString * className = NSStringFromClass([object class]);
    NSString * className = object.description;
    
    NSNumber * number = [self.objectCountPerClass valueForKey:className];
    if(!number){
        number = [NSNumber numberWithInt:0];
    }
    number = [NSNumber numberWithLong:number.integerValue + addValue];
    [self.objectCountPerClass setValue:number forKey:className];
}

-(void) addCountForObject:(TFEditableObject*) object{
    [self addCountForObject:object add:+1];
}

-(void) removeCountForObject:(TFEditableObject*) object{
    [self addCountForObject:object add:-1];
}

-(void) resetObjectsCount{
    [self.objectCountPerClass removeAllObjects];
}

#pragma mark - Pins

-(void) pinClotheObject:(THHardwareComponentEditableObject*) clotheObject toClothe:(THClothe*) clothe{
    
    if(!clotheObject.attachedToClothe){
        [clothe attachClotheObject:clotheObject];
    }
}

-(void) unpinClotheObject:(THHardwareComponentEditableObject*) clotheObject{
    if(clotheObject.attachedToClothe){
        [clotheObject.attachedToClothe deattachClotheObject:clotheObject];
    }
}

#pragma mark - Lilypad

-(void) addBoard:(THBoardEditable*)board{
    [self.boards addObject:board];
    [self notifyObjectAdded:board];
}

-(void) removeBoard:(THBoardEditable*) board{
    
    [self removeAllWiresTo:board notify:YES];
    
    for (THHardwareComponentEditableObject * hardwareComponent in self.hardwareComponents) {
        [hardwareComponent handleBoardRemoved:board];
    }
    
    [self.boards removeObject:board];
    [self notifyObjectRemoved:board];
}

-(THBoardEditable*) boardAtLocation:(CGPoint) location{
    for (THBoardEditable* board in _boards) {
        if([board testPoint:location]){
            return board;
        }
    }
    return nil;
}

-(NSArray*) boardsAtLocation:(CGPoint) location{
    NSMutableArray * boards = [NSMutableArray array];
    
    for (THBoardEditable* board in _boards) {
        if([board testPoint:location]){
            [boards addObject:board];
        }
    }
    return boards;
}

#pragma mark - iPhoneObjects

-(void) addiPhoneObject:(THViewEditableObject*) object{
    if(object.canBeRootView){
        self.iPhone.currentView = object;
    } else {
        [self.iPhone.currentView addSubview:object];
        [_iPhoneObjects addObject:object];
    }
    
    [self notifyObjectAdded:object];
}

-(void) removeiPhoneObject:(THViewEditableObject*) object{
    if(object.canBeRootView){
        self.iPhone.currentView = nil;
    } else {
        [self.iPhone.currentView removeSubview:object];
        [_iPhoneObjects removeObject:object];
    }
    
    [self deregisterActionsForObject:object];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationObjectRemoved object:object];
}

-(THViewEditableObject*) iPhoneObjectAtLocation:(CGPoint) location{
    THViewEditableObject * object = nil;
    for (THViewEditableObject * iPhoneObject in self.iPhoneObjects) {
        if([iPhoneObject testPoint:location]){
            object = iPhoneObject;
        }
    }
    if(!object && [self.iPhone.currentView testPoint:location]){
        object = self.iPhone.currentView;
    }
    return object;
}

#pragma mark - iPhone

-(void) addiPhone:(THiPhoneEditableObject *)iPhone{
    _iPhone = iPhone;
    
    [self notifyObjectAdded:iPhone];
}

-(void) removeiPhone{
    
    [self notifyObjectRemoved:_iPhone];
    
    for (THViewEditableObject * object in self.iPhoneObjects) {
        [object removeFromWorld];
    }

    _iPhone = nil;
}

#pragma mark - Clothe Objects

-(void) addHardwareComponent:(THHardwareComponentEditableObject*) clotheObject{
    [self.hardwareComponents addObject:clotheObject];
    [self notifyObjectAdded:clotheObject];
    //[self tryAttachClotheObject:clotheObject];
}

-(void) removeHardwareComponent:(THHardwareComponentEditableObject*) clotheObject{
    [self removeAllWiresFrom:clotheObject notify:YES];
    [self.hardwareComponents removeObject:clotheObject];

    [self deregisterActionsForObject:clotheObject];
    [self notifyObjectRemoved:clotheObject];
}

-(THHardwareComponentEditableObject*) hardwareComponentAtLocation:(CGPoint) location{
    for (THHardwareComponentEditableObject * object in self.hardwareComponents) {
        if([object testPoint:location]){
            return object;
        }
    }
    return nil;
}

-(void) tryAttachClotheObject: (THHardwareComponentEditableObject*) clotheObject{
    if(!clotheObject.attachedToClothe){
        THClothe * clothe = [self clotheAtLocation:clotheObject.position];
        if(clothe){
            [clotheObject removeFromParentAndCleanup:YES];
            [self pinClotheObject:clotheObject toClothe:clothe];
            
        }
    }
}

#pragma mark - Other Hardware Components

-(void) addOtherHardwareComponent:(THHardwareComponentEditableObject*) otherHardwareComponent{
    [self.hardwareComponents addObject:otherHardwareComponent];
    [self notifyObjectAdded:otherHardwareComponent];
}

-(void) removeOtherHardwareComponent:(THHardwareComponentEditableObject*) otherHardwareComponent{
    [self removeAllWiresFrom:otherHardwareComponent notify:YES];
    [self.otherHardwareComponents removeObject:otherHardwareComponent];
    
    [self deregisterActionsForObject:otherHardwareComponent];
    [self notifyObjectRemoved:otherHardwareComponent];
}

-(THHardwareComponentEditableObject*) otherHardwareComponentAtLocation:(CGPoint) location{
    for (THHardwareComponentEditableObject * object in self.otherHardwareComponents) {
        if([object testPoint:location]){
            return object;
        }
    }
    return nil;
}

#pragma mark - Clothes

-(void) addClothe:(THClothe*) clothe{
    [_clothes addObject:clothe];
    [self notifyObjectAdded:clothe];
}

-(void) removeClothe:(THClothe*) clothe{
    [_clothes removeObject:clothe];
    [self notifyObjectRemoved:clothe];
}

-(THClothe*) clotheAtLocation:(CGPoint) location{
    for (THClothe * clothe in self.clothes) {
        if([clothe testPoint:location]){
            return clothe;
        }
    }
    return nil;
}

#pragma mark - Visual Programming

-(void) addVisualProgrammingObject:(TFEditableObject*) object{
    [_visualProgrammingObjects addObject:object];
    [self notifyObjectAdded:object];
}

-(void) removeVisualProgrammingObject:(TFEditableObject*) object{
    [_visualProgrammingObjects removeObject:object];
    [self deregisterActionsForObject:object];
    [self notifyObjectRemoved:object];
}

-(TFEditableObject*) visualProgrammingObjectAtLocation:(CGPoint) location{
    for (TFEditableObject * object in self.visualProgrammingObjects) {
        if([object testPoint:location]){
            return object;
        }
    }
    return nil;
}


#pragma mark - EventAcionPairs

-(NSMutableArray*) actionsForTarget:(TFEditableObject*) target{
    NSMutableArray * array = [NSMutableArray array];
    for (TFEventActionPair * pair in self.eventActionPairs) {
        if(pair.action.target == target){
            [array addObject:pair];
        }
    }
    return array;
}

-(NSMutableArray*) actionsForSource:(TFEditableObject*) source{
    NSMutableArray * array = [NSMutableArray array];
    for (TFEventActionPair * pair in self.eventActionPairs) {
        if(pair.action.source == source){
            [array addObject:pair];
        }
    }
    return array;
}

-(void) deregisterActionsForObject:(TFEditableObject*) object{
    NSMutableArray * toRemove = [NSMutableArray array];
    for (TFEventActionPair * pair in self.eventActionPairs) {
        if(pair.action.target == object || pair.action.source == object){
            [toRemove addObject:pair];
        }
    }
    
    for (TFEventActionPair * pair in toRemove) {
        [self deregisterAction:pair.action];
    }
    
    [self removeAllInvocationConnectionsFrom:object];
    [self removeAllInvocationConnectionsTo:object];
    
    [[NSNotificationCenter defaultCenter] removeObserver:object];
}

-(void) deregisterAction:(TFAction*) action{
    TFEventActionPair * toRemove;
    NSInteger idx = 0;
    for (TFEventActionPair * pair in self.eventActionPairs) {
        if(pair.action == action){
            toRemove = pair;
            break;
        }
        idx++;
    }
    [_eventActionPairs removeObject:toRemove];
    
    TFEditableObject * editable = toRemove.action.source;
    [[NSNotificationCenter defaultCenter] removeObserver:action name:toRemove.event.name object:editable.simulableObject];
}

-(void) registerAction:(TFAction*) action forEvent:(TFEvent*) event{
    NSAssert(action, @"cannot register nil action");
    NSAssert(event, @"cannot register nil event");
    
    TFEventActionPair * pair = [[TFEventActionPair alloc] init];
    pair.action = action;
    pair.event = event;
    [_eventActionPairs addObject:pair];
    
    TFEditableObject * source = action.source;
    TFEditableObject * target = action.target;
    
    [source handleRegisteredAsSourceForAction:action];
    [target handleRegisteredAsTargetForAction:action];
    
    [[NSNotificationCenter defaultCenter] addObserver:action selector:@selector(startAction) name:event.name object:((TFEditableObject*)action.source).simulableObject];
}

#pragma mark - Wires

-(void) addWire:(THWire*) wire{
    [self.wires addObject:wire];

    [self notifyObjectAdded:wire];
}

-(void) removeWire:(THWire*) wire{
    [self.wires removeObject:wire];
    
    [self notifyObjectRemoved:wire];
}

-(void) addWireFrom:(THElementPinEditable*) elementPin to:(THBoardPinEditable*) boardPin{
    
    THWire * wire = [[THWire alloc] initWithObj1:elementPin obj2:boardPin];
    
    if(boardPin.type == kPintypeMinus){
        
        wire.color = kMinusPinColor;
        
    } else if(boardPin.type == kPintypePlus){
        
        wire.color = kPlusPinColor;
        
    } else {
        
        wire.color = kWireDefaultColor;
    }
    
    [self addWire:wire];
}

-(void) removeWires:(NSArray*) wires notify:(BOOL) notify{
    for (THWire * wire in wires) {
        [wire prepareToDie];
        [self.wires removeObject:wire];
        if(notify){
            [self notifyObjectRemoved:wire];
        }
    }
}

-(void) removeAllWiresFromElementPin:(THElementPinEditable*) elementPin notify:(BOOL) notify{
    NSMutableArray * toRemove = [NSMutableArray array];
    for (THWire * wire in self.wires) {
        if(wire.obj1 == elementPin){
            [toRemove addObject:wire];
        }
    }
    [self removeWires:toRemove notify:notify];
}

-(void) removeAllWiresFrom:(id) object notify:(BOOL) notify{
    NSMutableArray * toRemove = [NSMutableArray array];
    for (THWire * wire in self.wires) {
        if(wire.obj1.hardware == object){
            [toRemove addObject:wire];
        }
    }
    
    [self removeWires:toRemove notify:notify];
}

-(void) removeAllWiresTo:(THBoardEditable*) board notify:(BOOL) notify{
    NSMutableArray * toRemove = [NSMutableArray array];
    for (THWire * wire in self.wires) {
        
        if([board.pins containsObject:wire.obj2]){
            [toRemove addObject:wire];
        }
    }
    
    for (THWire * wire in toRemove) {
        [wire prepareToDie];
        [self.wires removeObject:wire];
        if(notify){
            [self notifyObjectRemoved:wire];
        }
    }
}

-(TFEditableObject*) wireAtLocation:(CGPoint) location{
    for (THWire * wire in self.wires) {
        for (THWireNode * node in wire.nodes) {
            if([node testPoint:location]){
                return wire;
            }
        }
    }
    return nil;
}

-(NSArray*) wiresForHardwareElement:(THHardwareComponentEditableObject*) hardwareComponent{
    NSMutableArray * wires = [NSMutableArray array];
    
    for (THWire * wire in self.wires) {
        if(wire.obj1.hardware == hardwareComponent){
            [wires addObject:wire];
        }
    }
    
    return wires;
}

#pragma mark - Invocation Connections

-(NSArray*) invocationConnectionsForObject:(TFEditableObject*) object{
    NSMutableArray * connections = [NSMutableArray array];
    
    for (THInvocationConnectionLine * connection in self.invocationConnections) {
        if(connection.obj1 == object){
            [connections addObject:connection];
        }
    }
    
    return connections;
}

-(NSArray*) invocationConnectionsToObject:(TFEditableObject*) object{
    NSMutableArray * connections = [NSMutableArray array];
    
    for (THInvocationConnectionLine * connection in self.invocationConnections) {
        if(connection.obj2 == object){
            [connections addObject:connection];
        }
    }
    
    return connections;
}

-(NSArray*) invocationConnectionsFrom:(TFEditableObject*) obj1 to:(TFEditableObject*) obj2{
    NSMutableArray * connections = [NSMutableArray array];
    
    for (THInvocationConnectionLine * connection in self.invocationConnections) {
        if(connection.obj1 == obj1 && connection.obj2 == obj2){
            [connections addObject:connection];
        }
    }
    
    return connections;
}

-(void) addInvocationConnection:(THInvocationConnectionLine*) connection animated:(BOOL) animated{
    
    connection.shouldAnimate = animated;
    [self.invocationConnections addObject:connection];
    [self notifyObjectAdded:connection];
}

-(void) removeInvocationConnection:(THInvocationConnectionLine*) invocationConnection{
    [self.invocationConnections removeObject:invocationConnection];
    
    [self notifyObjectRemoved:invocationConnection];
}

-(void) removeAllInvocationConnectionsFrom:(id) object{
    NSMutableArray * toRemove = [NSMutableArray array];
    for (THInvocationConnectionLine * invocationConnection in self.invocationConnections) {
        if(invocationConnection.obj1 == object){
            [toRemove addObject:invocationConnection];
        }
    }
    
    for (id objectToRemove in toRemove) {
        [self.invocationConnections removeObject:objectToRemove];
        [self notifyObjectRemoved:objectToRemove];
    }
}

-(void) removeAllInvocationConnectionsTo:(id) object{
    NSMutableArray * toRemove = [NSMutableArray array];
    for (THInvocationConnectionLine * invocationConnection in self.invocationConnections) {
        if(invocationConnection.obj2 == object){
            [toRemove addObject:invocationConnection];
        }
    }
    
    for (id objectToRemove in toRemove) {
        [self.invocationConnections removeObject:objectToRemove];
        [self notifyObjectRemoved:objectToRemove];
    }
}

-(void) removeAllConnectionsFrom:(TFEditableObject*) obj1 to:(TFEditableObject*) obj2{
    NSArray * toRemove = [self invocationConnectionsFrom:obj1 to:obj2];
    
    for (THInvocationConnectionLine * connection in toRemove) {
        [self.invocationConnections removeObject:connection];
        [self notifyObjectRemoved:connection];
        //[connection.obj1 reloadProperties];//juan check if properties work
    }
}

#pragma mark - All Objects

-(TFEditableObject*) objectAtLocation:(CGPoint)location{
    for (THInvocationConnectionLine * connection in self.invocationConnections) {
        if([connection testPoint:location]){
            return connection;
        }
    }
    NSMutableArray * arr = [NSMutableArray array];
    for (TFEditableObject* object in self.allObjects) {
        if([object testPoint:location]){
            [arr addObject:object];
            //return object;
        }
    }
    
    if([arr count] != 0) return arr.firstObject;
    
    if(self.iPhone){
        if([self.iPhone.currentView testPoint:location]){
            return self.iPhone.currentView;
        } else if([self.iPhone testPoint:location]){
            return self.iPhone;
        }
    }
    
    //find visible connection
    
    return nil;
}


/*
enum zPositions{
    kLilypadZ = -25,
    kClotheZ = -20,
    kiPhoneZ = -15,
    kClotheObjectZ = -10,
    kValueZ = -9,
    kConditionZ = -8,
    kNormalObjectZ = -7,
};*/

-(NSMutableArray*) allObjects{
    NSMutableArray * allObjects = [NSMutableArray arrayWithArray:self.boards];
    [allObjects addObjectsFromArray:self.visualProgrammingObjects];
    [allObjects addObjectsFromArray:self.iPhoneObjects];
    [allObjects addObjectsFromArray:self.hardwareComponents];
    [allObjects addObjectsFromArray:self.otherHardwareComponents];
    [allObjects addObjectsFromArray:self.clothes];

    return allObjects;
}

#pragma Mark - Non Editable Project


-(NSInteger) idxOfSimulable:(TFSimulableObject*) simulable inArray:(NSArray*) array{
    NSInteger i = 0;
    for (TFEditableObject * editable in array) {
        
        NSLog(@"got %@, checking %@",simulable,editable.simulableObject);
        
        if(editable.simulableObject == simulable){
            return i;
        }
        i++;
    }
    return i;
}

-(NSInteger) idxOfEditable:(TFEditableObject*) editable inArray:(NSArray*) array{
    NSInteger i = 0;
    for (TFEditableObject * e in array) {
        if(e == editable){
            return i;
        }
        i++;
    }
    return i;
}

-(TFSimulableObject*) simulableForEditable:(TFEditableObject*) editable inProject:(THClientProject*) project{
    if([editable isKindOfClass:[THHardwareComponentEditableObject class]]){
        NSInteger idx = [self idxOfEditable:editable inArray:self.hardwareComponents];
        return [project.hardwareComponents objectAtIndex:idx];
    } else if ([editable isKindOfClass:[THViewEditableObject class]]){
        NSInteger idx = [self idxOfEditable:editable inArray:self.iPhoneObjects];
        return [project.iPhoneObjects objectAtIndex:idx];
    } else if ([editable isKindOfClass:[THiPhoneEditableObject class]]){
        return (TFSimulableObject*) project.iPhone;
    } else if ([editable isKindOfClass:[THProgrammingElementEditable class]]){
        NSInteger idx = [self idxOfEditable:editable inArray:self.visualProgrammingObjects];
        return [project.visualProgrammingObjects objectAtIndex:idx];
    } else {
        NSAssert(NO, @"returning nil in simulableForEditable for %@",editable);
        return nil;
    }
}

-(NSMutableArray*) nonEditableElementsForArray:(NSMutableArray*) objects forProject:(THClientProject*) project{
    NSMutableArray * ret = [NSMutableArray arrayWithCapacity:objects.count];
    
    for (TFEditableObject * object in objects) {
        TFSimulableObject * copy = [object.simulableObject copy];
        [ret addObject:copy];
    }
    
    return ret;
}

-(void) addNonEditableActionPairsTo:(THClientProject*) project{
    
    for (TFEventActionPair * pair in self.eventActionPairs) {
        
        TFEvent * originalEvent = pair.event;
        TFMethodInvokeAction * originalAction = (TFMethodInvokeAction*) pair.action;
        
        //event
        TFEvent * newEvent = [originalEvent copy];
        if([newEvent.param1.target isKindOfClass:[TFEditableObject class]]){
            newEvent.param1.target = [self simulableForEditable:newEvent.param1.target inProject:project];
        }
        
        //action
        TFMethodInvokeAction * newAction = [originalAction copy];
        newAction.source = [self simulableForEditable:newAction.source inProject:project];
        newAction.target = [self simulableForEditable:newAction.target inProject:project];
        if(originalAction.firstParam){
            newAction.firstParam.target = [self simulableForEditable:newAction.firstParam.target inProject:project];
        }
        
        [project registerAction:newAction forEvent:newEvent];
    }
}

-(THElementPin*) findElementPin:(THElementPin*) pin inProject:(THClientProject*) project{
    for (THHardwareComponent * clothe in project.hardwareComponents){
        if(pin.hardware == clothe){
            for (THElementPin * epin in clothe.pins){
                if(epin.type == pin.type){
                    return epin;
                }
            }
        }
    }
    return nil;
}

-(void) cleanBoardPinsFor:(THClientProject*) project{
    
    NSInteger i = 0;
    for (THHardwareComponentEditableObject * editableClothe in self.hardwareComponents){
        THHardwareComponent * clothe = (THHardwareComponent*) editableClothe.simulableObject;
        THHardwareComponent * neclothe = [project.hardwareComponents objectAtIndex:i];
        
        NSInteger j = 0;
        for (THElementPin * epin in clothe.pins){
            if(epin.attachedToPin != nil){
                THElementPin * nepin = [neclothe.pins objectAtIndex:j];
                THBoardPin * lilyPin = (THBoardPin*) epin.attachedToPin;
                
                NSInteger idx = [project.currentBoard pinIdxForPin:lilyPin.number ofType:lilyPin.type];
                THBoardPin * newlilyPin = [project.currentBoard.pins objectAtIndex:idx];
                
                [newlilyPin attachPin:nepin];
                [nepin attachToPin:newlilyPin];
            }
            j++;
        }
        i++;
    }
}

-(void) cleanI2CComponentsFor:(THClientProject*) project{
    
    NSInteger i = 0;
    
    for (THBoardEditable * board in self.boards) {
        THBoard * clientBoard = [project.boards objectAtIndex:i++];
        
        clientBoard.i2cComponents = [NSMutableArray array];
        for (THHardwareComponentEditableObject * component in board.i2cComponents){
            TFSimulableObject * simulable = [self simulableForEditable:component inProject:project];
            [clientBoard.i2cComponents addObject:simulable];
        }
    }
}

-(void) printProject:(THClientProject*) project{
    for (TFEventActionPair * pair in project.actionPairs) {
        
        NSLog(@"event target: %@", pair.event.param1.target);
        NSLog(@"action source: %@", pair.action.source);
        NSLog(@"action target: %@", pair.action.target);
        NSLog(@"action invoke: %@", ((TFMethodInvokeAction*)pair.action).firstParam.target);
    }
}

-(THClientProject*) nonEditableProject{
    
    THClientProject * project = [[THClientProject alloc] initWithName:self.name];
    
    project.boards = [self nonEditableElementsForArray:self.boards forProject:project];
    project.hardwareComponents = [self nonEditableElementsForArray:self.hardwareComponents forProject:project];
    project.iPhoneObjects = [self nonEditableElementsForArray:self.iPhoneObjects forProject:project];
    project.visualProgrammingObjects = [self nonEditableElementsForArray:self.visualProgrammingObjects forProject:project];
    project.iPhone = (THiPhone*) self.iPhone.simulableObject;
    
    [self cleanBoardPinsFor:project];
    [self cleanI2CComponentsFor:project];
    [self addNonEditableActionPairsTo:project];
    
    //[self printProject:project];
    
    return project;
}

-(BOOL) isEmpty{
    return (self.allObjects.count == 0);
}

#pragma mark - Project Lifecycle

-(void) prepareToDie{
    
    for (TFEditableObject * object in self.allObjects) {
        [object prepareToDie];
    }
    
    for (TFEventActionPair * pair in _eventActionPairs) {
        [pair.action prepareToDie];
    }
    
    for (THInvocationConnectionLine * connection in _invocationConnections) {
        [connection prepareToDie];
    }
    
    [self.iPhone prepareToDie];
    
    for (THWire * wire in self.wires) {
        [wire prepareToDie];
    }
    
    _iPhone = nil;
}

-(void) willStartSimulation{
    for (TFEditableObject * object in self.allObjects) {
        [object willStartSimulation];
    }
    
    [self.iPhone willStartSimulation];
}

-(void) didStartSimulation{
    for (TFEditableObject * editable in self.allObjects) {
        [editable didStartSimulation];
    }
    
    [self.iPhone didStartSimulation];
}

-(void) prepareForEdition{
    for (TFEditableObject * object in self.allObjects) {
        [object willStartEdition];
    }
    [self.iPhone willStartEdition];
}

-(NSString*) description{
    return @"CustomProject";
}

@end
