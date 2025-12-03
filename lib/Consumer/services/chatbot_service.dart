import 'dart:convert';

import 'package:http/http.dart' as http;

class ChatBotService {

  Future<String> getMachineLearningResponse(String message) async {

    const String geminiUrl = 'https://generativelanguage.googleapis.com/v1beta/'
        'models/gemini-2.5-flash:generateContent';
    const String apiKey = 'AIzaSyBY4lp-mCnKgvjqNO_fUbxyhfprtKl1c6k';

    var prompt = "Eres un asistente que cumplira el rol de un ChatBot. Para que "
        "tengas contexto, la aplicacion es una plataforma donde los tecnicos "
        "publican sus servicios ya sea gasfiteria, electrcista, etc. Mientras "
        "que los consumidores solicitaran sus servicios para resolver las "
        "problematicas domesticas y/o cualquier otra con relacion a servicios "
        "tecnico. Asumiras el rol de una integracion de ChatBot en la aplicacion "
        "donde los clientes brindran una breve descripcion del problema tecnico "
        "que presenta y tu respondoras solo indicando el Id de la categoria del servicio, "
        "por ejemplo: 1, 2, 3 ETC ETC. Si  la descripcion no "
        "tiene nada relacionado con algun problema tecnicos lo descartas "
        "respondiendo de la siguiente manera LA DESCRIPCION QUE BRINDASTE "
        "NO ES LA CORRECTA, PRUEBA NUEVAMENTE. Este prompt se estara reenviando "
        "varias veces ya que es una integracion con la aplicacion. Te adjunto "
        "las categorias de servicios que manejo, cabe resaltar que tu respuesta "
        "sera el ID de la categoria mas cercana o relacionada al servicio. CATEGORIAS QUE "
        "SE MANEJAN EN MI APLICACION: GASFITERO(ID: 1), JARDINERO(ID: 2), ELECTRICISTA,(ID: 3) "
        "CARPINTERO(ID: 4), PINTOR(ID: 5), ALBAÑIL(ID: 6). "
        "DESCRIPCION DEL CLIENTE: $message";

    final response = await http.post(
      Uri.parse(geminiUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey,
      },
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];

      return text ?? 'Sin respuesta generada.';
    }

    return 'Error: No se pudo obtener respuesta del modelo.' + response.reasonPhrase!;
  }
}