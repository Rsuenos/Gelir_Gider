class InstallmentSlice {
  const InstallmentSlice({
    required this.index,
    required this.amount,
  });

  final int index;
  final double amount;
}

class InstallmentUtils {
  /// Tutarı eşit taksitlere böler ve kuruş farkını son taksite ekler
  static List<InstallmentSlice> splitAmount(num total, int n) {
    if (n <= 0) throw ArgumentError('Taksit sayısı pozitif olmalı');
    if (n == 1) return [InstallmentSlice(index: 1, amount: total.toDouble())];

    final cents = (total * 100).round();
    final base = cents ~/ n;
    final rem = cents % n;
    final parts = List.generate(n, (i) => base + (i == n - 1 ? rem : 0));

    return List.generate(
        n,
        (i) => InstallmentSlice(
              index: i + 1,
              amount: parts[i] / 100.0,
            ));
  }

  /// Ay ilerletme işlemini güvenli şekilde yapar (28/29/30/31 gün durumları)
  static DateTime addMonthsSafe(DateTime date, int months) {
    if (months == 0) return date;

    final y = date.year + ((date.month - 1 + months) ~/ 12);
    final m = ((date.month - 1 + months) % 12) + 1;
    final day = date.day.clamp(1, _getDaysInMonth(y, m));

    return DateTime(y, m, day);
  }

  /// Verilen yıl ve ayda kaç gün olduğunu hesaplar
  static int _getDaysInMonth(int year, int month) {
    if (month == 2) {
      return _isLeapYear(year) ? 29 : 28;
    } else if (month == 4 || month == 6 || month == 9 || month == 11) {
      return 30;
    } else {
      return 31;
    }
  }

  /// Artık yıl kontrolü
  static bool _isLeapYear(int year) {
    return (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0);
  }

  /// Verilen tarihin aynı ayda olup olmadığını kontrol eder
  static bool isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }
}
