// Copyright 2026 João Victor das Neves Sousa Almeida
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'brand/centavinhos_logo.dart';

/// Põe as licenças das fontes na tela de licenças. As dos pacotes entram
/// sozinhas; as das fontes não, porque elas vêm como arquivos do app.
void registrarLicencasDasFontes() {
  LicenseRegistry.addLicense(() async* {
    final libron = await rootBundle.loadString('assets/fonts/OFL-Libron.txt');
    yield LicenseEntryWithLineBreaks(['Fonte Libron'], libron);
    final roboto = await rootBundle.loadString('assets/fonts/OFL-RobotoFlex.txt');
    yield LicenseEntryWithLineBreaks(['Fonte Roboto Flex'], roboto);
  });
}

/// Tela de licenças: a do Centavinhos no topo, depois as fontes e os pacotes.
void abrirLicencas(BuildContext context) => showLicensePage(
  context: context,
  applicationName: 'Centavinhos',
  applicationIcon: const CentavinhosLogo(size: 64),
  applicationLegalese:
      '© 2026 João Victor das Neves Sousa Almeida\n'
      'Licenciado sob a Apache License 2.0',
);
