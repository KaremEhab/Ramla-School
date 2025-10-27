import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// --- Add imports for your models ---
// Assuming these paths are correct relative to your project structure
import 'package:ramla_school/core/models/users/teacher_model.dart';
import 'package:ramla_school/core/models/lesson_model.dart'; // Import REAL LessonModel
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/screens/chats/presentation/chat_details.dart'; // For UserStatus, Gender, Grade, SchoolSubject enums

// --- Models for Mock Data (ChatItem remains the same) ---
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

// TeacherItem is no longer needed as we use TeacherModel

// --- Main Screen Widget ---
class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with SingleTickerProviderStateMixin {
  // Needed for TabController
  late TabController _tabController;

  // --- Colors ---
  static const Color primaryGreen = Color(0xFF5DB075);
  static const Color primaryText = Color(0xFF333333);
  static const Color secondaryText = Color(0xFF666666);
  static const Color iconGrey = Color(0xFFAAAAAA);
  static const Color dividerColor = Color(0xFFEEEEEE);
  static const Color studentCardBg = Color(
    0xFFFDECDA,
  ); // Orange background for student card
  static const Color onlineIndicator =
      Colors.green; // Green dot for online status

  // --- Mock Data ---
  final List<ChatItem> _chats = [
    ChatItem(
      id: 'chat1',
      name: 'أستاذة سميرة',
      lastMessage: 'ممتاز يا ندى',
      timeAgo: '2 د',
      avatarUrl:
          'https://www.clipartmax.com/png/middle/144-1448593_avatar-icon-teacher-avatar.png',
      unreadCount: 1,
      isOnline: true,
    ),
    ChatItem(
      id: 'chat2',
      name: 'أستاذة فرح',
      lastMessage: 'هذا صحيح يا ندى',
      timeAgo: '5 د',
      avatarUrl:
          'https://www.clipartmax.com/png/middle/144-1448593_avatar-icon-teacher-avatar.png',
      unreadCount: 2,
    ),
    ChatItem(
      id: 'chat3',
      name: 'أستاذة اسماء',
      lastMessage: 'نعم هناك امتحان غدا',
      timeAgo: '1 س',
      avatarUrl:
          'https://www.clipartmax.com/png/middle/144-1448593_avatar-icon-teacher-avatar.png',
    ),
    // Add more chats...
  ];

