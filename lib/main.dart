import 'dart:convert'; // Для функции jsonDecode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Шаг 1: Импорт пакета

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PostsPage(),
    );
  }
}

// ==========================================
// Шаг 2: Модель данных
// ==========================================
class Post {
  final int id;
  final String title;

  Post({required this.id, required this.title});

  // Фабрика для преобразования JSON в объект Post
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
    );
  }
}

// ==========================================
// Шаг 5: Создание StatefulWidget
// ==========================================
class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  // Состояние экрана
  List<Post> posts = [];
  bool isLoading = true; // Флаг загрузки (для Шага 6)
  String? errorMessage;  // Сообщение об ошибке (для Шага 8)

  @override
  void initState() {
    super.initState();
    // Шаг 5: Вызов fetchPosts при инициализации экрана
    fetchPosts();
  }

  // ==========================================
  // Шаг 3, 4 и 8: Асинхронная функция с обработкой ошибок
  // ==========================================
  Future<void> fetchPosts() async {
    try {
      // Выполняем GET-запрос
      final response = await http.get(
        Uri.parse('https://jsonplaceholder.typicode.com/posts'),
      );

      if (response.statusCode == 200) {
        // Декодируем строку ответа в JSON (List<dynamic>)
        final List<dynamic> jsonData = jsonDecode(response.body);
        
        // Преобразуем JSON в список объектов Post и обновляем UI
        setState(() {
          posts = jsonData.map((json) => Post.fromJson(json)).toList();
          isLoading = false; // Отключаем индикатор загрузки
        });
      } else {
        // Если сервер вернул ошибку (например, 404)
        setState(() {
          errorMessage = 'Ошибка сервера: код ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      // Шаг 8: Обрабатываем исключения (например, нет интернета)
      setState(() {
        errorMessage = 'Ошибка загрузки: проверьте подключение к сети';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список постов'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      // Шаг 6: Логика отображения
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // 1. Показываем индикатор загрузки
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Показываем ошибку, если она есть
    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          style: const TextStyle(color: Colors.red, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }

    // 3. Показываем список данных
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        // Шаг 7: Вывод через ListTile
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(child: Text(post.id.toString())),
            title: Text(post.title),
          ),
        );
      },
    );
  }
}