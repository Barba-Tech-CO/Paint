import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../viewmodel/auth/auth_viewmodel.dart';

class AuthErrorState extends StatelessWidget {
  final AuthViewModel authViewModel;

  const AuthErrorState({
    super.key,
    required this.authViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Authentication'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 80.sp,
                color: Colors.red,
              ),
              SizedBox(height: 24.h),
              Text(
                'Authentication Error',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                authViewModel.state.errorMessage ??
                    'Unable to complete authentication',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              if (authViewModel.state.canRetry) ...[
                ElevatedButton(
                  onPressed: () async {
                    await authViewModel.retryAuthentication();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 32.w,
                      vertical: 16.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Try Again',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ),
                SizedBox(height: 16.h),
              ],
              TextButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  }
                },
                child: Text(
                  'Go Back',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
