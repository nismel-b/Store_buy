import'package:flutter/material.dart';
import 'dart:async';
import 'package:store_buy/bienvenue_screen.dart';

class SplashScreen extends StatefulWidget{
  const SplashScreen ({super.key});
  @override
  State<SplashScreen> createState()=> _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin{

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  double _loadingProgress = 0.0;

  @override
  void initState(){
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn)
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut)
    );
    _controller.forward();
    _startLoading();

  }
  void _startLoading(){
    Timer.periodic(const Duration(milliseconds: 30), (timer){
      setState(() {
        _loadingProgress += 0.01;
        if(_loadingProgress >= 1.0){
          timer.cancel();
          _navigateToHome();
        }
      });
    });
}
void _navigateToHome(){
    Future.delayed(const Duration(milliseconds: 500),(){
      if(!mounted)return;
      {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => BienvenueScreen())
        );
      }
    });
}
@override
  void dispose(){
    _controller.dispose();
    super.dispose();
}
@override
  Widget build (BuildContext context){
    return Scaffold(
      body: SafeArea(
            child:  Center(
              child: FadeTransition(opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(scale: _scaleAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          size: 96,
                          color: Color(0xFF4F46E5),
                        ),
                      ),),
                    const SizedBox(height: 48,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Store',
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -1,
                          ),),
                        Text('Self',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF567ACC),
                            letterSpacing: -1,
                          ),),
                        const SizedBox(height: 12,),
                        Text('Votre centre commerciale à portée de main',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                            color: Colors.white.withValues(alpha:0.9),
                            letterSpacing: 1.2,
                          ),),
                        const SizedBox(height: 64,),

                        //barre de chargement
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 64),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: _loadingProgress,
                                  backgroundColor: Colors.white.withValues(alpha:0.2),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(
                                      0xFFA6D0F1)),
                                  minHeight: 8,

                                ),
                              ),
                              const SizedBox(height: 24,),
                              Text('Chargement en cours...',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha:0.7),
                                  fontSize: 14,
                                ),)
                            ],
                          ),
                        ),

                      ],
                    ),
                  ],
                ),),
            ),),


    );
}
}