// import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';

import './common/constants.dart';
import './common/theme.dart';
import './pages/home/home_page.dart';
import './pages/create_note/create_note_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notion Capture',
      theme: themeData,
      initialRoute: Routes.root,
      routes: {
        Routes.root: (context) => const HomePage(),
        Routes.createNote: (context) => const CreateNotePage(),
      },
      // home: FutureBuilder<void>(
      //   future: _Init.instance.initialize(),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.done) {
      //       return const HomePage();
      //     } else {
      //       return const _SplashScreen();
      //     }
      //   },
      // ),
    );
  }
}

// class _SplashScreen extends StatelessWidget {
//   const _SplashScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     final height = MediaQuery.of(context).size.height;

//     return Scaffold(
//       body: Column(
//         mainAxisSize: MainAxisSize.max,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(height: 48, width: 48, child: Image.asset('assets/logo.png')),
//           const Align(alignment: Alignment.bottomCenter, child: const Text('Notion Capture')),
//         ],
//       ),
//     );
//   }
// }

// class _Init {
//   _Init._();
//   static final instance = _Init._();

//   Future initialize() async {
//     await Future.delayed(const Duration(seconds: 25));

//     // TODO: Fetch notes!
//   }
// }
