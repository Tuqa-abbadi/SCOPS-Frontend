import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'blocs/admin/admin_bloc.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/dashboard/dashboard_bloc.dart';
import 'blocs/payment/payment_bloc.dart';
import 'blocs/reviews/reviews_bloc.dart';
import 'blocs/user/user_cubit.dart';
import 'blocs/onboarding/onboarding_bloc.dart';
import 'blocs/services/services_bloc.dart';
import 'blocs/splash/splash_bloc.dart';
import 'blocs/subscription/subscription_bloc.dart';
import 'blocs/wallet/wallet_bloc.dart';
import 'core/config/app_config.dart';
import 'core/constants/api_constants.dart';
import 'core/network/dio_client.dart';
import 'core/theme/app_theme.dart';
import 'blocs/profile/change_password_bloc.dart';
import 'repositories/auth_repository.dart';
import 'repositories/profile_repository.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'services/token_storage_service.dart';

const bool designMode = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Stripe must be initialised before the widget tree is built.
  Stripe.publishableKey = AppConfig.stripePublishableKey;
  await Stripe.instance.applySettings();

  final tokenStorage = TokenStorageService();
  DioClient.init(baseUrl: ApiConstants.baseUrl, tokenStorage: tokenStorage);
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
        BlocProvider<UserCubit>(
          create: (_) => UserCubit(authRepository: authRepository)..loadUser(),
        ),
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
        BlocProvider<ForgotPasswordBloc>(
          create: (_) => ForgotPasswordBloc(authRepository: authRepository),
        ),
        BlocProvider<LogoutBloc>(
          create: (_) => LogoutBloc(authRepository: authRepository),
        ),
        BlocProvider<ChangePasswordBloc>(
          create: (_) =>
              ChangePasswordBloc(profileRepository: ProfileRepository()),
        ),
        BlocProvider<DashboardBloc>(create: (_) => DashboardBloc()),
        BlocProvider<ServicesBloc>(create: (_) => ServicesBloc()),
        BlocProvider<WalletBloc>(create: (_) => WalletBloc()),
        BlocProvider<SubscriptionBloc>(
          create: (_) => SubscriptionBloc(),
        ),
        BlocProvider<PaymentBloc>(
          create: (_) => PaymentBloc(),
        ),
        BlocProvider<ReviewsBloc>(
          create: (_) => ReviewsBloc(),
        ),
        BlocProvider<AdminBloc>(
          create: (_) => AdminBloc(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SCOPS',
        theme: AppTheme.darkTheme,
        home: designMode ? const DashboardScreen() : const SplashScreen(),
      ),
    );
  }
}
