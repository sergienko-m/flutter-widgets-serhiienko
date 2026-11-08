import '../models/product.dart';
import '../models/user.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'Flutter Widgets Lab';
  static const double breakpointWide = 720;
  static const int maxCartQuantity = 10;
  static const Duration shortAnimation = Duration(milliseconds: 300);
}

const User kDemoUser = User(
  id: 'u1',
  name: 'Олександр Шевченко',
  email: 'oleksandr@example.com',
);

/// Mock-дані (API contract описано в docs/ARCHITECTURE.md).
const List<Product> kMockProducts = [
  Product(
    id: 'p1',
    title: 'Бездротові навушники',
    description: 'Активне шумозаглушення, 30 годин роботи.',
    price: 1899,
    category: 'Електроніка',
    emoji: '🎧',
    colorValue: 0xFF42A5F5,
  ),
  Product(
    id: 'p2',
    title: 'Розумний годинник',
    description: 'Пульс, сон, GPS та водостійкість.',
    price: 3499,
    category: 'Електроніка',
    emoji: '⌚',
    colorValue: 0xFF7E57C2,
  ),
  Product(
    id: 'p3',
    title: 'Механічна клавіатура',
    description: 'Hot-swap перемикачі, підсвітка RGB.',
    price: 2299,
    category: 'Електроніка',
    emoji: '⌨️',
    colorValue: 0xFF26A69A,
  ),
  Product(
    id: 'p4',
    title: 'Рюкзак для ноутбука',
    description: 'Відсік до 16", водовідштовхувальна тканина.',
    price: 1299,
    category: 'Аксесуари',
    emoji: '🎒',
    colorValue: 0xFFFF7043,
  ),
  Product(
    id: 'p5',
    title: 'Термокружка',
    description: 'Тримає тепло до 8 годин.',
    price: 549,
    category: 'Аксесуари',
    emoji: '☕',
    colorValue: 0xFF8D6E63,
  ),
  Product(
    id: 'p6',
    title: 'Настільна лампа',
    description: 'Регулювання яскравості та температури світла.',
    price: 899,
    category: 'Дім',
    emoji: '💡',
    colorValue: 0xFFFFCA28,
  ),
  Product(
    id: 'p7',
    title: 'Кімнатна рослина',
    description: 'Невибаглива, підходить для початківців.',
    price: 399,
    category: 'Дім',
    emoji: '🪴',
    colorValue: 0xFF66BB6A,
  ),
  Product(
    id: 'p8',
    title: 'Килимок для йоги',
    description: 'Нековзне покриття, товщина 6 мм.',
    price: 749,
    category: 'Спорт',
    emoji: '🧘',
    colorValue: 0xFFEC407A,
  ),
];
