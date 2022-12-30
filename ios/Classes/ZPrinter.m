//
//  ZPrinter.m
//  zsdk
//
//  Created by Luis on 1/15/20.
//

#import "ZPrinter.h"
#import "ZebraPrinterFactory.h"
#import "BluetoothPrinterConnection.h"
#import "ErrorCodeUtils.h"
#import "PrinterResponse.h"
#import "SGDParams.h"
#import "SGD.h"
#import "ToolsUtil.h"
#import "PrinterSettings.h"

@implementation ZPrinter
const int MAX_TIME_OUT_FOR_READ = 5000;
const int TIME_TO_WAIT_FOR_MORE_DATA = 0;

- (id)initWithMethodChannel:(FlutterMethodChannel *)channel result:(FlutterResult)result printerConf:(PrinterConf *)printerConf{
    self = [self init];
    if(self){
        self.channel = channel;
        self.result = result;
        self.printerConf = ![ObjectUtils isNull:printerConf] ? printerConf : [[PrinterConf alloc] initWithCmWidth:nil cmHeight:nil dpi:nil orientation:nil];
    }
    return self;
}

+ (BluetoothPrinterConnection *) initWithAddress:(NSString *)anAddress {
    return [[BluetoothPrinterConnection alloc] initWithAddress:anAddress withMaxTimeoutForRead:MAX_TIME_OUT_FOR_READ andWithTimeToWaitForMoreData:TIME_TO_WAIT_FOR_MORE_DATA];
}

- (void)initValues:(id<ZebraPrinterConnection,NSObject>)connection{
    [self.printerConf initValues:connection];
}

- (void)onConnectionTimeOut {
    StatusInfo *statusInfo = [[StatusInfo alloc] init:UNKNOWN_STATUS cause:NO_CONNECTION];
    PrinterResponse *response = [[PrinterResponse alloc] init:EXCEPTION statusInfo:statusInfo message:@"Connection timeout."];
    self.result([FlutterError errorWithCode:[response getErrorCode] message: response.message details:[response toMap]]);
}

- (void)onException:(id<ZebraPrinter,NSObject>)printer exception:(NSException *)exception {
    NSLog(@"%@", exception.reason);
    StatusInfo *statusInfo = [self getStatusInfo:printer];
    PrinterResponse *response = [[PrinterResponse alloc] init:EXCEPTION statusInfo:statusInfo message:[NSString stringWithFormat:@"%@ %@ %@", @"Unknown exception.", exception.name, exception.reason]];
    self.result([FlutterError errorWithCode:[response getErrorCode] message: response.message details:[response toMap]]);
}

- (void)doManualCalibrationOverBluetooth:(NSString *)address {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        id<ZebraPrinter,NSObject> printer;
        id<ZebraPrinterConnection,NSObject> connection;
        @try {
            connection = [ZPrinter initWithAddress:address];
            if(![connection open]) return [self onConnectionTimeOut];
            NSError *error = nil;
            @try {
                printer = [ZebraPrinterFactory getInstance:connection error:&error];
//                id<ToolsUtil,NSObject> toolsUtils = [printer getToolsUtil];
//                [toolsUtils calibrate:&error];
                [SGD DO:SGDParams.KEY_MANUAL_CALIBRATION withValue:nil andWithPrinterConnection:connection error:&error];
                
                if (![ObjectUtils isNull:error])
                    @throw [NSException exceptionWithName:@"Printer error" reason:[error description] userInfo:nil];
                else {
                    StatusInfo *statusInfo = [self getStatusInfo:printer];
                    PrinterResponse *response = [[PrinterResponse alloc] init:SUCCESS statusInfo:statusInfo message:@"Printer status"];
                    self.result([response toMap]);
                }
            }
            @catch (NSException *e) {
                @throw e;
            } @finally {
                [connection close];
            }
        }
        @catch (NSException *e) {
            [self onException:printer exception:e];
        }
    });
}

