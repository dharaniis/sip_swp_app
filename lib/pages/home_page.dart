import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sip_swp_calc/logic/sip_calculator.dart';
import 'package:sip_swp_calc/logic/swp_calculator.dart';
import 'package:sip_swp_calc/logic/lumpsum_calculator.dart';
import 'package:sip_swp_calc/widgets/calc_slider.dart';
import 'package:sip_swp_calc/widgets/sip_breakdown.dart';
import 'package:sip_swp_calc/widgets/swp_breakdown.dart';
import 'package:sip_swp_calc/widgets/lumpsum_breakdown.dart';

final _currencyFormat = NumberFormat('#,##,##0.00');

class SipResultNotifier extends Notifier<SipResult?> {
  @override
  SipResult? build() => null;
  void calculate(double monthly, double rate, int years) {
    state = calculateSip(monthlyInvestment: monthly, annualRate: rate, years: years);
  }
}

final _sipResultProvider = NotifierProvider<SipResultNotifier, SipResult?>(SipResultNotifier.new);

class SwpResultNotifier extends Notifier<SwpResult?> {
  @override
  SwpResult? build() => null;
  void calculate(double principal, double rate, double withdrawal, int years) {
    state = calculateSwp(
      principal: principal,
      annualRate: rate,
      monthlyWithdrawal: withdrawal,
      years: years,
    );
  }
}

final _swpResultProvider = NotifierProvider<SwpResultNotifier, SwpResult?>(SwpResultNotifier.new);

class LumpsumResultNotifier extends Notifier<LumpsumResult?> {
  @override
  LumpsumResult? build() => null;
  void calculate(double principal, double rate, int years) {
    state = calculateLumpsum(principal: principal, annualRate: rate, years: years);
  }
}

