import 'package:proposal_writer/core/constants.dart';

class EnvConfig {
  const EnvConfig({
    required this.apiKey,
    required this.model,
    required this.baseUrl,
    required this.mockApi,
  });

  factory EnvConfig.fromEnvironment({Map<String, String> dotenv = const {}}) {
    const apiKeyDefine = String.fromEnvironment('OPENAI_API_KEY');
    const modelDefine = String.fromEnvironment('OPENAI_MODEL');
    const baseUrlDefine = String.fromEnvironment('OPENAI_BASE_URL');
    const mockDefine = bool.fromEnvironment('MOCK_API');

    final apiKey = apiKeyDefine.isNotEmpty
        ? apiKeyDefine
        : (dotenv['OPENAI_API_KEY'] ?? '');
    final model = modelDefine.isNotEmpty
        ? modelDefine
        : (dotenv['OPENAI_MODEL'] ?? defaultOpenAiModel);
    final baseUrlValue = baseUrlDefine.isNotEmpty
        ? baseUrlDefine
        : (dotenv['OPENAI_BASE_URL'] ?? defaultOpenAiBaseUrl);
    final mockApi = mockDefine || (dotenv['MOCK_API']?.toLowerCase() == 'true');

    return EnvConfig(
      apiKey: apiKey,
      model: model,
      baseUrl: Uri.parse(baseUrlValue),
      mockApi: mockApi,
    );
  }

  final String apiKey;
  final String model;
  final Uri baseUrl;
  final bool mockApi;
}
