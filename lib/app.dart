import 'package:flutter/material.dart';

import 'package:device_preview/device_preview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_framework/responsive_framework.dart';
// import 'package:lottie/lottie.dart';

import './common/constants.dart' show Routes;
import './common/theme.dart';
import 'pages/create_note/create_note_page.dart';
import 'pages/dashboard/dashboard_screen.dart';
import 'pages/onboarding/onboarding_screen.dart';
import 'pages/onboarding/view_models.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final isOnBoarded = ref.watch(onBoardingProvider);

        return MaterialApp(
          useInheritedMediaQuery: true,
          locale: DevicePreview.locale(context),
          builder: (context, child) {
            return DevicePreview.appBuilder(
              context,
              ResponsiveWrapper.builder(
                ClampingScrollWrapper.builder(context, child!),
                breakpoints: const [
                  ResponsiveBreakpoint.resize(350, name: MOBILE),
                  ResponsiveBreakpoint.autoScale(600, name: TABLET),
                  ResponsiveBreakpoint.resize(840, name: DESKTOP),
                  ResponsiveBreakpoint.autoScale(1600, name: 'XL'),
                ],
              ),
            );
          },
          debugShowCheckedModeBanner: false,
          title: 'Notion Capture',
          theme: themeData,
          initialRoute: isOnBoarded ? Routes.home : Routes.onboarding,
          routes: {
            Routes.home: (context) => const DashboardScreen(),
            Routes.onboarding: (context) => const OnboardingScreen(),
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
      },
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
