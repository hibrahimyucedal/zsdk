import 'dart:async';
import 'package:flutter/services.dart';
import 'package:zsdk/src/enumerators/cause.dart';
import 'package:zsdk/src/enumerators/error_code.dart';
import 'package:zsdk/src/enumerators/orientation.dart';
import 'package:zsdk/src/enumerators/status.dart';
import 'package:zsdk/src/printer_conf.dart';
import 'package:zsdk/src/printer_response.dart';
import 'package:zsdk/src/printer_settings.dart';
import 'package:zsdk/src/status_info.dart';

export 'package:zsdk/src/enumerators/cause.dart';
export 'package:zsdk/src/enumerators/error_code.dart';
export 'package:zsdk/src/enumerators/head_close_action.dart';
export 'package:zsdk/src/enumerators/media_type.dart';
export 'package:zsdk/src/enumerators/orientation.dart';
export 'package:zsdk/src/enumerators/power_up_action.dart';
export 'package:zsdk/src/enumerators/print_method.dart';
export 'package:zsdk/src/enumerators/print_mode.dart';
export 'package:zsdk/src/printer_conf.dart';
export 'package:zsdk/src/printer_response.dart';
export 'package:zsdk/src/printer_settings.dart';
export 'package:zsdk/src/enumerators/reprint_mode.dart';
export 'package:zsdk/src/enumerators/status.dart';
export 'package:zsdk/src/status_info.dart';
export 'package:zsdk/src/enumerators/zpl_mode.dart';

class ZSDK {
  ///In seconds
  static const int DEFAULT_CONNECTION_TIMEOUT = 10;

  /// Channel
  static const String _METHOD_CHANNEL = "zsdk";

  /// Methods
  static const String _PRINT_PDF_FILE_OVER_BLUETOOTH = "printPdfFileOverBluetooth";
  static const String _PRINT_IMAGE_OVER_BLUETOOTH = "printImageOverBluetooth";
  static const String _PRINT_PDF_DATA_OVER_BLUETOOTH = "printPdfDataOverBluetooth";
  static const String _PRINT_ZPL_FILE_OVER_BLUETOOTH = "printZplFileOverBluetooth";
  static const String _PRINT_ZPL_DATA_OVER_BLUETOOTH = "printZplDataOverBluetooth";
  static const String _CHECK_PRINTER_STATUS_OVER_BLUETOOTH =
      "checkPrinterStatusOverBluetooth";
  static const String _GET_PRINTER_SETTINGS_OVER_BLUETOOTH =
      "getPrinterSettingsOverBluetooth";
  static const String _SET_PRINTER_SETTINGS_OVER_BLUETOOTH =
      "setPrinterSettingsOverBluetooth";
  static const String _DO_MANUAL_CALIBRATION_OVER_BLUETOOTH =
      "doManualCalibrationOverBluetooth";
  static const String _PRINT_CONFIGURATION_LABEL_OVER_BLUETOOTH =
      "printConfigurationLabelOverBluetooth";

  /// Properties
  static const String _filePath = "filePath";
  static const String _data = "data";
  static const String _address = "address";
  static const String _base64 = "base64";
  static const String _cmWidth = "cmWidth";
  static const String _cmHeight = "cmHeight";
  static const String _orientation = "orientation";
  static const String _dpi = "dpi";

  late MethodChannel _channel;

  ZSDK() {
    _channel = const MethodChannel(_METHOD_CHANNEL);
    _channel.setMethodCallHandler(_onMethodCall);
  }

  Future<void> _onMethodCall(MethodCall call) async {
    try {
      switch (call.method) {
        default:
          print(call.arguments);
      }
    } catch (e) {
      print(e);
    }
  }

  FutureOr<T> _onTimeout<T>({Duration? timeout}) => throw PlatformException(
      code: ErrorCode.EXCEPTION.name,
      message:
          "Connection timeout${timeout != null ? " after ${timeout.inSeconds} seconds of waiting" : "."}",
      details: PrinterResponse(
        errorCode: ErrorCode.EXCEPTION,
        message:
            "Connection timeout${timeout != null ? " after ${timeout.inSeconds} seconds of waiting" : "."}",
        statusInfo: StatusInfo(
          Status.UNKNOWN,
          Cause.NO_CONNECTION,
        ),
      ).toMap());

  Future doManualCalibrationOverBluetooth(
          {required String address, Duration? timeout}) =>
      _channel.invokeMethod(_DO_MANUAL_CALIBRATION_OVER_BLUETOOTH, {
        _address: address
      }).timeout(
          timeout ??= const Duration(seconds: DEFAULT_CONNECTION_TIMEOUT),
          onTimeout: () => _onTimeout(timeout: timeout));

  Future printConfigurationLabelOverBluetooth(
          {required String address, Duration? timeout}) =>
      _channel.invokeMethod(_PRINT_CONFIGURATION_LABEL_OVER_BLUETOOTH, {
        _address: address,
      }).timeout(
          timeout ??= const Duration(seconds: DEFAULT_CONNECTION_TIMEOUT),
          onTimeout: () => _onTimeout(timeout: timeout));

