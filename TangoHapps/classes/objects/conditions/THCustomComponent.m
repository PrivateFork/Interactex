/*
 THCustomComponent.m
 Interactex Designer
 
 Created by Juan Haladjian on 23/06/15.
 
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


#import "THCustomComponent.h"
//#import "Interactex-Swift.h"
#import "THAccelerometerData.h"
@import JavaScriptCore;

@implementation THCustomComponent


-(id) init{
    self = [super init];
    if(self){
        [self loadCustomComponent];
        
    }
    return self;
}

-(void) loadCustomComponent{
    TFMethod * method = [TFMethod methodWithName:@"execute"];
    method.numParams = 1;
    method.firstParamType = kDataTypeAny;
    
    self.methods = [NSMutableArray arrayWithObjects:method,nil];
    
    TFEvent * event = [TFEvent eventNamed:kEventExecutionFinished];
    TFProperty * property = [[TFProperty alloc] initWithName:@"result" andType:kDataTypeAny];
    
    event.param1 = [TFPropertyInvocation invocationWithProperty:property target:self];
    self.events = [NSMutableArray arrayWithObjects:event,nil];
}

#pragma mark - Archiving

-(id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if(self){
        
        self.name = [decoder decodeObjectForKey:@"name"];
        self.code = [decoder decodeObjectForKey:@"code"];
        
        [self loadCustomComponent];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
    [coder encodeObject:self.name forKey:@"name"];
    [coder encodeObject:self.code forKey:@"code"];
}

-(id)copyWithZone:(NSZone *)zone {
    THCustomComponent * copy = [super copyWithZone:zone];
    copy.name = self.name;
    copy.code = self.code;
    return copy;
}

-(NSString*) expandJavascriptWithInputFrom:(id) param{
    if([param isKindOfClass:[NSArray class]]){
        NSString * string = @"var data = [";
        
        NSArray * data = param;
        for(int i = 0 ; i < (int) (data.count-1) ; i++){
            THAccelerometerData * acceleration = [data objectAtIndex:i];
            string = [string stringByAppendingFormat:@"%f,",acceleration.y];
        }
        if(data.count > 0){
            THAccelerometerData * acceleration = [data objectAtIndex:data.count-1];
            string = [string stringByAppendingFormat:@"%f",acceleration.y];
        }
        
        string = [string stringByAppendingFormat:@"];\n"];
        
        return [string stringByAppendingFormat:@"%@",self.code];
    }
    
    return self.code;
}

-(NSString*) expandJSWithFunctionCall:(NSString*) code{
    
    return [NSString stringWithFormat:@"function myFunction(data){%@} myFunction(data);",code];
}

-(void) execute:(id) param{
    /*
    NSString * newCode = [self expandJavascriptWithInputFrom:param];
    //newCode = [self expandJSWithFunctionCall:newCode];
    
    NSLog(@"%@",newCode);
    
    THJavascriptRunner * javascriptRunner = [THJavascriptRunner sharedInstance];

    JSValue * result = [javascriptRunner execute:newCode];
    _result = result.description;
    
    [super triggerEventNamed:kEventExecutionFinished];*/
}


-(NSString*) description{
    return @"customComponent";
}

@end
