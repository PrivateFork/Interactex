/*
IFViewController.h
iFirmata

Created by Juan Haladjian on 27/06/2013.

iFirmata is an App to control an Arduino board over Bluetooth 4.0. iFirmata uses the Firmata protocol: www.firmata.org

www.interactex.org

Copyright (C) 2013 TU Munich, Munich, Germany; DRLab, University of the Arts Berlin, Berlin, Germany; Telekom Innovation Laboratories, Berlin, Germany
	
Contacts:
juan.haladjian@cs.tum.edu
katharina.bredies@udk-berlin.de
opensource@telekom.de

    
It has been created with funding from EIT ICT, as part of the activity "Connected Textiles".


This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 
You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#import <UIKit/UIKit.h>
#import "IFPinsController.h"
#import "IFI2CLSM303ViewController.h"

@class IFPinsController;
@class CBPeripheral;

enum{
    kTableGroupIdxDigital,
    kTableGroupIdxAnalog,
    kTableGroupIdxI2C,
    kTableGroupIdxCharacteristics
};

@interface IFViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, IFFirmataControllerPinsDelegate, UIActionSheetDelegate>
{
    BOOL connected;
    BOOL goingToI2CScene;
}

@property (weak, nonatomic) IFPinsController * firmataPinsController;
@property (weak, nonatomic) IBOutlet UITableView * table;

- (IBAction) optionsMenuTapped:(id)sender;

@end
