//
//  CameraRolliOSLibrary.m
//  CameraRolliOSLibrary
//
//  Created by valley on 2/26/13.
//  Copyright (c) 2013 valley. All rights reserved.
//
//  parts inspired by https://github.com/freshplanet/ANE-ImagePicker/blob/master/ios/AirImagePicker/AirImagePicker.m
// http://developer.apple.com/library/ios/#documentation/AssetsLibrary/Reference/ALAssetsLibrary_Class/Reference/Reference.html
// http://developer.apple.com/library/ios/#documentation/AssetsLibrary/Reference/ALAsset_Class/Reference/Reference.html
// http://developer.apple.com/library/ios/#documentation/AssetsLibrary/Reference/ALAssetRepresentation_Class/Reference/Reference.html#//apple_ref/doc/c_ref/ALAssetRepresentation

#import "FlashRuntimeExtensions.h"
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "CameraRolliOSLibrary.h"

FREContext g_ctx;
NSMutableArray *assets;
ALAsset *currentAsset;
ALAssetsLibrary *library;


// loads an amount of photo assets, depending on the given start index and the amount
// async method
// params: startIndex, amount, type
FREObject LoadPhotoAssets(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    
    //NSLog(@"Entering LoadPhotoAssets()");
    
    [assets removeAllObjects];
    
    // get the start index (offset)
    uint32_t offset;
    FREObject offsetObject = argv[0];
    FREGetObjectAsUint32(offsetObject, &offset);
    
    // and the amount of photos to load in this step
    uint32_t amount;
    FREObject amountObject = argv[1];
    FREGetObjectAsUint32(amountObject, &amount);
    
    // finally the notify string
    uint32_t notifyLength;
    const uint8_t *notify;
    FREGetObjectAsUTF8(argv[2], &notifyLength, &notify);
    NSString *notifyString = [NSString stringWithUTF8String:(char*)notify];
    
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        if (group == nil) {
            NSInteger numberOfPhotos = [assets count];
                    
            NSString *result = [NSString stringWithFormat:@"%d",(int)numberOfPhotos];
            FREDispatchStatusEventAsync(g_ctx, (const uint8_t*)[notifyString UTF8String], (uint8_t*)[result UTF8String]);
        } else {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            NSInteger totalCount = [group numberOfAssets];
            if (offset < totalCount) {
                NSInteger difference = (totalCount - offset);
                NSInteger realAmount = (difference < amount) ? difference : amount;
                int i;
                for (i = offset; i < (offset + realAmount); i++)  {
                    [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:i] options:0 usingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
                        if (asset) {
                            [assets addObject:asset];
                        }
                    }];
                }
            }
                        
        }
    }
    failureBlock:^(NSError *err) {
        NSLog(@"err=%@", err);
    }
     
    ];
    
    
    //NSLog(@"Exiting LoadPhotoAssets()");
    
    return NULL;
}

// WORKS: this is for BitmapData passed from as3
// params: index, BitmapData, type (thumbnail, aspectRatioThumbnail)
// https://github.com/freshplanet/ANE-ImagePicker/blob/master/ios/AirImagePicker/AirImagePicker.m
FREObject DrawThumbnailAtIndexToBitmapData(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    
    //NSLog(@"Entering DrawThumbnailAtIndexToBitmapData()");
    uint32_t index;
    FREObject indexObject = argv[0];
    FREGetObjectAsUint32(indexObject, &index);
    ALAsset *asset = [assets objectAtIndex:index];
    
    // getting the type
    uint32_t typeLength;
    const uint8_t *type;
    FREGetObjectAsUTF8(argv[2], &typeLength, &type);
    NSString *typeString = [NSString stringWithUTF8String:(char*)type];
    
    UIImage *image;
    
    if ([typeString isEqualToString:@"thumbnail"]) {
        image = [UIImage imageWithCGImage:[asset thumbnail]];
    } else if ([typeString isEqualToString:@"aspectRatioThumbnail"]) {
        image = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
    }
    
    // Get the AS3 BitmapData
    FREBitmapData bitmapData;
    FREAcquireBitmapData(argv[1], &bitmapData);
    
    if (image) {
        //NSLog(@"Found image");
        
        imageToBitmapData(image, bitmapData);
        
        // Tell Flash which region of the BitmapData changes (all of it here)
        FREInvalidateBitmapDataRect(argv[1], 0, 0, bitmapData.width, bitmapData.height);
        
        // Release our control over the BitmapData
        FREReleaseBitmapData(argv[1]);
    }
    //NSLog(@"Exiting DrawThumbnailAtIndexToBitmapData()");
    return nil;
}

