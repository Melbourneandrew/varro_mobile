import 'dart:io';
import 'dart:math';
bool isRunningInSimulator() {
  return Platform.isIOS || Platform.isAndroid;
}

final List<String> subjects = ['I', 'You', 'They', 'We', 'She', 'He'];
final List<String> verbs = ['run', 'jump', 'eat', 'sleep', 'dance', 'sing'];
final List<String> adverbs = ['quickly', 'slowly', 'happily', 'loudly', 'quietly'];
final List<String> adjectives = ['happy', 'sad', 'colorful', 'tall', 'short', 'beautiful'];
final List<String> objects = ['dog', 'cat', 'car', 'tree', 'flower', 'star'];

String generateRandomSentence({int numSentences = 1}) {
  String text = '';
  for(int i = 0; i < numSentences; i++){
    String subject = subjects[Random().nextInt(subjects.length)];
    String verb = verbs[Random().nextInt(verbs.length)];
    String adverb = adverbs[Random().nextInt(adverbs.length)];
    String adjective = adjectives[Random().nextInt(adjectives.length)];
    String object = objects[Random().nextInt(objects.length)];
    text += '$subject $verb $adverb with $adjective $object. ';
  }
  return text;
}