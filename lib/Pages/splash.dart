import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:awas_app/Pages/Navigation/navigationForPages.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _awasTextAnimation;
  late Animation<double> _securityTextAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 3500),
      vsync: this,
    );

    // Animación para la escala del logo (ojo)
    _logoScaleAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    // Animación para la opacidad del logo
    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Animación para el texto AWAS
    _awasTextAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.7, curve: Curves.easeInOut),
      ),
    );

    // Animación para el texto Home Security
    _securityTextAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.8, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    // Navegar a la siguiente pantalla después de completar la animación
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 4000), () {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const navigationForPages(),
            transitionDuration: const Duration(milliseconds: 800),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? Colors.black : const Color(0xFFF5F5F5);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1A2138);

    return Scaffold(
      backgroundColor: bgColor,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Logo que se escala
                FadeTransition(
                  opacity: _logoOpacityAnimation,
                  child: ScaleTransition(
                    scale: _logoScaleAnimation,
                    child: SizedBox(
                      width: size.width * 0.7,
                      height: size.width * 0.7,
                      child: Image.asset(
                        Theme.of(context).brightness == Brightness.dark
                            ? "assets/ojonegrocut.PNG"
                            : "assets/ojoblancocut.PNG",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.05),

                // Texto AWAS
                FadeTransition(
                  opacity: _awasTextAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.5),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: _controller,
                        curve: const Interval(0.5, 0.7, curve: Curves.easeOut),
                      ),
                    ),
                    child: Text(
                      "AWAS",
                      style: GoogleFonts.poppins(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        letterSpacing: 6.0,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Texto Home Security
                FadeTransition(
                  opacity: _securityTextAnimation,
                  child: Text(
                    "HOME SECURITY",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Indicador de carga
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDarkMode ? Colors.white : const Color(0xFF1A2138),
                      ),
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}