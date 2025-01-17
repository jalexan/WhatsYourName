//
//  UIView+Additions.m
//  whatsyourname
//
//  Created by Richard Nguyen on 5/11/13.
//  Copyright (c) 2013 Richard Nguyen. All rights reserved.
//
#import "UIView+Additions.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Additions)

- (CGFloat)left {
  return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)x {
  CGRect frame = self.frame;
  frame.origin.x = x;
  self.frame = frame;
}

- (CGFloat)top {
  return self.frame.origin.y;
}

- (void)setTop:(CGFloat)y {
  CGRect frame = self.frame;
  frame.origin.y = y;
  self.frame = frame;
}

- (CGFloat)right {
  return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right {
  CGRect frame = self.frame;
  frame.origin.x = right - frame.size.width;
  self.frame = frame;
}

- (CGFloat)bottom {
  return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom {
  CGRect frame = self.frame;
  frame.origin.y = bottom - frame.size.height;
  self.frame = frame;
}

- (CGFloat)centerX {
  return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX {
  self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerY {
  return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY {
  self.center = CGPointMake(self.center.x, centerY);
}

- (CGFloat)width {
  return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width {
  CGRect frame = self.frame;
  frame.size.width = width;
  self.frame = frame;
}

- (CGFloat)height {
  return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height {
  CGRect frame = self.frame;
  frame.size.height = height;
  self.frame = frame;
}

- (CGPoint)origin {
  return self.frame.origin;
}


- (void)setOrigin:(CGPoint)origin {
  CGRect frame = self.frame;
  frame.origin = origin;
  self.frame = frame;
}

- (CGSize)size {
  return self.frame.size;
}

- (void)setSize:(CGSize)size {
  CGRect frame = self.frame;
  frame.size = size;
  self.frame = frame;
}


- (void)removeAllSubviews {
  while (self.subviews.count) {
    UIView* child = self.subviews.lastObject;
    [child removeFromSuperview];
  }
}


- (void)drawBorderOnSubviews {
    
    NSArray* subviews = self.subviews;
    
    for (UIView* view in subviews) {
        view.layer.borderColor = [UIColor magentaColor].CGColor;
        view.layer.borderWidth = 1.0f;
    }
    
}

- (void)drawSizeLabelOnSubviews {
    
    NSArray* subviews = self.subviews;
    
    for (UIView* view in subviews) {
        UILabel* sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 10)];
        sizeLabel.font = [UIFont systemFontOfSize:9];
        sizeLabel.textColor = [UIColor magentaColor];
        sizeLabel.backgroundColor = [UIColor clearColor];
        sizeLabel.text = [NSString stringWithFormat:@"%0.fx%0.f",view.width,view.height];
        
        [sizeLabel sizeToFit];
        [view addSubview:sizeLabel];
    }
    
}



@end
