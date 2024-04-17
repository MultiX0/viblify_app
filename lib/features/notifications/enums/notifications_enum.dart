enum ActionType {
  feed_like,
  feed_comment,
  feed_comment_like,
  dash_like,
  dash_comment,
  dash_comment_like,
  stt,
  new_follow,
}

String getActionTypeString(ActionType actionType) {
  switch (actionType) {
    case ActionType.feed_like:
      return 'feed_like';
    case ActionType.feed_comment:
      return 'feed_comment';
    case ActionType.feed_comment_like:
      return 'feed_comment_like';
    case ActionType.dash_like:
      return 'dash_like';
    case ActionType.dash_comment:
      return 'dash_comment';
    case ActionType.dash_comment_like:
      return 'dash_comment_like';
    case ActionType.stt:
      return 'stt';
    case ActionType.new_follow:
      return 'new_follow';
    default:
      return ''; // Handle any other cases if needed
  }
}

ActionType getActionTypeFromString(String actionString) {
  switch (actionString) {
    case 'feed_like':
      return ActionType.feed_like;
    case 'feed_comment':
      return ActionType.feed_comment;
    case 'feed_comment_like':
      return ActionType.feed_comment_like;
    case 'dash_like':
      return ActionType.dash_like;
    case 'dash_comment':
      return ActionType.dash_comment;
    case 'dash_comment_like':
      return ActionType.dash_comment_like;
    case 'stt':
      return ActionType.stt;
    case 'new_follow':
      return ActionType.new_follow;

    default:
      throw ArgumentError('Invalid action string: $actionString');
  }
}

String getNotificationString(ActionType actionType) {
  switch (actionType) {
    case ActionType.feed_like:
      return 'Likes Your Post';
    case ActionType.feed_comment:
      return 'Commented on Your Post';
    case ActionType.feed_comment_like:
      return 'Like Your Comment on the Post';
    case ActionType.dash_like:
      return 'Likes Your Dash';
    case ActionType.dash_comment:
      return 'Commented on Your Dash';
    case ActionType.dash_comment_like:
      return 'Like Your Comment on the Dash';

    case ActionType.stt:
      return 'send new anonymous message';
    case ActionType.new_follow:
      return 'start following you';
    default:
      return '';
  }
}
