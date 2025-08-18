import '../entities/project.dart';

class LoadProjectsUsecase {
  Future<List<Project>> execute() async {
    // Simulating data loading - in real app this would fetch from repository/service
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // For now, return empty list to show empty state
    // In a real app, this would fetch from a repository
    return [];
    
    // Example of what it could return:
    // return [
    //   Project(
    //     id: '1',
    //     name: 'Living Room Renovation',
    //     description: 'Complete living room paint job',
    //     status: 'In Progress',
    //     createdAt: DateTime.now().subtract(const Duration(days: 5)),
    //     estimatedValue: 2500.0,
    //     clientName: 'John Smith',
    //   ),
    //   Project(
    //     id: '2',
    //     name: 'Kitchen Remodel',
    //     description: 'Kitchen walls and ceiling painting',
    //     status: 'Completed',
    //     createdAt: DateTime.now().subtract(const Duration(days: 15)),
    //     updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    //     estimatedValue: 1800.0,
    //     clientName: 'Jane Doe',
    //   ),
    // ];
  }
}