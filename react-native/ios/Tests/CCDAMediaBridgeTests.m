#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <XCTest/XCTest.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTUtils.h>

@protocol CCDATestNativeModule <NSObject>
- (void)parseXml:(NSString *)xml options:(NSDictionary *)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject;
- (void)openMedia:(NSDictionary *)media resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject;
@end

@interface CCDAMediaBridgeTests : XCTestCase
@property(nonatomic, strong) id<CCDATestNativeModule> bridge;
@property(nonatomic, strong) NSURL *cacheDirectory;
@end

@implementation CCDAMediaBridgeTests

- (void)setUp
{
  [super setUp];
  Class bridgeClass = NSClassFromString(@"CCDAKit");
  XCTAssertNotNil(bridgeClass, @"The native bridge must be linked into the test host");
  self.bridge = (id<CCDATestNativeModule>)[[bridgeClass alloc] init];
  self.cacheDirectory = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:NSUUID.UUID.UUIDString]];
  [[NSFileManager defaultManager] createDirectoryAtURL:self.cacheDirectory withIntermediateDirectories:YES attributes:nil error:nil];
}

- (void)tearDown
{
  [[NSFileManager defaultManager] removeItemAtURL:self.cacheDirectory error:nil];
  self.bridge = nil;
  [super tearDown];
}

// Public synthetic payloads from test-data/ccda/samples/local-media-attachments.xml.
// Kept as literals so the pod's tests do not need a monorepo checkout at runtime.
- (NSArray<NSDictionary *> *)records
{
  return @[
    @{@"kind": @"imagePNG", @"value": @"iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAwUBAScY42YAAAAASUVORK5CYII="},
    @{@"kind": @"applicationPDF", @"value": @"JVBERi0xLjEKMSAwIG9iago8PCAvVHlwZSAvQ2F0YWxvZyAvUGFnZXMgMiAwIFIgPj4KZW5kb2JqCjIgMCBvYmoKPDwgL1R5cGUgL1BhZ2VzIC9LaWRzIFszIDAgUl0gL0NvdW50IDEgPj4KZW5kb2JqCjMgMCBvYmoKPDwgL1R5cGUgL1BhZ2UgL1BhcmVudCAyIDAgUiAvTWVkaWFCb3ggWzAgMCAyMDAgMTIwXSAvQ29udGVudHMgNCAwIFIgPj4KZW5kb2JqCjQgMCBvYmoKPDwgL0xlbmd0aCA0NCA+PgpzdHJlYW0KQlQgL0YxIDEyIFRmIDIwIDYwIFRkIChDQ0RBIFBERiBBdHRhY2htZW50KSBUaiBFVAplbmRzdHJlYW0KZW5kb2JqCnhyZWYKMCA1CjAwMDAwMDAwMDAgNjU1MzUgZiAKMDAwMDAwMDAwOSAwMDAwMCBuIAowMDAwMDAwMDU4IDAwMDAwIG4gCjAwMDAwMDAxMTUgMDAwMDAgbiAKMDAwMDAwMDIwNCAwMDAwMCBuIAp0cmFpbGVyCjw8IC9Sb290IDEgMCBSIC9TaXplIDUgPj4Kc3RhcnR4cmVmCjI5NwolJUVPRgo="},
    @{@"kind": @"textPlain", @"value": @"VGhpcyBpcyBhIHBsYWluIHRleHQgQ0NEQSBhdHRhY2htZW50Lgo="},
    @{@"kind": @"textHTML", @"value": @"PGh0bWw+PGJvZHk+PGgxPkNDREEgSFRNTCBBdHRhY2htZW50PC9oMT48cD5UaGlzIEhUTUwgYXR0YWNobWVudCBpcyBidW5kbGVkIGZyb20gc2hhcmVkIHRlc3QgZGF0YS48L3A+PC9ib2R5PjwvaHRtbD4="}
  ];
}

