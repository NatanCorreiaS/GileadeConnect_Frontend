import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gileade_frontend/app.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: '.env');
  });

  testWidgets('Home mostra botoes principais', (WidgetTester tester) async {
    await tester.pumpWidget(const GileadeApp());
    await tester.pump();

    expect(find.text('ENTRAR'), findsOneWidget);
    expect(find.text('CADASTRAR'), findsOneWidget);
  });
}
