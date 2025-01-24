import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // JSON işlemleri için
import 'TasksPage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(PersonalAssistantApp());
}

class PersonalAssistantApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kişisel Asistan Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _tasks = [];
  String _selectedFilter = "Tümü"; // Varsayılan filtre durumu

  final Map<String, String> _categoryImages = {
    'İş': 'assets/job.png',
    'Gündelik': 'assets/daily.png',
    'Okul': 'assets/school.png',
  };

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // Görevleri SharedPreferences'dan yükle
  Future<void> _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      setState(() {
        _tasks = List<Map<String, dynamic>>.from(json.decode(tasksJson));
      });
    }
  }

  // Filtrelenmiş görevleri döndüren fonksiyon
  List<Map<String, dynamic>> _getFilteredTasks() {
    final reminderTasks = _tasks.where((task) {
      final taskDate = DateTime.parse(task['dateTime']);
      final currentTime = DateTime.now();
      return taskDate.isAfter(currentTime) &&
          taskDate.difference(currentTime).inHours <= 3;
    }).toList();

    if (_selectedFilter == "Tamamlanan") {
      return reminderTasks.where((task) => task['completed'] == true).toList();
    } else if (_selectedFilter == "Tamamlanmayan") {
      return reminderTasks.where((task) => task['completed'] == false).toList();
    }
    return reminderTasks; // Tümü
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _getFilteredTasks();

    return Scaffold(
      appBar: AppBar(
        title: Text('Ana Sayfa'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menü',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.task),
              title: Text('Görevler'),
              onTap: () async {
                // Görev sayfasına geçiş ve geri döndüğünde görevleri yenile
                final updatedTasks = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TasksPage(initialTasks: _tasks),
                  ),
                );
                if (updatedTasks != null) {
                  setState(() {
                    _tasks = updatedTasks;
                  });
                }
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Hava Durumu Widget'ı
              Container(
                padding: EdgeInsets.all(16),
                color: Colors.blue[50],
                child: Column(
                  children: [
                    Text(
                      'Hava Durumu',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud, size: 40, color: Colors.blue),
                        SizedBox(width: 10),
                        Column(
                          children: [
                            Text('25°C', style: TextStyle(fontSize: 24)),
                            Text('Yağmurlu', style: TextStyle(fontSize: 18)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Hatırlatıcı Başlığı ve Filtreler
              Column(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Hatırlatıcı (Son 3 saati kalanlar)',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Tamamlanan Filtre Butonu
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            // Aynı filtreye tıklanırsa filtreleme kalkar
                            _selectedFilter = _selectedFilter == "Tamamlanan"
                                ? "Tümü"
                                : "Tamamlanan";
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: _selectedFilter == "Tamamlanan"
                                ? Colors.blue
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                            border: Border.all(color: Colors.blue),
                          ),
                          child: Text(
                            'Tamamlanan',
                            style: TextStyle(
                              color: _selectedFilter == "Tamamlanan"
                                  ? Colors.white
                                  : Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      // Tamamlanmayan Filtre Butonu
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            // Aynı filtreye tıklanırsa filtreleme kalkar
                            _selectedFilter = _selectedFilter == "Tamamlanmayan"
                                ? "Tümü"
                                : "Tamamlanmayan";
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: _selectedFilter == "Tamamlanmayan"
                                ? Colors.blue
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                            border: Border.all(color: Colors.blue),
                          ),
                          child: Text(
                            'Tamamlanmayan',
                            style: TextStyle(
                              color: _selectedFilter == "Tamamlanmayan"
                                  ? Colors.white
                                  : Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Görevler
              Expanded(
                child: filteredTasks.isEmpty
                    ? Center(child: Text('Filtreye uygun görev bulunamadı.'))
                    : GridView.builder(
                  padding: EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    final category = task['category'];
                    final image = _categoryImages[category];
                    return Card(
                      color: task['completed']
                          ? Colors.green
                          : Colors.white,
                      elevation: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Image.asset(
                              image ?? 'assets/default.png',
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              task['task'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: task['completed']
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              task['dateTime'] ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: task['completed']
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Sayfa yenileme butonu
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _loadTasks, // Yenileme butonu
              child: Icon(Icons.refresh),
            ),
          ),
        ],
      ),
    );
  }
}
