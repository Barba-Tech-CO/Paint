class DateHelper {
  /// Formata uma data para o formato "Uploaded at MM/DD/YYYY - H:MM AM/PM"
  static String formatUploadDateTime(DateTime dateTime) {
    String day = dateTime.day.toString().padLeft(2, '0');
    String month = dateTime.month.toString().padLeft(2, '0');
    String year = dateTime.year.toString();

    int hour = dateTime.hour;
    String minute = dateTime.minute.toString().padLeft(2, '0');
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
