import 'package:flutter_test/flutter_test.dart';
import 'package:wheresmymoney_old_nav/Layout/main.dart';

void main(){

  testWidgets('HomePage shows', (WidgetTester tester) async{
    await tester.pumpWidget(new MyApp());

    expect(find.text('Your balance: '), findsNothing);
    expect(find.text('Your balance'), findsNothing);
  });
}