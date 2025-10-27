import 'package:flutter/material.dart';

// --- Models for Mock Data ---
class ChatItem {
  final String id;
  final String name;
  final String lastMessage;
  final String timeAgo; // Or use DateTime
  final String avatarUrl;
  final int unreadCount;
  final bool isOnline;

  ChatItem({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.timeAgo,
    required this.avatarUrl,
    this.unreadCount = 0,
    this.isOnline = false,
  });
}

class TeacherItem {
  final String id;
  final String name;
  final String subject;
  final String avatarUrl;
  final bool isOnline;

  TeacherItem({
    required this.id,
    required this.name,
    required this.subject,
    required this.avatarUrl,
    this.isOnline = false,
  });
}

// --- Main Screen Widget ---
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with SingleTickerProviderStateMixin { // Needed for TabController
  late TabController _tabController;

  // --- Colors ---
  static const Color primaryGreen = Color(0xFF5DB075);
  static const Color primaryText = Color(0xFF333333);
  static const Color secondaryText = Color(0xFF666666);
  static const Color iconGrey = Color(0xFFAAAAAA);
  static const Color dividerColor = Color(0xFFEEEEEE);
  static const Color studentCardBg = Color(0xFFFDECDA); // Orange background for student card
  static const Color onlineIndicator = Colors.green; // Green dot for online status

  // --- Mock Data ---
  final List<ChatItem> _chats = [
    ChatItem(
      id: 'chat1',
      name: 'أستاذة سميرة',
      lastMessage: 'ممتاز يا ندى',
      timeAgo: '2 د',
      avatarUrl: 'https://placehold.co/60x60/FBBC05/FFFFFF?text=س', // Yellowish
      unreadCount: 1,
      isOnline: true,
    ),
     ChatItem(
      id: 'chat2',
      name: 'أستاذة فرح',
      lastMessage: 'هذا صحيح يا ندى',
      timeAgo: '5 د',
      avatarUrl: 'https://placehold.co/60x60/FBBC05/FFFFFF?text=ف', // Yellowish
      unreadCount: 2,
    ),
     ChatItem(
      id: 'chat3',
      name: 'أستاذة اسماء',
      lastMessage: 'نعم هناك امتحان غدا',
      timeAgo: '1 س',
      avatarUrl: 'https://placehold.co/60x60/FBBC05/FFFFFF?text=ا', // Yellowish
    ),
     // Add more chats...
  ];

   final List<TeacherItem> _teachers = [
     TeacherItem(
       id: 't1',
       name: 'أستاذة سميرة',
       subject: 'معلمة رياضيات',
       avatarUrl: 'https://placehold.co/60x60/FBBC05/FFFFFF?text=س', // Yellowish
       isOnline: true,
     ),
      TeacherItem(
       id: 't2',
       name: 'أستاذة فرح',
       subject: 'معلمة علوم',
       avatarUrl: 'https://placehold.co/60x60/FBBC05/FFFFFF?text=ف', // Yellowish
     ),
      TeacherItem(
       id: 't3',
       name: 'أستاذة اسماء',
       subject: 'معلمة لغة عربية',
       avatarUrl: 'https://placehold.co/60x60/FBBC05/FFFFFF?text=ا', // Yellowish
     ),
       TeacherItem(
       id: 't4',
       name: 'أستاذة خديجة',
       subject: 'معلمة لغة انجليزية',
       avatarUrl: 'https://placehold.co/60x60/FBBC05/FFFFFF?text=خ', // Yellowish
     ),
      // Add more teachers...
   ];


  @override
  void initState() {
    super.initState();
    // Initialize TabController with 2 tabs
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // --- Shadowless AppBar ---
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        forceMaterialTransparency: true,
        // --- End Shadowless AppBar ---
        centerTitle: true,
        automaticallyImplyLeading: false, // disables the back button
        title: const Text(
          'الرسائل',
          style: TextStyle(
            color: primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        // --- TabBar ---
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryGreen, // Color of the selected tab text
          unselectedLabelColor: secondaryText, // Color of unselected tab text
          indicatorColor: primaryGreen, // Color of the underline indicator
          indicatorWeight: 3.0,
          labelStyle: const TextStyle(
             fontFamily: 'Tajawal',
             fontWeight: FontWeight.bold,
             fontSize: 16
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Tajawal',
             fontWeight: FontWeight.normal,
             fontSize: 16
          ),
          tabs: const [
            Tab(text: 'الرسائل'),
            Tab(text: 'معلمين الصف'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // --- Content for "الرسائل" Tab ---
          _MyMessagesTab(chats: _chats),

          // --- Content for "معلمين الصف" Tab ---
          _ClassTeachersTab(teachers: _teachers),
        ],
      ),
    );
  }
}

// --- Widget for "My Messages" Tab Content ---
class _MyMessagesTab extends StatelessWidget {
  final List<ChatItem> chats;
  const _MyMessagesTab({required this.chats});

   // --- Colors ---
  static const Color primaryGreen = Color(0xFF5DB075);
  static const Color primaryText = Color(0xFF333333);
  static const Color secondaryText = Color(0xFF666666);
  static const Color onlineIndicator = Colors.green; // Green dot for online status


  @override
  Widget build(BuildContext context) {
     if (chats.isEmpty) {
        return const Center(child: Text('لا توجد رسائل حالياً'));
      }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return _ChatListItem(chat: chat);
      },
      separatorBuilder: (context, index) => const Divider(
        height: 24,
        color: _MessagesScreenState.dividerColor,
        indent: 70, // Indent to align after avatar
      ),
    );
  }
}

