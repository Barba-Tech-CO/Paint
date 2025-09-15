import 'package:go_router/go_router.dart';

import '../model/contacts/contact_model.dart';
import '../model/material_models/material_model.dart';
import '../model/projects/project_card_model.dart';
import '../view/auth/auth_view.dart';
import '../view/camera/camera_view.dart';
import '../view/contact_details/contact_details_view.dart';
import '../view/contacts/contacts_view.dart';
import '../view/create_project/create_project_view.dart';
import '../view/edit_contact/edit_contact_view.dart';
import '../view/edit_zone/edit_zone_view.dart';
import '../view/home/home_view.dart';
import '../view/new_contact/new_contact_view.dart';
import '../view/overview_zones/overview_zones_view.dart';
import '../view/processing/processing_view.dart';
import '../view/projects/projects_view.dart';
import '../view/quotes/quotes_view.dart';
import '../view/roomplan/roomplan_view.dart';
import '../view/select_material/select_material_view.dart';
import '../view/splash/splash_view.dart';
import '../view/success/success_view.dart';
import '../view/zones/zones_view.dart';
import '../view/zones_details/zones_details_view.dart';

final router = GoRouter(
  initialLocation: '/splash',
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
      builder: (context, state) {
        final projectData = state.extra as Map<String, dynamic>?;
        return CameraView(projectData: projectData);
      },
    ),
    GoRoute(
      path: '/contacts',
      builder: (context, state) => const ContactsView(),
    ),
    GoRoute(
      path: '/quotes',
      builder: (context, state) => const QuotesView(),
    ),
    GoRoute(
      name: 'roomplan',
      path: '/roomplan',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final photos = extra['photos'] as List<String>? ?? [];
        final projectData = extra['projectData'] as Map<String, dynamic>?;
        return RoomPlanView(
          capturedPhotos: photos,
          projectData: projectData,
        );
      },
    ),
    GoRoute(
      name: 'processing',
      path: '/processing',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final photos = extra['photos'] as List<String>? ?? [];
        final roomData = extra['roomData'] as Map<String, dynamic>?;
        final projectData = extra['projectData'] as Map<String, dynamic>?;
        return ProcessingView(
          capturedPhotos: photos,
          roomData: roomData,
          projectData: projectData,
        );
      },
    ),
    GoRoute(
      path: '/contact-details',
      builder: (context, state) {
        final contact = state.extra as ContactModel?;
        if (contact == null) {
          // Se não houver contato, redirecionar para a lista de contatos
          return const ContactsView();
        }
        return ContactDetailsView(contact: contact);
      },
    ),
    GoRoute(
      path: '/create-project',
      builder: (context, state) => const CreateProjectView(),
    ),
    GoRoute(
      path: '/zones',
      builder: (context, state) {
        final zoneData = state.extra as Map<String, dynamic>?;
        return ZonesView(initialZoneData: zoneData);
      },
    ),
    GoRoute(
      path: '/overview-zones',
      builder: (context, state) {
        // Aceita tanto List<MaterialModel> quanto Map com materiais e zonas
        final extra = state.extra;
        List<MaterialModel>? selectedMaterials;
        List<ProjectCardModel>? selectedZones;

        if (extra is List<MaterialModel>) {
          selectedMaterials = extra;
        } else if (extra is Map) {
          selectedMaterials = extra['materials'] as List<MaterialModel>?;
          selectedZones = extra['zones'] as List<ProjectCardModel>?;
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
      path: '/edit-contact',
      builder: (context, state) {
        final contact = state.extra as ContactModel?;
        if (contact == null) {
          // Se não houver contato, redirecionar para a lista de contatos
          return const ContactsView();
        }

        return EditContactView(contact: contact);
      },
    ),
    GoRoute(
      path: '/zones-details',
      builder: (context, state) {
        final zone = state.extra as ProjectCardModel?;
        return ZonesDetailsView(zone: zone);
      },
    ),
    GoRoute(
      path: '/edit-zone',
      builder: (context, state) {
        final zone = state.extra as ProjectCardModel?;
        return EditZoneView(zone: zone);
      },
    ),
    GoRoute(
      path: '/select-material',
      builder: (context, state) {
        return const SelectMaterialView();
      },
    ),
    GoRoute(
      path: '/quotes',
      builder: (context, state) => const QuotesView(),
    ),
    GoRoute(
      path: '/success',
      builder: (context, state) {
        return const SuccessView();
      },
    ),
  ],
);
