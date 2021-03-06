/*
THBoardEditable.m
Interactex Designer

Created by Juan Haladjian on 10/12/2013.

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

#import "THBoardEditable.h"
#import "TFLayer.h"
#import "THElementPinEditable.h"
#import "THBoardPinEditable.h"
#import "THWire.h"
#import "THHardwareComponentEditableObject.h"
#import "THPin.h"
#import "THBoard.h"

@implementation THBoardEditable

NSString * const kBoardSpriteNames[kMaxNumBoards] = {
    @"lilypadSimple.png",
    @"lilypadComplex.png",
    @"BLE-LilyPad.png"
};

#pragma mark - Initialization

#define kBLELilypadNumberOfPins 22

NSInteger kBoardNumPins[kMaxNumBoards] = {11,22,22};

CGPoint kBoardPinPositions[kMaxNumBoards][kBLELilypadNumberOfPins] = {
    {//simple
        {55.0, -94.0}, {94.0, -55.0},{109.0, -2.0},{94.0, 52.0},{54.0, 91.0},//D2,3,9,10,11
        {-52, -94}, {2.0, -110.0},//- +
        {-52,91},{-92,51},{-105, -3},{-91, -55}//A2 - A5
    },
    {{1,110},{-29,104},{-58.0, 91.0},{-84.0, 72.0},{-100.0, 45.0},//0 - 4
        {-111.0, 16.0}, {-102.0, -17.0},//- +
        {-100.0, -42.0},{-83.0, -70.0},{-59.0, -92.0},{-31.0, -102.0},{0.0, -110.0},{30.0, -105.0},//5-10
        {60.0, -96.0},{84.0, -73.0},{101.0, -48.0},//11-13
        {110.0, -17.0},{108.0, 13.0},{101.0, 42.0},{84.0, 72.0},{61.0, 92.0},{31,105}//A0 - A5
    },
    {//ble
        {1,110},{-29,104},{-58.0, 91.0},{-84.0, 72.0},{-100.0, 45.0},//0 - 4
        {-111.0, 16.0}, {-102.0, -17.0},//- +
        {-100.0, -42.0},{-83.0, -70.0},{-59.0, -92.0},{-31.0, -102.0},{0.0, -110.0},{30.0, -105.0},//5-10
        {60.0, -96.0},{84.0, -73.0},{101.0, -48.0},//11-13
        {110.0, -17.0},{108.0, 13.0},{101.0, 42.0},{84.0, 72.0},{61.0, 92.0},{31,105}//A0 - A5
    }
};


-(id) init{
    self = [super init];
    if (self) {
        
        self.i2cComponents = [NSMutableArray array];
        
        self.pins = [NSMutableArray array];
        
        self.showsWires = YES;
        
        [self loadBoard];
    }
    return self;
}

-(void) loadBoard{
    
    self.canBeDuplicated = NO;
}

#pragma mark - Archiving

-(id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if(self){
        self.pins = [decoder decodeObjectForKey:@"pins"];
        self.showsWires = [decoder decodeBoolForKey:@"showsWires"];
        self.i2cComponents = [decoder decodeObjectForKey:@"i2cComponents"];
        
        [self loadBoard];
        [self addPins];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
    [coder encodeObject:self.pins forKey:@"pins"];
    [coder encodeBool:self.showsWires forKey:@"showsWires"];
    [coder encodeObject:self.i2cComponents forKey:@"i2cComponents"];
}

-(id)copyWithZone:(NSZone *)zone {
    THBoardEditable * copy = [super copyWithZone:zone];
    copy.boardType = self.boardType;

    for (THHardwareComponentEditableObject * i2cComponent in self.i2cComponents) {
        [copy addI2CComponent:i2cComponent];
    }
    
    return copy;
}

#pragma mark - Methods

-(THBoardPinEditable*) minusPin{
    NSLog(@"Warning, THBoard subclasses should implement method minusPin");
    return nil;
}

-(THBoardPinEditable*) plusPin{
    NSLog(@"Warning, THBoard subclasses should implement method plusPin");
    return  nil;
}

-(THBoardPinEditable*) sclPin{
    NSLog(@"Warning, THBoard subclasses should implement method sclPin");
    return nil;
}

-(THBoardPinEditable*) sdaPin{
    NSLog(@"Warning, THBoard subclasses should implement method sdaPin");
    return  nil;
}

-(NSInteger) pinNumberAtPosition:(CGPoint) position{
    
    for (THBoardPinEditable * pin in self.pins) {
        if([pin testPoint:position]){
            return pin.number;
        }
    }
    
    return -1;
}

-(THPinEditable*) pinAtPosition:(CGPoint) position{
    for (THBoardPinEditable * pin in self.pins) {
        if([pin testPoint:position]){
            return pin;
        }
    }
    
    return nil;
}

-(THBoardPinEditable*) digitalPinWithNumber:(NSInteger) number{
    NSLog(@"Warning, calling digitalPinWithNumber on THBoardEditable");
    return nil;
}

-(THBoardPinEditable*) analogPinWithNumber:(NSInteger) number{
    return nil;
}

-(void) autoroutePlusAndMinusPins{
    
    THProject * project = (THProject*) [THDirector sharedDirector].currentProject;
    for (THHardwareComponentEditableObject * hardwareComponent in project.hardwareComponents) {
        [hardwareComponent autoroutePlusAndMinusPins];
    }
}

#pragma mark - I2C Components

-(void) addI2CComponent:(THHardwareComponentEditableObject*) component{
    [self.i2cComponents addObject:component];
}

-(void) removeI2CComponent:(THHardwareComponentEditableObject*) component{
    [self.i2cComponents removeObject:component];
}

-(THHardwareComponentEditableObject*) I2CComponentWithAddress:(NSInteger) address{
    
    for (THHardwareComponentEditableObject* component in self.i2cComponents) {
        id<THI2CProtocol> componentSimulable = (id<THI2CProtocol>)component.simulableObject;
        if(componentSimulable.i2cComponent.address == address){
            return component;
        }
    }
    return nil;
}

#pragma mark - Object's Lifecycle


-(void) addPins{
    for (THPinEditable * pin in self.pins) {
        [self addChild:pin z:1];
    }
}

-(void) loadPins{
    int i = 0;
    
    THBoard * lilypad = (THBoard*) self.simulableObject;
    
    for (THPin * pin in lilypad.pins) {
        
        THBoardPinEditable * pinEditable = [[THBoardPinEditable alloc] init];
        pinEditable.simulableObject = pin;
        
        if(pinEditable.type == kPintypeMinus){
            pinEditable.highlightColor = kMinusPinHighlightColor;
        } else if(pinEditable.type == kPintypeMinus){
            pinEditable.highlightColor = kPlusPinHighlightColor;
        }
        
        [self.pins addObject:pinEditable];
        i++;
    }
    
    [self addPins];
}

-(void) repositionPins{//after knowing sprite size pins should be repositioned
    
    int i = 0;
    for (THPinEditable * pin in self.pins) {
        
        pin.position = ccpAdd(ccp(self.contentSize.width/2.0f, self.contentSize.height/2.0f), kBoardPinPositions[self.boardType][i]);
        pin.position = ccpAdd(pin.position, ccp(pin.contentSize.width/2.0f, pin.contentSize.height/2.0f));
        i++;
    }
}

-(void) loadSprite{
    
    self.sprite = [CCSprite spriteWithFile:kBoardSpriteNames[self.boardType]];
    [self addChild:self.sprite];
}

-(void) addToLayer:(TFLayer *)layer{
    
    [self loadSprite];
    
    [self repositionPins];
    
    [layer addEditableObject:self];
    
    THProject * project = (THProject*) [THDirector sharedDirector].currentProject;
    if(project.boards.count == 1){
        for (THHardwareComponentEditableObject * object in project.hardwareComponents) {
            [object autoroute];
        }
    }
}

-(void) removeFromLayer:(TFLayer *)layer{
    [layer removeEditableObject:self];
}

-(void) addToWorld{
    THProject * project = (THProject*) [THDirector sharedDirector].currentProject;
    [project addBoard:self];
}

-(void) removeFromWorld{
    THProject * project = (THProject*) [THDirector sharedDirector].currentProject;
    [project removeBoard:self];
    
    [super removeFromWorld];
}

-(void) prepareToDie{
    
    for (THElementPinEditable * pin in self.pins) {
        [pin prepareToDie];
    }
    
    self.pins = nil;
    [super prepareToDie];
}

@end
