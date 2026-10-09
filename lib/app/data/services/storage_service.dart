import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo_model.dart';

enum StorageProviderType { getStorage, sharedPreferences }

/// Kontrak (Interface) untuk abstraksi Local Storage
abstract class BaseStorageService {
  StorageProviderType get type;
  String get name;

  Future<void> init();
  Future<List<TodoModel>> loadTodos();
  Future<void> saveTodos(List<TodoModel> todos);
  Future<bool?> loadTheme();
  Future<void> saveTheme(bool isDark);
}

/// ===============================================================
/// 1. IMPLEMENTASI DENGAN GET STORAGE
/// ===============================================================
/// Karakteristik:
/// - Sangat ringkas, dibuat khusus untuk ekosistem GetX.
/// - Operasi read bersifat sinkron (synchronous) setelah init.
/// - Otomatis mendukung List of Maps tanpa perlu jsonEncode manual.
class GetStorageService implements BaseStorageService {
  static const String _todosKey = 'getstorage_todos';
  static const String _themeKey = 'getstorage_is_dark';

  late GetStorage _box;

  @override
  StorageProviderType get type => StorageProviderType.getStorage;

  @override
  String get name => "GetStorage";

  @override
  Future<void> init() async {
    // Inisialisasi container GetStorage
    await GetStorage.init();
    _box = GetStorage();
  }

  @override
  Future<List<TodoModel>> loadTodos() async {
    // Di GetStorage, pembacaan data instan dari memory cache
    final rawData = _box.read<List>(_todosKey);
    if (rawData == null || rawData.isEmpty) {
      return [];
    }

    // rawData langsung berupa List of Map, tinggal di-mapping
    return rawData
        .map(
          (item) => TodoModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  @override
  Future<void> saveTodos(List<TodoModel> todos) async {
    // Cukup simpan List of Map secara langsung
    final listMap = todos.map((todo) => todo.toJson()).toList();
    await _box.write(_todosKey, listMap);
  }

  @override
  Future<bool?> loadTheme() async {
    return _box.read<bool>(_themeKey);
  }

  @override
  Future<void> saveTheme(bool isDark) async {
    await _box.write(_themeKey, isDark);
  }
}

/// ===============================================================
/// 2. IMPLEMENTASI DENGAN SHARED PREFERENCES
/// ===============================================================
/// Karakteristik:
/// - Plugin resmi Flutter (Official).
/// - Semua operasi read/write bersifat Asynchronous (Future/await).
/// - Hanya mendukung tipe primitif, sehingga `List<TodoModel>` harus
///   dikonversi manual menjadi String via jsonEncode & jsonDecode.
class SharedPrefService implements BaseStorageService {
  static const String _todosKey = 'sharedpref_todos';
  static const String _themeKey = 'sharedpref_is_dark';

  SharedPreferences? _prefs;

  @override
  StorageProviderType get type => StorageProviderType.sharedPreferences;

  @override
  String get name => "SharedPreferences";

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<List<TodoModel>> loadTodos() async {
    final prefs = await _getPrefs();
    // SharedPreferences hanya menyimpan tipe String untuk data kompleks
    final jsonString = prefs.getString(_todosKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    // Wajib parse string JSON secara manual
    final List decodedList = jsonDecode(jsonString) as List;
    return decodedList
        .map((item) => TodoModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveTodos(List<TodoModel> todos) async {
    final prefs = await _getPrefs();
    // Wajib encode List<Map> menjadi String JSON
    final listMap = todos.map((todo) => todo.toJson()).toList();
    final jsonString = jsonEncode(listMap);
    await prefs.setString(_todosKey, jsonString);
  }

  @override
  Future<bool?> loadTheme() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_themeKey);
  }

  @override
  Future<void> saveTheme(bool isDark) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_themeKey, isDark);
  }
}
