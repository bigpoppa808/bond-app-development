import 'package:flutter/material.dart';
import 'package:fresh_bond_app/core/design/components/bond_avatar.dart';
import 'package:fresh_bond_app/core/design/components/bond_card.dart';
import 'package:fresh_bond_app/core/design/theme/bond_colors.dart';
import 'package:fresh_bond_app/core/design/theme/bond_spacing.dart';
import 'package:fresh_bond_app/core/design/theme/bond_typography.dart';

/// Messages screen
class MessagesScreen extends StatefulWidget {
  /// Constructor
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final List<Map<String, dynamic>> _conversations = [
    {
      'name': 'Alex Johnson',
      'avatar': 'https://i.pravatar.cc/150?img=1',
      'lastMessage': 'Hey, how are you doing?',
      'time': '2m ago',
      'unread': 2,
      'online': true,
    },
    {
      'name': 'Sarah Williams',
      'avatar': 'https://i.pravatar.cc/150?img=2',
      'lastMessage': 'I just sent you the files you requested',
      'time': '1h ago',
      'unread': 0,
      'online': true,
    },
    {
      'name': 'Michael Brown',
      'avatar': 'https://i.pravatar.cc/150?img=3',
      'lastMessage': 'Are we still meeting tomorrow?',
      'time': '3h ago',
      'unread': 1,
      'online': false,
    },
    {
      'name': 'Emily Davis',
      'avatar': 'https://i.pravatar.cc/150?img=4',
      'lastMessage': 'Thanks for your help!',
      'time': '1d ago',
      'unread': 0,
      'online': false,
    },
    {
      'name': 'David Wilson',
      'avatar': 'https://i.pravatar.cc/150?img=5',
      'lastMessage': 'Let me know when you\'re free to chat',
      'time': '2d ago',
      'unread': 0,
      'online': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BondColors.background,
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: BondColors.backgroundSecondary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
            tooltip: 'Search',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
            tooltip: 'Filter',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _conversations.length,
                itemBuilder: (context, index) {
                  final conversation = _conversations[index];
                  return _buildConversationItem(conversation);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: BondColors.primary,
        child: const Icon(Icons.add_comment, color: Colors.white),
      ),
    );
  }

  Widget _buildConversationItem(Map<String, dynamic> conversation) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: BondSpacing.md,
          vertical: BondSpacing.sm,
        ),
        child: Row(
          children: [
            Stack(
              children: [
                BondAvatar(
                  size: BondAvatarSize.md,
                  imageUrl: conversation['avatar'],
                  status: conversation['online']
                      ? BondAvatarStatus.online
                      : BondAvatarStatus.offline,
                ),
              ],
            ),
            const SizedBox(width: BondSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        conversation['name'],
                        style: BondTypography.subtitle1,
                      ),
                      Text(
                        conversation['time'],
                        style: BondTypography.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: BondSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          conversation['lastMessage'],
                          style: conversation['unread'] > 0
                              ? BondTypography.body2.copyWith(
                                  fontWeight: FontWeight.bold,
                                )
                              : BondTypography.body2.copyWith(
                                  color: BondColors.textSecondary,
                                ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (conversation['unread'] > 0)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: BondColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            conversation['unread'].toString(),
                            style: BondTypography.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
