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
                'reply' => $this->genericReply($roleName),
                'buttons' => IntentRegistry::buttonsForRole($roleName),
            ]);
        }

        $params = (array) $request->input('params', []);
        $data = QueryExecutor::execute($intent, $localUser, $params);

        $email = (string) ($request->attributes->get('supabase_email') ?? $localUser->email ?? 'Usuario');
        $nameFromEmail = explode('@', $email)[0] ?? 'Usuario';
        $userName = (string) ($localUser->name ?: $nameFromEmail);

        $reply = GeminiFormatter::format($intent, $data, $userName, $roleName);

        return response()->json([
            'reply' => $reply,
            'intent' => $intent,
            'data' => $data,
            'buttons' => IntentRegistry::buttonsForRole($roleName),
        ]);
    }

    public function buttons(Request $request)
    {
        $localUser = $this->resolveLocalUser($request);
        $roleName = $this->resolveRoleName($request, $localUser);

        return response()->json([
            'buttons' => IntentRegistry::buttonsForRole($roleName),
        ]);
    }

    private function resolveLocalUser(Request $request): ?User
    {
        $email = (string) ($request->attributes->get('supabase_email') ?? '');
        if ($email === '') {
            return null;
        }

        return User::query()->with('role:id,name')->where('email', $email)->first();
    }

    private function resolveRoleName(Request $request, ?User $user): string
    {
        $localRole = $user?->role?->name;
        if ($localRole) {
            return (string) $localRole;
        }

        $tokenRole = mb_strtolower((string) ($request->attributes->get('supabase_role') ?? 'cliente'));

        return match ($tokenRole) {
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

    private function genericReply(string $roleName): string
    {
        return match ($roleName) {
            'coach' => 'No pude entender tu pregunta. Usa una opcion para consultar clientes, rutinas o progreso.',
            'nutriologo' => 'No pude entender tu pregunta. Usa una opcion para consultar clientes y planes nutricionales.',
            'cliente' => 'No pude entender tu pregunta. Usa una opcion para revisar tus rutinas, nutricion o contactos asignados.',
            default => 'No pude entender tu pregunta. Intenta con una de las opciones sugeridas.',
        };
    }
}
