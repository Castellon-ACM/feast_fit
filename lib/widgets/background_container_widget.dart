import 'package:flutter/material.dart';

class BackgroundContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final bool useGradient;

  const BackgroundContainer({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.useGradient = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: useGradient
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomCenter,
                colors: isDarkMode
                    ? [
                        const Color(0xFF1A1A1A),
                        const Color(0xFF2D2D2D),
                      ]
                    : [
                        const Color.fromARGB(255, 255, 255, 255),
                        const Color.fromARGB(255, 240, 240, 240), // Diferente color
                      ],
              )
            : null,
        color: !useGradient
            ? (isDarkMode ? const Color(0xFF1A1A1A) : Colors.white)
            : null,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -50,
            child: Transform.rotate(
              angle: -0.2,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(200),
                  gradient: RadialGradient(
                    colors: isDarkMode
                        ? [
                            const Color(0xFF3D3D3D).withOpacity(0.7),
                            const Color(0xFF1A1A1A).withOpacity(0),
                          ]
                        : [
                            const Color(0xFFFFFFFF).withOpacity(0.7),
                            const Color(0xFFFFF5F5).withOpacity(0.0),
                          ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 150,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(150),
                gradient: RadialGradient(
                  colors: isDarkMode
                      ? [
                          const Color(0xFF3D3D3D).withOpacity(0.5),
                          const Color(0xFF1A1A1A).withOpacity(0),
                        ]
                      : [
                          const Color(0xFFFFFFFF).withOpacity(0.7),
                          const Color(0xFFFFFFFF).withOpacity(0.0),
                        ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              painter: CurvePainter(isDarkMode: isDarkMode),
              size: const Size(double.infinity, 300),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

class CurvePainter extends CustomPainter {
  final bool isDarkMode;

  CurvePainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: isDarkMode
            ? [
                const Color(0xFF3D3D3D).withOpacity(0.4),
                const Color(0xFF3D3D3D).withOpacity(0.6),
                const Color(0xFF3D3D3D).withOpacity(0.4),
              ]
            : [
                const Color(0xFFCCCCCC).withOpacity(0.4),
                const Color(0xFFCCCCCC).withOpacity(0.6),
                const Color(0xFFCCCCCC).withOpacity(0.4),
              ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    var path = Path();
    path.moveTo(0, size.height);

    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.5,
      size.width * 0.5,
      size.height * 0.7,
    );

    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.9,
      size.width,
      size.height * 0.6,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