// gets an url and tries to load the photo. the photo will be stored in currentAsset
// async method
// params: url, notifystring
FREObject LoadPhotoForUrl(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    
    //NSLog(@"Entering LoadPhotoForUrl()");
    currentAsset = NULL;
    
    // getting the url
    uint32_t urlLength;
    const uint8_t *url;
    FREGetObjectAsUTF8(argv[0], &urlLength, &url);
    NSString *urlString = [NSString stringWithUTF8String:(char*)url];
    
    // getting the notifystring
    uint32_t notifyLength;
    const uint8_t *notify;
    FREGetObjectAsUTF8(argv[1], &notifyLength, &notify);
    NSString *notifyString = [NSString stringWithUTF8String:(char*)notify];
    
    // now retrieve the image: http://stackoverflow.com/questions/7221167/how-to-check-if-an-alasset-still-exists-using-a-url
    NSURL *assetUrl = [NSURL URLWithString:urlString];
    [library assetForURL:assetUrl resultBlock:^(ALAsset *asset) {
        if (asset) {
            currentAsset = asset;
            //NSLog(@"The asset for url %@ has been found. Now notify for type %@ ", urlString, notifyString);
            FREDispatchStatusEventAsync(g_ctx, (const uint8_t*)[notifyString UTF8String], (uint8_t*)"");
        }
    } failureBlock:^(NSError *error) {
        
    }];

    //NSLog(@"Exiting LoadPhotoForUrl()");
    
    return NULL;
}

// gets a list of urls and recursively loads the photos into assets array
// see: http://www.calebmadrigal.com/functional-programming-deal-asynchronicity-objective-c/
// see: http://stackoverflow.com/questions/15328101/how-to-load-several-photos-with-assetforurl-with-a-list-of-urls
// async
// params: list of asset urls
FREObject LoadPhotoAssetsForUrls(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    
    NSLog(@"Entering LoadPhotosForUrls()");
    
    [assets removeAllObjects];
    
    // getting the array of urls
    FREObject arr = argv[0];
    uint32_t arr_len;
    FREGetArrayLength(arr, &arr_len);
    
    // finally the notify string
    uint32_t notifyLength;
    const uint8_t *notify;
    FREGetObjectAsUTF8(argv[1], &notifyLength, &notify);
    NSString *notifyString = [NSString stringWithUTF8String:(char*)notify];
    
    loadImagesForUrls(arr, assets, notifyString);
    
    //NSLog(@"Exiting LoadPhotosForUrls() with %d loaded assets", numberOfPhotos);
    return NULL;
}

// gets an index and tries to load the photo. the photo will be stored in currentAsset
// async method
// params: index, notifystring
FREObject LoadPhotoAtIndex(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    
    //NSLog(@"Entering LoadPhotoAtIndex()");
    currentAsset = NULL;
    
    // getting the index
    uint32_t index;
    FREObject indexObject = argv[0];
    FREGetObjectAsUint32(indexObject, &index);
    
    // getting the notifystring
    uint32_t notifyLength;
    const uint8_t *notify;
    FREGetObjectAsUTF8(argv[1], &notifyLength, &notify);
    NSString *notifyString = [NSString stringWithUTF8String:(char*)notify];
    
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        // Within the group enumeration block, filter to enumerate just photos.
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        
        // Chooses the photo at the given index
        [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:index] options:0 usingBlock:^(ALAsset *asset, NSUInteger index, BOOL *innerStop) {
            
            // The end of the enumeration is signaled by asset == nil.
            if (asset) {
                currentAsset = asset;
                //NSLog(@"The asset at index %d has been found", index);
                FREDispatchStatusEventAsync(g_ctx, (const uint8_t*)[notifyString UTF8String], (uint8_t*)"");
            }
        }];
    } failureBlock: ^(NSError *error) {
        
    }];

    //NSLog(@"Exiting LoadPhotoAtIndex()");
    
    return NULL;
}

