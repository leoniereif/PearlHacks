//
//  ViewController.m
//  EpiCon
//
//  Created by Leonie Reif on 02/04/16.
//  Copyright © 2016 Leonie Reif. All rights reserved.
//

#import "ViewController.h"
#import <MyoKit/MyoKit.h>
#import <MessageUI/MessageUI.h> 
#import <MessageUI/MFMailComposeViewController.h>

@interface ViewController ()

- (IBAction)didTapConnect:(id)sender;

@end

@implementation ViewController

int countdown = 10;

- (id)init {
    // Initialize our view controller with a nib (see TLHMViewController.xib).
    self = [super initWithNibName:@"TLHMViewController" bundle:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Data notifications are received through NSNotificationCenter.
    // Posted whenever a TLMMyo connects
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didConnectDevice:)
                                                 name:TLMHubDidConnectDeviceNotification
                                               object:nil];
    // Posted whenever a TLMMyo disconnects.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDisconnectDevice:)
                                                 name:TLMHubDidDisconnectDeviceNotification
                                               object:nil];
    // Posted whenever the user does a successful Sync Gesture.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSyncArm:)
                                                 name:TLMMyoDidReceiveArmSyncEventNotification
                                               object:nil];
    // Posted whenever Myo loses sync with an arm (when Myo is taken off, or moved enough on the user's arm).
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUnsyncArm:)
                                                 name:TLMMyoDidReceiveArmUnsyncEventNotification
                                               object:nil];
    // Posted whenever Myo is unlocked and the application uses TLMLockingPolicyStandard.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUnlockDevice:)
                                                 name:TLMMyoDidReceiveUnlockEventNotification
                                               object:nil];
    // Posted whenever Myo is locked and the application uses TLMLockingPolicyStandard.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLockDevice:)
                                                 name:TLMMyoDidReceiveLockEventNotification
                                               object:nil];
    // Posted when a new orientation event is available from a TLMMyo. Notifications are posted at a rate of 50 Hz.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveOrientationEvent:)
                                                 name:TLMMyoDidReceiveOrientationEventNotification
                                               object:nil];
    // Posted when a new accelerometer event is available from a TLMMyo. Notifications are posted at a rate of 50 Hz.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveAccelerometerEvent:)
                                                 name:TLMMyoDidReceiveAccelerometerEventNotification
                                               object:nil];
    // Posted when a new pose is available from a TLMMyo.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivePoseChange:)
                                                 name:TLMMyoDidReceivePoseChangedNotification
                                               object:nil];
    
    graphView = [[GraphView alloc]initWithFrame:CGRectMake(10, 160, self.view.frame.size.width-20, 180)];
    [graphView setBackgroundColor:[UIColor whiteColor]];
    [graphView setSpacing:5];
    [graphView setFill:YES];
    [graphView setStrokeColor:[UIColor blueColor]];
    [graphView setZeroLineStrokeColor:[UIColor whiteColor]];
    [graphView setFillColor:[UIColor whiteColor]];
    [graphView setLineWidth:1];
    [graphView setCurvedLines:YES];
    //[graphView setNumberOfPointsInGraph:3];
    [self.view addSubview:graphView];
    graphView.hidden = YES;
    connectButton.hidden = NO;
    
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self
               action:@selector(month)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Show View" forState:UIControlStateNormal];
    button.frame = CGRectMake(20, 60, 160.0, 40.0);
    [button setBackgroundColor:[UIColor blueColor]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:button];
    button.hidden = YES;

}