  // --- Updated Mock Data using TeacherModel ---
  final List<TeacherModel> _teachers = [
    TeacherModel(
      id: 't1',
      firstName: 'أستاذة',
      lastName: 'سميرة',
      email: 'samira@example.com',
      imageUrl:
          'https://www.clipartmax.com/png/middle/144-1448593_avatar-icon-teacher-avatar.png',
      status: UserStatus.online, // Using enum
      gender: Gender.female, // Using enum
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      // Use your actual LessonModel now
      subjects: [
        LessonModel(
          id: 'math9',
          subject: SchoolSubject.math, // Use enum
          // teacher: null, // Teacher might be recursive here, handle appropriately
          isBreak: false,
          breakTitle: '',
          duration: 45,
          startTime: Timestamp.now(), // Placeholder
          endTime: Timestamp.now(), // Placeholder
        ),
      ],
    ),
    TeacherModel(
      id: 't2',
      firstName: 'أستاذة',
      lastName: 'فرح',
      email: 'farah@example.com',
      imageUrl:
          'https://www.clipartmax.com/png/middle/144-1448593_avatar-icon-teacher-avatar.png',
      status: UserStatus.offline,
      gender: Gender.female,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      subjects: [
        LessonModel(
          id: 'sci9',
          subject: SchoolSubject.science,
          isBreak: false,
          breakTitle: '',
          duration: 45,
          startTime: Timestamp.now(),
          endTime: Timestamp.now(),
        ),
      ],
    ),
    TeacherModel(
      id: 't3',
      firstName: 'أستاذة',
      lastName: 'اسماء',
      email: 'asmaa@example.com',
      imageUrl:
          'https://www.clipartmax.com/png/middle/144-1448593_avatar-icon-teacher-avatar.png',
      status: UserStatus.offline,
      gender: Gender.female,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      subjects: [
        LessonModel(
          id: 'arab9',
          subject: SchoolSubject.arabic,
          isBreak: false,
          breakTitle: '',
          duration: 45,
          startTime: Timestamp.now(),
          endTime: Timestamp.now(),
        ),
      ],
    ),
    TeacherModel(
      id: 't4',
      firstName: 'أستاذة',
      lastName: 'خديجة',
      email: 'khadija@example.com',
      imageUrl:
          'https://www.clipartmax.com/png/middle/144-1448593_avatar-icon-teacher-avatar.png',
      status: UserStatus.offline,
      gender: Gender.female,
      createdAt: DateTime.now().subtract(const Duration(days: 40)),
      subjects: [
        LessonModel(
          id: 'eng9',
          subject: SchoolSubject.english,
          isBreak: false,
          breakTitle: '',
          duration: 45,
          startTime: Timestamp.now(),
          endTime: Timestamp.now(),
        ),
      ],
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
            fontSize: 16,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Tajawal',
            fontWeight: FontWeight.normal,
            fontSize: 16,
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
  static const Color onlineIndicator =
      Colors.green; // Green dot for online status

  @override
  Widget build(BuildContext context) {
    if (chats.isEmpty) {
      return const Center(child: Text('لا توجد رسائل حالياً'));
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
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
  // --- Updated parameter type ---
  final List<TeacherModel> teachers;
  const _ClassTeachersTab({required this.teachers});

  // --- Colors ---
  static const Color primaryGreen = Color(0xFF5DB075);
  static const Color primaryText = Color(0xFF333333);
  static const Color secondaryText = Color(0xFF666666);
  static const Color onlineIndicator =
      Colors.green; // Green dot for online status

  @override
  Widget build(BuildContext context) {
    if (teachers.isEmpty) {
      return const Center(child: Text('لا يوجد معلمين متاحين حالياً'));
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      itemCount: teachers.length,
      itemBuilder: (context, index) {
        final teacher = teachers[index];
        // --- Pass TeacherModel ---
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
    return InkWell(
      // Make it tappable
      onTap: () {
        print('Tapped on chat with ${chat.name}');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailsScreen(
              recipientName: chat.name,
              recipientAvatarUrl: chat.avatarUrl,
              recipientIsOnline: chat.isOnline,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          // spacing: 12, // Removed - use SizedBox
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
            const SizedBox(width: 12), // Added SizedBox
            // Name, Message, Time, Count
            Expanded(
              child: Column(
                // spacing: 4, // Removed - use SizedBox
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          chat.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: _MyMessagesTab.primaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8), // Space before time
                      Text(
                        chat.timeAgo,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _MyMessagesTab.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4), // Added SizedBox
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment:
                        CrossAxisAlignment.end, // Align badge to bottom
                    children: [
                      Flexible(
                        child: Text(
                          chat.lastMessage,
                          style: TextStyle(
                            fontSize: 14,
                            color: chat.unreadCount > 0
                                ? _MyMessagesTab.primaryText
                                : _MyMessagesTab.secondaryText,
                            fontWeight: chat.unreadCount > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8), // Space before badge
                      if (chat.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ), // Adjusted padding
                          decoration: BoxDecoration(
                            color: _MyMessagesTab.primaryGreen,
                            borderRadius: BorderRadius.circular(
                              100,
                            ), // Make it rounder
                          ),
                          child: Text(
                            chat.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12, // Slightly smaller
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      // No need for placeholder SizedBox if unreadCount is 0
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

class _TeacherListItem extends StatelessWidget {
  // --- Updated parameter type ---
  final TeacherModel teacher;
  const _TeacherListItem({required this.teacher});

  @override
  Widget build(BuildContext context) {
    // Determine the subject string using the SchoolSubject enum extension
    String subjectDisplay =
        teacher.subjects.isNotEmpty && teacher.subjects.first.subject != null
        ? 'معلمة ${teacher.subjects.first.subject!.name}' // Access name via extension
        : 'معلمة'; // Fallback if no subjects listed or subject is null

    bool isOnline = teacher.status == UserStatus.online; // Check status enum

    return InkWell(
      // Make it tappable
      onTap: () {
        // TODO: Navigate to chat screen with this teacher.id (creating new if needed)
        print('Tapped on teacher ${teacher.fullName}'); // Use fullName getter
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            // Avatar with Online Indicator
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: NetworkImage(
                    teacher.imageUrl,
                  ), // Use imageUrl
                  backgroundColor: Colors.grey[200],
                  // Basic error handling for image
                  onBackgroundImageError: (exception, stackTrace) {
                    print('Error loading image: $exception');
                  },
                ),
                if (isOnline) // Check derived boolean
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
                    teacher.fullName, // Use fullName getter
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _ClassTeachersTab.primaryText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subjectDisplay, // Use derived subject string
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
              icon: const Icon(
                Icons.chat_bubble_outline,
                color: _MessagesScreenState.primaryGreen,
              ),
              onPressed: () {
                // TODO: Navigate to chat screen with this teacher.id
                print(
                  'Start chat with ${teacher.fullName}',
                ); // Use fullName getter
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Removed placeholder Grade, GradeHelper, and LessonModel definitions
// Assuming they are correctly defined in your 'constants.dart' and 'lesson_model.dart' files
