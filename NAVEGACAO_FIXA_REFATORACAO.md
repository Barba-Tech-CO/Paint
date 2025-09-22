# Refatoração para Navegação Fixa - AppBar e BottomNavBar

## Visão Geral

Este documento detalha a refatoração necessária para implementar navegação fixa onde apenas o conteúdo central das telas principais (Home, Projects, Contacts, Quotes) muda, mantendo AppBar e BottomNavBar sempre visíveis.

## Estrutura Atual vs. Proposta

### Estrutura Atual

Cada tela principal é independente e possui sua própria AppBar e estrutura:

```
HomeView
├── MainLayout
    ├── Scaffold
        ├── AppBar (PaintProAppBar)
        └── Body (conteúdo específico)
    └── BottomNavBar (FloatingBottomNavigationBar)
```

### Estrutura Proposta

Uma tela principal única gerencia toda a navegação:

```
MainScreenView
├── Scaffold
    ├── AppBar (PaintProAppBar) - FIXA
    ├── Body (conteúdo dinâmico) - MUTÁVEL
    └── BottomNavBar (FloatingBottomNavigationBar) - FIXA
```

## Refatoração Detalhada

### 1. Nova Tela Principal

```dart
// lib/view/main_screen/main_screen_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../config/dependency_injection.dart';
import '../../viewmodel/navigation_viewmodel.dart';
import '../../widgets/appbars/paint_pro_app_bar.dart';
import '../../widgets/navigation/floating_bottom_navigation_bar.dart';
import '../main_screen/home_content_widget.dart';
import '../main_screen/projects_content_widget.dart';
import '../main_screen/contacts_content_widget.dart';
import '../main_screen/quotes_content_widget.dart';

class MainScreenView extends StatefulWidget {
  const MainScreenView({super.key});

  @override
  State<MainScreenView> createState() => _MainScreenViewState();
}

class _MainScreenViewState extends State<MainScreenView> {
  late final NavigationViewModel _navigationViewModel;

  @override
  void initState() {
    super.initState();
    _navigationViewModel = getIt<NavigationViewModel>();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _navigationViewModel,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: Consumer<NavigationViewModel>(
          builder: (context, viewModel, child) {
            return PaintProAppBar(
              title: _getCurrentTitle(viewModel.currentRoute),
              toolbarHeight: 80,
            );
          },
        ),
        body: Consumer<NavigationViewModel>(
          builder: (context, viewModel, child) {
            return _getCurrentBody(viewModel.currentRoute);
          },
        ),
        bottomNavigationBar: Consumer<NavigationViewModel>(
          builder: (context, viewModel, child) {
            return FloatingBottomNavigationBar(
              viewModel: viewModel,
            );
          },
        ),
      ),
    );
  }

  String _getCurrentTitle(String currentRoute) {
    switch (currentRoute) {
      case '/home':
        return 'Home';
      case '/projects':
        return 'Projects';
      case '/contacts':
        return 'Contacts';
      case '/quotes':
        return 'Quotes';
      default:
        return 'Paint Pro';
    }
  }

  Widget _getCurrentBody(String currentRoute) {
    switch (currentRoute) {
      case '/home':
        return const HomeContentWidget();
      case '/projects':
        return const ProjectsContentWidget();
      case '/contacts':
        return const ContactsContentWidget();
      case '/quotes':
        return const QuotesContentWidget();
      default:
        return const HomeContentWidget();
    }
  }
}
```

### 2. Refatoração de Classes Existentes

#### Exemplo: ProjectsView → ProjectsContentWidget

**ANTES (ProjectsView atual):**

```dart
// lib/view/projects/projects_view.dart
class ProjectsView extends StatefulWidget {
  const ProjectsView({super.key});

  @override
  State<ProjectsView> createState() => _ProjectsViewState();
}

class _ProjectsViewState extends State<ProjectsView> {
  late final NavigationViewModel _navigationViewModel;
  late final ProjectsViewModel _projectsViewModel;

  @override
  void initState() {
    super.initState();
    _navigationViewModel = getIt<NavigationViewModel>();
    _projectsViewModel = getIt<ProjectsViewModel>();
    _projectsViewModel.initialize();
    _navigationViewModel.updateCurrentRoute('/projects');
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _projectsViewModel,
      child: MainLayout(
        currentRoute: '/projects',
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: const PaintProAppBar(title: 'Projects'),
          body: Consumer<ProjectsViewModel>(
            builder: (context, viewModel, _) {
              // Todo o conteúdo da tela...
            },
          ),
        ),
      ),
    );
  }
}
```

**DEPOIS (ProjectsContentWidget refatorado):**

