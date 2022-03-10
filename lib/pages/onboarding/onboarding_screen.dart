import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import './styles.dart';

// Ref: https://www.youtube.com/watch?v=8eRQyE2PN7w
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final int _numPages = 3;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final indicator = _PageIndicators(current: _currentPage, length: _numPages);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF151515),
    ));

    return Scaffold(
      body: // AnnotatedRegion<SystemUiOverlayStyle>(
          // value: SystemUiOverlayStyle.light,
          // child: Container(
          // decoration: const BoxDecoration(
          //   gradient: LinearGradient(
          //     begin: Alignment.topCenter,
          //     end: Alignment.bottomCenter,
          //     stops: [0.1, 0.4, 0.7, 0.9],
          //     colors: [
          //       Color(0xFF3594DD),
          //       Color(0xFF4563DB),
          //       Color(0xFF5036D5),
          //       Color(0xFF5B16D0),
          //     ],
          //   ),
          // ),
          Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            // stops: [0, 0.4, 0.7, 0.9],
            colors: [Color(0xff151515), Color(0xff030303)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Flexible(
              flex: 8,
              child: PageView(
                physics: const ClampingScrollPhysics(),
                controller: _pageController,
                onPageChanged: (int page) => setState(() => _currentPage = page),
                children: <Widget>[
                  // Column(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     const Padding(
                  //       padding: EdgeInsets.all(32),
                  //       child: _Illustration(image: 'assets/onboarding1.png'),
                  //     ),
                  //     _PageIndicators(current: _currentPage, length: _numPages),
                  //     const SizedBox(height: 24),
                  //     const _Description(
                  //       title:
                  //           'Have you ever forgotten or missed something at the end of theto take your medicine?',

                  //       //       'We can help you to track your medicine and remind you when to take it.',
                  //     ),
                  //   ],
                  // ),
                  _OnboardingPage(
                    illustration: _Illustration(image: 'assets/onboarding1.png'),
                    indicator: indicator,
                    description: _Description(
                        title: 'Have you ever forgotten something at the end of the day?'),
                  ),
                  Container(),
                  Container(),
                  // _OnboardingPage(
                  //   illustration: _Illustration(image: 'assets/onboarding1.png'),
                  //   indicator: indicator,
                  //   description: _Description(
                  //     title: 'Have you ever forgotten something at the end of the day?',
                  //     description:
                  //         'We can help you to track your medicine and remind you when to take it.',
                  //   ),
                  // ),
                  // _OnboardingPage(
                  //   illustration: _Illustration(image: 'assets/onboarding1.png'),
                  //   indicator: indicator,
                  //   description: _Description(
                  //     title: 'And with a bunch more of features to help your life be better',
                  //   ),
                  // ),
                  // Padding(
                  //   padding: EdgeInsets.all(40.0),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: <Widget>[
                  //       Center(
                  //         child: Image(
                  //           image: AssetImage(
                  //             'assets/onboarding1.png',
                  //           ),
                  //           height: 300.0,
                  //           width: 300.0,
                  //         ),
                  //       ),
                  //       SizedBox(height: 30.0),
                  //       Text(
                  //         'Live your life smarter\nwith us!',
                  //         style: kTitleStyle,
                  //       ),
                  //       SizedBox(height: 15.0),
                  //       Text(
                  //         'Lorem ipsum dolor sit amet, consect adipiscing elit, sed do eiusmod tempor incididunt ut labore et.',
                  //         style: kSubtitleStyle,
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // Padding(
                  //   padding: EdgeInsets.all(40.0),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: <Widget>[
                  //       Center(
                  //         child: Image(
                  //           image: AssetImage(
                  //             'assets/onboarding1.png',
                  //           ),
                  //           height: 300.0,
                  //           width: 300.0,
                  //         ),
                  //       ),
                  //       SizedBox(height: 30.0),
                  //       Text(
                  //         'Get a new experience\nof imagination',
                  //         style: kTitleStyle,
                  //       ),
                  //       SizedBox(height: 15.0),
                  //       Text(
                  //         'Lorem ipsum dolor sit amet, consect adipiscing elit, sed do eiusmod tempor incididunt ut labore et.',
                  //         style: kSubtitleStyle,
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
            // _PageIndicators(current: _currentPage, length: _numPages),
            // _currentPage != _numPages - 1
            //     ? Expanded(
            //         child: Align(
            //           alignment: FractionalOffset.bottomRight,
            //           child: FlatButton(
            //             onPressed: () {
            //               _pageController.nextPage(
            //                 duration: Duration(milliseconds: 500),
            //                 curve: Curves.ease,
            //               );
            //             },
            //             child: Row(
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               mainAxisSize: MainAxisSize.min,
            //               children: <Widget>[
            //                 Text(
            //                   'Next',
            //                   style: TextStyle(
            //                     color: Colors.white,
            //                     fontSize: 22.0,
            //                   ),
            //                 ),
            //                 SizedBox(width: 10.0),
            //                 Icon(
            //                   Icons.arrow_forward,
            //                   color: Colors.white,
            //                   size: 30.0,
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ),
            //       )
            //     : Text(''),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _Button(
                onPressed: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease,
                  );
                },
                isNext: _currentPage != _numPages - 1,
              ),
            ),
          ],
        ),
      ),
      // bottomSheet: _Button(
      //   onPressed: () {
      //     _pageController.nextPage(
      //       duration: const Duration(milliseconds: 500),
      //       curve: Curves.ease,
      //     );
      //   },
      //   isNext: _currentPage != _numPages - 1,
      // ),
      //)
      // bottomSheet: null,
      // _currentPage == _numPages - 1
      //     ? Container(
      //         height: 100.0,
      //         width: double.infinity,
      //         color: Colors.white,
      //         child: GestureDetector(
      //           onTap: () => print('Get started'),
      //           child: Center(
      //             child: Padding(
      //               padding: EdgeInsets.only(bottom: 30.0),
      //               child: Text(
      //                 'Get started',
      //                 style: TextStyle(
      //                   color: Color(0xFF5B16D0),
      //                   fontSize: 20.0,
      //                   fontWeight: FontWeight.bold,
      //                 ),
      //               ),
      //             ),
      //           ),
      //         ),
      //       )
      //     : Text(''),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    Key? key,
    required this.onPressed,
    required this.isNext,
  }) : super(key: key);

  final VoidCallback onPressed;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        // backgroundColor: isNext ? Colors.white : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: isNext
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Next',
                    style: Theme.of(context).textTheme.button!.copyWith(
                          color: Colors.white,
                        )),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 20, color: Colors.white),
              ],
            )
          : Text(
              'Get Started',
              style: Theme.of(context)
                  .textTheme
                  .button!
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    Key? key,
    required this.illustration,
    required this.indicator,
    required this.description,
  }) : super(key: key);

  final _Illustration illustration;
  final _PageIndicators indicator;
  final _Description description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 6,
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(0),
                child: illustration,
              ),
            ),
          ),
          Flexible(
            flex: 3,
            child: description,
          ),
          Align(alignment: Alignment.center, child: indicator),
        ],
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  const _Illustration({
    Key? key,
    required this.image,
  }) : super(key: key);

  final String image;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: AssetImage(image),
      // height: 300.0,
      // width: 300.0,
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({
    Key? key,
    required this.title,
    this.description,
  }) : super(key: key);

  final String title;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.subtitle1!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        description != null ? const SizedBox(height: 16) : const SizedBox(),
        description != null
            ? Text(
                description!,
                style: Theme.of(context).textTheme.bodyText1,
              )
            : const SizedBox(),
      ],
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
            height: i == current ? 4 : 3,
            width: i == current ? 10 : 6,
            decoration: BoxDecoration(
              color: i == current ? Colors.white : Colors.grey,
              borderRadius: const BorderRadius.all(Radius.circular(4)),
            ),
          ),
      ],
    );
  }
}
