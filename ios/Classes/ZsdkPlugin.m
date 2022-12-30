#import "ZsdkPlugin.h"
#import <ExternalAccessory/ExternalAccessory.h>
#import "MfiBtPrinterConnection.h"
#import "ZebraPrinter.h"
#import "ZebraPrinterFactory.h"
#import "ZebraPrinterConnection.h"
#import "BluetoothPrinterConnection.h"
#import "SGD.h"

#import "CauseUtils.h"
#import "ErrorCodeUtils.h"
#import "OrientationUtils.h"
#import "StatusInfo.h"
#import "PrinterResponse.h"
#import "PrinterConf.h"
#import "ZPrinter.h"
#import "SGDParams.h"

@implementation ZsdkPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [[ZsdkPlugin alloc] init:registrar];
}

/* Channel */
NSString* _METHOD_CHANNEL = @"zsdk";

/* Methods */
NSString* _PRINT_PDF_FILE_OVER_BLUETOOTH = @"printPdfFileOverBluetooth";
NSString* _PRINT_PDF_DATA_OVER_BLUETOOTH = @"printPdfDataOverBluetooth";
NSString* _PRINT_ZPL_FILE_OVER_BLUETOOTH = @"printZplFileOverBluetooth";
NSString* _PRINT_ZPL_DATA_OVER_BLUETOOTH = @"printZplDataOverBluetooth";
NSString* _CHECK_PRINTER_STATUS_OVER_BLUETOOTH = @"checkPrinterStatusOverBluetooth";
NSString* _GET_PRINTER_SETTINGS_OVER_BLUETOOTH = @"getPrinterSettingsOverBluetooth";
NSString* _SET_PRINTER_SETTINGS_OVER_BLUETOOTH = @"setPrinterSettingsOverBluetooth";
NSString* _DO_MANUAL_CALIBRATION_OVER_BLUETOOTH = @"doManualCalibrationOverBluetooth";
NSString* _PRINT_CONFIGURATION_LABEL_OVER_BLUETOOTH = @"printConfigurationLabelOverBluetooth";

/* Properties */
NSString* _filePath = @"filePath";
NSString* _data = @"data";
NSString* _address = @"address";
NSString* _cmWidth = @"cmWidth";
NSString* _cmHeight = @"cmHeight";
NSString* _orientation = @"orientation";
NSString* _dpi = @"dpi";

- (id)init:(id<FlutterPluginRegistrar,NSObject>)registrar {
    self = [self init];
    if(self){
        self.channel =[FlutterMethodChannel
        methodChannelWithName:_METHOD_CHANNEL binaryMessenger:[registrar messenger]];
        [registrar addMethodCallDelegate:self channel:self.channel];
    }
    return self;
}

