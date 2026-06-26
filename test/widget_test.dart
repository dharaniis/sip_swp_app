import 'package:flutter_test/flutter_test.dart';
import 'package:sip_swp_calc/logic/sip_calculator.dart';
import 'package:sip_swp_calc/logic/swp_calculator.dart';

void main() {
  test('SIP calculation with zero rate', () {
    final result = calculateSip(monthlyInvestment: 1000, annualRate: 0, years: 1);
    expect(result.totalInvested, 12000);
    expect(result.finalValue, 12000);
    expect(result.estimatedReturns, 0);
  });

  test('SIP calculation with positive rate', () {
    final result = calculateSip(monthlyInvestment: 1000, annualRate: 12, years: 1);
    expect(result.totalInvested, 12000);
    expect(result.finalValue, greaterThan(12000));
    expect(result.yearlyBreakdown.length, 1);
  });

  test('SWP calculation basic', () {
    final result = calculateSwp(principal: 100000, annualRate: 0, monthlyWithdrawal: 5000, years: 1);
    expect(result.totalWithdrawn, 60000);
    expect(result.remainingValue, 40000);
  });
}
