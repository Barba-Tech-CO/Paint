import 'package:go_router/go_router.dart';

import '../model/contacts/contact_model.dart';
import '../model/projects/project_card_model.dart';
import '../use_case/navigation/navigation_data_use_case.dart';
import '../view/auth/auth_view.dart';
import '../view/auth/login_screen.dart';
import '../view/auth/signup_screen.dart';
import '../view/auth/verify_otp_screen.dart';
import '../view/camera/camera_view.dart';
import '../view/settings/delete_account_view.dart';
import '../view/contact_details/contact_details_view.dart';
import '../view/contacts/contacts_view.dart';
import '../view/create_project/create_project_view.dart';
import '../view/edit_contact/edit_contact_view.dart';
import '../view/edit_zone/edit_zone_view.dart';
import '../view/home/home_view.dart';
import '../view/new_contact/new_contact_view.dart';
import '../view/overview_zones/overview_zones_view.dart';
import '../view/projects/projects_view.dart';
import '../view/quotes/quotes_view.dart';
import '../view/roomplan/roomplan_view.dart';
import '../view/select_material/select_material_view.dart';
import '../view/splash/splash_view.dart';
import '../view/success/success_view.dart';
import '../view/zones/zones_view.dart';
import '../view/zones_details/zones_details_view.dart';
import '../view/estimate/estimate_detail_view.dart';
import '../view/connect_ghl/connect_ghl_view.dart';
import '../widgets/loading/loading_widget.dart';

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
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/verify-otp',
      builder: (context, state) {
        final email = state.extra as String? ?? '';
        return VerifyOtpScreen(email: email);
      },
    ),
    GoRoute(
      path: '/delete-account',
      builder: (context, state) => const DeleteAccountView(),
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
        return LoadingWidget(
          title: 'Processing...',
          subtitle: 'Processing Photos',
          description: 'Calculating measurements...',
          duration: const Duration(seconds: 5),
          navigateToOnComplete: '/zones',
        );
      },
    ),
    GoRoute(
      name: 'loading',
      path: '/loading',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return LoadingWidget(
          title: extra['title'] ?? 'Loading...',
          subtitle: extra['subtitle'],
          description: extra['description'],
          duration: extra['duration'] ?? const Duration(seconds: 3),
          navigateToOnComplete: extra['navigateToOnComplete'],
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
      name: 'overview-zones',
      builder: (context, state) {
        final navigationDataUseCase = NavigationDataUseCase();
        final navigationData = navigationDataUseCase.processOverviewZonesData(
          state.extra,
        );

        return OverviewZonesView(
          selectedMaterials: navigationData.selectedMaterials,
          materialQuantities: navigationData.materialQuantities,
          selectedZones: navigationData.selectedZones,
          projectData: navigationData.projectData,
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
        // Handle both ProjectCardModel and Map<String, dynamic> cases
        ProjectCardModel? zone;
        if (state.extra is ProjectCardModel) {
          zone = state.extra as ProjectCardModel;
        } else if (state.extra is Map<String, dynamic>) {
          // Convert Map to ProjectCardModel if needed
          final zoneData = state.extra as Map<String, dynamic>;
          zone = ProjectCardModel.fromJson(zoneData);
        }
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
        final projectData = state.extra as Map<String, dynamic>?;
        return SelectMaterialView(projectData: projectData);
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
    GoRoute(
      path: '/estimate-detail',
      builder: (context, state) {
        final projectId = state.extra as int? ?? 0;
        return EstimateDetailView(projectId: projectId);
      },
    ),
    GoRoute(
      path: '/connect-ghl',
      builder: (context, state) => const ConnectGhlView(),
    ),
  ],
);
