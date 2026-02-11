import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spinning_wheel/app.dart';

void main() {
  testWidgets('app boots and shows wheel tab', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ProviderScope(child: SpinMasterApp()));

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('SPIN'), findsOneWidget);
    expect(find.text('Wheel'), findsOneWidget);
  });
}
