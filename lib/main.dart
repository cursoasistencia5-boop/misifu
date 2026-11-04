import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

// ───────────────────────── PALETA DE COLORES ─────────────────────────
class Paleta {
  static const bordo = Color(0xFF6D2932);
  static const bordoClaro = Color(0xFFA33F4D);
  static const bordoOscuro = Color(0xFF2A080C);
  static const negroVino = Color(0xFF0D0204);
  static const beige = Color(0xFFEAE0D5);
  static const hueso = Color(0xFFF7F2EA);
  static const dorado = Color(0xFFC9A66B);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MisifuApp());
}

class MisifuApp extends StatelessWidget {
  const MisifuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MISIFU Jujuy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Paleta.bordo,
        scaffoldBackgroundColor: Paleta.hueso,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Paleta.bordo,
          primary: Paleta.bordo,
          secondary: Paleta.beige,
          surface: Paleta.hueso,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Paleta.bordo,
          foregroundColor: Paleta.hueso,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
              color: Paleta.hueso,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Paleta.bordo,
            foregroundColor: Paleta.hueso,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            textStyle:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: const VideoIntroScreen(),
    );
  }
}

// ───────────────── PANTALLA INICIAL CON VIDEO ─────────────────
class VideoIntroScreen extends StatefulWidget {
  const VideoIntroScreen({super.key});

  @override
  State<VideoIntroScreen> createState() => _VideoIntroScreenState();
}

class _VideoIntroScreenState extends State<VideoIntroScreen> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _inicializarVideo();
  }

  Future<void> _inicializarVideo() async {
    VideoPlayerController? c;
    try {
      c = VideoPlayerController.asset('assets/intro.mp4');
      await c.initialize().timeout(const Duration(seconds: 8));
    } catch (_) {
      await c?.dispose();
      c = null;
    }
    if (c == null) {
      if (mounted) setState(() => _hasError = true);
      return;
    }
    if (!mounted) {
      await c.dispose();
      return;
    }
    await c.setLooping(true);
    await c.setVolume(0); // Chrome solo reproduce si está sin sonido
    _controller = c;
    setState(() => _initialized = true);
    try {
      await c.play();
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _irARegistro() {
    Navigator.pushReplacement(
      context,
      rutaAnimada(const AuthDualScreen(empezarLogin: false)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Paleta.negroVino,
      body: Stack(
        children: [
          Positioned.fill(
            child: _initialized && _controller != null
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller!.value.size.width,
                      height: _controller!.value.size.height,
                      child: VideoPlayer(_controller!),
                    ),
                  )
                : (_hasError
                    ? Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Paleta.bordo, Paleta.negroVino],
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.pets, size: 90, color: Paleta.beige),
                        ),
                      )
                    : const Center(
                        child: CircularProgressIndicator(color: Paleta.bordoClaro),
                      )),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Paleta.bordoOscuro.withOpacity(0.65),
                    Paleta.negroVino.withOpacity(0.92),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'MISIFU',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 10,
                      color: Paleta.hueso,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Jujuy · Red de Rescate y Adopción',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      letterSpacing: 2,
                      color: Paleta.beige.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 34),
                  BotonBordo(
                    texto: 'COMENZAR / REGISTRARSE',
                    icono: Icons.arrow_forward_rounded,
                    onTap: _irARegistro,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────── FONDO CON LÍNEAS DE CIRCUITO ─────────────────
class CircuitoPainter extends CustomPainter {
  final double pulso;
  final bool claro;
  CircuitoPainter(this.pulso, {this.claro = false});

  static const _rutas = <List<Offset>>[
    [Offset(0.00, 0.22), Offset(0.12, 0.22), Offset(0.12, 0.00)],
    [Offset(0.00, 0.78), Offset(0.07, 0.78), Offset(0.07, 1.00)],
    [Offset(1.00, 0.18), Offset(0.90, 0.18), Offset(0.90, 0.00)],
    [Offset(1.00, 0.82), Offset(0.93, 0.82), Offset(0.93, 0.60), Offset(1.00, 0.60)],
    [Offset(0.00, 0.50), Offset(0.04, 0.50), Offset(0.04, 0.40), Offset(0.00, 0.40)],
    [Offset(0.30, 1.00), Offset(0.30, 0.93), Offset(0.45, 0.93), Offset(0.45, 1.00)],
    [Offset(0.62, 0.00), Offset(0.62, 0.06), Offset(0.78, 0.06), Offset(0.78, 0.00)],
  ];

  @override
  void paint(Canvas canvas, Size s) {
    final linea = Paint()
      ..color = claro
          ? Paleta.bordo.withOpacity(0.30)
          : Paleta.bordoClaro.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final brillo = Paint()
      ..color = claro
          ? Paleta.bordoClaro.withOpacity(0.12)
          : Paleta.bordoClaro.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    for (final r in _rutas) {
      final path = Path()..moveTo(r.first.dx * s.width, r.first.dy * s.height);
      for (final p in r.skip(1)) {
        path.lineTo(p.dx * s.width, p.dy * s.height);
      }
      canvas.drawPath(path, brillo);
      canvas.drawPath(path, linea);
    }

    int i = 0;
    for (final r in _rutas) {
      for (final p in [r.first, r.last]) {
        final fase = (math.sin((pulso * 2 * math.pi) + i) + 1) / 2;
        final c = Offset(p.dx * s.width, p.dy * s.height);
        canvas.drawCircle(
            c,
            7 + fase * 4,
            Paint()
              ..color = (claro ? Paleta.bordoClaro : Paleta.beige)
                  .withOpacity(0.10 + 0.15 * fase)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));
        canvas.drawCircle(
            c, 3.2, Paint()..color = claro ? Paleta.hueso : Paleta.beige.withOpacity(0.9));
        canvas.drawCircle(
            c,
            3.2,
            Paint()
              ..style = PaintingStyle.stroke
              ..color = claro ? Paleta.bordo : Paleta.bordoClaro
              ..strokeWidth = 1.2);
        i++;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CircuitoPainter old) =>
      old.pulso != pulso || old.claro != claro;
}

// ───────────── RECORTE DIAGONAL DEL PANEL ─────────────
class DiagonalClipper extends CustomClipper<Path> {
  final bool alaIzquierda;
  DiagonalClipper(this.alaIzquierda);

  @override
  Path getClip(Size s) {
    final p = Path();
    if (alaIzquierda) {
      p.moveTo(0, 0);
      p.lineTo(s.width * 0.78, 0);
      p.lineTo(s.width, s.height);
      p.lineTo(0, s.height);
    } else {
      p.moveTo(s.width * 0.22, 0);
      p.lineTo(s.width, 0);
      p.lineTo(s.width, s.height);
      p.lineTo(0, s.height);
    }
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant DiagonalClipper old) =>
      old.alaIzquierda != alaIzquierda;
}

// ───────────────────── PANTALLA LOGIN / REGISTRO ─────────────────────
class AuthDualScreen extends StatefulWidget {
  final bool empezarLogin;
  const AuthDualScreen({super.key, this.empezarLogin = false});

  @override
  State<AuthDualScreen> createState() => _AuthDualScreenState();
}

class _AuthDualScreenState extends State<AuthDualScreen>
    with SingleTickerProviderStateMixin {
  late bool _isLogin = widget.empezarLogin;
  late final AnimationController _pulso;
  bool _verPassword = false;

  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  final _nombreC = TextEditingController();
  final _edadC = TextEditingController();
  final _dniC = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pulso = AnimationController(vsync: this, duration: const Duration(seconds: 5))
      ..repeat();
  }

  @override
  void dispose() {
    _pulso.dispose();
    _emailC.dispose();
    _passC.dispose();
    _nombreC.dispose();
    _edadC.dispose();
    _dniC.dispose();
    super.dispose();
  }

  void _aviso(String msg, {Color color = Paleta.bordo}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _procesarAccion() {
    if (_emailC.text.trim().isEmpty || _passC.text.isEmpty) {
      _aviso('Completá tu correo y contraseña.', color: Colors.red.shade800);
      return;
    }
    if (!_isLogin) {
      final edad = int.tryParse(_edadC.text.trim()) ?? 0;
      if (_nombreC.text.trim().isEmpty || _dniC.text.trim().isEmpty) {
        _aviso('Completá tu nombre y DNI.', color: Colors.red.shade800);
        return;
      }
      if (edad < 18) {
        _aviso('ALERTA: Debes ser mayor de 18 años para registrarte.',
            color: Colors.red.shade800);
        return;
      }
    }
    if (!_isLogin) {
      Sesion.nombre = _nombreC.text.trim();
      Sesion.edad = _edadC.text.trim();
      Sesion.dni = _dniC.text.trim();
      Sesion.email = _emailC.text.trim();
      _passC.clear();
      setState(() => _isLogin = true);
      _aviso('¡Cuenta creada! Ahora iniciá sesión.', color: Colors.green.shade700);
      return;
    }
    if (Sesion.nombre == 'Invitado' || Sesion.email != _emailC.text.trim()) {
      final base = _emailC.text.trim().split('@').first;
      if (Sesion.nombre == 'Invitado' && base.isNotEmpty) {
        Sesion.nombre = base[0].toUpperCase() + base.substring(1);
      }
      Sesion.email = _emailC.text.trim();
    }
    Navigator.pushReplacement(context, rutaAnimada(const MainScreen()));
  }

  void _alternar() => setState(() => _isLogin = !_isLogin);

  InputDecoration _deco(String label, IconData icono, {Widget? suffix}) {
    return InputDecoration(
      hintText: label,
      hintStyle: TextStyle(color: Paleta.beige.withOpacity(0.55), fontSize: 14),
      prefixIcon: Icon(icono, color: Paleta.beige.withOpacity(0.8), size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withOpacity(0.07),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Paleta.beige.withOpacity(0.12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Paleta.bordoClaro, width: 1.6),
      ),
    );
  }

  Widget _campo(TextEditingController c, String label, IconData icono,
      {bool oculto = false, TextInputType? tipo, Widget? suffix}) {
    return TextField(
      controller: c,
      obscureText: oculto,
      keyboardType: tipo,
      cursorColor: Paleta.beige,
      style: const TextStyle(color: Paleta.hueso),
      decoration: _deco(label, icono, suffix: suffix),
    );
  }

  Widget _botonPrincipal() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
            colors: [Paleta.bordoClaro, Paleta.bordo]),
        boxShadow: [
          BoxShadow(
              color: Paleta.bordoClaro.withOpacity(0.45),
              blurRadius: 18,
              offset: const Offset(0, 6)),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Paleta.hueso,
        ),
        onPressed: _procesarAccion,
        child: Text(_isLogin ? 'Ingresar' : 'Registrarme'),
      ),
    );
  }

  Widget _enlaceCambio() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isLogin ? '¿No tenés cuenta? ' : '¿Ya tenés cuenta? ',
          style: TextStyle(color: Paleta.beige.withOpacity(0.75), fontSize: 12),
        ),
        GestureDetector(
          onTap: _alternar,
          child: Text(
            _isLogin ? 'Registrate' : 'Iniciá sesión',
            style: const TextStyle(
                color: Paleta.dorado, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _formulario() {
    return Column(
      key: ValueKey(_isLogin),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _isLogin ? 'Iniciar Sesión' : 'Registro',
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Paleta.hueso,
              letterSpacing: 0.5),
        ),
        const SizedBox(height: 22),
        if (!_isLogin) ...[
          _campo(_nombreC, 'Nombre y Apellido', Icons.person_outline),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: _campo(_edadC, 'Edad', Icons.cake_outlined,
                    tipo: TextInputType.number)),
            const SizedBox(width: 10),
            Expanded(
                flex: 2,
                child: _campo(_dniC, 'DNI (sin puntos)', Icons.badge_outlined,
                    tipo: TextInputType.number)),
          ]),
          const SizedBox(height: 12),
        ],
        _campo(_emailC, 'Correo electrónico', Icons.mail_outline,
            tipo: TextInputType.emailAddress),
        const SizedBox(height: 12),
        _campo(
          _passC,
          'Contraseña',
          Icons.lock_outline,
          oculto: !_verPassword,
          suffix: IconButton(
            icon: Icon(
              _verPassword ? Icons.visibility : Icons.visibility_off,
              color: Paleta.beige.withOpacity(0.7),
              size: 20,
            ),
            onPressed: () => setState(() => _verPassword = !_verPassword),
          ),
        ),
        const SizedBox(height: 22),
        _botonPrincipal(),
        const SizedBox(height: 14),
        _enlaceCambio(),
      ],
    );
  }

  Widget _mensajeBienvenida({required bool compacto}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 34, vertical: compacto ? 26 : 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment:
            compacto ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Paleta.beige.withOpacity(0.12),
              border: Border.all(color: Paleta.beige.withOpacity(0.3)),
            ),
            child: const Icon(Icons.pets, size: 34, color: Paleta.beige),
          ),
          const SizedBox(height: 18),
          Text(
            _isLogin ? '¡BIENVENIDO\nDE NUEVO!' : '¡HOLA,\nAMIGO!',
            textAlign: compacto ? TextAlign.center : TextAlign.start,
            style: const TextStyle(
                fontSize: 30,
                height: 1.1,
                fontWeight: FontWeight.w900,
                color: Paleta.hueso,
                letterSpacing: 0.8),
          ),
          const SizedBox(height: 12),
          Text(
            _isLogin
                ? 'Ingresá con tu cuenta para seguir ayudando a las mascotas de Jujuy.'
                : 'Registrate con tus datos y formá parte de la red de rescate y adopción en Jujuy.',
            textAlign: compacto ? TextAlign.center : TextAlign.start,
            style: TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: Paleta.beige.withOpacity(0.9)),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaAncha(double ancho) {
    const alto = 580.0;
    final anchoPanel = ancho * 0.55;
    final anchoForm = ancho * 0.45;
    const dur = Duration(milliseconds: 650);
    const curva = Curves.easeInOutCubic;

    return SizedBox(
      width: ancho,
      height: alto,
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: dur,
            curve: curva,
            top: 0,
            bottom: 0,
            left: _isLogin ? 0 : ancho - anchoForm,
            width: anchoForm,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: SingleChildScrollView(
                  key: ValueKey(_isLogin),
                  child: SizedBox(height: alto - 48, child: _formulario()),
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: dur,
            curve: curva,
            top: 0,
            bottom: 0,
            left: _isLogin ? ancho - anchoPanel : 0,
            width: anchoPanel,
            child: ClipPath(
              clipper: DiagonalClipper(!_isLogin),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Paleta.bordo.withOpacity(0.55),
                      Paleta.bordoOscuro.withOpacity(0.85),
                    ],
                  ),
                ),
                child: Align(
                  alignment:
                      _isLogin ? Alignment.centerRight : Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: 0.78,
                    child: _mensajeBienvenida(compacto: false),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tarjetaAngosta() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              Paleta.bordo.withOpacity(0.55),
              Paleta.bordoOscuro.withOpacity(0.85),
            ]),
          ),
          child: _mensajeBienvenida(compacto: true),
        ),
        Padding(
          padding: const EdgeInsets.all(26),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: _formulario(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Paleta.negroVino,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.9, 1.0),
                  radius: 1.4,
                  colors: [Color(0xFF4A121A), Paleta.bordoOscuro, Paleta.negroVino],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulso,
              builder: (_, __) =>
                  CustomPaint(painter: CircuitoPainter(_pulso.value)),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: LayoutBuilder(
                  builder: (context, c) {
                    final ancho = math.min(c.maxWidth, 860.0);
                    final esAncha = ancho > 640;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'MISIFU',
                          style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 8,
                              color: Paleta.hueso),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Jujuy · Rescate y adopción',
                          style: TextStyle(
                              fontSize: 12,
                              letterSpacing: 2,
                              color: Paleta.beige.withOpacity(0.7)),
                        ),
                        const SizedBox(height: 22),
                        Container(
                          width: ancho,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(26),
                            border:
                                Border.all(color: Paleta.beige.withOpacity(0.18)),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.55),
                                  blurRadius: 40,
                                  offset: const Offset(0, 18)),
                              BoxShadow(
                                  color: Paleta.bordoClaro.withOpacity(0.18),
                                  blurRadius: 60),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(26),
                            child:
                                esAncha ? _tarjetaAncha(ancho) : _tarjetaAngosta(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────── TEMA DÍA / NOCHE ─────────────────────
final ValueNotifier<bool> modoNoche = ValueNotifier(false);

class Tema {
  static bool get n => modoNoche.value;
  static Color get texto => n ? Paleta.hueso : Paleta.bordo;
  static Color get textoSuave =>
      n ? Paleta.beige.withOpacity(0.8) : const Color(0xFF5B4A45);
  static Color get tenue =>
      n ? Paleta.beige.withOpacity(0.6) : const Color(0xFF8A7770);
  static Color get borde =>
      n ? Paleta.beige.withOpacity(0.16) : Paleta.bordo.withOpacity(0.14);
  static Color get campo => n ? Colors.white.withOpacity(0.07) : Colors.white;
}

PageRouteBuilder rutaAnimada(Widget pagina) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 900),
    pageBuilder: (_, __, ___) => pagina,
    transitionsBuilder: (context, anim, sec, child) {
      final c = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return AnimatedBuilder(
        animation: c,
        builder: (_, __) => Opacity(
          opacity: c.value.clamp(0.0, 1.0),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY((1 - c.value) * 0.7)
              ..scale(0.9 + 0.1 * c.value),
            child: child,
          ),
        ),
      );
    },
  );
}

