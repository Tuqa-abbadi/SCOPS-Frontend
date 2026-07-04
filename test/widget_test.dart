import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scops_frontend/main.dart';
import 'package:scops_frontend/core/theme/theme_controller.dart';
import 'package:scops_frontend/repositories/auth_repository.dart';
import 'package:scops_frontend/services/auth_api_service.dart';

class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository() : super(authApiService: AuthApiService(dio: Dio()));

  @override
  Future<bool> isLoggedIn() async => false;
}

void main() {
  testWidgets('SCOPS app builds', (WidgetTester tester) async {
    await tester.pumpWidget(
      ScopsApp(
        authRepository: FakeAuthRepository(),
        themeController: ThemeController(),
      ),
    );
    await tester.pump(const Duration(seconds: 13));
    await tester.pump(const Duration(seconds: 4));

    expect(find.byType(ScopsApp), findsOneWidget);
  });
}
