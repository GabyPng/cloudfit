<?php

namespace App\Http\Controllers\Chatbot;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\Chatbot\GeminiFormatter;
use App\Services\Chatbot\IntentClassifier;
use App\Services\Chatbot\IntentRegistry;
use App\Services\Chatbot\QueryExecutor;
use Illuminate\Http\Request;

class ChatbotController extends Controller
{
    public function message(Request $request)
    {
        $request->validate([
            'intent' => ['nullable', 'string', 'max:100'],
            'message' => ['nullable', 'string', 'max:500'],
            'params' => ['nullable', 'array'],
            'params.client_id' => ['nullable', 'integer'],
            'params.routine_id' => ['nullable', 'integer'],
            'params.plan_id' => ['nullable', 'integer'],
            'params.search_term' => ['nullable', 'string', 'max:100'],
        ]);

        if (! $request->filled('intent') && ! $request->filled('message')) {
            return response()->json([
                'reply' => 'No entendi tu mensaje. Intenta con una opcion sugerida.',
                'buttons' => $this->getButtons($request),
            ], 400);
        }

        $localUser = $this->resolveLocalUser($request);
        if (! $localUser) {
            return response()->json([
                'reply' => 'No pude vincular tu sesion con un usuario local. Ejecuta /api/sync e intenta de nuevo.',
                'buttons' => [],
            ], 422);
        }

        $roleName = $this->resolveRoleName($request, $localUser);
        $intent = (string) $request->input('intent', '');
        if ($intent === '' && $request->filled('message')) {
            $intent = (string) IntentClassifier::classify((string) $request->input('message'), $roleName);
        }

        $allowed = IntentRegistry::forRole($roleName);
        if ($intent === '' || ! isset($allowed[$intent])) {
            return response()->json([
                'reply' => $this->genericReply($roleName, (string) $request->input('message', '')),
                'role' => $roleName,
                'buttons' => IntentRegistry::buttonsForRole($roleName),
            ]);
        }

        $params = (array) $request->input('params', []);

        try {
            $data = QueryExecutor::execute($intent, $localUser, $params);
        } catch (\Throwable $e) {
            report($e);

            return response()->json([
                'reply' => 'Ocurrió un problema al procesar esa consulta. Intenta con otra opción disponible.',
                'intent' => $intent,
                'role' => $roleName,
                'buttons' => IntentRegistry::buttonsForRole($roleName),
            ], 200);
        }

        $email = (string) ($request->attributes->get('supabase_email') ?? $localUser->email ?? 'Usuario');
        $nameFromEmail = explode('@', $email)[0] ?? 'Usuario';
        $userName = (string) ($localUser->name ?: $nameFromEmail);

        $reply = GeminiFormatter::format($intent, $data, $userName, $roleName);

        return response()->json([
            'reply' => $reply,
            'intent' => $intent,
            'role' => $roleName,
            'data' => $data,
            'buttons' => IntentRegistry::buttonsForRole($roleName),
        ]);
    }

    public function buttons(Request $request)
    {
        $localUser = $this->resolveLocalUser($request);
        $roleName = $this->resolveRoleName($request, $localUser);

        return response()->json([
            'role' => $roleName,
            'buttons' => IntentRegistry::buttonsForRole($roleName),
        ]);
    }

    private function resolveLocalUser(Request $request): ?User
    {
        $email = (string) ($request->attributes->get('supabase_email') ?? '');
        if ($email === '') {
            return null;
        }

        return User::query()->with('role:role_id,name')->where('email', $email)->first();
    }

    private function resolveRoleName(Request $request, ?User $user): string
    {
        $tokenRole = mb_strtolower((string) ($request->attributes->get('supabase_role') ?? ''));

        if (in_array($tokenRole, ['admin', 'administrador'], true)) {
            return 'admin';
        }

        if ($tokenRole === 'coach') {
            return 'coach';
        }

        if (in_array($tokenRole, ['nutriologo', 'nutriólogo'], true)) {
            return 'nutriologo';
        }

        if ($tokenRole === 'cliente') {
            return 'cliente';
        }

        $localRole = mb_strtolower((string) ($user?->role?->name ?? 'cliente'));

        return match ($localRole) {
            'administrador' => 'admin',
            'coach' => 'coach',
            'nutriologo', 'nutriólogo' => 'nutriologo',
            default => 'cliente',
        };
    }

    private function getButtons(Request $request): array
    {
        $localUser = $this->resolveLocalUser($request);
        $roleName = $this->resolveRoleName($request, $localUser);

        return IntentRegistry::buttonsForRole($roleName);
    }

    private function genericReply(string $roleName, string $message = ''): string
    {
        $hint = trim($message) !== '' ? "Tu mensaje fue: '{$message}'." : 'No pude identificar claramente tu intención.';

        return match ($roleName) {
            'coach' => $hint . " Puedo ayudarte con clientes, rutinas, progreso o búsqueda de ejercicios. Prueba con algo como: 'muéstrame mis clientes' o usa uno de los botones.",
            'nutriologo' => $hint . " Puedo ayudarte con pacientes, planes nutricionales, macros y comidas. Prueba con algo como: 'muéstrame mis pacientes' o 'ver macros del plan'.",
            'cliente' => $hint . " Puedo ayudarte con tus rutinas, tu plan nutricional, tus macros o tus especialistas asignados. Intenta reformularlo o usar los botones sugeridos.",
            default => $hint . ' Intenta con una de las opciones sugeridas para que pueda ayudarte mejor.',
        };
    }
}
