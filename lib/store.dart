import 'package:shared_preferences/shared_preferences.dart';

/*
 A conversation credit will be used for every message sent to the assistant.
 1,000 credits will be given to the user for $0.99.
 1 credit = $0.00099

 A liberal estimate for a conversation credit is 100 words or ~120 tokens
 3.5-turbo 4k context is $0.002 for 1,000 tokens
 1 token = $0.000002

 1 credit = 1 message = 120 tokens

 120 tokens = $0.00024 API cost
 120 tokens = $0.00099 revenue
 120 tokens = $0.00075 profit

 1,000 messages = $0.75 profit
 https://docs.google.com/spreadsheets/d/12oWl-ih9atDBBdGrNR8bv7Jv2igbvBNSDnNHiK9fEkY/edit#gid=0
*/

class Store {
  static Future<int> getConversationCredits() async {
    final perfs = await SharedPreferences.getInstance();
    return perfs.getInt('conversationCredits') ?? 0;
  }

  static void spendConversaionCredits(int numCredits) async {
    print("Spending $numCredits credits");
    final perfs = await SharedPreferences.getInstance();
    int currentCredits = perfs.getInt('conversationCredits') ?? 0;
    int newCredits = currentCredits - numCredits;
    await perfs.setInt('conversationCredits', newCredits);
  }

  static Future<bool> firstTimeOpeningApp() async {
    final perfs = await SharedPreferences.getInstance();
    bool first = perfs.getBool('firstTimeOpeningApp') ?? true;
    if (first) {
      await perfs.setBool('firstTimeOpeningApp', false);
    }
    print("First time opening app: $first");
    return first;
  }

  static void addCredits(int numCredits) async {
    final perfs = await SharedPreferences.getInstance();
    int currentCredits = perfs.getInt('conversationCredits') ?? 0;
    int newCredits = currentCredits + numCredits;
    print("Adding $numCredits credits. New total: $newCredits");
    await perfs.setInt('conversationCredits', newCredits);
  }

  static void setPersonalOpenAIKey(String key) async {
    final perfs = await SharedPreferences.getInstance();
    await perfs.setString('personalOpenAIKey', key);
  }

  static Future<String> getPersonalOpenAIKey() async {
    final perfs = await SharedPreferences.getInstance();
    String personalOpenAIKey = perfs.getString('personalOpenAIKey') ?? '';
    return personalOpenAIKey;
  }
}
