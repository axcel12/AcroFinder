//
//  MQAExceptionHandler.h
//  AcroFinder
//
//  Created by Michael Ramos on 8/28/15.
//  Copyright (c) 2015 AcroFinder. All rights reserved.
//

#ifndef AcroFinder_MQAExceptionHandler_h
#define AcroFinder_MQAExceptionHandler_h

volatile void exceptionHandler(NSException *exception);
extern NSUncaughtExceptionHandler *exceptionHandlerPointer;

#endif
