// import 'dart:convert';

// import 'package:metadata_fetch/metadata_fetch.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import './models.dart';

class BookmarkRepository {
  // TODO: Fake data, will be deteled.
  static const List<Map<String, dynamic>> bookmarksJson = [
    {
      'title': 'JetBrains launches cross-platform UI framework for Kotlin',
      'url':
          'https://www.infoworld.com/article/3643392/jetbrains-launches-cross-platform-ui-framework-for-kotlin.html',
      'image':
          'https://images.techhive.com/images/article/2015/09/smartphones-tablet-mobile-devices-100614073-large.jpg',
    },
    // {
    //   'title': 'Flutter 2.5 was released. Here are the highlights in brief!',
    //   'url':
    //       'https://itnext.io/flutter-2-5-was-released-here-are-the-highlights-in-brief-edd244215086',
    //   'image': 'https://miro.medium.com/max/1400/1*i8u8WsdRYoag3Is2REmxuw.jpeg',
    // },
    {
      'title': 'What’s new in Flutter 2.5',
      'url': 'https://blog.logrocket.com/whats-new-in-flutter-2-5/',
      'image': 'https://blog.logrocket.com/wp-content/uploads/2021/09/whats-new-in-flutter-2-5.png',
    },
    // {
    //   'title': 'Roadmap to learn Flutter like a pro!',
    //   'url':
    //       'https://medium.com/google-developer-experts/roadmap-to-learn-flutter-like-a-pro-594f5c38e74a',
    //   'image': 'https://miro.medium.com/max/1400/1*VOReqkrlKvWTpx5QDR9RWQ.png',
    // },
    {
      'title': 'Roadmap to learn Flutter Efficiently ',
      'url': 'https://dev.to/aasharwahla/roadmap-to-learn-flutter-efficiently-27l9',
      'image':
          'https://res.cloudinary.com/practicaldev/image/fetch/s--ybleNxwj--/c_imagga_scale,f_auto,fl_progressive,h_420,q_auto,w_1000/https://dev-to-uploads.s3.amazonaws.com/uploads/articles/8kjqkgblnvwzq20ghqmi.png',
    },
    // {
    //   'title': 'Announcing General Availability for the Google Mobile Ads SDK for Flutter',
    //   'url':
    //       'https://medium.com/flutter/announcing-general-availability-for-the-google-mobile-ads-sdk-for-flutter-574e51ea6783',
    //   'image': 'https://miro.medium.com/max/1400/0*zOegrJCYTuapgWgf',
    // },
    {
      'title': 'Flutter devs get more monetization options with Google Mobile Ads SDK ',
      'url':
          'https://siliconangle.com/2021/11/16/flutter-devs-get-monetization-options-google-mobile-ads-sdk/',
      'image':
          'https://d15shllkswkct0.cloudfront.net/wp-content/blogs.dir/1/files/2021/11/flutter_update_key_graphic_v3_B.png',
    },
    // {
    //   'title': 'About web, community, and code samples — Q3 2021 survey results',
    //   'url':
    //       'https://medium.com/flutter/about-web-community-and-code-samples-q3-2021-survey-results-b67f5b997dca',
    //   'image': 'https://miro.medium.com/max/700/0*_GNHkk5TLOI7wQYc',
    // },
    // {
    //   'title': 'Learn Flutter for free with Flutter Apprentice!',
    //   'url':
    //       'https://medium.com/flutter/learn-flutter-for-free-with-flutter-apprentice-32ced5f97a12',
    //   'image': 'https://miro.medium.com/max/854/1*AvOHYfnMrCR81c4GltakzQ.png',
    // },
    {
      'title': 'Learn Flutter for free with Flutter Apprentice! ',
      'url':
          'https://developers.googleblog.com/2021/10/learn-flutter-for-free-with-flutter-apprentice.html',
      'image':
          'https://1.bp.blogspot.com/-_AeVQcJ-PXQ/YWiEuEA9VBI/AAAAAAAALBs/kOiAXuZwGHIpLT4rlg62_ipE077p-d1qACLcBGAsYHQ/s0/new%2Bflutter%2Bimage.png',
    },
    // {
    //   'title': 'Flutter in Action: Building a Flutter app from scratch',
    //   'url': 'https://medium.com/flutter/supernova-a-design-system-platform-ea00a9077c4d',
    // }
    {
      'title': 'Simplify Flutter state management with Riverpod',
      'url': 'https://blog.codemagic.io/flutter-state-management-with-riverpod/',
      'image': 'https://blog.codemagic.io/uploads/covers/codemagic-blog-header-flutter-1.png',
    }
  ];

  // TODO:
  // static Future<List<Metadata>> loadAndSaveBookmarks() async {
  //   final futureMetadata =
  //       _bookmarksJson.map((bookmark) => MetadataFetch.extract(bookmark['url'])).toList();
  //   final bookmarks = await Future.wait(futureMetadata);

  //   final prefs = await SharedPreferences.getInstance();
  //   final bookmarksJson = bookmarks.map((bookmark) => jsonEncode(bookmark!.toMap())).toList();
  //   await prefs.setStringList('bookmarks', bookmarksJson);

  //   if (bookmarks.isEmpty) {
  //     return [];
  //   }
  //   return futureMetadata;
  // }

  // TODO:
  // Delete bookmarks from shared preferences.
  // static Future<void> deleteBookmarks() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.remove('bookmarks');
  // }
}
