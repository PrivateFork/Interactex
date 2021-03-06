/*
THPaletteViewController.h
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

#import <UIKit/UIKit.h>
#import "THPaletteItem.h"
#import "THPalette.h"
#import "THTabbarSection.h"
#import "THTabbarView.h"
#import "THEditor.h"

@class PaletteItemContainer;
@class THDraggedPaletteItem;
@class THTabbarSection;
@class THTabbarView;

typedef enum {
    kDraggingInTab,
    kDraggingInEditor
} TFDraggingState;

@interface THPaletteViewController : UIViewController
<THPaletteDragDelegate, THPaletteEditionDelegate, THEditorDragDelegate, TFTabbarViewDataSource, TFTabBarViewDelegate> {
    THDraggedPaletteItem * _dragView;
    THDraggedPaletteItem * _editorDragView;
    
    NSMutableArray * _customPaletteItems;
    THTabbarSection * _selectedSection;
}

@property (nonatomic, weak) id<TFPaletteViewControllerDelegate> delegate;
@property (nonatomic, readonly) THPaletteItem * currentPaletteItem;
@property (nonatomic, readonly) THTabbarView * tabView;
@property (nonatomic) BOOL isEditing;

@property (nonatomic, strong) NSArray * clothesSectionArray;
@property (nonatomic, strong) NSArray * uiSectionArray;
@property (nonatomic, strong) NSArray * boardsSectionArray;
@property (nonatomic, strong) NSArray * hardwareSectionArray;
@property (nonatomic, strong) NSArray * variablesSectionArray;
@property (nonatomic, strong) NSArray * programmingSectionArray;
@property (nonatomic, strong) NSArray * signalProcessingArray;
@property (nonatomic, strong) NSArray * comparisonOperatorsArray;
@property (nonatomic, strong) NSArray * arithmeticSectionArray;

@property (nonatomic, strong) NSMutableArray * customComponentsSectionArray;

@property (nonatomic, copy) NSString * clothesSectionName;
@property (nonatomic, copy) NSString * uiSectionArrayName;
@property (nonatomic, copy) NSString * boardsSectionName;
@property (nonatomic, copy) NSString * hardwareSectionName;
@property (nonatomic, copy) NSString * variablesSectionName;
@property (nonatomic, copy) NSString * programmingSectionName;
@property (nonatomic, copy) NSString * signalProcessingName;
@property (nonatomic, copy) NSString * comparisonOperatorsSectionName;
@property (nonatomic, copy) NSString * arithmeticSectionName;
@property (nonatomic, copy) NSString * customComponentsSectionName;

@property (nonatomic, strong) NSMutableArray * sections;
@property (nonatomic, strong) NSMutableArray * sectionNames;

-(void) reloadCustomProgrammingObjects;
-(void) reloadPalettes;
-(void) useDefaultPaletteSections;
-(void) addCustomPaletteItems;
-(void) save;
-(void) prepareToDie;

@end
