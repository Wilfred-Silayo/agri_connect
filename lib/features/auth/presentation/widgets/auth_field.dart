import 'package:flutter/material.dart';

class AuthField extends StatefulWidget {
  final String hinttext;
  final TextEditingController controler;
  final bool isObscureText;
  final String? Function(String?)? validator;

  const AuthField({
    super.key,
    required this.hinttext,
    required this.controler,
    this.isObscureText = false,
    this.validator,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.isObscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controler,
      obscureText: _obscure,
      decoration: InputDecoration(
        hintText: widget.hinttext,
        suffixIcon:
            widget.isObscureText
                ? IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscure = !_obscure;
                    });
                  },
                )
                : null,
      ),
      validator: widget.validator ?? (value) {
        if (value!.isEmpty) {
          return "${widget.hinttext} is missing!";
        }
        return null;
      },
    );
  }
}