// ───────────────────── UTILIDADES COMUNES ─────────────────────
void aviso(BuildContext context, String msg, {Color color = Paleta.bordo}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

InputDecoration decoCampo(String label, IconData icono) {
  return InputDecoration(
    hintText: label,
    hintStyle: TextStyle(color: Tema.tenue, fontSize: 14),
    prefixIcon: Icon(icono, color: Tema.textoSuave, size: 20),
    filled: true,
    fillColor: Tema.campo,
    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: Tema.borde),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Paleta.bordoClaro, width: 1.6),
    ),
  );
}

BoxDecoration vidrioDeco({double radio = 22, double inclX = 0, double inclY = 0}) {
  final n = Tema.n;
  return BoxDecoration(
    borderRadius: BorderRadius.circular(radio),
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: n
          ? [Paleta.bordo.withOpacity(0.38), Paleta.bordoOscuro.withOpacity(0.78)]
          : const [Colors.white, Color(0xFFF3EBE1)],
    ),
    border: Border.all(color: Tema.borde),
    boxShadow: n
        ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 22,
              offset: Offset(-inclY * 80, 12 + inclX * 80),
            ),
            BoxShadow(color: Paleta.bordoClaro.withOpacity(0.10), blurRadius: 30),
          ]
        : [
            BoxShadow(
              color: Paleta.bordo.withOpacity(0.16),
              blurRadius: 20,
              offset: Offset(-inclY * 80, 10 + inclX * 80),
            ),
          ],
  );
}

Widget fotoCentrada(String url, {double alto = 160, Uint8List? bytes}) {
  if (bytes != null) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.memory(bytes, height: alto, fit: BoxFit.contain),
      ),
    );
  }
  return Center(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Image.network(
        url,
        height: alto,
        fit: BoxFit.contain,
        loadingBuilder: (c, child, prog) {
          if (prog == null) return child;
          return SizedBox(
            height: alto,
            width: alto,
            child: const Center(
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Paleta.bordoClaro),
            ),
          );
        },
        errorBuilder: (_, __, ___) => Container(
          height: alto,
          width: alto,
          color: Paleta.bordo.withOpacity(0.25),
          child: const Icon(Icons.pets, color: Paleta.bordoClaro, size: 40),
        ),
      ),
    ),
  );
}

Widget tituloPanel(IconData ic, String titulo, String subtitulo) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
                colors: [Paleta.bordoClaro, Paleta.bordo]),
            boxShadow: [
              BoxShadow(color: Paleta.bordoClaro.withOpacity(0.45), blurRadius: 12)
            ],
          ),
          child: Icon(ic, color: Paleta.hueso, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo,
                  style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: Tema.texto)),
              const SizedBox(height: 2),
              Text(subtitulo,
                  style: TextStyle(fontSize: 12.5, height: 1.3, color: Tema.textoSuave)),
            ],
          ),
        ),
      ],
    ),
  );
}

// ───────────────────── FONDO ANIMADO ─────────────────────
class FondoAnimado extends StatefulWidget {
  const FondoAnimado({super.key});
  @override
  State<FondoAnimado> createState() => _FondoAnimadoState();
}

class _FondoAnimadoState extends State<FondoAnimado>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = Tema.n;
    return Stack(children: [
      Positioned.fill(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.9, 1.0),
              radius: 1.5,
              colors: n
                  ? const [Color(0xFF4A121A), Paleta.bordoOscuro, Paleta.negroVino]
                  : const [Color(0xFFEBD8CE), Paleta.hueso, Color(0xFFF3EBDF)],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        ),
      ),
      Positioned.fill(
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) =>
              CustomPaint(painter: CircuitoPainter(_c.value, claro: !n)),
        ),
      ),
    ]);
  }
}

// ───────────────────── BOTÓN BORDO ─────────────────────
class BotonBordo extends StatefulWidget {
  final String texto;
  final IconData? icono;
  final VoidCallback onTap;
  final bool compacto;
  final bool vidrio;
  const BotonBordo({
    super.key,
    required this.texto,
    required this.onTap,
    this.icono,
    this.compacto = false,
    this.vidrio = false,
  });
  @override
  State<BotonBordo> createState() => _BotonBordoState();
}

class _BotonBordoState extends State<BotonBordo> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final v = widget.vidrio;
    final colorTexto = v ? Tema.texto : Paleta.hueso;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
              horizontal: widget.compacto ? 16 : 26,
              vertical: widget.compacto ? 10 : 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: v
                ? null
                : const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Paleta.bordoClaro, Paleta.bordo],
                  ),
            color: v ? Tema.campo : null,
            border: Border.all(
                color: v
                    ? (Tema.n
                        ? Paleta.beige.withOpacity(0.3)
                        : Paleta.bordo.withOpacity(0.35))
                    : Colors.white.withOpacity(0.18)),
            boxShadow: v
                ? []
                : [
                    BoxShadow(
                      color: Paleta.bordoClaro.withOpacity(_down ? 0.2 : 0.5),
                      blurRadius: _down ? 8 : 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icono != null) ...[
                Icon(widget.icono, size: 16, color: colorTexto),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(widget.texto,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: colorTexto,
                        fontWeight: FontWeight.bold,
                        fontSize: widget.compacto ? 13 : 15)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────── TARJETA 3D ─────────────────────
class Tarjeta3D extends StatefulWidget {
  final Widget child;
  final EdgeInsets margin;
  const Tarjeta3D({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
  });
  @override
  State<Tarjeta3D> createState() => _Tarjeta3DState();
}

class _Tarjeta3DState extends State<Tarjeta3D> {
  double _rx = 0, _ry = 0;

  void _mover(Offset p) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final s = box.size;
    final dx = (p.dx / s.width - 0.5) * 2;
    final dy = (p.dy / s.height - 0.5) * 2;
    setState(() {
      _ry = (dx * 0.05).clamp(-0.05, 0.05);
      _rx = (-dy * 0.05).clamp(-0.05, 0.05);
    });
  }

  void _reset() => setState(() {
        _rx = 0;
        _ry = 0;
      });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (e) => _mover(e.localPosition),
      onExit: (_) => _reset(),
      child: Listener(
        onPointerDown: (e) => _mover(e.localPosition),
        onPointerMove: (e) => _mover(e.localPosition),
        onPointerUp: (_) => _reset(),
        onPointerCancel: (_) => _reset(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          margin: widget.margin,
          clipBehavior: Clip.antiAlias,
          transformAlignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_rx)
            ..rotateY(_ry),
          decoration: vidrioDeco(inclX: _rx, inclY: _ry),
          child: widget.child,
        ),
      ),
    );
  }
}

// ───────────────────── ENTRADA ESCALONADA ─────────────────────
class Aparece extends StatefulWidget {
  final int indice;
  final Widget child;
  const Aparece({super.key, required this.indice, required this.child});
  @override
  State<Aparece> createState() => _ApareceState();
}

class _ApareceState extends State<Aparece> {
  bool _v = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 60 + widget.indice * 90), () {
      if (mounted) setState(() => _v = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _v ? 1 : 0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _v ? Offset.zero : const Offset(0, 0.15),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

// ───────────────────── CHIP DE FILTRO ─────────────────────
class ChipFiltro extends StatelessWidget {
  final String label;
  final bool seleccionado;
  final VoidCallback onTap;
  const ChipFiltro(
      {super.key,
      required this.label,
      required this.seleccionado,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: seleccionado
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Paleta.bordoClaro, Paleta.bordo])
              : null,
          color: seleccionado ? null : Tema.campo,
          border: Border.all(
              color: seleccionado ? Colors.white.withOpacity(0.2) : Tema.borde),
          boxShadow: seleccionado
              ? [
                  BoxShadow(
                      color: Paleta.bordoClaro.withOpacity(0.5),
                      blurRadius: 14,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: Text(label,
            style: TextStyle(
                color: seleccionado ? Paleta.hueso : Tema.texto,
                fontWeight: FontWeight.w700,
                fontSize: 13)),
      ),
    );
  }
}

Widget buscador(ValueChanged<String> onChanged) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
    child: TextField(
      onChanged: onChanged,
      cursorColor: Paleta.bordoClaro,
      style: TextStyle(color: Tema.texto),
      decoration: decoCampo('Buscar por nombre, zona o descripción', Icons.search),
    ),
  );
}

