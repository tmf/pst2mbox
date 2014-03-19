//
//  lrxDropZoneView.m
//  OutlookPersonalStoreConverter
//
//  Created by Tom Forrer on 4/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "lrxDropZoneView.h"

@implementation lrxDropZoneView

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    
    if ((NSDragOperationGeneric & [sender draggingSourceOperationMask]) 
        == NSDragOperationGeneric)
    {
        NSPasteboard *paste = [sender draggingPasteboard];
        //gets the dragging-specific pasteboard from the sender
        NSArray *types = [NSArray arrayWithObjects:NSFilenamesPboardType, nil];
        //a list of types that we can accept
        NSString *desiredType = [paste availableTypeFromArray:types];
        NSData *carriedData = [paste dataForType:desiredType];
        
        if (nil != carriedData)
        {
            //the pasteboard was able to give us some meaningful data
            if ([desiredType isEqualToString:NSFilenamesPboardType])
            {
                //we have a list of file names in an NSData object
                NSArray *fileArray = 
                [paste propertyListForType:@"NSFilenamesPboardType"];
                //be caseful since this method returns id.  
                //We just happen to know that it will be an array.
                NSString *path = [fileArray objectAtIndex:0];
                if([[path pathExtension] isEqualToString:@"pst"]){
                    [self setImage:[NSImage imageNamed:@"dropzone_hover.png"]];
                }else{
                    [self setImage:[NSImage imageNamed:@"dropzone_error.png"]];
                    [self setMbox:@""];
                }
                [self setNeedsDisplay:YES];
            }
        }
        //this means that the sender is offering the type of operation we want
        //return that we want the NSDragOperationGeneric operation that they 
        //are offering
        return NSDragOperationGeneric;
    }
    else
    {
        //since they aren't offering the type of operation we want, we have 
        //to tell them we aren't interested
        return NSDragOperationNone;
    }
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    //we aren't particularily interested in this so we will do nothing
    //this is one of the methods that we do not have to implement
    [self setImage:[NSImage imageNamed:@"dropzone.png"]];
    [self setNeedsDisplay:YES];
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
    if ((NSDragOperationGeneric & [sender draggingSourceOperationMask]) 
        == NSDragOperationGeneric)
    {
        //this means that the sender is offering the type of operation we want
        //return that we want the NSDragOperationGeneric operation that they 
        //are offering
        return NSDragOperationGeneric;
    }
    else
    {
        //since they aren't offering the type of operation we want, we have 
        //to tell them we aren't interested
        return NSDragOperationNone;
    }
}
- (void)draggingEnded:(id <NSDraggingInfo>)sender
{
    //we don't do anything in our implementation
    //this could be ommitted since NSDraggingDestination is an infomal
    //protocol and returns nothing
    if([[self mbox] isEqualToString:@""]){
        
    
    [self setImage:[NSImage imageNamed:@"dropzone.png"]];
    [self setNeedsDisplay:YES];
    }
    
    
}
- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    return YES;
}
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *paste = [sender draggingPasteboard];
    //gets the dragging-specific pasteboard from the sender
    NSArray *types = [NSArray arrayWithObjects:NSFilenamesPboardType, nil];
    //a list of types that we can accept
    NSString *desiredType = [paste availableTypeFromArray:types];
    NSData *carriedData = [paste dataForType:desiredType];
    
    if (nil == carriedData)
    {
        //the operation failed for some reason
        NSRunAlertPanel(@"Paste Error", @"Sorry, but the paste operation failed", 
                        nil, nil, nil);
        return NO;
    }
    else
    {
        //the pasteboard was able to give us some meaningful data
        if ([desiredType isEqualToString:NSFilenamesPboardType])
        {
            //we have a list of file names in an NSData object
            NSArray *fileArray = 
            [paste propertyListForType:@"NSFilenamesPboardType"];
            //be caseful since this method returns id.  
            //We just happen to know that it will be an array.
            NSString *path = [fileArray objectAtIndex:0];
            if([[path pathExtension] isEqualToString:@"pst"]){
            //assume that we can ignore all but the first path in the list
            NSString *readpstpath = [[NSBundle mainBundle] pathForResource:@"readpst" ofType:@""];
            NSTask *task;
            task = [[NSTask alloc] init];
            [task setLaunchPath: readpstpath];
            
            NSArray *arguments;
            arguments = [NSArray arrayWithObjects: @"-o", [path stringByDeletingLastPathComponent], @"-D", @"-r", path, nil];
            [task setArguments: arguments];
            
            NSPipe *pipe;
            pipe = [NSPipe pipe];
            [task setStandardOutput: pipe];
            
            NSFileHandle *file;
            file = [pipe fileHandleForReading];
            
            [task launch];
            
            NSData *data;
            data = [file readDataToEndOfFile];
            
            NSString *readpstoutput;
            readpstoutput = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
            //NSLog (@"grep returned:\n%@", readpstoutput);
            NSArray* lines = [readpstoutput componentsSeparatedByCharactersInSet: [NSCharacterSet newlineCharacterSet]];
            if([lines count]>0){
                NSString *lastline = [lines objectAtIndex:[lines count]-2];
                
                NSArray *tokens = [lastline componentsSeparatedByString:@" "];
                NSMutableString *mString  = [[NSMutableString alloc] initWithString: [tokens objectAtIndex:0]];
                [mString replaceOccurrencesOfString:@"\"" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [mString length])];
                
                NSString *mboxfolder = [mString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                NSString *mboxpath = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:mboxfolder];
                [self setMbox:mboxpath];
                [self setImage:[NSImage imageNamed:@"dropzone_mbox.png"]];
                
            }
            }
          
        }
        else
        {
            //this can't happen
            NSAssert(NO, @"This can't happen");
            return NO;
        }
    }
    [self setNeedsDisplay:YES];    //redraw us with the new image
    return YES;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
    //re-draw the view with our new data
    [self setNeedsDisplay:YES];
}
- (void)mouseUp:(NSEvent*)event {
    if (event.clickCount == 2) {
        if(![[self mbox] isEqualToString:@""]){
            NSURL *mboxURL = [NSURL fileURLWithPath: [self mbox]];
            [[NSWorkspace sharedWorkspace] openURL: mboxURL]; 
        }
    }
}
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    [self setImage:[NSImage imageNamed:@"dropzone.png"]];
    [self setNeedsDisplay:YES];
    [self setMbox:@""];
    return self;
    
}

- (void)dealloc
{
    [self unregisterDraggedTypes];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    [[self image] drawInRect:[self bounds] fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
}

- (void)setImage:(NSImage *)newImage
{
    //NSImage *temp = [newImage retain];
    //[_leImage release];
    //_leImage = temp;
    _image = newImage;
}
- (NSImage *)image
{
    return _image;
}
           
           - (NSString *) mbox{
               return _mbox;
           }
           - (void)setMbox:(NSString *)newMbox{
               _mbox = newMbox;
           }
@end
