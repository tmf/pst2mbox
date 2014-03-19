//
//  lrxDropZoneView.h
//  OutlookPersonalStoreConverter
//
//  Created by Tom Forrer on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface lrxDropZoneView : NSView
{
    NSImage *_image;
    NSString *_mbox;
}



- (void)setImage:(NSImage *)newImage;

- (NSImage *)image;

- (NSString *) mbox;
- (void)setMbox:(NSString *)newMbox; 

@end
