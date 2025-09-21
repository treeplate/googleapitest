class Space {
  // == spaces ==
  // "name"
  final String identifier;
  final SpaceType type;
  // "singleUserBotDm" - default to false if that's null
  final bool botDM;
  // null for anything other than SpaceType.space
  final String? displayName;
  // TODO: find out when this isn't null
  final bool? externalUserAllowed;
  // "spaceThreadingState"
  final SpaceThreadingState threadingState;
  // "spaceDetails.description" - null means no description
  final String? description;
  // "spaceDetails.guidelines" - null means no guidelines
  final String? guidelines;
  // "spaceHistoryState"
  final bool historyOn;
  // default to false if null
  final bool importMode;
  // null for DMs
  final DateTime? createTime;
  final DateTime? lastActiveTime;
  // null for non-DMs
  final bool? adminInstalled;
  // "membershipCount.joinedDirectHumanUserCount"
  final int joinedHumanCount;
  // "membershipCount.joinedGroupCount" - defaults to zero if null
  final int joinedGroupCount;
  // "accessSettings.accessState" - null for anything other than SpaceType.space
  final bool? discoverable;
  // "accessSettings.audience" - null means no target audience
  final String? targetAudienceIdentifier;
  final String spaceURI;
  // null if not in import mode
  final DateTime? importModeExpireTime;
  // == spaces.members ==
  final List<SpaceMember> members;
  // == spaces.messages ==
  final List<Message> messages;

  Space({
    required this.identifier,
    required this.type,
    required this.botDM,
    required this.displayName,
    required this.externalUserAllowed,
    required this.threadingState,
    required this.description,
    required this.guidelines,
    required this.historyOn,
    required this.importMode,
    required this.createTime,
    required this.lastActiveTime,
    required this.adminInstalled,
    required this.joinedHumanCount,
    required this.joinedGroupCount,
    required this.discoverable,
    required this.targetAudienceIdentifier,
    required this.spaceURI,
    required this.importModeExpireTime,
    required this.members,
    required this.messages,
  });
}

class SpaceMember {
  // "name"
  final String memberIdentifier;
  final MembershipState state;
  final MembershipRole role;
  // "member.name" - user identifier or group identifier, based on isGroup
  final String userIdentifier;
  // "member.type" - false if isGroup
  final bool isBot;
  // what type "member" is
  final bool isGroup;

  SpaceMember({
    required this.memberIdentifier,
    required this.state,
    required this.role,
    required this.userIdentifier,
    required this.isBot,
    required this.isGroup,
  });
}

class Message {
  final String identifier;
  // "sender.name"
  final String senderIdentifier;
  // "sender.type"
  final bool senderIsBot;
  final DateTime createTime;
  // null if never edited
  final DateTime? lastUpdateTime;
  // null if never deleted
  final DateTime? deleteTime;
  final String formattedText;
  // "thread.name"
  final String threadIdentifier;
  // "thread.threadKey" - null if not set by this app
  final String? threadKey;
  final String spaceIdentifier;
  // alt text for this message's cards
  final String? fallbackText;
  // "attachment" - null if no attachments
  final Attachment? attachment;
  // defaults to false if null
  final bool threadReply;
  // null if not set by this app
  final String? clientAssignedMessageId;
  // "emojiReactionSummaries" - defaults to empty if null
  final Map<String, int> emojis;
  // "privateMessageViewer.name" - null if not private message
  final String? privateMessageViewerIdentifier;
  // "privateMessageViewer.type" - null if not private message
  final bool? privateMessageViewerIsBot;
  // "deletionMetadata.deletionType" - null if not deleted
  final DeletionType? deletionType;
  // "quotedMessageMetadata.name" - null if no quoted message
  final String? quotedMessageIdentifier;
  // "quotedMessageMetadata.lastUpdateTime" - null if no quoted message
  final DateTime? quotedMessageLastUpdateTime;
  final List<String> attachedGifs;

  Message({
    required this.identifier,
    required this.senderIdentifier,
    required this.senderIsBot,
    required this.createTime,
    required this.lastUpdateTime,
    required this.deleteTime,
    required this.formattedText,
    required this.threadIdentifier,
    required this.threadKey,
    required this.spaceIdentifier,
    required this.fallbackText,
    required this.attachment,
    required this.threadReply,
    required this.clientAssignedMessageId,
    required this.emojis,
    required this.privateMessageViewerIdentifier,
    required this.privateMessageViewerIsBot,
    required this.deletionType,
    required this.quotedMessageIdentifier,
    required this.quotedMessageLastUpdateTime,
    required this.attachedGifs,
  });
}

class Attachment {
  // "name"
  final String identifier;
  // "contentName"
  final String originalFilename;
  // "contentType"
  final String contentType;
  // "thumbnailUri"
  final String thumbnailURI;
  // "downloadUri"
  final String downloadURI;
  // "source"
  final bool? fromDrive;
  // "driveDataRef.driveFileId" - null if fromDrive is false or null
  final String? driveFileID;
  // "attachmentDataRef.resourceName" - null if fromDrive is true or null
  final String? resourceIdentifier;
  // "attachmentDataRef.attachmentUploadToken" - null if fromDrive is true or null
  final String? uploadToken;

  Attachment({
    required this.identifier,
    required this.originalFilename,
    required this.contentType,
    required this.thumbnailURI,
    required this.downloadURI,
    required this.fromDrive,
    required this.driveFileID,
    required this.resourceIdentifier,
    required this.uploadToken,
  });
}

enum DeletionType {
  creator,
  spaceOwner,
  admin,
  appMessageExpiry,
  creatorViaApp,
  spaceOwnerViaApp,
  spaceMember,
}

enum MembershipState { joined, invited, notMember }

enum MembershipRole { member, manager }

enum SpaceType { space, groupChat, directMessage }

enum SpaceThreadingState {
  threadedMessages,
  groupedMessages,
  unthreadedMessages,
}
