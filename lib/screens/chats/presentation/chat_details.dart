import 'dart:io'; // For File type
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'package:file_picker/file_picker.dart'; // Import file_picker
import 'package:intl/intl.dart'; // Import intl
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/screens/documents/presentation/documents.dart'; // For UserStatus and potentially TeacherModel/StudentModel later
// import 'package:ramla_school/core/models/users/teacher_model.dart'; // Import if needed for recipient info

// Simple model for a chat message
class ChatMessage {
  final String id;
  final String text;
  final DateTime timestamp;
  final bool isSentByMe; // To determine sender/receiver bubble style
  final String? imageUrl; // Optional image in message
  final String?
  videoUrl; // Optional video in message (needs video player integration)
  final String? filePath; // Optional file path for non-image files

  ChatMessage({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isSentByMe,
    this.imageUrl,
    this.videoUrl,
    this.filePath,
  });
}

class ChatDetailsScreen extends StatefulWidget {
  // Pass recipient details (e.g., TeacherModel or ChatItem) here
  // For now, using simple placeholders
  final String recipientName;
  final String recipientAvatarUrl;
  final bool recipientIsOnline;

  const ChatDetailsScreen({
    super.key,
    required this.recipientName,
    required this.recipientAvatarUrl,
    required this.recipientIsOnline,
  });

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker(); // Initialize ImagePicker

