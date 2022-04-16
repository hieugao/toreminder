import 'package:flutter/material.dart';

import '../../features/sync/providers.dart';

class SyncIndicator extends StatelessWidget {
  const SyncIndicator(
      // this.numberUnsyncedNote,
      {
    required this.status,
    this.compact = false,
    Key? key,
  }) : super(key: key);

  // final int numberUnsyncedNote;
  final SyncStatus status;
  final bool compact;

  // bool get _isSynced =>
  //     status.connectivity == ConnectivityStatus.connected && numberUnsyncedNote == 0;

  @override
  Widget build(BuildContext context) {
    // return compact
    //     ? _buildSyncDot()
    //     : Container(
    //         padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
    //         decoration: BoxDecoration(
    //           borderRadius: BorderRadius.circular(10),
    //           color: Colors.grey[700],
    //         ),
    //         child: Row(
    //           children: [
    //             _buildSyncDot(),
    //             const SizedBox(width: 6),
    //             Text(
    //                 status == SyncStatus.syncing
    //                     ? 'Syncing... ($numberUnsyncedNote)'
    //                     // : _isSynced
    //                     : numberUnsyncedNote == 0
    //                         ? 'Synced'
    //                         : 'Unsynced ($numberUnsyncedNote)',
    //                 style: Theme.of(context).textTheme.caption),
    //           ],
    //         ),
    //       );
    return _buildSyncDot();
  }

  Widget _buildSyncDot() {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        // color: status == SyncStatus.syncing
        //     ? Colors.yellow
        //     // : _isSynced
        //     : numberUnsyncedNote == 0
        //         ? Colors.green
        //         : Colors.red,
        color: _getColor(),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.38),
            blurRadius: 2,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  Color _getColor() {
    switch (status) {
      case SyncStatus.syncing:
        return Colors.yellow;
      case SyncStatus.synced:
        return Colors.green;
      case SyncStatus.unsynced:
        return Colors.red;
      case SyncStatus.offline:
        return Colors.grey;
    }
  }
}
