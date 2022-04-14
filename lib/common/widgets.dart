import 'package:flutter/material.dart';

// import '../features/note/models.dart';

// class TagProperty extends StatelessWidget {
//   const TagProperty({
//     Key? key,
//     required this.tag,
//   }) : super(key: key);

//   final NotionTag tag;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(10),
//         color: tag.color.bg!.withOpacity(0.2),
//       ),
//       child: Text(
//         tag.name,
//         style: Theme.of(context).textTheme.bodyText2!.apply(color: tag.color.fg),
//       ),
//     );
//   }
// }

// class TagIcon extends StatelessWidget {
//   const TagIcon({
//     Key? key,
//     required this.tag,
//     this.isSelected = false,
//   }) : super(key: key);

//   final NotionTag tag;
//   final bool isSelected;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(6),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(14),
//         color: isSelected ? tag.color.fg.withOpacity(0.6) : Colors.transparent,
//         border: Border.all(color: tag.color.fg.withOpacity(0.6), width: 2),
//       ),
//       child: Text(
//         tag.emoji ?? '',
//         style: Theme.of(context).textTheme.bodyText2!.apply(color: tag.color.fg),
//       ),
//     );
//   }
// }

class TestPage extends StatelessWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Container(),
      ),
    );
  }
}

class ToreminderToast extends StatelessWidget {
  const ToreminderToast({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
  }) : super(key: key);

  final Icon icon;
  final String title;
  final String? subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: ClipPath(
        child: Container(
          decoration: BoxDecoration(border: Border(left: BorderSide(color: color, width: 6))),
          child: ListTile(
            enabled: false,
            dense: true,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              child: icon,
            ),
            title: Text(
              title,
              style: Theme.of(context).textTheme.bodyText1!.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              subtitle ?? 'Ooops! Internet is disconnected',
              style: Theme.of(context)
                  .textTheme
                  .bodyText2!
                  .copyWith(color: Colors.white.withOpacity(0.6)),
            ),
          ),
        ),
        clipper: ShapeBorderClipper(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
