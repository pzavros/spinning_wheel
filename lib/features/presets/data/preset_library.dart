class Preset {
  const Preset({required this.id, required this.name, required this.items});

  final String id;
  final String name;
  final List<String> items;
}

class PresetLibrary {
  static List<Preset> all() {
    return [
      const Preset(
        id: 'food',
        name: 'Food',
        items: [
          'Pizza',
          'Sushi',
          'Burger',
          'Tacos',
          'Pasta',
          'Ramen',
          'Salad',
          'BBQ',
        ],
      ),
      const Preset(
        id: 'activities',
        name: 'Activities',
        items: [
          'Movie',
          'Gym',
          'Walk',
          'Coffee',
          'Read',
          'Cook',
          'Game Night',
          'Nap',
        ],
      ),
      const Preset(id: 'yes-no', name: 'Yes / No', items: ['Yes', 'No']),
      Preset(
        id: 'numbers-1-10',
        name: 'Random Number (1-10)',
        items: List<String>.generate(10, (index) => '${index + 1}'),
      ),
    ];
  }
}
