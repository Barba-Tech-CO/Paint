# LoadingWidget - Documentação de Uso

O `LoadingWidget` foi refatorado para ser mais flexível e reutilizável em diferentes contextos da aplicação.

## Uso Básico

### 1. Usando o LoadingHelper (Recomendado)

```dart
import '../../helpers/loading_helper.dart';

// Para envio de quote (fluxo específico)
LoadingHelper.navigateToQuoteLoading(context);

// Para processamento de fotos
LoadingHelper.navigateToPhotoProcessing(
  context,
  navigateToOnComplete: '/camera',
);

// Loading personalizado
LoadingHelper.navigateToCustomLoading(
  context,
  title: 'Uploading',
  subtitle: 'Uploading Files',
  description: 'Please wait while we upload your files...',
  duration: Duration(seconds: 5),
  navigateToOnComplete: '/dashboard',
);
```

### 2. Usando GoRouter diretamente

```dart
context.go('/loading', extra: {
  'title': 'Custom Title',
  'subtitle': 'Custom Subtitle',
  'description': 'Custom description...',
  'duration': Duration(seconds: 4),
  'navigateToOnComplete': '/target-route',
});
```

### 3. Loading com callback (Dialog)

```dart
LoadingHelper.navigateToLoadingWithCallback(
  context,
  title: 'Processing',
  subtitle: 'Calculating results',
  duration: Duration(seconds: 3),
  onComplete: () {
    // Código personalizado após loading
    showDialog(/* ... */);
    // ou qualquer outra ação
  },
);
```

## Parâmetros Disponíveis

| Parâmetro              | Tipo          | Padrão                        | Descrição                           |
| ---------------------- | ------------- | ----------------------------- | ----------------------------------- |
| `title`                | String?       | 'Processing'                  | Título no AppBar                    |
| `subtitle`             | String?       | 'Processing Photos'           | Título principal na tela            |
| `description`          | String?       | 'Calculating measurements...' | Descrição/subtítulo                 |
| `duration`             | Duration?     | 3 segundos                    | Tempo de loading                    |
| `navigateToOnComplete` | String?       | null                          | Rota para navegar ao finalizar      |
| `onComplete`           | VoidCallback? | null                          | Callback ao finalizar (Dialog mode) |

## Exemplos de Uso por Contexto

### Upload de Arquivos

```dart
LoadingHelper.navigateToCustomLoading(
  context,
  title: 'Uploading',
  subtitle: 'Uploading Photos',
  description: 'Uploading images to server...',
  duration: Duration(seconds: 8),
  navigateToOnComplete: '/projects',
);
```

### Processamento de IA

```dart
LoadingHelper.navigateToCustomLoading(
  context,
  title: 'AI Processing',
  subtitle: 'Analyzing Image',
  description: 'AI is analyzing your photo...',
  duration: Duration(seconds: 6),
  navigateToOnComplete: '/results',
);
```

### Salvamento de Dados

```dart
LoadingHelper.navigateToLoadingWithCallback(
  context,
  title: 'Saving',
  subtitle: 'Saving Project',
  duration: Duration(seconds: 2),
  onComplete: () {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Project saved successfully!')),
    );
    context.go('/dashboard');
  },
);
```

## Vantagens da Nova Implementação

1. **Reutilizável**: Pode ser usado em qualquer contexto
2. **Flexível**: Textos e comportamentos personalizáveis
3. **Tipado**: Parâmetros seguros com tipos definidos
4. **Padronizado**: Helper methods para casos comuns
5. **Não-bloqueante**: Não interfere com outros fluxos

## Migração

Se você estava usando o `LoadingWidget` antigo, simplesmente substitua:

```dart
// ANTES
context.go('/loading');

// DEPOIS (comportamento similar ao anterior)
LoadingHelper.navigateToPhotoProcessing(context);
```
