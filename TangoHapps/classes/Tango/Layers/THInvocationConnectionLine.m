/*
THInvocationConnectionLine.m
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

#import "THInvocationConnectionLine.h"
#import "TFConnectionLine.h"
#import "THEditor.h"
#import "THInvocationConnectionProperties.h"

@implementation THInvocationConnectionLine

NSString * const invocationConnectionLineSpriteNames[THInvocationConnectionLineNumStates][kNumDataTypes] = {
    {@"circleEmpty", @"squareEmpty", @"squareEmpty", @"triangleEmpty", @"starEmpty"},
    {@"circleFilled", @"squareFilled", @"squareFilled", @"triangleFilled", @"starFilled"}};


#pragma mark - Initialization

-(id) initWithObj1:(TFEditableObject*) obj1 obj2:(TFEditableObject*) obj2{
    self = [super init];
    if(self){
        self.obj1 = obj1;
        self.obj2 = obj2;
        
        [self loadConnectionLine];
    }
    return self;
}

-(id) init{
    self = [super init];
    if(self){
        
        [self loadConnectionLine];
    }
    return self;
}

-(void) loadConnectionLine{
    self.canBeScaled = NO;
    self.canBeMoved = NO;
    self.z = kGestureObjectZ;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEditableObjectRemoved:) name:kNotificationObjectRemoved object:nil];
}

#pragma mark - Archiving

-(id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(self) {
        self.numParameters = [decoder decodeIntegerForKey:@"numParameters"];
        self.state = [decoder decodeIntegerForKey:@"state"];
        self.parameterType = [decoder decodeIntegerForKey:@"parameterType"];
        self.action = [decoder decodeObjectForKey:@"action"];
        self.obj1 = [decoder decodeObjectForKey:@"obj1"];
        self.obj2 = [decoder decodeObjectForKey:@"obj2"];
        self.lineCenter = [decoder decodeCGPointForKey:@"lineCenter"];
        
        [self loadConnectionLine];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:self.numParameters forKey:@"numParameters"];
    [coder encodeInteger:self.state forKey:@"state"];
    [coder encodeInteger:self.parameterType forKey:@"parameterType"];
    [coder encodeObject:self.action forKey:@"action"];
    [coder encodeObject:self.obj1 forKey:@"obj1"];
    [coder encodeObject:self.obj2 forKey:@"obj2"];
    [coder encodeCGPoint:self.lineCenter forKey:@"lineCenter"];
}


#pragma mark - Property Controller

-(NSArray*)propertyControllers {
    NSMutableArray *controllers = [NSMutableArray array];
    [controllers addObject:[THInvocationConnectionProperties properties]];
    [controllers addObjectsFromArray:[super propertyControllers]];
    return controllers;
}

#pragma mark - Methods

-(void)handleEditableObjectRemoved:(NSNotification *)notification{
    TFEditableObject * object = notification.object;
    if(object == self.action.firstParam.target){
        self.state = THInvocationConnectionLineStateIncomplete;
        [self reloadSprite];
    }
}

-(void) reloadSprite{
    if(self.numParameters == 1){
        
        [_invocationStateSprite removeFromParentAndCleanup:YES];
        NSString * spriteName = invocationConnectionLineSpriteNames[self.state][self.parameterType];
        spriteName = [spriteName stringByAppendingString:@".png"];
        _invocationStateSprite = [CCSprite spriteWithFile:spriteName];
        _invocationStateSprite.position = self.lineCenter;
        [self addChild:_invocationStateSprite];
    }
    
    _arrowSprite = [CCSprite spriteWithFile:@"connectionArrow.png"];
    _arrowSprite.position = self.obj2.position;
    [self addChild:_arrowSprite];
}

-(void) setLineCenter:(CGPoint)lineCenter{
    _invocationStateSprite.position = lineCenter;
    _lineCenter = lineCenter;
}

-(void) startDrawingSelectedLines{
    
    ccDrawColor4F(1.0, 0.5, 0.5, 1.0);
    glLineWidth(kLineWidthSelected);
}

-(void) startDrawingNormalLines{
    
    ccDrawColor4F(kConnectionLineDefaultColor.r/255.0f, kConnectionLineDefaultColor.g/255.0f, kConnectionLineDefaultColor.b/255.0f, 1.0f); //nazmus updated - value was inappropriate for ccDrawColor4F
    glLineWidth(kLineWidthNormal);
}


-(void) drawLines{
    if(self.selected){
        [self startDrawingSelectedLines];
    } else {
        [self startDrawingNormalLines];
    }
    
    CGPoint p1 = self.obj1.center;
    CGPoint p2 = self.obj2.center;
    
    ccDrawLine(p1, self.lineCenter);
    
    ccDrawCircle(p1, 3, 0, 5, NO);
    _arrowSprite.position = p2;
    /*
    float a = (p1.y - p2.y) / (p1.x-p2.x);
    float b = (p1.y-a) / p1.x;*/
    CGPoint arrowPos = ccpSub(p2,p1);
    arrowPos = ccpMult(arrowPos, 0.90);
    arrowPos = ccpAdd(arrowPos,p1);
    ccDrawLine(self.lineCenter,arrowPos);
    
    float angle = ccpAngleSigned(ccp(0,1), ccpSub(p2,p1));
    _arrowSprite.rotation = CC_RADIANS_TO_DEGREES(-angle);
    _arrowSprite.position = arrowPos;
//    ccDrawCircle(p2, 3, 0, 5, NO);
    //ccDrawArc(p2, 5, 10, 10, 5, 0);
    
    TFEditableObject * invocationParameter = (TFEditableObject*)self.action.firstParam.target;
    if(invocationParameter){
        CGPoint p3 = invocationParameter.center;
        ccDrawLine(p3, self.lineCenter);
    }
}

-(void) draw{
    //_invocationStateSprite.position = [self calculateLineCenter];
    _invocationStateSprite.position = self.lineCenter;
    
    
    [self drawLines];
    
    if(self.selected){
        float kSelectionPadding = 5;
        
        CGRect box = _invocationStateSprite.boundingBox;
        CGSize rectSize = CGSizeMake(box.size.width + kSelectionPadding * 2, box.size.height + kSelectionPadding * 2);
        
        CGPoint point = box.origin;
        point = [self convertToNodeSpace:point];
        point = ccpSub(point, ccp(kSelectionPadding, kSelectionPadding));
        
        ccDrawRect(point, ccp(point.x + rectSize.width, point.y + rectSize.height));
    }
}

#pragma mark - Layer

-(void) addToLayer:(TFLayer *)layer{
    [layer addEditableObject:self];
    
    [self reloadSprite];
}

-(void) removeFromLayer:(TFLayer *)layer{
    [layer removeEditableObject:self];
}

-(void) removeFromWorld{
    THProject * project = [THDirector sharedDirector].currentProject;
    [project removeInvocationConnection:self];
    [project deregisterAction:self.action];
    [super removeFromWorld];
    
}

-(BOOL) testPoint:(CGPoint)point{
    if(self.visible && CGRectContainsPoint(_invocationStateSprite.boundingBox, point)){
    //if(self.visible && ccpDistance(_invocationStateSprite.position, point) < 40){
        return YES;
    }
    return NO;
}


#pragma mark - Cleanup

-(void) prepareToDie{
    
    [super prepareToDie];
}

-(NSString*) description{
    return @"invocation connection line";
}

-(void) dealloc{
    [self prepareToDie];
    
}

@end
