import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_detector/screens/subscription_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/onboarding_provider.dart'; // Provider import kiya

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  static final List<Map<String, String>> _onboardingData = [
    {
      "image": "assets/images/onboarding 1.png",
      "title": "Let’s Plant",
      "subtitle": "A step towards less\npollution",
    },
    {
      "image": "assets/images/onboarding 2.png",
      "title": "Vision",
      "subtitle": "At Identi-tree organization, we envision a future where barren landscapes are transformed into thriving ecosystems through our reforestation project. Our vision goes beyond planting trees; we strive to cultivate a deep connection between people and nature, inspiring communities to actively participate in sustainable practices. ",
    },
    {
      "image": "assets/images/onboarding 3.png",
      "title": "Mission",
      "subtitle": "At Reforest Sri Lanka, our mission is to plant one million trees across the country by 2030. Through strategic partnerships, community engagement, and sustainable practices, we aim to revitalize landscapes, restore biodiversity, and combat climate change. Our commitment extends beyond the numerical goal.",
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double width = MediaQuery.sizeOf(context).width;
    final double height = MediaQuery.sizeOf(context).height;

    final currentPage = ref.watch(onboardingProvider);

    final PageController pageController = PageController(initialPage: currentPage);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
              color: Colors.black.withAlpha(990),
              colorBlendMode: BlendMode.dstATop,
            ),
          ),



          PageView.builder(
            controller: pageController,
            itemCount: _onboardingData.length,
            onPageChanged: (index) {
              ref.read(onboardingProvider.notifier).setPage(index);
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: width * 0.06),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: height * 0.01),
                    Image.asset(
                      _onboardingData[index]["image"]!,
                      height: height * 0.35,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: height * 0.03),
                    Text(
                      _onboardingData[index]["title"]!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                     SizedBox(height: 15),
                    Text(
                      _onboardingData[index]["subtitle"]!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),

          Positioned(
            bottom: height * 0.05,
            left: width * 0.06,
            right: width * 0.06,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _onboardingData.length,
                        (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentPage == index
                            ? const Color(0xFFFF9800)
                            : Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: height * 0.04),

                Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: ElevatedButton(
                      onPressed: () async {
                        if (currentPage < _onboardingData.length - 1) {
                          pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('has_seen_onboarding', true);

                          if (context.mounted) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                            );
                          }
                        }
                      },                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child:
                    Text(
                      currentPage == 0
                          ? "Start"
                          : "Next",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}