//
//  HIDController.m
//  SiriHIDRemote
//
//  Created by Adam Gastineau on 11/29/15.
//  Copyright © 2015 AppCannon Software. All rights reserved.
//

#import "HIDController.h"

#import <HIDKit/HIDKit.h>

@interface HIDController ()

@property (strong, nonatomic) NSMutableArray *siriRemotes;

@end

@implementation HIDController

+ (id)sharedInstance
{
    // structure used to test whether the block has completed or not
    static dispatch_once_t p = 0;
    
    // initialize sharedObject as nil (first call only)
    __strong static id _sharedObject = nil;
    
    // executes a block object once and only once for the lifetime of an application
    dispatch_once(&p, ^{
        _sharedObject = [[self alloc] init];
    });
    
    // returns the same object each time
    return _sharedObject;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.siriRemotes = [NSMutableArray array];
        
        [HIDManager sharedManager];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceConnectedNotification:) name:HIDManagerDeviceDidConnectNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(elementValueUpdateNotification:) name:HIDManagerElementValueDidUpdateNotification object:nil];
    }
    return self;
}

- (void)deviceConnectedNotification:(NSNotification *)notification
{
    HIDDevice *device = [notification object];
    
    // TODO: Replace constant "DL5QD2HMGQQT" with a better way of finding the correct HIDDevice object
    if([device productID] == 0x0266 && [device vendorID] == 0x4C && [[device transport] isEqualToString:@"BluetoothLowEnergy"] && [[device serialNumber] isEqualToString:@"DL5QD2HMGQQT"]) {
        [self.siriRemotes addObject:device];
        
        
        [device open];
        NSLog(@"Connected to Siri Remote");
        
        // Request the list of elements to begin receiving value update notifications
        [device elements];
    }
}

- (void)elementValueUpdateNotification:(NSNotification *)notification
{
    NSLog(@"Value updated");
}

@end