- (void)printConfigurationLabelOverBluetooth:(NSString *)address {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        id<ZebraPrinter,NSObject> printer;
        id<ZebraPrinterConnection,NSObject> connection;
        @try {
            connection = [ZPrinter initWithAddress:address];
            if(![connection open]) return [self onConnectionTimeOut];
            NSError *error = nil;
            @try {
                printer = [ZebraPrinterFactory getInstance:connection error:&error];
                id<ToolsUtil,NSObject> toolsUtils = [printer getToolsUtil];
                [toolsUtils printConfigurationLabel:&error];
                
                if (![ObjectUtils isNull:error])
                    @throw [NSException exceptionWithName:@"Printer error" reason:[error description] userInfo:nil];
                else {
                    StatusInfo *statusInfo = [self getStatusInfo:printer];
                    PrinterResponse *response = [[PrinterResponse alloc] init:SUCCESS statusInfo:statusInfo message:@"Printer status"];
                    self.result([response toMap]);
                }
            }
            @catch (NSException *e) {
                @throw e;
            } @finally {
                [connection close];
            }
        }
        @catch (NSException *e) {
            [self onException:printer exception:e];
        }
    });
}

- (void)checkPrinterStatusOverBluetooth:(NSString *)address {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        id<ZebraPrinter,NSObject> printer;
        id<ZebraPrinterConnection,NSObject> connection;
        @try {
            connection = [ZPrinter initWithAddress:address];
            if(![connection open]) return [self onConnectionTimeOut];
            NSError *error = nil;
            @try {
                printer = [ZebraPrinterFactory getInstance:connection error:&error];
                StatusInfo *statusInfo = [self getStatusInfo:printer];
                PrinterResponse *response = [[PrinterResponse alloc] init:SUCCESS statusInfo:statusInfo message:@"Printer status"];
                self.result([response toMap]);
            }
            @catch (NSException *e) {
                @throw e;
            } @finally {
                [connection close];
            }
        }
        @catch (NSException *e) {
            [self onException:printer exception:e];
        }
    });
}

- (void)getPrinterSettingsOverBluetooth:(NSString *)address {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        id<ZebraPrinter,NSObject> printer;
        id<ZebraPrinterConnection,NSObject> connection;
        @try {
            connection = [ZPrinter initWithAddress:address];
            if(![connection open]) return [self onConnectionTimeOut];
            NSError *error = nil;
            @try {
                printer = [ZebraPrinterFactory getInstance:connection error:&error];
                PrinterSettings *settings = [PrinterSettings get:connection];
                StatusInfo *statusInfo = [self getStatusInfo:printer];
                PrinterResponse *response = [[PrinterResponse alloc] initWithSettings:SUCCESS statusInfo:statusInfo settings:settings message:@"Printer status"];
                self.result([response toMap]);
            }
            @catch (NSException *e) {
                @throw e;
            } @finally {
                [connection close];
            }
        }
        @catch (NSException *e) {
            [self onException:printer exception:e];
        }
    });
}

- (void)setPrinterSettingsOverBluetooth:(NSString *)address settings:(PrinterSettings *)settings {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        id<ZebraPrinter,NSObject> printer;
        id<ZebraPrinterConnection,NSObject> connection;
        @try {
            
            if([ObjectUtils isNull:settings])
                @throw [NSException exceptionWithName:@"Printer Error" reason:@"Settings can't be null" userInfo:nil];
            
            connection = [ZPrinter initWithAddress:address];
            if(![connection open]) return [self onConnectionTimeOut];
            NSError *error = nil;
            @try {
                printer = [ZebraPrinterFactory getInstance:connection error:&error];
                [settings apply:connection];
                PrinterSettings *settings = [PrinterSettings get:connection];
                StatusInfo *statusInfo = [self getStatusInfo:printer];
                PrinterResponse *response = [[PrinterResponse alloc] initWithSettings:SUCCESS statusInfo:statusInfo settings:settings message:@"Printer status"];
                self.result([response toMap]);
            }
            @catch (NSException *e) {
                @throw e;
            } @finally {
                [connection close];
            }
        }
        @catch (NSException *e) {
            [self onException:printer exception:e];
        }
    });
}

- (void)printZplFileOverBluetooth:(NSString *)filePath address:(NSString *)address {
    //check if file exist.
    //Extract data from file
    //call printZplDataOverBluetooth passing the extracted data from file
    self.result(FlutterMethodNotImplemented);
}

- (void)printZplDataOverBluetooth:(NSString *)data address:(NSString *)address {
    [self doPrintZplDataOverBluetooth:data address:address];
}