// gets the dimension for the current loaded photo
// sync method
// params: index, type (thumbnail, aspectRatioThumbnail, fullScreen, fullResolution)
FREObject GetPhotoDimensionsAtIndex(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    
    //NSLog(@"Entering GetCurrentPhotoDimensions()");
    FREObject data = NULL;
    UIImage *image;
    
    // getting the index
    uint32_t index;
    FREObject indexObject = argv[0];
    FREGetObjectAsUint32(indexObject, &index);
    
    // getting the type
    uint32_t typeLength;
    const uint8_t *type;
    FREGetObjectAsUTF8(argv[1], &typeLength, &type);
    NSString *typeString = [NSString stringWithUTF8String:(char*)type];
    
    ALAsset *asset = [assets objectAtIndex:index];
    
    if (asset) {
        if ([typeString isEqualToString:@"thumbnail"]) {
            image = [UIImage imageWithCGImage:[asset thumbnail]];
        } else if ([typeString isEqualToString:@"aspectRatioThumbnail"]) {
            image = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
        } else if ([typeString isEqualToString:@"fullScreen"]) {
            image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
        } else if ([typeString isEqualToString:@"fullResolution"]) {
            image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage];
        }
        CGImageRef imageRef = [image CGImage];
        NSUInteger width = CGImageGetWidth(imageRef);
        NSUInteger height = CGImageGetHeight(imageRef);
        
        FREObject widthObject = nil;
        FRENewObjectFromInt32(width, &widthObject);
        FREObject heightObject = nil;
        FRENewObjectFromInt32(height, &heightObject);
        
        FRENewObject((const uint8_t*)"com.vlabs.ane.cameraroll.PhotoDimensions", 0, NULL, &data, NULL);
        FRESetObjectProperty(data, (const uint8_t*)"width", widthObject, NULL);
        FRESetObjectProperty(data, (const uint8_t*)"height", heightObject, NULL);
    }
    
    
    //NSLog(@"Exiting GetCurrentPhotoDimensions() for type %@", typeString);
    return data;
}


// gets the dimension for the current loaded photo
// sync method
// params: type (thumbnail, aspectRatioThumbnail, fullScreen, fullResolution)
FREObject GetCurrentPhotoDimensions(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    
    //NSLog(@"Entering GetCurrentPhotoDimensions()");
    FREObject data = NULL;
    UIImage *image;
    // getting the type
    uint32_t typeLength;
    const uint8_t *type;
    FREGetObjectAsUTF8(argv[0], &typeLength, &type);
    NSString *typeString = [NSString stringWithUTF8String:(char*)type];
    
    if (currentAsset) {
        if ([typeString isEqualToString:@"thumbnail"]) {
            image = [UIImage imageWithCGImage:[currentAsset thumbnail]];
        } else if ([typeString isEqualToString:@"aspectRatioThumbnail"]) {
            image = [UIImage imageWithCGImage:[currentAsset aspectRatioThumbnail]];
        } else if ([typeString isEqualToString:@"fullScreen"]) {
            image = [UIImage imageWithCGImage:currentAsset.defaultRepresentation.fullScreenImage];
        } else if ([typeString isEqualToString:@"fullResolution"]) {
            image = [UIImage imageWithCGImage:currentAsset.defaultRepresentation.fullResolutionImage];
        }
        CGImageRef imageRef = [image CGImage];
        NSUInteger width = CGImageGetWidth(imageRef);
        NSUInteger height = CGImageGetHeight(imageRef);
        
        FREObject widthObject = nil;
        FRENewObjectFromInt32(width, &widthObject);
        FREObject heightObject = nil;
        FRENewObjectFromInt32(height, &heightObject);
        
        FRENewObject((const uint8_t*)"com.vlabs.ane.cameraroll.PhotoDimensions", 0, NULL, &data, NULL);
        FRESetObjectProperty(data, (const uint8_t*)"width", widthObject, NULL);
        FRESetObjectProperty(data, (const uint8_t*)"height", heightObject, NULL);
    }
    

    //NSLog(@"Exiting GetCurrentPhotoDimensions() for type %@", typeString);
    return data;
}

