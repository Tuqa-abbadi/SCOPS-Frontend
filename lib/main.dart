import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/auth/auth_bloc.dart';
import 'blocs/dashboard/dashboard_bloc.dart';
import 'blocs/onboarding/onboarding_bloc.dart';
import 'blocs/services/services_bloc.dart';
import 'blocs/splash/splash_bloc.dart';
import 'blocs/subscription/subscription_bloc.dart';
import 'blocs/wallet/wallet_bloc.dart';
import 'core/network/dio_client.dart';
import 'repositories/auth_repository.dart';
import 'screens/splash/splash_screen.dart';
import 'services/token_storage_service.dart';

const String _baseUrl = 'https://6d16cb53-a851-4863-a1b3-d08fdd92c9be.mock.pstmn.io';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStorage = TokenStorageService();
  DioClient.init(baseUrl: _baseUrl, tokenStorage: tokenStorage);
  final authRepository = AuthRepository(tokenStorage: tokenStorage);

  runApp(ScopsApp(authRepository: authRepository));
}

class ScopsApp extends StatelessWidget {
  const ScopsApp({super.key, required this.authRepository});

  final AuthRepository authRepository;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SplashBloc>(
          create: (_) => SplashBloc(authRepository: authRepository),
        ),
        BlocProvider<OnboardingBloc>(create: (_) => OnboardingBloc()),
        BlocProvider<LoginBloc>(
          create: (_) => LoginBloc(authRepository: authRepository),
        ),
        BlocProvider<SignupBloc>(
          create: (_) => SignupBloc(authRepository: authRepository),
        ),
        BlocProvider<DashboardBloc>(create: (_) => DashboardBloc()),
        BlocProvider<ServicesBloc>(create: (_) => ServicesBloc()),
        BlocProvider<WalletBloc>(
          create: (_) => WalletBloc()..add(const WalletLoaded()),
        ),
        BlocProvider<SubscriptionBloc>(
          create: (_) => SubscriptionBloc()..add(const SubscriptionLoaded()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SCOPS',
        theme: ThemeData(useMaterial3: true),
        home: const SplashScreen(),
      ),
    );
  }
}