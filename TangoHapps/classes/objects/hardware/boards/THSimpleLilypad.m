/*
 THSimpleLilypad.m
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
 
 
 This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "THSimpleLilyPad.h"
#import "THBoardPin.h"
#import "I2CComponent.h"
#import "THHardwareComponent.h"
#import "THElementPin.h"

@implementation THSimpleLilypad

@dynamic minusPin;
@dynamic plusPin;
@dynamic sclPin;
@dynamic sdaPin;

-(void) load{
    _numberOfDigitalPins = 5;
    _numberOfAnalogPins = 4;
}

-(void) loadPins{
    
    THBoardPin * pin2 = [THBoardPin pinWithPinNumber:2 andType:kPintypeDigital];
    THBoardPin * pin3 = [THBoardPin pinWithPinNumber:3 andType:kPintypeDigital];
    THBoardPin * pin9 = [THBoardPin pinWithPinNumber:9 andType:kPintypeDigital];
    THBoardPin * pin10 = [THBoardPin pinWithPinNumber:10 andType:kPintypeDigital];
    THBoardPin * pin11 = [THBoardPin pinWithPinNumber:11 andType:kPintypeDigital];
    
    pin2.isPWM = YES;
    pin3.isPWM = YES;
    pin9.isPWM = YES;
    pin10.isPWM = YES;
    pin11.isPWM = YES;
    
    [_pins addObject:pin2];
    [_pins addObject:pin3];
    [_pins addObject:pin9];
    [_pins addObject:pin10];
    [_pins addObject:pin11];
    
    THBoardPin * minusPin = [THBoardPin pinWithPinNumber:-1 andType:kPintypeMinus];
    [_pins addObject:minusPin];
    
    THBoardPin * plusPin = [THBoardPin pinWithPinNumber:-1 andType:kPintypePlus];
    [_pins addObject:plusPin];
    
    for (int i = 2; i <= 5; i++) {
        THBoardPin * pin = [THBoardPin pinWithPinNumber:i andType:kPintypeAnalog];
        [_pins addObject:pin];
    }
}

-(id) init{
    self = [super init];
    if(self){
        
        _pins = [NSMutableArray array];
        _i2cComponents = [NSMutableArray array];
        
        [self load];
        [self loadPins];
    }
    return self;
}

#pragma mark - Archiving

-(id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    _pins = [decoder decodeObjectForKey:@"pins"];
    [self load];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:_pins forKey:@"pins"];
}

-(id)copyWithZone:(NSZone *)zone {
    THSimpleLilypad * copy = [super copyWithZone:zone];
    
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:_pins.count];
    for (THPin * pin in _pins) {
        THPin * copy = [pin copy];
        [array addObject:copy];
    }
    copy.pins = array;
    
    return copy;
}

#pragma mark - Pins

-(NSMutableArray*) analogPins{
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:self.numberOfAnalogPins];
    for (int i = 0; i < self.numberOfAnalogPins; i++) {
        THBoardPin * pin = [self analogPinWithNumber:i];
        [array addObject:pin];
    }
    return array;
}

-(NSMutableArray*) digitalPins{
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:self.numberOfDigitalPins];
    for (int i = 0; i < self.numberOfDigitalPins; i++) {
        THBoardPin * pin = [self digitalPinWithNumber:i];
        [array addObject:pin];
    }
    return array;
}

-(THBoardPin*) minusPin{
    return [_pins objectAtIndex:4];
}

-(THBoardPin*) plusPin{
    return [_pins objectAtIndex:5];
}

-(THBoardPin*) sclPin{
    return [self analogPinWithNumber:3];
}

-(THBoardPin*) sdaPin{
    return [self analogPinWithNumber:2];
}

/*
 -(BOOL) supportsSCL{
 return (self.type == kPintypeAnalog && self.number == 5);
 }
 
 -(BOOL) supportsSDA{
 return (self.type == kPintypeAnalog && self.number == 4);
 }*/

-(NSInteger) realIdxForPin:(THBoardPin*) pin{
    
    if(pin.type == kPintypeDigital){
        return pin.number;
    } else {
        return pin.number + self.numberOfDigitalPins;
    }
}

-(THBoardPin*) pinWithRealIdx:(NSInteger) pinNumber{
    NSInteger pinidx;
    
    if(pinNumber <= self.numberOfDigitalPins){
        return [self digitalPinWithNumber:pinNumber];
    } else {
        return [self analogPinWithNumber:pinNumber - self.numberOfDigitalPins];
    }
    return [self.pins objectAtIndex:pinidx];
}

-(NSInteger) pinIdxForPin:(NSInteger) pinNumber ofType:(THPinType) type{
    if(type == kPintypeDigital){
        if(pinNumber <= 4) {
            return pinNumber;
        } else if(pinNumber <= self.numberOfDigitalPins){
            return pinNumber + 2;
        }
        
        return pinNumber;
    } else if(type == kPintypeAnalog){
        if(pinNumber >= 0 && pinNumber <= 5){
            return pinNumber + 16;
        }
    } else if(type == kPintypeMinus){
        return 5;
    } else if(type == kPintypePlus){
        return 6;
    }
    
    return -1;
}

-(THBoardPin*) digitalPinWithNumber:(NSInteger) number{
    NSInteger idx = [self pinIdxForPin:number ofType:kPintypeDigital];
    if(idx >= 0){
        return [_pins objectAtIndex:idx];
    }
    return nil;
}

-(THBoardPin*) analogPinWithNumber:(NSInteger) number{
    
    NSInteger idx = [self pinIdxForPin:number ofType:kPintypeAnalog];
    if(idx >= 0){
        return [_pins objectAtIndex:idx];
    }
    return nil;
}

-(NSArray*) objectsAtPin:(NSInteger) pinNumber{
    THBoardPin * pin = _pins[pinNumber];
    return pin.attachedElementPins;
}

-(void) attachPin:(THElementPin*) object atPin:(NSInteger) pinNumber{
    THBoardPin * pin = [_pins objectAtIndex:pinNumber];
    [pin attachPin:object];
    
    if(object.hardware.i2cComponent && (pin.supportsSCL || pin.supportsSDA)){
        
        if((pin.supportsSCL && [self.sdaPin isClotheObjectAttached:object.hardware]) ||
           (pin.supportsSDA && [self.sclPin isClotheObjectAttached:object.hardware])) {
            
            [self addI2CCOmponent:object.hardware.i2cComponent];
        }
    }
}

#pragma mark - I2C Components

-(void) addI2CCOmponent:(I2CComponent*) component{
    [self.i2cComponents addObject:component];
}

-(void) removeI2CCOmponent:(I2CComponent*) component{
    [self.i2cComponents removeObject:component];
}

-(I2CComponent*) I2CComponentWithAddress:(NSInteger) address{
    
    for (I2CComponent * component in self.i2cComponents) {
        if(component.address == address){
            return component;
        }
    }
    return nil;
}

#pragma mark - Other

-(NSString*) description{
    return @"lilypad";
}

-(void) prepareToDie{
    for (THBoardPin * pin in self.pins) {
        [pin prepareToDie];
    }
    _pins = nil;
    [super prepareToDie];
}

@end
