
class ChatModel {
  /// The chat ID.
  final int chat;

  /// The chat message.
  final String message;

  /// The time of the chat.
  final dynamic time;

  /// The type of chat.
  var chatType;

  ChatModel({
    required this.chat,
    required this.message,
    required this.time,
    this.chatType = ChatType.message,
  });
  factory ChatModel.fromJson(dynamic json) {
    return ChatModel(
      chat: json['chat'] as int,
      message: json['message'] as String,
      time: json['time'] as dynamic,
    );
  }

  Map<String, dynamic> toJson() => {
    'chat': chat,
    'message': message,
    'time': time,
  };

  static List<Map<String, dynamic>> toJsonList(List<ChatModel> list) {
    List<Map<String, dynamic>> listJson = [];
    list.forEach((element) {
      listJson.add(element.toJson());
    });
    return listJson;
  }
}

/// Represents the type of a chat message.
enum ChatType {
  message,
  error,
  success,
  warning,
  info,
  loading,
}