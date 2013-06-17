//
//  StarImageView.h
//  whatsyourname
//
//  Created by Richard Nguyen on 6/14/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StarImageView : UIImageView

- (void)animateWithEndPoint:(CGPoint)theEndPoint completion:(void(^)())completion;

@end