  @override
  void initState() {
    super.initState();
    // Scroll to bottom when the chat first opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  // --- Mock Messages ---
  final List<ChatMessage> _messages = [
    ChatMessage(
      id: '1',
      text: 'السلام عليكم يا أستاذة',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      isSentByMe: true,
    ),
    ChatMessage(
      id: '2',
      text: 'وعليكم السلام يا ندى، كيف حالك؟',
      timestamp: DateTime.now().subtract(const Duration(minutes: 9)),
      isSentByMe: false,
    ),
    ChatMessage(
      id: '3',
      text: 'بخير الحمد لله. كان لدي سؤال بخصوص واجب الرياضيات',
      timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
      isSentByMe: true,
    ),
    ChatMessage(
      id: '4',
      text: 'تفضلي بالسؤال',
      timestamp: DateTime.now().subtract(const Duration(minutes: 7)),
      isSentByMe: false,
    ),
    ChatMessage(
      id: '5',
      text: 'هل هذا الحل صحيح؟',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      isSentByMe: true,
      imageUrl: 'https://i.ibb.co/0V9dQbBL/news.png',
    ), // Example image
    ChatMessage(
      id: '6',
      text: 'نعم، الحل صحيح وممتاز!',
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      isSentByMe: false,
    ),
    // Example video message placeholder (requires video player implementation)
    // ChatMessage(id: '7', text: 'شاهدي هذا الشرح', timestamp: DateTime.now().subtract(const Duration(minutes: 1)), isSentByMe: false, videoUrl: 'placeholder_video_url'),
    ChatMessage(
      id: '8',
      text: 'هذا ملف الواجب',
      timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      isSentByMe: true,
      filePath: '/path/to/dummy/file.pdf',
    ), // Example file
  ];

  // --- Colors ---
  static const Color primaryGreen = Color(0xFF5DB075);
  static const Color primaryText = Color(0xFF333333);
  static const Color secondaryText = Color(0xFF666666);
  static const Color myMessageBg = primaryGreen;
  static const Color otherMessageBg = Color(0xFFF0F0F0);
  static const Color inputBg = Color(0xFFF9F9F9);
  static const Color onlineIndicator = Colors.green;
  static Color dividerColor = Colors.grey.shade200; // Define dividerColor

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- Send Text Message ---
  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      _addMessageToList(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          timestamp: DateTime.now(),
          isSentByMe: true,
        ),
      );
      _messageController.clear();
      // TODO: Add logic to actually send the TEXT message via backend (Firebase)
    }
  }

  // --- Send File Message (Image or Other) ---
  void _sendFileMessage(String filePath, {String? imageUrl}) {
    String fileName = filePath.split('/').last; // Get file name from path
    _addMessageToList(
      ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: imageUrl == null
            ? 'مرفق: $fileName'
            : '', // Show filename or empty if image
        timestamp: DateTime.now(),
        isSentByMe: true,
        imageUrl: imageUrl, // Will be null for non-image files
        filePath: imageUrl == null
            ? filePath
            : null, // Store path for non-images
      ),
    );
    // TODO: Add logic to UPLOAD the file (filePath) to Firebase Storage
    // TODO: Get the download URL after upload
    // TODO: Send the download URL (and potentially file type/name) via backend (Firestore)
  }

  // --- Helper to add message and scroll ---
  void _addMessageToList(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    // Scroll to bottom after adding
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // --- Image Picking Logic ---
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Optional: Adjust quality
        maxWidth: 1000, // Optional: Resize image
      );
      if (pickedFile != null) {
        print('Image picked: ${pickedFile.path}');
        // For now, add a placeholder message with the local path (for display)
        // In real app, upload first, then add message with download URL
        _sendFileMessage(
          pickedFile.path,
          imageUrl: pickedFile.path,
        ); // Use local path as temp URL
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء اختيار الصورة: $e')),
      );
    }
  }

  // --- File Picking Logic ---
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        // type: FileType.custom, // Allow specific types if needed
        // allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        String filePath = result.files.single.path!;
        print('File picked: $filePath');
        // For now, add a placeholder message with the local path
        // In real app, upload first, then add message with download URL/file info
        _sendFileMessage(filePath);
      } else {
        // User canceled the picker
        print('File picking cancelled.');
      }
    } catch (e) {
      print('Error picking file: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('حدث خطأ أثناء اختيار الملف: $e')));
    }
  }

  // --- Show Attachment Options ---
  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: primaryGreen,
                ),
                title: const Text(
                  'المعرض',
                  style: TextStyle(fontFamily: 'Tajawal'),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: primaryGreen,
                ),
                title: const Text(
                  'الكاميرا',
                  style: TextStyle(fontFamily: 'Tajawal'),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.insert_drive_file_outlined,
                  color: primaryGreen,
                ),
                title: const Text(
                  'مستند',
                  style: TextStyle(fontFamily: 'Tajawal'),
                ),
                onTap: () {
                  Navigator.pop(context); // Close the bottom sheet
                  _pickFile();
                },
              ),
            ],
          ),
        );
      },
    );
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryGreen),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0, // Remove default title spacing
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(widget.recipientAvatarUrl),
              backgroundColor: Colors.grey[200],
              onBackgroundImageError: (exception, stackTrace) {
                print('Error loading recipient avatar: $exception');
              },
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.recipientName,
                  style: const TextStyle(
                    color: primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.recipientIsOnline ? 'نشطة الآن' : 'غير نشطة',
                  style: TextStyle(
                    color: widget.recipientIsOnline
                        ? onlineIndicator
                        : secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. Chat Messages Area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              // Scroll to bottom initially if needed (add after frame callback in initState)
              // itemExtent: null, // Let items size themselves
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final bool isMyMessage = message.isSentByMe;
                // Add padding for separation, especially for consecutive messages from same sender
                bool showPadding = true;
                if (index > 0 &&
                    _messages[index - 1].isSentByMe == message.isSentByMe) {
                  showPadding =
                      false; // Less padding if previous message is from same sender
                }
                return Padding(
                  padding: EdgeInsets.only(top: showPadding ? 8.0 : 2.0),
                  child: _MessageBubble(
                    message: message,
                    isMyMessage: isMyMessage,
                  ),
                );
              },
            ),
          ),
          // 2. Message Input Area
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: dividerColor)),
        boxShadow: [
          // Subtle shadow for input area
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        // Prevent input field from going under system UI (like home bar)
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end, // Align items to bottom
          children: [
            // --- MODIFIED: Attach Button opens bottom sheet ---
            IconButton(
              icon: const Icon(
                Icons.attach_file_outlined,
                color: secondaryText,
                size: 24,
              ), // Use attach icon
              onPressed: _showAttachmentOptions, // Call the bottom sheet method
            ),
            // --- END MODIFICATION ---

            // Message Text Field
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4.0,
                ), // Inner padding for alignment
                constraints: const BoxConstraints(
                  maxHeight: 100,
                ), // Limit text field height
                decoration: BoxDecoration(
                  color: inputBg,
                  borderRadius: BorderRadius.circular(24.0), // Rounded corners
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: null, // Allows multiline input that grows
                  textInputAction:
                      TextInputAction.newline, // Use newline for multiline
                  // onSubmitted: (_) => _sendMessage(), // Remove submit on enter for multiline
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: 'اكتب رسالة...',
                    border: InputBorder.none, // Remove underline
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ), // Adjust padding
                    isDense: true,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Send Button
            IconButton(
              style: IconButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(12),
              ),
              icon: const Icon(Icons.send_outlined, size: 20),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

// --- Message Bubble Widget ---
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMyMessage;

  const _MessageBubble({required this.message, required this.isMyMessage});

  @override
  Widget build(BuildContext context) {
    final alignment = isMyMessage
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final color = isMyMessage
        ? _ChatDetailsScreenState.myMessageBg
        : _ChatDetailsScreenState.otherMessageBg;
    final textColor = isMyMessage
        ? Colors.white
        : _ChatDetailsScreenState.primaryText;
    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomRight: isMyMessage
          ? const Radius.circular(20)
          : const Radius.circular(0),
      bottomLeft: isMyMessage
          ? const Radius.circular(0)
          : const Radius.circular(20),
    );

    return Container(
      // margin: const EdgeInsets.symmetric(vertical: 4.0), // Margin handled by ListView padding
      alignment: isMyMessage
          ? Alignment.centerLeft
          : Alignment.centerRight, // Align bubble left/right
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ), // Max width for bubble
            padding: EdgeInsets.symmetric(
              horizontal:
                  message.imageUrl != null ||
                      message.videoUrl != null ||
                      message.filePath != null
                  ? 8.0
                  : 16.0, // Less padding for media
              vertical:
                  message.imageUrl != null ||
                      message.videoUrl != null ||
                      message.filePath != null
                  ? 8.0
                  : 10.0,
            ),
            decoration: BoxDecoration(color: color, borderRadius: borderRadius),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize:
                  MainAxisSize.min, // Important for Column inside bubble
              children: [
                // Display Image if available
                if (message.imageUrl != null)
                  Padding(
                    padding: message.text.isNotEmpty
                        ? const EdgeInsets.only(bottom: 8.0)
                        : EdgeInsets.zero,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      // --- MODIFICATION: Handle local file paths for images ---
                      child:
                          message.imageUrl!.startsWith(
                            '/',
                          ) // Check if it's a local path
                          ? Image.file(
                              File(message.imageUrl!),
                              fit: BoxFit.cover,
                              // Add loading/error builders if needed for local files too
                            )
                          : Image.network(
                              // Assume network URL otherwise
                              message.imageUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) =>
                                  progress == null
                                  ? child
                                  : const Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                              errorBuilder: (context, error, stack) =>
                                  const Icon(
                                    Icons.broken_image,
                                    color: Colors.white70,
                                    size: 40,
                                  ),
                            ),
                      // --- END MODIFICATION ---
                    ),
                  ),

                // Display Video Placeholder if available (requires player integration)
                if (message.videoUrl != null)
                  Padding(
                    padding: message.text.isNotEmpty
                        ? const EdgeInsets.only(bottom: 8.0)
                        : EdgeInsets.zero,
                    child: Container(
                      height: 150, // Example height
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.play_circle_fill,
                        color: Colors.white.withOpacity(0.8),
                        size: 40,
                      ),
                    ),
                  ),

                // Display File Placeholder if available
                if (message.filePath != null)
                  Padding(
                    padding: message.text.isNotEmpty
                        ? const EdgeInsets.only(bottom: 8.0)
                        : EdgeInsets.zero,
                    child: InkWell(
                      // Make it tappable to open file
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfViewerPage(
                              url: message.filePath!,
                              title: message.text,
                            ),
                          ),
                        );
                        print("Attempting to open file: ${message.filePath}");
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isMyMessage
                              ? Colors.white.withOpacity(0.2)
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.insert_drive_file_outlined,
                              color: textColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              // Prevent overflow if filename is long
                              child: Text(
                                message.filePath!
                                    .split('/')
                                    .last, // Show file name
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Display Text if not empty
                if (message.text.isNotEmpty)
                  Padding(
                    // Add slight vertical padding if there's also media/file
                    padding: EdgeInsets.symmetric(
                      vertical:
                          (message.imageUrl != null ||
                              message.videoUrl != null ||
                              message.filePath != null)
                          ? 4.0
                          : 0,
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Display Timestamp below bubble
          Padding(
            padding: EdgeInsets.only(
              top: 4.0,
              left: isMyMessage ? 0 : 8.0, // Adjust padding based on sender
              right: isMyMessage ? 8.0 : 0,
            ),
            child: Text(
              DateFormat(
                'h:mm a',
                'ar',
              ).format(message.timestamp), // Format time e.g., ٩:٣٠ ص
              style: const TextStyle(
                color: _ChatDetailsScreenState.secondaryText,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