// If CameraRoll is not empty ask the first photo about its dimensions
FREObject GetThumbnailPhotoDimensions(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    
    NSLog(@"Entering GetThumbnailPhotoDimensions()");
    FREObject data = NULL;
    
    
    
    NSLog(@"Exiting GetThumbnailPhotoDimensions()");
    return data;
}

// Draws the current loaded fullscreen asset into the passed BitmapData
// params: BitmapData, type (thumbnail, fullScreen, fullResolution)
FREObject DrawPhotoToBitmapData(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    
    //NSLog(@"Entering DrawFullScreenPhotoToBitmapData()");
    // Get the AS3 BitmapData
    FREBitmapData bitmapData;
    FREAcquireBitmapData(argv[0], &bitmapData);
    UIImage *image;
    // getting the type
    uint32_t typeLength;
    const uint8_t *type;
    FREGetObjectAsUTF8(argv[1], &typeLength, &type);
    NSString *typeString = [NSString stringWithUTF8String:(char*)type];

    
    if (currentAsset) {
        if ([typeString isEqualToString:@"thumbnail"]) {
            image = [UIImage imageWithCGImage:[currentAsset thumbnail]];
        } else if ([typeString isEqualToString:@"fullScreen"]) {
            image = [UIImage imageWithCGImage:currentAsset.defaultRepresentation.fullScreenImage];
        } else if ([typeString isEqualToString:@"fullResolution"]) {
            image = [UIImage imageWithCGImage:currentAsset.defaultRepresentation.fullResolutionImage];
        }
    
        if (image) {
            //NSLog(@"Found image");
        
            imageToBitmapData(image, bitmapData);
        
            // Tell Flash which region of the BitmapData changes (all of it here)
            FREInvalidateBitmapDataRect(argv[0], 0, 0, bitmapData.width, bitmapData.height);
        
            // Release our control over the BitmapData
            FREReleaseBitmapData(argv[0]);
        }
    }
    
    //NSLog(@"Exiting DrawFullScreenPhotoToBitmapData()");
    return NULL;
}