class InterruptorTema extends StatelessWidget {
  const InterruptorTema({super.key});
  @override
  Widget build(BuildContext context) {
    final n = Tema.n;
    return GestureDetector(
      onTap: () => modoNoche.value = !modoNoche.value,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        width: 62,
        height: 34,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            colors: n
                ? const [Paleta.bordoOscuro, Paleta.bordo]
                : const [Paleta.beige, Color(0xFFF3C9B8)],
          ),
          border: Border.all(color: Tema.borde),
          boxShadow: [
            BoxShadow(
                color: Paleta.bordoClaro.withOpacity(n ? 0.4 : 0.2), blurRadius: 10)
          ],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          alignment: n ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Paleta.hueso,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (c, a) =>
                  RotationTransition(turns: a, child: ScaleTransition(scale: a, child: c)),
              child: Icon(
                n ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                key: ValueKey(n),
                size: 17,
                color: Paleta.bordo,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────── SESIÓN, MODELOS Y DATOS ─────────────────────
class Sesion {
  static String nombre = 'Invitado';
  static String edad = '';
  static String dni = '';
  static String email = '';
  static bool aceptoTerminos = false;

  static String get dniOculto =>
      dni.length < 4 ? '••••' : '••••${dni.substring(dni.length - 3)}';
  static String get primerNombre => nombre.split(' ').first;
}

String _dos(int n) => n.toString().padLeft(2, '0');
String fmtFecha(DateTime d) =>
    '${_dos(d.day)}/${_dos(d.month)}/${d.year} · ${_dos(d.hour)}:${_dos(d.minute)} hs';
String hace(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return 'ahora';
  if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'hace ${diff.inHours} h';
  return 'hace ${diff.inDays} d';
}

final RegExp _prohibido = RegExp(
    r'(\$|cbu|alias|precio|pesos|vendo|venta|\b\d{7,}\b)',
    caseSensitive: false);
bool textoProhibido(String t) => _prohibido.hasMatch(t);
const String kMsgProhibido =
    'No se permiten precios, ventas, datos bancarios ni teléfonos. Usá el chat interno.';

const List<String> kBarrios = [
  'Centro',
  'Alto Comedero',
  'Los Perales',
  'Gorriti',
  'Ciudad de Nieva',
  'Mariano Moreno',
];
const List<String> kTamanos = ['Pequeño', 'Mediano', 'Grande'];

void refrescar<T>(ValueNotifier<List<T>> n) => n.value = List.of(n.value);

class Comentario {
  final String autor, texto;
  final DateTime hora;
  Comentario(this.autor, this.texto, this.hora);
}

class Perdida {
  final String id, nombre, tipo, etapa, tamano, barrio, desc, img, autor;
  final DateTime fecha;
  int estado;
  final List<Comentario> comentarios;
  Perdida({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.etapa,
    required this.tamano,
    required this.barrio,
    required this.desc,
    required this.img,
    required this.autor,
    required this.fecha,
    this.estado = 0,
    List<Comentario>? comentarios,
  }) : comentarios = comentarios ?? [];
}

class Avistamiento {
  final String id, autor, ubicacion, barrio, enlaceMapa, tipo, etapa, tamano;
  final String color, condicion, dondeEsta, descripcion, img;
  final bool collar;
  final DateTime fecha;
  final Uint8List? bytes;
  int confirmaciones;
  bool eliminado;
  final List<Comentario> comentarios;
  Avistamiento({
    required this.id,
    required this.autor,
    required this.ubicacion,
    required this.barrio,
    this.enlaceMapa = '',
    required this.tipo,
    this.etapa = 'Adulto',
    required this.tamano,
    required this.color,
    required this.condicion,
    required this.dondeEsta,
    required this.descripcion,
    this.img = '',
    this.collar = false,
    required this.fecha,
    this.bytes,
    this.confirmaciones = 0,
    this.eliminado = false,
    List<Comentario>? comentarios,
  }) : comentarios = comentarios ?? [];
}

class Adopcion {
  final String id, nombre, tipo, etapa, edad, sexo, tamano, barrio;
  final String descripcion, personalidad, condiciones, img, autor;
  final bool vacunado, castrado, verificado;
  final DateTime fecha;
  final Uint8List? bytes;
  bool eliminado;
  final List<Comentario> comentarios;
  Adopcion({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.etapa,
    required this.edad,
    required this.sexo,
    required this.tamano,
    required this.barrio,
    required this.descripcion,
    required this.personalidad,
    required this.condiciones,
    this.img = '',
    required this.autor,
    this.vacunado = true,
    this.castrado = true,
    this.verificado = false,
    required this.fecha,
    this.bytes,
    this.eliminado = false,
    List<Comentario>? comentarios,
  }) : comentarios = comentarios ?? [];
}

class Reencuentro {
  final String id, nombre, tipo, barrio, desc, img, autor, tipoExito;
  final DateTime fecha;
  final List<Comentario> comentarios;
  Reencuentro({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.barrio,
    required this.desc,
    required this.img,
    required this.autor,
    required this.tipoExito,
    required this.fecha,
    List<Comentario>? comentarios,
  }) : comentarios = comentarios ?? [];
}

class Refugio {
  final String nombre, tipo, barrio, direccion, horarios, descripcion;
  final double meta;
  final List<Adopcion> mascotas;
  Refugio({
    required this.nombre,
    required this.tipo,
    required this.barrio,
    required this.direccion,
    required this.horarios,
    required this.descripcion,
    required this.meta,
    required this.mascotas,
  });
}

const _u = 'https://images.unsplash.com/photo-';
const _q = '?auto=format&fit=crop&w=600&q=80';
const _imgPerro1 = '${_u}1543466835-00a7907e9de1$_q';
const _imgGato1 = '${_u}1514888286974-6c03e2ca1dba$_q';
const _imgPerro2 = '${_u}1583511655857-d19b40a7a54e$_q';
const _imgPerro3 = '${_u}1587300003388-59208cc962cb$_q';
const _imgGato2 = '${_u}1573865526739-10659fec78a5$_q';
const _imgPerro4 = '${_u}1518717758536-85ae29035b6d$_q';
const _imgGato3 = '${_u}1495360010541-f48722b34f7d$_q';

DateTime _atras({int d = 0, int h = 0, int m = 0}) =>
    DateTime.now().subtract(Duration(days: d, hours: h, minutes: m));

final ValueNotifier<List<Perdida>> perdidas = ValueNotifier([
  Perdida(
    id: 'p1',
    nombre: 'Toby',
    tipo: 'Perro',
    etapa: 'Adulto',
    tamano: 'Mediano',
    barrio: 'Los Perales',
    desc: 'Mestizo marrón con collar rojo. Responde a su nombre.',
    img: _imgPerro1,
    autor: 'Ana M.',
    fecha: _atras(d: 2),
    estado: 0,
    comentarios: [
      Comentario('Jorge L.', 'Creo haberlo visto cerca de la escuela del barrio.',
          _atras(d: 1, h: 3)),
    ],
  ),
  Perdida(
    id: 'p2',
    nombre: 'Michi',
    tipo: 'Gato',
    etapa: 'Adulto',
    tamano: 'Pequeño',
    barrio: 'Centro',
    desc: 'Gato naranja, muy dócil. Se perdió cerca de la plaza.',
    img: _imgGato1,
    autor: 'Valeria S.',
    fecha: _atras(h: 5),
    estado: 1,
  ),
  Perdida(
    id: 'p3',
    nombre: 'Rex',
    tipo: 'Perro',
    etapa: 'Adulto',
    tamano: 'Grande',
    barrio: 'Alto Comedero',
    desc: 'Pastor mezcla, 3 años. Tiene una mancha blanca en el pecho.',
    img: _imgPerro2,
    autor: 'Marcos T.',
    fecha: _atras(d: 1),
    estado: 2,
  ),
]);

final ValueNotifier<List<Reencuentro>> reencuentros = ValueNotifier([
  Reencuentro(
    id: 'r1',
    nombre: 'Bruno',
    tipo: 'Perro',
    barrio: 'Gorriti',
    tipoExito: '¡Reencontrado!',
    desc: '¡Bruno ya volvió a casa! Gracias al aviso en la sección "Lo Vi", su familia pudo dar con él rápidamente.',
    img: _imgPerro4,
    autor: 'Sofía R.',
    fecha: _atras(d: 4),
  ),
  Reencuentro(
    id: 'r2',
    nombre: 'Pelusa',
    tipo: 'Gato',
    barrio: 'Ciudad de Nieva',
    tipoExito: '¡Adoptado!',
    desc: 'Pelusa encontró una familia amorosa a través de las adopciones responsables de MISIFU.',
    img: _imgGato3,
    autor: 'Hogar Peludos de los Andes',
    fecha: _atras(d: 8),
  ),
]);

final ValueNotifier<List<Avistamiento>> avistamientos = ValueNotifier([
  Avistamiento(
    id: 'a1',
    autor: 'Lucía F.',
    ubicacion: 'Av. Fascio y Alvear',
    barrio: 'Centro',
    enlaceMapa: '-24.1858, -65.2995',
    tipo: 'Perro',
    tamano: 'Mediano',
    color: 'Negro con collar azul',
    condicion: 'Asustado',
    dondeEsta: 'Sigue en la calle',
    collar: true,
    descripcion: 'Perrito negro con collar azul, asustado cerca de la plaza.',
    img: _imgPerro1,
    fecha: _atras(h: 2),
    confirmaciones: 2,
  ),
  Avistamiento(
    id: 'a2',
    autor: 'Santiago P.',
    ubicacion: 'Plaza de Los Perales',
    barrio: 'Los Perales',
    tipo: 'Gato',
    etapa: 'Cachorro',
    tamano: 'Pequeño',
    color: 'Gris atigrado',
    condicion: 'Desnutrido / débil',
    dondeEsta: 'Lo tengo conmigo',
    collar: false,
    descripcion: 'Gatito muy flaquito, lo resguardé hasta encontrar a su dueño.',
    img: _imgGato2,
    fecha: _atras(h: 6),
    confirmaciones: 1,
  ),
]);

final ValueNotifier<List<Adopcion>> adopciones = ValueNotifier([
  Adopcion(
    id: 'd1',
    nombre: 'Negrito',
    tipo: 'Perro',
    etapa: 'Cachorro',
    edad: '1 año',
    sexo: 'Macho',
    tamano: 'Mediano',
    barrio: 'Alto Comedero',
    descripcion: 'Lleno de energía. Lo rescaté de la calle y busca familia.',
    personalidad: 'Juguetón y activo',
    condiciones: 'Patio o salidas diarias. Seguimiento por chat.',
    img: _imgPerro1,
    autor: 'María G.',
    vacunado: true,
    castrado: false,
    fecha: _atras(d: 1),
  ),
  Adopcion(
    id: 'd2',
    nombre: 'Luna',
    tipo: 'Gato',
    etapa: 'Adulto',
    edad: '2 años',
    sexo: 'Hembra',
    tamano: 'Pequeño',
    barrio: 'Centro',
    descripcion: 'Cariñosa y silenciosa. Perfecta para departamento.',
    personalidad: 'Tranquila y mimosa',
    condiciones: 'Hogar sin otros gatos. Entrevista previa por chat.',
    img: _imgGato1,
    autor: 'Carlos R.',
    vacunado: true,
    castrado: true,
    fecha: _atras(d: 2),
  ),
]);

Adopcion _masc(String id, String nombre, String tipo, String etapa, String edad,
    String sexo, String tamano, String barrio, String pers, String cond,
    String img, String refugio,
    {bool vac = true, bool cast = true}) {
  return Adopcion(
    id: id,
    nombre: nombre,
    tipo: tipo,
    etapa: etapa,
    edad: edad,
    sexo: sexo,
    tamano: tamano,
    barrio: barrio,
    descripcion: '$nombre espera una familia que le dé una segunda oportunidad.',
    personalidad: pers,
    condiciones: cond,
    img: img,
    autor: refugio,
    vacunado: vac,
    castrado: cast,
    verificado: true,
    fecha: _atras(d: 3),
  );
}

final List<Refugio> kRefugios = [
  Refugio(
    nombre: 'Refugio Narices Frías Jujuy',
    tipo: 'ONG',
    barrio: 'Alto Comedero',
    direccion: 'Alto Comedero, San Salvador de Jujuy',
    horarios: 'Lun a Sáb · 9:00 a 17:00 hs',
    descripcion: 'Rescatamos y damos en adopción perros y gatos abandonados.',
    meta: 0.65,
    mascotas: [
      _masc('r1a', 'Toto', 'Perro', 'Adulto', '4 años', 'Macho', 'Mediano',
          'Alto Comedero', 'Noble y tranquilo', 'Adopción con entrevista',
          _imgPerro3, 'Refugio Narices Frías Jujuy'),
      _masc('r1b', 'Mía', 'Gato', 'Adulto', '2 años', 'Hembra', 'Pequeño',
          'Alto Comedero', 'Curiosa y cariñosa', 'Hogar con ventanas protegidas',
          _imgGato3, 'Refugio Narices Frías Jujuy'),
    ],
  ),
  Refugio(
    nombre: 'Huellitas del Norte',
    tipo: 'Veterinaria',
    barrio: 'Centro',
    direccion: 'Centro, San Salvador de Jujuy',
    horarios: 'Lun a Vie · 8:30 a 19:00 hs',
    descripcion: 'Veterinaria adherida. Punto de intercambio seguro.',
    meta: 0.4,
    mascotas: [
      _masc('r2a', 'Canela', 'Perro', 'Cachorro', '6 meses', 'Hembra', 'Pequeño',
          'Centro', 'Juguetona', 'Se entrega vacunada y desparasitada',
          _imgPerro4, 'Huellitas del Norte', cast: false),
    ],
  ),
];

// ───────────────────── FILTRO TRANSVERSAL ─────────────────────
class Filtro {
  String tipo = 'Todos';
  String barrio = 'Todos';
  String tamano = 'Todos';
  String texto = '';

  bool pasa({
    required String tipoItem,
    required String etapa,
    required String tam,
    required String bar,
    required String txt,
  }) {
    if (tipo == 'Cachorro') {
      if (etapa != 'Cachorro') return false;
    } else if (tipo != 'Todos' && tipoItem != tipo) {
      return false;
    }
    if (barrio != 'Todos' && bar != barrio) return false;
    if (tamano != 'Todos' && tam != tamano) return false;
    if (texto.isNotEmpty && !txt.toLowerCase().contains(texto.toLowerCase())) {
      return false;
    }
    return true;
  }
}

class BarraFiltros extends StatelessWidget {
  final Filtro filtro;
  final VoidCallback alCambiar;
  const BarraFiltros({super.key, required this.filtro, required this.alCambiar});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          for (final t in ['Todos', 'Gato', 'Perro', 'Cachorro'])
            ChipFiltro(
              label: t,
              seleccionado: filtro.tipo == t,
              onTap: () {
                filtro.tipo = t;
                alCambiar();
              },
            ),
          ChipFiltro(
            label: filtro.barrio == 'Todos' ? 'Barrio ▾' : '${filtro.barrio} ▾',
            seleccionado: filtro.barrio != 'Todos',
            onTap: () async {
              final r = await elegirOpcion(
                  context, 'Elegí un barrio', ['Todos', ...kBarrios], filtro.barrio);
              if (r != null) {
                filtro.barrio = r;
                alCambiar();
              }
            },
          ),
          ChipFiltro(
            label: filtro.tamano == 'Todos' ? 'Tamaño ▾' : '${filtro.tamano} ▾',
            seleccionado: filtro.tamano != 'Todos',
            onTap: () async {
              final r = await elegirOpcion(
                  context, 'Elegí un tamaño', ['Todos', ...kTamanos], filtro.tamano);
              if (r != null) {
                filtro.tamano = r;
                alCambiar();
              }
            },
          ),
        ],
      ),
    );
  }
}

