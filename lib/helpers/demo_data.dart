import 'dart:math';

import 'package:bluebubbles/database/database.dart';
import 'package:bluebubbles/database/models.dart';
import 'package:flutter/foundation.dart';

const bool isDemoMode = bool.fromEnvironment('DEMO_MODE');

class DemoData {
  static final _rng = Random();

  /// Seeds placeholder chats and messages into the database.
  /// Only runs when built with --dart-define=DEMO_MODE=true and the DB is empty.
  static void seed() {
    if (kIsWeb) return;
    if (!isDemoMode) return;
    if (Database.chats.count() > 0) return;

    final now = DateTime.now();

    _makeChat(
      guid: 'demo-chat-mom',
      address: '+15550000001',
      formattedAddress: 'Mom',
      msgs: [
        _m('Are you coming for dinner tonight? 🍝', false, now.subtract(const Duration(minutes: 12))),
        _m('Yes! I\'ll be there around 7 😊', true, now.subtract(const Duration(minutes: 8))),
        _m('Perfect, I\'ll make your favourite', false, now.subtract(const Duration(minutes: 5))),
      ],
    );

    _makeChat(
      guid: 'demo-chat-alex',
      address: '+15550000002',
      formattedAddress: 'Alex',
      hasUnread: true,
      msgs: [
        _m('Hey are you free this weekend?', false, now.subtract(const Duration(hours: 1))),
        _m('Can you send me those photos from the hike 📸', false, now.subtract(const Duration(minutes: 30))),
      ],
    );

    _makeChat(
      guid: 'demo-chat-trip',
      address: '+15550000003',
      formattedAddress: 'Jordan',
      displayName: 'Trip Planning 🌴',
      extraParticipants: [
        _handle('+15550000004', 'Riley'),
        _handle('+15550000005', 'Sam'),
      ],
      msgs: [
        _m('Who\'s booking the Airbnb?', false, now.subtract(const Duration(hours: 3))),
        _m('I\'ll look tonight', true, now.subtract(const Duration(hours: 2, minutes: 50))),
        _m('Found a great place, sending link now 🏡', true, now.subtract(const Duration(hours: 2))),
        _m('That looks amazing!! Booking it!!', false, now.subtract(const Duration(hours: 1, minutes: 45))),
      ],
    );

    _makeChat(
      guid: 'demo-chat-dad',
      address: '+15550000006',
      formattedAddress: 'Dad',
      msgs: [
        _m('Call me when you get a chance', false, now.subtract(const Duration(days: 1, hours: 2))),
        _m('Will do, talk tonight 👍', true, now.subtract(const Duration(days: 1, hours: 1))),
      ],
    );

    _makeChat(
      guid: 'demo-chat-sarah',
      address: '+15550000007',
      formattedAddress: 'Sarah Johnson',
      msgs: [
        _m('The meeting notes are in the shared doc', false, now.subtract(const Duration(days: 1, hours: 5))),
        _m('Thanks, got them!', true, now.subtract(const Duration(days: 1, hours: 4))),
        _m('Let me know if you have questions', false, now.subtract(const Duration(days: 1, hours: 3, minutes: 50))),
      ],
    );

    _makeChat(
      guid: 'demo-chat-friday',
      address: '+15550000008',
      formattedAddress: 'Jake',
      displayName: 'Friday Night 🎬',
      extraParticipants: [
        _handle('+15550000009', 'Maya'),
      ],
      msgs: [
        _m('Movie or dinner first?', false, now.subtract(const Duration(days: 2, hours: 1))),
        _m('Dinner then movie obviously 🍕', true, now.subtract(const Duration(days: 2, hours: 0, minutes: 55))),
        _m('Correct answer 😂', false, now.subtract(const Duration(days: 2, hours: 0, minutes: 50))),
      ],
    );
  }

  static Handle _handle(String address, String formattedAddress) {
    return Handle(address: address, formattedAddress: formattedAddress, service: 'iMessage');
  }

  static void _makeChat({
    required String guid,
    required String address,
    required String formattedAddress,
    String? displayName,
    List<Handle> extraParticipants = const [],
    List<Message> msgs = const [],
    bool hasUnread = false,
  }) {
    final primaryHandle = _handle(address, formattedAddress)..save();
    final participants = [primaryHandle];
    for (final h in extraParticipants) {
      participants.add(h..save());
    }

    final chat = Chat(
      guid: 'iMessage;-;$guid',
      chatIdentifier: 'iMessage;-;$guid',
      displayName: displayName,
      participants: participants,
      hasUnreadMessage: hasUnread,
      senderIsKnown: true,
    );
    chat.save();

    for (final msg in msgs) {
      if (msg.isFromMe == false) {
        msg.handle = primaryHandle;
      }
      msg.save(chat: chat);
    }

    // Re-save to pick up dbOnlyLatestMessageDate from the messages we just inserted.
    chat.save();
  }

  static Message _m(String text, bool fromMe, DateTime date) {
    return Message(
      guid: 'demo-msg-${_rng.nextInt(0x7fffffff)}',
      text: text,
      isFromMe: fromMe,
      dateCreated: date,
      dateDelivered: date,
    );
  }
}
