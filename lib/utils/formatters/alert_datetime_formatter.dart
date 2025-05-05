// TODO hacer el formateo para que quede chido

class AlertDateTimeFormatter {
  static String format(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if(difference.inDays < 1){
    return 'Hoy, ${dateTime.hour}:${dateTime.minute.toString()}';
  }else{
    if(difference.inDays == 1){
      return 'Ayer, ${dateTime.hour}:${dateTime.minute.toString()}';
    }else{
      if(difference.inDays <= 7){
        return '${dateTime.weekday}, ${dateTime.hour}:${dateTime.minute.toString()}';
      }else{
        return '${dateTime.day}/${dateTime.month}/${dateTime.year}, ${dateTime.hour}:${dateTime.minute.toString()}';
      }
    }
  }
  }
}