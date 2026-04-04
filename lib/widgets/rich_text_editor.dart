import 'package:flutter/material.dart';

class RichTextEditor extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final int? maxLines;
  final int? maxLength;
  final Function(String formattedText)? onChanged;

  const RichTextEditor({
    super.key,
    required this.controller,
    this.hintText = 'Write something...',
    this.maxLines,
    this.maxLength,
    this.onChanged,
  });

  @override
  State<RichTextEditor> createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  //current formatting options
  bool isBold = false;
  bool isItalic = false;
  bool isUnderline = false;
  Color textColor = Colors.black;
  double fontSize = 16.0;
  TextAlign textAlign = TextAlign.left;

  //available colors
  final List<Color> availableColors = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.teal,
  ];

  //Available font sizes
  final Map<String, double> fontSizes = {
    'Small': 14.0,
    'Normal': 16.0,
    'Large': 20.0,
    'X-Large': 24.0,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //Formatting Toolbar
        _buildFormattingToolbar(),

        const SizedBox(height: 8),

        //Text Field
        TextField(
          controller: widget.controller,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          textAlign: textAlign,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            decoration: isUnderline ? TextDecoration.underline : null,
            color: textColor,
            fontSize: fontSize,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.secondary.withOpacity(0.05),
          ),
          onChanged: (text) {
            if (widget.onChanged != null) {
              //Create formatted text with styling info
              final formattedText = _createFormattedText(text);
              widget.onChanged!(formattedText);
            }
          },
        ),
      ],
    );
  }

  //Build the formatting toolbar
  Widget _buildFormattingToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            //Bold
            _buildFormatButton(
              icon: Icons.format_bold,
              isActive: isBold,
              onTap: () => setState(() => isBold = !isBold),
              tooltip: 'Bold',
            ),

            //Italic
            _buildFormatButton(
              icon: Icons.format_italic,
              isActive: isItalic,
              onTap: () => setState(() => isItalic = !isItalic),
              tooltip: 'Italic',
            ),

            //Underline
            _buildFormatButton(
              icon: Icons.format_underline,
              isActive: isUnderline,
              onTap: () => setState(() => isUnderline = !isUnderline),
              tooltip: 'Underline',
            ),

            const VerticalDivider(width: 16),

            //Text Color
            _buildColorPicker(),

            const VerticalDivider(width: 16),

            //Font Size
            _buildFontSizePicker(),

            const VerticalDivider(width: 16),

            //Text Alignment
            _buildAlignButton(Icons.format_align_left, TextAlign.left),
            _buildAlignButton(Icons.format_align_center, TextAlign.center),
            _buildAlignButton(Icons.format_align_right, TextAlign.right),
          ],
        ),
      ),
    );
  }

  //Build a format button
  Widget _buildFormatButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.secondary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isActive
                ? Colors.white
                : Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
      ),
    );
  }

  //Build color picker
  Widget _buildColorPicker() {
    return PopupMenuButton<Color>(
      icon: Icon(
        Icons.color_lens,
        color: textColor,
      ),
      tooltip: 'Text Color',
      onSelected: (color) {
        setState(() => textColor = color);
      },
      itemBuilder: (context) => availableColors.map((color) {
        return PopupMenuItem<Color>(
          value: color,
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              if (color == textColor)
                const Icon(Icons.check, size: 20),
            ],
          ),
        );
      }).toList(),
    );
  }

  //Build font size picker
  Widget _buildFontSizePicker() {
    return PopupMenuButton<double>(
      icon: Icon(
        Icons.format_size,
        color: Theme.of(context).colorScheme.inversePrimary,
      ),
      tooltip: 'Font Size',
      onSelected: (size) {
        setState(() => fontSize = size);
      },
      itemBuilder: (context) => fontSizes.entries.map((entry) {
        return PopupMenuItem<double>(
          value: entry.value,
          child: Row(
            children: [
              Text(
                entry.key,
                style: TextStyle(fontSize: entry.value),
              ),
              const Spacer(),
              if (entry.value == fontSize)
                const Icon(Icons.check, size: 20),
            ],
          ),
        );
      }).toList(),
    );
  }

  //Build alignment button
  Widget _buildAlignButton(IconData icon, TextAlign alignment) {
    return InkWell(
      onTap: () => setState(() => textAlign = alignment),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: textAlign == alignment
              ? Theme.of(context).colorScheme.secondary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          icon,
          size: 20,
          color: textAlign == alignment
              ? Colors.white
              : Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
    );
  }

  //Create formatted text string

  String _createFormattedText(String text) {

    String formatted = text;

    //add style markers
    List<String> styles = [];

    if (isBold) styles.add('b');
    if (isItalic) styles.add('i');
    if (isUnderline) styles.add('u');

    if (textColor != Colors.black) {
      styles.add('c:${textColor.value.toRadixString(16)}');
    }

    if (fontSize != 16.0) {
      styles.add('s:$fontSize');
    }

    if (textAlign != TextAlign.left) {
      styles.add('a:${textAlign.name}');
    }

    //build formatted string
    if (styles.isNotEmpty) {
      formatted = '[${styles.join(',')}]$text[/${styles.join(',')}]';
    }

    return formatted;
  }
}