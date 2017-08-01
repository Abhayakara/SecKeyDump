//
//  ViewController.m
//  oxbed
//
//  Created by Ted Lemon on 7/31/17.
//  Copyright © 2017 Ted Lemon. All rights reserved.
//  See LICENSE for license terms

#import "ViewController.h"

@implementation ViewController

- (void)kablooie: (CFErrorRef)error withTitle: (NSString *)errTitle {
    NSError *err = CFBridgingRelease(error);  // ARC takes ownership
    
    NSAlert *alert = [NSAlert alertWithError: err];
    [alert beginSheetModalForWindow: [[self view] window] completionHandler:
                                    ^(NSModalResponse returncode) {}];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary* attributes =
    @{ (id)kSecAttrKeyType:               (id)kSecAttrKeyTypeRSA,
       (id)kSecAttrKeySizeInBits:         @2048,
       (id)kSecPrivateKeyAttrs:
           @{ (id)kSecAttrIsPermanent:    @NO,
              },
       };
    CFErrorRef error = NULL;
    SecKeyRef privateKey = SecKeyCreateRandomKey((__bridge CFDictionaryRef)attributes,
                                                 &error);
    if (!privateKey) {
        [self kablooie: error withTitle: @"SecKeyCreateRandomKey Failed"];
        return;
    }
    
    error = NULL;
    CFDataRef raw = SecKeyCopyExternalRepresentation(privateKey, &error);
    if (!raw) {
        [self kablooie: error withTitle: @"SecKeyCopyExternalRepresentation Failed"];
        return;
    }
    
    const UInt8 *keyData = CFDataGetBytePtr(raw);
    long len = CFDataGetLength(raw);
    long i;
    char *str = malloc(len * 3 + 1);
    
    for (i = 0; i < len; i++) {
        str[i * 3] = "0123456789ABCDEF"[(keyData[i] >> 4) & 15];
        str[i * 3 + 1] = "0123456789ABCDEF"[keyData[i] & 15];
        str[i * 3 + 2] = ' ';
    }
    str[i * 3 - 1] = 0;
    [[tv textStorage] appendAttributedString:
     [[NSAttributedString alloc]
      initWithString: [NSString stringWithUTF8String: str]]];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
