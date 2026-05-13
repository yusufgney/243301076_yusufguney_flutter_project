import 'package:flutter/material.dart';

import '../widgets/theme_toggle_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tema Demo'),
        actions: const [
          ThemeToggleIconButton(), // AppBar ikonu
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                'Menü',
                style: textTheme.headlineMedium?.copyWith(color: Colors.white),
              ),
            ),
            const ThemeToggleListTile(), // Ayar menüsü öğesi
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Metinler
            Text('Hoş Geldiniz!', style: textTheme.displayMedium),
            const SizedBox(height: 8),
            Text(
              'Bu ekran, yeni temanızın her iki modda da (Light/Dark) nasıl göründüğünü test etmeniz için tasarlandı. Tüm metinler Dark modda beyaz, Light modda koyu görünecektir.',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),

            // Kart (Card) Testi
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bilgi Kartı', style: textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      'Card widget arka plan rengi temaya göre uyarlanır.',
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Input Testi
            const TextField(
              decoration: InputDecoration(
                labelText: 'Kullanıcı Adı',
                hintText: 'Bir şeyler yazın...',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),

            // Buton Testi
            ElevatedButton(
              onPressed: () {},
              child: const Text('Devam Et'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ayarlar'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