- (void)month {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Monthly Report.png"]];
    [self.view addSubview:imageView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NSNotificationCenter Methods

- (void)didConnectDevice:(NSNotification *)notification {
    // Access the connected device.
    TLMMyo *myo = notification.userInfo[kTLMKeyMyo];
    NSLog(@"Connected to %@.", myo.name);
    
    // Align our label to be in the center of the view.
    //[self.helloLabel setCenter:self.view.center];
    
    // Set the text of the armLabel to "Perform the Sync Gesture".
    //self.armLabel.text = @"Perform the Sync Gesture";
    
    // Set the text of our helloLabel to be "Hello Myo".
    //self.helloLabel.text = @"Hello Myo";
    
    // Show the acceleration progress bar
    //[self.accelerationProgressBar setHidden:NO];
    //[self.accelerationLabel setHidden:NO];
    
    
    graphView.hidden = NO;
    connectButton.hidden = YES;
    button.hidden = NO;
    

}

- (void)didDisconnectDevice:(NSNotification *)notification {
    // Access the disconnected device.
    TLMMyo *myo = notification.userInfo[kTLMKeyMyo];
    NSLog(@"Disconnected from %@.", myo.name);
    
    // Remove the text from our labels when the Myo has disconnected.
    //self.helloLabel.text = @"";
    //self.armLabel.text = @"";
    //self.lockLabel.text = @"";
    
    // Hide the acceleration progress bar.
    //[self.accelerationProgressBar setHidden:YES];
    //[self.accelerationLabel setHidden:YES];
}

- (void)didUnlockDevice:(NSNotification *)notification {
    // Update the label to reflect Myo's lock state.
    //self.lockLabel.text = @"Unlocked";
}

- (void)didLockDevice:(NSNotification *)notification {
    // Update the label to reflect Myo's lock state.
    //self.lockLabel.text = @"Locked";
}

- (void)didSyncArm:(NSNotification *)notification {
    // Retrieve the arm event from the notification's userInfo with the kTLMKeyArmSyncEvent key.
    TLMArmSyncEvent *armEvent = notification.userInfo[kTLMKeyArmSyncEvent];
    
    // Update the armLabel with arm information.
    //NSString *armString = armEvent.arm == TLMArmRight ? @"Right" : @"Left";
    //NSString *directionString = armEvent.xDirection == TLMArmXDirectionTowardWrist ? @"Toward Wrist" : @"Toward Elbow";
    //self.armLabel.text = [NSString stringWithFormat:@"Arm: %@ X-Direction: %@", armString, directionString];
    
    //self.lockLabel.text = @"Locked";
}

- (void)didUnsyncArm:(NSNotification *)notification {
    // Reset the labels.
    //self.armLabel.text = @"Perform the Sync Gesture";
    //self.helloLabel.text = @"Hello Myo";
    //self.lockLabel.text = @"";
    //self.helloLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:50];
    //self.helloLabel.textColor = [UIColor blackColor];
}

- (void)didReceiveOrientationEvent:(NSNotification *)notification {
    // Retrieve the orientation from the NSNotification's userInfo with the kTLMKeyOrientationEvent key.
    TLMOrientationEvent *orientationEvent = notification.userInfo[kTLMKeyOrientationEvent];
    
    // Create Euler angles from the quaternion of the orientation.
    TLMEulerAngles *angles = [TLMEulerAngles anglesWithQuaternion:orientationEvent.quaternion];
    
    // Next, we want to apply a rotation and perspective transformation based on the pitch, yaw, and roll.
    CATransform3D rotationAndPerspectiveTransform = CATransform3DConcat(CATransform3DConcat(CATransform3DRotate (CATransform3DIdentity, angles.pitch.radians, -1.0, 0.0, 0.0), CATransform3DRotate(CATransform3DIdentity, angles.yaw.radians, 0.0, 1.0, 0.0)), CATransform3DRotate(CATransform3DIdentity, angles.roll.radians, 0.0, 0.0, -1.0));
    
    
    
    // Apply the rotation and perspective transform to helloLabel.
    //self.helloLabel.layer.transform = rotationAndPerspectiveTransform;
}

- (void)didReceiveAccelerometerEvent:(NSNotification *)notification {
    // Retrieve the accelerometer event from the NSNotification's userInfo with the kTLMKeyAccelerometerEvent.
    TLMAccelerometerEvent *accelerometerEvent = notification.userInfo[kTLMKeyAccelerometerEvent];
    
    // Get the acceleration vector from the accelerometer event.
    TLMVector3 accelerationVector = accelerometerEvent.vector;
    
    // Calculate the magnitude of the acceleration vector.
    float magnitude = TLMVector3Length(accelerationVector);
    
    // Update the progress bar based on the magnitude of the acceleration vector.
    //self.accelerationProgressBar.progress = magnitude / 8;
    
    //Note you can also access the x, y, z values of the acceleration (in G's) like below
    float x = accelerationVector.x;
    float y = accelerationVector.y;
    float z = accelerationVector.z;
    
    //NSLog(@"X=%f, Y=%f, Z=%f", x, y, z);
    [graphView setPoint:(float) sqrtf(pow(x,2)+pow(y,2)+pow(z,2)) ];
    
    NSLog(@"%f", magnitude);
    
    if (magnitude > 5.6) {
        NSLog(@"EMERGENCY NOTIFICATION");
        //Create UIAlertView alert
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"ALERT"
                                                                       message:@"You are having a seizure. \r Message to emergency contact will be sent in 10 seconds."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [NSTimer scheduledTimerWithTimeInterval:1.0
                                         target:self
                                       selector:@selector(updateAlertMessage:)
                                       userInfo:alert
                                        repeats:YES];
        
        UIAlertAction* sendNotificationAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                                  [self sendEmergencyMessage:self];
        
                                                                                                                                  
                                                              
                                                              }];
    
        UIAlertAction* cancelNotificationAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction * action) {
                                                                  
                                                              ;
                                                              }];
        
        [alert addAction:sendNotificationAction];
        [alert addAction:cancelNotificationAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

- (void)updateAlertMessage:(NSTimer *) timer
{
    NSString *str = [NSString stringWithFormat:@"You are having a seizure. \r Message to emergency contact will be sent in %d seconds.", countdown];
    UIAlertController *alert = (UIAlertController *) timer.userInfo;
    alert.message = str;
    countdown--;
    if (countdown == 0) {
        timer.invalidate;
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissModalViewControllerAnimated:YES];
}



- (void)sendEmergencyMessage:(id)sender {
    NSLog(@"Sending Emergency Message.");

    // Common constants
    NSString *kTwilioSID = @"AC2ed5135e651a1bfa29789d01a91daec7";//@"AC2c314c5b613b26d72ae0b712a2d2a7d0";//@"SK872b6dcead382f7ff2de3e80715b0e28";
    NSString *kTwilioSecret = @"2cbe7934b1b4f519222fefc50a115d55"; //@"73e888b8a00a7baa91eff4e308674ac4";//@"HMAFJhPD7TcOaF37t9JakkbMlLWWAjYg";
    NSString *kFromNumber = @"2015089784"; //@"+15005550006";
    NSString *kToNumber = @"%2B17744208009";
    NSString *kMessage=@"ALERT - SEIZURE DETECTED FROM ADAM'S DEVICE AT #TIMESTAMP #TIMEDATE";
    
    // Build request
    NSString *urlString = [NSString stringWithFormat:@"https://%@:%@@api.twilio.com/2010-04-01/Accounts/%@/SMS/Messages", kTwilioSID, kTwilioSecret, kTwilioSID];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    
    // Set up the body  MediaUrl
    NSString *bodyString = [NSString stringWithFormat:@"From=%@&To=%@&Body=%@", kFromNumber, kToNumber, kMessage];
    NSData *data = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    NSError *error;
    NSURLResponse *response;
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // The server answers with an error because it doesn't receive the params
        if(error) {
            NSLog(error);
        } else {
            NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"success %@", s);
        }
    }];
    [postDataTask resume];
    
    /*NSData *receivedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    // Handle the received data
    if (error) {
        NSLog(@"Error: %@", error);
    } else {
        NSString *receivedString = [[NSString alloc]initWithData:receivedData encoding:NSUTF8StringEncoding];
        NSLog(@"Request sent. %@", receivedString);
    }*/
    

}

