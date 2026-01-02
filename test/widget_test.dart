import 'package:flutter_test/flutter_test.dart';
import 'package:voucho_app/main.dart';
import 'package:voucho_app/app/modules/auth/login/view/login_view.dart';

void main() {
  testWidgets('Vérification de l\'affichage de la page de connexion', (WidgetTester tester) async {
    // 1. On lance l'application VouchoApp (et non MyApp)
    await tester.pumpWidget(const VouchoApp());

    // 2. On vérifie que le nom de l'app "Voucho" est bien affiché
    expect(find.text('Voucho'), findsOneWidget);

    // 3. On vérifie que le bouton de connexion est présent
    expect(find.text('Se connecter'), findsOneWidget);
  });
}