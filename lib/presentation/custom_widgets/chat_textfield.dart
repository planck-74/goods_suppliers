import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:goods/data/models/chat_message.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class EnhancedChatTextfield extends StatefulWidget {
  final String chatId;
  final ChatMessage? replyToMessage;
  final VoidCallback? onClearReply;
  final String? supplierId; // إضافة معرف المورد

  const EnhancedChatTextfield({
    super.key,
    required this.chatId,
    this.replyToMessage,
    this.onClearReply,
    this.supplierId,
  });

  @override
  _EnhancedChatTextfieldState createState() => _EnhancedChatTextfieldState();
}

class _EnhancedChatTextfieldState extends State<EnhancedChatTextfield>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final FocusNode _focusNode = FocusNode();
  // حالة الملفات والوسائط
  final List<AttachmentFile> _attachments = [];
  bool _isSending = false;

  // الرسوم المتحركة
  late AnimationController _sendButtonController;
  late AnimationController _attachmentController;
  late Animation<double> _sendButtonAnimation;
  late Animation<double> _attachmentAnimation;

  // حالة الكتابة
  bool _isTyping = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _setupControllers();
    _setupAnimations();
    _setupMessageListener();
  }

  void _setupControllers() {
    _messageController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  void _setupAnimations() {
    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _attachmentController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _sendButtonAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _sendButtonController, curve: Curves.elasticOut),
    );
    _attachmentAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _attachmentController, curve: Curves.easeInOut),
    );
  }

  void _setupMessageListener() {
    _messageController.addListener(() {
      final hasText = _messageController.text.trim().isNotEmpty;
      final hasAttachments = _attachments.isNotEmpty;

      if (hasText || hasAttachments) {
        if (!_sendButtonController.isAnimating) {
          _sendButtonController.forward();
        }
      } else {
        if (!_sendButtonController.isAnimating) {
          _sendButtonController.reverse();
        }
      }
    });
  }

  void _onTextChanged() {
    final text = _messageController.text;
    if (text.isNotEmpty && !_isTyping) {
      setState(() => _isTyping = true);
      _sendTypingIndicator();
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isTyping = false);
      }
    });
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _attachmentController.forward();
    } else {
      _attachmentController.reverse();
    }
  }

  Future<void> _sendTypingIndicator() async {
    // إرسال مؤشر الكتابة للطرف الآخر
    // يمكن تنفيذ هذا عبر Firestore أو أي آلية أخرى
  }

  // اختيار الصور مع إمكانية الاختيار المتعدد
  Future<void> _pickImages() async {
    try {
      final List<XFile> files = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (files.isNotEmpty) {
        setState(() {
          for (var file in files) {
            _attachments.add(AttachmentFile(
              path: file.path,
              type: AttachmentType.image,
              name: file.name,
            ));
          }
        });
      }
    } catch (e) {
      _showErrorMessage('خطأ في اختيار الصور: $e');
    }
  }

  // اختيار الملفات
  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xlsx', 'pptx'],
      );

      if (result != null) {
        setState(() {
          for (var file in result.files) {
            if (file.path != null) {
              _attachments.add(AttachmentFile(
                path: file.path!,
                type: AttachmentType.file,
                name: file.name,
                size: file.size,
              ));
            }
          }
        });
      }
    } catch (e) {
      _showErrorMessage('خطأ في اختيار الملفات: $e');
    }
  }

  // التقاط صورة من الكاميرا
  Future<void> _captureImage() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (file != null) {
        setState(() {
          _attachments.add(AttachmentFile(
            path: file.path,
            type: AttachmentType.image,
            name: file.name,
          ));
        });
      }
    } catch (e) {
      _showErrorMessage('خطأ في التقاط الصورة: $e');
    }
  }

  // إزالة مرفق
  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  // إرسال الرسالة المحسن
  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty && _attachments.isEmpty) return;
    if (_isSending) return;

    setState(() => _isSending = true);

    try {
      final senderId = FirebaseAuth.instance.currentUser?.uid;
      if (senderId == null) return;

      final timestamp = FieldValue.serverTimestamp();
      final chatDocRef =
          FirebaseFirestore.instance.collection('chats').doc(widget.chatId);

      // إرسال النص إذا كان موجوداً
      if (_messageController.text.trim().isNotEmpty) {
        await _sendTextMessage(chatDocRef, senderId, timestamp);
      }

      // إرسال المرفقات
      for (var attachment in _attachments) {
        await _sendAttachment(chatDocRef, senderId, timestamp, attachment);
      }

      // تنظيف الحقول
      _clearInputs();
    } catch (e) {
      _showErrorMessage('خطأ في إرسال الرسالة: $e');
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _sendTextMessage(DocumentReference chatDocRef, String senderId,
      FieldValue timestamp) async {
    final messageData = {
      'sender': senderId,
      'recipientId': widget.chatId, // إضافة معرف المستلم
      'text': _messageController.text.trim(),
      'timestamp': timestamp,
      'type': 'text',
      'status': 'sent',
      if (widget.replyToMessage != null) 'replyToId': widget.replyToMessage!.id,
    };

    await chatDocRef.collection('messages').add(messageData);

    // تحديث آخر رسالة في المحادثة
    await _updateLastMessage(
        chatDocRef, _messageController.text.trim(), timestamp);
  }

  Future<void> _sendAttachment(DocumentReference chatDocRef, String senderId,
      FieldValue timestamp, AttachmentFile attachment) async {
    // إنشاء رسالة مؤقتة للمرفق
    final tempMessageRef = await chatDocRef.collection('messages').add({
      'sender': senderId,
      'recipientId': widget.chatId, // إضافة معرف المستلم
      'fileName': attachment.name,
      'fileSize': attachment.size,
      'timestamp': timestamp,
      'type': attachment.type.name,
      'status': 'sending',
      'uploading': true,
      if (widget.replyToMessage != null) 'replyToId': widget.replyToMessage!.id,
    });

    try {
      // رفع الملف
      final downloadUrl = await _uploadFile(attachment, senderId);

      // تحديث الرسالة بالرابط النهائي
      await tempMessageRef.update({
        'file': downloadUrl,
        'uploading': false,
        'status': 'sent',
      });

      String lastMessageText;
      switch (attachment.type) {
        case AttachmentType.image:
          lastMessageText = '📷 صورة';
          break;
        case AttachmentType.file:
          lastMessageText = '📄 ${attachment.name}';
          break;
        case AttachmentType.voice:
          lastMessageText = '🎤 رسالة صوتية';
          break;
      }

      await _updateLastMessage(chatDocRef, lastMessageText, timestamp);
    } catch (e) {
      // تحديث حالة الرسالة إلى فشل
      await tempMessageRef.update({
        'status': 'failed',
        'uploading': false,
      });
      rethrow;
    }
  }

  Future<String> _uploadFile(AttachmentFile attachment, String senderId) async {
    final file = File(attachment.path);
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${attachment.name}';

    String folderPath;
    switch (attachment.type) {
      case AttachmentType.image:
        folderPath = 'chat_images';
        break;
      case AttachmentType.file:
        folderPath = 'chat_files';
        break;
      case AttachmentType.voice:
        folderPath = 'chat_voice';
        break;
    }

    final storageRef =
        FirebaseStorage.instance.ref('$folderPath/$senderId/$fileName');

    final uploadTask = storageRef.putFile(file);

    // مراقبة تقدم الرفع (يمكن إضافة مؤشر التقدم هنا)
    uploadTask.snapshotEvents.listen((snapshot) {
      final progress = snapshot.bytesTransferred / snapshot.totalBytes;
      // يمكن تحديث واجهة المستخدم بتقدم الرفع
      print('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
    });

    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _updateLastMessage(DocumentReference chatDocRef, String message,
      FieldValue timestamp) async {
    await chatDocRef.set({
      'clientId': FirebaseAuth.instance.currentUser?.uid,
      'supplierId': widget.supplierId,
      'lastMessage': message,
      'lastMessageTime': timestamp,
      'updatedAt': timestamp,
    }, SetOptions(merge: true));
  }

  void _clearInputs() {
    _messageController.clear();
    setState(() {
      _attachments.clear();
    });
    widget.onClearReply?.call();
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'إرفاق ملف',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Icons.photo_library,
                  label: 'معرض الصور',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImages();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.camera_alt,
                  label: 'الكاميرا',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    _captureImage();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.attach_file,
                  label: 'ملفات',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    _pickFiles();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Column(
          children: [
            if (_attachments.isNotEmpty) _buildAttachmentPreview(),
            _buildInputRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentPreview() {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _attachments.length,
        itemBuilder: (context, index) {
          final attachment = _attachments[index];
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 8),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                  ),
                  child: attachment.type == AttachmentType.image
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(attachment.path),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.blue[50],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                attachment.type == AttachmentType.file
                                    ? Icons.description
                                    : Icons.mic,
                                color: Colors.blue,
                                size: 30,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                attachment.name.length > 8
                                    ? '${attachment.name.substring(0, 8)}...'
                                    : attachment.name,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _removeAttachment(index),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputRow() {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _attachmentAnimation,
          builder: (context, child) => Transform.scale(
            scale: 0.7 + (_attachmentAnimation.value * 0.3),
            child: IconButton(
              icon: const Icon(Icons.attach_file, color: Colors.grey),
              onPressed: _showAttachmentOptions,
            ),
          ),
        ),
        Expanded(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 120),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.grey[100],
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              controller: _messageController,
              focusNode: _focusNode,
              decoration: const InputDecoration(
                hintText: 'اكتب رسالة...',
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: 6,
              minLines: 1,
              textInputAction: TextInputAction.newline,
            ),
          ),
        ),
        const SizedBox(width: 8),
        AnimatedBuilder(
          animation: _sendButtonAnimation,
          builder: (context, child) => Transform.scale(
            scale: _sendButtonAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isSending
                      ? [Colors.grey, Colors.grey[400]!]
                      : [const Color(0xFFFF5722), const Color(0xFFD32F2F)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (_isSending ? Colors.grey : Colors.red)
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                iconSize: 24,
                icon: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white),
                onPressed: _isSending ? null : _sendMessage,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _focusNode.dispose();
    _sendButtonController.dispose();
    _attachmentController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }
}

// نموذج المرفقات
class AttachmentFile {
  final String path;
  final AttachmentType type;
  final String name;
  final int? size;

  AttachmentFile({
    required this.path,
    required this.type,
    required this.name,
    this.size,
  });
}

enum AttachmentType { image, file, voice }
