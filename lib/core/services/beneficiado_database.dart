import 'package:sqflite/sqflite.dart';
import '../models/beneficiado.dart';

class BeneficiadoDatabase {
  static final BeneficiadoDatabase _instance = BeneficiadoDatabase._();
  factory BeneficiadoDatabase() => _instance;
  BeneficiadoDatabase._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/beneficiados.db';
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE beneficiados (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            cpf TEXT NOT NULL,
            idade INTEGER,
            celular TEXT,
            igreja TEXT,
            papel_igreja TEXT,
            estado_civil TEXT,
            email TEXT,
            sexo TEXT,
            cidade TEXT,
            estado_uf TEXT,
            escolaridade TEXT,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
          )
        ''');
      },
    );
  }

  Future<int> salvar(Beneficiado beneficiado) async {
    final db = await database;
    final existente = await db.query(
      'beneficiados',
      where: 'cpf = ?',
      whereArgs: [beneficiado.cpf],
    );
    if (existente.isNotEmpty) {
      await db.update(
        'beneficiados',
        beneficiado.toJson(),
        where: 'cpf = ?',
        whereArgs: [beneficiado.cpf],
      );
      return existente.first['id'] as int;
    }
    return db.insert('beneficiados', beneficiado.toJson());
  }

  Future<List<Beneficiado>> listar({String? busca}) async {
    final db = await database;
    List<Map<String, dynamic>> maps;
    if (busca != null && busca.isNotEmpty) {
      maps = await db.query(
        'beneficiados',
        where: 'nome LIKE ? OR cpf LIKE ?',
        whereArgs: ['%$busca%', '%$busca%'],
        orderBy: 'created_at DESC',
      );
    } else {
      maps = await db.query('beneficiados', orderBy: 'created_at DESC');
    }
    return maps.map((m) => Beneficiado.fromJson(m)).toList();
  }

  Future<void> removerPorCpf(String cpf) async {
    final db = await database;
    await db.delete('beneficiados', where: 'cpf = ?', whereArgs: [cpf]);
  }
}
