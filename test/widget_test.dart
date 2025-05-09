import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_api/main.dart';

void main() {
  testWidgets('Dashboard UI test', (WidgetTester tester) async {
    // Build the app.
    await tester.pumpWidget(const MyApp());

    // Verifica se o título da AppBar está presente.
    expect(find.text('📊 Últimos Dados do Sistema'), findsOneWidget);

    // Verifica se o CircularProgressIndicator aparece antes dos dados carregarem.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
