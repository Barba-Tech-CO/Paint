import '../entities/home_stats.dart';
import '../entities/user_greeting.dart';

class LoadHomeDataUsecase {
  Future<UserGreeting> loadUserGreeting() async {
    // Simulating data loading - in real app this would fetch from repository/service
    await Future.delayed(const Duration(milliseconds: 500));
    
    final hour = DateTime.now().hour;
    String greeting;
    
    if (hour < 12) {
      greeting = "Good morning!";
    } else if (hour < 17) {
      greeting = "Good afternoon!";
    } else {
      greeting = "Good evening!";
    }
    
    return UserGreeting(
      greeting: greeting,
      userName: "John",
    );
  }

  Future<HomeStats> loadHomeStats() async {
    // Simulating data loading - in real app this would fetch from repository/service
    await Future.delayed(const Duration(milliseconds: 800));
    
    return const HomeStats(
      activeProjects: 2,
      monthlyRevenue: "\$30,050",
      completedProjects: 6,
      conversionRate: "85%",
    );
  }

  Future<bool> hasActiveProjects() async {
    // Simulating data loading - in real app this would check actual projects
    await Future.delayed(const Duration(milliseconds: 300));
    
    return false; // Currently no projects for demo
  }
}