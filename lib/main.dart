import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sunmi_printer_plus/enums.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'package:sunmi_printer_plus/sunmi_style.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sunmi Printer',
      theme: ThemeData(useMaterial3: true),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool printBinded = false;
  int paperSize = 0;
  String serialNumber = "";
  String printerVersion = "";

  int counter = 0;

  @override
  void initState() {
    super.initState();

    _bindingPrinter().then((bool? isBind) async {
      SunmiPrinter.paperSize().then((int size) {
        setState(() {
          paperSize = size;
        });
      });

      SunmiPrinter.printerVersion().then((String version) {
        setState(() {
          printerVersion = version;
        });
      });

      SunmiPrinter.serialNumber().then((String serial) {
        setState(() {
          serialNumber = serial;
        });
      });

      setState(() {
        printBinded = isBind!;
      });
    });
  }

  /// must binding ur printer at first init in app
  Future<bool?> _bindingPrinter() async {
    final bool? result = await SunmiPrinter.bindingPrinter();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sunmi printer Example'),
      ),
      body: Center(
        child: Column(
          children: [
            FloatingActionButton.extended(
              label: Text("NEXT: ${counter + 1}"),
              onPressed: () async {
                //! print image
                Future<Uint8List> readFileBytes(String path) async {
                  ByteData fileData = await rootBundle.load(path);
                  Uint8List fileUnit8List = fileData.buffer.asUint8List(
                      fileData.offsetInBytes, fileData.lengthInBytes);
                  return fileUnit8List;
                }

                Future<Uint8List> _getImageFromAsset(String iconPath) async {
                  return await readFileBytes(iconPath);
                }

                await SunmiPrinter.initPrinter();

                Uint8List byte = await _getImageFromAsset(
                    'assets/images/sticker_white.jpeg');
                await SunmiPrinter.setAlignment(SunmiPrintAlign.CENTER);

                await SunmiPrinter.startTransactionPrint(true);
                await SunmiPrinter.printImage(byte);
                await SunmiPrinter.lineWrap(2);
                await SunmiPrinter.exitTransactionPrint(true);

                // ! print text
                setState(() {
                  counter++;
                });

                await SunmiPrinter.initPrinter();
                await SunmiPrinter.startTransactionPrint(true);
                await SunmiPrinter.setCustomFontSize(50);
                await SunmiPrinter.printText('整理券番号 $counter 番',
                    style: SunmiStyle(
                      align: SunmiPrintAlign.CENTER,
                      bold: true,
                      fontSize: SunmiFontSize.XL,
                    ));
                await SunmiPrinter.resetFontSize();
                await SunmiPrinter.lineWrap(2);
                await SunmiPrinter.exitTransactionPrint(true);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // counter --
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FloatingActionButton.extended(
                    label: Text("counter --"),
                    onPressed: () async {
                      setState(() {
                        counter--;
                      });
                    },
                  ),
                ),
                // counter ++
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FloatingActionButton.extended(
                    label: Text("counter ++"),
                    onPressed: () async {
                      setState(() {
                        counter++;
                      });
                    },
                  ),
                ),
                // counter reset
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FloatingActionButton.extended(
                    label: Text("counter reset"),
                    onPressed: () async {
                      setState(() {
                        counter = 0;
                      });
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
