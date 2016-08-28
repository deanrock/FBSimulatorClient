//
//  AppDelegate.m
//  FBSimulatorCLI
//
//  Created by Tapan Thaker on 07/11/15.
//  Copyright (c) 2015 TT. All rights reserved.
//

#import "AppDelegate.h"
#import "ArgumentParser.h"
#import "FBSimulatorClient-Swift.h"
#import <Foundation/Foundation.h>

@interface AppDelegate () {
    WebServer *webserver;
}

@end

@implementation AppDelegate

- (void)startServer:(NSInteger)port {
    webserver = [[WebServer alloc]initWithPort:port];
    [webserver startServer];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSInteger portNumber = 9898;
    
    NSArray *arguments = [[NSProcessInfo processInfo] arguments];
    ArgumentParser *parser = [[ArgumentParser alloc]initWithArguments:arguments];
    
    if ([parser flagExists:@"--start-server"] ) {
        NSString *portNumberString = [parser valueForFlag:@"--port"];
        if (portNumberString != nil) {
            NSScanner *scanner = [NSScanner scannerWithString:portNumberString];
            if ([scanner scanInteger:&portNumber]) {
                [self startServer:portNumber];
            } else {
                [NSException raise:@"Invalid port number" format:@"Invalid port number:%@",portNumberString];
            }
        } else {
            [NSException raise:@"Invalid port number" format:@"Please pass a valid port number with --port argument"];
        }
    } else {
        [self startServer:portNumber];
    }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
