//  Created by Murphy on 11/06/17.
//  Copyright © 2017 Murphy. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>


@interface Utils : NSObject

+ (BOOL)isJailbroken;
+ (NSData *)AES128EncryptedData: (NSData *)data WithKey:(NSString *)key;
+ (NSData *)AES128DecryptedData: (NSData *)data WithKey:(NSString *)key;
+ (NSData *)AES128EncryptedData: (NSData *)data WithKey:(NSString *)key iv:(NSString *)iv;
+ (NSData *)AES128DecryptedData: (NSData *)data WithKey:(NSString *)key iv:(NSString *)iv;
+ (NSData *)AES128Operation:(CCOperation)operation WithData: (NSData *)data  key:(NSString *)key iv:(NSString *)iv;
+ (void) updateConfigKey:(NSString *)key WithValue:(id)value;
+ (id) getConfigKey:(NSString *)key;
@end