- (void)didReceivePoseChange:(NSNotification *)notification {
    // Retrieve the pose from the NSNotification's userInfo with the kTLMKeyPose key.
    TLMPose *pose = notification.userInfo[kTLMKeyPose];
    //self.currentPose = pose;
    
    // Handle the cases of the TLMPoseType enumeration, and change the color of helloLabel based on the pose we receive.
    switch (pose.type) {
        case TLMPoseTypeUnknown:
        case TLMPoseTypeRest:
        case TLMPoseTypeDoubleTap:
            // Changes helloLabel's font to Helvetica Neue when the user is in a rest or unknown pose.
            //self.helloLabel.text = @"Hello Myo";
            //self.helloLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:50];
            //self.helloLabel.textColor = [UIColor blackColor];
            break;
        case TLMPoseTypeFist:
            // Changes helloLabel's font to Noteworthy when the user is in a fist pose.
            //self.helloLabel.text = @"Fist";
            //self.helloLabel.font = [UIFont fontWithName:@"Noteworthy" size:50];
            //self.helloLabel.textColor = [UIColor greenColor];
            break;
        case TLMPoseTypeWaveIn:
            // Changes helloLabel's font to Courier New when the user is in a wave in pose.
            //self.helloLabel.text = @"Wave In";
            //self.helloLabel.font = [UIFont fontWithName:@"Courier New" size:50];
            //self.helloLabel.textColor = [UIColor greenColor];
            break;
        case TLMPoseTypeWaveOut:
            // Changes helloLabel's font to Snell Roundhand when the user is in a wave out pose.
            //self.helloLabel.text = @"Wave Out";
            //self.helloLabel.font = [UIFont fontWithName:@"Snell Roundhand" size:50];
            //self.helloLabel.textColor = [UIColor greenColor];
            break;
        case TLMPoseTypeFingersSpread:
            // Changes helloLabel's font to Chalkduster when the user is in a fingers spread pose.
            //self.helloLabel.text = @"Fingers Spread";
            //self.helloLabel.font = [UIFont fontWithName:@"Chalkduster" size:50];
            //self.helloLabel.textColor = [UIColor greenColor];
            break;
    }
    
    // Unlock the Myo whenever we receive a pose
    if (pose.type == TLMPoseTypeUnknown || pose.type == TLMPoseTypeRest) {
        // Causes the Myo to lock after a short period.
        [pose.myo unlockWithType:TLMUnlockTypeTimed];
    } else {
        // Keeps the Myo unlocked until specified.
        // This is required to keep Myo unlocked while holding a pose, but if a pose is not being held, use
        // TLMUnlockTypeTimed to restart the timer.
        [pose.myo unlockWithType:TLMUnlockTypeHold];
        // Indicates that a user action has been performed.
        [pose.myo indicateUserAction];
    }
}


- (IBAction)didTapConnect:(id)sender {
    // Note that when the settings view controller is presented to the user, it must be in a UINavigationController.
    
    /*UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"CustomDone" style:UIBarButtonItemStyleDone target:self action:@selector(Add:)];
    
    [[TLMSettingsViewController settingsInNavigationController].navigationItem setLeftBarButtonItem:button];
    
    [TLMSettingsViewController settingsInNavigationController].navigationItem.title = @"somethingsomething";*/
    
    UINavigationController *controller = [TLMSettingsViewController settingsInNavigationController];
    // Present the settings view controller modally.
    [self presentViewController:controller animated:YES completion:nil];
    controller = [TLMSettingsViewController settingsInNavigationController];
    
}

@end
