// Copyright 2026 João Victor das Neves Sousa Almeida
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import 'ui/app.dart';
import 'ui/licencas.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'pt_BR';
  await initializeDateFormatting('pt_BR');
  registrarLicencasDasFontes();
  runApp(const ProviderScope(child: CentavinhosApp()));
}
