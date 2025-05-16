import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goods/business_logic/cubits/get_client_data/get_client_data_cubit.dart';
import 'package:goods/business_logic/cubits/get_client_data/get_client_data_state.dart';
import 'package:goods/data/global/theme/theme_data.dart';
import 'package:goods/presentation/custom_widgets/chat_textfield.dart';
import 'package:goods/presentation/custom_widgets/custom_app_bar%20copy.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int _limit = 20;
  final ScrollController _scrollController = ScrollController();

  late String clientId;
  late Map<String, dynamic> clientData;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      clientId = args['clientId'];
      clientData = args['client'];
      _initialized = true;

      context.read<GetClientDataCubit>().getClientData(clientId);
    }
  }

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50) {
        _loadMoreMessages();
      }
    });
  }

  Future<void> _loadMoreMessages() async {
    setState(() {
      _limit += 20;
    });
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
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
                  image: NetworkImage(clientData['imageUrl']),
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
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/images/dreamy.jpg'),
          ),
        ),
        child: BlocBuilder<GetClientDataCubit, GetClientDataState>(
          builder: (context, state) {
            if (state is GetClientDataLoading) {
              return const ChatMessagesSkeleton();
            } else if (state is GetClientDataError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is GetClientDataSuccess) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('chats')
                          .doc(clientId)
                          .collection('messages')
                          .orderBy('timestamp', descending: true)
                          .limit(_limit)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const ChatMessagesSkeleton();
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text(
                              'بادر بالتحدث إلينا.',
                              style: TextStyle(fontSize: 32),
                            ),
                          );
                        }

                        final messages = snapshot.data!.docs;
                        return ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          padding: const EdgeInsets.only(bottom: 80, top: 10),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final messageData =
                                messages[index].data() as Map<String, dynamic>;

                            final Timestamp? timestamp =
                                messageData['timestamp'] as Timestamp?;
                            final DateTime messageTime =
                                timestamp?.toDate() ?? DateTime.now();

                            final String messageDateString =
                                DateFormat('yyyy-MM-dd').format(messageTime);
                            String? previousMessageDate;
                            if (index < messages.length - 1) {
                              final previousMessageData = messages[index + 1]
                                  .data() as Map<String, dynamic>;
                              final Timestamp? previousTimestamp =
                                  previousMessageData['timestamp']
                                      as Timestamp?;
                              final DateTime previousMessageTime =
                                  previousTimestamp?.toDate() ?? DateTime.now();
                              previousMessageDate = DateFormat('yyyy-MM-dd')
                                  .format(previousMessageTime);
                            }
                            final bool showDateHeader =
                                index == messages.length - 1 ||
                                    messageDateString != previousMessageDate;

                            final bool isMe =
                                messageData['sender'] == supplierId;
                            final String timeString =
                                DateFormat('hh:mm a').format(messageTime);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (showDateHeader)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8, horizontal: 16),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          DateFormat.yMMMMd()
                                              .format(messageTime),
                                          style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  child: Align(
                                    alignment: isMe
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Column(
                                      crossAxisAlignment: isMe
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                      children: [
                                        if (messageData.containsKey('file') &&
                                            messageData['file'] != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 4),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: isMe &&
                                                      messageData[
                                                              'uploading'] ==
                                                          true
                                                  ? Image.file(
                                                      File(messageData['file']),
                                                      width: 200,
                                                      height: 200,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Image.network(
                                                      messageData['file'],
                                                      width: 200,
                                                      height: 200,
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                          ),
                                        if (messageData.containsKey('text') &&
                                            (messageData['text'] as String)
                                                .trim()
                                                .isNotEmpty)
                                          Container(
                                            decoration: BoxDecoration(
                                              color: isMe
                                                  ? const Color.fromARGB(
                                                      255, 243, 22, 6)
                                                  : Colors.grey[300],
                                              borderRadius: BorderRadius.only(
                                                topLeft:
                                                    const Radius.circular(12),
                                                topRight:
                                                    const Radius.circular(12),
                                                bottomLeft: Radius.circular(
                                                    isMe ? 12 : 0),
                                                bottomRight: Radius.circular(
                                                    isMe ? 0 : 12),
                                              ),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 10),
                                            child: Text(
                                              messageData['text'],
                                              style: TextStyle(
                                                color: isMe
                                                    ? Colors.white
                                                    : Colors.black,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        const SizedBox(height: 4),
                                        Text(
                                          timeString,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Positioned(
                    right: 0,
                    left: 0,
                    bottom: 0,
                    child: ChatTextfield(clientId: clientId),
                  ),
                ],
              );
            }
            return const Center(child: Text('Unknown state'));
          },
        ),
      ),
    );
  }
}

class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final Color color;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        width: width,
        height: height,
        color: color,
      ),
    );
  }
}

class ChatMessagesSkeleton extends StatelessWidget {
  const ChatMessagesSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    // Increase the itemCount for a longer skeleton list.
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10),
        itemCount: 10, // Increase number of skeleton items
        itemBuilder: (context, index) {
          final bool isMe = index % 2 == 0;
          // Simulate that every 3rd message has an image placeholder.
          final bool hasImage = index % 3 == 0;
          // Different colors for sender and receiver.
          const Color senderColor = Color.fromARGB(255, 255, 49, 49);
          final Color receiverColor = Colors.grey[300]!;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  // If this simulated message includes an image, show an image placeholder.
                  if (hasImage)
                    SkeletonBox(
                      width: 200,
                      height: 200,
                      borderRadius: BorderRadius.circular(12),
                      color: isMe ? senderColor : receiverColor,
                    ),
                  if (hasImage) const SizedBox(height: 8),
                  // Text bubble skeleton.
                  SkeletonBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 20,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: Radius.circular(isMe ? 12 : 0),
                      bottomRight: Radius.circular(isMe ? 0 : 12),
                    ),
                    color: isMe ? senderColor : receiverColor,
                  ),
                  const SizedBox(height: 4),
                  // Time indicator skeleton.
                  SkeletonBox(
                    width: 50,
                    height: 14,
                    borderRadius: BorderRadius.circular(4),
                    color: isMe ? senderColor : receiverColor,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
