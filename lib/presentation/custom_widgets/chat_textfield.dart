// chat_textfield.dart
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // For file uploads
import 'package:flutter/material.dart';
import 'package:goods/data/global/theme/theme_data.dart';

class ChatTextfield extends StatefulWidget {
  final String clientId;
  const ChatTextfield({super.key, required this.clientId});

  @override
  _ChatTextfieldState createState() => _ChatTextfieldState();
}

class _ChatTextfieldState extends State<ChatTextfield> {
  final TextEditingController messageController = TextEditingController();
  String? _selectedFilePath;

  @override
  void initState() {
    super.initState();
    messageController.addListener(() {
      setState(() {}); // Update the UI as text changes.
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  // 🟢 Pick an image file
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      setState(() {
        _selectedFilePath = result.files.single.path;
      });
      print("File selected: $_selectedFilePath");
    }
  }

  // 🛑 Remove the selected file (preview)
  void _removeFile() {
    setState(() {
      _selectedFilePath = null;
    });
  }

  // 📤 Send text or image message with optimistic update
  Future<void> sendMessage() async {
    print("Start sendMessage");
    // If no text and no file, return.
    if (messageController.text.isEmpty && _selectedFilePath == null) return;

    final senderId = supplierId;
    final timestamp = FieldValue.serverTimestamp();
    print("Text: ${messageController.text}");

    // Send text message if provided.
    if (messageController.text.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.clientId)
          .collection('messages')
          .add({
        'sender': senderId,
        'text': messageController.text,
        'timestamp': timestamp,
      });
    }

    // If a file is selected, handle the image upload.
    if (_selectedFilePath != null) {
      // Save the file path to a local variable.
      String localFilePath = _selectedFilePath!;
      // Immediately clear the preview from the UI.
      setState(() {
        _selectedFilePath = null;
      });

      print("Uploading file");
      // Optimistically add a message document with the local file path and an uploading flag.
      DocumentReference messageRef = await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.clientId)
          .collection('messages')
          .add({
        'sender': senderId,
        'file': localFilePath, // Initially store the local file path.
        'uploading': true,
        'timestamp': timestamp,
      });

      // Start uploading the file.
      File file = File(localFilePath);
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageReference = FirebaseStorage.instance
          .ref('chat_images')
          .child(widget.clientId)
          .child(fileName);
      UploadTask uploadTask = storageReference.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask;
      // Get the download URL once the upload is complete.
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      print("File uploaded. Download URL: $downloadUrl");

      // Update the same message document with the download URL and remove the uploading flag.
      await messageRef.update({
        'file': downloadUrl,
        'uploading': false,
      });
    }

    // Clear the text field.
    messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 2, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 Display the selected file preview (if any)
          if (_selectedFilePath != null)
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(File(_selectedFilePath!)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: _removeFile,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black54,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),

          Row(
            children: [
              Expanded(
                child: Container(
                  constraints:
                      const BoxConstraints(minHeight: 40, maxHeight: 150),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.grey[100],
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 2),
                      IconButton(
                        style: ButtonStyle(
                          side: WidgetStateProperty.all(
                              const BorderSide(width: 0.5)),
                        ),
                        icon: const Icon(Icons.attach_file),
                        onPressed: _pickFile,
                      ),
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          decoration: const InputDecoration(
                            hintText: 'رسالة',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                          ),
                          maxLines: 5,
                          minLines: 1,
                          keyboardType: TextInputType.multiline,
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.all(Radius.circular(50)),
                ),
                child: IconButton(
                  iconSize: 36,
                  icon: const Icon(Icons.send),
                  color: (messageController.text.isEmpty &&
                          _selectedFilePath == null)
                      ? Colors.grey
                      : Colors.red,
                  onPressed: sendMessage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