- (void)assertPreviewsForPolicy:(NSString *)policy
{
  for (NSDictionary *record in [self records]) {
    NSDictionary *payload;
    if ([policy isEqualToString:@"cachedFile"]) {
      NSURL *file = [self.cacheDirectory URLByAppendingPathComponent:record[@"kind"]];
      NSData *data = [[NSData alloc] initWithBase64EncodedString:record[@"value"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
      XCTAssertTrue([data writeToURL:file atomically:YES]);
      payload = @{@"kind": @"cachedFile", @"filePath": file.path};
    } else {
      payload = @{@"kind": @"inlineBase64", @"value": record[@"value"]};
    }
    NSDictionary *media = @{@"mediaType": @{@"kind": record[@"kind"]}, @"payload": payload};
    XCTestExpectation *opened = [self expectationWithDescription:@"Open attachment preview"];
    [self.bridge openMedia:media resolver:^(__unused id result) { [opened fulfill]; }
                 rejecter:^(NSString *code, NSString *message, NSError *error) {
      XCTFail(@"Preview failed: %@ %@", code, message);
      [opened fulfill];
    }];
    [self waitForExpectations:@[opened] timeout:10];
    UIViewController *presented = RCTPresentedViewController();
    XCTAssertTrue([presented isKindOfClass:UINavigationController.class]);
    if (![presented isKindOfClass:UINavigationController.class]) continue;
    UINavigationController *navigation = (UINavigationController *)presented;
    UIViewController *preview = navigation.topViewController;
    XCTAssertNotNil(preview.navigationItem.rightBarButtonItem);
    Class contentType = [record[@"kind"] hasPrefix:@"image"] ? UIImageView.class : WKWebView.class;
    XCTAssertTrue([self view:preview.view containsClass:contentType]);
    XCTestExpectation *closed = [self expectationWithDescription:@"Dismiss preview"];
    [navigation dismissViewControllerAnimated:NO completion:^{ [closed fulfill]; }];
    [self waitForExpectations:@[closed] timeout:5];
    XCTAssertNil(navigation.presentingViewController);
  }
}

- (BOOL)view:(UIView *)view containsClass:(Class)type
{
  if ([view isKindOfClass:type]) return YES;
  for (UIView *child in view.subviews) if ([self view:child containsClass:type]) return YES;
  return NO;
}

- (void)testCachedImagesPDFTextAndHTMLPreviews { [self assertPreviewsForPolicy:@"cachedFile"]; }
- (void)testInlineImagesPDFTextAndHTMLPreviews { [self assertPreviewsForPolicy:@"inlineBase64"]; }

- (void)expectPreviewFailure:(NSDictionary *)media
{
  XCTestExpectation *failed = [self expectationWithDescription:@"Reject invalid attachment"];
  [self.bridge openMedia:media resolver:^(__unused id result) {
    XCTFail(@"Invalid attachment unexpectedly opened");
    [failed fulfill];
  } rejecter:^(NSString *code, NSString *message, NSError *error) {
    XCTAssertEqualObjects(code, @"CCDA_PREVIEW_FAILED");
    XCTAssertGreaterThan(message.length, 0);
    [failed fulfill];
  }];
  [self waitForExpectations:@[failed] timeout:5];
}

- (void)testMissingCachedFileRejects
{
  [self expectPreviewFailure:@{@"mediaType": @{@"kind": @"textPlain"}, @"payload": @{
    @"kind": @"cachedFile", @"filePath": [self.cacheDirectory.path stringByAppendingPathComponent:@"missing.txt"]
  }}];
}

- (void)testMalformedImageRejects
{
  [self expectPreviewFailure:@{@"mediaType": @{@"kind": @"imagePNG"}, @"payload": @{@"kind": @"inlineBase64", @"value": @"%%%invalid"}}];
}

- (void)testUnsupportedAndUnavailableMediaReject
{
  [self expectPreviewFailure:@{@"mediaType": @{@"kind": @"unsupported"}, @"payload": @{@"kind": @"unavailable"}}];
  [self expectPreviewFailure:@{@"mediaType": @{@"kind": @"textHTML"}, @"payload": @{@"kind": @"unavailable"}}];
}

- (void)testParserCachesTextWithNumericByteCount
{
  NSString *xml = @"<ClinicalDocument xmlns=\"urn:hl7-org:v3\"><id root=\"test\"/><component><structuredBody><component><section><title>Test</title><entry><observationMedia ID=\"text\"><value mediaType=\"text/plain\" representation=\"B64\">VGVzdA==</value></observationMedia></entry></section></component></structuredBody></component></ClinicalDocument>";
  XCTestExpectation *parsed = [self expectationWithDescription:@"Parse cached media"];
  [self.bridge parseXml:xml options:@{@"mediaCacheDirectory": self.cacheDirectory.path}
              resolver:^(id result) {
    NSDictionary *document = result;
    NSDictionary *payload = document[@"sections"][0][@"media"][0][@"payload"];
    XCTAssertEqualObjects(payload[@"kind"], @"cachedFile");
    XCTAssertTrue([payload[@"byteCount"] isKindOfClass:NSNumber.class]);
    XCTAssertEqualObjects(payload[@"byteCount"], @4);
    XCTAssertEqualObjects([NSData dataWithContentsOfFile:payload[@"filePath"]], [@"Test" dataUsingEncoding:NSUTF8StringEncoding]);
    [parsed fulfill];
  } rejecter:^(NSString *code, NSString *message, NSError *error) {
    XCTFail(@"Parsing failed: %@ %@", code, message);
    [parsed fulfill];
  }];
  [self waitForExpectations:@[parsed] timeout:10];
}

- (void)testMalformedXMLPreservesParserErrorCode
{
  XCTestExpectation *failed = [self expectationWithDescription:@"Reject malformed XML"];
  [self.bridge parseXml:@"<ClinicalDocument>" options:@{} resolver:^(__unused id document) {
    XCTFail(@"Malformed XML unexpectedly parsed");
    [failed fulfill];
  } rejecter:^(NSString *code, NSString *message, NSError *error) {
    XCTAssertEqualObjects(code, @"CCDA_INVALID_XML");
    [failed fulfill];
  }];
  [self waitForExpectations:@[failed] timeout:5];
}
@end