// ───────────────────── WIDGETS AUXILIARES ─────────────────────
const RoundedRectangleBorder kFormaHoja = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(28)));
Color fondoHoja() => Tema.n ? Paleta.bordoOscuro : Paleta.hueso;

Widget manija() => Center(
      child: Container(
        width: 44,
        height: 4,
        decoration: BoxDecoration(
            color: Tema.tenue, borderRadius: BorderRadius.circular(4)),
      ),
    );

Future<String?> elegirOpcion(
    BuildContext context, String titulo, List<String> opciones, String actual) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: fondoHoja(),
    shape: kFormaHoja,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            manija(),
            const SizedBox(height: 14),
            Text(titulo,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800, color: Tema.texto)),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final o in opciones)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(o,
                          style: TextStyle(
                              color: Tema.texto,
                              fontWeight:
                                  o == actual ? FontWeight.w800 : FontWeight.w500)),
                      trailing: o == actual
                          ? const Icon(Icons.check, color: Paleta.bordoClaro)
                          : null,
                      onTap: () => Navigator.pop(ctx, o),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget avatar(String nombre, {double r = 18}) {
  return Container(
    width: r * 2,
    height: r * 2,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const LinearGradient(colors: [Paleta.bordoClaro, Paleta.bordo]),
      boxShadow: [
        BoxShadow(color: Paleta.bordoClaro.withOpacity(0.4), blurRadius: 10)
      ],
    ),
    child: Text(nombre.isEmpty ? '?' : nombre[0].toUpperCase(),
        style: TextStyle(
            color: Paleta.hueso, fontWeight: FontWeight.w900, fontSize: r * 0.9)),
  );
}

Widget chipInfo(String t, {IconData? ic, bool fuerte = false}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: fuerte
          ? const LinearGradient(colors: [Paleta.bordoClaro, Paleta.bordo])
          : null,
      color: fuerte ? null : Tema.campo,
      border: Border.all(
          color: fuerte ? Colors.white.withOpacity(0.2) : Tema.borde),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (ic != null) ...[
          Icon(ic, size: 12, color: fuerte ? Paleta.hueso : Tema.textoSuave),
          const SizedBox(width: 4),
        ],
        Text(t,
            style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: fuerte ? Paleta.hueso : Tema.texto)),
      ],
    ),
  );
}

Widget insigniaVerificado() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.green.shade700,
      borderRadius: BorderRadius.circular(20),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.verified, size: 12, color: Colors.white),
        SizedBox(width: 3),
        Text('Verificado',
            style: TextStyle(
                color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

Widget filaDato(IconData ic, String etiqueta, String valor) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(ic, size: 15, color: Paleta.bordoClaro),
        const SizedBox(width: 6),
        Text('$etiqueta: ',
            style: TextStyle(
                fontSize: 12.5, fontWeight: FontWeight.w700, color: Tema.textoSuave)),
        Expanded(
          child: Text(valor,
              style: TextStyle(fontSize: 12.5, color: Tema.texto, height: 1.25)),
        ),
      ],
    ),
  );
}

Widget selectorChips(String titulo, List<String> opciones, String valor,
    ValueChanged<String> alCambiar) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(titulo,
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w800, color: Tema.texto)),
      const SizedBox(height: 6),
      Wrap(
        runSpacing: 8,
        children: [
          for (final o in opciones)
            ChipFiltro(
                label: o, seleccionado: o == valor, onTap: () => alCambiar(o)),
        ],
      ),
      const SizedBox(height: 12),
    ],
  );
}

Widget switchFila(String texto, bool valor, ValueChanged<bool> alCambiar) {
  return Row(
    children: [
      Expanded(
        child: Text(texto,
            style: TextStyle(fontSize: 13, color: Tema.texto, fontWeight: FontWeight.w600)),
      ),
      Switch(
        value: valor,
        onChanged: alCambiar,
        thumbColor: WidgetStateProperty.all(Paleta.hueso),
        trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? Paleta.bordoClaro : Tema.tenue),
      ),
    ],
  );
}

Widget barraEstado(int estado) {
  const pasos = ['Perdido', 'Encontré', 'Resguardo', 'Finalizado'];
  return Column(
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: (estado + 1) / 4,
          minHeight: 6,
          backgroundColor: Paleta.bordo.withOpacity(0.12),
          valueColor: const AlwaysStoppedAnimation(Paleta.bordoClaro),
        ),
      ),
      const SizedBox(height: 6),
      Row(
        children: [
          for (int i = 0; i < 4; i++)
            Expanded(
              child: Text(pasos[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: i == estado ? FontWeight.w900 : FontWeight.w500,
                      color: i <= estado ? Tema.texto : Tema.tenue)),
            ),
        ],
      ),
    ],
  );
}

Widget imagenMascota(String url, Uint8List? bytes) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: bytes != null
        ? Image.memory(bytes, fit: BoxFit.contain)
        : Image.network(
            url,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              width: 160,
              height: 160,
              color: Paleta.bordo.withOpacity(0.25),
              child: const Icon(Icons.pets, color: Paleta.bordoClaro, size: 40),
            ),
          ),
  );
}

void dialogoInfo(BuildContext context, String titulo, Widget contenido) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: fondoHoja(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Text(titulo,
          style: TextStyle(color: Tema.texto, fontWeight: FontWeight.w800)),
      content: SingleChildScrollView(child: contenido),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cerrar',
              style: TextStyle(color: Paleta.bordoClaro, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}

const String kAlertaSeguridad =
    'Por tu seguridad: Nunca vayas a encuentros a solas, utiliza puntos públicos, no pases tu número personal y jamás transfieras dinero por adelantado.';

// ───────────────────── CHAT INTERNO ─────────────────────
class Mensaje {
  final String autor, texto;
  final DateTime hora;
  final bool mio, oculto;
  Mensaje(this.autor, this.texto, this.hora, {this.mio = false, this.oculto = false});
}

final Map<String, List<Mensaje>> chats = {};

void abrirChat(BuildContext context,
    {required String clave, required String con, required String asunto}) {
  if (con == Sesion.nombre) {
    aviso(context, 'Esta publicación es tuya.');
    return;
  }
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (_) => ChatScreen(clave: clave, con: con, asunto: asunto)),
  );
}

class ChatScreen extends StatefulWidget {
  final String clave, con, asunto;
  const ChatScreen(
      {super.key, required this.clave, required this.con, required this.asunto});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _c = TextEditingController();
  final _scroll = ScrollController();

  List<Mensaje> get _msgs => chats.putIfAbsent(
      widget.clave,
      () => [
            Mensaje(widget.con, '¡Hola! Gracias por escribirme. ¿En qué te puedo ayudar?',
                DateTime.now())
          ]);

  @override
  void dispose() {
    _c.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _bajar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  void _enviar() {
    final t = _c.text.trim();
    if (t.isEmpty) return;
    final malo = textoProhibido(t);
    setState(() => _msgs
        .add(Mensaje(Sesion.nombre, t, DateTime.now(), mio: true, oculto: malo)));
    _c.clear();
    _bajar();
    if (malo) {
      aviso(context,
          'Mensaje ocultado: $kMsgProhibido Se notificó al administrador.',
          color: Colors.red.shade800);
    } else {
      Future.delayed(const Duration(milliseconds: 1300), () {
        if (!mounted) return;
        setState(() => _msgs.add(Mensaje(
            widget.con,
            'Gracias por tu mensaje, te respondo en cuanto pueda. Coordinemos en un lugar público. 🐾',
            DateTime.now())));
        _bajar();
      });
    }
  }

  Widget _burbuja(Mensaje m) {
    final texto = m.oculto
        ? '🔒 Mensaje oculto por seguridad (en revisión del administrador)'
        : m.texto;
    return Align(
      alignment: m.mio ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          gradient: m.mio
              ? const LinearGradient(colors: [Paleta.bordoClaro, Paleta.bordo])
              : null,
          color: m.mio ? null : (Tema.n ? Colors.white.withOpacity(0.08) : Colors.white),
          border: m.mio ? null : Border.all(color: Tema.borde),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(m.mio ? 18 : 4),
            bottomRight: Radius.circular(m.mio ? 4 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(texto,
                style: TextStyle(
                    fontSize: 14,
                    fontStyle: m.oculto ? FontStyle.italic : FontStyle.normal,
                    color: m.mio ? Paleta.hueso : Tema.texto)),
            const SizedBox(height: 3),
            Text('${_dos(m.hora.hour)}:${_dos(m.hora.minute)}',
                style: TextStyle(
                    fontSize: 10,
                    color: m.mio ? Paleta.hueso.withOpacity(0.7) : Tema.tenue)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: modoNoche,
      builder: (context, noche, _) {
        final msgs = _msgs;
        return Scaffold(
          backgroundColor: noche ? Paleta.negroVino : Paleta.hueso,
          body: Stack(
            children: [
              Positioned.fill(child: FondoAnimado()),
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(6, 6, 16, 6),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios_new, color: Tema.texto, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                          avatar(widget.con, r: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(widget.con,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Tema.texto)),
                                Text(widget.asunto,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 12, color: Tema.textoSuave)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 14),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Paleta.bordo.withOpacity(Tema.n ? 0.35 : 0.10),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Paleta.bordoClaro.withOpacity(0.4)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: Paleta.bordoClaro, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(kAlertaSeguridad,
                                style: TextStyle(
                                    fontSize: 11.5, height: 1.3, color: Tema.texto)),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        controller: _scroll,
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                        children: [for (final m in msgs) _burbuja(m)],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _c,
                              onSubmitted: (_) => _enviar(),
                              cursorColor: Paleta.bordoClaro,
                              style: TextStyle(color: Tema.texto),
                              decoration: decoCampo('Escribí un mensaje', Icons.chat_bubble_outline),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: _enviar,
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Paleta.bordoClaro, Paleta.bordo]),
                                boxShadow: [
                                  BoxShadow(
                                      color: Paleta.bordoClaro.withOpacity(0.5),
                                      blurRadius: 14)
                                ],
                              ),
                              child: const Icon(Icons.send_rounded, color: Paleta.hueso),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ───────────────────── COMENTARIOS ─────────────────────
void abrirComentarios(BuildContext context,
    {required String titulo,
    required List<Comentario> lista,
    required VoidCallback alCambiar}) {
  final c = TextEditingController();
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: fondoHoja(),
    shape: kFormaHoja,
    builder: (ctx) => StatefulBuilder(builder: (ctx, setSt) {
      void enviar() {
        final t = c.text.trim();
        if (t.isEmpty) return;
        if (textoProhibido(t)) {
          aviso(ctx, kMsgProhibido, color: Colors.red.shade800);
          return;
        }
        lista.add(Comentario(Sesion.nombre, t, DateTime.now()));
        c.clear();
        setSt(() {});
        alCambiar();
      }

      return Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            manija(),
            const SizedBox(height: 14),
            Text('Comentarios',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, color: Tema.texto)),
            Text(titulo, style: TextStyle(fontSize: 12.5, color: Tema.textoSuave)),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: lista.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Text('Todavía no hay comentarios. ¡Sé el primero! 🐾',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Tema.tenue)),
                    )
                  : ListView(
                      shrinkWrap: true,
                      children: [
                        for (final x in lista)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                avatar(x.autor, r: 16),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${x.autor} · ${hace(x.hora)}',
                                          style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w700,
                                              color: Tema.textoSuave)),
                                      const SizedBox(height: 2),
                                      Text(x.texto,
                                          style: TextStyle(
                                              fontSize: 13.5, height: 1.3, color: Tema.texto)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: 8),
            Text('Para coordinar usá el chat interno: no compartas teléfonos ni precios.',
                style: TextStyle(fontSize: 11, color: Tema.tenue)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: c,
                    onSubmitted: (_) => enviar(),
                    cursorColor: Paleta.bordoClaro,
                    style: TextStyle(color: Tema.texto),
                    decoration: decoCampo('Escribí un comentario', Icons.chat_bubble_outline),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: enviar,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [Paleta.bordoClaro, Paleta.bordo]),
                    ),
                    child: const Icon(Icons.send_rounded, color: Paleta.hueso, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
          ],
        ),
      );
    }),
  );
}

