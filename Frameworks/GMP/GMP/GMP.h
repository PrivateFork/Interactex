//
//  GMPController.h
//  iGMP
//
//  Created by Juan Haladjian on 11/6/13.
//  Copyright (c) 2013 Technical University Munich. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GMPCommunicationModule.h"

#define IFParseBufSize 1024

typedef struct
{
    uint8_t index;
    uint8_t capability;
} pin_t;

typedef struct
{
    uint8_t pins[8];
}group_t;


@class GMP;

// pin modes
// bit 0 1:digital (gpio),
// bit 3~1 001: pwm, 010: adc, 011: dac, 100: comperator
// bit 7~4 0001: uart, 0010: spi, 0100: i2c, 1000: one wire
typedef enum {
    kGMPCapabilityGPIO = 0x01,
    kGMPCapabilityPWM	= 0x02,
    kGMPCapabilityADC	= 0x04,
    kGMPCapabilityDAC	= 0x06,
    kGMPCapabilityCOMP = 0x08,
    kGMPCapabilityUART = 0x10,
    kGMPCapabilitySPI	= 0x20,
    kGMPCapabilityI2C	= 0x40,
    kGMPCapabilityOneWire = 0x80
} GMPPinCapability;

//servo?

typedef enum{
    kGMPPinModeInput = 0x00,
    kGMPPinModeOutput,
    kGMPPinModeAnalog,
    kGMPPinModePWM,
    kGMPPinModeServo,
    kGMPPinModeShift,
    kGMPPinModeI2C
} GMPPinMode;

/*
typedef enum {
    kGMPParsinStateNone,
    kGMPParsinStateFirmware
    
}GMPParsinState;*/

extern NSString * const kGMPFirmwareName;

@protocol GMPControllerDelegate <NSObject>

@optional

-(void) gmpController:(GMP*) gmpController didReceiveFirmwareName: (NSString*) name;

-(void) gmpController:(GMP*) gmpController didReceiveCapabilityResponseForPins:(uint8_t*) buffer count:(NSInteger) count;

-(void) gmpController:(GMP*) gmpController didReceivePinStateResponseForPin:(NSInteger) pin mode:(GMPPinMode) mode;

-(void) gmpController:(GMP*) gmpController didReceiveAnalogMessageForPin:(NSInteger) pin value:(NSInteger) value;

-(void) gmpController:(GMP*) gmpController didReceiveDigitalMessageForPin:(NSInteger) pin value:(BOOL) value;

-(void) gmpController:(GMP*) gmpController didReceiveI2CReplyForAddress:(NSInteger) address reg:(NSInteger) reg buffer:(uint8_t*) buffer length:(NSInteger) length;

@end

@interface GMP : NSObject
{
}

@property (nonatomic, strong) GMPCommunicationModule * communicationModule;
@property (nonatomic, weak) id<GMPControllerDelegate> delegate;

@property (nonatomic, readonly) BOOL isI2CEnabled;
//@property (nonatomic, readonly) NSInteger numberOfPins;

//Initialization / Termination
-(void) sendFirmwareRequest;
-(void) sendCapabilitiesRequest;
-(void) sendResetRequest;

//Modes
-(void) sendPinModeRequestForPin:(NSInteger) pin;
-(void) sendPinModeForPin:(NSInteger) pin mode:(GMPPinMode) mode;
-(void) sendPinModesForPins:(pin_t*) pinModes count:(NSInteger) count;

//Digital
-(void) sendDigitalOutputForPin:(NSInteger) pin value:(NSInteger) value;
-(void) sendDigitalReadForPin:(NSInteger) pin;
-(void) sendReportRequestForDigitalPin:(NSInteger) pin reports:(BOOL) reports;

//Analog
-(void) sendAnalogReadForPin:(NSInteger) pin;
-(void) sendReportRequestForAnalogPin:(NSInteger) pin reports:(BOOL) reports;
-(void) sendAnalogWriteForPin:(NSInteger) pin value:(NSInteger) value;

//I2C
-(void) sendI2CReadAddress:(NSInteger) address reg:(NSInteger) reg size:(NSInteger) size;
-(void) sendI2CStartReadingAddress:(NSInteger) address reg:(NSInteger) reg size:(NSInteger) size;
-(void) sendI2CWriteToAddress:(NSInteger) address reg:(NSInteger) reg values:(uint8_t*) values numValues:(NSInteger) numValues;

-(void) sendI2CStopStreamingAddress:(NSInteger) address;
-(void) sendI2CConfigMessage;

//Other
-(void) didReceiveData:(uint8_t *)buffer lenght:(NSInteger)originalLength;

@end