- (void) doPrintZplDataOverBluetooth:(NSString *)data address:(NSString *)address {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        id<ZebraPrinter,NSObject> printer;
        id<ZebraPrinterConnection,NSObject> connection;
        @try {
            if([ObjectUtils isNull:data])
                @throw [NSException exceptionWithName:@"Printer Error" reason:@"ZPL data can not be empty" userInfo:nil];

            connection = [ZPrinter initWithAddress:address];
            if(![connection open]) return [self onConnectionTimeOut];
            NSError *error = nil;
            @try {
                printer = [ZebraPrinterFactory getInstance:connection error:&error];
                if ([self isReadyToPrint:printer]) {
                    [self initValues:connection];
                    [self changePrinterLanguage:connection language:SGDParams.VALUE_ZPL_LANGUAGE];
                    
                    [connection write:[data dataUsingEncoding:NSUTF8StringEncoding] error:&error];
                    
                    if (![ObjectUtils isNull:error])
                        @throw [NSException exceptionWithName:@"Printer error" reason:[error description] userInfo:nil];
                    else {
                        StatusInfo *statusInfo = [self getStatusInfo:printer];
                        PrinterResponse *response = [[PrinterResponse alloc] init:SUCCESS statusInfo:statusInfo message:@"Successful print"];
                        self.result([response toMap]);
                    }
                } else {
                    StatusInfo *statusInfo = [self getStatusInfo:printer];
                    PrinterResponse *response = [[PrinterResponse alloc] init:PRINTER_ERROR statusInfo:statusInfo message:@"Printer is not ready"];
                    self.result([FlutterError errorWithCode:[response getErrorCode] message: response.message details:[response toMap]]);
                }
            }
            @catch (NSException *e) {
                @throw e;
            } @finally {
                [connection close];
            }
        }
        @catch (NSException *e) {
            [self onException:printer exception:e];
        }
    });
}

- (bool)isReadyToPrint:(id<ZebraPrinter,NSObject>)printer{
    @try {
        NSError *error = nil;
        bool value = [[printer getCurrentStatus:&error] isReadyToPrint];
        if (![ObjectUtils isNull:error])
            @throw [NSException exceptionWithName:@"Printer Error" reason:[error description] userInfo:nil];
        return value;
    } @catch (NSException *e) {
        NSLog(@"%@", e.reason);
    }
    return false;
}

- (StatusInfo *)getStatusInfo:(id<ZebraPrinter,NSObject>)printer{
    Status status = UNKNOWN_STATUS;
    Cause cause = UNKNOWN_CAUSE;
    @try {
        NSError *error = nil;
        PrinterStatus *printerStatus = [printer getCurrentStatus:&error];
        if (![ObjectUtils isNull:error])
            @throw [NSException exceptionWithName:@"Printer Error" reason:[error description] userInfo:nil];
        
        if([printerStatus isPaused]) status = PAUSED;
        if([printerStatus isReadyToPrint]) status = READY_TO_PRINT;

        if([printerStatus isPartialFormatInProgress]) cause = PARTIAL_FORMAT_IN_PROGRESS;
        if([printerStatus isHeadCold]) cause = HEAD_COLD;
        if([printerStatus isHeadOpen]) cause = HEAD_OPEN;
        if([printerStatus isHeadTooHot]) cause = HEAD_TOO_HOT;
        if([printerStatus isPaperOut]) cause = PAPER_OUT;
        if([printerStatus isRibbonOut]) cause = RIBBON_OUT;
        if([printerStatus isReceiveBufferFull]) cause = RECEIVE_BUFFER_FULL;

    } @catch (NSException *e) {
        NSLog(@"%@", e.reason);
    }
    return [[StatusInfo alloc] init:status cause:cause];
}

- (void)changePrinterLanguage:(id<ZebraPrinterConnection,NSObject>)connection language:(NSString *)language {
    if([ObjectUtils isNull:connection]) return;
    if(![connection isConnected]) [connection open];

    if([ObjectUtils isNull:language]) language = SGDParams.VALUE_ZPL_LANGUAGE;

    NSError *error = nil;
    const NSString *printerLanguage = [SGD GET:SGDParams.KEY_PRINTER_LANGUAGES withPrinterConnection:connection error:&error];
    if (![ObjectUtils isNull:error])
        @throw [NSException exceptionWithName:@"Printer Error" reason:[error description] userInfo:nil];
    if(![printerLanguage isEqualToString:language]){
        [SGD SET:SGDParams.KEY_PRINTER_LANGUAGES withValue:language andWithPrinterConnection:connection error:&error];
        if (error != nil)
            @throw [NSException exceptionWithName:@"Printer Error" reason:[error description] userInfo:nil];
    }
}

@end