// returns the size of the JPEG representation at assets index
// params: index
// https://github.com/freshplanet/ANE-ImagePicker/blob/master/ios/AirImagePicker/AirImagePicker.m
FREObject GetJPEGRepresentationSizeAtIndex(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {

    //NSLog(@"Entering GetJPEGRepresentationSizeAtIndex()");
    uint32_t index;
    FREObject indexObject = argv[0];
    FREGetObjectAsUint32(indexObject, &index);
    ALAsset *asset = [assets objectAtIndex:index];
    UIImage *image = [UIImage imageWithCGImage:[asset thumbnail]];
    
    //NSLog(@"Exiting GetJPEGRepresentationSizeAtIndex()");
    if (image) {
       
        NSData *jpegData = UIImageJPEGRepresentation(image, 1.0);
        if (jpegData) {
            FREObject result;
            if (FRENewObjectFromUint32(jpegData.length, &result) == FRE_OK) {
                return result;
            }
            else return nil;
        }
    }
    
    return nil;
}



// params: index, ByteArray
// https://github.com/freshplanet/ANE-ImagePicker/blob/master/ios/AirImagePicker/AirImagePicker.m
FREObject CopyThumbnailJPEGRepresentationAtIndexToByteArray(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    
    //NSLog(@"Entering CopyThumbnailJPEGRepresentationAtIndexToByteArray()");
    uint32_t index;
    FREObject indexObject = argv[0];
    FREGetObjectAsUint32(indexObject, &index);
    ALAsset *asset = [assets objectAtIndex:index];
    UIImage *image = [UIImage imageWithCGImage:[asset thumbnail]];
    if (image) {
        
        NSData *jpegData = UIImageJPEGRepresentation(image, 1.0);
    
        if (jpegData) {
            // Get the AS3 ByteArray
            FREByteArray byteArray;
            FREAcquireByteArray(argv[1], &byteArray);
        
            // Copy JPEG representation in ByteArray
            memcpy(byteArray.bytes, jpegData.bytes, jpegData.length);
        
            // Release our control over the ByteArray
            FREReleaseByteArray(argv[1]);
        }
    }

    //NSLog(@"Exiting CopyThumbnailJPEGRepresentationAtIndexToByteArray()");
    return nil;
}

// sync method which iterates over assets array and returns the assets properties
// params: startIndex, length
FREObject GetPhotoInfos(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {

    //NSLog(@"Entering GetPhotoInfos()");
    uint32_t startIndex;
    FREObject startIndexObject = argv[0];
    FREGetObjectAsUint32(startIndexObject, &startIndex);
    
    uint32_t length;
    FREObject lengthObject = argv[1];
    FREGetObjectAsUint32(lengthObject, &length);
    
    // Create a new AS3 Array, pass 0 arguments to the constructor (and no arguments values = NULL)
    FREObject populatedArray = NULL;
    FRENewObject((const uint8_t*)"Array", 0, NULL, &populatedArray, nil);
    FRESetArrayLength(populatedArray, length);
    
    // now iterate over assets and get the infos we need
    NSDictionary *metadata = nil; //asset.defaultRepresentation.metadata;
    ALAsset *asset = nil;
    NSDate *date = nil;
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    dateFormatter.dateFormat = @"y:MM:dd HH:mm:ss";
    
    int i;
    for (i = startIndex; i < (startIndex+length); i++)  {
        asset = [assets objectAtIndex:i];
        metadata = asset.defaultRepresentation.metadata;
        // http://stackoverflow.com/questions/6030384/alassetpropertydate-returns-wrong-date
        date = [dateFormatter dateFromString:[[metadata objectForKey:@"{Exif}"] objectForKey:@"DateTimeOriginal"]];
        FREObject freDate ;
        FRENewObjectFromDate(date, &freDate);
        
        uint32_t arr_len = 20; // count of positions
        FREObject data = NULL;
        FRENewObject((const uint8_t*)"com.vlabs.ane.cameraroll.PhotoMetadata", 0, NULL, &data, NULL);
        FRESetArrayLength(data, arr_len);
        
        // now set the date object
        FRESetObjectProperty(data, (const uint8_t*)"time", freDate, NULL);
        
        // next we need the unique identifier url
        NSURL *assetUrl = asset.defaultRepresentation.url;
        NSString *urlString = [assetUrl absoluteString];
        // Convert Obj-C string to C UTF8String const char *str = [returnString UTF8String];
        const char *str = [urlString UTF8String];
        FREObject urlStr;
        FRENewObjectFromUTF8(strlen(str)+1, (const uint8_t*)str, &urlStr);
        FRESetObjectProperty(data, (const uint8_t*)"url", urlStr, NULL);
        
        
        // and insert the data object into the array
        FRESetArrayElementAt(populatedArray, i, data);
        
        //NSLog(@"Found a date %@", date);
    }
    
    
    //NSLog(@"Exiting GetPhotoInfos()");
    return populatedArray;
}



//
// Returns the number of photos in CameraRoll

FREObject CountPhotos(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    
    //NSLog(@"Entering CountPhotos()");
        
    NSUInteger __block images = 0;
    
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
            if (group == nil) {
                NSString *result = [NSString stringWithFormat:@"%d",(int)images];
                FREDispatchStatusEventAsync(g_ctx, (const uint8_t*)"COUNT_PHOTOS_COMPLETED", (uint8_t*)[result UTF8String]);
            } else {
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                images += group.numberOfAssets;
            }
        }
        failureBlock:^(NSError *err) {
            NSLog(@"err=%@", err);
        }
        

    ];
        
    //NSLog(@"Exiting CountPhotos()");
    return NULL;
}




//
// An InitNativeCode function is necessary in the Android implementation of this extension.
// Therefore, an analogous function is necessary in the iOS implementation to make
// the ActionScript interface identical for all implementations.
// However, the iOS implementation has nothing to do.

FREObject InitNativeCode(FREContext ctx, void* funcData, uint32_t argc, FREObject argv[]) {
    
    //NSLog(@"Entering InitNativeCode()");
    
    // Nothing to do.
    
    //NSLog(@"Exiting InitNativeCode()");
    
    return NULL;
}

//
// The context initializer is called when the runtime creates the extension context instance.

void CameraRollContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx,
						uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet) {
    
    //NSLog(@"Entering CameraRollContextInitializer()");
    
	*numFunctionsToTest = 14;
    
	FRENamedFunction* func = (FRENamedFunction*) malloc(sizeof(FRENamedFunction) * *numFunctionsToTest);
	
    func[0].name = (const uint8_t*) "loadPhotoAssets";
	func[0].functionData = NULL;
	func[0].function = &LoadPhotoAssets;
    
    func[1].name = (const uint8_t*) "drawThumbnailAtIndexToBitmapData";
	func[1].functionData = NULL;
	func[1].function = &DrawThumbnailAtIndexToBitmapData;
    
    func[2].name = (const uint8_t*) "getPhotoInfos";
	func[2].functionData = NULL;
	func[2].function = &GetPhotoInfos;
    
    func[3].name = (const uint8_t*) "countPhotos";
	func[3].functionData = NULL;
	func[3].function = &CountPhotos;
    
	func[4].name = (const uint8_t*) "getJPEGRepresentationSizeAtIndex";
	func[4].functionData = NULL;
	func[4].function = &GetJPEGRepresentationSizeAtIndex;
    
    func[5].name = (const uint8_t*) "copyThumbnailJPEGRepresentationAtIndexToByteArray";
	func[5].functionData = NULL;
	func[5].function = &CopyThumbnailJPEGRepresentationAtIndexToByteArray;
    
    func[6].name = (const uint8_t*) "loadPhotoForUrl";
	func[6].functionData = NULL;
	func[6].function = &LoadPhotoForUrl;
    
    func[7].name = (const uint8_t*) "loadPhotoAtIndex";
	func[7].functionData = NULL;
	func[7].function = &LoadPhotoAtIndex;
    
    func[8].name = (const uint8_t*) "getCurrentPhotoDimensions";
	func[8].functionData = NULL;
	func[8].function = &GetCurrentPhotoDimensions;
    
    func[9].name = (const uint8_t*) "getThumbnailPhotoDimensions";
	func[9].functionData = NULL;
	func[9].function = &GetThumbnailPhotoDimensions;
    
    func[10].name = (const uint8_t*) "drawPhotoToBitmapData";
	func[10].functionData = NULL;
	func[10].function = &DrawPhotoToBitmapData;
    
    func[11].name = (const uint8_t*) "loadPhotoAssetsForUrls";
	func[11].functionData = NULL;
	func[11].function = &LoadPhotoAssetsForUrls;     
	
    func[12].name = (const uint8_t*) "getPhotoDimensionsAtIndex";
	func[12].functionData = NULL;
	func[12].function = &GetPhotoDimensionsAtIndex;
    
	//Just for consistency with Android
	func[13].name = (const uint8_t*) "initNativeCode";
	func[13].functionData = NULL;
	func[13].function = &InitNativeCode;   
    
	*functionsToSet = func;
    
    g_ctx = ctx;
    library = [[ALAssetsLibrary alloc] init];
    assets = [[NSMutableArray alloc] init];
    
    //NSLog(@"Exiting CameraRollContextInitializer()");
    
}

//
// The context finalizer is called when the extension's ActionScript code
// calls the ExtensionContext instance's dispose() method.
// If the AIR runtime garbage collector disposes of the ExtensionContext instance, the runtime also calls
// ContextFinalizer().

void CameraRollContextFinalizer(FREContext ctx) {
    
    //NSLog(@"Entering CameraRollContextFinalizer()");
    
    library = NULL;
    assets = NULL;
    currentAsset = NULL;
    
    //NSLog(@"Exiting CameraRollContextFinalizer()");
    
	return;
}

//
// The extension initializer is called the first time the ActionScript side of the extension
// calls ExtensionContext.createExtensionContext() for any context.

void CameraRollExtensionInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet,
                    FREContextFinalizer* ctxFinalizerToSet) {
    
    //NSLog(@"Entering CameraRollExtensionInitializer()");
    
    *extDataToSet = NULL;
    *ctxInitializerToSet = &CameraRollContextInitializer;
    *ctxFinalizerToSet = &CameraRollContextFinalizer;
    
    //NSLog(@"Exiting CameraRollExtensionInitializer()");
}

//
// The extension finalizer is called when the runtime unloads the extension. However, it is not always called.

