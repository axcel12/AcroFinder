//
//  MQAExceptionHandler.m
//  AcroFinder
//
//  Created by Michael Ramos on 8/28/15.
//  Copyright (c) 2015 AcroFinder. All rights reserved.
//

#import <Foundation/Foundation.h>

void exceptionHandler(NSException *exception) {}
NSUncaughtExceptionHandler *exceptionHandlerPointer = &exceptionHandler;