final _lumpsumResultProvider = NotifierProvider<LumpsumResultNotifier, LumpsumResult?>(LumpsumResultNotifier.new);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _tabIndex = 0;

  double _sipMonthly = 5000;
  double _sipRate = 12;
  double _sipYears = 10;

  double _swpPrincipal = 500000;
  double _swpRate = 8;
  double _swpWithdrawal = 5000;
  double _swpYears = 10;

  double _lumpsumPrincipal = 500000;
  double _lumpsumRate = 12;
  double _lumpsumYears = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateSip();
      _calculateSwp();
      _calculateLumpsum();
    });
  }

  void _calculateSip() {
    if (_sipMonthly <= 0 || _sipRate <= 0 || _sipYears <= 0) return;
    ref.read(_sipResultProvider.notifier).calculate(_sipMonthly, _sipRate, _sipYears.round());
  }

  void _calculateSwp() {
    if (_swpPrincipal <= 0 || _swpRate <= 0 || _swpWithdrawal <= 0 || _swpYears <= 0) return;
    ref.read(_swpResultProvider.notifier).calculate(_swpPrincipal, _swpRate, _swpWithdrawal, _swpYears.round());
  }

  void _calculateLumpsum() {
    if (_lumpsumPrincipal <= 0 || _lumpsumRate <= 0 || _lumpsumYears <= 0) return;
    ref.read(_lumpsumResultProvider.notifier).calculate(_lumpsumPrincipal, _lumpsumRate, _lumpsumYears.round());
  }

  @override
  Widget build(BuildContext context) {
    final sipResult = ref.watch(_sipResultProvider);
    final swpResult = ref.watch(_swpResultProvider);
    final lumpsumResult = ref.watch(_lumpsumResultProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.calculate, color: Color(0xFF002856), size: 28),
            SizedBox(width: 8),
            Text(
              'SIP, SWP & Lumpsum',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('SIP')),
                ButtonSegment(value: 1, label: Text('SWP')),
                ButtonSegment(value: 2, label: Text('Lumpsum')),
              ],
              selected: {_tabIndex},
              onSelectionChanged: (set) {
                setState(() => _tabIndex = set.first);
              },
              style: SegmentedButton.styleFrom(
                selectedBackgroundColor: const Color(0xFF002856),
                selectedForegroundColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _tabIndex,
              children: [
                _buildSipTab(sipResult),
                _buildSwpTab(swpResult),
                _buildLumpsumTab(lumpsumResult),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSipTab(SipResult? result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputCard([
            CalcSlider(
              title: 'Monthly Investment',
              subtitle: 'Amount you invest each month',
              min: 100,
              max: 500000,
              value: _sipMonthly,
              step: 500,
              onChanged: (v) => setState(() => _sipMonthly = v),
              onChangeEnd: (_) => _calculateSip(),
            ),
            const Divider(height: 1),
            CalcSlider(
              title: 'Expected Return',
              subtitle: 'Per annum',
              unit: '%',
              min: 0.5,
              max: 30,
              value: _sipRate,
              step: 0.5,
              onChanged: (v) => setState(() => _sipRate = v),
              onChangeEnd: (_) => _calculateSip(),
            ),
            const Divider(height: 1),
            CalcSlider(
              title: 'Time Period',
              subtitle: 'Duration of investment',
              unit: 'Years',
              min: 1,
              max: 40,
              value: _sipYears,
              step: 1,
              onChanged: (v) => setState(() => _sipYears = v),
              onChangeEnd: (_) => _calculateSip(),
            ),
          ]),
          if (result != null) ...[
            const SizedBox(height: 20),
            _buildSipResultCard(result),
            const SizedBox(height: 16),
            SipBreakdown(yearlyBreakdown: result.yearlyBreakdown),
          ],
        ],
      ),
    );
  }

  Widget _buildSwpTab(SwpResult? result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputCard([
            CalcSlider(
              title: 'Total Investment',
              subtitle: 'Initial lump sum amount',
              min: 10000,
              max: 200000000,
                value: _swpPrincipal,
                step: 50000,
              onChanged: (v) => setState(() => _swpPrincipal = v),
              onChangeEnd: (_) => _calculateSwp(),
            ),
            const Divider(height: 1),
            CalcSlider(
              title: 'Expected Return',
              subtitle: 'Per annum',
              unit: '%',
              min: 0.5,
              max: 30,
              value: _swpRate,
              step: 0.5,
              onChanged: (v) => setState(() => _swpRate = v),
              onChangeEnd: (_) => _calculateSwp(),
            ),
            const Divider(height: 1),
            CalcSlider(
              title: 'Monthly Withdrawal',
              subtitle: 'Amount to withdraw each month',
              min: 500,
              max: 500000,
              value: _swpWithdrawal,
              step: 500,
              onChanged: (v) => setState(() => _swpWithdrawal = v),
              onChangeEnd: (_) => _calculateSwp(),
            ),
            const Divider(height: 1),
            CalcSlider(
              title: 'Time Period',
              subtitle: 'Duration of withdrawals',
              unit: 'Years',
              min: 1,
              max: 40,
              value: _swpYears,
              step: 1,
              onChanged: (v) => setState(() => _swpYears = v),
              onChangeEnd: (_) => _calculateSwp(),
            ),
          ]),
          if (result != null) ...[
            const SizedBox(height: 20),
            _buildSwpResultCard(result),
            const SizedBox(height: 16),
            SwpBreakdown(yearlyBreakdown: result.yearlyBreakdown),
          ],
        ],
      ),
    );
  }

  Widget _buildLumpsumTab(LumpsumResult? result) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputCard([
            CalcSlider(
              title: 'Total Investment',
              subtitle: 'Initial lump sum amount',
              min: 10000,
              max: 200000000,
                value: _lumpsumPrincipal,
                step: 50000,
              onChanged: (v) => setState(() => _lumpsumPrincipal = v),
              onChangeEnd: (_) => _calculateLumpsum(),
            ),
            const Divider(height: 1),
            CalcSlider(
              title: 'Expected Return',
              subtitle: 'Per annum',
              unit: '%',
              min: 0.5,
              max: 30,
              value: _lumpsumRate,
              step: 0.5,
              onChanged: (v) => setState(() => _lumpsumRate = v),
              onChangeEnd: (_) => _calculateLumpsum(),
            ),
            const Divider(height: 1),
            CalcSlider(
              title: 'Time Period',
              subtitle: 'Duration of investment',
              unit: 'Years',
              min: 1,
              max: 40,
              value: _lumpsumYears,
              step: 1,
              onChanged: (v) => setState(() => _lumpsumYears = v),
              onChangeEnd: (_) => _calculateLumpsum(),
            ),
          ]),
          if (result != null) ...[
            const SizedBox(height: 20),
            _buildLumpsumResultCard(result),
            const SizedBox(height: 16),
            LumpsumBreakdown(yearlyBreakdown: result.yearlyBreakdown),
          ],
        ],
      ),
    );
  }

  Widget _buildInputCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSipResultCard(SipResult result) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SIP Summary',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF002856))),
          const Divider(),
          _resultRow('Total Invested', '\u20B9 ${_currencyFormat.format(result.totalInvested)}'),
          const SizedBox(height: 8),
          _resultRow('Estimated Returns', '\u20B9 ${_currencyFormat.format(result.estimatedReturns)}',
              valueColor: Colors.green),
          const SizedBox(height: 8),
          _resultRow('Final Value', '\u20B9 ${_currencyFormat.format(result.finalValue)}',
              valueColor: const Color(0xFF002856)),
        ],
      ),
    );
  }

  Widget _buildSwpResultCard(SwpResult result) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('SWP Summary',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF002856))),
          const Divider(),
          _resultRow('Total Withdrawn', '\u20B9 ${_currencyFormat.format(result.totalWithdrawn)}'),
          const SizedBox(height: 8),
          _resultRow('Remaining Value', '\u20B9 ${_currencyFormat.format(result.remainingValue)}',
              valueColor: const Color(0xFF002856)),
          const SizedBox(height: 8),
          _resultRow('Total Returns', '\u20B9 ${_currencyFormat.format(result.totalReturns)}',
              valueColor: Colors.green),
        ],
      ),
    );
  }

  Widget _buildLumpsumResultCard(LumpsumResult result) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Lumpsum Summary',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF002856))),
          const Divider(),
          _resultRow('Total Invested', '\u20B9 ${_currencyFormat.format(result.totalInvestment)}'),
          const SizedBox(height: 8),
          _resultRow('Estimated Returns', '\u20B9 ${_currencyFormat.format(result.estimatedReturns)}',
              valueColor: Colors.green),
          const SizedBox(height: 8),
          _resultRow('Final Value', '\u20B9 ${_currencyFormat.format(result.finalValue)}',
              valueColor: const Color(0xFF002856)),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.black87)),
        Text(value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: valueColor ?? Colors.black)),
      ],
    );
  }
}
