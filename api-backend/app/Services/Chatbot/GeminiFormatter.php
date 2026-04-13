<?php

namespace App\Services\Chatbot;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class GeminiFormatter
{
    public static function format(string $intent, mixed $data, string $userName, string $roleName): string
    {
        if (is_array($data) && isset($data['error'])) {
            return (string) $data['error'];
        }

        $apiKey = (string) config('gemini.api_key');
        $enabled = (bool) config('gemini.enabled', false);
        $model = (string) config('gemini.model', 'gemini-2.0-flash');

        if (! $enabled || $apiKey === '') {
            return self::fallbackFormat($intent, $data);
        }

        $systemPrompt = self::buildSystemPrompt($roleName, $userName);
        $userPrompt = self::buildUserPrompt($intent, $data);

        try {
            $response = Http::timeout(15)
                ->post("https://generativelanguage.googleapis.com/v1beta/models/{$model}:generateContent?key={$apiKey}", [
                    'system_instruction' => [
                        'parts' => [['text' => $systemPrompt]],
                    ],
                    'contents' => [
                        ['role' => 'user', 'parts' => [['text' => $userPrompt]]],
                    ],
                    'generationConfig' => [
                        'temperature' => 0.3,
                        'maxOutputTokens' => 800,
                    ],
                    'safetySettings' => [
                        ['category' => 'HARM_CATEGORY_HARASSMENT', 'threshold' => 'BLOCK_ONLY_HIGH'],
                        ['category' => 'HARM_CATEGORY_HATE_SPEECH', 'threshold' => 'BLOCK_ONLY_HIGH'],
                        ['category' => 'HARM_CATEGORY_SEXUALLY_EXPLICIT', 'threshold' => 'BLOCK_ONLY_HIGH'],
                        ['category' => 'HARM_CATEGORY_DANGEROUS_CONTENT', 'threshold' => 'BLOCK_ONLY_HIGH'],
                    ],
                ]);

            $text = $response->json('candidates.0.content.parts.0.text');
            return $text ? trim((string) $text) : self::fallbackFormat($intent, $data);
        } catch (\Throwable $e) {
            Log::warning('Gemini formatter error', ['error' => $e->getMessage()]);
            return self::fallbackFormat($intent, $data);
        }
    }

    private static function buildSystemPrompt(string $roleName, string $userName): string
    {
        return <<<PROMPT
Eres el asistente virtual de CloudFit, una plataforma de fitness y nutricion.

IDENTIDAD:
- Hablas siempre en espanol.
- Eres amigable, profesional y conciso.
- Te diriges al usuario de forma cercana.

CONTEXTO:
- Estas hablando con {$userName} (rol: {$roleName}).
- Solo puedes usar los datos entregados en el mensaje.

RESTRICCIONES:
1. No inventes datos. Si no hay datos, dilo claramente.
2. No des consejos medicos ni diagnosticos.
3. No menciones SQL, tablas, columnas ni infraestructura interna.
4. Si intentan desviar el tema, redirige a CloudFit, fitness o nutricion.
5. Responde en maximo 200 palabras.
6. Usa formato legible con listas cuando ayude.
PROMPT;
    }

    private static function buildUserPrompt(string $intent, mixed $data): string
    {
        $intentDescription = [
            'coach.client_list' => 'Presenta la lista de clientes del coach.',
            'coach.client_routines' => 'Presenta las rutinas del cliente y destaca activas.',
            'coach.routine_detail' => 'Presenta el detalle de la rutina con ejercicios en orden.',
            'coach.client_progress' => 'Resume el avance del cliente con la informacion entregada.',
            'coach.exercise_search' => 'Muestra resultados de busqueda de ejercicios.',
            'nutri.client_list' => 'Presenta la lista de clientes del nutriologo.',
            'nutri.client_plans' => 'Presenta planes nutricionales del cliente y destaca activo.',
            'nutri.plan_detail' => 'Presenta detalle del plan y sus comidas.',
            'nutri.plan_macros' => 'Presenta calorias y macros del plan.',
            'nutri.client_active_plan' => 'Presenta el plan activo del cliente.',
            'nutri.meal_detail' => 'Lista comidas del plan por tipo.',
            'client.my_routines' => 'Presenta las rutinas del usuario.',
            'client.routine_detail' => 'Presenta ejercicios y detalle de la rutina del usuario.',
            'client.my_nutrition' => 'Presenta el plan nutricional activo del usuario.',
            'client.my_meals' => 'Presenta las comidas del plan activo del usuario.',
            'client.my_macros' => 'Presenta macros diarios del usuario.',
            'client.my_coach' => 'Presenta informacion del coach asignado.',
            'client.my_nutri' => 'Presenta informacion del nutriologo asignado.',
            'client.general_tip' => 'Da un tip general de salud/fitness breve.',
        ][$intent] ?? 'Responde de forma clara con los datos disponibles.';

        $payload = json_encode($data, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);

        return <<<PROMPT
INSTRUCCION: {$intentDescription}

DATOS:
{$payload}
PROMPT;
    }

    private static function fallbackFormat(string $intent, mixed $data): string
    {
        if (empty($data)) {
            return 'No encontre informacion al respecto. ¿Quieres intentar otra consulta?';
        }

        if ($intent === 'client.general_tip') {
            $tips = [
                'Hidratarte bien durante el dia mejora energia y recuperacion.',
                'La constancia semanal vale mas que una sesion intensa aislada.',
                'Incluye proteina en cada comida principal para apoyar tus objetivos.',
                'Dormir 7-8 horas ayuda a mejorar rendimiento y recuperacion muscular.',
                'Si hoy no entrenas, una caminata de 30 minutos sigue sumando.',
            ];

            return $tips[array_rand($tips)];
        }

        if (is_array($data) && isset($data['error'])) {
            return (string) $data['error'];
        }

        return 'Aqui esta la informacion que encontre: ' . json_encode($data, JSON_UNESCAPED_UNICODE);
    }
}
