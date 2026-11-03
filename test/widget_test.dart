import 'package:flutter_test/flutter_test.dart';
import 'package:labexam/main.dart';

void main() {
  testWidgets('Stock Inventory Manager displays the entry page',
          (WidgetTester tester) async {
        await tester.pumpWidget(const StockManagerApp());

        expect(find.text('Stock Inventory Manager'), findsOneWidget);
        expect(find.text('Add Stock Item'), findsOneWidget);
        expect(find.text('Save Stock Item'), findsOneWidget);
      });
}