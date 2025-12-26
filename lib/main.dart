import 'dart:io'; // Для роботи з файлом фото
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Для MethodChannel
import 'package:image_picker/image_picker.dart'; // Для камери

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 14 Final',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 209, 196, 233),
          centerTitle: true,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // --- НАЛАШТУВАННЯ КАНАЛУ ---
  static const platform = MethodChannel('com.example.lab14/native_test');

  // --- ЗМІННІ ДЛЯ КАМЕРИ ---
  File? _capturedImage;
  final ImagePicker _picker = ImagePicker();

  // 1. Функція виклику нативного коду
  Future<void> _callNativeMethod() async {
    String nativeMessage;
    try {
      final String result = await platform.invokeMethod('getHello');
      nativeMessage = result; // Очікуємо "Hi, Mom!"
    } on PlatformException catch (e) {
      nativeMessage = "Помилка: '${e.message}'.";
    }

    if (!mounted) return;
    // Показуємо діалог з роботом
    _showRobotDialog(context, nativeMessage);
  }

  // 2. Функція відображення діалогу з роботом
  void _showRobotDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          // Ваша іконка робота
          icon: Image.network(
            'https://emojiisland.com/cdn/shop/products/Robot_Emoji_Icon_abe1111a-1293-4668-bdf9-9ceb05cff58e_large.png?v=1571606090',
            height: 80,
            errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.smart_toy, size: 80, color: Colors.teal),
          ),
          title: const Text(
            'Native data:',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          content: Text(
            message, // Текст з Android ("Hi, Mom!")
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.normal),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        );
      },
    );
  }

  // 3. Функція для фото
  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _capturedImage = File(photo.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Demo Home Page')),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // Кнопка для нативного коду
          Center(
            child: OutlinedButton(
              onPressed: _callNativeMethod,
              child: const Text('#1 String (Native Call)'),
            ),
          ),

          const Divider(height: 40),

          // Область для показу фото
          Expanded(
            child: Center(
              child: _capturedImage == null
                  ? const Text('Фото ще немає', style: TextStyle(color: Colors.grey))
                  : Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_capturedImage!),
                ),
              ),
            ),
          ),
        ],
      ),
      // Кнопка камери
      floatingActionButton: FloatingActionButton(
        onPressed: _takePhoto,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}