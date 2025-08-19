class Message {
  final String sender;
  final String text;
  final DateTime timestamp;
  final MessageType type;
  final MessageStatus status;
  final String? imageUrl;

  Message({
    required this.sender,
    required this.text,
    required this.timestamp,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    this.imageUrl,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      sender: json['sender'] ?? '',
      text: json['text'] ?? '',
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type'] ?? 'text'}',
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString() == 'MessageStatus.${json['status'] ?? 'sent'}',
        orElse: () => MessageStatus.sent,
      ),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'imageUrl': imageUrl,
    };
  }

  Message copyWith({
    String? sender,
    String? text,
    DateTime? timestamp,
    MessageType? type,
    MessageStatus? status,
    String? imageUrl,
  }) {
    return Message(
      sender: sender ?? this.sender,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

enum MessageType {
  text,
  image,
  emoji,
  system,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}
