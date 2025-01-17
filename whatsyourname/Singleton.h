//
//  SynthesizeSingleton.h
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Modified by Oliver Jones.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#if __has_feature(objc_arc)
#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname) \
+ (classname *)sharedInstance\
{\
static classname *sharedInstance = nil;\
static dispatch_once_t onceToken;\
dispatch_once(&onceToken, ^{\
sharedInstance = [[classname alloc] init];\
});\
return sharedInstance;\
}
#else
#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname) \
static classname *shared##classname = nil; \
+ (void)cleanupFromTerminate \
{ \
classname *temp = shared##classname; \
shared##classname = nil; \
[temp dealloc]; \
} \
+ (void)registerForCleanup \
{ \
[[NSNotificationCenter defaultCenter] addObserver:self \
selector:@selector(cleanupFromTerminate) \
name:UIApplicationWillTerminateNotification \
object:nil]; \
} \
+ (classname *)sharedInstance \
{ \
static dispatch_once_t p; \
dispatch_once(&p, \
^{ \
if (shared##classname == nil) \
{ \
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; \
shared##classname = [[self alloc] init]; \
[self registerForCleanup]; \
[pool drain]; \
} \
}); \
return shared##classname; \
} \
+ (id)allocWithZone:(NSZone *)zone \
{ \
static dispatch_once_t p; \
__block classname* temp = nil; \
dispatch_once(&p, \
^{ \
if (shared##classname == nil) \
{ \
temp = shared##classname = [super allocWithZone:zone]; \
} \
}); \
return temp; \
} \
- (id)copyWithZone:(NSZone *)zone { return self; } \
- (id)retain { return self; } \
- (NSUInteger)retainCount { return NSUIntegerMax; } \
- (oneway void)release { } \
- (id)autorelease { return self; }
#endif