// ───────────────────── FICHA DE ADOPCIÓN ─────────────────────
void mostrarFicha(BuildContext context, Adopcion a) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: fondoHoja(),
    shape: kFormaHoja,
    builder: (ctx) => ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.9),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            manija(),
            const SizedBox(height: 14),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: imagenMascota(a.img, a.bytes),
              ),
            ),
            const SizedBox(height: 14),
            Text('${a.nombre}, ${a.edad}',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w900, color: Tema.texto)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 6, children: [
              chipInfo(a.tipo, ic: Icons.pets),
              chipInfo(a.etapa),
              chipInfo(a.sexo),
              chipInfo('Tamaño ${a.tamano.toLowerCase()}'),
            ]),
            const SizedBox(height: 12),
            Text(a.descripcion,
                style: TextStyle(fontSize: 14, height: 1.4, color: Tema.textoSuave)),
            const SizedBox(height: 10),
            Text('FICHA TÉCNICA',
                style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w900,
                    color: Tema.tenue)),
            const SizedBox(height: 4),
            filaDato(Icons.vaccines, 'Vacunado', a.vacunado ? 'Sí' : 'No'),
            filaDato(Icons.medical_services_outlined, 'Castrado / esterilizado',
                a.castrado ? 'Sí' : 'No'),
            filaDato(Icons.favorite_border, 'Carácter', a.personalidad),
            filaDato(Icons.home_outlined, 'Condiciones de adopción', a.condiciones),
            filaDato(Icons.location_on_outlined, 'Zona', a.barrio),
            filaDato(Icons.schedule, 'Publicado', '${fmtFecha(a.fecha)} (${hace(a.fecha)})'),
            const SizedBox(height: 6),
            Row(
              children: [
                avatar(a.autor, r: 14),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(a.autor,
                      style: TextStyle(fontWeight: FontWeight.w800, color: Tema.texto)),
                ),
                const SizedBox(width: 8),
                if (a.verificado) insigniaVerificado(),
              ],
            ),
            const SizedBox(height: 16),
            BotonBordo(
              texto: 'Quiero adoptar · Chatear',
              icono: Icons.chat_bubble_outline,
              onTap: () {
                Navigator.pop(ctx);
                abrirChat(context,
                    clave: 'ad-${a.id}-${Sesion.nombre}',
                    con: a.autor,
                    asunto: 'Adopción de ${a.nombre}');
              },
            ),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(
                child: BotonBordo(
                  texto: 'Comentarios · ${a.comentarios.length}',
                  icono: Icons.forum_outlined,
                  vidrio: true,
                  compacto: true,
                  onTap: () => abrirComentarios(context,
                      titulo: a.nombre,
                      lista: a.comentarios,
                      alCambiar: () => refrescar(adopciones)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: BotonBordo(
                  texto: 'Compartir',
                  icono: Icons.share,
                  vidrio: true,
                  compacto: true,
                  onTap: () => aviso(context, 'Compartiendo a ${a.nombre} (simulación)'),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Text(
                'Por seguridad el contacto es solo por chat interno. Nunca transfieras dinero por adelantado.',
                style: TextStyle(fontSize: 11, color: Tema.tenue)),
          ],
        ),
      ),
    ),
  );
}

// ───────────────────── SUBIR FOTO ─────────────────────
Future<Uint8List?> _elegirFoto(BuildContext ctx, bool camara) async {
  try {
    if (camara) {
      final x = await ImagePicker()
          .pickImage(source: ImageSource.camera, imageQuality: 80, maxWidth: 1600);
      return x == null ? null : await x.readAsBytes();
    } else {
      final f = await FilePicker.pickFile(type: FileType.image);
      return f == null ? null : await f.readAsBytes();
    }
  } catch (e) {
    if (ctx.mounted) {
      aviso(
        ctx,
        camara
            ? 'No se pudo abrir la cámara. Revisá los permisos del dispositivo.'
            : 'No se pudo abrir el explorador de archivos.',
        color: Colors.red.shade800,
      );
    }
    return null;
  }
}

Widget _opcionGrande(IconData ic, String titulo, String sub, VoidCallback onTap) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Paleta.bordoClaro, Paleta.bordo],
          ),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
                color: Paleta.bordoClaro.withOpacity(0.5),
                blurRadius: 18,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ic, color: Paleta.hueso, size: 36),
            const SizedBox(height: 10),
            Text(titulo,
                style: const TextStyle(
                    color: Paleta.hueso, fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 4),
            Text(sub,
                textAlign: TextAlign.center,
                style: TextStyle(color: Paleta.hueso.withOpacity(0.8), fontSize: 11.5)),
          ],
        ),
      ),
    ),
  );
}

void elegirFotoYContinuar(BuildContext ctxPadre, void Function(Uint8List) alElegir) {
  showModalBottomSheet<void>(
    context: ctxPadre,
    backgroundColor: fondoHoja(),
    shape: kFormaHoja,
    builder: (sheetCtx) {
      Future<void> elegir(bool camara) async {
        Navigator.pop(sheetCtx);
        final bytes = await _elegirFoto(ctxPadre, camara);
        if (bytes != null && ctxPadre.mounted) alElegir(bytes);
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            manija(),
            const SizedBox(height: 18),
            Text('¿Cómo querés subir la foto?',
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, color: Tema.texto)),
            const SizedBox(height: 4),
            Text('Elegí una opción para continuar.',
                style: TextStyle(fontSize: 13, color: Tema.textoSuave)),
            const SizedBox(height: 20),
            Row(children: [
              _opcionGrande(Icons.camera_alt, 'Cámara', 'Sacá una foto ahora',
                  () => elegir(true)),
              const SizedBox(width: 14),
              _opcionGrande(Icons.folder_open, 'Archivos',
                  'Elegí una foto de tu dispositivo', () => elegir(false)),
            ]),
          ],
        ),
      );
    },
  );
}

void abrirMenuSubir(BuildContext ctx, {required void Function(int) irA}) {
  showModalBottomSheet<void>(
    context: ctx,
    backgroundColor: fondoHoja(),
    shape: kFormaHoja,
    builder: (s) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          manija(),
          const SizedBox(height: 18),
          Text('¿Qué querés publicar?',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, color: Tema.texto)),
          const SizedBox(height: 20),
          Row(children: [
            _opcionGrande(Icons.visibility, 'Lo vi', 'Vi un animal en la calle', () {
              Navigator.pop(s);
              abrirReporteAvistamiento(ctx, alPublicar: () => irA(1));
            }),
            const SizedBox(width: 14),
            _opcionGrande(Icons.volunteer_activism, 'Adopción', 'Dar un animal en adopción', () {
              Navigator.pop(s);
              abrirPublicarAdopcion(ctx, alPublicar: () => irA(2));
            }),
          ]),
        ],
      ),
    ),
  );
}

Widget _fotoConCambio(Uint8List foto, VoidCallback camara, VoidCallback archivo) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.memory(foto, height: 150, fit: BoxFit.contain),
        ),
      ),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(
          child: BotonBordo(
            texto: 'Otra con cámara',
            icono: Icons.camera_alt,
            vidrio: true,
            compacto: true,
            onTap: camara,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: BotonBordo(
            texto: 'Otro archivo',
            icono: Icons.folder_open,
            vidrio: true,
            compacto: true,
            onTap: archivo,
          ),
        ),
      ]),
      const SizedBox(height: 14),
    ],
  );
}

Widget _campoTexto(TextEditingController c, String hint, IconData ic,
    {int lineas = 1}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: c,
      maxLines: lineas,
      style: TextStyle(color: Tema.texto),
      cursorColor: Paleta.bordoClaro,
      decoration: decoCampo(hint, ic),
    ),
  );
}

// ───────────────────── FORMULARIO: LO VI ─────────────────────
void abrirReporteAvistamiento(BuildContext ctxPadre, {VoidCallback? alPublicar}) {
  elegirFotoYContinuar(
      ctxPadre, (b) => _formularioAvistamiento(ctxPadre, b, alPublicar));
}

void _formularioAvistamiento(
    BuildContext ctxPadre, Uint8List fotoInicial, VoidCallback? alPublicar) {
  final ubic = TextEditingController();
  final mapa = TextEditingController();
  final color = TextEditingController();
  final desc = TextEditingController();
  Uint8List foto = fotoInicial;
  String tipo = 'Perro', etapa = 'Adulto', tamano = 'Mediano';
  String condicion = 'Se lo ve bien', donde = 'Sigue en la calle', barrio = 'Centro';
  bool collar = false;

  showModalBottomSheet<void>(
    context: ctxPadre,
    isScrollControlled: true,
    backgroundColor: fondoHoja(),
    shape: kFormaHoja,
    builder: (ctx) => StatefulBuilder(builder: (ctx, setSt) {
      return Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 14),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.9),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                manija(),
                const SizedBox(height: 14),
                Text('Reportar avistamiento',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800, color: Tema.texto)),
                const SizedBox(height: 4),
                Text('Cuantos más datos des, más fácil será encontrar a su familia.',
                    style: TextStyle(fontSize: 12.5, color: Tema.textoSuave)),
                const SizedBox(height: 14),
                _fotoConCambio(
                  foto,
                  () async {
                    final b = await _elegirFoto(ctx, true);
                    if (b != null) setSt(() => foto = b);
                  },
                  () async {
                    final b = await _elegirFoto(ctx, false);
                    if (b != null) setSt(() => foto = b);
                  },
                ),
                selectorChips('¿Qué animal es?', ['Perro', 'Gato', 'Otro'], tipo,
                    (v) => setSt(() => tipo = v)),
                selectorChips('Edad aproximada', ['Cachorro', 'Adulto'], etapa,
                    (v) => setSt(() => etapa = v)),
                selectorChips('Tamaño', kTamanos, tamano, (v) => setSt(() => tamano = v)),
                _campoTexto(color, 'Color y señas particulares', Icons.palette_outlined),
                selectorChips(
                    'Estado en el que estaba',
                    ['Se lo ve bien', 'Asustado', 'Herido', 'Desnutrido / débil'],
                    condicion,
                    (v) => setSt(() => condicion = v)),
                switchFila('¿Tiene collar o chapita?', collar, (v) => setSt(() => collar = v)),
                const SizedBox(height: 6),
                selectorChips(
                    '¿Dónde está ahora?',
                    ['Sigue en la calle', 'Lo tengo conmigo', 'En veterinaria / refugio'],
                    donde,
                    (v) => setSt(() => donde = v)),
                selectorChips('Barrio', kBarrios, barrio, (v) => setSt(() => barrio = v)),
                _campoTexto(ubic, 'Ubicación exacta (esquina, referencia)',
                    Icons.location_on_outlined),
                _campoTexto(mapa, 'Coordenadas o enlace corto de Google Maps (opcional)',
                    Icons.map_outlined),
                _campoTexto(desc, 'Descripción de la situación', Icons.pets, lineas: 3),
                Text('Se registrará automáticamente la fecha y hora: ${fmtFecha(DateTime.now())}',
                    style: TextStyle(fontSize: 11.5, color: Tema.tenue)),
                const SizedBox(height: 14),
                BotonBordo(
                  texto: 'PUBLICAR AHORA',
                  onTap: () {
                    if (ubic.text.trim().isEmpty || desc.text.trim().isEmpty) {
                      aviso(ctx, 'Completá ubicación y descripción',
                          color: Colors.red.shade800);
                      return;
                    }
                    if (textoProhibido('${ubic.text} ${desc.text} ${color.text}')) {
                      aviso(ctx, kMsgProhibido, color: Colors.red.shade800);
                      return;
                    }
                    avistamientos.value = [
                      Avistamiento(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        autor: Sesion.nombre,
                        ubicacion: ubic.text.trim(),
                        barrio: barrio,
                        enlaceMapa: mapa.text.trim(),
                        tipo: tipo,
                        etapa: etapa,
                        tamano: tamano,
                        color: color.text.trim().isEmpty ? 'Sin especificar' : color.text.trim(),
                        condicion: condicion,
                        dondeEsta: donde,
                        collar: collar,
                        descripcion: desc.text.trim(),
                        fecha: DateTime.now(),
                        bytes: foto,
                      ),
                      ...avistamientos.value,
                    ];
                    Navigator.pop(ctx);
                    aviso(ctxPadre,
                        '¡Publicado! Se enviará una alerta zonal a los vecinos de $barrio.',
                        color: Colors.green.shade700);
                    alPublicar?.call();
                  },
                ),
                const SizedBox(height: 22),
              ],
            ),
          ),
        ),
      );
    }),
  );
}

// ───────────────────── FORMULARIO: PUBLICAR ADOPCIÓN ─────────────────────
void abrirPublicarAdopcion(BuildContext ctxPadre, {VoidCallback? alPublicar}) {
  elegirFotoYContinuar(ctxPadre, (b) => _formularioAdopcion(ctxPadre, b, alPublicar));
}

