PtoJ
====

Testing DPI preservation in Cocoa image transcoding

Issue: DPI not respected when converting PNG to JP2 with NSBitmapImageRep or CGImageDestinationRef
-------

I have a PNG with a DPI of 144. When I load the bits from disk into an NSBitmapImageRep, this is properly recognized: the size.width and pixelsWide values are different.

If I then use representationUsingType:NSJPEGFileType to convert the NSBitmapImageRep to classic JPEG, this info is preserved. If I load the output NSData back into an NSBitmapImageRep or write to disk and open it with Preview.app, I see a DPI of 144. Same thing if I use CGImage to convert to JPEG with CGImageDestinationCreateWithData's kUTTypeJPEG.

However, if I do the same thing but replace NSJPEGFileType and kUTTypeJPEG with NSJPEG2000FileType or kUTTypeJPEG2000 respectively, this doesn't happen. Programmatically I see pixelsWide and size.width as the same value, and Preview.app shows a DPI of 72.

Note that for CGImageDestinationAddImage(), I'm even providing a properties dictionary that sets kCGImagePropertyDPIWidth and kCGImagePropertyDPIHeight.

At first I thought that maybe JP2 just didn't support DPI…but I can edit the image in Preview.app and get it back up to 144 DPI.

Am I missing something, or should I be filing a Radar on this?

I've put a little CLI tool on GitHub to demonstrate this. It takes one command line argument (the input image path), and outputs 4 copies to the same directory as the input:
* .jpg with NS calls
* .jpg with CG calls
* .jp2 with NS calls
* .jp2 with CG calls

Feed it an image with 144 DPI and you should see the first two come out as 144 DPI, and the last two come out as 72 DPI.