import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_booking_app/main.dart';

void main() {
  testWidgets('App loads splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const HotelBookingApp());
    expect(find.text('Royal Stay'), findsOneWidget);
  });
}