void _formularioAdopcion(
    BuildContext ctxPadre, Uint8List fotoInicial, VoidCallback? alPublicar) {
  final nombre = TextEditingController();
  final edad = TextEditingController();
  final pers = TextEditingController();
  final cond = TextEditingController();
  final desc = TextEditingController();
  Uint8List foto = fotoInicial;
  String tipo = 'Perro', etapa = 'Adulto', tamano = 'Mediano';
  String sexo = 'Macho', barrio = 'Centro';
  bool vacunado = false, castrado = false, gratis = false;

  showModalBottomSheet<void>(
    context: ctxPadre,
    isScrollControlled: true,
    backgroundColor: fondoHoja(),
    shape: kFormaHoja,
    builder: (ctx) => StatefulBuilder(builder: (ctx, setSt) {
      return Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 14),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.9),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                manija(),
                const SizedBox(height: 14),
                Text('Dar en adopción',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800, color: Tema.texto)),
                const SizedBox(height: 4),
                Text('Completá la ficha técnica. Tu dirección nunca se muestra: coordinás por chat.',
                    style: TextStyle(fontSize: 12.5, color: Tema.textoSuave)),
                const SizedBox(height: 14),
                _fotoConCambio(
                  foto,
                  () async {
                    final b = await _elegirFoto(ctx, true);
                    if (b != null) setSt(() => foto = b);
                  },
                  () async {
                    final b = await _elegirFoto(ctx, false);
                    if (b != null) setSt(() => foto = b);
                  },
                ),
                _campoTexto(nombre, 'Nombre del animal', Icons.pets),
                selectorChips('Especie', ['Perro', 'Gato', 'Otro'], tipo,
                    (v) => setSt(() => tipo = v)),
                selectorChips('Etapa', ['Cachorro', 'Adulto'], etapa,
                    (v) => setSt(() => etapa = v)),
                _campoTexto(edad, 'Edad aproximada (ej: 2 años, 6 meses)', Icons.cake_outlined),
                selectorChips('Sexo', ['Macho', 'Hembra'], sexo, (v) => setSt(() => sexo = v)),
                selectorChips('Tamaño', kTamanos, tamano, (v) => setSt(() => tamano = v)),
                switchFila('Vacunado', vacunado, (v) => setSt(() => vacunado = v)),
                switchFila('Castrado / esterilizado', castrado, (v) => setSt(() => castrado = v)),
                const SizedBox(height: 8),
                selectorChips('Barrio (no se muestra la dirección)', kBarrios, barrio,
                    (v) => setSt(() => barrio = v)),
                _campoTexto(pers, 'Carácter (ej: juguetón, tranquilo)', Icons.favorite_border),
                _campoTexto(cond, 'Condiciones de adopción (ej: patio, seguimiento)',
                    Icons.home_outlined),
                _campoTexto(desc, 'Historia y descripción', Icons.notes, lineas: 3),
                switchFila('Confirmo que la adopción es gratuita y responsable (sin venta)',
                    gratis, (v) => setSt(() => gratis = v)),
                const SizedBox(height: 14),
                BotonBordo(
                  texto: 'PUBLICAR EN ADOPCIÓN',
                  onTap: () {
                    if (nombre.text.trim().isEmpty ||
                        edad.text.trim().isEmpty ||
                        desc.text.trim().isEmpty) {
                      aviso(ctx, 'Completá nombre, edad e historia',
                          color: Colors.red.shade800);
                      return;
                    }
                    if (!gratis) {
                      aviso(ctx, 'Debés confirmar que la adopción es gratuita (no se permite la venta).',
                          color: Colors.red.shade800);
                      return;
                    }
                    if (textoProhibido(
                        '${nombre.text} ${edad.text} ${pers.text} ${cond.text} ${desc.text}')) {
                      aviso(ctx, kMsgProhibido, color: Colors.red.shade800);
                      return;
                    }
                    adopciones.value = [
                      Adopcion(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        nombre: nombre.text.trim(),
                        tipo: tipo,
                        etapa: etapa,
                        edad: edad.text.trim(),
                        sexo: sexo,
                        tamano: tamano,
                        barrio: barrio,
                        descripcion: desc.text.trim(),
                        personalidad:
                            pers.text.trim().isEmpty ? 'Sin especificar' : pers.text.trim(),
                        condiciones:
                            cond.text.trim().isEmpty ? 'A coordinar por chat' : cond.text.trim(),
                        autor: Sesion.nombre,
                        vacunado: vacunado,
                        castrado: castrado,
                        fecha: DateTime.now(),
                        bytes: foto,
                      ),
                      ...adopciones.value,
                    ];
                    Navigator.pop(ctx);
                    aviso(ctxPadre, '¡Publicado en adopción! Las consultas llegarán por chat.',
                        color: Colors.green.shade700);
                    alPublicar?.call();
                  },
                ),
                const SizedBox(height: 22),
              ],
            ),
          ),
        ),
      );
    }),
  );
}

