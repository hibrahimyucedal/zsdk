package com.plugin.flutter.zsdk;

import android.annotation.SuppressLint;
import android.content.Context;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** ZsdkPlugin */
public class ZsdkPlugin implements FlutterPlugin, MethodCallHandler {

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    init(
        flutterPluginBinding.getApplicationContext(),
        flutterPluginBinding.getBinaryMessenger()
    );
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    if(channel != null) channel.setMethodCallHandler(null);
  }

  // This static method is only to remain compatible with apps that don’t use the v2 Android embedding.
  @Deprecated()
  @SuppressLint("Registrar")
  public static void registerWith(Registrar registrar)
  {
    new ZsdkPlugin().init(
        registrar.context(),
        registrar.messenger()
    );
  }

  /** Channel */
  static final String _METHOD_CHANNEL = "zsdk";

  /** Methods */
  static final String _PRINT_PDF_FILE_OVER_BLUETOOTH = "printPdfFileOverBluetooth";
  static final String _PRINT_IMAGE_OVER_BLUETOOTH = "printImageOverBluetooth";
  static final String _PRINT_PDF_DATA_OVER_BLUETOOTH = "printPdfDataOverBluetooth";
  static final String _PRINT_ZPL_FILE_OVER_BLUETOOTH = "printZplFileOverBluetooth";
  static final String _PRINT_ZPL_DATA_OVER_BLUETOOTH = "printZplDataOverBluetooth";
  static final String _CHECK_PRINTER_STATUS_OVER_BLUETOOTH = "checkPrinterStatusOverBluetooth";
  static final String _GET_PRINTER_SETTINGS_OVER_BLUETOOTH = "getPrinterSettingsOverBluetooth";
  static final String _SET_PRINTER_SETTINGS_OVER_BLUETOOTH = "setPrinterSettingsOverBluetooth";
  static final String _DO_MANUAL_CALIBRATION_OVER_BLUETOOTH = "doManualCalibrationOverBluetooth";
  static final String _PRINT_CONFIGURATION_LABEL_OVER_BLUETOOTH = "printConfigurationLabelOverBluetooth";

  /** Properties */
  static final String _filePath = "filePath";
  static final String _data = "data";
  static final String _address = "address";
  static final String _base64 = "base64";
  static final String _cmWidth = "cmWidth";
  static final String _cmHeight = "cmHeight";
  static final String _orientation = "orientation";
  static final String _dpi = "dpi";


  private MethodChannel channel;
  private Context context;

  public ZsdkPlugin() {
  }

  private void init(Context context, BinaryMessenger messenger)
  {
    this.context = context;
    channel = new MethodChannel(messenger, _METHOD_CHANNEL);
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    try
    {
      ZPrinter printer = new ZPrinter(
          context,
          channel,
          result,
          new PrinterConf(
              cmWidth:7,
              cmHeight:4,
              dpi:200
          )
      );
      switch(call.method){
        case _DO_MANUAL_CALIBRATION_OVER_BLUETOOTH:
          printer.doManualCalibrationOverBluetooth(
              call.argument(_address)
          );
          break;
        case _PRINT_CONFIGURATION_LABEL_OVER_BLUETOOTH:
          printer.printConfigurationLabelOverBluetooth(
              call.argument(_address)
          );
          break;
        case _CHECK_PRINTER_STATUS_OVER_BLUETOOTH:
          printer.checkPrinterStatusOverBluetooth(
              call.argument(_address)
          );
          break;
        case _GET_PRINTER_SETTINGS_OVER_BLUETOOTH:
          printer.getPrinterSettingsOverBluetooth(
              call.argument(_address)
          );
          break;
        case _SET_PRINTER_SETTINGS_OVER_BLUETOOTH:
          printer.setPrinterSettingsOverBluetooth(
              call.argument(_address),
              new PrinterSettings(call.arguments())
          );
          break;
        case _PRINT_PDF_FILE_OVER_BLUETOOTH:
          printer.printPdfOverBluetooth(
              call.argument(_filePath),
              call.argument(_address)
          );
        case _PRINT_IMAGE_OVER_BLUETOOTH:
        printer.printImageOverBluetooth(
            call.argument(_base64),
            call.argument(_address)
        );
        break;
        case _PRINT_ZPL_FILE_OVER_BLUETOOTH:
          printer.printZplFileOverBluetooth(
              call.argument(_filePath),
              call.argument(_address)
          );
          break;
        case _PRINT_ZPL_DATA_OVER_BLUETOOTH:
          printer.printZplDataOverBluetooth(
              call.argument(_data),
              call.argument(_address)
          );
          break;
        case _PRINT_PDF_DATA_OVER_BLUETOOTH:
        default:
          result.notImplemented();
      }
    }
    catch(Exception e)
    {
      e.printStackTrace();
      result.error(ErrorCode.EXCEPTION.name(), e.getMessage(), null);
    }
  }
}
