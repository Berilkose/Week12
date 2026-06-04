import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget { // uygulamayı şekillendirir, widgetleri ve diğer ayarlamalar burada yapılır.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Application',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}


class MyAppState extends ChangeNotifier {
  var current = WordPair.random(); // bu class uygulamanın çalışması için gereken verileri tanımlar.
  // uygulamanın asıl verisi bu class içinde tanımlanır ve bu veriler değiştiğinde uygulamanın güncellenmesi için notifyListeners() fonksiyonu çağrılır. 
  void getNext() {// bu fonksiyon, current değişkenini yeni bir rastgele kelime çifti ile günceller ve ardından notifyListeners() fonksiyonunu çağırarak uygulamanın güncellenmesini sağlar.
    current = WordPair.random();
    notifyListeners();// notifyListeners() fonksiyonu, MyAppState sınıfını dinleyen widgetlere, verilerin değiştiğini bildirir ve bu widgetlerin yeniden oluşturulmasını sağlar. 
  }
  // Favorites listesi, kullanıcı tarafından favorilere eklenen kelime çiftlerini saklamak için kullanılır. toggleFavorite() fonksiyonu, 
  //current değişkeninin favorites listesinde olup olmadığını kontrol eder ve buna göre ekleme veya çıkarma işlemi yapar. 
  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

//Favorileri gösteren FavoritesPage widgeti, uygulamanın favoriler sayfasını oluşturur. Bu widget, MyAppState sınıfını dinleyerek favorites listesini alır ve bu listeyi ekranda gösterir. 
//Eğer favorites listesi boşsa, kullanıcıya "No favorites yet." mesajı gösterilir. Aksi takdirde, favori kelime çiftleri bir ListView içinde listelenir.
class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}

// artık MyHomePageState ile kendi değerlerimizi yönetebiliriz.
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// MyHomePage widgeti, uygulamanın ana sayfasını oluşturur. Bu widget, bir Scaffold widgeti içinde bir Row widgeti kullanarak iki ana bölüme ayrılır: NavigationRail ve GeneratorPage.
// NavigationRail, uygulamanın sol tarafında yer alır ve kullanıcıya gezinme seçenekleri sunar. GeneratorPage ise, sağ tarafta yer alır ve kullanıcıya rastgele kelime çiftlerini gösterir.

class _MyHomePageState extends State<MyHomePage> {
var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }  

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                  ],
                  // arayüzü sürekli güncellemek için kullanılıyor.
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


// Bu otomatik olarak BigCard widgetini oluşturur ve pair değişkenini bu widgete gönderir. BigCard widgeti, pair değişkenini kullanarak bir metin oluşturur ve bu metni ekranda gösterir. 
//ElevatedButton widgeti ise, kullanıcıya bir buton sağlar ve bu butona tıklandığında getNext() fonksiyonunu çağırarak uygulamanın güncellenmesini sağlar.
class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // renk seçiminde kullanılan temayı alır. Bu, uygulamanın genel görünümünü ve hissini belirler.
    final style = theme.textTheme.displayMedium!.copyWith( // yazı stilini belirler. 
    );
    return Card( //Text widgetini bir Card widgeti içine yerleştirir. Card widgeti, içeriği görsel olarak vurgulamak için kullanılır ve genellikle kenarlık, gölge ve yuvarlatılmış köşeler gibi özelliklere sahiptir.
      color: theme.colorScheme.primary,
      child: Padding( // Padding widgeti, içindeki widgete belirli bir boşluk ekler. Bu örnekte, Text widgetine 8.0 birimlik bir boşluk eklenir.
        padding: const EdgeInsets.all(20.0),
        child: Text( //Burada Text widgeti, pair değişkenini kullanarak oluşturulan metni ekranda gösterir. pair.asLowerCase ifadesi, 
        //pair değişkenindeki kelime çiftini küçük harflerle birleştirir ve bu metni Text widgetine verir. style parametresi ise, metnin görünümünü belirler.
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}