import 'package:flutter/material.dart';
import '../../../core/widgets/floating_chat_bubble.dart';

class ChatDemoPage extends StatelessWidget {
  const ChatDemoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Chat IA'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Contenido principal de la página
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.movie_filter,
                  size: 100,
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                ),
                const SizedBox(height: 20),
                Text(
                  'Chat de Recomendaciones',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Haz clic en el botón de chat flotante para comenzar a recibir recomendaciones de películas personalizadas.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () {
                    // Aquí podrías agregar alguna acción adicional
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Busca el chat flotante en la esquina inferior derecha!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Empezar Chat'),
                ),
              ],
            ),
          ),
          // Burbuja de chat flotante
          const FloatingChatBubble(),
        ],
      ),
    );
  }
}