import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sip_swp_calc/logic/swp_calculator.dart';

class SwpBreakdown extends StatelessWidget {
  final List<SwpYearRow> yearlyBreakdown;

  const SwpBreakdown({super.key, required this.yearlyBreakdown});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Year-wise Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF002856),
            ),
          ),
          const SizedBox(height: 12),
          Table(
            border: TableBorder(
              horizontalInside: BorderSide(color: Colors.grey.shade200, width: 0.5),
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
            defaultColumnWidth: const FlexColumnWidth(),
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFF002856)),
                children: [
                  _headerCell('Year'),
                  _headerCell('Withdrawn'),
                  _headerCell('Balance'),
                ],
              ),
              ...yearlyBreakdown.map((row) {
                final prevIndex = yearlyBreakdown.indexOf(row) - 1;
                final yearlyWithdrawn = prevIndex >= 0
                    ? row.withdrawn - yearlyBreakdown[prevIndex].withdrawn
                    : row.withdrawn;
                final isEven = yearlyBreakdown.indexOf(row).isEven;
                return TableRow(
                  decoration: BoxDecoration(
                    color: isEven ? Colors.grey[50] : Colors.white,
                  ),
                  children: [
                    _dataCell('${row.year}'),
                    _dataCell('\u20B9${NumberFormat.decimalPattern('en_IN').format(yearlyWithdrawn.round())}'),
                    _dataCell(
                      '\u20B9${NumberFormat.decimalPattern('en_IN').format(row.value.round())}',
                      style: TextStyle(
                        color: row.value > 0 ? const Color(0xFF002856) : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _dataCell(String text, {TextStyle? style}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: style ?? const TextStyle(fontSize: 13),
      ),
    );
  }
}
