import 'package:belajar_flutter_get/app/core/theme/app_colors.dart';
import 'package:belajar_flutter_get/app/data/models/todo_model.dart';
import 'package:belajar_flutter_get/app/data/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  // ─── SERVICES UNTUK PERBANDINGAN GETSTORAGE & SHARED PREFERENCES ───
  final GetStorageService _getStorageService = GetStorageService();
  final SharedPrefService _sharedPrefService = SharedPrefService();

  // Storage aktif (bisa di-switch oleh user untuk demonstrasi)
  final Rx<StorageProviderType> activeStorageType =
      StorageProviderType.getStorage.obs;

  BaseStorageService get currentStorage =>
      activeStorageType.value == StorageProviderType.getStorage
      ? _getStorageService
      : _sharedPrefService;

  // ─── STATE TODOS & FILTER ───
  final RxList<TodoModel> todos = <TodoModel>[].obs;
  final RxString filterStatus = 'all'.obs; // 'all', 'active', 'completed'
  final RxString filterPriority = 'all'.obs; // 'all', 'low', 'medium', 'high'

  // ─── THEME ───
  final RxBool isDarkMode = true.obs;

  // ─── STATS ───
  int get totalTodos => todos.length;
  int get completedTodos => todos.where((t) => t.isCompleted).length;
  int get activeTodos => todos.where((t) => !t.isCompleted).length;

  List<TodoModel> get filteredTodos {
    List<TodoModel> result = todos.toList();

    // Filter by status
    if (filterStatus.value == 'active') {
      result = result.where((t) => !t.isCompleted).toList();
    } else if (filterStatus.value == 'completed') {
      result = result.where((t) => t.isCompleted).toList();
    }

    // Filter by priority
    if (filterPriority.value != 'all') {
      result = result.where((t) => t.priority == filterPriority.value).toList();
    }

    return result;
  }

  @override
  void onInit() {
    super.onInit();
    _initStorageAndLoadData();
  }

  /// Inisialisasi storage service dan muat data tersimpan
  Future<void> _initStorageAndLoadData() async {
    // 1. Init kedua storage provider
    await _getStorageService.init();
    await _sharedPrefService.init();

    // 2. Muat tema yang tersimpan
    final savedTheme = await currentStorage.loadTheme();
    if (savedTheme != null) {
      isDarkMode.value = savedTheme;
      AppColors.setTheme(dark: isDarkMode.value);
      Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    }

    // 3. Muat data Todo dari storage aktif
    await loadTodosFromStorage();
  }

  /// Memuat daftar todos dari storage aktif
  Future<void> loadTodosFromStorage() async {
    final loaded = await currentStorage.loadTodos();
    if (loaded.isNotEmpty) {
      todos.assignAll(loaded);
    } else {
      // Jika storage masih kosong (user baru), pakai sample todos lalu simpan
      await saveTodosToStorage();
    }
  }

  /// Menyimpan daftar todos ke storage aktif
  Future<void> saveTodosToStorage() async {
    await currentStorage.saveTodos(todos.toList());
  }

  /// Mengganti provider storage (GetStorage <-> SharedPreferences)
  Future<void> switchStorageProvider(StorageProviderType type) async {
    if (activeStorageType.value == type) return;

    activeStorageType.value = type;

    // Muat data dari storage terpilih
    final loaded = await currentStorage.loadTodos();
    if (loaded.isNotEmpty) {
      todos.assignAll(loaded);
    } else {
      // Sinkronkan data saat ini ke storage baru agar tidak kosong
      await saveTodosToStorage();
    }

    Get.snackbar(
      'Storage Berganti!',
      'Sekarang aktif: ${currentStorage.name}',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;

    AppColors.setTheme(dark: isDarkMode.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);

    // Simpan pilihan tema ke storage agar konsisten saat app dibuka lagi
    await _getStorageService.saveTheme(isDarkMode.value);
    await _sharedPrefService.saveTheme(isDarkMode.value);
  }

  // void _addSampleTodos() {
  //   todos.addAll([
  //     TodoModel(
  //       id: DateTime.now().millisecondsSinceEpoch.toString(),
  //       title: 'Belajar Flutter GetX',
  //       description: 'Pelajari state management menggunakan GetX',
  //       isCompleted: true,
  //       createdAt: DateTime.now().subtract(const Duration(days: 2)),
  //       priority: 'high',
  //     ),
  //     TodoModel(
  //       id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
  //       title: 'Membuat aplikasi Todo List',
  //       description: 'Buat aplikasi todo list dengan fitur CRUD lengkap',
  //       isCompleted: false,
  //       createdAt: DateTime.now().subtract(const Duration(days: 1)),
  //       priority: 'high',
  //     ),
  //     TodoModel(
  //       id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
  //       title: 'Belajar GetStorage & SharedPref',
  //       description: 'Pahami perbedaan implementasi keduanya di Flutter',
  //       isCompleted: false,
  //       createdAt: DateTime.now(),
  //       priority: 'medium',
  //     ),
  //     TodoModel(
  //       id: (DateTime.now().millisecondsSinceEpoch + 3).toString(),
  //       title: 'Implementasi Local Persistence',
  //       description: 'Simpan data agar tidak hilang saat app restart',
  //       isCompleted: false,
  //       createdAt: DateTime.now(),
  //       priority: 'low',
  //     ),
  //   ]);
  // }

  void addTodo({
    required String title,
    String description = '',
    String priority = 'medium',
  }) async {
    if (title.trim().isEmpty) return;
    final todo = TodoModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      description: description.trim(),
      isCompleted: false,
      createdAt: DateTime.now(),
      priority: priority,
    );
    todos.insert(0, todo);

    // Simpan perubahan ke storage
    await saveTodosToStorage();

    Get.snackbar(
      'Berhasil!',
      'Todo "${todo.title}" telah ditambahkan (${currentStorage.name})',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void toggleTodo(String id) async {
    final index = todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      final todo = todos[index];
      todos[index] = todo.copyWith(isCompleted: !todo.isCompleted);
      todos.refresh();

      // Simpan perubahan ke storage
      await saveTodosToStorage();
    }
  }

  void deleteTodo(String id) async {
    final todo = todos.firstWhereOrNull((t) => t.id == id);
    if (todo != null) {
      todos.removeWhere((t) => t.id == id);

      //  Simpan perubahan ke storage
      await saveTodosToStorage();

      Get.snackbar(
        'Dihapus!',
        '"${todo.title}" telah dihapus',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void updateTodo({
    required String id,
    required String title,
    String description = '',
    String priority = 'medium',
  }) async {
    if (title.trim().isEmpty) return;
    final index = todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      todos[index] = todos[index].copyWith(
        title: title.trim(),
        description: description.trim(),
        priority: priority,
      );
      todos.refresh();

      // 💾 Simpan perubahan ke storage
      await saveTodosToStorage();

      Get.snackbar(
        'Diperbarui!',
        'Todo berhasil diperbarui',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void clearCompleted() async {
    todos.removeWhere((t) => t.isCompleted);
    // Simpan perubahan ke storage
    await saveTodosToStorage();
  }

  void setFilter(String status) {
    filterStatus.value = status;
  }

  void setPriorityFilter(String priority) {
    filterPriority.value = priority;
  }
}
