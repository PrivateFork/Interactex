/*
THTemperatureSensorEditable.m
Interactex Designer

Created by Juan Haladjian on 12/10/2013.

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

#import "THTemperatureSensorEditable.h"
#import "THTemperatureSensor.h"

@implementation THTemperatureSensorEditable

@dynamic value;
@dynamic minValueNotify;
@dynamic maxValueNotify;
@dynamic notifyBehavior;

const CGSize kTemperatureValueLabelSize = {75, 20};

-(id) init{
    self = [super init];
    if(self){
        self.simulableObject = [[THTemperatureSensor alloc] init];

        [self loadTemperatureSensor];
        [super loadPins];
    }
    return self;
}

-(void) loadTemperatureSensor{
    
    self.type = kHardwareTypeTemperatureSensor;
}

#pragma mark - Archiving

-(id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    
    if(self){
        [self loadTemperatureSensor];
        
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    
}

-(id)copyWithZone:(NSZone *)zone {
    THTemperatureSensorEditable * copy = [super copyWithZone:zone];
    
    copy.minValueNotify = self.minValueNotify;
    copy.maxValueNotify = self.maxValueNotify;
    copy.notifyBehavior = self.notifyBehavior;
    
    return copy;
}

#pragma mark - Property Controller

-(NSArray*)propertyControllers
{
    NSMutableArray *controllers = [NSMutableArray array];
    //[controllers addObject:[THPotentiometerProperties properties]];
    [controllers addObjectsFromArray:[super propertyControllers]];
    return controllers;
}

#pragma mark - Pins

-(THElementPinEditable*) minusPin{
    return [self.pins objectAtIndex:1];
}

-(THElementPinEditable*) analogPin{
    return [self.pins objectAtIndex:2];
}

-(THElementPinEditable*) plusPin{
    return [self.pins objectAtIndex:0];
}

#pragma mark - Methods

-(void) handleTouchBegan{
    self.isDown = YES;
}

-(void) handleTouchEnded{
    self.isDown = NO;
}

-(void) update{
    
    if(self.isDown){
        _touchDownIntensity += kDefaultAnalogSimulationIncrease;
    } else {
        _touchDownIntensity -= kDefaultAnalogSimulationIncrease;
    }
    _touchDownIntensity = [THClientHelper Constrain:_touchDownIntensity min:0 max:kMaxAnalogValue];
    
    THTemperatureSensor * temperatureSensor = (THTemperatureSensor*) self.simulableObject;
    temperatureSensor.value = _touchDownIntensity;
    _valueLabel.string = [NSString stringWithFormat:@"%ld",(long)temperatureSensor.value];
    
}

-(NSInteger) value{
    
    THTemperatureSensor * temperatureSensor = (THTemperatureSensor*) self.simulableObject;
    return temperatureSensor.value;
}

-(NSInteger) minValueNotify{
    
    THTemperatureSensor * temperatureSensor = (THTemperatureSensor*) self.simulableObject;
    return temperatureSensor.minValueNotify;
}

-(void) setMinValueNotify:(NSInteger)minValueNotify{
    
    THTemperatureSensor * temperatureSensor = (THTemperatureSensor*) self.simulableObject;
    temperatureSensor.minValueNotify = minValueNotify;
}

-(NSInteger) maxValueNotify{
    
    THTemperatureSensor * temperatureSensor = (THTemperatureSensor*) self.simulableObject;
    return temperatureSensor.maxValueNotify;
}

-(void) setMaxValueNotify:(NSInteger)maxValueNotify{
    
    THTemperatureSensor * temperatureSensor = (THTemperatureSensor*) self.simulableObject;
    temperatureSensor.maxValueNotify = maxValueNotify;
}

-(THSensorNotifyBehavior) notifyBehavior{
    
    THTemperatureSensor * temperatureSensor = (THTemperatureSensor*) self.simulableObject;
    return temperatureSensor.notifyBehavior;
}

-(void) setNotifyBehavior:(THSensorNotifyBehavior)notifyBehavior{
    THTemperatureSensor * temperatureSensor = (THTemperatureSensor*) self.simulableObject;
    temperatureSensor.notifyBehavior = notifyBehavior;
}

-(void) willStartEdition{
    _valueLabel.visible = NO;
}

-(void) willStartSimulation{
    THTemperatureSensor * temperatureSensor = (THTemperatureSensor*) self.simulableObject;
    _value = temperatureSensor.value;
    _valueLabel.visible = YES;
    
    [super willStartSimulation];
}

-(void) addValueLabel{
    
    _valueLabel = [CCLabelTTF labelWithString:@"" fontName:kSimulatorDefaultFont fontSize:15 dimensions:kTemperatureValueLabelSize hAlignment:kCCVerticalTextAlignmentCenter];
    _valueLabel.position = ccp(self.contentSize.width/2,self.contentSize.height/2 - 75);
    _valueLabel.color = kDefaultSimulationLabelColor;
    [self addChild:_valueLabel z:1];
}

-(void) refreshUI{
    [super refreshUI];
    [self addValueLabel];
}

-(void) addToLayer:(TFLayer *)layer{
    [super addToLayer:layer];
    
    [self addValueLabel];
}

-(NSString*) description{
    return @"Temperature Sensor";
}

@end
