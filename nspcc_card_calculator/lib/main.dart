import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const NSPCCApp());
}

class NSPCCApp extends StatelessWidget {
  const NSPCCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NSPCC Card Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0e251f),
          primary: const Color(0xFF0e251f),
          secondary: const Color(0xFFd4b36a),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0e251f),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/calc': (_) => const CalculatorScreen(),
        '/result': (_) => const ResultScreen(),
        '/form': (_) => const FormScreen(),
        '/success': (_) => const SuccessScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/calc');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0e251f), Color(0xFF0a1a16)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF123a30),
                    shape: BoxShape.circle,
                    boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 18, offset: Offset(0, 10))],
                    border: Border.all(color: Color(0x66d4b36a)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Image.asset('assets/logo.png'),
                ),
                const SizedBox(height: 16),
                const Text('NSPCC', style: TextStyle(fontSize: 18, letterSpacing: 2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PricingConfig {
  static const Map<String, double> baseByFormat = {
    'Покер': 400, 'Таро': 450, 'МАК': 430, 'Индивидуальный': 500,
  };
  static const Map<String, double> materialMul = {
    'Бумага': 1.00, 'Пластик': 1.40,
  };
  static const Map<String, double> finishMul = {
    'Матовая': 1.00, 'Глянцевая': 1.03, 'Linen Finish': 1.06,
  };
  static const Map<String, double> edgesMul = {
    'Обычные': 1.00, 'Золочёные': 1.12, 'Серебряные': 1.10,
  };
  static const Map<String, double> cmykMul = {
    'CMYK4': 1.00, 'CMYK6': 1.10,
  };
  static const Map<String, double> packMul = {
    'Стандартная коробка': 1.00, 'Крышка-дно': 1.15, 'Магнитная': 1.25,
  };
  static double discountByQty(int qty) {
    if (qty >= 5000) return 0.80;
    if (qty >= 2000) return 0.85;
    if (qty >= 1500) return 0.88;
    if (qty >= 1000) return 0.92;
    if (qty >= 500)  return 1.00;
    return 1.05;
  }
  static const double designTotal = 60000;
}

class CalcState {
  String format = 'Таро';
  String material = 'Бумага';
  String finish = 'Linen Finish';
  String pack = 'Стандартная коробка';
  String edges = 'Обычные';
  String cmyk = 'CMYK4';
  bool withDesign = false;
  int qty = 500;
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});
  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final CalcState state = CalcState();
  final _qtyCtrl = TextEditingController(text: '500');

  void _recalcQty(String v) {
    final parsed = int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), ''));
    setState(() { state.qty = (parsed == null || parsed <= 0) ? 1 : parsed; });
  }

  Map<String, dynamic> computePrice() {
    final base = PricingConfig.baseByFormat[state.format] ?? 450.0;
    final m = PricingConfig.materialMul[state.material] ?? 1;
    final f = PricingConfig.finishMul[state.finish] ?? 1;
    final p = PricingConfig.packMul[state.pack] ?? 1;
    final e = PricingConfig.edgesMul[state.edges] ?? 1;
    final c = PricingConfig.cmykMul[state.cmyk] ?? 1;
    final disc = PricingConfig.discountByQty(state.qty);

    double pricePerDeck = base * m * f * p * e * c * disc;
    if (state.withDesign) {
      pricePerDeck += (PricingConfig.designTotal / state.qty);
    }
    double total = pricePerDeck * state.qty;
    return {'pricePerDeck': pricePerDeck, 'total': total};
  }

  @override
  Widget build(BuildContext context) {
    final result = computePrice();
    final gold = const Color(0xFFd4b36a);
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFF0e251f), title: const Text('Калькулятор тиража')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Column(children: [
                Container(
                  width: 84, height: 84, padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, color: const Color(0xFF123a30),
                    border: Border.all(color: gold.withOpacity(.5)),
                    boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 16, offset: Offset(0,8))],
                  ),
                  child: Image.asset('assets/logo.png'),
                ),
                const SizedBox(height: 10),
                const Text('NSPCC', style: TextStyle(letterSpacing: 2)),
              ]),
            ),
            const SizedBox(height: 16),
            _tile('Формат', _dropdown(state.format, ['Покер','Таро','МАК','Индивидуальный'], (v)=> setState(()=> state.format=v!))),
            _tile('Материал', _dropdown(state.material, ['Бумага','Пластик'], (v)=> setState(()=> state.material=v!))),
            _tile('Покрытие', _dropdown(state.finish, ['Матовая','Глянцевая','Linen Finish'], (v)=> setState(()=> state.finish=v!))),
            _tile('Упаковка', _dropdown(state.pack, ['Стандартная коробка','Крышка-дно','Магнитная'], (v)=> setState(()=> state.pack=v!))),
            _tile('Торцы', _dropdown(state.edges, ['Обычные','Золочёные','Серебряные'], (v)=> setState(()=> state.edges=v!))),
            _tile('Тип печати', _dropdown(state.cmyk, ['CMYK4','CMYK6'], (v)=> setState(()=> state.cmyk=v!))),
            _tile('Тираж, шт', TextField(controller: _qtyCtrl, keyboardType: TextInputType.number, onChanged: _recalcQty, decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Например, 500'),)),
            SwitchListTile(value: state.withDesign, onChanged: (v)=> setState(()=> state.withDesign=v), title: const Text('С разработкой дизайна (+ распределить G/T)'), subtitle: const Text('G = 60 000 ₽ (можно изменить в коде)'), activeColor: gold),
            Card(
              color: const Color(0xFF14352c),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: gold.withOpacity(.3))),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Итог', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('Цена за 1 колоду: ${_fmt(result['pricePerDeck'])} ₽'),
                  Text('Общая стоимость: ${_fmt(result['total'])} ₽'),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: ElevatedButton(
                onPressed: () {
                  final res = computePrice();
                  Navigator.pushNamed(context, '/result', arguments: {'state': state, 'result': res});
                },
                style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: const Color(0xFF1b1408)),
                child: const Text('Рассчитать'),
              )),
            ])
          ],
        ),
      ),
    );
  }

  Widget _tile(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.only(bottom: 6.0), child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
        child,
      ]),
    );
  }

  Widget _dropdown(String value, List<String> items, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((e)=> DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      decoration: const InputDecoration(border: OutlineInputBorder()),
    );
  }

  String _fmt(num v) => v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
}

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final CalcState state = args['state'];
    final Map<String, dynamic> result = args['result'];
    final gold = const Color(0xFFd4b36a);
    return Scaffold(
      appBar: AppBar(title: const Text('Результат')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Card(
            color: const Color(0xFF14352c),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: gold.withOpacity(.3))),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Итог расчёта', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Цена за 1 колоду: ${_fmt(result['pricePerDeck'])} ₽'),
                Text('Общая стоимость: ${_fmt(result['total'])} ₽'),
              ]),
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/form', arguments: {'state': state, 'result': result}),
            style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: const Color(0xFF1b1408)),
            child: const Text('Отправить заявку'),
          ),
        ]),
      ),
    );
  }
  String _fmt(num v) => v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
}

