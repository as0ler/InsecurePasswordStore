//
//  Created by Murphy on 11/06/17.
//  Copyright © 2017 Murphy. All rights reserved.
//


#import "Utils.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation Utils


+ (void) updateConfigKey:(NSString *)key WithValue:(id)value {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"config.plist"];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    if (![fileManager fileExistsAtPath: path]) {

        path = [documentsDirectory stringByAppendingPathComponent: [NSString stringWithFormat:@"config.plist"] ];
    }

    NSMutableDictionary *data;

    if ([fileManager fileExistsAtPath: path]) {

        data = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    }
    else {
        // If the file doesn’t exist, create an empty dictionary
        data = [[NSMutableDictionary alloc] init];
    }

    //To insert the data into the plist
    [data setObject:value forKey:key];
    [data writeToFile:path atomically:YES];
    NSLog(@"Configuration Updated");
}

+ (id) getConfigKey:(NSString *)key {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"config.plist"];
    //To retrieve the data from the plist
    NSMutableDictionary *savedValue = [[NSMutableDictionary alloc] initWithContentsOfFile: path];
    NSObject *value = [savedValue objectForKey:key];
    return value;
}


+ (BOOL)isJailbroken
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:@"/bin/bash"]) {
        return YES;
    } else if ([fileManager fileExistsAtPath:@"/bin/ls"]) {
        return YES;
    }
    
    return NO;
}

+ (NSData *)AES128EncryptedData: (NSData *)data WithKey:(NSString *)key
{
    return [self AES128EncryptedData:data WithKey:key iv:nil];
}

+ (NSData *)AES128DecryptedData: (NSData *)data WithKey:(NSString *)key
{
    return [self AES128DecryptedData: data WithKey:key iv:nil];
}

+ (NSData *)AES128EncryptedData: (NSData *)data WithKey:(NSString *)key iv:(NSString *)iv
{
    return [self AES128Operation:kCCEncrypt WithData:data key:key iv:iv];
}

+ (NSData *)AES128DecryptedData: (NSData *)data WithKey:(NSString *)key iv:(NSString *)iv
{
    return [self AES128Operation:kCCDecrypt WithData:data key:key iv:iv];
}

+ (NSData *)AES128Operation:(CCOperation)operation WithData: (NSData *)data  key:(NSString *)key iv:(NSString *)iv
{
    char keyPtr[kCCKeySizeAES128 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];

    char ivPtr[kCCBlockSizeAES128 + 1];
    bzero(ivPtr, sizeof(ivPtr));
    if (iv) {
        [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    }

    NSUInteger dataLength = [data length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);

    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(operation,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr,
                                          kCCBlockSizeAES128,
                                          ivPtr,
                                          [data bytes],
                                          dataLength,
                                          buffer,
                                          bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}

@end


