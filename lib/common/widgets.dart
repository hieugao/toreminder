// import 'package:flutter/material.dart';

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
