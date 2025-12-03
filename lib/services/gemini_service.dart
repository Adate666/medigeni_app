import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class GeminiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  static String? _apiKey;

  static void initialize(String apiKey) {
    _apiKey = apiKey;
  }

  static bool get isInitialized => _apiKey != null && _apiKey!.isNotEmpty;

  // Prompts système pour chaque fonctionnalité
  static const String _chatbotSystemPrompt = '''
Tu es un assistant médical empathique et professionnel. Ton rôle est de fournir des informations générales sur la santé, de répondre aux questions des patients de manière claire et rassurante, et de les orienter vers des professionnels de santé lorsque nécessaire.

IMPORTANT - Disclaimers médicaux à inclure :
- Les informations fournies ne remplacent pas une consultation médicale professionnelle
- En cas d'urgence, contactez immédiatement les services d'urgence (15 en France)
- Consultez toujours un professionnel de santé pour un diagnostic précis
- Ne remplace pas les conseils de votre médecin traitant

Sois empathique, professionnel et rassurant dans tes réponses.
''';

  static const String _bmiSystemPrompt = '''
Tu es un assistant médical spécialisé dans l'interprétation de l'Indice de Masse Corporelle (IMC).

Fournis une interprétation claire et personnalisée de l'IMC, incluant :
1. La catégorie de l'IMC (Insuffisance pondérale, Poids normal, Surpoids, Obésité)
2. Une explication simple de ce que cela signifie
3. Des conseils personnalisés et pratiques pour améliorer la santé
4. Des recommandations générales (pas de prescriptions médicales)

Sois encourageant et positif, tout en restant factuel et professionnel.
''';

  static const String _symptomSystemPrompt = '''
Tu es un système de triage médical intelligent. Analyse les symptômes décrits et fournis :

1. Une évaluation du niveau d'urgence (low, medium, high, emergency)
2. Les causes potentielles les plus probables
3. Des conseils immédiats pour la gestion des symptômes
4. Des recommandations sur quand consulter un médecin

IMPORTANT :
- Ne pose jamais de diagnostic définitif
- En cas de symptômes graves, recommande immédiatement de consulter un médecin ou d'appeler les urgences
- Sois clair sur les limites de cette analyse
- Fournis des informations générales et éducatives uniquement
''';

  static const String _quickAdviceSystemPrompt = '''
Tu es un assistant médical pour professionnels de santé. Fournis des avis rapides et des vérifications médicales basées sur les informations fournies.

Sois concis, précis et professionnel. Inclus des références générales lorsque possible.
''';

  // Chatbot conversationnel
  static Future<String> chatWithBot({
    required String userMessage,
    List<Map<String, String>>? conversationHistory,
  }) async {
    if (!isInitialized) {
      return 'Erreur : Clé API Gemini non configurée. Veuillez configurer votre clé API dans les paramètres.';
    }

    try {
      final messages = <Map<String, dynamic>>[
        {
          'role': 'user',
          'parts': [{'text': _chatbotSystemPrompt}]
        },
      ];

      // Ajouter l'historique de conversation
      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        for (var msg in conversationHistory) {
          messages.add({
            'role': msg['role'] ?? 'user',
            'parts': [{'text': msg['content'] ?? ''}]
          });
        }
      }

      // Ajouter le message actuel
      messages.add({
        'role': 'user',
        'parts': [{'text': userMessage}]
      });

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': messages,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
        return text ?? 'Désolé, je n\'ai pas pu générer de réponse.';
      } else {
        debugPrint('Gemini API Error: ${response.statusCode} - ${response.body}');
        return 'Erreur lors de la communication avec l\'assistant IA. Veuillez réessayer.';
      }
    } catch (e) {
      debugPrint('Gemini Service Error: $e');
      return 'Une erreur est survenue. Veuillez réessayer plus tard.';
    }
  }

  // Interprétation IMC
  static Future<Map<String, String>> interpretBMI({
    required double bmi,
    required double weight,
    required double height,
  }) async {
    if (!isInitialized) {
      return {
        'interpretation': 'Clé API non configurée',
        'advice': 'Veuillez configurer votre clé API Gemini.',
      };
    }

    try {
      final prompt = '''
$_bmiSystemPrompt

IMC calculé : $bmi
Poids : ${weight}kg
Taille : ${height}m

Fournis une interprétation et des conseils personnalisés.
''';

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'role': 'user',
              'parts': [{'text': prompt}]
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String? ?? '';
        
        // Séparer l'interprétation et les conseils (approximation)
        final lines = text.split('\n');
        final interpretation = lines.take(lines.length ~/ 2).join('\n');
        final advice = lines.skip(lines.length ~/ 2).join('\n');

        return {
          'interpretation': interpretation.isNotEmpty ? interpretation : text,
          'advice': advice.isNotEmpty ? advice : text,
        };
      } else {
        return {
          'interpretation': 'Erreur lors de l\'analyse',
          'advice': 'Veuillez réessayer.',
        };
      }
    } catch (e) {
      debugPrint('BMI Interpretation Error: $e');
      return {
        'interpretation': 'Erreur lors de l\'analyse',
        'advice': 'Veuillez réessayer plus tard.',
      };
    }
  }

  // Analyse de symptômes
  static Future<Map<String, String>> analyzeSymptoms({
    required List<String> symptoms,
    String? additionalInfo,
  }) async {
    if (!isInitialized) {
      return {
        'severity': 'medium',
        'possibleCauses': 'Clé API non configurée',
        'immediateAdvice': 'Veuillez configurer votre clé API Gemini.',
      };
    }

    try {
      final symptomsText = symptoms.join(', ');
      final prompt = '''
$_symptomSystemPrompt

Symptômes décrits : $symptomsText
${additionalInfo != null ? 'Informations supplémentaires : $additionalInfo' : ''}

Fournis une analyse avec :
1. Niveau d'urgence (low, medium, high, emergency)
2. Causes potentielles
3. Conseils immédiats
''';

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'role': 'user',
              'parts': [{'text': prompt}]
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String? ?? '';
        
        // Extraire le niveau de sévérité
        String severity = 'medium';
        if (text.toLowerCase().contains('emergency') || text.toLowerCase().contains('urgence')) {
          severity = 'emergency';
        } else if (text.toLowerCase().contains('high') || text.toLowerCase().contains('élevé')) {
          severity = 'high';
        } else if (text.toLowerCase().contains('low') || text.toLowerCase().contains('faible')) {
          severity = 'low';
        }

        // Extraire les causes et conseils (approximation)
        final parts = text.split(RegExp(r'\d+\.'));
        final possibleCauses = parts.length > 1 ? parts[1].trim() : text;
        final immediateAdvice = parts.length > 2 ? parts[2].trim() : text;

        return {
          'severity': severity,
          'possibleCauses': possibleCauses,
          'immediateAdvice': immediateAdvice,
        };
      } else {
        return {
          'severity': 'medium',
          'possibleCauses': 'Erreur lors de l\'analyse',
          'immediateAdvice': 'Veuillez consulter un médecin.',
        };
      }
    } catch (e) {
      debugPrint('Symptom Analysis Error: $e');
      return {
        'severity': 'medium',
        'possibleCauses': 'Erreur lors de l\'analyse',
        'immediateAdvice': 'Veuillez consulter un médecin si les symptômes persistent.',
      };
    }
  }

  // Avis rapide pour médecins
  static Future<String> getQuickAdvice({
    required String query,
    String? context,
  }) async {
    if (!isInitialized) {
      return 'Clé API non configurée. Veuillez configurer votre clé API Gemini.';
    }

    try {
      final prompt = '''
$_quickAdviceSystemPrompt

Question : $query
${context != null ? 'Contexte : $context' : ''}

Fournis un avis rapide et professionnel.
''';

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'role': 'user',
              'parts': [{'text': prompt}]
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String? ?? 
               'Désolé, je n\'ai pas pu générer de réponse.';
      } else {
        return 'Erreur lors de la communication avec l\'assistant IA.';
      }
    } catch (e) {
      debugPrint('Quick Advice Error: $e');
      return 'Une erreur est survenue. Veuillez réessayer.';
    }
  }
}

