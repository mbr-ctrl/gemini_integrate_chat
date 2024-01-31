import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/constants.dart';
import '../models/chat.dart';
import '../services/gemini_ai.dart';
import '../widgets/chat_item_card.dart';
import '../widgets/helper_widget.dart';

class FlutterGeminiChat extends StatefulWidget {
  const FlutterGeminiChat({
    Key? key,
    required this.chatContext,
    required this.chatList,
    required this.apiKey,
    this.hintText = "Posez vos questions...",
    this.bodyPlaceHolder = const BodyPlaceholderWidget(),
    this.buttonColor = secondaryColor,
    this.errorMessage = "an error occurred, please try again later",
    this.botChatBubbleColor = primaryColor,
    this.userChatBubbleColor = secondaryColor,
    this.botChatBubbleTextColor = Colors.black,
    this.userChatBubbleTextColor = Colors.black,
    this.loaderWidget = const Center(
      child: CircularProgressIndicator(
        color: primaryColor,
      ),
    ),
    this.onRecorderTap,
  }) : super(key: key);

  /// The context of the chat.
  final String chatContext;

  /// The list of chat models.
  final List<ChatModel> chatList;

  /// The API key for the chat get it on https://ai.google.dev/.
  final String apiKey;

  /// The hint text for the chat input field.
  final String hintText;

  /// The placeholder widget to be displayed in the chat body.
  final Widget bodyPlaceHolder;

  /// The color of the chat button.
  final Color buttonColor;

  /// The error message to be displayed in case of an error.
  final String errorMessage;

  /// The color of the chat bubble for the bots messages.
  final Color botChatBubbleColor;

  /// The color of the chat bubble for the user's messages.
  final Color userChatBubbleColor;

  ///The color of text chat bubble for the bots messages.
  final Color botChatBubbleTextColor;

  ///The color of text chat bubble for the users messages.
  final Color userChatBubbleTextColor;

  /// The loader widget to be displayed in the chat body.
  final Widget loaderWidget;

  /// Recorder button onTap callback.
  final VoidCallback? onRecorderTap;

  @override
  _FlutterGeminiChatState createState() => _FlutterGeminiChatState();
}

class _FlutterGeminiChatState extends State<FlutterGeminiChat> {
  List<Map<String, String>> messages = [];

  final TextEditingController questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    messages.add({"text": widget.chatContext});
  }

  @override
  void dispose() {
    questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: widget.chatList.isEmpty ? widget.bodyPlaceHolder : chatBody(),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: texFieldBottomWidget(),
        ),
      ],
    );
  }

  Padding chatBody() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 90),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: widget.chatList.length,
        itemBuilder: (context, index) => ChatItemCard(
          botChatBubbleColor: widget.botChatBubbleColor,
          userChatBubbleColor: widget.userChatBubbleColor,
          chatItem: widget.chatList[index],
          onTap: () {
            showToolsDialog(context, index);
          },
        ),
      ),
    );
  }

  Future<dynamic> showToolsDialog(BuildContext context, int index) {
    return customDialog(
      context: context,
      widget: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            onTap: () {
              Clipboard.setData(
                  ClipboardData(text: widget.chatList[index].message));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: primaryColor,
                  duration: Duration(milliseconds: 400),
                  content: Text('Copier dans le presse papier'),
                ),
              );
            },
            leading: const Icon(Icons.copy),
            title: const Text("Copier"),
          ),
          ListTile(
            onTap: () {
              setState(() {
                widget.chatList.removeAt(index);
              });
              Navigator.pop(context);
            },
            leading: const Icon(Icons.delete),
            title: const Text("Supprimer"),
          ),
          ListTile(
            onTap: () {
              setState(() {
                questionController.text = widget.chatList[index].message;
                questionController.selection = TextSelection.fromPosition(
                    TextPosition(offset: questionController.text.length));
              });
              Navigator.pop(context);
            },
            leading: const Icon(Icons.add),
            title: const Text("Modifier"),
          ),
        ],
      ),
    );
  }

  Widget texFieldBottomWidget() {
    return Container(
      height: 90,
      padding: const EdgeInsets.only(
          left: appPadding, right: appPadding, top: appPadding + 8),
      color: Colors.white,
      child: TextField(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(10),
          hintText: widget.hintText,
          suffixIcon: questionController.text.isEmpty
              ? InkWell(
            onTap: widget.onRecorderTap,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: secondaryColor),
              padding: const EdgeInsets.all(14),
              child: const Icon(
                Icons.mic,
                color: Colors.white,
                size: 24,
              ),
            ),
          )
              : InkWell(
            onTap: () async {
              var question = questionController.text;
              setState(() {
                widget.chatList.add(ChatModel(
                    chat: 0,
                    message: questionController.text,
                    time:
                    "${DateTime.now().hour}:${DateTime.now().second}"));

                setState(() {
                  widget.chatList.add(ChatModel(
                      chatType: ChatType.loading,
                      chat: 1,
                      message: "",
                      time: ""));
                });

                FocusScope.of(context).unfocus();
                try {
                  _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut);
                } catch (e) {
                  print(
                      "**************************************************************");
                  print(e);
                }
                messages.add({
                  "text": widget.chatContext + "\n" + question,
                });
                questionController.text = "";
              });
              var (responseString, response) =
              await GeminiApi.geminiChatApi(
                  messages: messages, apiKey: widget.apiKey);
              setState(() {
                FocusScope.of(context).unfocus();
                _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent +
                        MediaQuery.of(context).size.height,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut);
                if (response.statusCode == 200) {
                  widget.chatList.removeLast();
                  widget.chatList.add(ChatModel(
                      chat: 1,
                      message: responseString,
                      time:
                      "${DateTime.now().hour}:${DateTime.now().second}"));
                } else {
                  widget.chatList.removeLast();
                  widget.chatList.add(ChatModel(
                      chat: 0,
                      chatType: ChatType.error,
                      message: widget.errorMessage,
                      time:
                      "${DateTime.now().hour}:${DateTime.now().second}"));
                }
                FocusScope.of(context).unfocus();
              });
            },
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: widget.buttonColor),
              padding: const EdgeInsets.all(14),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          labelStyle: const TextStyle(fontSize: 12),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.greenAccent),
            borderRadius: BorderRadius.circular(25),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: primaryColor),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        controller: questionController,
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }
}

class BodyPlaceholderWidget extends StatelessWidget {
  const BodyPlaceholderWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 300,
            height: 300,
            child: const Icon(Icons.chat),
          ),
          const Text("Texte", style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}