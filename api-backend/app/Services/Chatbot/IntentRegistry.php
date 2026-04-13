<?php

namespace App\Services\Chatbot;

class IntentRegistry
{
    /**
     * @return array<string, array<string, mixed>>
     */
    public static function forRole(string $roleName): array
    {
        $role = mb_strtolower(trim($roleName));

        $intents = [
            'coach' => [
                'coach.client_list' => [
                    'label' => '¿Quiénes son mis clientes?',
                    'keywords' => ['clientes', 'mis clientes', 'lista clientes', 'quienes'],
                    'requires' => [],
                ],
                'coach.client_routines' => [
                    'label' => '¿Qué rutinas tiene mi cliente?',
                    'keywords' => ['rutinas', 'rutina cliente', 'entrenamiento'],
                    'requires' => ['client_id'],
                ],
                'coach.routine_detail' => [
                    'label' => 'Detalle de una rutina',
                    'keywords' => ['detalle rutina', 'ejercicios rutina', 'ver rutina'],
                    'requires' => ['routine_id'],
                ],
                'coach.client_progress' => [
                    'label' => '¿Cómo va el progreso de mi cliente?',
                    'keywords' => ['progreso', 'avance', 'como va'],
                    'requires' => ['client_id'],
                ],
                'coach.exercise_search' => [
                    'label' => 'Buscar un ejercicio',
                    'keywords' => ['buscar ejercicio', 'ejercicio', 'musculo'],
                    'requires' => ['search_term'],
                ],
            ],
            'nutriologo' => [
                'nutri.client_list' => [
                    'label' => '¿Quiénes son mis clientes?',
                    'keywords' => ['clientes', 'mis clientes', 'pacientes'],
                    'requires' => [],
                ],
                'nutri.client_plans' => [
                    'label' => '¿Qué planes tiene mi cliente?',
                    'keywords' => ['planes', 'plan cliente', 'plan nutricional'],
                    'requires' => ['client_id'],
                ],
                'nutri.plan_detail' => [
                    'label' => 'Detalle de un plan nutricional',
                    'keywords' => ['detalle plan', 'ver plan', 'informacion plan'],
                    'requires' => ['plan_id'],
                ],
                'nutri.plan_macros' => [
                    'label' => 'Macros de un plan',
                    'keywords' => ['macros', 'calorias', 'proteina', 'carbohidratos'],
                    'requires' => ['plan_id'],
                ],
                'nutri.client_active_plan' => [
                    'label' => '¿Cuál es el plan activo de mi cliente?',
                    'keywords' => ['plan activo', 'plan actual', 'plan vigente'],
                    'requires' => ['client_id'],
                ],
                'nutri.meal_detail' => [
                    'label' => 'Comidas de un plan',
                    'keywords' => ['comidas', 'alimentos', 'meals', 'menu'],
                    'requires' => ['plan_id'],
                ],
            ],
            'cliente' => [
                'client.my_routines' => [
                    'label' => '¿Cuáles son mis rutinas?',
                    'keywords' => ['mis rutinas', 'rutinas', 'entrenamiento', 'ejercicios'],
                    'requires' => [],
                ],
                'client.routine_detail' => [
                    'label' => 'Detalle de mi rutina',
                    'keywords' => ['detalle rutina', 'ver rutina', 'ejercicios de'],
                    'requires' => ['routine_id'],
                ],
                'client.my_nutrition' => [
                    'label' => '¿Cuál es mi plan de nutrición?',
                    'keywords' => ['nutricion', 'dieta', 'plan alimenticio', 'plan nutricional'],
                    'requires' => [],
                ],
                'client.my_meals' => [
                    'label' => '¿Qué comidas tiene mi plan?',
                    'keywords' => ['comidas', 'alimentos', 'que comer', 'menu'],
                    'requires' => [],
                ],
                'client.my_macros' => [
                    'label' => '¿Cuáles son mis macros diarios?',
                    'keywords' => ['macros', 'calorias', 'proteina', 'carbohidratos'],
                    'requires' => [],
                ],
                'client.my_coach' => [
                    'label' => '¿Quién es mi coach?',
                    'keywords' => ['mi coach', 'entrenador', 'quien me entrena'],
                    'requires' => [],
                ],
                'client.my_nutri' => [
                    'label' => '¿Quién es mi nutriólogo?',
                    'keywords' => ['mi nutriologo', 'nutricionista', 'quien lleva mi dieta'],
                    'requires' => [],
                ],
                'client.general_tip' => [
                    'label' => 'Dame un tip de salud',
                    'keywords' => ['tip', 'consejo', 'recomendacion', 'sugerencia'],
                    'requires' => [],
                ],
            ],
        ];

        return $intents[$role] ?? [];
    }

    /**
     * @return array<int, array{intent: string, label: string}>
     */
    public static function buttonsForRole(string $roleName): array
    {
        $buttons = [];

        foreach (self::forRole($roleName) as $intent => $config) {
            $buttons[] = [
                'intent' => $intent,
                'label' => (string) ($config['label'] ?? $intent),
            ];
        }

        return $buttons;
    }
}
