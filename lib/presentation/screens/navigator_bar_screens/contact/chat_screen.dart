import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/get_client_data/get_client_data_cubit.dart';
import 'package:goods/business_logic/cubits/get_client_data/get_client_data_state.dart';
import 'package:goods/business_logic/cubits/get_supplier_data/get_supplier_data_cubit.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/data/models/chat_message.dart';
import 'package:goods/presentation/custom_widgets/chat_textfield.dart';
import 'package:goods/presentation/custom_widgets/custom_app_bar%20copy.dart';

import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

class EnhancedChatScreen extends StatefulWidget {
  const EnhancedChatScreen({super.key});

  @override
  _EnhancedChatScreenState createState() => _EnhancedChatScreenState();
}

class _EnhancedChatScreenState extends State<EnhancedChatScreen>
    with TickerProviderStateMixin {
  int _limit = 20;
  final ScrollController _scrollController = ScrollController();
  final Set<String> _selectedMessages = {};
  bool _isSelectionMode = false;
  ChatMessage? _replyToMessage;
  String _searchQuery = '';
  bool _isSearchMode = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
    _setupAnimations();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50) {
        _loadMoreMessages();
      }
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  Future<void> _loadMoreMessages() async {
    setState(() {
      _limit += 20;
    });
    await Future.delayed(const Duration(milliseconds: 300));
  }

  void _toggleMessageSelection(String messageId) {
    setState(() {
      if (_selectedMessages.contains(messageId)) {
        _selectedMessages.remove(messageId);
        if (_selectedMessages.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedMessages.add(messageId);
        _isSelectionMode = true;
      }
    });
  }

  void _deleteSelectedMessages() async {
    final batch = FirebaseFirestore.instance.batch();
    for (String messageId in _selectedMessages) {
      final docRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('messages')
          .doc(messageId);
      batch.delete(docRef);
    }
    await batch.commit();
    setState(() {
      _selectedMessages.clear();
      _isSelectionMode = false;
    });
  }

  void _copySelectedMessages() {
    // جمع النصوص المحددة ونسخها
    final messages = _selectedMessages.join('\n');
    Clipboard.setData(ClipboardData(text: messages));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ الرسائل')),
    );
    setState(() {
      _selectedMessages.clear();
      _isSelectionMode = false;
    });
  }

  void _setReplyMessage(ChatMessage message) {
    setState(() {
      _replyToMessage = message;
    });
  }

  void _clearReply() {
    setState(() {
      _replyToMessage = null;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? supplier =
        context.read<GetSupplierDataCubit>().supplier;
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    String clientId = arguments['clientId'];
    Map<String, dynamic> clientData = arguments['clientData'];

    return Scaffold(
      appBar: _buildAppBar(supplier, clientData),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: BlocBuilder<GetClientDataCubit, GetClientDataState>(
          builder: (context, state) {
            if (state is GetClientDataLoading) {
              return const ChatMessagesSkeleton();
            } else if (state is GetClientDataError) {
              return _buildErrorWidget(
                  message: state.message, clientId: clientId);
            } else if (state is GetClientDataSuccess) {
              return _buildChatContent();
            }
            return const Center(child: Text('خطأ غير معروف'));
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      Map<String, dynamic>? supplier, Map<String, dynamic>? clientData) {
    if (_isSelectionMode) {
      return AppBar(
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            setState(() {
              _selectedMessages.clear();
              _isSelectionMode = false;
            });
          },
        ),
        title: Text(
          '${_selectedMessages.length} محدد',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.white),
            onPressed: _copySelectedMessages,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _deleteSelectedMessages,
          ),
        ],
      );
    }
    return customAppBar(
      context,
      Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.fitHeight,
                image: NetworkImage(clientData!['imageUrl']),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            clientData['businessName'] ?? 'العميل',
            style: const TextStyle(color: whiteColor),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(
      {required String message, required String clientId}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('خطأ: $message'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<GetClientDataCubit>().getClientData(clientId);
            },
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildChatContent() {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    String clientId = arguments['clientId'];
    // Mark all messages as read (reset unreadCount) when opening the chat
    Future.microtask(() async {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(clientId)
          .set({'unreadCount': 0}, SetOptions(merge: true));
    });
    return Column(
      children: [
        if (_isSearchMode) _buildSearchBar(),
        if (_replyToMessage != null) _buildReplyPreview(),
        Expanded(child: _buildMessagesList()),
        EnhancedChatTextfield(
          chatId: clientId,
          replyToMessage: _replyToMessage,
          onClearReply: _clearReply,
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey[100],
      child: TextField(
        decoration: InputDecoration(
          hintText: 'البحث في الرسائل...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _isSearchMode = false;
                _searchQuery = '';
              });
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الرد على:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  _replyToMessage?.text ?? '[مرفق]',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: _clearReply,
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    final arguments = ModalRoute.of(context)!.settings.arguments as Map;
    String clientId = arguments['clientId'];
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(clientId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(_limit)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ChatMessagesSkeleton();
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        final messages = snapshot.data!.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .where((message) {
          if (_searchQuery.isEmpty) return true;
          return message.text
                  ?.toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ??
              false;
        }).toList();

        // Mark messages as read if not sent by current user and not already read
        Future.microtask(() async {
          for (final doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['sender'] != currentUserId && data['status'] != 'read') {
              await doc.reference.update({'status': 'read'});
            }
          }
        });

        return FadeTransition(
          opacity: _fadeAnimation,
          child: ListView.builder(
            controller: _scrollController,
            reverse: true,
            padding: const EdgeInsets.only(bottom: 8, top: 10),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return _buildMessageItem(messages[index], index, messages);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'بادر بالتحدث إلينا',
            style: TextStyle(
              fontSize: 24,
              color: Colors.grey[600],
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اكتب رسالتك الأولى لبدء المحادثة',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(
      ChatMessage message, int index, List<ChatMessage> messages) {
    final bool isMe =
        message.senderId == FirebaseAuth.instance.currentUser?.uid;
    final bool isSelected = _selectedMessages.contains(message.id);

    // تحديد إذا كان يجب إظهار تاريخ جديد
    bool showDateHeader = false;
    if (index == messages.length - 1) {
      showDateHeader = true;
    } else {
      final currentDate = DateFormat('yyyy-MM-dd').format(message.timestamp);
      final previousDate =
          DateFormat('yyyy-MM-dd').format(messages[index + 1].timestamp);
      showDateHeader = currentDate != previousDate;
    }

    return Column(
      children: [
        if (showDateHeader) _buildDateHeader(message.timestamp),
        GestureDetector(
          onLongPress: () => _toggleMessageSelection(message.id),
          onTap: _isSelectionMode
              ? () => _toggleMessageSelection(message.id)
              : null,
          child: Container(
            color: isSelected ? Colors.red.withOpacity(0.1) : null,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: _buildMessageBubble(message, isMe),
          ),
        ),
      ],
    );
  }

  Widget _buildDateHeader(DateTime date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            DateFormat.yMMMMd('ar').format(date),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () => _showMessageOptions(message),
        child: Container(
          margin: EdgeInsets.only(
            left: isMe ? 50 : 0,
            right: isMe ? 0 : 50,
            bottom: 8,
          ),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (message.replyToId != null) _buildReplyIndicator(message),
              _buildMessageContent(message, isMe),
              const SizedBox(height: 4),
              _buildMessageFooter(message, isMe),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReplyIndicator(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'رد على رسالة',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildMessageContent(ChatMessage message, bool isMe) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isMe
              ? [const Color(0xFFFF5722), const Color(0xFFD32F2F)]
              : [Colors.white, Colors.grey[50]!],
        ),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isMe ? 18 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.type == MessageType.image && message.fileUrl != null)
            _buildImageMessage(message),
          if (message.text != null && message.text!.trim().isNotEmpty)
            Text(
              message.text!,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 16,
                height: 1.3,
              ),
            ),
          if (message.isEdited)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'تم التعديل',
                style: TextStyle(
                  fontSize: 11,
                  color: isMe ? Colors.white70 : Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          message.fileUrl!,
          width: 200,
          height: 200,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.error),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMessageFooter(ChatMessage message, bool isMe) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          DateFormat('hh:mm a').format(message.timestamp),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 11,
          ),
        ),
        if (isMe) ...[
          const SizedBox(width: 4),
          _buildMessageStatusIcon(message.status),
        ],
      ],
    );
  }

  Widget _buildMessageStatusIcon(MessageStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case MessageStatus.sending:
        icon = Icons.access_time;
        color = Colors.grey;
        break;
      case MessageStatus.sent:
        icon = Icons.check;
        color = Colors.grey;
        break;
      case MessageStatus.delivered:
        icon = Icons.done_all;
        color = Colors.grey;
        break;
      case MessageStatus.read:
        icon = Icons.done_all;
        color = Colors.blue;
        break;
      case MessageStatus.failed:
        icon = Icons.error;
        color = Colors.red;
        break;
    }

    return Icon(icon, size: 14, color: color);
  }

  void _showMessageOptions(ChatMessage message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('رد'),
              onTap: () {
                Navigator.pop(context);
                _setReplyMessage(message);
              },
            ),
            if (message.text != null)
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('نسخ'),
                onTap: () {
                  Navigator.pop(context);
                  Clipboard.setData(ClipboardData(text: message.text!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم نسخ النص')),
                  );
                },
              ),
            if (message.senderId == FirebaseAuth.instance.currentUser?.uid)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('حذف', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _deleteMessage(message.id);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.clear_all),
              title: const Text('مسح المحادثة'),
              onTap: () {
                Navigator.pop(context);
                _clearChat();
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('حظر'),
              onTap: () {
                Navigator.pop(context);
                // تنفيذ منطق الحظر
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteMessage(String messageId) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  Future<void> _clearChat() async {
    final batch = FirebaseFirestore.instance.batch();
    final messages = await FirebaseFirestore.instance
        .collection('chats')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection('messages')
        .get();

    for (var doc in messages.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}

// نفس الـ Skeleton من الكود الأصلي مع تحسينات بسيطة
class ChatMessagesSkeleton extends StatelessWidget {
  const ChatMessagesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: 8,
        itemBuilder: (context, index) {
          final bool isMe = index % 2 == 0;
          final bool hasImage = index % 3 == 0;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.only(
                  left: isMe ? 50 : 0,
                  right: isMe ? 0 : 50,
                ),
                child: Column(
                  crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (hasImage)
                      Container(
                        width: 200,
                        height: 150,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.red[100] : Colors.grey[200],
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(isMe ? 18 : 4),
                          bottomRight: Radius.circular(isMe ? 4 : 18),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            height: 16,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 60,
                            height: 12,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