class FormScreen extends StatefulWidget {
  const FormScreen({super.key});
  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _name = TextEditingController();
  final _contact = TextEditingController();
  final _comment = TextEditingController();
  bool _sending = false;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final CalcState state = args['state'];
    final Map<String, dynamic> result = args['result'];
    final gold = const Color(0xFFd4b36a);

    return Scaffold(
      appBar: AppBar(title: const Text('Заявка')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: 'Имя', border: OutlineInputBorder()),),
            const SizedBox(height: 12),
            TextField(controller: _contact, decoration: const InputDecoration(labelText: 'Контакт (телефон/Telegram)', border: OutlineInputBorder()),),
            const SizedBox(height: 12),
            TextField(controller: _comment, decoration: const InputDecoration(labelText: 'Комментарий', border: OutlineInputBorder()), maxLines: 4,),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sending ? null : () async {
                  setState(()=> _sending = true);
                  final body = _buildEmailBody(state, result, _name.text, _contact.text, _comment.text);
                  final uri = Uri(
                    scheme: 'mailto',
                    path: 'naucards@yandex.ru',
                    queryParameters: {'subject': 'Заявка на расчёт с калькулятора', 'body': body},
                  );
                  try { await launchUrl(uri); } catch (_) {}
                  await Future.delayed(const Duration(seconds: 1));
                  if (mounted) { setState(()=> _sending = false); Navigator.pushNamed(context, '/success'); }
                },
                style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: const Color(0xFF1b1408)),
                child: _sending ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Отправить'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildEmailBody(CalcState s, Map<String, dynamic> res, String name, String contact, String comment) {
    final price = _fmt(res['pricePerDeck']);
    final total = _fmt(res['total']);
    return [
      'Формат: ${s.format}',
      'Материал: ${s.material}',
      'Покрытие: ${s.finish}',
      'Торцы: ${s.edges}',
      'CMYK: ${s.cmyk}',
      'Упаковка: ${s.pack}',
      'Тираж: ${s.qty} шт',
      'Итог за 1 колоду: $price ₽',
      'Общая стоимость: $total ₽',
      '',
      'Имя: $name',
      'Контакт: $contact',
      'Комментарий: $comment',
    ].join('\\n');
  }

  String _fmt(num v) => v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\\d{1,3})(?=(\\d{3})+(?!\\d))'), (m) => '${m[1]} ');
}

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final gold = const Color(0xFFd4b36a);
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF0e251f), Color(0xFF0a1a16)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 72, color: gold),
            const SizedBox(height: 12),
            const Text('Спасибо! Ваша заявка отправлена.', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 6),
            const Text('Мы свяжемся с вами в течение рабочего дня.', style: TextStyle(color: Color(0xFF9fb2a8))),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/calc', (route) => false),
              style: ElevatedButton.styleFrom(backgroundColor: gold, foregroundColor: const Color(0xFF1b1408)),
              child: const Text('Новый расчёт'),
            ),
          ],
        ),
      ),
    );
  }
}