  Future checkPrinterStatusOverBluetooth(
          {required String address, Duration? timeout}) =>
      _channel.invokeMethod(_CHECK_PRINTER_STATUS_OVER_BLUETOOTH, {
        _address: address
      }).timeout(
          timeout ??= const Duration(seconds: DEFAULT_CONNECTION_TIMEOUT),
          onTimeout: () => _onTimeout(timeout: timeout));

  Future getPrinterSettingsOverBluetooth(
          {required String address, Duration? timeout}) =>
      _channel.invokeMethod(_GET_PRINTER_SETTINGS_OVER_BLUETOOTH, {
        _address: address
      }).timeout(
          timeout ??= const Duration(seconds: DEFAULT_CONNECTION_TIMEOUT),
          onTimeout: () => _onTimeout(timeout: timeout));

  Future setPrinterSettingsOverBluetooth(
          {required PrinterSettings settings,
          required String address,
          Duration? timeout}) =>
      _channel
          .invokeMethod(
              _SET_PRINTER_SETTINGS_OVER_BLUETOOTH,
              {
                _address: address as dynamic
              }..addAll(settings.toMap()))
          .timeout(
              timeout ??= const Duration(seconds: DEFAULT_CONNECTION_TIMEOUT),
              onTimeout: () => _onTimeout(timeout: timeout));

  Future resetPrinterSettingsOverBluetooth(
          {required String address,Duration? timeout}) =>
      setPrinterSettingsOverBluetooth(
          settings: PrinterSettings.defaultSettings(),
          address: address,
          timeout: timeout);

  Future printPdfFileOverBluetooth(
          {required String filePath,
          required String address,
          PrinterConf? printerConf,
          Duration? timeout}) =>
      _printFileOverBluetooth(
          method: _PRINT_PDF_FILE_OVER_BLUETOOTH,
          filePath: filePath,
          address: address,
          printerConf: printerConf,
          timeout: timeout);

  Future printImageOverBluetooth(
          {required String base64,
          required String address,
          PrinterConf? printerConf,
          Duration? timeout}) =>
      _printImageOverBluetooth(
          method: _PRINT_IMAGE_OVER_BLUETOOTH,
          base64: base64,
          address: address,
          printerConf: printerConf,
          timeout: timeout);

  Future printZplFileOverBluetooth(
          {required String filePath,
          required String address,
          PrinterConf? printerConf,
          Duration? timeout}) =>
      _printFileOverBluetooth(
          method: _PRINT_ZPL_FILE_OVER_BLUETOOTH,
          filePath: filePath,
          address: address,
          printerConf: printerConf,
          timeout: timeout);

  Future _printImageOverBluetooth(
          {required method,
          required String base64,
          required String address,
          PrinterConf? printerConf,
          Duration? timeout}) =>
      _channel.invokeMethod(method, {
        _base64: base64,
        _address: address,
        _cmWidth: printerConf?.cmWidth,
        _cmHeight: printerConf?.cmHeight,
        _dpi: printerConf?.dpi,
        _orientation: printerConf?.orientation?.name,
      }).timeout(
          timeout ??= const Duration(seconds: DEFAULT_CONNECTION_TIMEOUT),
          onTimeout: () => _onTimeout(timeout: timeout));
  
  Future _printFileOverBluetooth(
          {required method,
          required String filePath,
          required String address,
          PrinterConf? printerConf,
          Duration? timeout}) =>
      _channel.invokeMethod(method, {
        _filePath: filePath,
        _address: address,
        _cmWidth: printerConf?.cmWidth,
        _cmHeight: printerConf?.cmHeight,
        _dpi: printerConf?.dpi,
        _orientation: printerConf?.orientation?.name,
      }).timeout(
          timeout ??= const Duration(seconds: DEFAULT_CONNECTION_TIMEOUT),
          onTimeout: () => _onTimeout(timeout: timeout));

  Future printPdfDataOverBluetooth(
          {required ByteData data,
          required String address,
          PrinterConf? printerConf,
          Duration? timeout}) =>
      _printDataOverBluetooth(
          method: _PRINT_PDF_DATA_OVER_BLUETOOTH,
          data: data,
          address: address,
          printerConf: printerConf,
          timeout: timeout);

  Future printZplDataOverBluetooth(
          {required String data,
          required String address,
          PrinterConf? printerConf,
          Duration? timeout}) =>
      _printDataOverBluetooth(
          method: _PRINT_ZPL_DATA_OVER_BLUETOOTH,
          data: data,
          address: address,
          printerConf: printerConf,
          timeout: timeout);

  Future _printDataOverBluetooth(
          {required method,
          required dynamic data,
          required String address,
          PrinterConf? printerConf,
          Duration? timeout}) =>
      _channel.invokeMethod(method, {
        _data: data,
        _address: address,
        _cmWidth: printerConf?.cmWidth,
        _cmHeight: printerConf?.cmHeight,
        _dpi: printerConf?.dpi,
        _orientation: printerConf?.orientation?.name,
      }).timeout(
          timeout ??= const Duration(seconds: DEFAULT_CONNECTION_TIMEOUT),
          onTimeout: () => _onTimeout(timeout: timeout));
}
