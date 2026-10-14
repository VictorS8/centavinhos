// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class Contas extends Table with TableInfo<Contas, Conta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Contas(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (tipo IN (\'carteira\', \'banco\'))',
  );
  static const VerificationMeta _saldoInicialCentavosMeta =
      const VerificationMeta('saldoInicialCentavos');
  late final GeneratedColumn<int> saldoInicialCentavos = GeneratedColumn<int>(
    'saldo_inicial_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _dataSaldoInicialMeta = const VerificationMeta(
    'dataSaldoInicial',
  );
  late final GeneratedColumn<String> dataSaldoInicial = GeneratedColumn<String>(
    'data_saldo_inicial',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _arquivadaMeta = const VerificationMeta(
    'arquivada',
  );
  late final GeneratedColumn<int> arquivada = GeneratedColumn<int>(
    'arquivada',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nome,
    tipo,
    saldoInicialCentavos,
    dataSaldoInicial,
    arquivada,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Conta> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('saldo_inicial_centavos')) {
      context.handle(
        _saldoInicialCentavosMeta,
        saldoInicialCentavos.isAcceptableOrUnknown(
          data['saldo_inicial_centavos']!,
          _saldoInicialCentavosMeta,
        ),
      );
    }
    if (data.containsKey('data_saldo_inicial')) {
      context.handle(
        _dataSaldoInicialMeta,
        dataSaldoInicial.isAcceptableOrUnknown(
          data['data_saldo_inicial']!,
          _dataSaldoInicialMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataSaldoInicialMeta);
    }
    if (data.containsKey('arquivada')) {
      context.handle(
        _arquivadaMeta,
        arquivada.isAcceptableOrUnknown(data['arquivada']!, _arquivadaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Conta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Conta(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      saldoInicialCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}saldo_inicial_centavos'],
      )!,
      dataSaldoInicial: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_saldo_inicial'],
      )!,
      arquivada: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}arquivada'],
      )!,
    );
  }

  @override
  Contas createAlias(String alias) {
    return Contas(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Conta extends DataClass implements Insertable<Conta> {
  final int id;
  final String nome;
  final String tipo;
  final int saldoInicialCentavos;
  final String dataSaldoInicial;

  /// AAAA-MM-DD, dia em que começou a usar o app
  final int arquivada;
  const Conta({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.saldoInicialCentavos,
    required this.dataSaldoInicial,
    required this.arquivada,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    map['tipo'] = Variable<String>(tipo);
    map['saldo_inicial_centavos'] = Variable<int>(saldoInicialCentavos);
    map['data_saldo_inicial'] = Variable<String>(dataSaldoInicial);
    map['arquivada'] = Variable<int>(arquivada);
    return map;
  }

  ContasCompanion toCompanion(bool nullToAbsent) {
    return ContasCompanion(
      id: Value(id),
      nome: Value(nome),
      tipo: Value(tipo),
      saldoInicialCentavos: Value(saldoInicialCentavos),
      dataSaldoInicial: Value(dataSaldoInicial),
      arquivada: Value(arquivada),
    );
  }

  factory Conta.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Conta(
      id: serializer.fromJson<int>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      tipo: serializer.fromJson<String>(json['tipo']),
      saldoInicialCentavos: serializer.fromJson<int>(
        json['saldo_inicial_centavos'],
      ),
      dataSaldoInicial: serializer.fromJson<String>(json['data_saldo_inicial']),
      arquivada: serializer.fromJson<int>(json['arquivada']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nome': serializer.toJson<String>(nome),
      'tipo': serializer.toJson<String>(tipo),
      'saldo_inicial_centavos': serializer.toJson<int>(saldoInicialCentavos),
      'data_saldo_inicial': serializer.toJson<String>(dataSaldoInicial),
      'arquivada': serializer.toJson<int>(arquivada),
    };
  }

  Conta copyWith({
    int? id,
    String? nome,
    String? tipo,
    int? saldoInicialCentavos,
    String? dataSaldoInicial,
    int? arquivada,
  }) => Conta(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    tipo: tipo ?? this.tipo,
    saldoInicialCentavos: saldoInicialCentavos ?? this.saldoInicialCentavos,
    dataSaldoInicial: dataSaldoInicial ?? this.dataSaldoInicial,
    arquivada: arquivada ?? this.arquivada,
  );
  Conta copyWithCompanion(ContasCompanion data) {
    return Conta(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      saldoInicialCentavos: data.saldoInicialCentavos.present
          ? data.saldoInicialCentavos.value
          : this.saldoInicialCentavos,
      dataSaldoInicial: data.dataSaldoInicial.present
          ? data.dataSaldoInicial.value
          : this.dataSaldoInicial,
      arquivada: data.arquivada.present ? data.arquivada.value : this.arquivada,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Conta(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('tipo: $tipo, ')
          ..write('saldoInicialCentavos: $saldoInicialCentavos, ')
          ..write('dataSaldoInicial: $dataSaldoInicial, ')
          ..write('arquivada: $arquivada')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nome,
    tipo,
    saldoInicialCentavos,
    dataSaldoInicial,
    arquivada,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Conta &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.tipo == this.tipo &&
          other.saldoInicialCentavos == this.saldoInicialCentavos &&
          other.dataSaldoInicial == this.dataSaldoInicial &&
          other.arquivada == this.arquivada);
}

class ContasCompanion extends UpdateCompanion<Conta> {
  final Value<int> id;
  final Value<String> nome;
  final Value<String> tipo;
  final Value<int> saldoInicialCentavos;
  final Value<String> dataSaldoInicial;
  final Value<int> arquivada;
  const ContasCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.tipo = const Value.absent(),
    this.saldoInicialCentavos = const Value.absent(),
    this.dataSaldoInicial = const Value.absent(),
    this.arquivada = const Value.absent(),
  });
  ContasCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
    required String tipo,
    this.saldoInicialCentavos = const Value.absent(),
    required String dataSaldoInicial,
    this.arquivada = const Value.absent(),
  }) : nome = Value(nome),
       tipo = Value(tipo),
       dataSaldoInicial = Value(dataSaldoInicial);
  static Insertable<Conta> custom({
    Expression<int>? id,
    Expression<String>? nome,
    Expression<String>? tipo,
    Expression<int>? saldoInicialCentavos,
    Expression<String>? dataSaldoInicial,
    Expression<int>? arquivada,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (tipo != null) 'tipo': tipo,
      if (saldoInicialCentavos != null)
        'saldo_inicial_centavos': saldoInicialCentavos,
      if (dataSaldoInicial != null) 'data_saldo_inicial': dataSaldoInicial,
      if (arquivada != null) 'arquivada': arquivada,
    });
  }

  ContasCompanion copyWith({
    Value<int>? id,
    Value<String>? nome,
    Value<String>? tipo,
    Value<int>? saldoInicialCentavos,
    Value<String>? dataSaldoInicial,
    Value<int>? arquivada,
  }) {
    return ContasCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      saldoInicialCentavos: saldoInicialCentavos ?? this.saldoInicialCentavos,
      dataSaldoInicial: dataSaldoInicial ?? this.dataSaldoInicial,
      arquivada: arquivada ?? this.arquivada,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (saldoInicialCentavos.present) {
      map['saldo_inicial_centavos'] = Variable<int>(saldoInicialCentavos.value);
    }
    if (dataSaldoInicial.present) {
      map['data_saldo_inicial'] = Variable<String>(dataSaldoInicial.value);
    }
    if (arquivada.present) {
      map['arquivada'] = Variable<int>(arquivada.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContasCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('tipo: $tipo, ')
          ..write('saldoInicialCentavos: $saldoInicialCentavos, ')
          ..write('dataSaldoInicial: $dataSaldoInicial, ')
          ..write('arquivada: $arquivada')
          ..write(')'))
        .toString();
  }
}

class Cartoes extends Table with TableInfo<Cartoes, Cartao> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Cartoes(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _diaFechamentoMeta = const VerificationMeta(
    'diaFechamento',
  );
  late final GeneratedColumn<int> diaFechamento = GeneratedColumn<int>(
    'dia_fechamento',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (dia_fechamento BETWEEN 1 AND 31)',
  );
  static const VerificationMeta _diaVencimentoMeta = const VerificationMeta(
    'diaVencimento',
  );
  late final GeneratedColumn<int> diaVencimento = GeneratedColumn<int>(
    'dia_vencimento',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (dia_vencimento BETWEEN 1 AND 31)',
  );
  static const VerificationMeta _contaPagamentoIdMeta = const VerificationMeta(
    'contaPagamentoId',
  );
  late final GeneratedColumn<int> contaPagamentoId = GeneratedColumn<int>(
    'conta_pagamento_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES contas(id)',
  );
  static const VerificationMeta _arquivadoMeta = const VerificationMeta(
    'arquivado',
  );
  late final GeneratedColumn<int> arquivado = GeneratedColumn<int>(
    'arquivado',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nome,
    diaFechamento,
    diaVencimento,
    contaPagamentoId,
    arquivado,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cartoes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Cartao> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('dia_fechamento')) {
      context.handle(
        _diaFechamentoMeta,
        diaFechamento.isAcceptableOrUnknown(
          data['dia_fechamento']!,
          _diaFechamentoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_diaFechamentoMeta);
    }
    if (data.containsKey('dia_vencimento')) {
      context.handle(
        _diaVencimentoMeta,
        diaVencimento.isAcceptableOrUnknown(
          data['dia_vencimento']!,
          _diaVencimentoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_diaVencimentoMeta);
    }
    if (data.containsKey('conta_pagamento_id')) {
      context.handle(
        _contaPagamentoIdMeta,
        contaPagamentoId.isAcceptableOrUnknown(
          data['conta_pagamento_id']!,
          _contaPagamentoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contaPagamentoIdMeta);
    }
    if (data.containsKey('arquivado')) {
      context.handle(
        _arquivadoMeta,
        arquivado.isAcceptableOrUnknown(data['arquivado']!, _arquivadoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Cartao map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Cartao(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      diaFechamento: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dia_fechamento'],
      )!,
      diaVencimento: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dia_vencimento'],
      )!,
      contaPagamentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conta_pagamento_id'],
      )!,
      arquivado: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}arquivado'],
      )!,
    );
  }

  @override
  Cartoes createAlias(String alias) {
    return Cartoes(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Cartao extends DataClass implements Insertable<Cartao> {
  final int id;
  final String nome;
  final int diaFechamento;
  final int diaVencimento;
  final int contaPagamentoId;
  final int arquivado;
  const Cartao({
    required this.id,
    required this.nome,
    required this.diaFechamento,
    required this.diaVencimento,
    required this.contaPagamentoId,
    required this.arquivado,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    map['dia_fechamento'] = Variable<int>(diaFechamento);
    map['dia_vencimento'] = Variable<int>(diaVencimento);
    map['conta_pagamento_id'] = Variable<int>(contaPagamentoId);
    map['arquivado'] = Variable<int>(arquivado);
    return map;
  }

  CartoesCompanion toCompanion(bool nullToAbsent) {
    return CartoesCompanion(
      id: Value(id),
      nome: Value(nome),
      diaFechamento: Value(diaFechamento),
      diaVencimento: Value(diaVencimento),
      contaPagamentoId: Value(contaPagamentoId),
      arquivado: Value(arquivado),
    );
  }

  factory Cartao.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Cartao(
      id: serializer.fromJson<int>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      diaFechamento: serializer.fromJson<int>(json['dia_fechamento']),
      diaVencimento: serializer.fromJson<int>(json['dia_vencimento']),
      contaPagamentoId: serializer.fromJson<int>(json['conta_pagamento_id']),
      arquivado: serializer.fromJson<int>(json['arquivado']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nome': serializer.toJson<String>(nome),
      'dia_fechamento': serializer.toJson<int>(diaFechamento),
      'dia_vencimento': serializer.toJson<int>(diaVencimento),
      'conta_pagamento_id': serializer.toJson<int>(contaPagamentoId),
      'arquivado': serializer.toJson<int>(arquivado),
    };
  }

  Cartao copyWith({
    int? id,
    String? nome,
    int? diaFechamento,
    int? diaVencimento,
    int? contaPagamentoId,
    int? arquivado,
  }) => Cartao(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    diaFechamento: diaFechamento ?? this.diaFechamento,
    diaVencimento: diaVencimento ?? this.diaVencimento,
    contaPagamentoId: contaPagamentoId ?? this.contaPagamentoId,
    arquivado: arquivado ?? this.arquivado,
  );
  Cartao copyWithCompanion(CartoesCompanion data) {
    return Cartao(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      diaFechamento: data.diaFechamento.present
          ? data.diaFechamento.value
          : this.diaFechamento,
      diaVencimento: data.diaVencimento.present
          ? data.diaVencimento.value
          : this.diaVencimento,
      contaPagamentoId: data.contaPagamentoId.present
          ? data.contaPagamentoId.value
          : this.contaPagamentoId,
      arquivado: data.arquivado.present ? data.arquivado.value : this.arquivado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Cartao(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('diaFechamento: $diaFechamento, ')
          ..write('diaVencimento: $diaVencimento, ')
          ..write('contaPagamentoId: $contaPagamentoId, ')
          ..write('arquivado: $arquivado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nome,
    diaFechamento,
    diaVencimento,
    contaPagamentoId,
    arquivado,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Cartao &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.diaFechamento == this.diaFechamento &&
          other.diaVencimento == this.diaVencimento &&
          other.contaPagamentoId == this.contaPagamentoId &&
          other.arquivado == this.arquivado);
}

class CartoesCompanion extends UpdateCompanion<Cartao> {
  final Value<int> id;
  final Value<String> nome;
  final Value<int> diaFechamento;
  final Value<int> diaVencimento;
  final Value<int> contaPagamentoId;
  final Value<int> arquivado;
  const CartoesCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.diaFechamento = const Value.absent(),
    this.diaVencimento = const Value.absent(),
    this.contaPagamentoId = const Value.absent(),
    this.arquivado = const Value.absent(),
  });
  CartoesCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
    required int diaFechamento,
    required int diaVencimento,
    required int contaPagamentoId,
    this.arquivado = const Value.absent(),
  }) : nome = Value(nome),
       diaFechamento = Value(diaFechamento),
       diaVencimento = Value(diaVencimento),
       contaPagamentoId = Value(contaPagamentoId);
  static Insertable<Cartao> custom({
    Expression<int>? id,
    Expression<String>? nome,
    Expression<int>? diaFechamento,
    Expression<int>? diaVencimento,
    Expression<int>? contaPagamentoId,
    Expression<int>? arquivado,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (diaFechamento != null) 'dia_fechamento': diaFechamento,
      if (diaVencimento != null) 'dia_vencimento': diaVencimento,
      if (contaPagamentoId != null) 'conta_pagamento_id': contaPagamentoId,
      if (arquivado != null) 'arquivado': arquivado,
    });
  }

  CartoesCompanion copyWith({
    Value<int>? id,
    Value<String>? nome,
    Value<int>? diaFechamento,
    Value<int>? diaVencimento,
    Value<int>? contaPagamentoId,
    Value<int>? arquivado,
  }) {
    return CartoesCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      diaFechamento: diaFechamento ?? this.diaFechamento,
      diaVencimento: diaVencimento ?? this.diaVencimento,
      contaPagamentoId: contaPagamentoId ?? this.contaPagamentoId,
      arquivado: arquivado ?? this.arquivado,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (diaFechamento.present) {
      map['dia_fechamento'] = Variable<int>(diaFechamento.value);
    }
    if (diaVencimento.present) {
      map['dia_vencimento'] = Variable<int>(diaVencimento.value);
    }
    if (contaPagamentoId.present) {
      map['conta_pagamento_id'] = Variable<int>(contaPagamentoId.value);
    }
    if (arquivado.present) {
      map['arquivado'] = Variable<int>(arquivado.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CartoesCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('diaFechamento: $diaFechamento, ')
          ..write('diaVencimento: $diaVencimento, ')
          ..write('contaPagamentoId: $contaPagamentoId, ')
          ..write('arquivado: $arquivado')
          ..write(')'))
        .toString();
  }
}

class Faturas extends Table with TableInfo<Faturas, Fatura> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Faturas(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _cartaoIdMeta = const VerificationMeta(
    'cartaoId',
  );
  late final GeneratedColumn<int> cartaoId = GeneratedColumn<int>(
    'cartao_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES cartoes(id)',
  );
  static const VerificationMeta _mesMeta = const VerificationMeta('mes');
  late final GeneratedColumn<String> mes = GeneratedColumn<String>(
    'mes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _pagoEmMeta = const VerificationMeta('pagoEm');
  late final GeneratedColumn<String> pagoEm = GeneratedColumn<String>(
    'pago_em',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _contaPagamentoIdMeta = const VerificationMeta(
    'contaPagamentoId',
  );
  late final GeneratedColumn<int> contaPagamentoId = GeneratedColumn<int>(
    'conta_pagamento_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES contas(id)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cartaoId,
    mes,
    pagoEm,
    contaPagamentoId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'faturas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Fatura> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cartao_id')) {
      context.handle(
        _cartaoIdMeta,
        cartaoId.isAcceptableOrUnknown(data['cartao_id']!, _cartaoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_cartaoIdMeta);
    }
    if (data.containsKey('mes')) {
      context.handle(
        _mesMeta,
        mes.isAcceptableOrUnknown(data['mes']!, _mesMeta),
      );
    } else if (isInserting) {
      context.missing(_mesMeta);
    }
    if (data.containsKey('pago_em')) {
      context.handle(
        _pagoEmMeta,
        pagoEm.isAcceptableOrUnknown(data['pago_em']!, _pagoEmMeta),
      );
    }
    if (data.containsKey('conta_pagamento_id')) {
      context.handle(
        _contaPagamentoIdMeta,
        contaPagamentoId.isAcceptableOrUnknown(
          data['conta_pagamento_id']!,
          _contaPagamentoIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {cartaoId, mes},
  ];
  @override
  Fatura map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Fatura(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cartaoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cartao_id'],
      )!,
      mes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mes'],
      )!,
      pagoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pago_em'],
      ),
      contaPagamentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conta_pagamento_id'],
      ),
    );
  }

  @override
  Faturas createAlias(String alias) {
    return Faturas(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['UNIQUE(cartao_id, mes)'];
  @override
  bool get dontWriteConstraints => true;
}

class Fatura extends DataClass implements Insertable<Fatura> {
  final int id;
  final int cartaoId;
  final String mes;

  /// AAAA-MM do vencimento
  final String? pagoEm;

  /// vazio = dia do vencimento
  final int? contaPagamentoId;
  const Fatura({
    required this.id,
    required this.cartaoId,
    required this.mes,
    this.pagoEm,
    this.contaPagamentoId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cartao_id'] = Variable<int>(cartaoId);
    map['mes'] = Variable<String>(mes);
    if (!nullToAbsent || pagoEm != null) {
      map['pago_em'] = Variable<String>(pagoEm);
    }
    if (!nullToAbsent || contaPagamentoId != null) {
      map['conta_pagamento_id'] = Variable<int>(contaPagamentoId);
    }
    return map;
  }

  FaturasCompanion toCompanion(bool nullToAbsent) {
    return FaturasCompanion(
      id: Value(id),
      cartaoId: Value(cartaoId),
      mes: Value(mes),
      pagoEm: pagoEm == null && nullToAbsent
          ? const Value.absent()
          : Value(pagoEm),
      contaPagamentoId: contaPagamentoId == null && nullToAbsent
          ? const Value.absent()
          : Value(contaPagamentoId),
    );
  }

  factory Fatura.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Fatura(
      id: serializer.fromJson<int>(json['id']),
      cartaoId: serializer.fromJson<int>(json['cartao_id']),
      mes: serializer.fromJson<String>(json['mes']),
      pagoEm: serializer.fromJson<String?>(json['pago_em']),
      contaPagamentoId: serializer.fromJson<int?>(json['conta_pagamento_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cartao_id': serializer.toJson<int>(cartaoId),
      'mes': serializer.toJson<String>(mes),
      'pago_em': serializer.toJson<String?>(pagoEm),
      'conta_pagamento_id': serializer.toJson<int?>(contaPagamentoId),
    };
  }

  Fatura copyWith({
    int? id,
    int? cartaoId,
    String? mes,
    Value<String?> pagoEm = const Value.absent(),
    Value<int?> contaPagamentoId = const Value.absent(),
  }) => Fatura(
    id: id ?? this.id,
    cartaoId: cartaoId ?? this.cartaoId,
    mes: mes ?? this.mes,
    pagoEm: pagoEm.present ? pagoEm.value : this.pagoEm,
    contaPagamentoId: contaPagamentoId.present
        ? contaPagamentoId.value
        : this.contaPagamentoId,
  );
  Fatura copyWithCompanion(FaturasCompanion data) {
    return Fatura(
      id: data.id.present ? data.id.value : this.id,
      cartaoId: data.cartaoId.present ? data.cartaoId.value : this.cartaoId,
      mes: data.mes.present ? data.mes.value : this.mes,
      pagoEm: data.pagoEm.present ? data.pagoEm.value : this.pagoEm,
      contaPagamentoId: data.contaPagamentoId.present
          ? data.contaPagamentoId.value
          : this.contaPagamentoId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Fatura(')
          ..write('id: $id, ')
          ..write('cartaoId: $cartaoId, ')
          ..write('mes: $mes, ')
          ..write('pagoEm: $pagoEm, ')
          ..write('contaPagamentoId: $contaPagamentoId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, cartaoId, mes, pagoEm, contaPagamentoId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Fatura &&
          other.id == this.id &&
          other.cartaoId == this.cartaoId &&
          other.mes == this.mes &&
          other.pagoEm == this.pagoEm &&
          other.contaPagamentoId == this.contaPagamentoId);
}

class FaturasCompanion extends UpdateCompanion<Fatura> {
  final Value<int> id;
  final Value<int> cartaoId;
  final Value<String> mes;
  final Value<String?> pagoEm;
  final Value<int?> contaPagamentoId;
  const FaturasCompanion({
    this.id = const Value.absent(),
    this.cartaoId = const Value.absent(),
    this.mes = const Value.absent(),
    this.pagoEm = const Value.absent(),
    this.contaPagamentoId = const Value.absent(),
  });
  FaturasCompanion.insert({
    this.id = const Value.absent(),
    required int cartaoId,
    required String mes,
    this.pagoEm = const Value.absent(),
    this.contaPagamentoId = const Value.absent(),
  }) : cartaoId = Value(cartaoId),
       mes = Value(mes);
  static Insertable<Fatura> custom({
    Expression<int>? id,
    Expression<int>? cartaoId,
    Expression<String>? mes,
    Expression<String>? pagoEm,
    Expression<int>? contaPagamentoId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cartaoId != null) 'cartao_id': cartaoId,
      if (mes != null) 'mes': mes,
      if (pagoEm != null) 'pago_em': pagoEm,
      if (contaPagamentoId != null) 'conta_pagamento_id': contaPagamentoId,
    });
  }

  FaturasCompanion copyWith({
    Value<int>? id,
    Value<int>? cartaoId,
    Value<String>? mes,
    Value<String?>? pagoEm,
    Value<int?>? contaPagamentoId,
  }) {
    return FaturasCompanion(
      id: id ?? this.id,
      cartaoId: cartaoId ?? this.cartaoId,
      mes: mes ?? this.mes,
      pagoEm: pagoEm ?? this.pagoEm,
      contaPagamentoId: contaPagamentoId ?? this.contaPagamentoId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cartaoId.present) {
      map['cartao_id'] = Variable<int>(cartaoId.value);
    }
    if (mes.present) {
      map['mes'] = Variable<String>(mes.value);
    }
    if (pagoEm.present) {
      map['pago_em'] = Variable<String>(pagoEm.value);
    }
    if (contaPagamentoId.present) {
      map['conta_pagamento_id'] = Variable<int>(contaPagamentoId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FaturasCompanion(')
          ..write('id: $id, ')
          ..write('cartaoId: $cartaoId, ')
          ..write('mes: $mes, ')
          ..write('pagoEm: $pagoEm, ')
          ..write('contaPagamentoId: $contaPagamentoId')
          ..write(')'))
        .toString();
  }
}

class Categorias extends Table with TableInfo<Categorias, Categoria> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Categorias(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (tipo IN (\'ganho\', \'despesa\'))',
  );
  static const VerificationMeta _categoriaPaiIdMeta = const VerificationMeta(
    'categoriaPaiId',
  );
  late final GeneratedColumn<int> categoriaPaiId = GeneratedColumn<int>(
    'categoria_pai_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES categorias(id)',
  );
  static const VerificationMeta _arquivadaMeta = const VerificationMeta(
    'arquivada',
  );
  late final GeneratedColumn<int> arquivada = GeneratedColumn<int>(
    'arquivada',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nome,
    tipo,
    categoriaPaiId,
    arquivada,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categorias';
  @override
  VerificationContext validateIntegrity(
    Insertable<Categoria> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('categoria_pai_id')) {
      context.handle(
        _categoriaPaiIdMeta,
        categoriaPaiId.isAcceptableOrUnknown(
          data['categoria_pai_id']!,
          _categoriaPaiIdMeta,
        ),
      );
    }
    if (data.containsKey('arquivada')) {
      context.handle(
        _arquivadaMeta,
        arquivada.isAcceptableOrUnknown(data['arquivada']!, _arquivadaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Categoria map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Categoria(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      categoriaPaiId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}categoria_pai_id'],
      ),
      arquivada: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}arquivada'],
      )!,
    );
  }

  @override
  Categorias createAlias(String alias) {
    return Categorias(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Categoria extends DataClass implements Insertable<Categoria> {
  final int id;
  final String nome;
  final String tipo;
  final int? categoriaPaiId;
  final int arquivada;
  const Categoria({
    required this.id,
    required this.nome,
    required this.tipo,
    this.categoriaPaiId,
    required this.arquivada,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    map['tipo'] = Variable<String>(tipo);
    if (!nullToAbsent || categoriaPaiId != null) {
      map['categoria_pai_id'] = Variable<int>(categoriaPaiId);
    }
    map['arquivada'] = Variable<int>(arquivada);
    return map;
  }

  CategoriasCompanion toCompanion(bool nullToAbsent) {
    return CategoriasCompanion(
      id: Value(id),
      nome: Value(nome),
      tipo: Value(tipo),
      categoriaPaiId: categoriaPaiId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoriaPaiId),
      arquivada: Value(arquivada),
    );
  }

  factory Categoria.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Categoria(
      id: serializer.fromJson<int>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      tipo: serializer.fromJson<String>(json['tipo']),
      categoriaPaiId: serializer.fromJson<int?>(json['categoria_pai_id']),
      arquivada: serializer.fromJson<int>(json['arquivada']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nome': serializer.toJson<String>(nome),
      'tipo': serializer.toJson<String>(tipo),
      'categoria_pai_id': serializer.toJson<int?>(categoriaPaiId),
      'arquivada': serializer.toJson<int>(arquivada),
    };
  }

  Categoria copyWith({
    int? id,
    String? nome,
    String? tipo,
    Value<int?> categoriaPaiId = const Value.absent(),
    int? arquivada,
  }) => Categoria(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    tipo: tipo ?? this.tipo,
    categoriaPaiId: categoriaPaiId.present
        ? categoriaPaiId.value
        : this.categoriaPaiId,
    arquivada: arquivada ?? this.arquivada,
  );
  Categoria copyWithCompanion(CategoriasCompanion data) {
    return Categoria(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      categoriaPaiId: data.categoriaPaiId.present
          ? data.categoriaPaiId.value
          : this.categoriaPaiId,
      arquivada: data.arquivada.present ? data.arquivada.value : this.arquivada,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Categoria(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('tipo: $tipo, ')
          ..write('categoriaPaiId: $categoriaPaiId, ')
          ..write('arquivada: $arquivada')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nome, tipo, categoriaPaiId, arquivada);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Categoria &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.tipo == this.tipo &&
          other.categoriaPaiId == this.categoriaPaiId &&
          other.arquivada == this.arquivada);
}

class CategoriasCompanion extends UpdateCompanion<Categoria> {
  final Value<int> id;
  final Value<String> nome;
  final Value<String> tipo;
  final Value<int?> categoriaPaiId;
  final Value<int> arquivada;
  const CategoriasCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.tipo = const Value.absent(),
    this.categoriaPaiId = const Value.absent(),
    this.arquivada = const Value.absent(),
  });
  CategoriasCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
    required String tipo,
    this.categoriaPaiId = const Value.absent(),
    this.arquivada = const Value.absent(),
  }) : nome = Value(nome),
       tipo = Value(tipo);
  static Insertable<Categoria> custom({
    Expression<int>? id,
    Expression<String>? nome,
    Expression<String>? tipo,
    Expression<int>? categoriaPaiId,
    Expression<int>? arquivada,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (tipo != null) 'tipo': tipo,
      if (categoriaPaiId != null) 'categoria_pai_id': categoriaPaiId,
      if (arquivada != null) 'arquivada': arquivada,
    });
  }

  CategoriasCompanion copyWith({
    Value<int>? id,
    Value<String>? nome,
    Value<String>? tipo,
    Value<int?>? categoriaPaiId,
    Value<int>? arquivada,
  }) {
    return CategoriasCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      categoriaPaiId: categoriaPaiId ?? this.categoriaPaiId,
      arquivada: arquivada ?? this.arquivada,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (categoriaPaiId.present) {
      map['categoria_pai_id'] = Variable<int>(categoriaPaiId.value);
    }
    if (arquivada.present) {
      map['arquivada'] = Variable<int>(arquivada.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriasCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('tipo: $tipo, ')
          ..write('categoriaPaiId: $categoriaPaiId, ')
          ..write('arquivada: $arquivada')
          ..write(')'))
        .toString();
  }
}

class Tags extends Table with TableInfo<Tags, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Tags(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE',
  );
  @override
  List<GeneratedColumn> get $columns => [id, nome];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
    );
  }

  @override
  Tags createAlias(String alias) {
    return Tags(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Tag extends DataClass implements Insertable<Tag> {
  final int id;
  final String nome;
  const Tag({required this.id, required this.nome});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(id: Value(id), nome: Value(nome));
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<int>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nome': serializer.toJson<String>(nome),
    };
  }

  Tag copyWith({int? id, String? nome}) =>
      Tag(id: id ?? this.id, nome: nome ?? this.nome);
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('nome: $nome')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nome);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag && other.id == this.id && other.nome == this.nome);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<int> id;
  final Value<String> nome;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
  });
  TagsCompanion.insert({this.id = const Value.absent(), required String nome})
    : nome = Value(nome);
  static Insertable<Tag> custom({
    Expression<int>? id,
    Expression<String>? nome,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
    });
  }

  TagsCompanion copyWith({Value<int>? id, Value<String>? nome}) {
    return TagsCompanion(id: id ?? this.id, nome: nome ?? this.nome);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome')
          ..write(')'))
        .toString();
  }
}

class Recorrencias extends Table with TableInfo<Recorrencias, Recorrencia> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Recorrencias(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _diaDoMesMeta = const VerificationMeta(
    'diaDoMes',
  );
  late final GeneratedColumn<int> diaDoMes = GeneratedColumn<int>(
    'dia_do_mes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _dataInicioMeta = const VerificationMeta(
    'dataInicio',
  );
  late final GeneratedColumn<String> dataInicio = GeneratedColumn<String>(
    'data_inicio',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _dataFimMeta = const VerificationMeta(
    'dataFim',
  );
  late final GeneratedColumn<String> dataFim = GeneratedColumn<String>(
    'data_fim',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _ativaMeta = const VerificationMeta('ativa');
  late final GeneratedColumn<int> ativa = GeneratedColumn<int>(
    'ativa',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1',
    defaultValue: const CustomExpression('1'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    diaDoMes,
    dataInicio,
    dataFim,
    ativa,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recorrencias';
  @override
  VerificationContext validateIntegrity(
    Insertable<Recorrencia> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('dia_do_mes')) {
      context.handle(
        _diaDoMesMeta,
        diaDoMes.isAcceptableOrUnknown(data['dia_do_mes']!, _diaDoMesMeta),
      );
    } else if (isInserting) {
      context.missing(_diaDoMesMeta);
    }
    if (data.containsKey('data_inicio')) {
      context.handle(
        _dataInicioMeta,
        dataInicio.isAcceptableOrUnknown(data['data_inicio']!, _dataInicioMeta),
      );
    } else if (isInserting) {
      context.missing(_dataInicioMeta);
    }
    if (data.containsKey('data_fim')) {
      context.handle(
        _dataFimMeta,
        dataFim.isAcceptableOrUnknown(data['data_fim']!, _dataFimMeta),
      );
    }
    if (data.containsKey('ativa')) {
      context.handle(
        _ativaMeta,
        ativa.isAcceptableOrUnknown(data['ativa']!, _ativaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Recorrencia map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Recorrencia(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      diaDoMes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dia_do_mes'],
      )!,
      dataInicio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_inicio'],
      )!,
      dataFim: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_fim'],
      ),
      ativa: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ativa'],
      )!,
    );
  }

  @override
  Recorrencias createAlias(String alias) {
    return Recorrencias(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Recorrencia extends DataClass implements Insertable<Recorrencia> {
  final int id;
  final int diaDoMes;
  final String dataInicio;

  /// AAAA-MM-DD
  final String? dataFim;

  /// vazio = sem fim
  final int ativa;
  const Recorrencia({
    required this.id,
    required this.diaDoMes,
    required this.dataInicio,
    this.dataFim,
    required this.ativa,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['dia_do_mes'] = Variable<int>(diaDoMes);
    map['data_inicio'] = Variable<String>(dataInicio);
    if (!nullToAbsent || dataFim != null) {
      map['data_fim'] = Variable<String>(dataFim);
    }
    map['ativa'] = Variable<int>(ativa);
    return map;
  }

  RecorrenciasCompanion toCompanion(bool nullToAbsent) {
    return RecorrenciasCompanion(
      id: Value(id),
      diaDoMes: Value(diaDoMes),
      dataInicio: Value(dataInicio),
      dataFim: dataFim == null && nullToAbsent
          ? const Value.absent()
          : Value(dataFim),
      ativa: Value(ativa),
    );
  }

  factory Recorrencia.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Recorrencia(
      id: serializer.fromJson<int>(json['id']),
      diaDoMes: serializer.fromJson<int>(json['dia_do_mes']),
      dataInicio: serializer.fromJson<String>(json['data_inicio']),
      dataFim: serializer.fromJson<String?>(json['data_fim']),
      ativa: serializer.fromJson<int>(json['ativa']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dia_do_mes': serializer.toJson<int>(diaDoMes),
      'data_inicio': serializer.toJson<String>(dataInicio),
      'data_fim': serializer.toJson<String?>(dataFim),
      'ativa': serializer.toJson<int>(ativa),
    };
  }

  Recorrencia copyWith({
    int? id,
    int? diaDoMes,
    String? dataInicio,
    Value<String?> dataFim = const Value.absent(),
    int? ativa,
  }) => Recorrencia(
    id: id ?? this.id,
    diaDoMes: diaDoMes ?? this.diaDoMes,
    dataInicio: dataInicio ?? this.dataInicio,
    dataFim: dataFim.present ? dataFim.value : this.dataFim,
    ativa: ativa ?? this.ativa,
  );
  Recorrencia copyWithCompanion(RecorrenciasCompanion data) {
    return Recorrencia(
      id: data.id.present ? data.id.value : this.id,
      diaDoMes: data.diaDoMes.present ? data.diaDoMes.value : this.diaDoMes,
      dataInicio: data.dataInicio.present
          ? data.dataInicio.value
          : this.dataInicio,
      dataFim: data.dataFim.present ? data.dataFim.value : this.dataFim,
      ativa: data.ativa.present ? data.ativa.value : this.ativa,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Recorrencia(')
          ..write('id: $id, ')
          ..write('diaDoMes: $diaDoMes, ')
          ..write('dataInicio: $dataInicio, ')
          ..write('dataFim: $dataFim, ')
          ..write('ativa: $ativa')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, diaDoMes, dataInicio, dataFim, ativa);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Recorrencia &&
          other.id == this.id &&
          other.diaDoMes == this.diaDoMes &&
          other.dataInicio == this.dataInicio &&
          other.dataFim == this.dataFim &&
          other.ativa == this.ativa);
}

class RecorrenciasCompanion extends UpdateCompanion<Recorrencia> {
  final Value<int> id;
  final Value<int> diaDoMes;
  final Value<String> dataInicio;
  final Value<String?> dataFim;
  final Value<int> ativa;
  const RecorrenciasCompanion({
    this.id = const Value.absent(),
    this.diaDoMes = const Value.absent(),
    this.dataInicio = const Value.absent(),
    this.dataFim = const Value.absent(),
    this.ativa = const Value.absent(),
  });
  RecorrenciasCompanion.insert({
    this.id = const Value.absent(),
    required int diaDoMes,
    required String dataInicio,
    this.dataFim = const Value.absent(),
    this.ativa = const Value.absent(),
  }) : diaDoMes = Value(diaDoMes),
       dataInicio = Value(dataInicio);
  static Insertable<Recorrencia> custom({
    Expression<int>? id,
    Expression<int>? diaDoMes,
    Expression<String>? dataInicio,
    Expression<String>? dataFim,
    Expression<int>? ativa,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (diaDoMes != null) 'dia_do_mes': diaDoMes,
      if (dataInicio != null) 'data_inicio': dataInicio,
      if (dataFim != null) 'data_fim': dataFim,
      if (ativa != null) 'ativa': ativa,
    });
  }

  RecorrenciasCompanion copyWith({
    Value<int>? id,
    Value<int>? diaDoMes,
    Value<String>? dataInicio,
    Value<String?>? dataFim,
    Value<int>? ativa,
  }) {
    return RecorrenciasCompanion(
      id: id ?? this.id,
      diaDoMes: diaDoMes ?? this.diaDoMes,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      ativa: ativa ?? this.ativa,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (diaDoMes.present) {
      map['dia_do_mes'] = Variable<int>(diaDoMes.value);
    }
    if (dataInicio.present) {
      map['data_inicio'] = Variable<String>(dataInicio.value);
    }
    if (dataFim.present) {
      map['data_fim'] = Variable<String>(dataFim.value);
    }
    if (ativa.present) {
      map['ativa'] = Variable<int>(ativa.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecorrenciasCompanion(')
          ..write('id: $id, ')
          ..write('diaDoMes: $diaDoMes, ')
          ..write('dataInicio: $dataInicio, ')
          ..write('dataFim: $dataFim, ')
          ..write('ativa: $ativa')
          ..write(')'))
        .toString();
  }
}

class Lancamentos extends Table with TableInfo<Lancamentos, Lancamento> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Lancamentos(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (tipo IN (\'ganho\', \'despesa\', \'estorno\'))',
  );
  static const VerificationMeta _descricaoMeta = const VerificationMeta(
    'descricao',
  );
  late final GeneratedColumn<String> descricao = GeneratedColumn<String>(
    'descricao',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _valorCentavosMeta = const VerificationMeta(
    'valorCentavos',
  );
  late final GeneratedColumn<int> valorCentavos = GeneratedColumn<int>(
    'valor_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (valor_centavos > 0)',
  );
  static const VerificationMeta _dataLancamentoMeta = const VerificationMeta(
    'dataLancamento',
  );
  late final GeneratedColumn<String> dataLancamento = GeneratedColumn<String>(
    'data_lancamento',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _contaIdMeta = const VerificationMeta(
    'contaId',
  );
  late final GeneratedColumn<int> contaId = GeneratedColumn<int>(
    'conta_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES contas(id)',
  );
  static const VerificationMeta _cartaoIdMeta = const VerificationMeta(
    'cartaoId',
  );
  late final GeneratedColumn<int> cartaoId = GeneratedColumn<int>(
    'cartao_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES cartoes(id)',
  );
  static const VerificationMeta _mesFaturaMeta = const VerificationMeta(
    'mesFatura',
  );
  late final GeneratedColumn<String> mesFatura = GeneratedColumn<String>(
    'mes_fatura',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _faturaManualMeta = const VerificationMeta(
    'faturaManual',
  );
  late final GeneratedColumn<int> faturaManual = GeneratedColumn<int>(
    'fatura_manual',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _mesReferenciaMeta = const VerificationMeta(
    'mesReferencia',
  );
  late final GeneratedColumn<String> mesReferencia = GeneratedColumn<String>(
    'mes_referencia',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _parcelaAtualMeta = const VerificationMeta(
    'parcelaAtual',
  );
  late final GeneratedColumn<int> parcelaAtual = GeneratedColumn<int>(
    'parcela_atual',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _totalParcelasMeta = const VerificationMeta(
    'totalParcelas',
  );
  late final GeneratedColumn<int> totalParcelas = GeneratedColumn<int>(
    'total_parcelas',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _grupoParcelamentoMeta = const VerificationMeta(
    'grupoParcelamento',
  );
  late final GeneratedColumn<String> grupoParcelamento =
      GeneratedColumn<String>(
        'grupo_parcelamento',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _recorrenciaIdMeta = const VerificationMeta(
    'recorrenciaId',
  );
  late final GeneratedColumn<int> recorrenciaId = GeneratedColumn<int>(
    'recorrencia_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES recorrencias(id)',
  );
  static const VerificationMeta _observacaoMeta = const VerificationMeta(
    'observacao',
  );
  late final GeneratedColumn<String> observacao = GeneratedColumn<String>(
    'observacao',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  late final GeneratedColumn<String> criadoEm = GeneratedColumn<String>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tipo,
    descricao,
    valorCentavos,
    dataLancamento,
    contaId,
    cartaoId,
    mesFatura,
    faturaManual,
    mesReferencia,
    parcelaAtual,
    totalParcelas,
    grupoParcelamento,
    recorrenciaId,
    observacao,
    criadoEm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lancamentos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Lancamento> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('descricao')) {
      context.handle(
        _descricaoMeta,
        descricao.isAcceptableOrUnknown(data['descricao']!, _descricaoMeta),
      );
    } else if (isInserting) {
      context.missing(_descricaoMeta);
    }
    if (data.containsKey('valor_centavos')) {
      context.handle(
        _valorCentavosMeta,
        valorCentavos.isAcceptableOrUnknown(
          data['valor_centavos']!,
          _valorCentavosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_valorCentavosMeta);
    }
    if (data.containsKey('data_lancamento')) {
      context.handle(
        _dataLancamentoMeta,
        dataLancamento.isAcceptableOrUnknown(
          data['data_lancamento']!,
          _dataLancamentoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dataLancamentoMeta);
    }
    if (data.containsKey('conta_id')) {
      context.handle(
        _contaIdMeta,
        contaId.isAcceptableOrUnknown(data['conta_id']!, _contaIdMeta),
      );
    }
    if (data.containsKey('cartao_id')) {
      context.handle(
        _cartaoIdMeta,
        cartaoId.isAcceptableOrUnknown(data['cartao_id']!, _cartaoIdMeta),
      );
    }
    if (data.containsKey('mes_fatura')) {
      context.handle(
        _mesFaturaMeta,
        mesFatura.isAcceptableOrUnknown(data['mes_fatura']!, _mesFaturaMeta),
      );
    }
    if (data.containsKey('fatura_manual')) {
      context.handle(
        _faturaManualMeta,
        faturaManual.isAcceptableOrUnknown(
          data['fatura_manual']!,
          _faturaManualMeta,
        ),
      );
    }
    if (data.containsKey('mes_referencia')) {
      context.handle(
        _mesReferenciaMeta,
        mesReferencia.isAcceptableOrUnknown(
          data['mes_referencia']!,
          _mesReferenciaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mesReferenciaMeta);
    }
    if (data.containsKey('parcela_atual')) {
      context.handle(
        _parcelaAtualMeta,
        parcelaAtual.isAcceptableOrUnknown(
          data['parcela_atual']!,
          _parcelaAtualMeta,
        ),
      );
    }
    if (data.containsKey('total_parcelas')) {
      context.handle(
        _totalParcelasMeta,
        totalParcelas.isAcceptableOrUnknown(
          data['total_parcelas']!,
          _totalParcelasMeta,
        ),
      );
    }
    if (data.containsKey('grupo_parcelamento')) {
      context.handle(
        _grupoParcelamentoMeta,
        grupoParcelamento.isAcceptableOrUnknown(
          data['grupo_parcelamento']!,
          _grupoParcelamentoMeta,
        ),
      );
    }
    if (data.containsKey('recorrencia_id')) {
      context.handle(
        _recorrenciaIdMeta,
        recorrenciaId.isAcceptableOrUnknown(
          data['recorrencia_id']!,
          _recorrenciaIdMeta,
        ),
      );
    }
    if (data.containsKey('observacao')) {
      context.handle(
        _observacaoMeta,
        observacao.isAcceptableOrUnknown(data['observacao']!, _observacaoMeta),
      );
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    } else if (isInserting) {
      context.missing(_criadoEmMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Lancamento map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Lancamento(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      descricao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descricao'],
      )!,
      valorCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}valor_centavos'],
      )!,
      dataLancamento: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_lancamento'],
      )!,
      contaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conta_id'],
      ),
      cartaoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cartao_id'],
      ),
      mesFatura: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mes_fatura'],
      ),
      faturaManual: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fatura_manual'],
      )!,
      mesReferencia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mes_referencia'],
      )!,
      parcelaAtual: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parcela_atual'],
      ),
      totalParcelas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_parcelas'],
      ),
      grupoParcelamento: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grupo_parcelamento'],
      ),
      recorrenciaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recorrencia_id'],
      ),
      observacao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observacao'],
      ),
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}criado_em'],
      )!,
    );
  }

  @override
  Lancamentos createAlias(String alias) {
    return Lancamentos(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'CHECK((conta_id IS NULL)<>(cartao_id IS NULL))',
    'CHECK(tipo <> \'estorno\' OR cartao_id IS NOT NULL)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class Lancamento extends DataClass implements Insertable<Lancamento> {
  final int id;
  final String tipo;
  final String descricao;
  final int valorCentavos;
  final String dataLancamento;

  /// AAAA-MM-DD
  final int? contaId;

  /// carteira ou banco
  final int? cartaoId;

  /// só despesa no cartão
  final String? mesFatura;

  /// AAAA-MM, só cartão
  final int faturaManual;

  /// 1 = trocada à mão
  final String mesReferencia;

  /// AAAA-MM: fatura ou data
  final int? parcelaAtual;
  final int? totalParcelas;
  final String? grupoParcelamento;

  /// mesmo valor nas parcelas
  final int? recorrenciaId;
  final String? observacao;
  final String criadoEm;
  const Lancamento({
    required this.id,
    required this.tipo,
    required this.descricao,
    required this.valorCentavos,
    required this.dataLancamento,
    this.contaId,
    this.cartaoId,
    this.mesFatura,
    required this.faturaManual,
    required this.mesReferencia,
    this.parcelaAtual,
    this.totalParcelas,
    this.grupoParcelamento,
    this.recorrenciaId,
    this.observacao,
    required this.criadoEm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tipo'] = Variable<String>(tipo);
    map['descricao'] = Variable<String>(descricao);
    map['valor_centavos'] = Variable<int>(valorCentavos);
    map['data_lancamento'] = Variable<String>(dataLancamento);
    if (!nullToAbsent || contaId != null) {
      map['conta_id'] = Variable<int>(contaId);
    }
    if (!nullToAbsent || cartaoId != null) {
      map['cartao_id'] = Variable<int>(cartaoId);
    }
    if (!nullToAbsent || mesFatura != null) {
      map['mes_fatura'] = Variable<String>(mesFatura);
    }
    map['fatura_manual'] = Variable<int>(faturaManual);
    map['mes_referencia'] = Variable<String>(mesReferencia);
    if (!nullToAbsent || parcelaAtual != null) {
      map['parcela_atual'] = Variable<int>(parcelaAtual);
    }
    if (!nullToAbsent || totalParcelas != null) {
      map['total_parcelas'] = Variable<int>(totalParcelas);
    }
    if (!nullToAbsent || grupoParcelamento != null) {
      map['grupo_parcelamento'] = Variable<String>(grupoParcelamento);
    }
    if (!nullToAbsent || recorrenciaId != null) {
      map['recorrencia_id'] = Variable<int>(recorrenciaId);
    }
    if (!nullToAbsent || observacao != null) {
      map['observacao'] = Variable<String>(observacao);
    }
    map['criado_em'] = Variable<String>(criadoEm);
    return map;
  }

  LancamentosCompanion toCompanion(bool nullToAbsent) {
    return LancamentosCompanion(
      id: Value(id),
      tipo: Value(tipo),
      descricao: Value(descricao),
      valorCentavos: Value(valorCentavos),
      dataLancamento: Value(dataLancamento),
      contaId: contaId == null && nullToAbsent
          ? const Value.absent()
          : Value(contaId),
      cartaoId: cartaoId == null && nullToAbsent
          ? const Value.absent()
          : Value(cartaoId),
      mesFatura: mesFatura == null && nullToAbsent
          ? const Value.absent()
          : Value(mesFatura),
      faturaManual: Value(faturaManual),
      mesReferencia: Value(mesReferencia),
      parcelaAtual: parcelaAtual == null && nullToAbsent
          ? const Value.absent()
          : Value(parcelaAtual),
      totalParcelas: totalParcelas == null && nullToAbsent
          ? const Value.absent()
          : Value(totalParcelas),
      grupoParcelamento: grupoParcelamento == null && nullToAbsent
          ? const Value.absent()
          : Value(grupoParcelamento),
      recorrenciaId: recorrenciaId == null && nullToAbsent
          ? const Value.absent()
          : Value(recorrenciaId),
      observacao: observacao == null && nullToAbsent
          ? const Value.absent()
          : Value(observacao),
      criadoEm: Value(criadoEm),
    );
  }

  factory Lancamento.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Lancamento(
      id: serializer.fromJson<int>(json['id']),
      tipo: serializer.fromJson<String>(json['tipo']),
      descricao: serializer.fromJson<String>(json['descricao']),
      valorCentavos: serializer.fromJson<int>(json['valor_centavos']),
      dataLancamento: serializer.fromJson<String>(json['data_lancamento']),
      contaId: serializer.fromJson<int?>(json['conta_id']),
      cartaoId: serializer.fromJson<int?>(json['cartao_id']),
      mesFatura: serializer.fromJson<String?>(json['mes_fatura']),
      faturaManual: serializer.fromJson<int>(json['fatura_manual']),
      mesReferencia: serializer.fromJson<String>(json['mes_referencia']),
      parcelaAtual: serializer.fromJson<int?>(json['parcela_atual']),
      totalParcelas: serializer.fromJson<int?>(json['total_parcelas']),
      grupoParcelamento: serializer.fromJson<String?>(
        json['grupo_parcelamento'],
      ),
      recorrenciaId: serializer.fromJson<int?>(json['recorrencia_id']),
      observacao: serializer.fromJson<String?>(json['observacao']),
      criadoEm: serializer.fromJson<String>(json['criado_em']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tipo': serializer.toJson<String>(tipo),
      'descricao': serializer.toJson<String>(descricao),
      'valor_centavos': serializer.toJson<int>(valorCentavos),
      'data_lancamento': serializer.toJson<String>(dataLancamento),
      'conta_id': serializer.toJson<int?>(contaId),
      'cartao_id': serializer.toJson<int?>(cartaoId),
      'mes_fatura': serializer.toJson<String?>(mesFatura),
      'fatura_manual': serializer.toJson<int>(faturaManual),
      'mes_referencia': serializer.toJson<String>(mesReferencia),
      'parcela_atual': serializer.toJson<int?>(parcelaAtual),
      'total_parcelas': serializer.toJson<int?>(totalParcelas),
      'grupo_parcelamento': serializer.toJson<String?>(grupoParcelamento),
      'recorrencia_id': serializer.toJson<int?>(recorrenciaId),
      'observacao': serializer.toJson<String?>(observacao),
      'criado_em': serializer.toJson<String>(criadoEm),
    };
  }

  Lancamento copyWith({
    int? id,
    String? tipo,
    String? descricao,
    int? valorCentavos,
    String? dataLancamento,
    Value<int?> contaId = const Value.absent(),
    Value<int?> cartaoId = const Value.absent(),
    Value<String?> mesFatura = const Value.absent(),
    int? faturaManual,
    String? mesReferencia,
    Value<int?> parcelaAtual = const Value.absent(),
    Value<int?> totalParcelas = const Value.absent(),
    Value<String?> grupoParcelamento = const Value.absent(),
    Value<int?> recorrenciaId = const Value.absent(),
    Value<String?> observacao = const Value.absent(),
    String? criadoEm,
  }) => Lancamento(
    id: id ?? this.id,
    tipo: tipo ?? this.tipo,
    descricao: descricao ?? this.descricao,
    valorCentavos: valorCentavos ?? this.valorCentavos,
    dataLancamento: dataLancamento ?? this.dataLancamento,
    contaId: contaId.present ? contaId.value : this.contaId,
    cartaoId: cartaoId.present ? cartaoId.value : this.cartaoId,
    mesFatura: mesFatura.present ? mesFatura.value : this.mesFatura,
    faturaManual: faturaManual ?? this.faturaManual,
    mesReferencia: mesReferencia ?? this.mesReferencia,
    parcelaAtual: parcelaAtual.present ? parcelaAtual.value : this.parcelaAtual,
    totalParcelas: totalParcelas.present
        ? totalParcelas.value
        : this.totalParcelas,
    grupoParcelamento: grupoParcelamento.present
        ? grupoParcelamento.value
        : this.grupoParcelamento,
    recorrenciaId: recorrenciaId.present
        ? recorrenciaId.value
        : this.recorrenciaId,
    observacao: observacao.present ? observacao.value : this.observacao,
    criadoEm: criadoEm ?? this.criadoEm,
  );
  Lancamento copyWithCompanion(LancamentosCompanion data) {
    return Lancamento(
      id: data.id.present ? data.id.value : this.id,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      descricao: data.descricao.present ? data.descricao.value : this.descricao,
      valorCentavos: data.valorCentavos.present
          ? data.valorCentavos.value
          : this.valorCentavos,
      dataLancamento: data.dataLancamento.present
          ? data.dataLancamento.value
          : this.dataLancamento,
      contaId: data.contaId.present ? data.contaId.value : this.contaId,
      cartaoId: data.cartaoId.present ? data.cartaoId.value : this.cartaoId,
      mesFatura: data.mesFatura.present ? data.mesFatura.value : this.mesFatura,
      faturaManual: data.faturaManual.present
          ? data.faturaManual.value
          : this.faturaManual,
      mesReferencia: data.mesReferencia.present
          ? data.mesReferencia.value
          : this.mesReferencia,
      parcelaAtual: data.parcelaAtual.present
          ? data.parcelaAtual.value
          : this.parcelaAtual,
      totalParcelas: data.totalParcelas.present
          ? data.totalParcelas.value
          : this.totalParcelas,
      grupoParcelamento: data.grupoParcelamento.present
          ? data.grupoParcelamento.value
          : this.grupoParcelamento,
      recorrenciaId: data.recorrenciaId.present
          ? data.recorrenciaId.value
          : this.recorrenciaId,
      observacao: data.observacao.present
          ? data.observacao.value
          : this.observacao,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Lancamento(')
          ..write('id: $id, ')
          ..write('tipo: $tipo, ')
          ..write('descricao: $descricao, ')
          ..write('valorCentavos: $valorCentavos, ')
          ..write('dataLancamento: $dataLancamento, ')
          ..write('contaId: $contaId, ')
          ..write('cartaoId: $cartaoId, ')
          ..write('mesFatura: $mesFatura, ')
          ..write('faturaManual: $faturaManual, ')
          ..write('mesReferencia: $mesReferencia, ')
          ..write('parcelaAtual: $parcelaAtual, ')
          ..write('totalParcelas: $totalParcelas, ')
          ..write('grupoParcelamento: $grupoParcelamento, ')
          ..write('recorrenciaId: $recorrenciaId, ')
          ..write('observacao: $observacao, ')
          ..write('criadoEm: $criadoEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tipo,
    descricao,
    valorCentavos,
    dataLancamento,
    contaId,
    cartaoId,
    mesFatura,
    faturaManual,
    mesReferencia,
    parcelaAtual,
    totalParcelas,
    grupoParcelamento,
    recorrenciaId,
    observacao,
    criadoEm,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Lancamento &&
          other.id == this.id &&
          other.tipo == this.tipo &&
          other.descricao == this.descricao &&
          other.valorCentavos == this.valorCentavos &&
          other.dataLancamento == this.dataLancamento &&
          other.contaId == this.contaId &&
          other.cartaoId == this.cartaoId &&
          other.mesFatura == this.mesFatura &&
          other.faturaManual == this.faturaManual &&
          other.mesReferencia == this.mesReferencia &&
          other.parcelaAtual == this.parcelaAtual &&
          other.totalParcelas == this.totalParcelas &&
          other.grupoParcelamento == this.grupoParcelamento &&
          other.recorrenciaId == this.recorrenciaId &&
          other.observacao == this.observacao &&
          other.criadoEm == this.criadoEm);
}

class LancamentosCompanion extends UpdateCompanion<Lancamento> {
  final Value<int> id;
  final Value<String> tipo;
  final Value<String> descricao;
  final Value<int> valorCentavos;
  final Value<String> dataLancamento;
  final Value<int?> contaId;
  final Value<int?> cartaoId;
  final Value<String?> mesFatura;
  final Value<int> faturaManual;
  final Value<String> mesReferencia;
  final Value<int?> parcelaAtual;
  final Value<int?> totalParcelas;
  final Value<String?> grupoParcelamento;
  final Value<int?> recorrenciaId;
  final Value<String?> observacao;
  final Value<String> criadoEm;
  const LancamentosCompanion({
    this.id = const Value.absent(),
    this.tipo = const Value.absent(),
    this.descricao = const Value.absent(),
    this.valorCentavos = const Value.absent(),
    this.dataLancamento = const Value.absent(),
    this.contaId = const Value.absent(),
    this.cartaoId = const Value.absent(),
    this.mesFatura = const Value.absent(),
    this.faturaManual = const Value.absent(),
    this.mesReferencia = const Value.absent(),
    this.parcelaAtual = const Value.absent(),
    this.totalParcelas = const Value.absent(),
    this.grupoParcelamento = const Value.absent(),
    this.recorrenciaId = const Value.absent(),
    this.observacao = const Value.absent(),
    this.criadoEm = const Value.absent(),
  });
  LancamentosCompanion.insert({
    this.id = const Value.absent(),
    required String tipo,
    required String descricao,
    required int valorCentavos,
    required String dataLancamento,
    this.contaId = const Value.absent(),
    this.cartaoId = const Value.absent(),
    this.mesFatura = const Value.absent(),
    this.faturaManual = const Value.absent(),
    required String mesReferencia,
    this.parcelaAtual = const Value.absent(),
    this.totalParcelas = const Value.absent(),
    this.grupoParcelamento = const Value.absent(),
    this.recorrenciaId = const Value.absent(),
    this.observacao = const Value.absent(),
    required String criadoEm,
  }) : tipo = Value(tipo),
       descricao = Value(descricao),
       valorCentavos = Value(valorCentavos),
       dataLancamento = Value(dataLancamento),
       mesReferencia = Value(mesReferencia),
       criadoEm = Value(criadoEm);
  static Insertable<Lancamento> custom({
    Expression<int>? id,
    Expression<String>? tipo,
    Expression<String>? descricao,
    Expression<int>? valorCentavos,
    Expression<String>? dataLancamento,
    Expression<int>? contaId,
    Expression<int>? cartaoId,
    Expression<String>? mesFatura,
    Expression<int>? faturaManual,
    Expression<String>? mesReferencia,
    Expression<int>? parcelaAtual,
    Expression<int>? totalParcelas,
    Expression<String>? grupoParcelamento,
    Expression<int>? recorrenciaId,
    Expression<String>? observacao,
    Expression<String>? criadoEm,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tipo != null) 'tipo': tipo,
      if (descricao != null) 'descricao': descricao,
      if (valorCentavos != null) 'valor_centavos': valorCentavos,
      if (dataLancamento != null) 'data_lancamento': dataLancamento,
      if (contaId != null) 'conta_id': contaId,
      if (cartaoId != null) 'cartao_id': cartaoId,
      if (mesFatura != null) 'mes_fatura': mesFatura,
      if (faturaManual != null) 'fatura_manual': faturaManual,
      if (mesReferencia != null) 'mes_referencia': mesReferencia,
      if (parcelaAtual != null) 'parcela_atual': parcelaAtual,
      if (totalParcelas != null) 'total_parcelas': totalParcelas,
      if (grupoParcelamento != null) 'grupo_parcelamento': grupoParcelamento,
      if (recorrenciaId != null) 'recorrencia_id': recorrenciaId,
      if (observacao != null) 'observacao': observacao,
      if (criadoEm != null) 'criado_em': criadoEm,
    });
  }

  LancamentosCompanion copyWith({
    Value<int>? id,
    Value<String>? tipo,
    Value<String>? descricao,
    Value<int>? valorCentavos,
    Value<String>? dataLancamento,
    Value<int?>? contaId,
    Value<int?>? cartaoId,
    Value<String?>? mesFatura,
    Value<int>? faturaManual,
    Value<String>? mesReferencia,
    Value<int?>? parcelaAtual,
    Value<int?>? totalParcelas,
    Value<String?>? grupoParcelamento,
    Value<int?>? recorrenciaId,
    Value<String?>? observacao,
    Value<String>? criadoEm,
  }) {
    return LancamentosCompanion(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      descricao: descricao ?? this.descricao,
      valorCentavos: valorCentavos ?? this.valorCentavos,
      dataLancamento: dataLancamento ?? this.dataLancamento,
      contaId: contaId ?? this.contaId,
      cartaoId: cartaoId ?? this.cartaoId,
      mesFatura: mesFatura ?? this.mesFatura,
      faturaManual: faturaManual ?? this.faturaManual,
      mesReferencia: mesReferencia ?? this.mesReferencia,
      parcelaAtual: parcelaAtual ?? this.parcelaAtual,
      totalParcelas: totalParcelas ?? this.totalParcelas,
      grupoParcelamento: grupoParcelamento ?? this.grupoParcelamento,
      recorrenciaId: recorrenciaId ?? this.recorrenciaId,
      observacao: observacao ?? this.observacao,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (descricao.present) {
      map['descricao'] = Variable<String>(descricao.value);
    }
    if (valorCentavos.present) {
      map['valor_centavos'] = Variable<int>(valorCentavos.value);
    }
    if (dataLancamento.present) {
      map['data_lancamento'] = Variable<String>(dataLancamento.value);
    }
    if (contaId.present) {
      map['conta_id'] = Variable<int>(contaId.value);
    }
    if (cartaoId.present) {
      map['cartao_id'] = Variable<int>(cartaoId.value);
    }
    if (mesFatura.present) {
      map['mes_fatura'] = Variable<String>(mesFatura.value);
    }
    if (faturaManual.present) {
      map['fatura_manual'] = Variable<int>(faturaManual.value);
    }
    if (mesReferencia.present) {
      map['mes_referencia'] = Variable<String>(mesReferencia.value);
    }
    if (parcelaAtual.present) {
      map['parcela_atual'] = Variable<int>(parcelaAtual.value);
    }
    if (totalParcelas.present) {
      map['total_parcelas'] = Variable<int>(totalParcelas.value);
    }
    if (grupoParcelamento.present) {
      map['grupo_parcelamento'] = Variable<String>(grupoParcelamento.value);
    }
    if (recorrenciaId.present) {
      map['recorrencia_id'] = Variable<int>(recorrenciaId.value);
    }
    if (observacao.present) {
      map['observacao'] = Variable<String>(observacao.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<String>(criadoEm.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LancamentosCompanion(')
          ..write('id: $id, ')
          ..write('tipo: $tipo, ')
          ..write('descricao: $descricao, ')
          ..write('valorCentavos: $valorCentavos, ')
          ..write('dataLancamento: $dataLancamento, ')
          ..write('contaId: $contaId, ')
          ..write('cartaoId: $cartaoId, ')
          ..write('mesFatura: $mesFatura, ')
          ..write('faturaManual: $faturaManual, ')
          ..write('mesReferencia: $mesReferencia, ')
          ..write('parcelaAtual: $parcelaAtual, ')
          ..write('totalParcelas: $totalParcelas, ')
          ..write('grupoParcelamento: $grupoParcelamento, ')
          ..write('recorrenciaId: $recorrenciaId, ')
          ..write('observacao: $observacao, ')
          ..write('criadoEm: $criadoEm')
          ..write(')'))
        .toString();
  }
}

class LancamentoCategorias extends Table
    with TableInfo<LancamentoCategorias, LancamentoCategoria> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  LancamentoCategorias(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _lancamentoIdMeta = const VerificationMeta(
    'lancamentoId',
  );
  late final GeneratedColumn<int> lancamentoId = GeneratedColumn<int>(
    'lancamento_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES lancamentos(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _categoriaIdMeta = const VerificationMeta(
    'categoriaId',
  );
  late final GeneratedColumn<int> categoriaId = GeneratedColumn<int>(
    'categoria_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES categorias(id)',
  );
  static const VerificationMeta _valorCentavosMeta = const VerificationMeta(
    'valorCentavos',
  );
  late final GeneratedColumn<int> valorCentavos = GeneratedColumn<int>(
    'valor_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (valor_centavos > 0)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    lancamentoId,
    categoriaId,
    valorCentavos,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lancamento_categorias';
  @override
  VerificationContext validateIntegrity(
    Insertable<LancamentoCategoria> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('lancamento_id')) {
      context.handle(
        _lancamentoIdMeta,
        lancamentoId.isAcceptableOrUnknown(
          data['lancamento_id']!,
          _lancamentoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lancamentoIdMeta);
    }
    if (data.containsKey('categoria_id')) {
      context.handle(
        _categoriaIdMeta,
        categoriaId.isAcceptableOrUnknown(
          data['categoria_id']!,
          _categoriaIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoriaIdMeta);
    }
    if (data.containsKey('valor_centavos')) {
      context.handle(
        _valorCentavosMeta,
        valorCentavos.isAcceptableOrUnknown(
          data['valor_centavos']!,
          _valorCentavosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_valorCentavosMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {lancamentoId, categoriaId};
  @override
  LancamentoCategoria map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LancamentoCategoria(
      lancamentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lancamento_id'],
      )!,
      categoriaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}categoria_id'],
      )!,
      valorCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}valor_centavos'],
      )!,
    );
  }

  @override
  LancamentoCategorias createAlias(String alias) {
    return LancamentoCategorias(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(lancamento_id, categoria_id)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class LancamentoCategoria extends DataClass
    implements Insertable<LancamentoCategoria> {
  final int lancamentoId;
  final int categoriaId;
  final int valorCentavos;
  const LancamentoCategoria({
    required this.lancamentoId,
    required this.categoriaId,
    required this.valorCentavos,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['lancamento_id'] = Variable<int>(lancamentoId);
    map['categoria_id'] = Variable<int>(categoriaId);
    map['valor_centavos'] = Variable<int>(valorCentavos);
    return map;
  }

  LancamentoCategoriasCompanion toCompanion(bool nullToAbsent) {
    return LancamentoCategoriasCompanion(
      lancamentoId: Value(lancamentoId),
      categoriaId: Value(categoriaId),
      valorCentavos: Value(valorCentavos),
    );
  }

  factory LancamentoCategoria.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LancamentoCategoria(
      lancamentoId: serializer.fromJson<int>(json['lancamento_id']),
      categoriaId: serializer.fromJson<int>(json['categoria_id']),
      valorCentavos: serializer.fromJson<int>(json['valor_centavos']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'lancamento_id': serializer.toJson<int>(lancamentoId),
      'categoria_id': serializer.toJson<int>(categoriaId),
      'valor_centavos': serializer.toJson<int>(valorCentavos),
    };
  }

  LancamentoCategoria copyWith({
    int? lancamentoId,
    int? categoriaId,
    int? valorCentavos,
  }) => LancamentoCategoria(
    lancamentoId: lancamentoId ?? this.lancamentoId,
    categoriaId: categoriaId ?? this.categoriaId,
    valorCentavos: valorCentavos ?? this.valorCentavos,
  );
  LancamentoCategoria copyWithCompanion(LancamentoCategoriasCompanion data) {
    return LancamentoCategoria(
      lancamentoId: data.lancamentoId.present
          ? data.lancamentoId.value
          : this.lancamentoId,
      categoriaId: data.categoriaId.present
          ? data.categoriaId.value
          : this.categoriaId,
      valorCentavos: data.valorCentavos.present
          ? data.valorCentavos.value
          : this.valorCentavos,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LancamentoCategoria(')
          ..write('lancamentoId: $lancamentoId, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('valorCentavos: $valorCentavos')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(lancamentoId, categoriaId, valorCentavos);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LancamentoCategoria &&
          other.lancamentoId == this.lancamentoId &&
          other.categoriaId == this.categoriaId &&
          other.valorCentavos == this.valorCentavos);
}

class LancamentoCategoriasCompanion
    extends UpdateCompanion<LancamentoCategoria> {
  final Value<int> lancamentoId;
  final Value<int> categoriaId;
  final Value<int> valorCentavos;
  final Value<int> rowid;
  const LancamentoCategoriasCompanion({
    this.lancamentoId = const Value.absent(),
    this.categoriaId = const Value.absent(),
    this.valorCentavos = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LancamentoCategoriasCompanion.insert({
    required int lancamentoId,
    required int categoriaId,
    required int valorCentavos,
    this.rowid = const Value.absent(),
  }) : lancamentoId = Value(lancamentoId),
       categoriaId = Value(categoriaId),
       valorCentavos = Value(valorCentavos);
  static Insertable<LancamentoCategoria> custom({
    Expression<int>? lancamentoId,
    Expression<int>? categoriaId,
    Expression<int>? valorCentavos,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (lancamentoId != null) 'lancamento_id': lancamentoId,
      if (categoriaId != null) 'categoria_id': categoriaId,
      if (valorCentavos != null) 'valor_centavos': valorCentavos,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LancamentoCategoriasCompanion copyWith({
    Value<int>? lancamentoId,
    Value<int>? categoriaId,
    Value<int>? valorCentavos,
    Value<int>? rowid,
  }) {
    return LancamentoCategoriasCompanion(
      lancamentoId: lancamentoId ?? this.lancamentoId,
      categoriaId: categoriaId ?? this.categoriaId,
      valorCentavos: valorCentavos ?? this.valorCentavos,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (lancamentoId.present) {
      map['lancamento_id'] = Variable<int>(lancamentoId.value);
    }
    if (categoriaId.present) {
      map['categoria_id'] = Variable<int>(categoriaId.value);
    }
    if (valorCentavos.present) {
      map['valor_centavos'] = Variable<int>(valorCentavos.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LancamentoCategoriasCompanion(')
          ..write('lancamentoId: $lancamentoId, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('valorCentavos: $valorCentavos, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class LancamentoTags extends Table
    with TableInfo<LancamentoTags, LancamentoTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  LancamentoTags(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _lancamentoIdMeta = const VerificationMeta(
    'lancamentoId',
  );
  late final GeneratedColumn<int> lancamentoId = GeneratedColumn<int>(
    'lancamento_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES lancamentos(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES tags(id)',
  );
  @override
  List<GeneratedColumn> get $columns => [lancamentoId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lancamento_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<LancamentoTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('lancamento_id')) {
      context.handle(
        _lancamentoIdMeta,
        lancamentoId.isAcceptableOrUnknown(
          data['lancamento_id']!,
          _lancamentoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lancamentoIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {lancamentoId, tagId};
  @override
  LancamentoTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LancamentoTag(
      lancamentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lancamento_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  LancamentoTags createAlias(String alias) {
    return LancamentoTags(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(lancamento_id, tag_id)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class LancamentoTag extends DataClass implements Insertable<LancamentoTag> {
  final int lancamentoId;
  final int tagId;
  const LancamentoTag({required this.lancamentoId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['lancamento_id'] = Variable<int>(lancamentoId);
    map['tag_id'] = Variable<int>(tagId);
    return map;
  }

  LancamentoTagsCompanion toCompanion(bool nullToAbsent) {
    return LancamentoTagsCompanion(
      lancamentoId: Value(lancamentoId),
      tagId: Value(tagId),
    );
  }

  factory LancamentoTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LancamentoTag(
      lancamentoId: serializer.fromJson<int>(json['lancamento_id']),
      tagId: serializer.fromJson<int>(json['tag_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'lancamento_id': serializer.toJson<int>(lancamentoId),
      'tag_id': serializer.toJson<int>(tagId),
    };
  }

  LancamentoTag copyWith({int? lancamentoId, int? tagId}) => LancamentoTag(
    lancamentoId: lancamentoId ?? this.lancamentoId,
    tagId: tagId ?? this.tagId,
  );
  LancamentoTag copyWithCompanion(LancamentoTagsCompanion data) {
    return LancamentoTag(
      lancamentoId: data.lancamentoId.present
          ? data.lancamentoId.value
          : this.lancamentoId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LancamentoTag(')
          ..write('lancamentoId: $lancamentoId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(lancamentoId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LancamentoTag &&
          other.lancamentoId == this.lancamentoId &&
          other.tagId == this.tagId);
}

class LancamentoTagsCompanion extends UpdateCompanion<LancamentoTag> {
  final Value<int> lancamentoId;
  final Value<int> tagId;
  final Value<int> rowid;
  const LancamentoTagsCompanion({
    this.lancamentoId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LancamentoTagsCompanion.insert({
    required int lancamentoId,
    required int tagId,
    this.rowid = const Value.absent(),
  }) : lancamentoId = Value(lancamentoId),
       tagId = Value(tagId);
  static Insertable<LancamentoTag> custom({
    Expression<int>? lancamentoId,
    Expression<int>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (lancamentoId != null) 'lancamento_id': lancamentoId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LancamentoTagsCompanion copyWith({
    Value<int>? lancamentoId,
    Value<int>? tagId,
    Value<int>? rowid,
  }) {
    return LancamentoTagsCompanion(
      lancamentoId: lancamentoId ?? this.lancamentoId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (lancamentoId.present) {
      map['lancamento_id'] = Variable<int>(lancamentoId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LancamentoTagsCompanion(')
          ..write('lancamentoId: $lancamentoId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Transferencias extends Table
    with TableInfo<Transferencias, Transferencia> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Transferencias(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _valorCentavosMeta = const VerificationMeta(
    'valorCentavos',
  );
  late final GeneratedColumn<int> valorCentavos = GeneratedColumn<int>(
    'valor_centavos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (valor_centavos > 0)',
  );
  static const VerificationMeta _contaOrigemIdMeta = const VerificationMeta(
    'contaOrigemId',
  );
  late final GeneratedColumn<int> contaOrigemId = GeneratedColumn<int>(
    'conta_origem_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES contas(id)',
  );
  static const VerificationMeta _contaDestinoIdMeta = const VerificationMeta(
    'contaDestinoId',
  );
  late final GeneratedColumn<int> contaDestinoId = GeneratedColumn<int>(
    'conta_destino_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES contas(id)',
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _recorrenciaIdMeta = const VerificationMeta(
    'recorrenciaId',
  );
  late final GeneratedColumn<int> recorrenciaId = GeneratedColumn<int>(
    'recorrencia_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES recorrencias(id)',
  );
  static const VerificationMeta _observacaoMeta = const VerificationMeta(
    'observacao',
  );
  late final GeneratedColumn<String> observacao = GeneratedColumn<String>(
    'observacao',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  late final GeneratedColumn<String> criadoEm = GeneratedColumn<String>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    valorCentavos,
    contaOrigemId,
    contaDestinoId,
    data,
    recorrenciaId,
    observacao,
    criadoEm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transferencias';
  @override
  VerificationContext validateIntegrity(
    Insertable<Transferencia> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('valor_centavos')) {
      context.handle(
        _valorCentavosMeta,
        valorCentavos.isAcceptableOrUnknown(
          data['valor_centavos']!,
          _valorCentavosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_valorCentavosMeta);
    }
    if (data.containsKey('conta_origem_id')) {
      context.handle(
        _contaOrigemIdMeta,
        contaOrigemId.isAcceptableOrUnknown(
          data['conta_origem_id']!,
          _contaOrigemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contaOrigemIdMeta);
    }
    if (data.containsKey('conta_destino_id')) {
      context.handle(
        _contaDestinoIdMeta,
        contaDestinoId.isAcceptableOrUnknown(
          data['conta_destino_id']!,
          _contaDestinoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contaDestinoIdMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('recorrencia_id')) {
      context.handle(
        _recorrenciaIdMeta,
        recorrenciaId.isAcceptableOrUnknown(
          data['recorrencia_id']!,
          _recorrenciaIdMeta,
        ),
      );
    }
    if (data.containsKey('observacao')) {
      context.handle(
        _observacaoMeta,
        observacao.isAcceptableOrUnknown(data['observacao']!, _observacaoMeta),
      );
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    } else if (isInserting) {
      context.missing(_criadoEmMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Transferencia map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Transferencia(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      valorCentavos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}valor_centavos'],
      )!,
      contaOrigemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conta_origem_id'],
      )!,
      contaDestinoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conta_destino_id'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data'],
      )!,
      recorrenciaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recorrencia_id'],
      ),
      observacao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observacao'],
      ),
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}criado_em'],
      )!,
    );
  }

  @override
  Transferencias createAlias(String alias) {
    return Transferencias(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'CHECK(conta_origem_id <> conta_destino_id)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class Transferencia extends DataClass implements Insertable<Transferencia> {
  final int id;
  final int valorCentavos;
  final int contaOrigemId;
  final int contaDestinoId;
  final String data;

  /// AAAA-MM-DD
  final int? recorrenciaId;
  final String? observacao;
  final String criadoEm;
  const Transferencia({
    required this.id,
    required this.valorCentavos,
    required this.contaOrigemId,
    required this.contaDestinoId,
    required this.data,
    this.recorrenciaId,
    this.observacao,
    required this.criadoEm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['valor_centavos'] = Variable<int>(valorCentavos);
    map['conta_origem_id'] = Variable<int>(contaOrigemId);
    map['conta_destino_id'] = Variable<int>(contaDestinoId);
    map['data'] = Variable<String>(data);
    if (!nullToAbsent || recorrenciaId != null) {
      map['recorrencia_id'] = Variable<int>(recorrenciaId);
    }
    if (!nullToAbsent || observacao != null) {
      map['observacao'] = Variable<String>(observacao);
    }
    map['criado_em'] = Variable<String>(criadoEm);
    return map;
  }

  TransferenciasCompanion toCompanion(bool nullToAbsent) {
    return TransferenciasCompanion(
      id: Value(id),
      valorCentavos: Value(valorCentavos),
      contaOrigemId: Value(contaOrigemId),
      contaDestinoId: Value(contaDestinoId),
      data: Value(data),
      recorrenciaId: recorrenciaId == null && nullToAbsent
          ? const Value.absent()
          : Value(recorrenciaId),
      observacao: observacao == null && nullToAbsent
          ? const Value.absent()
          : Value(observacao),
      criadoEm: Value(criadoEm),
    );
  }

  factory Transferencia.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Transferencia(
      id: serializer.fromJson<int>(json['id']),
      valorCentavos: serializer.fromJson<int>(json['valor_centavos']),
      contaOrigemId: serializer.fromJson<int>(json['conta_origem_id']),
      contaDestinoId: serializer.fromJson<int>(json['conta_destino_id']),
      data: serializer.fromJson<String>(json['data']),
      recorrenciaId: serializer.fromJson<int?>(json['recorrencia_id']),
      observacao: serializer.fromJson<String?>(json['observacao']),
      criadoEm: serializer.fromJson<String>(json['criado_em']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'valor_centavos': serializer.toJson<int>(valorCentavos),
      'conta_origem_id': serializer.toJson<int>(contaOrigemId),
      'conta_destino_id': serializer.toJson<int>(contaDestinoId),
      'data': serializer.toJson<String>(data),
      'recorrencia_id': serializer.toJson<int?>(recorrenciaId),
      'observacao': serializer.toJson<String?>(observacao),
      'criado_em': serializer.toJson<String>(criadoEm),
    };
  }

  Transferencia copyWith({
    int? id,
    int? valorCentavos,
    int? contaOrigemId,
    int? contaDestinoId,
    String? data,
    Value<int?> recorrenciaId = const Value.absent(),
    Value<String?> observacao = const Value.absent(),
    String? criadoEm,
  }) => Transferencia(
    id: id ?? this.id,
    valorCentavos: valorCentavos ?? this.valorCentavos,
    contaOrigemId: contaOrigemId ?? this.contaOrigemId,
    contaDestinoId: contaDestinoId ?? this.contaDestinoId,
    data: data ?? this.data,
    recorrenciaId: recorrenciaId.present
        ? recorrenciaId.value
        : this.recorrenciaId,
    observacao: observacao.present ? observacao.value : this.observacao,
    criadoEm: criadoEm ?? this.criadoEm,
  );
  Transferencia copyWithCompanion(TransferenciasCompanion data) {
    return Transferencia(
      id: data.id.present ? data.id.value : this.id,
      valorCentavos: data.valorCentavos.present
          ? data.valorCentavos.value
          : this.valorCentavos,
      contaOrigemId: data.contaOrigemId.present
          ? data.contaOrigemId.value
          : this.contaOrigemId,
      contaDestinoId: data.contaDestinoId.present
          ? data.contaDestinoId.value
          : this.contaDestinoId,
      data: data.data.present ? data.data.value : this.data,
      recorrenciaId: data.recorrenciaId.present
          ? data.recorrenciaId.value
          : this.recorrenciaId,
      observacao: data.observacao.present
          ? data.observacao.value
          : this.observacao,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Transferencia(')
          ..write('id: $id, ')
          ..write('valorCentavos: $valorCentavos, ')
          ..write('contaOrigemId: $contaOrigemId, ')
          ..write('contaDestinoId: $contaDestinoId, ')
          ..write('data: $data, ')
          ..write('recorrenciaId: $recorrenciaId, ')
          ..write('observacao: $observacao, ')
          ..write('criadoEm: $criadoEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    valorCentavos,
    contaOrigemId,
    contaDestinoId,
    data,
    recorrenciaId,
    observacao,
    criadoEm,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Transferencia &&
          other.id == this.id &&
          other.valorCentavos == this.valorCentavos &&
          other.contaOrigemId == this.contaOrigemId &&
          other.contaDestinoId == this.contaDestinoId &&
          other.data == this.data &&
          other.recorrenciaId == this.recorrenciaId &&
          other.observacao == this.observacao &&
          other.criadoEm == this.criadoEm);
}

class TransferenciasCompanion extends UpdateCompanion<Transferencia> {
  final Value<int> id;
  final Value<int> valorCentavos;
  final Value<int> contaOrigemId;
  final Value<int> contaDestinoId;
  final Value<String> data;
  final Value<int?> recorrenciaId;
  final Value<String?> observacao;
  final Value<String> criadoEm;
  const TransferenciasCompanion({
    this.id = const Value.absent(),
    this.valorCentavos = const Value.absent(),
    this.contaOrigemId = const Value.absent(),
    this.contaDestinoId = const Value.absent(),
    this.data = const Value.absent(),
    this.recorrenciaId = const Value.absent(),
    this.observacao = const Value.absent(),
    this.criadoEm = const Value.absent(),
  });
  TransferenciasCompanion.insert({
    this.id = const Value.absent(),
    required int valorCentavos,
    required int contaOrigemId,
    required int contaDestinoId,
    required String data,
    this.recorrenciaId = const Value.absent(),
    this.observacao = const Value.absent(),
    required String criadoEm,
  }) : valorCentavos = Value(valorCentavos),
       contaOrigemId = Value(contaOrigemId),
       contaDestinoId = Value(contaDestinoId),
       data = Value(data),
       criadoEm = Value(criadoEm);
  static Insertable<Transferencia> custom({
    Expression<int>? id,
    Expression<int>? valorCentavos,
    Expression<int>? contaOrigemId,
    Expression<int>? contaDestinoId,
    Expression<String>? data,
    Expression<int>? recorrenciaId,
    Expression<String>? observacao,
    Expression<String>? criadoEm,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (valorCentavos != null) 'valor_centavos': valorCentavos,
      if (contaOrigemId != null) 'conta_origem_id': contaOrigemId,
      if (contaDestinoId != null) 'conta_destino_id': contaDestinoId,
      if (data != null) 'data': data,
      if (recorrenciaId != null) 'recorrencia_id': recorrenciaId,
      if (observacao != null) 'observacao': observacao,
      if (criadoEm != null) 'criado_em': criadoEm,
    });
  }

  TransferenciasCompanion copyWith({
    Value<int>? id,
    Value<int>? valorCentavos,
    Value<int>? contaOrigemId,
    Value<int>? contaDestinoId,
    Value<String>? data,
    Value<int?>? recorrenciaId,
    Value<String?>? observacao,
    Value<String>? criadoEm,
  }) {
    return TransferenciasCompanion(
      id: id ?? this.id,
      valorCentavos: valorCentavos ?? this.valorCentavos,
      contaOrigemId: contaOrigemId ?? this.contaOrigemId,
      contaDestinoId: contaDestinoId ?? this.contaDestinoId,
      data: data ?? this.data,
      recorrenciaId: recorrenciaId ?? this.recorrenciaId,
      observacao: observacao ?? this.observacao,
      criadoEm: criadoEm ?? this.criadoEm,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (valorCentavos.present) {
      map['valor_centavos'] = Variable<int>(valorCentavos.value);
    }
    if (contaOrigemId.present) {
      map['conta_origem_id'] = Variable<int>(contaOrigemId.value);
    }
    if (contaDestinoId.present) {
      map['conta_destino_id'] = Variable<int>(contaDestinoId.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (recorrenciaId.present) {
      map['recorrencia_id'] = Variable<int>(recorrenciaId.value);
    }
    if (observacao.present) {
      map['observacao'] = Variable<String>(observacao.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<String>(criadoEm.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransferenciasCompanion(')
          ..write('id: $id, ')
          ..write('valorCentavos: $valorCentavos, ')
          ..write('contaOrigemId: $contaOrigemId, ')
          ..write('contaDestinoId: $contaDestinoId, ')
          ..write('data: $data, ')
          ..write('recorrenciaId: $recorrenciaId, ')
          ..write('observacao: $observacao, ')
          ..write('criadoEm: $criadoEm')
          ..write(')'))
        .toString();
  }
}

class Configuracoes extends Table with TableInfo<Configuracoes, Configuracao> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Configuracoes(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chaveMeta = const VerificationMeta('chave');
  late final GeneratedColumn<String> chave = GeneratedColumn<String>(
    'chave',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  late final GeneratedColumn<String> valor = GeneratedColumn<String>(
    'valor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [chave, valor];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'configuracoes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Configuracao> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chave')) {
      context.handle(
        _chaveMeta,
        chave.isAcceptableOrUnknown(data['chave']!, _chaveMeta),
      );
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chave};
  @override
  Configuracao map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Configuracao(
      chave: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chave'],
      ),
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valor'],
      )!,
    );
  }

  @override
  Configuracoes createAlias(String alias) {
    return Configuracoes(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Configuracao extends DataClass implements Insertable<Configuracao> {
  final String? chave;
  final String valor;
  const Configuracao({this.chave, required this.valor});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || chave != null) {
      map['chave'] = Variable<String>(chave);
    }
    map['valor'] = Variable<String>(valor);
    return map;
  }

  ConfiguracoesCompanion toCompanion(bool nullToAbsent) {
    return ConfiguracoesCompanion(
      chave: chave == null && nullToAbsent
          ? const Value.absent()
          : Value(chave),
      valor: Value(valor),
    );
  }

  factory Configuracao.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Configuracao(
      chave: serializer.fromJson<String?>(json['chave']),
      valor: serializer.fromJson<String>(json['valor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chave': serializer.toJson<String?>(chave),
      'valor': serializer.toJson<String>(valor),
    };
  }

  Configuracao copyWith({
    Value<String?> chave = const Value.absent(),
    String? valor,
  }) => Configuracao(
    chave: chave.present ? chave.value : this.chave,
    valor: valor ?? this.valor,
  );
  Configuracao copyWithCompanion(ConfiguracoesCompanion data) {
    return Configuracao(
      chave: data.chave.present ? data.chave.value : this.chave,
      valor: data.valor.present ? data.valor.value : this.valor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Configuracao(')
          ..write('chave: $chave, ')
          ..write('valor: $valor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(chave, valor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Configuracao &&
          other.chave == this.chave &&
          other.valor == this.valor);
}

class ConfiguracoesCompanion extends UpdateCompanion<Configuracao> {
  final Value<String?> chave;
  final Value<String> valor;
  final Value<int> rowid;
  const ConfiguracoesCompanion({
    this.chave = const Value.absent(),
    this.valor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConfiguracoesCompanion.insert({
    this.chave = const Value.absent(),
    required String valor,
    this.rowid = const Value.absent(),
  }) : valor = Value(valor);
  static Insertable<Configuracao> custom({
    Expression<String>? chave,
    Expression<String>? valor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chave != null) 'chave': chave,
      if (valor != null) 'valor': valor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConfiguracoesCompanion copyWith({
    Value<String?>? chave,
    Value<String>? valor,
    Value<int>? rowid,
  }) {
    return ConfiguracoesCompanion(
      chave: chave ?? this.chave,
      valor: valor ?? this.valor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chave.present) {
      map['chave'] = Variable<String>(chave.value);
    }
    if (valor.present) {
      map['valor'] = Variable<String>(valor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConfiguracoesCompanion(')
          ..write('chave: $chave, ')
          ..write('valor: $valor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Filtros extends Table with TableInfo<Filtros, Filtro> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Filtros(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _criteriosJsonMeta = const VerificationMeta(
    'criteriosJson',
  );
  late final GeneratedColumn<String> criteriosJson = GeneratedColumn<String>(
    'criterios_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [id, nome, criteriosJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'filtros';
  @override
  VerificationContext validateIntegrity(
    Insertable<Filtro> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('criterios_json')) {
      context.handle(
        _criteriosJsonMeta,
        criteriosJson.isAcceptableOrUnknown(
          data['criterios_json']!,
          _criteriosJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_criteriosJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Filtro map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Filtro(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      criteriosJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}criterios_json'],
      )!,
    );
  }

  @override
  Filtros createAlias(String alias) {
    return Filtros(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Filtro extends DataClass implements Insertable<Filtro> {
  final int id;
  final String nome;
  final String criteriosJson;
  const Filtro({
    required this.id,
    required this.nome,
    required this.criteriosJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    map['criterios_json'] = Variable<String>(criteriosJson);
    return map;
  }

  FiltrosCompanion toCompanion(bool nullToAbsent) {
    return FiltrosCompanion(
      id: Value(id),
      nome: Value(nome),
      criteriosJson: Value(criteriosJson),
    );
  }

  factory Filtro.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Filtro(
      id: serializer.fromJson<int>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      criteriosJson: serializer.fromJson<String>(json['criterios_json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nome': serializer.toJson<String>(nome),
      'criterios_json': serializer.toJson<String>(criteriosJson),
    };
  }

  Filtro copyWith({int? id, String? nome, String? criteriosJson}) => Filtro(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    criteriosJson: criteriosJson ?? this.criteriosJson,
  );
  Filtro copyWithCompanion(FiltrosCompanion data) {
    return Filtro(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      criteriosJson: data.criteriosJson.present
          ? data.criteriosJson.value
          : this.criteriosJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Filtro(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('criteriosJson: $criteriosJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nome, criteriosJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Filtro &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.criteriosJson == this.criteriosJson);
}

class FiltrosCompanion extends UpdateCompanion<Filtro> {
  final Value<int> id;
  final Value<String> nome;
  final Value<String> criteriosJson;
  const FiltrosCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.criteriosJson = const Value.absent(),
  });
  FiltrosCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
    required String criteriosJson,
  }) : nome = Value(nome),
       criteriosJson = Value(criteriosJson);
  static Insertable<Filtro> custom({
    Expression<int>? id,
    Expression<String>? nome,
    Expression<String>? criteriosJson,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (criteriosJson != null) 'criterios_json': criteriosJson,
    });
  }

  FiltrosCompanion copyWith({
    Value<int>? id,
    Value<String>? nome,
    Value<String>? criteriosJson,
  }) {
    return FiltrosCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      criteriosJson: criteriosJson ?? this.criteriosJson,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (criteriosJson.present) {
      map['criterios_json'] = Variable<String>(criteriosJson.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FiltrosCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('criteriosJson: $criteriosJson')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final Contas contas = Contas(this);
  late final Cartoes cartoes = Cartoes(this);
  late final Faturas faturas = Faturas(this);
  late final Categorias categorias = Categorias(this);
  late final Tags tags = Tags(this);
  late final Recorrencias recorrencias = Recorrencias(this);
  late final Lancamentos lancamentos = Lancamentos(this);
  late final LancamentoCategorias lancamentoCategorias = LancamentoCategorias(
    this,
  );
  late final LancamentoTags lancamentoTags = LancamentoTags(this);
  late final Transferencias transferencias = Transferencias(this);
  late final Configuracoes configuracoes = Configuracoes(this);
  late final Filtros filtros = Filtros(this);
  late final Index idxLancMes = Index(
    'idx_lanc_mes',
    'CREATE INDEX idx_lanc_mes ON lancamentos (mes_referencia)',
  );
  late final Index idxLancData = Index(
    'idx_lanc_data',
    'CREATE INDEX idx_lanc_data ON lancamentos (data_lancamento)',
  );
  late final Index idxTransfData = Index(
    'idx_transf_data',
    'CREATE INDEX idx_transf_data ON transferencias (data)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    contas,
    cartoes,
    faturas,
    categorias,
    tags,
    recorrencias,
    lancamentos,
    lancamentoCategorias,
    lancamentoTags,
    transferencias,
    configuracoes,
    filtros,
    idxLancMes,
    idxLancData,
    idxTransfData,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'lancamentos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('lancamento_categorias', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'lancamentos',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('lancamento_tags', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $ContasCreateCompanionBuilder = ContasCompanion Function({
  Value<int> id,
  required String nome,
  required String tipo,
  Value<int> saldoInicialCentavos,
  required String dataSaldoInicial,
  Value<int> arquivada,
});
typedef $ContasUpdateCompanionBuilder = ContasCompanion Function({
  Value<int> id,
  Value<String> nome,
  Value<String> tipo,
  Value<int> saldoInicialCentavos,
  Value<String> dataSaldoInicial,
  Value<int> arquivada,
});

final class $ContasReferences
    extends BaseReferences<_$AppDatabase, Contas, Conta> {
  $ContasReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<Cartoes, List<Cartao>> _cartoesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.cartoes,
    aliasName: 'contas__id__cartoes__conta_pagamento_id',
  );

  $CartoesProcessedTableManager get cartoesRefs {
    final manager = $CartoesTableManager(
      $_db,
      $_db.cartoes,
    ).filter((f) => f.contaPagamentoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_cartoesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Faturas, List<Fatura>> _faturasRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.faturas,
    aliasName: 'contas__id__faturas__conta_pagamento_id',
  );

  $FaturasProcessedTableManager get faturasRefs {
    final manager = $FaturasTableManager(
      $_db,
      $_db.faturas,
    ).filter((f) => f.contaPagamentoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_faturasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Lancamentos, List<Lancamento>>
  _lancamentosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.lancamentos,
    aliasName: 'contas__id__lancamentos__conta_id',
  );

  $LancamentosProcessedTableManager get lancamentosRefs {
    final manager = $LancamentosTableManager(
      $_db,
      $_db.lancamentos,
    ).filter((f) => f.contaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_lancamentosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $ContasFilterComposer extends Composer<_$AppDatabase, Contas> {
  $ContasFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get saldoInicialCentavos => $composableBuilder(
    column: $table.saldoInicialCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataSaldoInicial => $composableBuilder(
    column: $table.dataSaldoInicial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get arquivada => $composableBuilder(
    column: $table.arquivada,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> cartoesRefs(
    Expression<bool> Function($CartoesFilterComposer f) f,
  ) {
    final $CartoesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cartoes,
      getReferencedColumn: (t) => t.contaPagamentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CartoesFilterComposer(
            $db: $db,
            $table: $db.cartoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> faturasRefs(
    Expression<bool> Function($FaturasFilterComposer f) f,
  ) {
    final $FaturasFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.faturas,
      getReferencedColumn: (t) => t.contaPagamentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FaturasFilterComposer(
            $db: $db,
            $table: $db.faturas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> lancamentosRefs(
    Expression<bool> Function($LancamentosFilterComposer f) f,
  ) {
    final $LancamentosFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lancamentos,
      getReferencedColumn: (t) => t.contaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LancamentosFilterComposer(
            $db: $db,
            $table: $db.lancamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ContasOrderingComposer extends Composer<_$AppDatabase, Contas> {
  $ContasOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get saldoInicialCentavos => $composableBuilder(
    column: $table.saldoInicialCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataSaldoInicial => $composableBuilder(
    column: $table.dataSaldoInicial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get arquivada => $composableBuilder(
    column: $table.arquivada,
    builder: (column) => ColumnOrderings(column),
  );
}

class $ContasAnnotationComposer extends Composer<_$AppDatabase, Contas> {
  $ContasAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<int> get saldoInicialCentavos => $composableBuilder(
    column: $table.saldoInicialCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dataSaldoInicial => $composableBuilder(
    column: $table.dataSaldoInicial,
    builder: (column) => column,
  );

  GeneratedColumn<int> get arquivada =>
      $composableBuilder(column: $table.arquivada, builder: (column) => column);

  Expression<T> cartoesRefs<T extends Object>(
    Expression<T> Function($CartoesAnnotationComposer a) f,
  ) {
    final $CartoesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cartoes,
      getReferencedColumn: (t) => t.contaPagamentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CartoesAnnotationComposer(
            $db: $db,
            $table: $db.cartoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> faturasRefs<T extends Object>(
    Expression<T> Function($FaturasAnnotationComposer a) f,
  ) {
    final $FaturasAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.faturas,
      getReferencedColumn: (t) => t.contaPagamentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FaturasAnnotationComposer(
            $db: $db,
            $table: $db.faturas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> lancamentosRefs<T extends Object>(
    Expression<T> Function($LancamentosAnnotationComposer a) f,
  ) {
    final $LancamentosAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lancamentos,
      getReferencedColumn: (t) => t.contaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LancamentosAnnotationComposer(
            $db: $db,
            $table: $db.lancamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ContasTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Contas,
          Conta,
          $ContasFilterComposer,
          $ContasOrderingComposer,
          $ContasAnnotationComposer,
          $ContasCreateCompanionBuilder,
          $ContasUpdateCompanionBuilder,
          (Conta, $ContasReferences),
          Conta,
          PrefetchHooks Function({
            bool cartoesRefs,
            bool faturasRefs,
            bool lancamentosRefs,
          })
        > {
  $ContasTableManager(_$AppDatabase db, Contas table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ContasFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ContasOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ContasAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<int> saldoInicialCentavos = const Value.absent(),
                Value<String> dataSaldoInicial = const Value.absent(),
                Value<int> arquivada = const Value.absent(),
              }) => ContasCompanion(
                id: id,
                nome: nome,
                tipo: tipo,
                saldoInicialCentavos: saldoInicialCentavos,
                dataSaldoInicial: dataSaldoInicial,
                arquivada: arquivada,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nome,
                required String tipo,
                Value<int> saldoInicialCentavos = const Value.absent(),
                required String dataSaldoInicial,
                Value<int> arquivada = const Value.absent(),
              }) => ContasCompanion.insert(
                id: id,
                nome: nome,
                tipo: tipo,
                saldoInicialCentavos: saldoInicialCentavos,
                dataSaldoInicial: dataSaldoInicial,
                arquivada: arquivada,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Contas, Conta>(table),
                  $ContasReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                cartoesRefs = false,
                faturasRefs = false,
                lancamentosRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (cartoesRefs) db.cartoes,
                    if (faturasRefs) db.faturas,
                    if (lancamentosRefs) db.lancamentos,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (cartoesRefs)
                        await $_getPrefetchedData<Conta, Contas, Cartao>(
                          currentTable: table,
                          referencedTable: $ContasReferences._cartoesRefsTable(
                            db,
                          ),
                          managerFromTypedResult: (p0) =>
                              $ContasReferences(db, table, p0).cartoesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.contaPagamentoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (faturasRefs)
                        await $_getPrefetchedData<Conta, Contas, Fatura>(
                          currentTable: table,
                          referencedTable: $ContasReferences._faturasRefsTable(
                            db,
                          ),
                          managerFromTypedResult: (p0) =>
                              $ContasReferences(db, table, p0).faturasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.contaPagamentoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (lancamentosRefs)
                        await $_getPrefetchedData<Conta, Contas, Lancamento>(
                          currentTable: table,
                          referencedTable: $ContasReferences
                              ._lancamentosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $ContasReferences(db, table, p0).lancamentosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.contaId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $ContasProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Contas,
      Conta,
      $ContasFilterComposer,
      $ContasOrderingComposer,
      $ContasAnnotationComposer,
      $ContasCreateCompanionBuilder,
      $ContasUpdateCompanionBuilder,
      (Conta, $ContasReferences),
      Conta,
      PrefetchHooks Function({
        bool cartoesRefs,
        bool faturasRefs,
        bool lancamentosRefs,
      })
    >;
typedef $CartoesCreateCompanionBuilder = CartoesCompanion Function({
  Value<int> id,
  required String nome,
  required int diaFechamento,
  required int diaVencimento,
  required int contaPagamentoId,
  Value<int> arquivado,
});
typedef $CartoesUpdateCompanionBuilder = CartoesCompanion Function({
  Value<int> id,
  Value<String> nome,
  Value<int> diaFechamento,
  Value<int> diaVencimento,
  Value<int> contaPagamentoId,
  Value<int> arquivado,
});

final class $CartoesReferences
    extends BaseReferences<_$AppDatabase, Cartoes, Cartao> {
  $CartoesReferences(super.$_db, super.$_table, super.$_typedResult);

  static Contas _contaPagamentoIdTable(_$AppDatabase db) =>
      db.contas.createAlias('cartoes__conta_pagamento_id__contas__id');

  $ContasProcessedTableManager get contaPagamentoId {
    final $_column = $_itemColumn<int>('conta_pagamento_id')!;

    final manager = $ContasTableManager(
      $_db,
      $_db.contas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contaPagamentoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<Faturas, List<Fatura>> _faturasRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.faturas,
    aliasName: 'cartoes__id__faturas__cartao_id',
  );

  $FaturasProcessedTableManager get faturasRefs {
    final manager = $FaturasTableManager(
      $_db,
      $_db.faturas,
    ).filter((f) => f.cartaoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_faturasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Lancamentos, List<Lancamento>>
  _lancamentosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.lancamentos,
    aliasName: 'cartoes__id__lancamentos__cartao_id',
  );

  $LancamentosProcessedTableManager get lancamentosRefs {
    final manager = $LancamentosTableManager(
      $_db,
      $_db.lancamentos,
    ).filter((f) => f.cartaoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_lancamentosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $CartoesFilterComposer extends Composer<_$AppDatabase, Cartoes> {
  $CartoesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diaFechamento => $composableBuilder(
    column: $table.diaFechamento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diaVencimento => $composableBuilder(
    column: $table.diaVencimento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get arquivado => $composableBuilder(
    column: $table.arquivado,
    builder: (column) => ColumnFilters(column),
  );

  $ContasFilterComposer get contaPagamentoId {
    final $ContasFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaPagamentoId,
      referencedTable: $db.contas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ContasFilterComposer(
            $db: $db,
            $table: $db.contas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> faturasRefs(
    Expression<bool> Function($FaturasFilterComposer f) f,
  ) {
    final $FaturasFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.faturas,
      getReferencedColumn: (t) => t.cartaoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FaturasFilterComposer(
            $db: $db,
            $table: $db.faturas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> lancamentosRefs(
    Expression<bool> Function($LancamentosFilterComposer f) f,
  ) {
    final $LancamentosFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lancamentos,
      getReferencedColumn: (t) => t.cartaoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LancamentosFilterComposer(
            $db: $db,
            $table: $db.lancamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $CartoesOrderingComposer extends Composer<_$AppDatabase, Cartoes> {
  $CartoesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diaFechamento => $composableBuilder(
    column: $table.diaFechamento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diaVencimento => $composableBuilder(
    column: $table.diaVencimento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get arquivado => $composableBuilder(
    column: $table.arquivado,
    builder: (column) => ColumnOrderings(column),
  );

  $ContasOrderingComposer get contaPagamentoId {
    final $ContasOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaPagamentoId,
      referencedTable: $db.contas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ContasOrderingComposer(
            $db: $db,
            $table: $db.contas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $CartoesAnnotationComposer extends Composer<_$AppDatabase, Cartoes> {
  $CartoesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<int> get diaFechamento => $composableBuilder(
    column: $table.diaFechamento,
    builder: (column) => column,
  );

  GeneratedColumn<int> get diaVencimento => $composableBuilder(
    column: $table.diaVencimento,
    builder: (column) => column,
  );

  GeneratedColumn<int> get arquivado =>
      $composableBuilder(column: $table.arquivado, builder: (column) => column);

  $ContasAnnotationComposer get contaPagamentoId {
    final $ContasAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaPagamentoId,
      referencedTable: $db.contas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ContasAnnotationComposer(
            $db: $db,
            $table: $db.contas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> faturasRefs<T extends Object>(
    Expression<T> Function($FaturasAnnotationComposer a) f,
  ) {
    final $FaturasAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.faturas,
      getReferencedColumn: (t) => t.cartaoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FaturasAnnotationComposer(
            $db: $db,
            $table: $db.faturas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> lancamentosRefs<T extends Object>(
    Expression<T> Function($LancamentosAnnotationComposer a) f,
  ) {
    final $LancamentosAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lancamentos,
      getReferencedColumn: (t) => t.cartaoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LancamentosAnnotationComposer(
            $db: $db,
            $table: $db.lancamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $CartoesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Cartoes,
          Cartao,
          $CartoesFilterComposer,
          $CartoesOrderingComposer,
          $CartoesAnnotationComposer,
          $CartoesCreateCompanionBuilder,
          $CartoesUpdateCompanionBuilder,
          (Cartao, $CartoesReferences),
          Cartao,
          PrefetchHooks Function({
            bool contaPagamentoId,
            bool faturasRefs,
            bool lancamentosRefs,
          })
        > {
  $CartoesTableManager(_$AppDatabase db, Cartoes table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $CartoesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $CartoesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $CartoesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<int> diaFechamento = const Value.absent(),
                Value<int> diaVencimento = const Value.absent(),
                Value<int> contaPagamentoId = const Value.absent(),
                Value<int> arquivado = const Value.absent(),
              }) => CartoesCompanion(
                id: id,
                nome: nome,
                diaFechamento: diaFechamento,
                diaVencimento: diaVencimento,
                contaPagamentoId: contaPagamentoId,
                arquivado: arquivado,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nome,
                required int diaFechamento,
                required int diaVencimento,
                required int contaPagamentoId,
                Value<int> arquivado = const Value.absent(),
              }) => CartoesCompanion.insert(
                id: id,
                nome: nome,
                diaFechamento: diaFechamento,
                diaVencimento: diaVencimento,
                contaPagamentoId: contaPagamentoId,
                arquivado: arquivado,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Cartoes, Cartao>(table),
                  $CartoesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                contaPagamentoId = false,
                faturasRefs = false,
                lancamentosRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (faturasRefs) db.faturas,
                    if (lancamentosRefs) db.lancamentos,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (contaPagamentoId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.contaPagamentoId,
                            referencedTable: $CartoesReferences
                                ._contaPagamentoIdTable(db),
                            referencedColumn: $CartoesReferences
                                ._contaPagamentoIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (faturasRefs)
                        await $_getPrefetchedData<Cartao, Cartoes, Fatura>(
                          currentTable: table,
                          referencedTable: $CartoesReferences._faturasRefsTable(
                            db,
                          ),
                          managerFromTypedResult: (p0) =>
                              $CartoesReferences(db, table, p0).faturasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cartaoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (lancamentosRefs)
                        await $_getPrefetchedData<Cartao, Cartoes, Lancamento>(
                          currentTable: table,
                          referencedTable: $CartoesReferences
                              ._lancamentosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $CartoesReferences(db, table, p0).lancamentosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cartaoId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $CartoesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Cartoes,
      Cartao,
      $CartoesFilterComposer,
      $CartoesOrderingComposer,
      $CartoesAnnotationComposer,
      $CartoesCreateCompanionBuilder,
      $CartoesUpdateCompanionBuilder,
      (Cartao, $CartoesReferences),
      Cartao,
      PrefetchHooks Function({
        bool contaPagamentoId,
        bool faturasRefs,
        bool lancamentosRefs,
      })
    >;
typedef $FaturasCreateCompanionBuilder = FaturasCompanion Function({
  Value<int> id,
  required int cartaoId,
  required String mes,
  Value<String?> pagoEm,
  Value<int?> contaPagamentoId,
});
typedef $FaturasUpdateCompanionBuilder = FaturasCompanion Function({
  Value<int> id,
  Value<int> cartaoId,
  Value<String> mes,
  Value<String?> pagoEm,
  Value<int?> contaPagamentoId,
});

final class $FaturasReferences
    extends BaseReferences<_$AppDatabase, Faturas, Fatura> {
  $FaturasReferences(super.$_db, super.$_table, super.$_typedResult);

  static Cartoes _cartaoIdTable(_$AppDatabase db) =>
      db.cartoes.createAlias('faturas__cartao_id__cartoes__id');

  $CartoesProcessedTableManager get cartaoId {
    final $_column = $_itemColumn<int>('cartao_id')!;

    final manager = $CartoesTableManager(
      $_db,
      $_db.cartoes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cartaoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Contas _contaPagamentoIdTable(_$AppDatabase db) =>
      db.contas.createAlias('faturas__conta_pagamento_id__contas__id');

  $ContasProcessedTableManager? get contaPagamentoId {
    final $_column = $_itemColumn<int>('conta_pagamento_id');
    if ($_column == null) return null;
    final manager = $ContasTableManager(
      $_db,
      $_db.contas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contaPagamentoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $FaturasFilterComposer extends Composer<_$AppDatabase, Faturas> {
  $FaturasFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mes => $composableBuilder(
    column: $table.mes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pagoEm => $composableBuilder(
    column: $table.pagoEm,
    builder: (column) => ColumnFilters(column),
  );

  $CartoesFilterComposer get cartaoId {
    final $CartoesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cartaoId,
      referencedTable: $db.cartoes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CartoesFilterComposer(
            $db: $db,
            $table: $db.cartoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ContasFilterComposer get contaPagamentoId {
    final $ContasFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaPagamentoId,
      referencedTable: $db.contas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ContasFilterComposer(
            $db: $db,
            $table: $db.contas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $FaturasOrderingComposer extends Composer<_$AppDatabase, Faturas> {
  $FaturasOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mes => $composableBuilder(
    column: $table.mes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pagoEm => $composableBuilder(
    column: $table.pagoEm,
    builder: (column) => ColumnOrderings(column),
  );

  $CartoesOrderingComposer get cartaoId {
    final $CartoesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cartaoId,
      referencedTable: $db.cartoes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CartoesOrderingComposer(
            $db: $db,
            $table: $db.cartoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ContasOrderingComposer get contaPagamentoId {
    final $ContasOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaPagamentoId,
      referencedTable: $db.contas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ContasOrderingComposer(
            $db: $db,
            $table: $db.contas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $FaturasAnnotationComposer extends Composer<_$AppDatabase, Faturas> {
  $FaturasAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mes =>
      $composableBuilder(column: $table.mes, builder: (column) => column);

  GeneratedColumn<String> get pagoEm =>
      $composableBuilder(column: $table.pagoEm, builder: (column) => column);

  $CartoesAnnotationComposer get cartaoId {
    final $CartoesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cartaoId,
      referencedTable: $db.cartoes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CartoesAnnotationComposer(
            $db: $db,
            $table: $db.cartoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ContasAnnotationComposer get contaPagamentoId {
    final $ContasAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaPagamentoId,
      referencedTable: $db.contas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ContasAnnotationComposer(
            $db: $db,
            $table: $db.contas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $FaturasTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Faturas,
          Fatura,
          $FaturasFilterComposer,
          $FaturasOrderingComposer,
          $FaturasAnnotationComposer,
          $FaturasCreateCompanionBuilder,
          $FaturasUpdateCompanionBuilder,
          (Fatura, $FaturasReferences),
          Fatura,
          PrefetchHooks Function({bool cartaoId, bool contaPagamentoId})
        > {
  $FaturasTableManager(_$AppDatabase db, Faturas table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $FaturasFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $FaturasOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $FaturasAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> cartaoId = const Value.absent(),
                Value<String> mes = const Value.absent(),
                Value<String?> pagoEm = const Value.absent(),
                Value<int?> contaPagamentoId = const Value.absent(),
              }) => FaturasCompanion(
                id: id,
                cartaoId: cartaoId,
                mes: mes,
                pagoEm: pagoEm,
                contaPagamentoId: contaPagamentoId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int cartaoId,
                required String mes,
                Value<String?> pagoEm = const Value.absent(),
                Value<int?> contaPagamentoId = const Value.absent(),
              }) => FaturasCompanion.insert(
                id: id,
                cartaoId: cartaoId,
                mes: mes,
                pagoEm: pagoEm,
                contaPagamentoId: contaPagamentoId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Faturas, Fatura>(table),
                  $FaturasReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({cartaoId = false, contaPagamentoId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (cartaoId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.cartaoId,
                            referencedTable: $FaturasReferences._cartaoIdTable(
                              db,
                            ),
                            referencedColumn: $FaturasReferences
                                ._cartaoIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (contaPagamentoId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.contaPagamentoId,
                            referencedTable: $FaturasReferences
                                ._contaPagamentoIdTable(db),
                            referencedColumn: $FaturasReferences
                                ._contaPagamentoIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $FaturasProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Faturas,
      Fatura,
      $FaturasFilterComposer,
      $FaturasOrderingComposer,
      $FaturasAnnotationComposer,
      $FaturasCreateCompanionBuilder,
      $FaturasUpdateCompanionBuilder,
      (Fatura, $FaturasReferences),
      Fatura,
      PrefetchHooks Function({bool cartaoId, bool contaPagamentoId})
    >;
typedef $CategoriasCreateCompanionBuilder = CategoriasCompanion Function({
  Value<int> id,
  required String nome,
  required String tipo,
  Value<int?> categoriaPaiId,
  Value<int> arquivada,
});
typedef $CategoriasUpdateCompanionBuilder = CategoriasCompanion Function({
  Value<int> id,
  Value<String> nome,
  Value<String> tipo,
  Value<int?> categoriaPaiId,
  Value<int> arquivada,
});

final class $CategoriasReferences
    extends BaseReferences<_$AppDatabase, Categorias, Categoria> {
  $CategoriasReferences(super.$_db, super.$_table, super.$_typedResult);

  static Categorias _categoriaPaiIdTable(_$AppDatabase db) =>
      db.categorias.createAlias('categorias__categoria_pai_id__categorias__id');

  $CategoriasProcessedTableManager? get categoriaPaiId {
    final $_column = $_itemColumn<int>('categoria_pai_id');
    if ($_column == null) return null;
    final manager = $CategoriasTableManager(
      $_db,
      $_db.categorias,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoriaPaiIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<LancamentoCategorias, List<LancamentoCategoria>>
  _lancamentoCategoriasRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.lancamentoCategorias,
        aliasName: 'categorias__id__lancamento_categorias__categoria_id',
      );

  $LancamentoCategoriasProcessedTableManager get lancamentoCategoriasRefs {
    final manager = $LancamentoCategoriasTableManager(
      $_db,
      $_db.lancamentoCategorias,
    ).filter((f) => f.categoriaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _lancamentoCategoriasRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $CategoriasFilterComposer extends Composer<_$AppDatabase, Categorias> {
  $CategoriasFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get arquivada => $composableBuilder(
    column: $table.arquivada,
    builder: (column) => ColumnFilters(column),
  );

  $CategoriasFilterComposer get categoriaPaiId {
    final $CategoriasFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaPaiId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CategoriasFilterComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> lancamentoCategoriasRefs(
    Expression<bool> Function($LancamentoCategoriasFilterComposer f) f,
  ) {
    final $LancamentoCategoriasFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lancamentoCategorias,
      getReferencedColumn: (t) => t.categoriaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LancamentoCategoriasFilterComposer(
            $db: $db,
            $table: $db.lancamentoCategorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $CategoriasOrderingComposer extends Composer<_$AppDatabase, Categorias> {
  $CategoriasOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get arquivada => $composableBuilder(
    column: $table.arquivada,
    builder: (column) => ColumnOrderings(column),
  );

  $CategoriasOrderingComposer get categoriaPaiId {
    final $CategoriasOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaPaiId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CategoriasOrderingComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $CategoriasAnnotationComposer
    extends Composer<_$AppDatabase, Categorias> {
  $CategoriasAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<int> get arquivada =>
      $composableBuilder(column: $table.arquivada, builder: (column) => column);

  $CategoriasAnnotationComposer get categoriaPaiId {
    final $CategoriasAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaPaiId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CategoriasAnnotationComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> lancamentoCategoriasRefs<T extends Object>(
    Expression<T> Function($LancamentoCategoriasAnnotationComposer a) f,
  ) {
    final $LancamentoCategoriasAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lancamentoCategorias,
      getReferencedColumn: (t) => t.categoriaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LancamentoCategoriasAnnotationComposer(
            $db: $db,
            $table: $db.lancamentoCategorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $CategoriasTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Categorias,
          Categoria,
          $CategoriasFilterComposer,
          $CategoriasOrderingComposer,
          $CategoriasAnnotationComposer,
          $CategoriasCreateCompanionBuilder,
          $CategoriasUpdateCompanionBuilder,
          (Categoria, $CategoriasReferences),
          Categoria,
          PrefetchHooks Function({
            bool categoriaPaiId,
            bool lancamentoCategoriasRefs,
          })
        > {
  $CategoriasTableManager(_$AppDatabase db, Categorias table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $CategoriasFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $CategoriasOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $CategoriasAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<int?> categoriaPaiId = const Value.absent(),
                Value<int> arquivada = const Value.absent(),
              }) => CategoriasCompanion(
                id: id,
                nome: nome,
                tipo: tipo,
                categoriaPaiId: categoriaPaiId,
                arquivada: arquivada,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nome,
                required String tipo,
                Value<int?> categoriaPaiId = const Value.absent(),
                Value<int> arquivada = const Value.absent(),
              }) => CategoriasCompanion.insert(
                id: id,
                nome: nome,
                tipo: tipo,
                categoriaPaiId: categoriaPaiId,
                arquivada: arquivada,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Categorias, Categoria>(table),
                  $CategoriasReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({categoriaPaiId = false, lancamentoCategoriasRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (lancamentoCategoriasRefs) db.lancamentoCategorias,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoriaPaiId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.categoriaPaiId,
                            referencedTable: $CategoriasReferences
                                ._categoriaPaiIdTable(db),
                            referencedColumn: $CategoriasReferences
                                ._categoriaPaiIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (lancamentoCategoriasRefs)
                        await $_getPrefetchedData<
                          Categoria,
                          Categorias,
                          LancamentoCategoria
                        >(
                          currentTable: table,
                          referencedTable: $CategoriasReferences
                              ._lancamentoCategoriasRefsTable(db),
                          managerFromTypedResult: (p0) => $CategoriasReferences(
                            db,
                            table,
                            p0,
                          ).lancamentoCategoriasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoriaId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $CategoriasProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Categorias,
      Categoria,
      $CategoriasFilterComposer,
      $CategoriasOrderingComposer,
      $CategoriasAnnotationComposer,
      $CategoriasCreateCompanionBuilder,
      $CategoriasUpdateCompanionBuilder,
      (Categoria, $CategoriasReferences),
      Categoria,
      PrefetchHooks Function({
        bool categoriaPaiId,
        bool lancamentoCategoriasRefs,
      })
    >;
typedef $TagsCreateCompanionBuilder = TagsCompanion Function({
  Value<int> id,
  required String nome,
});
typedef $TagsUpdateCompanionBuilder = TagsCompanion Function({
  Value<int> id,
  Value<String> nome,
});

final class $TagsReferences extends BaseReferences<_$AppDatabase, Tags, Tag> {
  $TagsReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<LancamentoTags, List<LancamentoTag>>
  _lancamentoTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.lancamentoTags,
    aliasName: 'tags__id__lancamento_tags__tag_id',
  );

  $LancamentoTagsProcessedTableManager get lancamentoTagsRefs {
    final manager = $LancamentoTagsTableManager(
      $_db,
      $_db.lancamentoTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_lancamentoTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $TagsFilterComposer extends Composer<_$AppDatabase, Tags> {
  $TagsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> lancamentoTagsRefs(
    Expression<bool> Function($LancamentoTagsFilterComposer f) f,
  ) {
    final $LancamentoTagsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lancamentoTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LancamentoTagsFilterComposer(
            $db: $db,
            $table: $db.lancamentoTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $TagsOrderingComposer extends Composer<_$AppDatabase, Tags> {
  $TagsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );
}

class $TagsAnnotationComposer extends Composer<_$AppDatabase, Tags> {
  $TagsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  Expression<T> lancamentoTagsRefs<T extends Object>(
    Expression<T> Function($LancamentoTagsAnnotationComposer a) f,
  ) {
    final $LancamentoTagsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lancamentoTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LancamentoTagsAnnotationComposer(
            $db: $db,
            $table: $db.lancamentoTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $TagsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Tags,
          Tag,
          $TagsFilterComposer,
          $TagsOrderingComposer,
          $TagsAnnotationComposer,
          $TagsCreateCompanionBuilder,
          $TagsUpdateCompanionBuilder,
          (Tag, $TagsReferences),
          Tag,
          PrefetchHooks Function({bool lancamentoTagsRefs})
        > {
  $TagsTableManager(_$AppDatabase db, Tags table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $TagsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $TagsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $TagsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> nome = const Value.absent(),
          }) => TagsCompanion(id: id, nome: nome),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String nome,
          }) => TagsCompanion.insert(id: id, nome: nome),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Tags, Tag>(table),
                  $TagsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({lancamentoTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (lancamentoTagsRefs) db.lancamentoTags,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (lancamentoTagsRefs)
                    await $_getPrefetchedData<Tag, Tags, LancamentoTag>(
                      currentTable: table,
                      referencedTable: $TagsReferences._lancamentoTagsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $TagsReferences(db, table, p0).lancamentoTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $TagsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Tags,
      Tag,
      $TagsFilterComposer,
      $TagsOrderingComposer,
      $TagsAnnotationComposer,
      $TagsCreateCompanionBuilder,
      $TagsUpdateCompanionBuilder,
      (Tag, $TagsReferences),
      Tag,
      PrefetchHooks Function({bool lancamentoTagsRefs})
    >;
typedef $RecorrenciasCreateCompanionBuilder = RecorrenciasCompanion Function({
  Value<int> id,
  required int diaDoMes,
  required String dataInicio,
  Value<String?> dataFim,
  Value<int> ativa,
});
typedef $RecorrenciasUpdateCompanionBuilder = RecorrenciasCompanion Function({
  Value<int> id,
  Value<int> diaDoMes,
  Value<String> dataInicio,
  Value<String?> dataFim,
  Value<int> ativa,
});

final class $RecorrenciasReferences
    extends BaseReferences<_$AppDatabase, Recorrencias, Recorrencia> {
  $RecorrenciasReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<Lancamentos, List<Lancamento>>
  _lancamentosRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.lancamentos,
    aliasName: 'recorrencias__id__lancamentos__recorrencia_id',
  );

  $LancamentosProcessedTableManager get lancamentosRefs {
    final manager = $LancamentosTableManager(
      $_db,
      $_db.lancamentos,
    ).filter((f) => f.recorrenciaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_lancamentosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Transferencias, List<Transferencia>>
  _transferenciasRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transferencias,
    aliasName: 'recorrencias__id__transferencias__recorrencia_id',
  );

  $TransferenciasProcessedTableManager get transferenciasRefs {
    final manager = $TransferenciasTableManager(
      $_db,
      $_db.transferencias,
    ).filter((f) => f.recorrenciaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transferenciasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $RecorrenciasFilterComposer
    extends Composer<_$AppDatabase, Recorrencias> {
  $RecorrenciasFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diaDoMes => $composableBuilder(
    column: $table.diaDoMes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataInicio => $composableBuilder(
    column: $table.dataInicio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataFim => $composableBuilder(
    column: $table.dataFim,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ativa => $composableBuilder(
    column: $table.ativa,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> lancamentosRefs(
    Expression<bool> Function($LancamentosFilterComposer f) f,
  ) {
    final $LancamentosFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lancamentos,
      getReferencedColumn: (t) => t.recorrenciaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LancamentosFilterComposer(
            $db: $db,
            $table: $db.lancamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transferenciasRefs(
    Expression<bool> Function($TransferenciasFilterComposer f) f,
  ) {
    final $TransferenciasFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transferencias,
      getReferencedColumn: (t) => t.recorrenciaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TransferenciasFilterComposer(
            $db: $db,
            $table: $db.transferencias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $RecorrenciasOrderingComposer
    extends Composer<_$AppDatabase, Recorrencias> {
  $RecorrenciasOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diaDoMes => $composableBuilder(
    column: $table.diaDoMes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataInicio => $composableBuilder(
    column: $table.dataInicio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataFim => $composableBuilder(
    column: $table.dataFim,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ativa => $composableBuilder(
    column: $table.ativa,
    builder: (column) => ColumnOrderings(column),
  );
}

class $RecorrenciasAnnotationComposer
    extends Composer<_$AppDatabase, Recorrencias> {
  $RecorrenciasAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get diaDoMes =>
      $composableBuilder(column: $table.diaDoMes, builder: (column) => column);

  GeneratedColumn<String> get dataInicio => $composableBuilder(
    column: $table.dataInicio,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dataFim =>
      $composableBuilder(column: $table.dataFim, builder: (column) => column);

  GeneratedColumn<int> get ativa =>
      $composableBuilder(column: $table.ativa, builder: (column) => column);

  Expression<T> lancamentosRefs<T extends Object>(
    Expression<T> Function($LancamentosAnnotationComposer a) f,
  ) {
    final $LancamentosAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lancamentos,
      getReferencedColumn: (t) => t.recorrenciaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LancamentosAnnotationComposer(
            $db: $db,
            $table: $db.lancamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> transferenciasRefs<T extends Object>(
    Expression<T> Function($TransferenciasAnnotationComposer a) f,
  ) {
    final $TransferenciasAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transferencias,
      getReferencedColumn: (t) => t.recorrenciaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TransferenciasAnnotationComposer(
            $db: $db,
            $table: $db.transferencias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $RecorrenciasTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Recorrencias,
          Recorrencia,
          $RecorrenciasFilterComposer,
          $RecorrenciasOrderingComposer,
          $RecorrenciasAnnotationComposer,
          $RecorrenciasCreateCompanionBuilder,
          $RecorrenciasUpdateCompanionBuilder,
          (Recorrencia, $RecorrenciasReferences),
          Recorrencia,
          PrefetchHooks Function({
            bool lancamentosRefs,
            bool transferenciasRefs,
          })
        > {
  $RecorrenciasTableManager(_$AppDatabase db, Recorrencias table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $RecorrenciasFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $RecorrenciasOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $RecorrenciasAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> diaDoMes = const Value.absent(),
                Value<String> dataInicio = const Value.absent(),
                Value<String?> dataFim = const Value.absent(),
                Value<int> ativa = const Value.absent(),
              }) => RecorrenciasCompanion(
                id: id,
                diaDoMes: diaDoMes,
                dataInicio: dataInicio,
                dataFim: dataFim,
                ativa: ativa,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int diaDoMes,
                required String dataInicio,
                Value<String?> dataFim = const Value.absent(),
                Value<int> ativa = const Value.absent(),
              }) => RecorrenciasCompanion.insert(
                id: id,
                diaDoMes: diaDoMes,
                dataInicio: dataInicio,
                dataFim: dataFim,
                ativa: ativa,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Recorrencias, Recorrencia>(table),
                  $RecorrenciasReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({lancamentosRefs = false, transferenciasRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (lancamentosRefs) db.lancamentos,
                    if (transferenciasRefs) db.transferencias,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (lancamentosRefs)
                        await $_getPrefetchedData<
                          Recorrencia,
                          Recorrencias,
                          Lancamento
                        >(
                          currentTable: table,
                          referencedTable: $RecorrenciasReferences
                              ._lancamentosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $RecorrenciasReferences(
                                db,
                                table,
                                p0,
                              ).lancamentosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.recorrenciaId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (transferenciasRefs)
                        await $_getPrefetchedData<
                          Recorrencia,
                          Recorrencias,
                          Transferencia
                        >(
                          currentTable: table,
                          referencedTable: $RecorrenciasReferences
                              ._transferenciasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $RecorrenciasReferences(
                                db,
                                table,
                                p0,
                              ).transferenciasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.recorrenciaId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $RecorrenciasProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Recorrencias,
      Recorrencia,
      $RecorrenciasFilterComposer,
      $RecorrenciasOrderingComposer,
      $RecorrenciasAnnotationComposer,
      $RecorrenciasCreateCompanionBuilder,
      $RecorrenciasUpdateCompanionBuilder,
      (Recorrencia, $RecorrenciasReferences),
      Recorrencia,
      PrefetchHooks Function({bool lancamentosRefs, bool transferenciasRefs})
    >;
typedef $LancamentosCreateCompanionBuilder = LancamentosCompanion Function({
  Value<int> id,
  required String tipo,
  required String descricao,
  required int valorCentavos,
  required String dataLancamento,
  Value<int?> contaId,
  Value<int?> cartaoId,
  Value<String?> mesFatura,
  Value<int> faturaManual,
  required String mesReferencia,
  Value<int?> parcelaAtual,
  Value<int?> totalParcelas,
  Value<String?> grupoParcelamento,
  Value<int?> recorrenciaId,
  Value<String?> observacao,
  required String criadoEm,
});
typedef $LancamentosUpdateCompanionBuilder = LancamentosCompanion Function({
  Value<int> id,
  Value<String> tipo,
  Value<String> descricao,
  Value<int> valorCentavos,
  Value<String> dataLancamento,
  Value<int?> contaId,
  Value<int?> cartaoId,
  Value<String?> mesFatura,
  Value<int> faturaManual,
  Value<String> mesReferencia,
  Value<int?> parcelaAtual,
  Value<int?> totalParcelas,
  Value<String?> grupoParcelamento,
  Value<int?> recorrenciaId,
  Value<String?> observacao,
  Value<String> criadoEm,
});

final class $LancamentosReferences
    extends BaseReferences<_$AppDatabase, Lancamentos, Lancamento> {
  $LancamentosReferences(super.$_db, super.$_table, super.$_typedResult);

  static Contas _contaIdTable(_$AppDatabase db) =>
      db.contas.createAlias('lancamentos__conta_id__contas__id');

  $ContasProcessedTableManager? get contaId {
    final $_column = $_itemColumn<int>('conta_id');
    if ($_column == null) return null;
    final manager = $ContasTableManager(
      $_db,
      $_db.contas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Cartoes _cartaoIdTable(_$AppDatabase db) =>
      db.cartoes.createAlias('lancamentos__cartao_id__cartoes__id');

  $CartoesProcessedTableManager? get cartaoId {
    final $_column = $_itemColumn<int>('cartao_id');
    if ($_column == null) return null;
    final manager = $CartoesTableManager(
      $_db,
      $_db.cartoes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cartaoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Recorrencias _recorrenciaIdTable(_$AppDatabase db) => db.recorrencias
      .createAlias('lancamentos__recorrencia_id__recorrencias__id');

  $RecorrenciasProcessedTableManager? get recorrenciaId {
    final $_column = $_itemColumn<int>('recorrencia_id');
    if ($_column == null) return null;
    final manager = $RecorrenciasTableManager(
      $_db,
      $_db.recorrencias,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recorrenciaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<LancamentoCategorias, List<LancamentoCategoria>>
  _lancamentoCategoriasRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.lancamentoCategorias,
        aliasName: 'lancamentos__id__lancamento_categorias__lancamento_id',
      );

  $LancamentoCategoriasProcessedTableManager get lancamentoCategoriasRefs {
    final manager = $LancamentoCategoriasTableManager(
      $_db,
      $_db.lancamentoCategorias,
    ).filter((f) => f.lancamentoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _lancamentoCategoriasRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<LancamentoTags, List<LancamentoTag>>
  _lancamentoTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.lancamentoTags,
    aliasName: 'lancamentos__id__lancamento_tags__lancamento_id',
  );

  $LancamentoTagsProcessedTableManager get lancamentoTagsRefs {
    final manager = $LancamentoTagsTableManager(
      $_db,
      $_db.lancamentoTags,
    ).filter((f) => f.lancamentoId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_lancamentoTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $LancamentosFilterComposer extends Composer<_$AppDatabase, Lancamentos> {
  $LancamentosFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get valorCentavos => $composableBuilder(
    column: $table.valorCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataLancamento => $composableBuilder(
    column: $table.dataLancamento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mesFatura => $composableBuilder(
    column: $table.mesFatura,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get faturaManual => $composableBuilder(
    column: $table.faturaManual,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mesReferencia => $composableBuilder(
    column: $table.mesReferencia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parcelaAtual => $composableBuilder(
    column: $table.parcelaAtual,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalParcelas => $composableBuilder(
    column: $table.totalParcelas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grupoParcelamento => $composableBuilder(
    column: $table.grupoParcelamento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observacao => $composableBuilder(
    column: $table.observacao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  $ContasFilterComposer get contaId {
    final $ContasFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaId,
      referencedTable: $db.contas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ContasFilterComposer(
            $db: $db,
            $table: $db.contas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $CartoesFilterComposer get cartaoId {
    final $CartoesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cartaoId,
      referencedTable: $db.cartoes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CartoesFilterComposer(
            $db: $db,
            $table: $db.cartoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $RecorrenciasFilterComposer get recorrenciaId {
    final $RecorrenciasFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recorrenciaId,
      referencedTable: $db.recorrencias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $RecorrenciasFilterComposer(
            $db: $db,
            $table: $db.recorrencias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> lancamentoCategoriasRefs(
    Expression<bool> Function($LancamentoCategoriasFilterComposer f) f,
  ) {
    final $LancamentoCategoriasFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lancamentoCategorias,
      getReferencedColumn: (t) => t.lancamentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LancamentoCategoriasFilterComposer(
            $db: $db,
            $table: $db.lancamentoCategorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> lancamentoTagsRefs(
    Expression<bool> Function($LancamentoTagsFilterComposer f) f,
  ) {
    final $LancamentoTagsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lancamentoTags,
      getReferencedColumn: (t) => t.lancamentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LancamentoTagsFilterComposer(
            $db: $db,
            $table: $db.lancamentoTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $LancamentosOrderingComposer
    extends Composer<_$AppDatabase, Lancamentos> {
  $LancamentosOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valorCentavos => $composableBuilder(
    column: $table.valorCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataLancamento => $composableBuilder(
    column: $table.dataLancamento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mesFatura => $composableBuilder(
    column: $table.mesFatura,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get faturaManual => $composableBuilder(
    column: $table.faturaManual,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mesReferencia => $composableBuilder(
    column: $table.mesReferencia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parcelaAtual => $composableBuilder(
    column: $table.parcelaAtual,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalParcelas => $composableBuilder(
    column: $table.totalParcelas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grupoParcelamento => $composableBuilder(
    column: $table.grupoParcelamento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observacao => $composableBuilder(
    column: $table.observacao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  $ContasOrderingComposer get contaId {
    final $ContasOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaId,
      referencedTable: $db.contas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ContasOrderingComposer(
            $db: $db,
            $table: $db.contas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $CartoesOrderingComposer get cartaoId {
    final $CartoesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cartaoId,
      referencedTable: $db.cartoes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CartoesOrderingComposer(
            $db: $db,
            $table: $db.cartoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $RecorrenciasOrderingComposer get recorrenciaId {
    final $RecorrenciasOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recorrenciaId,
      referencedTable: $db.recorrencias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $RecorrenciasOrderingComposer(
            $db: $db,
            $table: $db.recorrencias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $LancamentosAnnotationComposer
    extends Composer<_$AppDatabase, Lancamentos> {
  $LancamentosAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get descricao =>
      $composableBuilder(column: $table.descricao, builder: (column) => column);

  GeneratedColumn<int> get valorCentavos => $composableBuilder(
    column: $table.valorCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dataLancamento => $composableBuilder(
    column: $table.dataLancamento,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mesFatura =>
      $composableBuilder(column: $table.mesFatura, builder: (column) => column);

  GeneratedColumn<int> get faturaManual => $composableBuilder(
    column: $table.faturaManual,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mesReferencia => $composableBuilder(
    column: $table.mesReferencia,
    builder: (column) => column,
  );

  GeneratedColumn<int> get parcelaAtual => $composableBuilder(
    column: $table.parcelaAtual,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalParcelas => $composableBuilder(
    column: $table.totalParcelas,
    builder: (column) => column,
  );

  GeneratedColumn<String> get grupoParcelamento => $composableBuilder(
    column: $table.grupoParcelamento,
    builder: (column) => column,
  );

  GeneratedColumn<String> get observacao => $composableBuilder(
    column: $table.observacao,
    builder: (column) => column,
  );

  GeneratedColumn<String> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  $ContasAnnotationComposer get contaId {
    final $ContasAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaId,
      referencedTable: $db.contas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ContasAnnotationComposer(
            $db: $db,
            $table: $db.contas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $CartoesAnnotationComposer get cartaoId {
    final $CartoesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cartaoId,
      referencedTable: $db.cartoes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CartoesAnnotationComposer(
            $db: $db,
            $table: $db.cartoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $RecorrenciasAnnotationComposer get recorrenciaId {
    final $RecorrenciasAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recorrenciaId,
      referencedTable: $db.recorrencias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $RecorrenciasAnnotationComposer(
            $db: $db,
            $table: $db.recorrencias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> lancamentoCategoriasRefs<T extends Object>(
    Expression<T> Function($LancamentoCategoriasAnnotationComposer a) f,
  ) {
    final $LancamentoCategoriasAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lancamentoCategorias,
      getReferencedColumn: (t) => t.lancamentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LancamentoCategoriasAnnotationComposer(
            $db: $db,
            $table: $db.lancamentoCategorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> lancamentoTagsRefs<T extends Object>(
    Expression<T> Function($LancamentoTagsAnnotationComposer a) f,
  ) {
    final $LancamentoTagsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lancamentoTags,
      getReferencedColumn: (t) => t.lancamentoId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LancamentoTagsAnnotationComposer(
            $db: $db,
            $table: $db.lancamentoTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $LancamentosTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Lancamentos,
          Lancamento,
          $LancamentosFilterComposer,
          $LancamentosOrderingComposer,
          $LancamentosAnnotationComposer,
          $LancamentosCreateCompanionBuilder,
          $LancamentosUpdateCompanionBuilder,
          (Lancamento, $LancamentosReferences),
          Lancamento,
          PrefetchHooks Function({
            bool contaId,
            bool cartaoId,
            bool recorrenciaId,
            bool lancamentoCategoriasRefs,
            bool lancamentoTagsRefs,
          })
        > {
  $LancamentosTableManager(_$AppDatabase db, Lancamentos table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $LancamentosFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $LancamentosOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $LancamentosAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<String> descricao = const Value.absent(),
                Value<int> valorCentavos = const Value.absent(),
                Value<String> dataLancamento = const Value.absent(),
                Value<int?> contaId = const Value.absent(),
                Value<int?> cartaoId = const Value.absent(),
                Value<String?> mesFatura = const Value.absent(),
                Value<int> faturaManual = const Value.absent(),
                Value<String> mesReferencia = const Value.absent(),
                Value<int?> parcelaAtual = const Value.absent(),
                Value<int?> totalParcelas = const Value.absent(),
                Value<String?> grupoParcelamento = const Value.absent(),
                Value<int?> recorrenciaId = const Value.absent(),
                Value<String?> observacao = const Value.absent(),
                Value<String> criadoEm = const Value.absent(),
              }) => LancamentosCompanion(
                id: id,
                tipo: tipo,
                descricao: descricao,
                valorCentavos: valorCentavos,
                dataLancamento: dataLancamento,
                contaId: contaId,
                cartaoId: cartaoId,
                mesFatura: mesFatura,
                faturaManual: faturaManual,
                mesReferencia: mesReferencia,
                parcelaAtual: parcelaAtual,
                totalParcelas: totalParcelas,
                grupoParcelamento: grupoParcelamento,
                recorrenciaId: recorrenciaId,
                observacao: observacao,
                criadoEm: criadoEm,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String tipo,
                required String descricao,
                required int valorCentavos,
                required String dataLancamento,
                Value<int?> contaId = const Value.absent(),
                Value<int?> cartaoId = const Value.absent(),
                Value<String?> mesFatura = const Value.absent(),
                Value<int> faturaManual = const Value.absent(),
                required String mesReferencia,
                Value<int?> parcelaAtual = const Value.absent(),
                Value<int?> totalParcelas = const Value.absent(),
                Value<String?> grupoParcelamento = const Value.absent(),
                Value<int?> recorrenciaId = const Value.absent(),
                Value<String?> observacao = const Value.absent(),
                required String criadoEm,
              }) => LancamentosCompanion.insert(
                id: id,
                tipo: tipo,
                descricao: descricao,
                valorCentavos: valorCentavos,
                dataLancamento: dataLancamento,
                contaId: contaId,
                cartaoId: cartaoId,
                mesFatura: mesFatura,
                faturaManual: faturaManual,
                mesReferencia: mesReferencia,
                parcelaAtual: parcelaAtual,
                totalParcelas: totalParcelas,
                grupoParcelamento: grupoParcelamento,
                recorrenciaId: recorrenciaId,
                observacao: observacao,
                criadoEm: criadoEm,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Lancamentos, Lancamento>(table),
                  $LancamentosReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                contaId = false,
                cartaoId = false,
                recorrenciaId = false,
                lancamentoCategoriasRefs = false,
                lancamentoTagsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (lancamentoCategoriasRefs) db.lancamentoCategorias,
                    if (lancamentoTagsRefs) db.lancamentoTags,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (contaId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.contaId,
                            referencedTable: $LancamentosReferences
                                ._contaIdTable(db),
                            referencedColumn: $LancamentosReferences
                                ._contaIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (cartaoId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.cartaoId,
                            referencedTable: $LancamentosReferences
                                ._cartaoIdTable(db),
                            referencedColumn: $LancamentosReferences
                                ._cartaoIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (recorrenciaId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.recorrenciaId,
                            referencedTable: $LancamentosReferences
                                ._recorrenciaIdTable(db),
                            referencedColumn: $LancamentosReferences
                                ._recorrenciaIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (lancamentoCategoriasRefs)
                        await $_getPrefetchedData<
                          Lancamento,
                          Lancamentos,
                          LancamentoCategoria
                        >(
                          currentTable: table,
                          referencedTable: $LancamentosReferences
                              ._lancamentoCategoriasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $LancamentosReferences(
                                db,
                                table,
                                p0,
                              ).lancamentoCategoriasRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.lancamentoId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (lancamentoTagsRefs)
                        await $_getPrefetchedData<
                          Lancamento,
                          Lancamentos,
                          LancamentoTag
                        >(
                          currentTable: table,
                          referencedTable: $LancamentosReferences
                              ._lancamentoTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $LancamentosReferences(
                                db,
                                table,
                                p0,
                              ).lancamentoTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.lancamentoId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $LancamentosProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Lancamentos,
      Lancamento,
      $LancamentosFilterComposer,
      $LancamentosOrderingComposer,
      $LancamentosAnnotationComposer,
      $LancamentosCreateCompanionBuilder,
      $LancamentosUpdateCompanionBuilder,
      (Lancamento, $LancamentosReferences),
      Lancamento,
      PrefetchHooks Function({
        bool contaId,
        bool cartaoId,
        bool recorrenciaId,
        bool lancamentoCategoriasRefs,
        bool lancamentoTagsRefs,
      })
    >;
typedef $LancamentoCategoriasCreateCompanionBuilder =
    LancamentoCategoriasCompanion Function({
      required int lancamentoId,
      required int categoriaId,
      required int valorCentavos,
      Value<int> rowid,
    });
typedef $LancamentoCategoriasUpdateCompanionBuilder =
    LancamentoCategoriasCompanion Function({
      Value<int> lancamentoId,
      Value<int> categoriaId,
      Value<int> valorCentavos,
      Value<int> rowid,
    });

final class $LancamentoCategoriasReferences
    extends
        BaseReferences<
          _$AppDatabase,
          LancamentoCategorias,
          LancamentoCategoria
        > {
  $LancamentoCategoriasReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static Lancamentos _lancamentoIdTable(_$AppDatabase db) => db.lancamentos
      .createAlias('lancamento_categorias__lancamento_id__lancamentos__id');

  $LancamentosProcessedTableManager get lancamentoId {
    final $_column = $_itemColumn<int>('lancamento_id')!;

    final manager = $LancamentosTableManager(
      $_db,
      $_db.lancamentos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_lancamentoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Categorias _categoriaIdTable(_$AppDatabase db) => db.categorias
      .createAlias('lancamento_categorias__categoria_id__categorias__id');

  $CategoriasProcessedTableManager get categoriaId {
    final $_column = $_itemColumn<int>('categoria_id')!;

    final manager = $CategoriasTableManager(
      $_db,
      $_db.categorias,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoriaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $LancamentoCategoriasFilterComposer
    extends Composer<_$AppDatabase, LancamentoCategorias> {
  $LancamentoCategoriasFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get valorCentavos => $composableBuilder(
    column: $table.valorCentavos,
    builder: (column) => ColumnFilters(column),
  );

  $LancamentosFilterComposer get lancamentoId {
    final $LancamentosFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lancamentoId,
      referencedTable: $db.lancamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LancamentosFilterComposer(
            $db: $db,
            $table: $db.lancamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $CategoriasFilterComposer get categoriaId {
    final $CategoriasFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CategoriasFilterComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $LancamentoCategoriasOrderingComposer
    extends Composer<_$AppDatabase, LancamentoCategorias> {
  $LancamentoCategoriasOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get valorCentavos => $composableBuilder(
    column: $table.valorCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  $LancamentosOrderingComposer get lancamentoId {
    final $LancamentosOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lancamentoId,
      referencedTable: $db.lancamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LancamentosOrderingComposer(
            $db: $db,
            $table: $db.lancamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $CategoriasOrderingComposer get categoriaId {
    final $CategoriasOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CategoriasOrderingComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $LancamentoCategoriasAnnotationComposer
    extends Composer<_$AppDatabase, LancamentoCategorias> {
  $LancamentoCategoriasAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get valorCentavos => $composableBuilder(
    column: $table.valorCentavos,
    builder: (column) => column,
  );

  $LancamentosAnnotationComposer get lancamentoId {
    final $LancamentosAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lancamentoId,
      referencedTable: $db.lancamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LancamentosAnnotationComposer(
            $db: $db,
            $table: $db.lancamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $CategoriasAnnotationComposer get categoriaId {
    final $CategoriasAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $CategoriasAnnotationComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $LancamentoCategoriasTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          LancamentoCategorias,
          LancamentoCategoria,
          $LancamentoCategoriasFilterComposer,
          $LancamentoCategoriasOrderingComposer,
          $LancamentoCategoriasAnnotationComposer,
          $LancamentoCategoriasCreateCompanionBuilder,
          $LancamentoCategoriasUpdateCompanionBuilder,
          (LancamentoCategoria, $LancamentoCategoriasReferences),
          LancamentoCategoria,
          PrefetchHooks Function({bool lancamentoId, bool categoriaId})
        > {
  $LancamentoCategoriasTableManager(
    _$AppDatabase db,
    LancamentoCategorias table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $LancamentoCategoriasFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $LancamentoCategoriasOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $LancamentoCategoriasAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> lancamentoId = const Value.absent(),
                Value<int> categoriaId = const Value.absent(),
                Value<int> valorCentavos = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LancamentoCategoriasCompanion(
                lancamentoId: lancamentoId,
                categoriaId: categoriaId,
                valorCentavos: valorCentavos,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int lancamentoId,
                required int categoriaId,
                required int valorCentavos,
                Value<int> rowid = const Value.absent(),
              }) => LancamentoCategoriasCompanion.insert(
                lancamentoId: lancamentoId,
                categoriaId: categoriaId,
                valorCentavos: valorCentavos,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<LancamentoCategorias, LancamentoCategoria>(table),
                  $LancamentoCategoriasReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({lancamentoId = false, categoriaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (lancamentoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.lancamentoId,
                        referencedTable: $LancamentoCategoriasReferences
                            ._lancamentoIdTable(db),
                        referencedColumn: $LancamentoCategoriasReferences
                            ._lancamentoIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (categoriaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.categoriaId,
                        referencedTable: $LancamentoCategoriasReferences
                            ._categoriaIdTable(db),
                        referencedColumn: $LancamentoCategoriasReferences
                            ._categoriaIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $LancamentoCategoriasProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      LancamentoCategorias,
      LancamentoCategoria,
      $LancamentoCategoriasFilterComposer,
      $LancamentoCategoriasOrderingComposer,
      $LancamentoCategoriasAnnotationComposer,
      $LancamentoCategoriasCreateCompanionBuilder,
      $LancamentoCategoriasUpdateCompanionBuilder,
      (LancamentoCategoria, $LancamentoCategoriasReferences),
      LancamentoCategoria,
      PrefetchHooks Function({bool lancamentoId, bool categoriaId})
    >;
typedef $LancamentoTagsCreateCompanionBuilder =
    LancamentoTagsCompanion Function({
      required int lancamentoId,
      required int tagId,
      Value<int> rowid,
    });
typedef $LancamentoTagsUpdateCompanionBuilder =
    LancamentoTagsCompanion Function({
      Value<int> lancamentoId,
      Value<int> tagId,
      Value<int> rowid,
    });

final class $LancamentoTagsReferences
    extends BaseReferences<_$AppDatabase, LancamentoTags, LancamentoTag> {
  $LancamentoTagsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Lancamentos _lancamentoIdTable(_$AppDatabase db) => db.lancamentos
      .createAlias('lancamento_tags__lancamento_id__lancamentos__id');

  $LancamentosProcessedTableManager get lancamentoId {
    final $_column = $_itemColumn<int>('lancamento_id')!;

    final manager = $LancamentosTableManager(
      $_db,
      $_db.lancamentos,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_lancamentoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Tags _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias('lancamento_tags__tag_id__tags__id');

  $TagsProcessedTableManager get tagId {
    final $_column = $_itemColumn<int>('tag_id')!;

    final manager = $TagsTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $LancamentoTagsFilterComposer
    extends Composer<_$AppDatabase, LancamentoTags> {
  $LancamentoTagsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $LancamentosFilterComposer get lancamentoId {
    final $LancamentosFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lancamentoId,
      referencedTable: $db.lancamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LancamentosFilterComposer(
            $db: $db,
            $table: $db.lancamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $TagsFilterComposer get tagId {
    final $TagsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TagsFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $LancamentoTagsOrderingComposer
    extends Composer<_$AppDatabase, LancamentoTags> {
  $LancamentoTagsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $LancamentosOrderingComposer get lancamentoId {
    final $LancamentosOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lancamentoId,
      referencedTable: $db.lancamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LancamentosOrderingComposer(
            $db: $db,
            $table: $db.lancamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $TagsOrderingComposer get tagId {
    final $TagsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TagsOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $LancamentoTagsAnnotationComposer
    extends Composer<_$AppDatabase, LancamentoTags> {
  $LancamentoTagsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $LancamentosAnnotationComposer get lancamentoId {
    final $LancamentosAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.lancamentoId,
      referencedTable: $db.lancamentos,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LancamentosAnnotationComposer(
            $db: $db,
            $table: $db.lancamentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $TagsAnnotationComposer get tagId {
    final $TagsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TagsAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $LancamentoTagsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          LancamentoTags,
          LancamentoTag,
          $LancamentoTagsFilterComposer,
          $LancamentoTagsOrderingComposer,
          $LancamentoTagsAnnotationComposer,
          $LancamentoTagsCreateCompanionBuilder,
          $LancamentoTagsUpdateCompanionBuilder,
          (LancamentoTag, $LancamentoTagsReferences),
          LancamentoTag,
          PrefetchHooks Function({bool lancamentoId, bool tagId})
        > {
  $LancamentoTagsTableManager(_$AppDatabase db, LancamentoTags table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $LancamentoTagsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $LancamentoTagsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $LancamentoTagsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> lancamentoId = const Value.absent(),
                Value<int> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LancamentoTagsCompanion(
                lancamentoId: lancamentoId,
                tagId: tagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int lancamentoId,
                required int tagId,
                Value<int> rowid = const Value.absent(),
              }) => LancamentoTagsCompanion.insert(
                lancamentoId: lancamentoId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<LancamentoTags, LancamentoTag>(table),
                  $LancamentoTagsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({lancamentoId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (lancamentoId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.lancamentoId,
                        referencedTable: $LancamentoTagsReferences
                            ._lancamentoIdTable(db),
                        referencedColumn: $LancamentoTagsReferences
                            ._lancamentoIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (tagId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.tagId,
                        referencedTable: $LancamentoTagsReferences._tagIdTable(
                          db,
                        ),
                        referencedColumn: $LancamentoTagsReferences
                            ._tagIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $LancamentoTagsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      LancamentoTags,
      LancamentoTag,
      $LancamentoTagsFilterComposer,
      $LancamentoTagsOrderingComposer,
      $LancamentoTagsAnnotationComposer,
      $LancamentoTagsCreateCompanionBuilder,
      $LancamentoTagsUpdateCompanionBuilder,
      (LancamentoTag, $LancamentoTagsReferences),
      LancamentoTag,
      PrefetchHooks Function({bool lancamentoId, bool tagId})
    >;
typedef $TransferenciasCreateCompanionBuilder =
    TransferenciasCompanion Function({
      Value<int> id,
      required int valorCentavos,
      required int contaOrigemId,
      required int contaDestinoId,
      required String data,
      Value<int?> recorrenciaId,
      Value<String?> observacao,
      required String criadoEm,
    });
typedef $TransferenciasUpdateCompanionBuilder =
    TransferenciasCompanion Function({
      Value<int> id,
      Value<int> valorCentavos,
      Value<int> contaOrigemId,
      Value<int> contaDestinoId,
      Value<String> data,
      Value<int?> recorrenciaId,
      Value<String?> observacao,
      Value<String> criadoEm,
    });

final class $TransferenciasReferences
    extends BaseReferences<_$AppDatabase, Transferencias, Transferencia> {
  $TransferenciasReferences(super.$_db, super.$_table, super.$_typedResult);

  static Contas _contaOrigemIdTable(_$AppDatabase db) =>
      db.contas.createAlias('transferencias__conta_origem_id__contas__id');

  $ContasProcessedTableManager get contaOrigemId {
    final $_column = $_itemColumn<int>('conta_origem_id')!;

    final manager = $ContasTableManager(
      $_db,
      $_db.contas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contaOrigemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Contas _contaDestinoIdTable(_$AppDatabase db) =>
      db.contas.createAlias('transferencias__conta_destino_id__contas__id');

  $ContasProcessedTableManager get contaDestinoId {
    final $_column = $_itemColumn<int>('conta_destino_id')!;

    final manager = $ContasTableManager(
      $_db,
      $_db.contas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contaDestinoIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static Recorrencias _recorrenciaIdTable(_$AppDatabase db) => db.recorrencias
      .createAlias('transferencias__recorrencia_id__recorrencias__id');

  $RecorrenciasProcessedTableManager? get recorrenciaId {
    final $_column = $_itemColumn<int>('recorrencia_id');
    if ($_column == null) return null;
    final manager = $RecorrenciasTableManager(
      $_db,
      $_db.recorrencias,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recorrenciaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $TransferenciasFilterComposer
    extends Composer<_$AppDatabase, Transferencias> {
  $TransferenciasFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get valorCentavos => $composableBuilder(
    column: $table.valorCentavos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observacao => $composableBuilder(
    column: $table.observacao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  $ContasFilterComposer get contaOrigemId {
    final $ContasFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaOrigemId,
      referencedTable: $db.contas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ContasFilterComposer(
            $db: $db,
            $table: $db.contas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ContasFilterComposer get contaDestinoId {
    final $ContasFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaDestinoId,
      referencedTable: $db.contas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ContasFilterComposer(
            $db: $db,
            $table: $db.contas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $RecorrenciasFilterComposer get recorrenciaId {
    final $RecorrenciasFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recorrenciaId,
      referencedTable: $db.recorrencias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $RecorrenciasFilterComposer(
            $db: $db,
            $table: $db.recorrencias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $TransferenciasOrderingComposer
    extends Composer<_$AppDatabase, Transferencias> {
  $TransferenciasOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valorCentavos => $composableBuilder(
    column: $table.valorCentavos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observacao => $composableBuilder(
    column: $table.observacao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  $ContasOrderingComposer get contaOrigemId {
    final $ContasOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaOrigemId,
      referencedTable: $db.contas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ContasOrderingComposer(
            $db: $db,
            $table: $db.contas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ContasOrderingComposer get contaDestinoId {
    final $ContasOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaDestinoId,
      referencedTable: $db.contas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ContasOrderingComposer(
            $db: $db,
            $table: $db.contas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $RecorrenciasOrderingComposer get recorrenciaId {
    final $RecorrenciasOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recorrenciaId,
      referencedTable: $db.recorrencias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $RecorrenciasOrderingComposer(
            $db: $db,
            $table: $db.recorrencias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $TransferenciasAnnotationComposer
    extends Composer<_$AppDatabase, Transferencias> {
  $TransferenciasAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get valorCentavos => $composableBuilder(
    column: $table.valorCentavos,
    builder: (column) => column,
  );

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<String> get observacao => $composableBuilder(
    column: $table.observacao,
    builder: (column) => column,
  );

  GeneratedColumn<String> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  $ContasAnnotationComposer get contaOrigemId {
    final $ContasAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaOrigemId,
      referencedTable: $db.contas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ContasAnnotationComposer(
            $db: $db,
            $table: $db.contas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $ContasAnnotationComposer get contaDestinoId {
    final $ContasAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contaDestinoId,
      referencedTable: $db.contas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ContasAnnotationComposer(
            $db: $db,
            $table: $db.contas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $RecorrenciasAnnotationComposer get recorrenciaId {
    final $RecorrenciasAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.recorrenciaId,
      referencedTable: $db.recorrencias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $RecorrenciasAnnotationComposer(
            $db: $db,
            $table: $db.recorrencias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $TransferenciasTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Transferencias,
          Transferencia,
          $TransferenciasFilterComposer,
          $TransferenciasOrderingComposer,
          $TransferenciasAnnotationComposer,
          $TransferenciasCreateCompanionBuilder,
          $TransferenciasUpdateCompanionBuilder,
          (Transferencia, $TransferenciasReferences),
          Transferencia,
          PrefetchHooks Function({
            bool contaOrigemId,
            bool contaDestinoId,
            bool recorrenciaId,
          })
        > {
  $TransferenciasTableManager(_$AppDatabase db, Transferencias table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $TransferenciasFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $TransferenciasOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $TransferenciasAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> valorCentavos = const Value.absent(),
                Value<int> contaOrigemId = const Value.absent(),
                Value<int> contaDestinoId = const Value.absent(),
                Value<String> data = const Value.absent(),
                Value<int?> recorrenciaId = const Value.absent(),
                Value<String?> observacao = const Value.absent(),
                Value<String> criadoEm = const Value.absent(),
              }) => TransferenciasCompanion(
                id: id,
                valorCentavos: valorCentavos,
                contaOrigemId: contaOrigemId,
                contaDestinoId: contaDestinoId,
                data: data,
                recorrenciaId: recorrenciaId,
                observacao: observacao,
                criadoEm: criadoEm,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int valorCentavos,
                required int contaOrigemId,
                required int contaDestinoId,
                required String data,
                Value<int?> recorrenciaId = const Value.absent(),
                Value<String?> observacao = const Value.absent(),
                required String criadoEm,
              }) => TransferenciasCompanion.insert(
                id: id,
                valorCentavos: valorCentavos,
                contaOrigemId: contaOrigemId,
                contaDestinoId: contaDestinoId,
                data: data,
                recorrenciaId: recorrenciaId,
                observacao: observacao,
                criadoEm: criadoEm,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Transferencias, Transferencia>(table),
                  $TransferenciasReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                contaOrigemId = false,
                contaDestinoId = false,
                recorrenciaId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (contaOrigemId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.contaOrigemId,
                            referencedTable: $TransferenciasReferences
                                ._contaOrigemIdTable(db),
                            referencedColumn: $TransferenciasReferences
                                ._contaOrigemIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (contaDestinoId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.contaDestinoId,
                            referencedTable: $TransferenciasReferences
                                ._contaDestinoIdTable(db),
                            referencedColumn: $TransferenciasReferences
                                ._contaDestinoIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (recorrenciaId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.recorrenciaId,
                            referencedTable: $TransferenciasReferences
                                ._recorrenciaIdTable(db),
                            referencedColumn: $TransferenciasReferences
                                ._recorrenciaIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $TransferenciasProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Transferencias,
      Transferencia,
      $TransferenciasFilterComposer,
      $TransferenciasOrderingComposer,
      $TransferenciasAnnotationComposer,
      $TransferenciasCreateCompanionBuilder,
      $TransferenciasUpdateCompanionBuilder,
      (Transferencia, $TransferenciasReferences),
      Transferencia,
      PrefetchHooks Function({
        bool contaOrigemId,
        bool contaDestinoId,
        bool recorrenciaId,
      })
    >;
typedef $ConfiguracoesCreateCompanionBuilder = ConfiguracoesCompanion Function({
  Value<String?> chave,
  required String valor,
  Value<int> rowid,
});
typedef $ConfiguracoesUpdateCompanionBuilder = ConfiguracoesCompanion Function({
  Value<String?> chave,
  Value<String> valor,
  Value<int> rowid,
});

class $ConfiguracoesFilterComposer
    extends Composer<_$AppDatabase, Configuracoes> {
  $ConfiguracoesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get chave => $composableBuilder(
    column: $table.chave,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );
}

class $ConfiguracoesOrderingComposer
    extends Composer<_$AppDatabase, Configuracoes> {
  $ConfiguracoesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get chave => $composableBuilder(
    column: $table.chave,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );
}

class $ConfiguracoesAnnotationComposer
    extends Composer<_$AppDatabase, Configuracoes> {
  $ConfiguracoesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get chave =>
      $composableBuilder(column: $table.chave, builder: (column) => column);

  GeneratedColumn<String> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);
}

class $ConfiguracoesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Configuracoes,
          Configuracao,
          $ConfiguracoesFilterComposer,
          $ConfiguracoesOrderingComposer,
          $ConfiguracoesAnnotationComposer,
          $ConfiguracoesCreateCompanionBuilder,
          $ConfiguracoesUpdateCompanionBuilder,
          (
            Configuracao,
            BaseReferences<_$AppDatabase, Configuracoes, Configuracao>,
          ),
          Configuracao,
          PrefetchHooks Function()
        > {
  $ConfiguracoesTableManager(_$AppDatabase db, Configuracoes table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ConfiguracoesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ConfiguracoesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ConfiguracoesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> chave = const Value.absent(),
                Value<String> valor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConfiguracoesCompanion(
                chave: chave,
                valor: valor,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> chave = const Value.absent(),
                required String valor,
                Value<int> rowid = const Value.absent(),
              }) => ConfiguracoesCompanion.insert(
                chave: chave,
                valor: valor,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Configuracoes, Configuracao>(table),
                  BaseReferences<_$AppDatabase, Configuracoes, Configuracao>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $ConfiguracoesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Configuracoes,
      Configuracao,
      $ConfiguracoesFilterComposer,
      $ConfiguracoesOrderingComposer,
      $ConfiguracoesAnnotationComposer,
      $ConfiguracoesCreateCompanionBuilder,
      $ConfiguracoesUpdateCompanionBuilder,
      (
        Configuracao,
        BaseReferences<_$AppDatabase, Configuracoes, Configuracao>,
      ),
      Configuracao,
      PrefetchHooks Function()
    >;
typedef $FiltrosCreateCompanionBuilder = FiltrosCompanion Function({
  Value<int> id,
  required String nome,
  required String criteriosJson,
});
typedef $FiltrosUpdateCompanionBuilder = FiltrosCompanion Function({
  Value<int> id,
  Value<String> nome,
  Value<String> criteriosJson,
});

class $FiltrosFilterComposer extends Composer<_$AppDatabase, Filtros> {
  $FiltrosFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get criteriosJson => $composableBuilder(
    column: $table.criteriosJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $FiltrosOrderingComposer extends Composer<_$AppDatabase, Filtros> {
  $FiltrosOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get criteriosJson => $composableBuilder(
    column: $table.criteriosJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $FiltrosAnnotationComposer extends Composer<_$AppDatabase, Filtros> {
  $FiltrosAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get criteriosJson => $composableBuilder(
    column: $table.criteriosJson,
    builder: (column) => column,
  );
}

class $FiltrosTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Filtros,
          Filtro,
          $FiltrosFilterComposer,
          $FiltrosOrderingComposer,
          $FiltrosAnnotationComposer,
          $FiltrosCreateCompanionBuilder,
          $FiltrosUpdateCompanionBuilder,
          (Filtro, BaseReferences<_$AppDatabase, Filtros, Filtro>),
          Filtro,
          PrefetchHooks Function()
        > {
  $FiltrosTableManager(_$AppDatabase db, Filtros table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $FiltrosFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $FiltrosOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $FiltrosAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<String> criteriosJson = const Value.absent(),
              }) => FiltrosCompanion(
                id: id,
                nome: nome,
                criteriosJson: criteriosJson,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nome,
                required String criteriosJson,
              }) => FiltrosCompanion.insert(
                id: id,
                nome: nome,
                criteriosJson: criteriosJson,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Filtros, Filtro>(table),
                  BaseReferences<_$AppDatabase, Filtros, Filtro>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $FiltrosProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Filtros,
      Filtro,
      $FiltrosFilterComposer,
      $FiltrosOrderingComposer,
      $FiltrosAnnotationComposer,
      $FiltrosCreateCompanionBuilder,
      $FiltrosUpdateCompanionBuilder,
      (Filtro, BaseReferences<_$AppDatabase, Filtros, Filtro>),
      Filtro,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $ContasTableManager get contas => $ContasTableManager(_db, _db.contas);
  $CartoesTableManager get cartoes => $CartoesTableManager(_db, _db.cartoes);
  $FaturasTableManager get faturas => $FaturasTableManager(_db, _db.faturas);
  $CategoriasTableManager get categorias =>
      $CategoriasTableManager(_db, _db.categorias);
  $TagsTableManager get tags => $TagsTableManager(_db, _db.tags);
  $RecorrenciasTableManager get recorrencias =>
      $RecorrenciasTableManager(_db, _db.recorrencias);
  $LancamentosTableManager get lancamentos =>
      $LancamentosTableManager(_db, _db.lancamentos);
  $LancamentoCategoriasTableManager get lancamentoCategorias =>
      $LancamentoCategoriasTableManager(_db, _db.lancamentoCategorias);
  $LancamentoTagsTableManager get lancamentoTags =>
      $LancamentoTagsTableManager(_db, _db.lancamentoTags);
  $TransferenciasTableManager get transferencias =>
      $TransferenciasTableManager(_db, _db.transferencias);
  $ConfiguracoesTableManager get configuracoes =>
      $ConfiguracoesTableManager(_db, _db.configuracoes);
  $FiltrosTableManager get filtros => $FiltrosTableManager(_db, _db.filtros);
}
