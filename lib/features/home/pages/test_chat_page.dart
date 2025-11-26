import 'package:flutter/material.dart';
import '../../../core/widgets/chat_wrapper.dart';

class TestChatPage extends StatelessWidget {
  const TestChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChatWrapper(
      showChat: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Prueba de Chat IA'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              const Text(
                'Página de prueba del Chat IA',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Busca el icono de chat flotante en la esquina inferior derecha para probar las recomendaciones de películas con IA.',
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡El chat está funcionando! Mira abajo a la derecha 👇'),
                    ),
                  );
                },
                child: const Text('Mostrar ubicación del chat'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}