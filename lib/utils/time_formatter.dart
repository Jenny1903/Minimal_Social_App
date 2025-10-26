class TimeFormatter{
  static String formatTimeAgo(DateTime dateTime){
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inHours < 1){
      return '${difference.inMinutes}m ago';
    }else if (difference.inDays < 1){
      return '${difference.inMinutes}h ago';
    }
    else {
      return '${difference.inMinutes}d ago';
    }
  }
}