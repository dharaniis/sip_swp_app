class SipMonthRow {
  final int month;
  final double investedThisMonth;
  final double totalInvested;
  final double value;

  SipMonthRow({
    required this.month,
    required this.investedThisMonth,
    required this.totalInvested,
    required this.value,
  });
}

class SipResult {
  final double totalInvested;
  final double finalValue;
  final double estimatedReturns;
  final List<SipYearRow> yearlyBreakdown;
  final List<SipMonthRow> schedule;

  SipResult({
    required this.totalInvested,
    required this.finalValue,
    required this.estimatedReturns,
    required this.yearlyBreakdown,
    required this.schedule,
  });
}

class SipYearRow {
  final int year;
  final double invested;
  final double value;

  SipYearRow({required this.year, required this.invested, required this.value});
}

SipResult calculateSip({
  required double monthlyInvestment,
  required double annualRate,
  required int years,
}) {
  final monthlyRate = annualRate / 12 / 100;
  final totalMonths = years * 12;
  final totalInvested = monthlyInvestment * totalMonths;

  double finalValue;
  if (monthlyRate == 0) {
    finalValue = totalInvested;
  } else {
    final onePlusR = 1 + monthlyRate;
    var compound = 1.0;
    for (int i = 0; i < totalMonths; i++) {
      compound *= onePlusR;
    }
    finalValue = monthlyInvestment * (compound - 1) / monthlyRate * onePlusR;
  }

  final estimatedReturns = finalValue - totalInvested;

  final schedule = <SipMonthRow>[];
  final yearlyBreakdown = <SipYearRow>[];

  if (monthlyRate == 0) {
    for (int m = 1; m <= totalMonths; m++) {
      final totalInv = monthlyInvestment * m;
      schedule.add(SipMonthRow(
        month: m,
        investedThisMonth: monthlyInvestment,
        totalInvested: totalInv,
        value: totalInv,
      ));
    }
    for (int y = 1; y <= years; y++) {
      final invested = monthlyInvestment * y * 12;
      yearlyBreakdown.add(SipYearRow(year: y, invested: invested, value: invested));
    }
  } else {
    final onePlusR = 1 + monthlyRate;
    var runningValue = 0.0;
    for (int m = 1; m <= totalMonths; m++) {
      runningValue = (runningValue + monthlyInvestment) * onePlusR;
      schedule.add(SipMonthRow(
        month: m,
        investedThisMonth: monthlyInvestment,
        totalInvested: monthlyInvestment * m,
        value: runningValue,
      ));
    }
    for (int y = 1; y <= years; y++) {
      final months = y * 12;
      final invested = monthlyInvestment * months;
      var compound = 1.0;
      for (int i = 0; i < months; i++) {
        compound *= onePlusR;
      }
      final value = monthlyInvestment * (compound - 1) / monthlyRate * onePlusR;
      yearlyBreakdown.add(SipYearRow(year: y, invested: invested, value: value));
    }
  }

  return SipResult(
    totalInvested: totalInvested,
    finalValue: finalValue,
    estimatedReturns: estimatedReturns,
    yearlyBreakdown: yearlyBreakdown,
    schedule: schedule,
  );
}