- (void)discoverBluetoothDevices:(FlutterResult)result {
    @try {
        NSString *serialNumber = @"";
        NSString *name = @"";
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        
        EAAccessoryManager *sam = [EAAccessoryManager sharedAccessoryManager];
        NSArray * connectedAccessories = [sam connectedAccessories];
        for (EAAccessory *accessory in connectedAccessories) {
            if([accessory.protocolStrings indexOfObject:@"com.zebra.rawport"] != NSNotFound){
                serialNumber = accessory.serialNumber;
                name = accessory.name;
                
                [dict setObject:name forKey:serialNumber];
            }
        }
        result(dict);
    }
    @catch (NSException *exception) {
        result([FlutterError errorWithCode:@"Error"
                                       message: exception.reason
                                       details:nil]);
    }
}
- (void)getDeviceProperties:(NSString*) serial result:(FlutterResult)result {
     NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
     [dict setObject:@"Not Implemented" forKey:@"error"];
     result(dict);
}
- (void)getBatteryLevel:(NSString*) serial result:(FlutterResult)result {
   dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        @try {
            id<ZebraPrinterConnection, NSObject> connection = [[MfiBtPrinterConnection alloc] initWithSerialNumber:serial];
            
            NSError *error = nil;
            
            [connection open];
            
            NSString *battery = [SGD GET:@"power.percent_full" withPrinterConnection:connection error:&error];
            
            [connection close];
            
            if (error != nil) {
                @throw [NSException exceptionWithName:@"Printer Error"
                                               reason:[error description]
                                               userInfo:nil];
            }
            
            result(battery);
        }
        @catch (NSException *e) {
            result([FlutterError errorWithCode:@"Error"
                                       message: e.reason
                                       details:nil]);
        }
    });
}
- (void)sendZplOverBluetooth:(NSString *)serial data:(NSString*)data result:(FlutterResult)result {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        @try {
            // Instantiate connection to Zebra Bluetooth accessory
            //EAAccessoryManager *sam = [EAAccessoryManager sharedAccessoryManager];
            
            id<ZebraPrinterConnection, NSObject> connection = [[MfiBtPrinterConnection alloc] initWithSerialNumber:serial];
            
            NSError *error = nil;
            //BOOL success =
             [connection open];
            
            /*
             id<ZebraPrinter,NSObject> printer = [ZebraPrinterFactory getInstance:connection error:&error];
            */
            NSData *dataBytes = [NSData dataWithBytes:[data UTF8String] length:[data length]];
            
            [connection write:dataBytes error:&error];
            
            /*
             success = success && [thePrinterConn write:[data dataUsingEncoding:NSUTF8StringEncoding] error:&error];
             */
            if (error != nil) {
                @throw [NSException exceptionWithName:@"Printer Error"
                                               reason:[error description]
                                               userInfo:nil];
            } else {
                result(@"Wrote. Are you happy?");
            }
        
            [connection close];
        }@catch (NSException *exception) {
                result([FlutterError errorWithCode:@"Error"
                                           message: exception.reason
                                           details:nil]);
         }
       // [connection release];
    });
    
}
- (void)test:(FlutterResult)result {
    @try {
        id<ZebraPrinterConnection,NSObject> connection = [[BluetoothPrinterConnection alloc] initWithAddress:@"10.0.1.100"];
        [connection open];
        PrinterConf *printerConf = [[PrinterConf alloc] initWithCmWidth:nil cmHeight:nil dpi:nil orientation:nil];
        
        [printerConf initValues:connection];
    }
    @catch (NSException *exception) {
        result([FlutterError errorWithCode:@"Error"
                                       message: exception.reason
                                       details:nil]);
    }
}



- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    @try {
//        NSLog(@"%@", SGDParams.KEY_DARKNESS);
//        NSLog(@"%f", SGDParams.VALUE_DPI_DEFAULT);
        NSDictionary *arguments = [call arguments];
         ZPrinter *printer = [[ZPrinter alloc]
                              initWithMethodChannel:self.channel
                              result:result
                              printerConf:[[PrinterConf alloc]
                                           initWithCmWidth:arguments[_cmWidth]
                                           cmHeight:arguments[_cmHeight]
                                           dpi:arguments[_dpi]
                                           orientation:arguments[_orientation]
                                           ]
                              ];
        
        if ([_DO_MANUAL_CALIBRATION_OVER_BLUETOOTH isEqualToString:call.method])
            [printer doManualCalibrationOverBluetooth:arguments[_address]];
        else if ([_PRINT_CONFIGURATION_LABEL_OVER_BLUETOOTH isEqualToString:call.method])
            [printer printConfigurationLabelOverBluetooth:arguments[_address]];
        else if ([_CHECK_PRINTER_STATUS_OVER_BLUETOOTH isEqualToString:call.method])
            [printer checkPrinterStatusOverBluetooth:arguments[_address]];
        else if ([_GET_PRINTER_SETTINGS_OVER_BLUETOOTH isEqualToString:call.method])
            [printer getPrinterSettingsOverBluetooth:arguments[_address]];
        else if ([_SET_PRINTER_SETTINGS_OVER_BLUETOOTH isEqualToString:call.method])
            [printer setPrinterSettingsOverBluetooth:arguments[_address] settings:[[PrinterSettings alloc] initWithArguments:arguments]];
        else if ([_PRINT_ZPL_FILE_OVER_BLUETOOTH isEqualToString:call.method])
           [printer printZplFileOverBluetooth:arguments[_filePath] address:arguments[_address]];
        else if ([_PRINT_ZPL_DATA_OVER_BLUETOOTH isEqualToString:call.method])
            [printer printZplDataOverBluetooth:arguments[_data] address:arguments[_address]];
        else result(FlutterMethodNotImplemented);
    } @catch (NSException *e) {
        StatusInfo *statusInfo = [[StatusInfo alloc] init:UNKNOWN_STATUS cause:UNKNOWN_CAUSE];
        PrinterResponse *response = [[PrinterResponse alloc] init:EXCEPTION statusInfo:statusInfo message:[NSString stringWithFormat: @"%@ %@", @"Exception handling MethodCall", e.reason]];
        result([FlutterError errorWithCode:[response getErrorCode] message: response.message details:[response toMap]]);
    }
}
       

@end