// --- Widget for "Class Teachers" Tab Content ---
class _ClassTeachersTab extends StatelessWidget {
  final List<TeacherItem> teachers;
  const _ClassTeachersTab({required this.teachers});

  // --- Colors ---
  static const Color primaryGreen = Color(0xFF5DB075);
  static const Color primaryText = Color(0xFF333333);
  static const Color secondaryText = Color(0xFF666666);
  static const Color onlineIndicator = Colors.green; // Green dot for online status


  @override
  Widget build(BuildContext context) {
     if (teachers.isEmpty) {
        return const Center(child: Text('لا يوجد معلمين متاحين حالياً'));
      }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      itemCount: teachers.length,
      itemBuilder: (context, index) {
        final teacher = teachers[index];
        return _TeacherListItem(teacher: teacher);
      },
       separatorBuilder: (context, index) => const Divider(
        height: 24,
        color: _MessagesScreenState.dividerColor,
        indent: 70, // Indent to align after avatar
      ),
    );
  }
}


// --- List Item Widgets ---

class _ChatListItem extends StatelessWidget {
  final ChatItem chat;
  const _ChatListItem({required this.chat});

  @override
  Widget build(BuildContext context) {
    return InkWell( // Make it tappable
      onTap: () {
        // TODO: Navigate to the actual chat screen with this chat.id
        print('Tapped on chat with ${chat.name}');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            // Avatar with Online Indicator
            Stack(
               clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(chat.avatarUrl),
                   backgroundColor: Colors.grey[200],
                ),
                 if (chat.isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0, // In RTL, right is visually bottom-left
                      child: Container(
                        height: 14,
                        width: 14,
                        decoration: BoxDecoration(
                          color: _MyMessagesTab.onlineIndicator,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
              ],
            ),
            const SizedBox(width: 12),
            // Name and Last Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _MyMessagesTab.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat.lastMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: chat.unreadCount > 0 ? _MyMessagesTab.primaryText : _MyMessagesTab.secondaryText,
                       fontWeight: chat.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Time and Unread Count
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                 Text(
                   chat.timeAgo,
                   style: const TextStyle(
                     fontSize: 12,
                     color: _MyMessagesTab.secondaryText,
                   ),
                 ),
                 const SizedBox(height: 8),
                 if (chat.unreadCount > 0)
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                     decoration: BoxDecoration(
                       color: _MyMessagesTab.primaryGreen,
                       borderRadius: BorderRadius.circular(10),
                     ),
                     child: Text(
                       chat.unreadCount.toString(),
                       style: const TextStyle(
                         color: Colors.white,
                         fontSize: 12,
                         fontWeight: FontWeight.bold,
                       ),
                     ),
                   )
                 else
                   const SizedBox(height: 18), // Placeholder for alignment
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class _TeacherListItem extends StatelessWidget {
  final TeacherItem teacher;
  const _TeacherListItem({required this.teacher});

  @override
  Widget build(BuildContext context) {
    return InkWell( // Make it tappable
       onTap: () {
        // TODO: Navigate to chat screen with this teacher.id (creating new if needed)
        print('Tapped on teacher ${teacher.name}');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            // Avatar with Online Indicator
            Stack(
               clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(teacher.avatarUrl),
                   backgroundColor: Colors.grey[200],
                ),
                 if (teacher.isOnline)
                    Positioned(
                       bottom: 0,
                      right: 0, // In RTL, right is visually bottom-left
                      child: Container(
                        height: 14,
                        width: 14,
                        decoration: BoxDecoration(
                          color: _ClassTeachersTab.onlineIndicator,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
              ],
            ),
            const SizedBox(width: 12),
            // Name and Subject
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    teacher.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _ClassTeachersTab.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    teacher.subject,
                    style: const TextStyle(
                      fontSize: 14,
                      color: _ClassTeachersTab.secondaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Chat Icon Button
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: _MessagesScreenState.primaryGreen),
              onPressed: () {
                 // TODO: Navigate to chat screen with this teacher.id
                 print('Start chat with ${teacher.name}');
              },
            ),
          ],
        ),
      ),
    );
  }
}