import 'package:riverpod/riverpod.dart';

import '../repositories/notion_repo.dart';

final notionRepositoryProvider = Provider<NotionRepository>((ref) => NotionRepository());
