import 'package:agri_connect/features/products/presentation/pages/product_details_page.dart';
import 'package:agri_connect/features/products/presentation/pages/products_page.dart';
import 'package:go_router/go_router.dart';

final productRoutes = [
  GoRoute(path: '/products', builder: (context, state) => const ProductsPage()),
  GoRoute(
    path: '/products/:id',
    builder: (context, state) {
      final id = state.pathParameters['id']!;
      //productId: id
      return ProductDetailPage();
    },
  ),
];