// ───────────────────── ESTRUCTURA PRINCIPAL ─────────────────────
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _idx = 0;
  final PageController _pc = PageController();
  final GlobalKey<ScaffoldState> _sk = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Sesion.aceptoTerminos && mounted) _bienvenida();
    });
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _bienvenida() {
    bool acepto = false;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSt) {
        return AlertDialog(
          backgroundColor: fondoHoja(),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text('Antes de empezar 🐾',
              style: TextStyle(color: Tema.texto, fontWeight: FontWeight.w900)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Apoyamos la adopción, no la venta. Todos los animales merecen una segunda oportunidad.',
                    style: TextStyle(fontSize: 13, height: 1.35, color: Tema.textoSuave)),
                const SizedBox(height: 12),
                filaDato(Icons.shield_outlined, 'Regla de oro',
                    'Nunca asistas a encuentros a solas. Usá puntos de intercambio seguros (veterinarias adheridas) o lugares públicos concurridos.'),
                filaDato(Icons.money_off, 'Pagos',
                    'Nunca transfieras dinero como recompensa antes de recuperar a tu mascota.'),
                filaDato(Icons.chat_bubble_outline, 'Contacto',
                    'Todo contacto es por el chat interno. Los teléfonos no se muestran.'),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: acepto,
                      activeColor: Paleta.bordoClaro,
                      onChanged: (v) => setSt(() => acepto = v ?? false),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                            'Acepto los Términos y la Política de Privacidad (tratamiento de datos sensibles: DNI y ubicación).',
                            style: TextStyle(fontSize: 12, color: Tema.texto)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: acepto
                  ? () {
                      Sesion.aceptoTerminos = true;
                      Navigator.pop(ctx);
                    }
                  : null,
              child: Text('Continuar',
                  style: TextStyle(
                      color: acepto ? Paleta.bordoClaro : Tema.tenue,
                      fontWeight: FontWeight.w900)),
            ),
          ],
        );
      }),
    );
  }

  void _ir(int i) {
    setState(() => _idx = i);
    _pc.animateToPage(i,
        duration: const Duration(milliseconds: 550), curve: Curves.easeOutCubic);
  }

  Widget _panel(int i) {
    switch (i) {
      case 0:
        return PanelPerdidas();
      case 1:
        return PanelLoVi();
      case 2:
        return PanelAdopciones();
      case 3:
        return PanelRefugios();
      case 4:
        return PanelReencuentros();
      default:
        return PanelPerdidas();
    }
  }

  int _cantPropias() =>
      avistamientos.value.where((a) => a.autor == Sesion.nombre && !a.eliminado).length +
      adopciones.value.where((a) => a.autor == Sesion.nombre && !a.eliminado).length;

  void _misPublicaciones() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: fondoHoja(),
      shape: kFormaHoja,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSt) {
        final av = avistamientos.value
            .where((a) => a.autor == Sesion.nombre && !a.eliminado)
            .toList();
        final ad = adopciones.value
            .where((a) => a.autor == Sesion.nombre && !a.eliminado)
            .toList();
        Widget fila(IconData ic, String t, String sub, VoidCallback borrar) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(9),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [Paleta.bordoClaro, Paleta.bordo]),
              ),
              child: Icon(ic, color: Paleta.hueso, size: 18),
            ),
            title: Text(t,
                style: TextStyle(color: Tema.texto, fontWeight: FontWeight.w700)),
            subtitle: Text(sub, style: TextStyle(color: Tema.tenue, fontSize: 12)),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: Tema.tenue),
              tooltip: 'Eliminar',
              onPressed: borrar,
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.7),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                manija(),
                const SizedBox(height: 14),
                Text('Mis publicaciones',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800, color: Tema.texto)),
                const SizedBox(height: 8),
                Flexible(
                  child: (av.isEmpty && ad.isEmpty)
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          child: Text(
                              'Todavía no publicaste nada. Usá el botón "Subir" del menú.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Tema.tenue)),
                        )
                      : ListView(
                          shrinkWrap: true,
                          children: [
                            for (final a in av)
                              fila(Icons.visibility, 'Lo vi · ${a.ubicacion}',
                                  fmtFecha(a.fecha), () {
                                a.eliminado = true;
                                refrescar(avistamientos);
                                setSt(() {});
                                aviso(ctx,
                                    'Publicación eliminada correctamente.');
                              }),
                            for (final a in ad)
                              fila(Icons.volunteer_activism, 'Adopción · ${a.nombre}',
                                  fmtFecha(a.fecha), () {
                                a.eliminado = true;
                                refrescar(adopciones);
                                setSt(() {});
                                aviso(ctx,
                                    'Publicación eliminada correctamente.');
                              }),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _buzon() {
    final c = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: fondoHoja(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text('Buzón de sugerencias',
            style: TextStyle(color: Tema.texto, fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Dejá tus comentarios para mejorar la app, ¡gracias!',
                style: TextStyle(fontSize: 13, color: Tema.textoSuave)),
            const SizedBox(height: 12),
            TextField(
              controller: c,
              maxLines: 4,
              style: TextStyle(color: Tema.texto),
              decoration: decoCampo('Escribí tu sugerencia', Icons.lightbulb_outline),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: TextStyle(color: Tema.tenue)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              aviso(context, '¡Gracias por tu sugerencia!', color: Colors.green.shade700);
            },
            child: const Text('Enviar',
                style: TextStyle(color: Paleta.bordoClaro, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _pildoraDrawer(IconData ic, String t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(ic, size: 13, color: Paleta.hueso),
        const SizedBox(width: 5),
        Text(t,
            style: const TextStyle(
                color: Paleta.hueso, fontSize: 11.5, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _itemDrawer(IconData ic, String t, VoidCallback onTap) {
    return ListTile(
      leading: Icon(ic, color: Paleta.bordoClaro),
      title: Text(t, style: TextStyle(color: Tema.texto, fontWeight: FontWeight.w600)),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  Widget _drawer() {
    final propias = _cantPropias();
    return Drawer(
      backgroundColor: fondoHoja(),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 22),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Paleta.bordoClaro, Paleta.bordoOscuro],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                avatar(Sesion.nombre, r: 30),
                const SizedBox(height: 12),
                Text(Sesion.nombre,
                    style: const TextStyle(
                        color: Paleta.hueso, fontSize: 21, fontWeight: FontWeight.w900)),
                if (Sesion.email.isNotEmpty)
                  Text(Sesion.email,
                      style: TextStyle(
                          color: Paleta.beige.withOpacity(0.85), fontSize: 12.5)),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  _pildoraDrawer(Icons.cake_outlined,
                      Sesion.edad.isEmpty ? 'Edad —' : '${Sesion.edad} años'),
                  _pildoraDrawer(Icons.badge_outlined, 'DNI ${Sesion.dniOculto}'),
                  _pildoraDrawer(Icons.verified_user_outlined,
                      propias > 0 ? 'Modo Editor' : 'Modo Usuario'),
                ]),
                const SizedBox(height: 8),
                Text('Tu DNI es privado: solo lo ve el administrador.',
                    style: TextStyle(
                        color: Paleta.beige.withOpacity(0.7), fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          _itemDrawer(Icons.folder_shared_outlined, 'Mis publicaciones ($propias)',
              _misPublicaciones),
          _itemDrawer(Icons.lightbulb_outline, 'Buzón de sugerencias', _buzon),
          _itemDrawer(
              Icons.shield_outlined,
              'Seguridad y regla de oro',
              () => dialogoInfo(
                  context,
                  'Seguridad',
                  Text(
                      'NUNCA asistas a encuentros a solas. Usá siempre puntos de intercambio seguros (veterinarias adheridas) o lugares públicos concurridos.\n\nNunca transfieras dinero como recompensa antes de recuperar a tu mascota.\n\n$kAlertaSeguridad',
                      style: TextStyle(color: Tema.textoSuave, height: 1.4)))),
          _itemDrawer(
              Icons.gavel,
              'Términos y privacidad',
              () => dialogoInfo(
                  context,
                  'Términos y privacidad',
                  Text(
                      'Tus datos sensibles (DNI y ubicación) se usan solo para verificar tu identidad y prevenir estafas. No se muestran a otros usuarios. Está prohibida la venta de animales y el contacto por fuera del chat interno.',
                      style: TextStyle(color: Tema.textoSuave, height: 1.4)))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                const Icon(Icons.brightness_6_outlined, color: Paleta.bordoClaro),
                const SizedBox(width: 16),
                Expanded(
                  child: Text('Modo día / noche',
                      style: TextStyle(color: Tema.texto, fontWeight: FontWeight.w600)),
                ),
                InterruptorTema(),
              ],
            ),
          ),
          Divider(color: Tema.borde),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: Text(
                '“El maltrato no se ignora, se denuncia. Alzar la voz por quienes no pueden hablar es el primer paso para cambiar su mundo y detener la crueldad.”',
                style: TextStyle(
                    fontSize: 12.5,
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                    color: Tema.textoSuave)),
          ),
          _itemDrawer(
              Icons.logout,
              'Cerrar sesión',
              () => Navigator.pushReplacement(
                  context, rutaAnimada(const AuthDualScreen(empezarLogin: true)))),
        ],
      ),
    );
  }

  Widget _cabecera() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 10, 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _sk.currentState?.openDrawer(),
            child: avatar(Sesion.nombre, r: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () => _sk.currentState?.openDrawer(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hola, ${Sesion.primerNombre} 👋',
                      style: TextStyle(fontSize: 12, color: Tema.textoSuave)),
                  Text('MISIFU JUJUY',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                          color: Tema.texto)),
                ],
              ),
            ),
          ),
          InterruptorTema(),
          IconButton(
            icon: Icon(Icons.menu_rounded, color: Tema.texto),
            tooltip: 'Menú',
            onPressed: () => _sk.currentState?.openDrawer(),
          ),
        ],
      ),
    );
  }

  Widget _navItem(int i, IconData ic, String label) {
    final sel = _idx == i;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _ir(i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: sel
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Paleta.bordoClaro, Paleta.bordo])
              : null,
          boxShadow: sel
              ? [
                  BoxShadow(
                      color: Paleta.bordoClaro.withOpacity(0.55),
                      blurRadius: 16,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ic,
                size: 20,
                color: sel ? Paleta.hueso : Paleta.beige.withOpacity(0.75)),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    color: sel ? Paleta.hueso : Paleta.beige.withOpacity(0.8),
                    fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 9.5)),
          ],
        ),
      ),
    );
  }

  Widget _barraNavegacion() {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Positioned(
      left: 10,
      right: 10,
      bottom: 12 + bottom,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: Tema.n
              ? Paleta.bordoOscuro.withOpacity(0.94)
              : Paleta.bordo.withOpacity(0.96),
          borderRadius: BorderRadius.circular(34),
          border: Border.all(color: Paleta.beige.withOpacity(0.18)),
          boxShadow: [
            BoxShadow(
                color: Paleta.bordo.withOpacity(Tema.n ? 0.6 : 0.35),
                blurRadius: 24,
                offset: const Offset(0, 10)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(0, Icons.search_rounded, 'Perdidas'),
            _navItem(1, Icons.visibility, 'Lo vi'),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => abrirMenuSubir(context, irA: _ir),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFC4505F), Paleta.bordoClaro]),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                            color: Paleta.bordoClaro.withOpacity(0.7),
                            blurRadius: 18,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: const Icon(Icons.add_a_photo, color: Paleta.hueso, size: 20),
                  ),
                  const SizedBox(height: 3),
                  Text('Subir',
                      style: TextStyle(
                          color: Paleta.beige.withOpacity(0.9),
                          fontWeight: FontWeight.w700,
                          fontSize: 9.5)),
                ],
              ),
            ),
            _navItem(2, Icons.volunteer_activism, 'Adopción'),
            _navItem(3, Icons.home_work_rounded, 'Refugios'),
            _navItem(4, Icons.stars_rounded, 'Éxito'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: modoNoche,
      builder: (context, noche, _) {
        return Scaffold(
          key: _sk,
          backgroundColor: noche ? Paleta.negroVino : Paleta.hueso,
          drawer: _drawer(),
          body: Stack(
            children: [
              Positioned.fill(child: FondoAnimado()),
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    _cabecera(),
                    Expanded(
                      child: PageView.builder(
                        controller: _pc,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 5,
                        itemBuilder: (context, i) {
                          return AnimatedBuilder(
                            animation: _pc,
                            builder: (context, child) {
                              double v = 0;
                              if (_pc.hasClients && _pc.position.haveDimensions) {
                                v = ((_pc.page ?? i.toDouble()) - i).clamp(-1.0, 1.0);
                              }
                              return Transform(
                                alignment: v > 0
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                transform: Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateY(v * 0.55),
                                child: Opacity(
                                  opacity: (1 - v.abs() * 0.7).clamp(0.0, 1.0),
                                  child: child,
                                ),
                              );
                            },
                            child: _panel(i),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              _barraNavegacion(),
            ],
          ),
        );
      },
    );
  }
}

// ───────────────────── PANEL A: MASCOTAS PERDIDAS ─────────────────────
class PanelPerdidas extends StatefulWidget {
  const PanelPerdidas({super.key});
  @override
  State<PanelPerdidas> createState() => _PanelPerdidasState();
}

class _PanelPerdidasState extends State<PanelPerdidas> {
  final Filtro _f = Filtro();

  void _avanzarEstado(Perdida m) {
    if (m.autor != Sesion.nombre) {
      aviso(context, 'Solo el autor puede cambiar el estado.');
      return;
    }
    setState(() {
      m.estado = (m.estado + 1) % 4;
    });
    refrescar(perdidas);
    aviso(context, 'Estado actualizado', color: Colors.green.shade700);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Perdida>>(
      valueListenable: perdidas,
      builder: (context, todas, _) {
        final lista = todas
            .where((m) =>
                m.estado < 3 &&
                _f.pasa(
                    tipoItem: m.tipo,
                    etapa: m.etapa,
                    tam: m.tamano,
                    bar: m.barrio,
                    txt: '${m.nombre} ${m.desc} ${m.barrio}'))
            .toList()
          ..sort((a, b) => b.fecha.compareTo(a.fecha));

        return ListView(
          padding: const EdgeInsets.only(top: 4, bottom: 120),
          children: [
            Aparece(
              indice: 0,
              child: tituloPanel(Icons.search_rounded, 'Mascotas perdidas',
                  'Ayudá a que vuelvan a casa. Escribile al dueño si tenés información.'),
            ),
            Aparece(
              indice: 1,
              child: buscador((v) => setState(() => _f.texto = v)),
            ),
            Aparece(
              indice: 2,
              child: BarraFiltros(filtro: _f, alCambiar: () => setState(() {})),
            ),
            const SizedBox(height: 6),
            if (lista.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Text('No encontramos mascotas con ese filtro 🐾',
                    textAlign: TextAlign.center, style: TextStyle(color: Tema.tenue)),
              ),
            for (int i = 0; i < lista.length; i++)
              Aparece(
                key: ValueKey('perdida_${lista[i].id}_${_f.tipo}_${_f.barrio}_${_f.tamano}_${_f.texto}'),
                indice: i + 3,
                child: _tarjeta(lista[i]),
              ),
          ],
        );
      },
    );
  }

  Widget _tarjeta(Perdida m) {
    final esAutor = m.autor == Sesion.nombre;
    return Tarjeta3D(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                chipInfo('PERDIDO', fuerte: true),
                const Spacer(),
                Icon(Icons.schedule, size: 13, color: Tema.tenue),
                const SizedBox(width: 4),
                Text(hace(m.fecha), style: TextStyle(color: Tema.tenue, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: esAutor ? () => _avanzarEstado(m) : null,
              child: barraEstado(m.estado),
            ),
            if (esAutor)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('(Tocá la barra para cambiar de estado)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: Tema.tenue)),
              ),
            const SizedBox(height: 12),
            fotoCentrada(m.img, alto: 150),
            const SizedBox(height: 12),
            Text(m.nombre,
                style: TextStyle(
                    color: Tema.texto, fontSize: 21, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Wrap(spacing: 8, runSpacing: 6, children: [
              chipInfo(m.tipo, ic: Icons.pets),
              chipInfo(m.etapa),
              chipInfo('Tamaño ${m.tamano.toLowerCase()}'),
              chipInfo(m.barrio, ic: Icons.location_on),
            ]),
            const SizedBox(height: 8),
            Text(m.desc,
                style: TextStyle(color: Tema.textoSuave, fontSize: 13, height: 1.35)),
            const SizedBox(height: 8),
            Row(children: [
              avatar(m.autor, r: 11),
              const SizedBox(width: 8),
              Text('Publicó ${m.autor} · ${fmtFecha(m.fecha)}',
                  style: TextStyle(fontSize: 11.5, color: Tema.tenue)),
            ]),
            const SizedBox(height: 14),
            Wrap(spacing: 10, runSpacing: 10, children: [
              BotonBordo(
                texto: esAutor ? 'Tu publicación' : 'Tengo información',
                icono: Icons.chat_bubble_outline,
                compacto: true,
                onTap: () => abrirChat(context,
                    clave: 'pe-${m.id}-${Sesion.nombre}',
                    con: m.autor,
                    asunto: 'Sobre ${m.nombre} (perdido)'),
              ),
              BotonBordo(
                texto: 'Comentarios · ${m.comentarios.length}',
                icono: Icons.forum_outlined,
                compacto: true,
                vidrio: true,
                onTap: () => abrirComentarios(context,
                    titulo: m.nombre,
                    lista: m.comentarios,
                    alCambiar: () => refrescar(perdidas)),
              ),
              BotonBordo(
                texto: 'Compartir',
                icono: Icons.share,
                compacto: true,
                vidrio: true,
                onTap: () => aviso(context, 'Compartiendo a ${m.nombre} (simulación)'),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

// ───────────────────── PANEL B: LO VI POR AQUÍ ─────────────────────
class PanelLoVi extends StatefulWidget {
  const PanelLoVi({super.key});
  @override
  State<PanelLoVi> createState() => _PanelLoViState();
}

class _PanelLoViState extends State<PanelLoVi> {
  final Filtro _f = Filtro();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Avistamiento>>(
      valueListenable: avistamientos,
      builder: (context, todos, _) {
        final lista = todos
            .where((a) =>
                !a.eliminado &&
                _f.pasa(
                    tipoItem: a.tipo,
                    etapa: a.etapa,
                    tam: a.tamano,
                    bar: a.barrio,
                    txt: '${a.ubicacion} ${a.descripcion} ${a.color} ${a.barrio}'))
            .toList()
          ..sort((a, b) => b.fecha.compareTo(a.fecha));

        return ListView(
          padding: const EdgeInsets.only(top: 4, bottom: 120),
          children: [
            Aparece(
              indice: 0,
              child: tituloPanel(Icons.visibility_rounded, 'Lo vi por aquí',
                  'Animales vistos o rescatados en la calle. Comentá o escribile a quien lo publicó.'),
            ),
            Aparece(
              indice: 1,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('${lista.length} avistamientos',
                          style: TextStyle(
                              color: Tema.textoSuave, fontWeight: FontWeight.w600)),
                    ),
                    BotonBordo(
                      texto: 'Subir lo vi',
                      icono: Icons.add_a_photo,
                      compacto: true,
                      onTap: () => abrirReporteAvistamiento(context),
                    ),
                  ],
                ),
              ),
            ),
            Aparece(
              indice: 2,
              child: BarraFiltros(filtro: _f, alCambiar: () => setState(() {})),
            ),
            const SizedBox(height: 6),
            if (lista.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Text('No hay avistamientos con ese filtro 🐾',
                    textAlign: TextAlign.center, style: TextStyle(color: Tema.tenue)),
              ),
            for (int i = 0; i < lista.length; i++)
              Aparece(
                key: ValueKey('avistamiento_${lista[i].id}_${_f.tipo}_${_f.barrio}_${_f.tamano}'),
                indice: i + 3,
                child: _tarjeta(context, lista[i]),
              ),
          ],
        );
      },
    );
  }

  Widget _tarjeta(BuildContext context, Avistamiento a) {
    final propio = a.autor == Sesion.nombre;
    final urgente = a.condicion == 'Herido' || a.condicion == 'Desnutrido / débil';
    return Tarjeta3D(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              const Icon(Icons.location_on, size: 18, color: Paleta.bordoClaro),
              const SizedBox(width: 4),
              Expanded(
                child: Text(a.ubicacion,
                    style: TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 15, color: Tema.texto)),
              ),
              if (propio)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.delete_outline, color: Tema.tenue),
                  tooltip: 'Eliminar',
                  onPressed: () {
                    a.eliminado = true;
                    refrescar(avistamientos);
                    aviso(context, 'Publicación eliminada correctamente');
                  },
                )
              else
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.flag_outlined, color: Tema.tenue),
                  tooltip: 'Denunciar publicación',
                  onPressed: () => aviso(context, 'Gracias, el administrador revisará esta publicación.'),
                ),
            ]),
            const SizedBox(height: 6),
            fotoCentrada(a.img, alto: 150, bytes: a.bytes),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 6, children: [
              chipInfo(a.tipo, ic: Icons.pets),
              chipInfo(a.etapa),
              chipInfo('Tamaño ${a.tamano.toLowerCase()}'),
              chipInfo(a.condicion,
                  ic: urgente ? Icons.warning_amber_rounded : Icons.favorite_border,
                  fuerte: urgente),
            ]),
            const SizedBox(height: 10),
            filaDato(Icons.palette_outlined, 'Color y señas', a.color),
            filaDato(Icons.sell_outlined, 'Collar o chapita', a.collar ? 'Sí, tiene' : 'No tiene'),
            filaDato(Icons.place_outlined, '¿Dónde está ahora?', a.dondeEsta),
            filaDato(Icons.map_outlined, 'Barrio', a.barrio),
            if (a.enlaceMapa.isNotEmpty)
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: a.enlaceMapa));
                  aviso(context, 'Copiado. Pegalo en Google Maps para ver el punto exacto.');
                },
                child: filaDato(Icons.my_location, 'Punto en el mapa',
                    '${a.enlaceMapa}  (tocá para copiar)'),
              ),
            const SizedBox(height: 6),
            Text(a.descripcion,
                style: TextStyle(fontSize: 14, height: 1.35, color: Tema.textoSuave)),
            const SizedBox(height: 10),
            Row(children: [
              avatar(a.autor, r: 11),
              const SizedBox(width: 8),
              Expanded(
                child: Text('${a.autor} · ${fmtFecha(a.fecha)}  (${hace(a.fecha)})',
                    style: TextStyle(fontSize: 11.5, color: Tema.tenue)),
              ),
            ]),
            const SizedBox(height: 14),
            Wrap(spacing: 10, runSpacing: 10, children: [
              BotonBordo(
                texto: propio ? 'Es tu publicación' : 'Escribirle a ${a.autor.split(' ').first}',
                icono: Icons.chat_bubble_outline,
                compacto: true,
                onTap: () => abrirChat(context,
                    clave: 'av-${a.id}-${Sesion.nombre}',
                    con: a.autor,
                    asunto: 'Lo vi: ${a.ubicacion}'),
              ),
              BotonBordo(
                texto: 'Comentarios · ${a.comentarios.length}',
                icono: Icons.forum_outlined,
                compacto: true,
                vidrio: true,
                onTap: () => abrirComentarios(context,
                    titulo: a.ubicacion,
                    lista: a.comentarios,
                    alCambiar: () => refrescar(avistamientos)),
              ),
              BotonBordo(
                texto: 'Yo también lo vi · ${a.confirmaciones}',
                icono: Icons.thumb_up_alt_outlined,
                compacto: true,
                vidrio: true,
                onTap: () {
                  a.confirmaciones++;
                  refrescar(avistamientos);
                },
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

// ───────────────────── PANEL C: ADOPCIONES PARTICULARES ─────────────────────
class PanelAdopciones extends StatefulWidget {
  const PanelAdopciones({super.key});
  @override
  State<PanelAdopciones> createState() => _PanelAdopcionesState();
}

class _PanelAdopcionesState extends State<PanelAdopciones> {
  final Filtro _f = Filtro();
  int _i = 0;
  double _dx = 0;
  bool _drag = false;
  bool _inst = false;
  final Set<String> _fav = {};
  List<Adopcion> _actual = [];

  List<Adopcion> _visibles(List<Adopcion> todas) {
    return todas
        .where((a) =>
            !a.eliminado &&
            _f.pasa(
                tipoItem: a.tipo,
                etapa: a.etapa,
                tam: a.tamano,
                bar: a.barrio,
                txt: '${a.nombre} ${a.descripcion} ${a.barrio}'))
        .toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
  }

  void _soltar(double w) {
    if (_actual.isEmpty || _i >= _actual.length) return;
    if (_dx.abs() > 100) {
      final like = _dx > 0;
      final nombre = _actual[_i].nombre;
      setState(() {
        _drag = false;
        _dx = like ? w * 1.5 : -w * 1.5;
      });
      Future.delayed(const Duration(milliseconds: 270), () {
        if (!mounted) return;
        setState(() {
          if (like) _fav.add(nombre);
          _i++;
          _dx = 0;
          _inst = true;
        });
        if (like) aviso(context, '$nombre guardado en favoritos ♥');
        Future.delayed(const Duration(milliseconds: 40), () {
          if (mounted) setState(() => _inst = false);
        });
      });
    } else {
      setState(() {
        _drag = false;
        _dx = 0;
      });
    }
  }

  Widget _sello(String t, Color c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        border: Border.all(color: c, width: 3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(t,
          style: TextStyle(
              color: c, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2)),
    );
  }

  Widget _tarjetaAnimal(Adopcion a, double dx) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: vidrioDeco(radio: 26),
      child: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 230),
                      child: imagenMascota(a.img, a.bytes),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${a.nombre}, ${a.edad}',
                        style: TextStyle(
                            color: Tema.texto, fontSize: 24, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 6, children: [
                      chipInfo(a.tipo, ic: Icons.pets, fuerte: true),
                      chipInfo(a.sexo),
                      chipInfo('Tamaño ${a.tamano.toLowerCase()}'),
                      if (a.vacunado) chipInfo('Vacunado', ic: Icons.vaccines),
                      if (a.castrado) chipInfo('Castrado'),
                    ]),
                    const SizedBox(height: 8),
                    Text(a.descripcion,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Tema.textoSuave, fontSize: 13, height: 1.35)),
                    const SizedBox(height: 6),
                    Text('Publicado por ${a.autor} · ${hace(a.fecha)} · ${a.barrio}',
                        style: TextStyle(color: Tema.tenue, fontSize: 11.5)),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 20,
            left: 20,
            child: Opacity(
              opacity: (dx / 100).clamp(0.0, 1.0),
              child: _sello('ME GUSTA', Colors.green.shade600),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Opacity(
              opacity: (-dx / 100).clamp(0.0, 1.0),
              child: _sello('PASAR', Paleta.bordo),
            ),
          ),
        ],
      ),
    );
  }

  Widget _botonRedondo(IconData ic, VoidCallback onTap, {bool principal = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: principal ? 64 : 54,
        height: principal ? 64 : 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: principal
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Paleta.bordoClaro, Paleta.bordo])
              : null,
          color: principal ? null : Tema.campo,
          border: Border.all(
              color: principal ? Colors.white.withOpacity(0.25) : Tema.borde),
          boxShadow: principal
              ? [
                  BoxShadow(
                      color: Paleta.bordoClaro.withOpacity(0.6),
                      blurRadius: 20,
                      offset: const Offset(0, 6))
                ]
              : [],
        ),
        child: Icon(ic,
            color: principal ? Paleta.hueso : Tema.texto, size: principal ? 30 : 24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Adopcion>>(
      valueListenable: adopciones,
      builder: (context, todas, _) {
        _actual = _visibles(todas);
        if (_i >= _actual.length && _actual.isNotEmpty) {
          _i = _actual.length;
        }
        final terminado = _i >= _actual.length;
        return LayoutBuilder(builder: (context, c) {
          final w = c.maxWidth;
          return Column(
            children: [
              Aparece(
                indice: 0,
                child: tituloPanel(Icons.volunteer_activism, 'Adopciones de usuarios',
                    'Apoyamos la adopción, no la venta. Deslizá o tocá la tarjeta para ver la ficha.'),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('♥ ${_fav.length} favoritos',
                          style: TextStyle(
                              color: Tema.textoSuave, fontWeight: FontWeight.w700)),
                    ),
                    BotonBordo(
                      texto: 'Publicar adopción',
                      icono: Icons.add,
                      compacto: true,
                      onTap: () => abrirPublicarAdopcion(context),
                    ),
                  ],
                ),
              ),
              BarraFiltros(
                filtro: _f,
                alCambiar: () => setState(() {
                  _i = 0;
                  _dx = 0;
                }),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: terminado
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.pets, color: Tema.texto, size: 54),
                            const SizedBox(height: 12),
                            Text(
                                _actual.isEmpty
                                    ? 'No hay adopciones con ese filtro'
                                    : '¡Viste todos los peluditos!',
                                style: TextStyle(
                                    color: Tema.texto,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 18),
                            BotonBordo(
                              texto: 'Volver a ver',
                              icono: Icons.refresh,
                              onTap: () => setState(() {
                                _i = 0;
                                _f.tipo = 'Todos';
                                _f.barrio = 'Todos';
                                _f.tamano = 'Todos';
                              }),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: Stack(
                          children: [
                            if (_i + 1 < _actual.length)
                              Positioned.fill(
                                child: Transform.scale(
                                  scale: 0.93,
                                  child: Opacity(
                                    opacity: 0.7,
                                    child: _tarjetaAnimal(_actual[_i + 1], 0),
                                  ),
                                ),
                              ),
                            Positioned.fill(
                              child: GestureDetector(
                                onTap: () => mostrarFicha(context, _actual[_i]),
                                onPanStart: (_) => setState(() => _drag = true),
                                onPanUpdate: (d) => setState(() => _dx += d.delta.dx),
                                onPanEnd: (_) => _soltar(w),
                                child: AnimatedContainer(
                                  duration: Duration(
                                      milliseconds: (_drag || _inst) ? 0 : 260),
                                  curve: Curves.easeOut,
                                  transformAlignment: Alignment.bottomCenter,
                                  transform: Matrix4.identity()
                                    ..setEntry(3, 2, 0.001)
                                    ..translate(_dx, 0.0)
                                    ..rotateZ(_dx / 1100)
                                    ..rotateY(_dx / 1400),
                                  child: _tarjetaAnimal(_actual[_i], _dx),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              if (!terminado)
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 112),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _botonRedondo(Icons.close, () {
                        _dx = -101;
                        _soltar(w);
                      }),
                      const SizedBox(width: 22),
                      _botonRedondo(Icons.favorite, () {
                        _dx = 101;
                        _soltar(w);
                      }, principal: true),
                      const SizedBox(width: 22),
                      _botonRedondo(Icons.chat_bubble_outline,
                          () => mostrarFicha(context, _actual[_i])),
                    ],
                  ),
                ),
            ],
          );
        });
      },
    );
  }
}

