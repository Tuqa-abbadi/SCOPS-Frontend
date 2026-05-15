import 'package:flutter_test/flutter_test.dart';
import 'package:scops_frontend/main.dart';
import 'package:scops_frontend/repositories/auth_repository.dart';

class FakeAuthRepository extends AuthRepository {
  @override
  Future<bool> isLoggedIn() async => false;
}

void main() {
  testWidgets('SCOPS app builds', (WidgetTester tester) async {
    await tester.pumpWidget(
      ScopsApp(authRepository: FakeAuthRepository()),
    );

    expect(find.byType(ScopsApp), findsOneWidget);
  });
}
