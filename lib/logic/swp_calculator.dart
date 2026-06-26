class SwpMonthRow {
  final int month;
  final double openingBalance;
  final double closingBalance;
  final double withdrawal;
  final double totalWithdrawn;

  SwpMonthRow({
    required this.month,
    required this.openingBalance,
    required this.closingBalance,
    required this.withdrawal,
    required this.totalWithdrawn,
  });
}

class SwpResult {
  final double totalWithdrawn;
  final double remainingValue;
  final double totalReturns;
  final List<SwpYearRow> yearlyBreakdown;
  final List<SwpMonthRow> schedule;

  SwpResult({
    required this.totalWithdrawn,
    required this.remainingValue,
    required this.totalReturns,
    required this.yearlyBreakdown,
    required this.schedule,
  });
}

class SwpYearRow {
  final int year;
  final double invested;
  final double value;
  final double withdrawn;

  SwpYearRow({
    required this.year,
    required this.invested,
    required this.value,
    required this.withdrawn,
  });
}

SwpResult calculateSwp({
  required double principal,
  required double annualRate,
  required double monthlyWithdrawal,
  required int years,
}) {
  final monthlyRate = annualRate / 12 / 100;
  var balance = principal;
  var totalWithdrawn = 0.0;
  final schedule = <SwpMonthRow>[];
  final yearlyBreakdown = <SwpYearRow>[];

  for (int y = 1; y <= years; y++) {
    for (int m = 0; m < 12; m++) {
      final monthIndex = (y - 1) * 12 + m + 1;
      final opening = balance;
      balance = balance * (1 + monthlyRate);
      double withdrawal = 0;
      if (balance >= monthlyWithdrawal) {
        balance -= monthlyWithdrawal;
        withdrawal = monthlyWithdrawal;
        totalWithdrawn += monthlyWithdrawal;
      } else {
        withdrawal = balance;
        totalWithdrawn += balance;
        balance = 0;
      }
      schedule.add(SwpMonthRow(
        month: monthIndex,
        openingBalance: opening,
        closingBalance: balance,
        withdrawal: withdrawal,
        totalWithdrawn: totalWithdrawn,
      ));
    }
    yearlyBreakdown.add(SwpYearRow(
      year: y,
      invested: principal,
      value: balance,
      withdrawn: totalWithdrawn,
    ));
  }

  return SwpResult(
    totalWithdrawn: totalWithdrawn,
    remainingValue: balance,
    totalReturns: totalWithdrawn + balance - principal,
    yearlyBreakdown: yearlyBreakdown,
    schedule: schedule,
  );
}
