/*
THSlideSwitchEditableObject.m
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

#import "THSlideSwitchEditableObject.h"
#import "THSlideSwitch.h"

#import "THSwitchProperties.h"
#import "THElementPin.h"
#import "THPin.h"
#import "THElementPinEditable.h"

@implementation THSlideSwitchEditableObject

@dynamic on;

-(void) loadSlideSwitch{
    
    self.sprite = [CCSprite spriteWithFile:@"switch.png"];
    [self addChild:self.sprite z:1];
    
    
    _switchOnSprite = [CCSprite spriteWithFile:@"switchOn.png"];
    _switchOnSprite.visible = NO;
    //_switchOnSprite.anchorPoint = ccp(0,0);
    _switchOnSprite.position = ccp(self.sprite.contentSize.width/2.0f,self.sprite.contentSize.height/2.0f);
    [self addChild:_switchOnSprite];
}

-(id) init{
    self = [super init];
    if(self){        
        self.simulableObject = [[THSlideSwitch alloc] init];
        
        self.type = kHardwareTypeSwitch;
        
        [self loadSlideSwitch];
        [self loadPins];
    }
    return self;
}

#pragma mark - Archiving

-(id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    [self loadSlideSwitch];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
}

#pragma mark - Property Controller

-(NSArray*)propertyControllers
{
    NSMutableArray *controllers = [NSMutableArray array];
    //[controllers addObject:[THSwitchProperties properties]];
    [controllers addObjectsFromArray:[super propertyControllers]];
    return controllers;
}

#pragma mark - Methods

-(BOOL) on{
    
    THSlideSwitch * clotheSwitch = (THSlideSwitch*) self.simulableObject;
    return clotheSwitch.on;
}

-(void) update{
    
    if(self.on){
        [self handleSwitchOn];
    } else if(!self.on){
        [self handleSwitchOff];
    }
}

-(void) handleSwitchOn{
    _switchOnSprite.visible = YES;
}

-(void) handleSwitchOff{
    _switchOnSprite.visible = NO;
}

- (void)turnOn{
    THSlideSwitch * clotheSwitch = (THSlideSwitch*) self.simulableObject;
    [clotheSwitch switchOn];
}

- (void)turnOff{
    THSlideSwitch * clotheSwitch = (THSlideSwitch*) self.simulableObject;
    [clotheSwitch switchOff];
}

-(void) updatePinValue{
    
    THSlideSwitch * clotheswitch = (THSlideSwitch*) self.simulableObject;
    THElementPin * switchPin = [clotheswitch.pins objectAtIndex:0];
    THBoardPin * boardPin = (THBoardPin*) switchPin.attachedToPin;
    boardPin.value = clotheswitch.on;
}

-(void) handleTouchBegan{
    THSlideSwitch * clotheSwitch = (THSlideSwitch*) self.simulableObject;
    [clotheSwitch toggle];
    [self updatePinValue];
}

-(NSString*) description{
    return @"Button";
}

@end