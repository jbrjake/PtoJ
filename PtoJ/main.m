//
//  main.c
//  PtoJ
//
//  Created by Jonathon Rubin on 1/8/14.
//  Copyright (c) 2014 Jonathon Rubin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main(int argc, const char * argv[])
{

    // Path setup
    if (argc < 2) {
        fprintf( stderr, "Error: Please supply a path to an image.\n");
        return 1;
    }
    
    NSString * inputPath = [NSString stringWithUTF8String: argv[1]];
    NSString * jpgNSOutputPath = [[inputPath stringByDeletingPathExtension] stringByAppendingString:@"_ns.jpg"];
    NSString * jp2NSOutputPath = [[inputPath stringByDeletingPathExtension] stringByAppendingString:@"_ns.jp2"];
    NSString * jpgCGOutputPath = [[inputPath stringByDeletingPathExtension] stringByAppendingString:@"_cg.jpg"];
    NSString * jp2CGOutputPath = [[inputPath stringByDeletingPathExtension] stringByAppendingString:@"_cg.jp2"];
    NSArray * paths = @[jpgNSOutputPath, jpgCGOutputPath, jp2NSOutputPath, jp2CGOutputPath];

    // Read a provided image
    BOOL isDirectory = NO;
    if( !inputPath || ![[NSFileManager defaultManager] fileExistsAtPath: inputPath isDirectory: &isDirectory] || isDirectory )
    {
        fprintf( stderr, "Error: Can't find input file.\n" );
        return 2;
    }
    
    NSData * imageData = [NSData dataWithContentsOfFile: inputPath];
    if( !imageData )
    {
        fprintf( stderr, "Error: Can't load input file.\n" );
        return 3;
    }
    
    NSBitmapImageRep * theImage = [[NSBitmapImageRep alloc] initWithData: imageData];

    // Verify input size and pixels
    NSLog(@"    Input image size: %f x %f", theImage.size.width, theImage.size.height);
    NSLog(@"    Input pixel size: %ld x %ld", theImage.pixelsWide, theImage.pixelsHigh);
    
    // Convert to JPG with NSBitmapImageRep
    NSData * nsJpgData = [theImage representationUsingType: NSJPEGFileType properties:nil];
    
    // Convert to JP2 with NSBitmapImageRep
    NSData * nsJp2Data = [theImage representationUsingType: NSJPEG2000FileType properties:nil];
    
    // Set up a properties dictionary for CGImage, explicitly telling it the DPI and pixel dimensions
    NSDictionary * cgPropDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                 @(theImage.pixelsHigh / theImage.size.height * 72), kCGImagePropertyDPIHeight,
                                 @(theImage.pixelsWide / theImage.size.width * 72), kCGImagePropertyDPIWidth,
                                 @(theImage.pixelsHigh), kCGImagePropertyPixelHeight,
                                 @(theImage.pixelsWide), kCGImagePropertyPixelWidth,
                                 nil];
    
    // Convert to JPG with CGImage
    NSData * cgJpgData = [NSMutableData data];
    CGImageDestinationRef imageDest =  CGImageDestinationCreateWithData((__bridge CFMutableDataRef) cgJpgData, kUTTypeJPEG, 1, NULL);
    CGImageDestinationAddImage(imageDest, [theImage CGImage], (__bridge CFDictionaryRef) cgPropDict);
    CGImageDestinationFinalize(imageDest);
    CFRelease(imageDest);
    
    // Convert to JP2 with CGImage
    NSData * cgJp2Data = [NSMutableData data];
    imageDest =  CGImageDestinationCreateWithData((__bridge CFMutableDataRef) cgJp2Data, kUTTypeJPEG2000, 1, NULL);
    CGImageDestinationAddImage(imageDest, [theImage CGImage], (__bridge CFDictionaryRef) cgPropDict);
    CGImageDestinationFinalize(imageDest);
    CFRelease(imageDest);
    
    // Write to disk
    [nsJpgData writeToFile: jpgNSOutputPath atomically: NO];
    [nsJp2Data writeToFile: jp2NSOutputPath atomically: NO];
    [cgJpgData writeToFile: jpgCGOutputPath atomically: NO];
    [cgJp2Data writeToFile: jp2CGOutputPath atomically: NO];
 
    // Verify output sizes and pixels
    for( NSString *aPath in paths) {
        NSData * anImageData = [NSData dataWithContentsOfFile: aPath];
        if( !anImageData )
        {
            fprintf( stderr, "Error: Can't load output file.\n" );
            return 4;
        }
        
        NSBitmapImageRep * anImage = [[NSBitmapImageRep alloc] initWithData: anImageData];
        
        // Report results
        NSLog(@"*** %@ ***", aPath);
        NSLog(@"    Output image size: %f x %f", anImage.size.width, anImage.size.height);
        NSLog(@"    Output pixel size: %ld x %ld", anImage.pixelsWide, anImage.pixelsHigh);
        if( anImage.size.width != theImage.size.width ) {
            // We have a problem
            NSLog(@"        DPI lost!");
        }
    }
    
    return 0;
}

