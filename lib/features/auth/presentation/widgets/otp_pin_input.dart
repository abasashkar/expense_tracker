import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:expense_tracker/core/theme/app_theme.dart';

class OtpPinInput extends StatefulWidget {
  const OtpPinInput({
    super.key,
    required this.onCompleted,
    this.length = 6,
    this.enabled = true,
  });

  final ValueChanged<String> onCompleted;
  final int length;
  final bool enabled;

  @override
  State<OtpPinInput> createState() => OtpPinInputState();
}

class OtpPinInputState extends State<OtpPinInput> {
  static const double _gap = 8;
  static const double _maxBoxWidth = 54;

  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  String get value => _controller.text;

  void clear() {
    _controller.clear();
    setState(() {});
  }

  void requestFocus() => _focusNode.requestFocus();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final code = _controller.text;
    final activeIndex =
        code.length < widget.length ? code.length : widget.length - 1;
    final isFocused = _focusNode.hasFocus;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final fittedWidth =
            (maxWidth - _gap * (widget.length - 1)) / widget.length;
        final boxWidth =
            fittedWidth > _maxBoxWidth ? _maxBoxWidth : fittedWidth;
        final boxHeight = boxWidth * 1.12;
        final digitFontSize = boxWidth * 0.48;
        final placeholderFontSize = boxWidth * 0.36;

        return GestureDetector(
          onTap: widget.enabled ? () => _focusNode.requestFocus() : null,
          behavior: HitTestBehavior.opaque,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: boxHeight,
                width: maxWidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.length, (index) {
                    final char = index < code.length ? code[index] : '';
                    final filled = char.isNotEmpty;
                    final isActive =
                        isFocused && index == activeIndex && !filled;

                    return Padding(
                      padding: EdgeInsets.only(
                        left: index == 0 ? 0 : _gap,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        width: boxWidth,
                        height: boxHeight,
                        decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isActive
                              ? AppTheme.primary
                              : filled
                                  ? AppTheme.primary.withValues(alpha: 0.35)
                                  : AppTheme.cardBorder,
                          width: isActive ? 2 : 1,
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color:
                                      AppTheme.primary.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                        ),
                        child: Center(
                          child: filled
                              ? Text(
                                  char,
                                  style: TextStyle(
                                    fontSize: digitFontSize,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textPrimary,
                                    height: 1,
                                  ),
                                )
                              : Text(
                                  '–',
                                  style: TextStyle(
                                    fontSize: placeholderFontSize,
                                    fontWeight: FontWeight.w400,
                                    color: AppTheme.textSecondary
                                        .withValues(alpha: 0.35),
                                    height: 1,
                                  ),
                                ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Offstage(
                child: SizedBox(
                  width: 1,
                  height: 1,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    enabled: widget.enabled,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    maxLength: widget.length,
                    autofocus: true,
                    autocorrect: false,
                    enableSuggestions: false,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style:
                        const TextStyle(fontSize: 1, color: Colors.transparent),
                    decoration: const InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {});
                      if (value.length == widget.length) {
                        widget.onCompleted(value);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
