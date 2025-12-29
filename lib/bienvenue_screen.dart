import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store_buy/constants/app_colors.dart';

class BienvenueScreen extends StatelessWidget {
  const BienvenueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 60.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Store Self
                      Column(
                        children: [
                          Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryDark,
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Image.asset(
                                'img/logo-storeself.png',
                                width: 500,
                                height: 500,

                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            "STORE SELF",
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                              letterSpacing: 2,
                              fontFamily: 'Wizzard',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 80),

                      // Texte de bienvenue
                             const Text(
                               "Bienvenue sur Store Self\n votre centre commerciale",
                               textAlign: TextAlign.center,
                               style: TextStyle(
                                 fontSize: 24,
                                 fontWeight: FontWeight.w500,
                                 color: AppColors.primaryDark,
                                 height: 1.5,
                               ),
                             ),

                      const SizedBox(height: 80),

                      // Bouton principal
                             ElevatedButton(
                               onPressed: () async {
                                 // Check if onboarding is completed
                                 final prefs = await SharedPreferences.getInstance();
                                 final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

                                 if (!onboardingCompleted) {
                                   if(context.mounted){
                                     Navigator.pushNamed(context, '/onboarding');
                                   }
                                 } else {
                                   if (context.mounted){
                                     Navigator.pushNamed(context, '/connect');
                                   }
                                 }
                               },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlueAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                          shadowColor: AppColors.primaryDark,
                        ),
                        child: const Text(
                          "Se connecter",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Bouton secondaire
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/connect');
                        },
                               child: const Text(
                                 "Créer un compte",
                                 style: TextStyle(
                                   color: AppColors.primaryDark,
                                   fontSize: 14,
                                   fontWeight: FontWeight.w500,
                                 ),
                               ),
                      ),

                      const Spacer(),

                      // Indicateurs de page
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryDark,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

        //  ),
       // ),
     // ),
    );
  }
}
