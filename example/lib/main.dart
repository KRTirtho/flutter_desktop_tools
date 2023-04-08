import 'package:flutter/material.dart';
import 'package:flutter_desktop_tools/flutter_desktop_tools.dart';

void main() async {
  await DesktopTools.ensureInitialized(
    DesktopWindowOptions(
      title: "Flutter Desktop Tools",
      hideTitleBar: true,
    ),
  );

  final systemTray = await DesktopTools.createSystemTrayMenu(
    title: "Flutter Desktop Tools",
    iconPath: "assets/app_icon.png",
    windowsIconPath: "assets/app_icon.ico",
    items: [
      MenuItemLabel(
        label: "Item 1",
        name: "item1",
        image: "assets/app_icon.png",
      ),
      MenuItemLabel(label: "Item 2"),
    ],
    onEvent: (event, tray) async {
      switch (event) {
        case SystemTrayEvent.click:
          DesktopTools.platform.isWindows
              ? await DesktopTools.window.show()
              : await tray.popUpContextMenu();
          break;
        case SystemTrayEvent.rightClick:
          !DesktopTools.platform.isWindows
              ? await DesktopTools.window.show()
              : await tray.popUpContextMenu();

          break;
        default:
      }
    },
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Desktop Tools',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Flutter Desktop Tools'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
