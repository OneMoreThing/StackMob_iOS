// Copyright 2011 StackMob, Inc
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import <UIKit/UIKit.h>
#import "NSData+Base64.h"
#import "SMFileTest.h"
#import "SMFile.h"
#import "NSString+StackMob.h"

//#import "application_headers" as required

@implementation SMFileTest
- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testJSONSerializastion {
    NSData *data = [NSData data];
    NSString *fName = @"test.jpg";
    NSString *contentType = @"image/jpg";
    SMFile *file =  [[SMFile alloc] initWithFileName:fName data:data contentType:contentType];

    
    NSString *expectedResult = [NSString stringWithFormat:@"Content-Type: %@\n\
                                Content-Disposition: attachment; filename=%@\n\
                                Content-Transfer-Encoding: %@\n\n\
                                %@", contentType,
                                fName, 
                                @"base64",
                                [data base64EncodedString]];
    
    NSString *r = [[file JSON] stringWithoutWhitespaceAndNewLineChars];
    expectedResult = [expectedResult stringWithoutWhitespaceAndNewLineChars];
    bool result = [expectedResult isEqualToString:r];
    STAssertTrue(result, @"JSON serialization failed");
    [file release];
}


@end