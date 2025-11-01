// News Card Widget
import 'package:flutter/material.dart';
import 'package:ramla_school/core/app/constants.dart';
import 'package:ramla_school/core/models/news_model.dart';
import 'package:ramla_school/screens/news/presentation/news_details.dart';

class NewsCardWidget extends StatelessWidget {
  final NewsModel news;

  const NewsCardWidget({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetailsScreen(news: news),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: screenBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: dividerColor),
          boxShadow: [
            BoxShadow(
              color: iconGrey.withAlpha((0.05 * 255).round()),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // News Image
            SizedBox(
              width: 80,
              height: 80,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  news.images.first,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: dividerColor,
                    child: const Icon(Icons.error, color: offlineIndicator),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: dividerColor,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),

            // News Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.category,
                    style: const TextStyle(
                      color: chartOrange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    news.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? validatorMsg;
  final bool isPassword;
  final bool isConfirm;
  final bool isDropdown;
  final TextInputType keyboardType;
  final String? Function(String?)? extraValidator;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.validatorMsg,
    this.isPassword = false,
    this.isConfirm = false,
    this.isDropdown = false,
    this.keyboardType = TextInputType.text,
    this.extraValidator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      decoration: _buildInputDecoration(),
      validator: (value) {
        if (widget.validatorMsg != null && (value == null || value.isEmpty)) {
          return widget.validatorMsg;
        }
        if (widget.extraValidator != null) return widget.extraValidator!(value);
        return null;
      },
    );
  }

  InputDecoration _buildInputDecoration() {
    return InputDecoration(
      hintText: widget.hint,
      hintStyle: const TextStyle(color: iconGrey),
      filled: true,
      fillColor: textFieldFill,
      prefixIcon: widget.isDropdown ? null : Icon(widget.icon, color: iconGrey),
      suffixIcon: widget.isPassword
          ? IconButton(
              icon: Icon(
                _obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: iconGrey,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            )
          : (widget.isDropdown ? Icon(widget.icon, color: iconGrey) : null),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: onlineIndicator),
      ),
    );
  }
}