```dart
// lib/view/main_screen/projects_content_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../config/dependency_injection.dart';
import '../../viewmodel/projects/projects_viewmodel.dart';
import '../../widgets/cards/project_card_widget.dart';
import '../../widgets/form_field/paint_pro_search_field.dart';

class ProjectsContentWidget extends StatefulWidget {
  const ProjectsContentWidget({super.key});

  @override
  State<ProjectsContentWidget> createState() => _ProjectsContentWidgetState();
}

class _ProjectsContentWidgetState extends State<ProjectsContentWidget> {
  late final ProjectsViewModel _projectsViewModel;

  @override
  void initState() {
    super.initState();
    _projectsViewModel = getIt<ProjectsViewModel>();
    _projectsViewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _projectsViewModel,
      child: Consumer<ProjectsViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            );
          }

          if (viewModel.hasError && viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error',
                    style: GoogleFonts.albertSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    viewModel.errorMessage!,
                    style: GoogleFonts.albertSans(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadProjects(),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            );
          }

          if (!viewModel.hasProjects) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.folder_outlined,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No projects',
                    style: GoogleFonts.albertSans(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your projects will appear here',
                    style: GoogleFonts.albertSans(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          // Lista de projetos
          return Column(
            children: [
              // Barra de pesquisa
              if (viewModel.hasProjects)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: PaintProSearchField(
                    hintText: 'Search projects',
                    onChanged: (value) => viewModel.searchQuery = value,
                    onClear: () => viewModel.clearSearch(),
                  ),
                ),

              // Lista de projetos
              if (viewModel.hasProjects)
                Expanded(
                  child: viewModel.hasFilteredProjects
                      ? ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                          ),
                          itemCount: viewModel.filteredProjects.length,
                          itemBuilder: (context, index) {
                            final project = viewModel.filteredProjects[index];
                            return ProjectCardWidget(
                              projectName: project.projectName,
                              personName: project.personName,
                              zonesCount: project.zonesCount,
                              createdDate: project.createdDate,
                              image: project.image,
                              onRename: (newName) {
                                viewModel.renameProject(
                                  project.id.toString(),
                                  newName,
                                );
                              },
                              onDelete: () {
                                viewModel.deleteProject(
                                  project.id.toString(),
                                );
                              },
                            );
                          },
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.search_off,
                                size: 64,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No projects found',
                                style: GoogleFonts.albertSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try a different search',
                                style: GoogleFonts.albertSans(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
            ],
          );
        },
      ),
    );
  }
}
```

### 3. Atualização das Rotas

```dart
// lib/config/routes.dart - Atualização necessária
final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    // ... outras rotas ...

    // Rota principal unificada
    GoRoute(
      path: '/main',
      builder: (context, state) => const MainScreenView(),
    ),

    // Rotas específicas para navegação interna
    GoRoute(
      path: '/home',
      redirect: (context, state) => '/main?tab=home',
    ),
    GoRoute(
      path: '/projects',
      redirect: (context, state) => '/main?tab=projects',
    ),
    GoRoute(
      path: '/contacts',
      redirect: (context, state) => '/main?tab=contacts',
    ),
    GoRoute(
      path: '/quotes',
      redirect: (context, state) => '/main?tab=quotes',
    ),

    // ... outras rotas ...
  ],
);
```

### 4. Atualização do NavigationViewModel

```dart
// lib/viewmodel/navigation_viewmodel.dart - Adições necessárias
class NavigationViewModel extends ChangeNotifier {
  String _currentRoute = '/home';
  String _currentTab = 'home';

  String get currentRoute => _currentRoute;
  String get currentTab => _currentTab;

  void updateCurrentRoute(String route) {
    _currentRoute = route;
    _updateCurrentTab(route);
    notifyListeners();
  }

  void updateCurrentTab(String tab) {
    _currentTab = tab;
    _currentRoute = '/$tab';
    notifyListeners();
  }

  void _updateCurrentTab(String route) {
    switch (route) {
      case '/home':
        _currentTab = 'home';
        break;
      case '/projects':
        _currentTab = 'projects';
        break;
      case '/contacts':
        _currentTab = 'contacts';
        break;
      case '/quotes':
        _currentTab = 'quotes';
        break;
      default:
        _currentTab = 'home';
    }
  }
}
```

## Vantagens da Refatoração

### 1. **Performance**

- AppBar e BottomNavBar não são reconstruídas a cada mudança de tela
- Redução significativa de rebuilds desnecessários
- Transições mais suaves e responsivas

### 2. **Experiência do Usuário**

- Navegação mais fluida entre telas
- Consistência visual mantida
- Comportamento similar a apps nativos populares

### 3. **Manutenibilidade**

- Código mais organizado e modular
- Separação clara entre navegação e conteúdo
- Facilita futuras modificações no layout

### 4. **Reutilização**

- Componentes de conteúdo podem ser reutilizados
- Lógica de navegação centralizada
- Facilita testes unitários

## Estrutura de Arquivos Proposta

```
lib/view/
├── main_screen/
│   ├── main_screen_view.dart
│   ├── home_content_widget.dart
│   ├── projects_content_widget.dart
│   ├── contacts_content_widget.dart
│   └── quotes_content_widget.dart
├── projects/
│   └── projects_view.dart (deprecated)
├── home/
│   └── home_view.dart (deprecated)
├── contacts/
│   └── contacts_view.dart (deprecated)
└── quotes/
    └── quotes_view.dart (deprecated)
```

## Migração Gradual

1. **Fase 1**: Criar `MainScreenView` e `ProjectsContentWidget`
2. **Fase 2**: Migrar `HomeView` → `HomeContentWidget`
3. **Fase 3**: Migrar `ContactsView` → `ContactsContentWidget`
4. **Fase 4**: Migrar `QuotesView` → `QuotesContentWidget`
5. **Fase 5**: Atualizar rotas e remover views antigas

## Considerações Técnicas

### Estado Compartilhado

- ViewModels específicos de cada tela permanecem inalterados
- Apenas a estrutura de apresentação muda
- Estado de navegação centralizado no `NavigationViewModel`

### Navegação

- go_router continua sendo usado
- Redirecionamentos para manter compatibilidade
- Parâmetros de query para identificar aba ativa

### Testes

- Testes unitários dos ContentWidgets
- Testes de integração da navegação
- Manter cobertura de testes existente

Esta refatoração transforma a aplicação em uma experiência mais moderna e eficiente, mantendo toda a funcionalidade existente enquanto melhora significativamente a performance e a experiência do usuário.
