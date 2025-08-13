import 'package:go_router/go_router.dart';

import '../../features/tezgah/presentation/pages/home_page.dart';
import '../../features/tezgah/presentation/pages/operations_page.dart';
import '../../features/tezgah/presentation/pages/weaving_page.dart';
import '../../features/tezgah/presentation/pages/warp_operations_page.dart';
import '../../features/tezgah/presentation/pages/fabric_operations_page.dart';

GoRouter buildRouter() {
  return GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: '/operations',
        name: 'operations',
        builder: (context, state) {
          final String initial = (state.extra as String?) ?? '';
          return OperationsPage(initialLoomsText: initial);
        },
      ),
      GoRoute(
        path: '/weaving',
        name: 'weaving',
        builder: (context, state) {
          final String initial = (state.extra as String?) ?? '';
          return WeavingPage(initialLoomsText: initial);
        },
      ),
      GoRoute(
        path: '/warp',
        name: 'warp',
        builder: (context, state) => const WarpOperationsPage(),
      ),
      GoRoute(
        path: '/fabric',
        name: 'fabric',
        builder: (context, state) => const FabricOperationsPage(),
      ),
    ],
  );
}
