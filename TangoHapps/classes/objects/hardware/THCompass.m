//
//  THCompass.m
//  TangoHapps
//
//  Created by Juan Haladjian on 11/20/12.
//  Copyright (c) 2012 Juan Haladjian. All rights reserved.
//

#import "THCompass.h"
#import "THElementPin.h"
#import "IFI2CComponent.h"
#import "IFI2CRegister.h"

@implementation THCompass

#pragma mark - Initialization

-(id) init{
    self = [super init];
    if(self){
        
        [self load];
        [self loadPins];
        [self loadI2CComponent];
    }
    return self;
}

-(void) load{
    
    TFProperty * property1 = [TFProperty propertyWithName:@"accelerometerX" andType:kDataTypeInteger];
    TFProperty * property2 = [TFProperty propertyWithName:@"accelerometerY" andType:kDataTypeInteger];
    TFProperty * property3 = [TFProperty propertyWithName:@"accelerometerZ" andType:kDataTypeInteger];
    
    TFProperty * property4 = [TFProperty propertyWithName:@"heading" andType:kDataTypeFloat];
    self.properties = [NSMutableArray arrayWithObjects:property1,property2,property3,property4,nil];
    
    self.properties = [NSMutableArray arrayWithObjects:property1,property2,property3,property4,nil];
    
    TFEvent * event1 = [TFEvent eventNamed:kEventXChanged];
    event1.param1 = [TFPropertyInvocation invocationWithProperty:property1 target:self];
    TFEvent * event2 = [TFEvent eventNamed:kEventYChanged];
    event2.param1 = [TFPropertyInvocation invocationWithProperty:property2 target:self];
    TFEvent * event3 = [TFEvent eventNamed:kEventZChanged];
    event3.param1 = [TFPropertyInvocation invocationWithProperty:property3 target:self];
    
    TFEvent * event4 = [TFEvent eventNamed:kEventHeadingChanged];
    event4.param1 = [TFPropertyInvocation invocationWithProperty:property4 target:self];
    
    self.events = [NSArray arrayWithObjects:event1,event2,event3,event4,nil];
}

-(void) loadPins{
    
    THElementPin * minusPin = [THElementPin pinWithType:kElementPintypeMinus];
    minusPin.hardware = self;
    THElementPin * sclPin = [THElementPin pinWithType:kElementPintypeScl];
    sclPin.hardware = self;
    sclPin.defaultBoardPinMode = kPinModeCompass;
    THElementPin * sdaPin = [THElementPin pinWithType:kElementPintypeSda];
    sdaPin.hardware = self;
    sdaPin.defaultBoardPinMode = kPinModeCompass;
    
    THElementPin * plusPin = [THElementPin pinWithType:kElementPintypePlus];
    
    [self.pins addObject:minusPin];
    [self.pins addObject:sclPin];
    [self.pins addObject:sdaPin];
    [self.pins addObject:plusPin];
}

-(IFI2CComponent*) loadI2CComponent{
    
    self.i2cComponent = [[IFI2CComponent alloc] init];
    self.i2cComponent.address = 24;
    
    IFI2CRegister * reg1 = [[IFI2CRegister alloc] init];
    reg1.number = 32;
    
    IFI2CRegister * reg2 = [[IFI2CRegister alloc] init];
    reg2.number = 40;
    
    [self.i2cComponent addRegister:reg1];
    [self.i2cComponent addRegister:reg2];
    
    [reg2 addObserver:self forKeyPath:@"value" options:NSKeyValueObservingOptionNew context:nil];
    
    return self.i2cComponent;
}

#pragma mark - Archiving

-(id)initWithCoder:(NSCoder *)decoder{
    
    self = [super initWithCoder:decoder];
    if(self){
        [self load];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder{
    [super encodeWithCoder:coder];
}

-(id)copyWithZone:(NSZone *)zone{
    THCompass * copy = [super copyWithZone:zone];
    
    return copy;
}

#pragma mark - Methods

-(void) setValuesFromBuffer:(uint8_t*) buffer length:(NSInteger) length{
    
    self.accelerometerX = ((int16_t)(buffer[1] << 8 | buffer[0])) >> 4;
    self.accelerometerY = ((int16_t)(buffer[3] << 8 | buffer[2])) >> 4;
    self.accelerometerZ = ((int16_t)(buffer[5] << 8 | buffer[4])) >> 4;
}

-(void) setAccelerometerX:(NSInteger)accelerometerX{
    if(accelerometerX != _accelerometerX){
        _accelerometerX = accelerometerX;
        //NSLog(@"new x: %d",_x);
        
        [self triggerEventNamed:kEventXChanged];
    }
}

-(void) setAccelerometerY:(NSInteger)accelerometerY{
    if(accelerometerY != _accelerometerY){
        _accelerometerY = accelerometerY;
        //NSLog(@"new y: %d",_y);
        
        [self triggerEventNamed:kEventYChanged];
    }
}

-(void) setAccelerometerZ:(NSInteger)accelerometerZ{
    if(accelerometerZ != _accelerometerZ){
        _accelerometerZ = accelerometerZ;
        //NSLog(@"new z: %d",_z);
        
        [self triggerEventNamed:kEventZChanged];
    }
}

-(void) setHeading:(NSInteger)heading{
    if(heading != _heading){
        _heading = heading;
        [self triggerEventNamed:kEventHeadingChanged];
    }
}

-(void) didStartSimulating{
    [self triggerEventNamed:kEventXChanged];
    [self triggerEventNamed:kEventYChanged];
    [self triggerEventNamed:kEventZChanged];
    
    [self triggerEventNamed:kEventHeadingChanged];
    
    [super didStartSimulating];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if([keyPath isEqualToString:@"value"]){
        IFI2CRegister * reg = object;
        [self setValuesFromBuffer:(uint8_t*)reg.value.bytes length:reg.value.length];
    }
}

-(NSString*) description{
    return @"compass";
}

-(void) prepareToDie{
    IFI2CRegister * reg = [self.i2cComponent.registers objectAtIndex:1];
    [reg removeObserver:self forKeyPath:@"value"];
    
    self.i2cComponent = nil;
}
@end
