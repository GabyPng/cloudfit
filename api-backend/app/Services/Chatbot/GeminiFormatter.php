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
            return self::friendlyEmptyState($intent, (string) $data['error']);
        }

        if (empty($data)) {
            return self::friendlyEmptyState($intent);
        }

        if (is_array($data) && count($data) === 0) {
            return self::friendlyEmptyState($intent);
        }

        return self::formatStructuredPayload($intent, $data);
    }

    private static function formatStructuredPayload(string $intent, mixed $data): string
    {
        if (is_array($data) && (isset($data['routine']) || isset($data['exercises']))) {
            return self::formatRoutinePayload($data);
        }

        if (is_array($data) && (isset($data['plan']) || isset($data['meals']))) {
            return self::formatPlanPayload($data);
        }

        if (is_array($data) && isset($data['total_routines'])) {
            return self::formatProgressPayload($data);
        }

        if (is_array($data) && array_is_list($data)) {
            return self::formatListPayload($intent, $data);
        }

        if (is_object($data) || is_array($data)) {
            return self::formatObjectPayload($intent, $data);
        }

        return 'Aquí está la información que encontré para ti.';
    }

    private static function formatListPayload(string $intent, array $items): string
    {
        $intro = match ($intent) {
            'coach.client_list' => 'Estos son tus clientes:',
            'nutri.client_list' => 'Estos son tus pacientes:',
            'coach.client_routines', 'client.my_routines' => 'Estas son las rutinas encontradas:',
            'nutri.client_plans' => 'Estos son los planes disponibles:',
            'nutri.meal_detail', 'client.my_meals' => 'Estas son las comidas del plan:',
            'coach.exercise_search' => 'Estos ejercicios coinciden con tu búsqueda:',
            default => 'Esto es lo que encontré:',
        };

        $lines = [];

        foreach (array_slice($items, 0, 10) as $item) {
            $name = data_get($item, 'name')
                ?? data_get($item, 'title')
                ?? data_get($item, 'exercise_name')
                ?? data_get($item, 'meal_type')
                ?? 'Elemento';

            $details = array_filter([
                data_get($item, 'email'),
                data_get($item, 'goal'),
                data_get($item, 'status'),
                data_get($item, 'portion'),
                data_get($item, 'daily_calories') ? data_get($item, 'daily_calories') . ' kcal' : null,
                data_get($item, 'reps') ? ((data_get($item, 'sets') ?? '?') . ' series x ' . data_get($item, 'reps') . ' reps') : null,
            ]);

            $lines[] = '• ' . $name . (! empty($details) ? ' — ' . implode(' | ', $details) : '');
        }

        return trim($intro . "\n" . implode("\n", $lines));
    }

    private static function formatRoutinePayload(array $data): string
    {
        $routineName = (string) (data_get($data, 'routine.name') ?? 'Rutina');
        $description = (string) (data_get($data, 'routine.description') ?? '');
        $exercises = data_get($data, 'exercises', []);

        $lines = ["Detalle de la rutina: {$routineName}"];

        if ($description !== '') {
            $lines[] = $description;
        }

        if (is_array($exercises) && count($exercises) > 0) {
            $lines[] = 'Ejercicios:';
            foreach ($exercises as $exercise) {
                $lines[] = '• ' . (data_get($exercise, 'exercise_name') ?? 'Ejercicio')
                    . ' — ' . (data_get($exercise, 'sets') ?? '?') . ' series x ' . (data_get($exercise, 'reps') ?? '?')
                    . (data_get($exercise, 'rest_time') ? ' | Descanso: ' . data_get($exercise, 'rest_time') : '');
            }
        }

        return implode("\n", $lines);
    }

    private static function formatPlanPayload(array $data): string
    {
        $title = (string) (data_get($data, 'plan.title') ?? 'Plan nutricional');
        $goal = data_get($data, 'plan.goal');
        $meals = data_get($data, 'meals', []);

        $lines = ["Detalle del plan: {$title}"];

        if ($goal) {
            $lines[] = 'Objetivo: ' . $goal;
        }

        if (is_array($meals) && count($meals) > 0) {
            $lines[] = 'Comidas:';
            foreach ($meals as $meal) {
                $lines[] = '• ' . (data_get($meal, 'meal_type') ?? 'Comida') . ': ' . (data_get($meal, 'name') ?? 'Sin nombre')
                    . (data_get($meal, 'portion') ? ' (' . data_get($meal, 'portion') . ')' : '')
                    . (data_get($meal, 'calories') ? ' - ' . data_get($meal, 'calories') . ' kcal' : '');
            }
        }

        return implode("\n", $lines);
    }

    private static function formatProgressPayload(array $data): string
    {
        return implode("\n", [
            'Resumen de progreso del cliente:',
            '• Rutinas totales: ' . (data_get($data, 'total_routines') ?? 0),
            '• Rutinas activas: ' . (data_get($data, 'active_routines') ?? 0),
            '• Rutinas inactivas: ' . (data_get($data, 'inactive_routines') ?? 0),
        ]);
    }

    private static function formatObjectPayload(string $intent, mixed $data): string
    {
        $dailyCalories = data_get($data, 'daily_calories');
        $macroTargets = data_get($data, 'macro_targets');

        if ($dailyCalories || $macroTargets) {
            if (is_string($macroTargets)) {
                $decoded = json_decode($macroTargets, true);
                if (json_last_error() === JSON_ERROR_NONE) {
                    $macroTargets = $decoded;
                }
            }

            $title = (string) (data_get($data, 'title') ?? 'Plan nutricional');
            $lines = ["Resumen del plan: {$title}"];

            if ($dailyCalories) {
                $lines[] = '• Calorías diarias: ' . $dailyCalories . ' kcal';
            }

            if (is_array($macroTargets)) {
                if (isset($macroTargets['protein'])) {
                    $lines[] = '• Proteína: ' . $macroTargets['protein'] . ' g';
                }
                if (isset($macroTargets['carbs'])) {
                    $lines[] = '• Carbohidratos: ' . $macroTargets['carbs'] . ' g';
                }
                if (isset($macroTargets['fat'])) {
                    $lines[] = '• Grasas: ' . $macroTargets['fat'] . ' g';
                }
            }

            if (data_get($data, 'goal')) {
                $lines[] = '• Objetivo: ' . data_get($data, 'goal');
            }

            return implode("\n", $lines);
        }

        $name = data_get($data, 'name') ?? data_get($data, 'title') ?? 'Resultado encontrado';
        $details = array_filter([
            data_get($data, 'email'),
            data_get($data, 'focus'),
            data_get($data, 'goal'),
            data_get($data, 'status'),
        ]);

        return $name . (! empty($details) ? "\n• " . implode("\n• ", $details) : '');
    }

    private static function friendlyEmptyState(string $intent, string $error = ''): string
    {
        $base = match ($intent) {
            'coach.client_list' => 'Aún no encontré clientes asignados a tu cuenta.',
            'coach.client_routines', 'client.my_routines' => 'No encontré rutinas disponibles en este momento.',
            'coach.client_progress' => 'Todavía no hay suficiente información de progreso para mostrar.',
            'coach.exercise_search' => 'No encontré ejercicios que coincidan con esa búsqueda.',
            'nutri.client_list' => 'Aún no encontré pacientes asignados a tu perfil.',
            'nutri.client_plans', 'nutri.client_active_plan', 'client.my_nutrition' => 'No encontré planes nutricionales disponibles por ahora.',
            'nutri.plan_detail', 'nutri.plan_macros', 'nutri.meal_detail', 'client.my_meals', 'client.my_macros' => 'No encontré detalles suficientes para ese plan o sus comidas.',
            'client.my_coach' => 'Todavía no tienes un coach asignado.',
            'client.my_nutri' => 'Todavía no tienes un nutriólogo asignado.',
            default => 'No encontré información para esa consulta en este momento.',
        };

        if ($error !== '') {
            return $base . ' ' . $error . ' Puedes intentar con otra opción o reformular tu consulta.';
        }

        return $base . ' Puedes intentar con otra opción o reformular tu consulta.';
    }
}
