import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

//FORMATTED TEXT DISPLAY
//Displays text with rich formatting
//Supports: Bold, Italic, Underline, Colors, Sizes, Mentions, Hashtags

class FormattedTextDisplay extends StatelessWidget {
  final String text;
  final TextStyle? baseStyle;
  final int? maxLines;
  final TextOverflow? overflow;
  final Function(String)? onMentionTap;
  final Function(String)? onHashtagTap;

  const FormattedTextDisplay({
    super.key,
    required this.text,
    this.baseStyle,
    this.maxLines,
    this.overflow,
    this.onMentionTap,
    this.onHashtagTap,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: _parseText(context),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }

  //Parse text and apply formatting
  TextSpan _parseText(BuildContext context) {
    //Check if text has formatting tags
    if (text.contains('[') && text.contains(']')) {
      return _parseFormattedText(context);
    } else {
      // Parse for mentions and hashtags only
      return _parseSimpleText(context);
    }
  }

  //Parse text with formatting tags
  TextSpan _parseFormattedText(BuildContext context) {
    //Extract formatting info
    final regex = RegExp(r'\[(.*?)\](.*?)\[/.*?\]');
    final match = regex.firstMatch(text);

    if (match == null) {
      return _parseSimpleText(context);
    }

    final styles = match.group(1)?.split(',') ?? [];
    final content = match.group(2) ?? text;

    // Apply styles
    TextStyle style = baseStyle ?? const TextStyle();

    for (var styleTag in styles) {
      if (styleTag == 'b') {
        style = style.copyWith(fontWeight: FontWeight.bold);
      } else if (styleTag == 'i') {
        style = style.copyWith(fontStyle: FontStyle.italic);
      } else if (styleTag == 'u') {
        style = style.copyWith(decoration: TextDecoration.underline);
      } else if (styleTag.startsWith('c:')) {
        final colorHex = styleTag.substring(2);
        final color = Color(int.parse(colorHex, radix: 16));
        style = style.copyWith(color: color);
      } else if (styleTag.startsWith('s:')) {
        final size = double.parse(styleTag.substring(2));
        style = style.copyWith(fontSize: size);
      }
    }

    return TextSpan(
      text: content,
      style: style,
    );
  }

  //Parse simple text (detect mentions and hashtags)
  TextSpan _parseSimpleText(BuildContext context) {
    final List<TextSpan> spans = [];
    final words = text.split(' ');

    for (int i = 0; i < words.length; i++) {
      final word = words[i];

      if (word.startsWith('@')) {
        //Mention
        spans.add(TextSpan(
          text: word,
          style: (baseStyle ?? const TextStyle()).copyWith(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              if (onMentionTap != null) {
                onMentionTap!(word.substring(1));
              }
            },
        ));
      } else if (word.startsWith('#')) {
        //Hashtag
        spans.add(TextSpan(
          text: word,
          style: (baseStyle ?? const TextStyle()).copyWith(
            color: Colors.blue,
            fontWeight: FontWeight.w600,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              if (onHashtagTap != null) {
                onHashtagTap!(word.substring(1));
              }
            },
        ));
      } else {
        //Normal text
        spans.add(TextSpan(
          text: word,
          style: baseStyle,
        ));
      }

      //Add space between words (except last word)
      if (i < words.length - 1) {
        spans.add(TextSpan(text: ' ', style: baseStyle));
      }
    }

    return TextSpan(children: spans);
  }
}
