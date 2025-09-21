import 'package:googleapis/chat/v1.dart' as chat;

import 'datastructure.dart';

Future<List<Space>> getSpaces(chat.HangoutsChatApi api) async {
  List<Space> spaces = [];
  for (chat.Space space in (await api.spaces.list()).spaces!) {
    List<chat.Membership> members = (await api.spaces.members.list(space.name!)).memberships!;
    List<chat.Message> messages = (await api.spaces.messages.list(space.name!)).messages ?? [];
    spaces.add(
      Space(
        identifier: space.name!,
        type: switch (space.spaceType) {
          'SPACE' => .space,
          'GROUP_CHAT' => .groupChat,
          'DIRECT_MESSAGE' => .directMessage,
          _ => throw FormatException('invalid spaceType ${space.spaceType}'),
        },
        botDM: space.singleUserBotDm ?? false,
        displayName: space.displayName,
        externalUserAllowed: space.externalUserAllowed,
        threadingState: switch (space.spaceThreadingState) {
          'THREADED_MESSAGES' => .threadedMessages,
          'GROUPED_MESSAGES' => .groupedMessages,
          'UNTHREADED_MESSAGES' => .unthreadedMessages,
          _ => throw FormatException(
            'invalid spaceThreadingState ${space.spaceThreadingState}',
          ),
        },
        description: space.spaceDetails?.description,
        guidelines: space.spaceDetails?.guidelines,
        historyOn: switch (space.spaceHistoryState) {
          'HISTORY_OFF' => false,
          'HISTORY_ON' => true,
          _ => throw FormatException(
            'invalid spaceHistoryState ${space.spaceHistoryState}',
          ),
        },
        importMode: space.importMode ?? false,
        createTime: DateTime.tryParse(space.createTime ?? 'null'),
        lastActiveTime: DateTime.tryParse(space.lastActiveTime ?? 'null'),
        adminInstalled: space.adminInstalled,
        joinedHumanCount: space.membershipCount!.joinedDirectHumanUserCount!,
        joinedGroupCount: space.membershipCount!.joinedGroupCount ?? 0,
        discoverable: switch (space.accessSettings?.accessState) {
          null => null,
          'PRIVATE' => false,
          'DISCOVERABLE' => true,
          _ => throw FormatException(
            'invalid accessState ${space.accessSettings?.accessState}',
          ),
        },
        targetAudienceIdentifier: space.accessSettings?.audience,
        spaceURI: space.spaceUri!,
        importModeExpireTime: DateTime.tryParse(
          space.importModeExpireTime ?? 'null',
        ),
        members: members.map((member) {
          return SpaceMember(
            memberIdentifier: member.name!,
            state: switch (member.state!) {
              'JOINED' => .joined,
              'INVITED' => .invited,
              'NOT_A_MEMBER' => .notMember,
              _ => throw FormatException(
                'invalid member.state ${member.state}',
              ),
            },
            role: switch (member.role!) {
              'ROLE_MEMBER' => .member,
              'ROLE_MANAGER' => .manager,
              _ => throw FormatException('invalid member.role ${member.role}'),
            },
            userIdentifier: member.member!.name!,
            isBot: parseUserType(member.member),
            isGroup: member.groupMember != null,
          );
        }).toList(),
        messages: messages
            .map(
              (message) {
                return Message(
                identifier: message.name!,
                senderIdentifier: message.sender!.name!,
                senderIsBot: parseUserType(message.sender!),
                createTime: DateTime.parse(message.createTime!),
                lastUpdateTime: DateTime.tryParse(message.createTime ?? 'null'),
                deleteTime: DateTime.tryParse(message.deleteTime ?? 'null'),
                formattedText: message.formattedText!,
                threadIdentifier: message.thread!.name!,
                threadKey: message.thread!.threadKey,
                spaceIdentifier: message.space!.name!,
                fallbackText: message.fallbackText,
                attachment: message.attachment == null
                    ? null
                    : Attachment(
                        identifier: message.attachment!.single.name!,
                        originalFilename:
                            message.attachment!.single.contentName!,
                        contentType: message.attachment!.single.contentType!,
                        thumbnailURI: message.attachment!.single.thumbnailUri!,
                        downloadURI: message.attachment!.single.downloadUri!,
                        fromDrive: switch (message.attachment!.single.source) {
                          'DRIVE_FILE' => true,
                          'UPLOADED_CONTENT' => false,
                          _ => throw FormatException(
                            'invalid attachment.source ${message.attachment!.single.source}',
                          ),
                        },
                        driveFileID: message
                            .attachment!
                            .single
                            .driveDataRef
                            ?.driveFileId,
                        resourceIdentifier: message
                            .attachment!
                            .single
                            .attachmentDataRef
                            ?.resourceName,
                        uploadToken: message
                            .attachment!
                            .single
                            .attachmentDataRef
                            ?.attachmentUploadToken,
                      ),
                threadReply: message.threadReply ?? false,
                clientAssignedMessageId: message.clientAssignedMessageId,
                emojis: Map.fromEntries(
                  message.emojiReactionSummaries?.map(
                        (e) => MapEntry(
                          e.emoji!.unicode ??
                              e.emoji!.customEmoji?.uid ??
                              'unknown emoji',
                          e.reactionCount!,
                        ),
                      ) ??
                      [],
                ),
                privateMessageViewerIdentifier:
                    message.privateMessageViewer?.name,
                privateMessageViewerIsBot: parseUserType(
                  message.privateMessageViewer,
                ),
                deletionType: switch (message.deletionMetadata?.deletionType) {
                  null => null,
                  'CREATOR' => .creator,
                  'SPACE_OWNER' => .spaceOwner,
                  'ADMIN' => .admin,
                  'APP_MESSAGE_EXPIRY' => .appMessageExpiry,
                  'CREATOR_VIA_APP' => .creatorViaApp,
                  'SPACE_OWNER_VIA_APP' => .spaceOwnerViaApp,
                  'SPACE_MEMBER' => .spaceMember,
                  _ => throw FormatException(
                    'invalid deletionType ${message.deletionMetadata?.deletionType}',
                  ),
                },
                quotedMessageIdentifier: message.quotedMessageMetadata?.name,
                quotedMessageLastUpdateTime: DateTime.tryParse(
                  message.quotedMessageMetadata?.lastUpdateTime ?? 'null',
                ),
                attachedGifs:
                    message.attachedGifs?.map((e) => e.uri!).toList() ?? [],
              );
              },
            )
            .toList(),
      ),
    );
  }
  return spaces;
}

bool parseUserType(chat.User? user) {
  return switch (user?.type) {
    null => false,
    'HUMAN' => false,
    'BOT' => true,
    _ => throw FormatException('invalid user.type ${user?.type}'),
  };
}
