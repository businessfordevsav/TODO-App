import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/environment_config.dart';
import 'core/error/error_handler.dart';
import 'core/security/security_service.dart';
import 'data/local/database_service.dart';
import 'data/remote/todo_api_service.dart';
import 'data/repositories/todo_repository.dart';
import 'providers/todo_provider.dart';
import 'presentation/screens/todo_list_screen.dart';
import 'presentation/screens/security_blocked_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GlobalErrorHandler.initialize();
  await EnvironmentConfig.initialize();

  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SecurityCheckResult?>(
      future: _performSecurityCheck(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        if (snapshot.hasError) {
          return GlobalErrorHandler.buildErrorPage(
            FlutterErrorDetails(exception: snapshot.error!),
          );
        }

        final securityResult = snapshot.data;
        if (securityResult != null && !securityResult.isSecure) {
          return SecurityBlockedScreen(message: securityResult.message);
        }

        return _buildApp();
      },
    );
  }

  Future<SecurityCheckResult?> _performSecurityCheck() async {
    // Only check security in production
    if (EnvironmentConfig.isProduction) {
      final securityService = SecurityService();
      return await securityService.performSecurityCheck();
    }
    return null;
  }

  Widget _buildApp() {
    return MultiProvider(
      providers: [
        Provider<DatabaseService>(create: (_) => DatabaseService()),
        Provider<TodoApiService>(create: (_) => TodoApiService()),
        ProxyProvider2<TodoApiService, DatabaseService, TodoRepository>(
          update: (_, api, db, __) =>
              TodoRepository(apiService: api, dbService: db),
        ),
        ChangeNotifierProxyProvider<TodoRepository, TodoProvider>(
          create: (context) => TodoProvider(context.read<TodoRepository>()),
          update: (_, repo, provider) => provider ?? TodoProvider(repo),
        ),
      ],
      child: MaterialApp(
        title: EnvironmentConfig.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const TodoListScreen(),
      ),
    );
  }
}
