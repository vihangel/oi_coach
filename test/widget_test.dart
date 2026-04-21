import 'package:flutter_test/flutter_test.dart';
import 'package:oi_coach/app/app.dart';

void main() {
  testWidgets('App renders', (tester) async {
    await tester.pumpWidget(const ApexApp());
    await tester.pumpAndSettle();
    // Verify the app renders with the bottom navigation tabs
    expect(find.text('HOJE'), findsOneWidget);
  });
}
