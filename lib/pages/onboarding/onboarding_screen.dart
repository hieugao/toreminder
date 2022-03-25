import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/constants.dart';
import 'view_models.dart';

// Ref: https://www.youtube.com/watch?v=8eRQyE2PN7w
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  static const String prefsKey = 'onBoarding';

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final int _numPages = 3;
  int _current = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF151515),
    ));

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xff151515), Color(0xff030303)],
            ),
          ),
          child: Consumer(builder: (context, ref, child) {
            return Stack(children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(
                    height: height * 0.8,
                    child: PageView(
                      physics: const ClampingScrollPhysics(),
                      controller: _pageController,
                      onPageChanged: (int page) => setState(() => _current = page),
                      children: const [
                        // TODO: Create a data model for these pages.
                        _OnboardingPage(
                          asset: 'assets/onboarding1.png',
                          title: 'Oh, Hi there!\nWelcome to Toreminder.',
                          description:
                              'One quick question, have you ever forgotten something important'
                              ' at the end of the day? If the answer is yes, then congrats,'
                              ' you came to the right place.',
                        ),
                        _OnboardingPage(
                            asset: 'assets/onboarding2.png',
                            title: 'To-do Management',
                            description:
                                'With the help of Reminders, it\'s impossible to forget your'
                                ' important todo when the day pass.\n\n'
                                'Your todo list is also neatly organized based on sections'
                                ' (date, project, etc) too.'),
                        _OnboardingPage(
                            asset: 'assets/onboarding3.png',
                            title: 'A ton of more helpers',
                            description:
                                'It also support a wide range of features to help you manage your todo list easier, like:\n\n'
                                ' • Recurring Due Dates\n'
                                ' • Priority Levels\n'
                                ' • Labels\n'
                                ' • Etc'),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _BottomButton(
                      onPressed: () {
                        if (_current < _numPages - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        } else {
                          ref.read(onBoardingProvider.notifier).setOnBoardingComplete();
                          Navigator.of(context).pushReplacementNamed(Routes.home);
                        }
                      },
                      isNext: _current != _numPages - 1,
                      current: _current,
                      length: _numPages,
                    ),
                  )
                ],
              ),
              Positioned(
                top: 16,
                right: 24,
                child: _SkipButton(onPressed: () {
                  ref.read(onBoardingProvider.notifier).setOnBoardingComplete();
                  Navigator.of(context).pushReplacementNamed(Routes.home);
                }),
              ),
            ]);
          }),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    Key? key,
    required this.asset,
    required this.title,
    this.description,
  }) : super(key: key);

  final String asset;
  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: height * 0.5,
            child: Image(
              image: AssetImage(asset),
            ),
          ),
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .headline6!
                .copyWith(fontWeight: FontWeight.bold, fontFamily: 'Bree'),
          ),
          // description != null ? const SizedBox(height: 8) : const SizedBox(),
          description != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    description!,
                    style: Theme.of(context).textTheme.subtitle2!.copyWith(
                          color: Theme.of(context).textTheme.subtitle2!.color!.withOpacity(0.8),
                          fontSize: 13,
                        ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  const _BottomButton({
    Key? key,
    required this.onPressed,
    required this.isNext,
    required this.current,
    required this.length,
  }) : super(key: key);

  final VoidCallback onPressed;
  final bool isNext;
  final int current;
  final int length;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return isNext
        ? Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PageIndicators(current: current, length: length),
              TextButton(
                onPressed: onPressed,
                style: TextButton.styleFrom(
                  // backgroundColor: isNext ? Colors.white : Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Next',
                        style: Theme.of(context).textTheme.button!.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            )),
                    // const SizedBox(width: 8),
                    // Icon(Icons.arrow_forward, size: 20, color: Theme.of(context).primaryColor),
                  ],
                ),
              ),
            ],
          )
        : ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              // backgroundColor: isNext ? Colors.white : Colors.transparent,
              minimumSize: Size.fromHeight(56),
              // padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Get Started',
              style: Theme.of(context).textTheme.headline6!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Bree',
                  ),
            ),
          );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({Key? key, required this.onPressed}) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: Theme.of(context).colorScheme.secondary,
        // tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: const Size(0, 0),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Text(
        'Skip',
        style: Theme.of(context).textTheme.caption!.copyWith(
              color: Colors.white,
            ),
      ),
    );
  }
}

class _PageIndicators extends StatelessWidget {
  const _PageIndicators({
    Key? key,
    required this.current,
    required this.length,
  }) : super(key: key);

  final int current;
  final int length;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < length; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            height: i == current ? 8 : 6,
            width: i == current ? 8 : 6,
            decoration: BoxDecoration(
              color: i == current ? Colors.white : Colors.grey,
              borderRadius: const BorderRadius.all(Radius.circular(2)),
            ),
          ),
      ],
    );
  }
}
