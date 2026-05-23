import 'dart:js' as js;

Future<void> puterSpeak(String text) async {
  try {
    js.context.callMethod('puterTTS', [text]);
  } catch (_) {}
}
