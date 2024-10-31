import 'package:scream_mobile/storage/profile_storage.dart';
import 'package:scream_mobile/storage/question_storage.dart';

import '../rest/streaming_completion.dart';
import '../storage/message_storage.dart';

class Prompts {
  static const ThinkOfSomethingToSaySystemPromt = '''
  You generate a conversation starter, responding only with the first sentence 
  of a conversation based on the user's input.
  ''';

  static const ThinkOfSomethingToSayUserPrompt = '''
  Think of something to say. Make it a single question or statement.
  ''';

  static const DefaultSystemPrompt = '''
  You are a friendly voice assistant providing very brief responses. Prioritize generating responses that are 
  conversational in tone and concise in length. Do not provide lists or markdown in the response.
  Be concise when being conversational, only elaborating when you are asked an in-depth 
  question. Be extremely brief, trying to match the length of the user's input. Start each sentence with the word "Flower".
  ''';

  static const UpdateProfileSystemPrompt = '''You generate a JSON structured user profile''';

  static Future<String> buildUpdateProfilePrompt() async {
    List<String> recentlyAskedQuestions = await QuestionStorage.getAskedQuestions();
    List<String> questionsInQueue = await QuestionStorage.getQuestions();
    UserProfile profile = await ProfileStorage.getProfile() ?? UserProfile.empty();
    List<Message> chatHistory = await MessageStorage.getMessagesSinceLastProfileUpdate();

    String chatHistoryString = chatHistory.map((e) => "${e.role}: ${e.content}").join('\n');
    String profileString = profile.toString();
    String alreadyGeneratedQuestions = "${recentlyAskedQuestions.join(', ')}, ${questionsInQueue.join(', ')}";

    return '''
      Think deeply about the provided chat history. Use this to update the profile for the user who the chat history belongs to. The profile has a number of fields that can be updated. Here is a description of each field:
      * Name: The user's name
      * Interests: This captures the users hobbies, passions, or topics they enjoy discussing.
      * Goals: This captures the user's goals, both short term and long term.
      * Events: This captures events the user has planned for the future. This could be one off events or recurring events. Include information about when the event is, who is attending, and what the event is. Remove events that have already happened.
      
      Condense any parts of these items that seem to be related.
      As well as updating the profile, generate 5 short, engaging questions to start a conversation. These should be based on the chat history and the current profile. Some of the questions should help clarify and expand the user profile. One of the questions should be fun! Do not repeat any recent questions.
      
      Current Profile:
      $profileString
      
      Chat History:
      $chatHistoryString
      
      Already Generated Questions: $alreadyGeneratedQuestions
    ''';
  }
}
