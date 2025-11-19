class DateUtils {
  /// Formata uma data para o formato "Uploaded at MM/DD/YYYY - H:MM AM/PM"
  /// Sempre usa o timezone local do dispositivo
  static String formatUploadDateTime(DateTime dateTime) {
    // Sempre converter para timezone local do dispositivo
    final localDateTime = dateTime.toLocal();

    String day = localDateTime.day.toString().padLeft(2, '0');
    String month = localDateTime.month.toString().padLeft(2, '0');
    String year = localDateTime.year.toString();

    int hour = localDateTime.hour;
    String minute = localDateTime.minute.toString().padLeft(2, '0');
    String period = hour >= 12 ? 'PM' : 'AM';

    // Converter para formato 12 horas
    if (hour > 12) {
      hour = hour - 12;
    } else if (hour == 0) {
      hour = 12;
    }

    return "Uploaded at $month/$day/$year - $hour:$minute $period";
  }
}
