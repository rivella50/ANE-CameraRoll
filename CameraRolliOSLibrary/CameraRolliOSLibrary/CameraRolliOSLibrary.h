//
//  CameraRolliOSLibrary.h
//  CameraRolliOSLibrary
//
//  Created by valley on 2/28/13.
//  Copyright (c) 2013 valley. All rights reserved.
//

#ifndef CameraRolliOSLibrary_CameraRolliOSLibrary_h
#define CameraRolliOSLibrary_CameraRolliOSLibrary_h

@interface CameraRolliOSLibrary

FREResult FRENewObjectFromDate(NSDate* date, FREObject* asDate );
void imageToBitmapData(UIImage *image, FREBitmapData bitmapData);
NSMutableArray* loadImagesForUrls(NSArray *imageUrls);
@end

#endif
