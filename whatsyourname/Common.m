//
//  Common.c
//  whatsyourname
//
//  Created by Richard Nguyen on 5/18/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import "Common.h"


void RunBlockAfterDelay(NSTimeInterval delay, void (^block)(void)) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC*delay),
                   dispatch_get_main_queue(), block);
}