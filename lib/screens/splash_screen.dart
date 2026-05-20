import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/splash_provider.dart';
import 'onboarding_screen.dart';

class SplashScreen extends ConsumerWidget {

  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final double width = MediaQuery.sizeOf(context).width;
    final double height = MediaQuery.sizeOf(context).height;

    final splashState = ref.watch(splashProvider);

    return Scaffold(
      backgroundColor: Colors.green.shade700,
      body: splashState.when(
        loading: () => Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding:  EdgeInsets.symmetric(horizontal: width * 0.03),
                    child: Image.asset(
                      'assets/images/splash.png',
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: height * 0.28,
                  decoration: BoxDecoration(
                      color: Colors.green.shade800,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(1000),
                          bottomRight: Radius.circular(1000)
                      )
                  ),
                )
            ),


            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/splash_top.png',
                height: 160,
                width: 160,
              ),
            ),


            Positioned(
                top: 100,
                left: 50,
                child: Text("Tree Identity App",style: TextStyle(
                  color: Colors.white.withAlpha(100),
                  fontSize: 42,
                  fontWeight: FontWeight.bold
                ),
                textAlign: TextAlign.center,
                )
            ),

            Positioned(
                top: 210,
                left: 110,
                child: Text("Leaf through the trees",style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                ),
                )
            ),

          ],
        ),

        data: (nextScreen) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            );
          });
          return const SizedBox.shrink();
        },

        error: (error, stack) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}