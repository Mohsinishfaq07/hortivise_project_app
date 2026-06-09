// Developed By Muhammad Waleed.. Senior Android and Flutter developer..
// waleedkalyar48@gmail.com/

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:horti_vige/ui/utils/extensions/extensions.dart';

class LoadingButton extends StatefulWidget {
  const LoadingButton({super.key, required this.onPressed, required this.text});
  final Future Function()? onPressed;
  final String text;

  @override
  _LoadingButtonState createState() => _LoadingButtonState();
}

class _LoadingButtonState extends State<LoadingButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed:
                (_isLoading || widget.onPressed == null) ? null : _loadFuture,
            child: _isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : Text(widget.text),
          ),
        ),
      ],
    );
  }

  Future<void> _loadFuture() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onPressed!();
    } catch (e, s) {
      log(e.toString(), error: e, stackTrace: s);
      showAppToast(
        'Error $e',
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
      rethrow;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
