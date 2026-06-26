class LumpsumYearRow {
  final int year;
  final double value;
  final double returns;

  LumpsumYearRow({
    required this.year,
    required this.value,
    required this.returns,
  });
}

class LumpsumResult {
  final double totalInvestment;
  final double finalValue;
  final double estimatedReturns;
  final List<LumpsumYearRow> yearlyBreakdown;

  LumpsumResult({
    required this.totalInvestment,
    required this.finalValue,
    required this.estimatedReturns,
    required this.yearlyBreakdown,
  });
}

LumpsumResult calculateLumpsum({
  required double principal,
  required double annualRate,
  required int years,
}) {
  final monthlyRate = annualRate / 12 / 100;
  final totalMonths = years * 12;

  double finalValue;
  if (monthlyRate == 0) {
    finalValue = principal;
  } else {
    final onePlusR = 1 + monthlyRate;
    var compound = 1.0;
    for (int i = 0; i < totalMonths; i++) {
      compound *= onePlusR;
    }
    finalValue = principal * compound;
  }

  final estimatedReturns = finalValue - principal;

  final yearlyBreakdown = <LumpsumYearRow>[];
  if (monthlyRate == 0) {
    for (int y = 1; y <= years; y++) {
      yearlyBreakdown.add(LumpsumYearRow(
        year: y,
        value: principal,
        returns: 0,
      ));
    }
  } else {
    final onePlusR = 1 + monthlyRate;
    for (int y = 1; y <= years; y++) {
      final months = y * 12;
      var compound = 1.0;
      for (int i = 0; i < months; i++) {
        compound *= onePlusR;
      }
      final value = principal * compound;
      yearlyBreakdown.add(LumpsumYearRow(
        year: y,
        value: value,
        returns: value - principal,
      ));
    }
  }

  return LumpsumResult(
    totalInvestment: principal,
    finalValue: finalValue,
    estimatedReturns: estimatedReturns,
    yearlyBreakdown: yearlyBreakdown,
  );
}