void CameraRollExtensionFinalizer(void* extData) {
    
    //NSLog(@"Entering CameraRollExtensionFinalizer()");
    
    // Nothing to clean up.
    
    //NSLog(@"Exiting CameraRollExtensionFinalizer()");
    return;
}

// https://github.com/StickSports/ANE-Game-Center/blob/master/ios/GameCenterIosExtension/FRETypeConversion.m
FREResult FRENewObjectFromDate(NSDate* date, FREObject* asDate )
{
    NSTimeInterval timestamp = date.timeIntervalSince1970 * 1000;
    FREResult result;
    FREObject time;
    result = FRENewObjectFromDouble( timestamp, &time );
    if( result != FRE_OK ) return result;
    result = FRENewObject((const uint8_t*)"Date", 0, NULL, asDate, NULL );
    if( result != FRE_OK ) return result;
    result = FRESetObjectProperty( *asDate,(const uint8_t*)"time", time, NULL);
    if( result != FRE_OK ) return result;
    return FRE_OK;
}

void imageToBitmapData(UIImage *image, FREBitmapData bitmapData)
{
    //NSLog(@"Entering imageToBitmapData()");
    
    // Pull the raw pixels values out of the image data
    CGImageRef imageRef = [image CGImage];
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    //NSLog(@"Width: %d  Height: %d", width, height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char *rawData = malloc(height * width * 4);
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    // Pixels are now it rawData in the format RGBA8888
    // Now loop over each pixel to write them into the AS3 BitmapData memory
    int x, y;
    // There may be extra pixels in each row due to the value of lineStride32.
    // We'll skip over those as needed.
    int offset = bitmapData.lineStride32 - bitmapData.width;
    int offset2 = bytesPerRow - bitmapData.width*4;
    int byteIndex = 0;
    uint32_t *bitmapDataPixels = bitmapData.bits32;
    for (y=0; y<bitmapData.height; y++)
    {
        for (x=0; x<bitmapData.width; x++, bitmapDataPixels++, byteIndex += 4)
        {
            // Values are currently in RGBA7777, so each color value is currently a separate number.
            int red = (rawData[byteIndex]);
            int green = (rawData[byteIndex + 1]);
            int blue = (rawData[byteIndex + 2]);
            int alpha = (rawData[byteIndex + 3]);
            
            // Combine values into ARGB32
            *bitmapDataPixels = (alpha << 24) | (red << 16) | (green << 8) | blue;
        }
        
        bitmapDataPixels += offset;
        byteIndex += offset2;
    }
    
    // Free the memory we allocated
    free(rawData);
    
    //NSLog(@"Exiting imageToBitmapData()");
}

void loadImagesForUrls(FREObject imageUrls, NSMutableArray *loadedImages, NSString *notifyString) {
    
    NSLog(@"Entering loadImagesForUrls()");
    uint32_t arr_len;
    FREGetArrayLength(imageUrls, &arr_len);
    
    @try
    {
        for (int index = 0; index < arr_len; index++)
        {
            FREObject element;
            FREGetArrayElementAt(imageUrls, index, &element);
            // getting the url
            uint32_t urlLength;
            const uint8_t *urlParam;
            FREGetObjectAsUTF8(element, &urlLength, &urlParam);
            NSString *urlString = [NSString stringWithUTF8String:(char*)urlParam];
            NSURL *assetUrl = [NSURL URLWithString:urlString];
            
            [library assetForURL:assetUrl resultBlock:^(ALAsset *asset) {
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (asset) {
                        NSLog(@"Adding asset to assets list.");
                        [loadedImages addObject:asset];
                    } else {
                        NSLog(@"Not found asset for url %@.", assetUrl);
                    }
                    
                    if (index == (arr_len - 1)) {
                        NSString *result = [NSString stringWithFormat:@"%d",(int)arr_len];
                        FREDispatchStatusEventAsync(g_ctx, (const uint8_t*)[notifyString UTF8String], (uint8_t*)[result UTF8String]);
                    }
                    
                });
                
            } failureBlock:^(NSError *error) {
                
                NSLog(@"Failed to get Image");
            }];
            
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"%s\n exception: Name- %@ Reason->%@", __PRETTY_FUNCTION__,[exception name],[exception reason]);
    }
    @finally
    {
        NSLog(@"Finished loadImagesForUrls");
        return;
    }
}