// ───────────────────── PANEL D: REFUGIOS Y VETERINARIAS ─────────────────────
class PanelRefugios extends StatelessWidget {
  const PanelRefugios({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 120),
      children: [
        Aparece(
          indice: 0,
          child: tituloPanel(Icons.home_work_rounded, 'Refugios y veterinarias',
              'Asociaciones verificadas con sus mascotas disponibles. Contacto solo por chat.'),
        ),
        for (int i = 0; i < kRefugios.length; i++)
          Aparece(indice: i + 1, child: _tarjeta(context, kRefugios[i])),
      ],
    );
  }

  Widget _tarjeta(BuildContext context, Refugio r) {
    return Tarjeta3D(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Paleta.bordoClaro, Paleta.bordo]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Paleta.bordoClaro.withOpacity(0.5), blurRadius: 14)
                  ],
                ),
                child: const Icon(Icons.home_work_rounded, color: Paleta.hueso, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.nombre,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800, color: Tema.texto)),
                    const SizedBox(height: 4),
                    Row(children: [
                      chipInfo(r.tipo),
                      const SizedBox(width: 8),
                      insigniaVerificado(),
                    ]),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Text(r.descripcion,
                style: TextStyle(fontSize: 13, height: 1.35, color: Tema.textoSuave)),
            const SizedBox(height: 8),
            filaDato(Icons.location_on_outlined, 'Ubicación', r.direccion),
            filaDato(Icons.schedule, 'Horarios', r.horarios),
            filaDato(Icons.pets, 'Disponibles', '${r.mascotas.length} mascotas en adopción'),
            const SizedBox(height: 10),
            Text('MASCOTAS PARA ADOPTAR',
                style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w900,
                    color: Tema.tenue)),
            const SizedBox(height: 8),
            SizedBox(
              height: 148,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final m in r.mascotas)
                    GestureDetector(
                      onTap: () => mostrarFicha(context, m),
                      child: Container(
                        width: 128,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Tema.campo,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Tema.borde),
                        ),
                        child: Column(
                          children: [
                            Expanded(child: Center(child: imagenMascota(m.img, m.bytes))),
                            const SizedBox(height: 6),
                            Text(m.nombre,
                                style: TextStyle(
                                    fontWeight: FontWeight.w800, color: Tema.texto)),
                            Text('${m.edad} · ${m.sexo}',
                                style: TextStyle(fontSize: 11, color: Tema.tenue)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text('Meta de donaciones de alimento (demo)',
                style: TextStyle(color: Tema.textoSuave, fontSize: 12)),
            const SizedBox(height: 6),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: r.meta),
              duration: const Duration(milliseconds: 1400),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: v,
                  minHeight: 9,
                  backgroundColor: Paleta.bordo.withOpacity(0.12),
                  valueColor: const AlwaysStoppedAnimation(Paleta.bordoClaro),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(spacing: 10, runSpacing: 10, children: [
              BotonBordo(
                texto: 'Chatear con el refugio',
                icono: Icons.chat_bubble_outline,
                compacto: true,
                onTap: () => abrirChat(context,
                    clave: 'ref-${r.nombre}-${Sesion.nombre}',
                    con: r.nombre,
                    asunto: 'Consulta de adopción'),
              ),
              BotonBordo(
                texto: 'Cómo llegar',
                icono: Icons.directions,
                compacto: true,
                vidrio: true,
                onTap: () {
                  Clipboard.setData(ClipboardData(text: r.direccion));
                  aviso(context, 'Dirección copiada. Pegala en Google Maps.');
                },
              ),
              BotonBordo(
                texto: 'Ser voluntario',
                icono: Icons.volunteer_activism,
                compacto: true,
                vidrio: true,
                onTap: () => abrirChat(context,
                    clave: 'vol-${r.nombre}-${Sesion.nombre}',
                    con: r.nombre,
                    asunto: 'Quiero ser voluntario'),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

// ───────────────────── PANEL E: REENCUENTROS CON ÉXITO ─────────────────────
class PanelReencuentros extends StatelessWidget {
  const PanelReencuentros({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Reencuentro>>(
      valueListenable: reencuentros,
      builder: (context, lista, _) {
        return ListView(
          padding: const EdgeInsets.only(top: 4, bottom: 120),
          children: [
            Aparece(
              indice: 0,
              child: tituloPanel(
                Icons.stars_rounded,
                'Historias de Éxito',
                'Mascotas que volvieron a casa o encontraron un nuevo hogar en Jujuy. 🎉',
              ),
            ),
            if (lista.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Text('Todavía no hay historias registradas. 🐾',
                    textAlign: TextAlign.center, style: TextStyle(color: Tema.tenue)),
              ),
            for (int i = 0; i < lista.length; i++)
              Aparece(
                indice: i + 1,
                child: _tarjeta(context, lista[i]),
              ),
          ],
        );
      },
    );
  }

  Widget _tarjeta(BuildContext context, Reencuentro r) {
    return Tarjeta3D(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                chipInfo(r.tipoExito, fuerte: true),
                const Spacer(),
                Icon(Icons.calendar_today, size: 13, color: Tema.tenue),
                const SizedBox(width: 4),
                Text(fmtFecha(r.fecha), style: TextStyle(color: Tema.tenue, fontSize: 11.5)),
              ],
            ),
            const SizedBox(height: 12),
            fotoCentrada(r.img, alto: 160),
            const SizedBox(height: 12),
            Text(
              r.nombre,
              style: TextStyle(
                color: Tema.texto,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(spacing: 8, runSpacing: 6, children: [
              chipInfo(r.tipo, ic: Icons.pets),
              chipInfo(r.barrio, ic: Icons.location_on),
            ]),
            const SizedBox(height: 10),
            Text(
              r.desc,
              style: TextStyle(color: Tema.textoSuave, fontSize: 13.5, height: 1.4),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                avatar(r.autor, r: 11),
                const SizedBox(width: 8),
                Text('Publicó ${r.autor}', style: TextStyle(fontSize: 11.5, color: Tema.tenue)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}