import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CalcSlider extends StatefulWidget {
  final String title;
  final String subtitle;
  final String unit;
  final double min;
  final double max;
  final double value;
  final double step;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;

  const CalcSlider({
    super.key,
    required this.title,
    this.subtitle = '',
    this.unit = '',
    required this.min,
    required this.max,
    required this.value,
    required this.step,
    required this.onChanged,
    this.onChangeEnd,
  });

  @override
  State<CalcSlider> createState() => _CalcSliderState();
}

class _CalcSliderState extends State<CalcSlider> {
  late final TextEditingController _controller;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _formatValue(widget.value),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CalcSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.text = _formatValue(widget.value);
    }
  }

  bool get _isCurrency => widget.unit.isEmpty;

  String _formatValue(double value) {
    if (_isCurrency) {
      return NumberFormat.decimalPattern('en_IN').format(value.round());
    }
    return value.toStringAsFixed(widget.unit == '%' ? 1 : 0);
  }

  double _parseValue(String text) {
    if (_isCurrency) {
      return NumberFormat.decimalPattern('en_IN').parse(text).toDouble().roundToDouble();
    }
    return double.tryParse(text) ?? widget.value;
  }

  void _handleChanged(String value) {
    final parsed = double.tryParse(value.replaceAll(',', ''));
    setState(() {
      if (parsed == null) {
        _errorMessage = null;
      } else if (parsed > widget.max) {
        _errorMessage = 'Exceeding limits';
      } else if (parsed < widget.min) {
        _errorMessage = 'Lower than minimum';
      } else {
        _errorMessage = null;
      }
    });
  }

  void _handleEditComplete() {
    if (_errorMessage != null) return;
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    try {
      var number = _parseValue(text);
      if (_isCurrency) number = number.roundToDouble();
      final clamped = number.clamp(widget.min, widget.max);
      final stepped = (clamped / widget.step).round() * widget.step;
      final finalValue = stepped.clamp(widget.min, widget.max);
      widget.onChanged(finalValue);
      widget.onChangeEnd?.call(finalValue);
      _controller.text = _formatValue(finalValue);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (widget.subtitle.isNotEmpty)
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                height: 45,
                width: _isCurrency ? 150 : 100,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9DCE5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFB8BEC9),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    if (_isCurrency)
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Text(
                          '\u20B9',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2B3548),
                          ),
                        ),
                      ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        keyboardType: const TextInputType.numberWithOptions(),
                        inputFormatters: _isCurrency
                            ? [FilteringTextInputFormatter.allow(RegExp(r'[\d]'))]
                            : [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2D3D),
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isCollapsed: true,
                        ),
                        onChanged: _handleChanged,
                        onTapOutside: (_) {
                          FocusManager.instance.primaryFocus?.unfocus();
                          _handleEditComplete();
                        },
                        onEditingComplete: () {
                          _handleEditComplete();
                        },
                        onSubmitted: (_) {
                          _handleEditComplete();
                        },
                      ),
                    ),
                    if (!_isCurrency)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          widget.unit,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2B3548),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Color(0xFFE32517),
                  fontSize: 10,
                ),
              ),
            ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF002856),
              thumbColor: const Color(0xFF002856),
              inactiveTrackColor: Colors.grey[300],
              overlayColor: const Color(0xFF002856).withValues(alpha: 0.12),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              min: widget.min,
              max: widget.max,
              value: widget.value.clamp(widget.min, widget.max),
              divisions: ((widget.max - widget.min) / widget.step).round().clamp(1, 100000),
              onChanged: widget.onChanged,
              onChangeEnd: widget.onChangeEnd ?? (_) {},
            ),
          ),
        ],
      ),
    );
  }
}
