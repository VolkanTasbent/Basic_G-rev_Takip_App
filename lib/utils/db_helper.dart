// Sqflite ve Path paketlerini import ediyoruz
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
// Task modelini import ediyoruz, bu model veritabanında kullanılacak verileri temsil edecek
import '../models/task.dart';

class DBHelper {
  // Singleton tasarım desenine göre bir instance oluşturuyoruz, yani sadece bir veritabanı bağlantısı olacak
  static final DBHelper instance = DBHelper._init();
  static Database? _database; // Veritabanı örneği

  // Private constructor ile sınıfın dışarıdan oluşturulmasını engelliyoruz
  DBHelper._init();

  // Veritabanı bağlantısının bir getter'ı, eğer veritabanı henüz başlatılmadıysa, başlatıyoruz
  Future<Database> get database async {
    if (_database != null) return _database!; // Veritabanı zaten varsa, mevcut olanı döndür
    _database = await _initDB('tasks.db'); // Veritabanı yoksa, başlatıyoruz
    return _database!;
  }

  // Veritabanını başlatan metod
  Future<Database> _initDB(String filePath) async {
    // Veritabanı dosyasının bulunduğu dizini alıyoruz
    final dbPath = await getDatabasesPath();
    // Veritabanı dosyasının tam yolunu oluşturuyoruz
    final path = join(dbPath, filePath);

    // Veritabanını açıyoruz veya oluşturuyoruz, eğer yoksa `_createDB` metodunu çağırıyoruz
    return await openDatabase(
      path,
      version: 1, // Veritabanı versiyonu
      onCreate: _createDB, // Veritabanı oluşturulurken yapılacak işlemler
    );
  }

  // Veritabanı oluşturulurken çalışacak metod
  Future<void> _createDB(Database db, int version) async {
    // `tasks` tablosunu oluşturuyoruz
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,  // Otomatik artan bir id
        title TEXT NOT NULL,  // Görev başlığı, boş olamaz
        description TEXT NOT NULL,  // Görev açıklaması, boş olamaz
        is_completed INTEGER NOT NULL  // Görev tamamlanma durumu, boş olamaz
      )
    ''');
  }

  // Yeni bir görev eklemek için kullanılan metod
  Future<int> createTask(Task task) async {
    final db = await instance.database; // Veritabanı bağlantısını alıyoruz
    return await db.insert('tasks', task.toMap()); // `tasks` tablosuna yeni görev ekliyoruz
  }

  // Tüm görevleri almak için kullanılan metod
  Future<List<Task>> getTasks() async {
    final db = await instance.database; // Veritabanı bağlantısını alıyoruz
    final result = await db.query('tasks'); // `tasks` tablosundan tüm görevleri alıyoruz
    // Sonuçları `Task` modeline dönüştürüp bir liste olarak döndürüyoruz
    return result.map((map) => Task.fromMap(map)).toList();
  }

  // Mevcut bir görevi güncellemek için kullanılan metod
  Future<int> updateTask(Task task) async {
    final db = await instance.database; // Veritabanı bağlantısını alıyoruz
    // `tasks` tablosundaki görevi güncelliyoruz
    return db.update(
      'tasks', // Tablo adı
      task.toMap(), // Güncellenmiş görev verisi
      where: 'id = ?', // Hangi görev güncellenecek (id'ye göre)
      whereArgs: [task.id], // Güncellenecek görevin id'si
    );
  }

  // Mevcut bir görevi silmek için kullanılan metod
  Future<int> deleteTask(int id) async {
    final db = await instance.database; // Veritabanı bağlantısını alıyoruz
    // `tasks` tablosundaki görevi id'ye göre siliyoruz
    return db.delete(
      'tasks', // Tablo adı
      where: 'id = ?', // Hangi görev silinecek (id'ye göre)
      whereArgs: [id], // Silinecek görevin id'si
    );
  }
}
