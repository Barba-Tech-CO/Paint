import 'package:go_router/go_router.dart';

import '../model/models.dart';
import '../view/views.dart';

final router = GoRouter(
  initialLocation: '/zones',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashView(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthView(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeView(),
    ),
    GoRoute(
      path: '/projects',
      builder: (context, state) => const ProjectsView(),
    ),
    GoRoute(
      path: '/camera',
      builder: (context, state) => const CameraView(),
    ),
    GoRoute(
      path: '/contacts',
      builder: (context, state) => const ContactsView(),
    ),
    GoRoute(
      path: '/highlights',
      builder: (context, state) => const HighlightsView(),
    ),
    GoRoute(
      path: '/contact-details',
      builder: (context, state) => const ContactDetailsView(),
    ),
    GoRoute(
      path: '/create-project',
      builder: (context, state) => const CreateProjectView(),
    ),
    GoRoute(
      path: '/zones',
      builder: (context, state) => const ZonesView(),
    ),
    GoRoute(
      path: '/room-adjust',
      builder: (context, state) => const RoomAdjustView(),
    ),
    GoRoute(
      path: '/select-colors',
      builder: (context, state) => const SelectColorsView(),
    ),
    GoRoute(
      path: '/overview-zones',
      builder: (context, state) {
        // Aceita tanto List<MaterialModel> quanto Map com materiais e zonas
        final extra = state.extra;
        List<MaterialModel>? selectedMaterials;
        List<ZonesCardModel>? selectedZones;

        if (extra is List<MaterialModel>) {
          selectedMaterials = extra;
        } else if (extra is Map) {
          selectedMaterials = extra['materials'] as List<MaterialModel>?;
          selectedZones = extra['zones'] as List<ZonesCardModel>?;
        }

        return OverviewZonesView(
          selectedMaterials: selectedMaterials,
          selectedZones: selectedZones,
        );
      },
    ),
    GoRoute(
      path: '/new-contact',
      builder: (context, state) => const NewContactView(),
    ),
    GoRoute(
      path: '/zones-details',
      builder: (context, state) {
        final zone = state.extra as ZonesCardModel?;
        return ZonesDetailsView(zone: zone);
      },
    ),
    GoRoute(
      path: '/edit-zone',
      builder: (context, state) {
        final zone = state.extra as ZonesCardModel?;
        return EditZoneView(zone: zone);
      },
    ),
    GoRoute(
      path: '/select-material',
      builder: (context, state) {
        return const SelectMaterialView();
      },
    ),
  ],
);
