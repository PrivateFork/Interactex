/*
GMPViewController.h
GMPDemo

Created by Juan Haladjian on 11/06/2013.

GMP is a library used to remotely control a microcontroller. GMP is based on Firmata: www.firmata.org

www.interactex.org

Copyright (C) 2013 TU Munich, Munich, Germany; DRLab, University of the Arts Berlin, Berlin, Germany; Telekom Innovation Laboratories, Berlin, Germany

Contacts:
juan.haladjian@cs.tum.edu
katharina.bredies@udk-berlin.de
opensource@telekom.de

    
It has been created with funding from EIT ICT, as part of the activity "Connected Textiles".


This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
 
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 
You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#import <UIKit/UIKit.h>

@class GMP;
@class GMPDelegate;

@interface GMPViewController : UIViewController <BLEDiscoveryDelegate, BLEServiceDelegate, GMPControllerDelegate>
{
    BOOL reportingDigital;
    BOOL reportingAnalog;
}
@property (weak, nonatomic) IBOutlet UIButton *digitalReportButton;
@property (weak, nonatomic) IBOutlet UIButton *analogReportButton;
@property (weak, nonatomic) IBOutlet UIButton *connectionButton;

- (IBAction)reconnectTapped:(id)sender;

- (IBAction)sendFirmwareTapped:(id)sender;
- (IBAction)sendModesTapped:(id)sender;
- (IBAction)sendHighTapped:(id)sender;
- (IBAction)sendLOWTapped:(id)sender;

- (IBAction)sendDigitalReadTapped:(id)sender;
- (IBAction)sendAnalogReadTapped:(id)sender;


- (IBAction)sendI2CReadTapped:(id)sender;
- (IBAction)sendI2CWriteTapped:(id)sender;

- (IBAction)sendI2CStartReadingTapped:(id)sender;

- (IBAction)sendI2CStopTapped:(id)sender;
- (IBAction)sendResetTapped:(id)sender;
- (IBAction)startDigitalReadTapped:(id)sender;
- (IBAction)startAnalogReadTapped:(id)sender;
- (IBAction)sendAnalogOutputTapped:(id)sender;

@property (weak, nonatomic) IBOutlet UITextView *textField;

@property (nonatomic, strong) GMP * gmpController;
@property (nonatomic, strong) GMPDelegate * gmpDelegate;

@end
