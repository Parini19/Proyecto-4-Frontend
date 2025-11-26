import 'package:flutter/material.dart';
import 'floating_chat_bubble.dart';

class ChatWrapper extends StatelessWidget {
  final Widget child;
  final bool showChat;

  const ChatWrapper({
    Key? key,
    required this.child,
    this.showChat = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!showChat) {
      return child;
    }

    // Si el child es un Scaffold, envolvemos solo el body
    return Stack(
      children: [
        child,
        const FloatingChatBubble(),
      ],
    );
  }
}