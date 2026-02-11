import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bhansa_ghar/online/ui/feature/staff_management/presentation/widgets/staff_card.dart';
import 'package:bhansa_ghar/online/core/models/staff/staff_model.dart';

void main() {
  testWidgets('StaffCard handles long emails without overflow', (
    WidgetTester tester,
  ) async {
    // Arrange
    final staff = StaffMember(
      id: 1,
      username: 'test_user',
      email:
          'very_long_email_address_that_should_overflow_if_not_handled_correctly@example.com',
      role: 'kitchen',
      roleDisplay: 'Kitchen Staff',
      isActive: true,
    );

    // Act
    // Increase width to 400 to ensure we aren't just squeezing fixed elements too much
    // But keeps it constrained enough to require truncation.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 400,
              child: StaffCard(
                staff: staff,
                onEdit: () {},
                onToggleStatus: () {},
                onRemove: () {},
              ),
            ),
          ),
        ),
      ),
    );

    // Assert
    expect(tester.takeException(), isNull);
    expect(find.text(staff.email), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
  });
}
