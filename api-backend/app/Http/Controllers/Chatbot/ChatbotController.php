<?php

namespace App\Http\Controllers\Chatbot;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class ChatbotController extends Controller
{
    // Gemini REST endpoint (v1beta)
    private const GEMINI_URL = 'https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent';

    public function __construct() {}

    /**
     * POST /api/chatbot/message
     * Body: { "message": "..." }
     * Auth: supabase.auth middleware (todos los roles)
     */
    public function message(Request $request)
    {
        $request->validate(['message' => 'required|string|max:500']);

        $userMessage = trim($request->input('message'));
        $role        = strtoupper($request->attributes->get('supabase_role') ?? 'CLIENTE');
        $idToken     = $request->attributes->get('supabase_token');
        $email       = $request->attributes->get('supabase_email') ?? '';
        $nombre      = explode('@', $email)[0];

        // Intenta usar Gemini; si no está habilitado/configurado, usa reglas
        $reply = $this->geminiEnabled()
            ? $this->geminiReply($userMessage, $role, $idToken, $nombre)
            : $this->ruleBasedReply(mb_strtolower($userMessage), $role, $idToken, $nombre);

        return response()->json(['reply' => $reply, 'role' => $role]);
    }

    // GEMINI

    private function geminiEnabled(): bool
    {
        return (bool) config('gemini.enabled', false)
            && ! empty(config('gemini.api_key'));
    }

    private function geminiReply(string $msg, string $role, ?string $idToken, string $nombre): string
    {
        $contextData  = $this->buildUserContext($role, $idToken);
        $systemPrompt = $this->systemPrompt($nombre, $role, $contextData);

        $apiKey = config('gemini.api_key');
        $model  = config('gemini.model', 'gemini-2.0-flash');
        $url    = str_replace('{model}', $model, self::GEMINI_URL);

        try {
            $response = Http::timeout(15)
                ->withQueryParameters(['key' => $apiKey])
                ->post($url, [
                    'system_instruction' => [
                        'parts' => [['text' => $systemPrompt]],
                    ],
                    'contents' => [
                        ['role' => 'user', 'parts' => [['text' => $msg]]],
                    ],
                    'generationConfig' => [
                        'temperature'     => 0.7,
                        'maxOutputTokens' => 512,
                        'topP'            => 0.9,
                    ],
                    'safetySettings' => [
                        ['category' => 'HARM_CATEGORY_HARASSMENT',       'threshold' => 'BLOCK_ONLY_HIGH'],
                        ['category' => 'HARM_CATEGORY_HATE_SPEECH',       'threshold' => 'BLOCK_ONLY_HIGH'],
                        ['category' => 'HARM_CATEGORY_SEXUALLY_EXPLICIT', 'threshold' => 'BLOCK_ONLY_HIGH'],
                        ['category' => 'HARM_CATEGORY_DANGEROUS_CONTENT', 'threshold' => 'BLOCK_ONLY_HIGH'],
                    ],
                ]);

            if ($response->successful()) {
                $text = $response->json('candidates.0.content.parts.0.text');
                if ($text) return trim($text);
            }

            \Log::warning('Gemini no devolvió respuesta. Body: ' . $response->body());
        } catch (\Exception $e) {
            \Log::warning('Gemini API error: ' . $e->getMessage());
        }

        // Fallback a reglas si Gemini falla
        return $this->ruleBasedReply(mb_strtolower($msg), $role, $idToken, $nombre);
    }

    // El promt 
    private function systemPrompt(string $nombre, string $role, string $contextData): string
    {
        $rolLabel = match($role) {
            'ADMINISTRADOR' => 'Administrador',
            'COACH'         => 'Coach',
            'NUTRIOLOGO'    => 'Nutriólogo',
            'CLIENTE'       => 'Cliente',
            default         => 'Usuario',
        };

        return <<<PROMPT
Eres el asistente virtual de CloudFit, una plataforma de fitness y nutrición personalizada.
Eres amigable, motivador, profesional y siempre respondes en español.
Usas emojis con moderación. Tus respuestas son concisas (máximo 3-4 párrafos cortos).

USUARIO ACTUAL:
- Nombre: {$nombre}
- Rol: {$rolLabel}

DATOS DEL USUARIO:
{$contextData}

PLATAFORMA CloudFit:
- Roles: Administrador, Coach, Nutriólogo, Cliente
- Funcionalidades: rutinas de ejercicio, planes nutricionales, registro de progreso (peso/IMC), tickets de soporte
- Los planes de entrenamiento los crea el coach; los nutricionales los crea el nutriólogo
- El cliente puede ver su progreso, rutinas y plan nutricional desde su panel

REGLAS:
1. Solo responde sobre CloudFit, fitness, nutrición o salud general.
2. Si preguntan algo fuera del tema, redirige amablemente hacia CloudFit.
3. No inventes datos del usuario. Si no tienes datos reales en DATOS DEL USUARIO, dilo.
4. No des consejos médicos específicos. Remite al nutriólogo o coach para consultas especializadas.
5. Si el usuario pregunta por su progreso, rutina o plan, muestra los datos de DATOS DEL USUARIO.
PROMPT;
    }

    /**
     * Carga datos reales del usuario desde la base de datos para enriquecer el prompt de Gemini.
     */
    private function buildUserContext(string $role, ?string $idToken): string
    {
        if (! $idToken) return 'No hay datos disponibles (sin sesión activa).';

        $parts = [];

        if ($role === 'CLIENTE') {
            $parts[] = 'Aún no has sincronizado tu progreso/rutinas reales desde Supabase.';
        }

        if (in_array($role, ['COACH', 'NUTRIOLOGO'])) {
            $parts[] = 'Aún no tienes clientes asignados.';
        }

        return empty($parts) ? 'Sin datos específicos.' : implode("\n", $parts);
    }

    // Comportamiento sin ia

    private function ruleBasedReply(string $msg, string $role, ?string $idToken, string $nombre): string
    {
        if ($this->matches($msg, ['hola','hi','buenas','hey','saludos','buenos días','buenas tardes','buenas noches']))
            return $this->greeting($role, $nombre);

        if ($this->matches($msg, ['ayuda','help','opciones','menú','menu','comandos','qué puedes']))
            return $this->helpMessage($role);

        if ($this->matches($msg, ['progreso','peso','imc','avance','medidas','registro'])) {
            return $role === 'CLIENTE'
                ? $this->progresoCliente($idToken)
                : '📊 El progreso lo consultan los clientes en su panel. Como ' . $role . ', revisa el panel de tus clientes.';
        }

        if ($this->matches($msg, ['rutina','entrenamiento','ejercicio','workout','gym','series','repeticiones'])) {
            if ($role === 'CLIENTE') return $this->rutinaCliente($idToken);
            if ($role === 'COACH')   return '🏋️ Gestiona las rutinas en tu panel → *Mis Clientes → Rutinas*.';
            return '🏋️ Tu coach asigna las rutinas. Revisa tu panel.';
        }

        if ($this->matches($msg, ['nutri','dieta','alimenta','comida','calorías','calorias','plan nutricional'])) {
            if ($role === 'CLIENTE')    return $this->planNutricional($idToken);
            if ($role === 'NUTRIOLOGO') return '🥗 Gestiona los planes nutricionales en tu panel.';
            return '🥗 Tu nutriólogo asigna tu plan. Revísalo en tu panel.';
        }

        if ($this->matches($msg, ['ticket','soporte','problema','error','falla','reporte']))
            return $this->soporteInfo();

        if ($this->matches($msg, ['objetivo','meta','goal','bajar peso','subir peso','ganar músculo','perder grasa']))
            return '🎯 Habla con tu coach o nutriólogo para ajustar tus metas. Ellos actualizarán tu plan.';

        if ($this->matches($msg, ['adiós','adios','bye','hasta luego','chao','chau']))
            return "👋 ¡Hasta pronto, {$nombre}! Cada día es una oportunidad para mejorar. 💪";

        return $this->fallback();
    }

    private function greeting(string $role, string $nombre): string
    {
        $hora = now()->format('H');
        $saludo = match(true) {
            $hora >= 5  && $hora < 12 => '¡Buenos días',
            $hora >= 12 && $hora < 19 => '¡Buenas tardes',
            default                    => '¡Buenas noches',
        };
        $rolLabel = match($role) {
            'ADMINISTRADOR' => 'Administrador', 'COACH' => 'Coach',
            'NUTRIOLOGO'    => 'Nutriólogo',    'CLIENTE' => 'Cliente', default => 'Usuario',
        };
        $extra = match($role) {
            'CLIENTE'       => 'Pregúntame sobre tu *progreso*, *rutina*, *plan nutricional* o *soporte*.',
            'COACH'         => 'Pregúntame sobre tus *clientes*, *rutinas* o el *soporte*.',
            'NUTRIOLOGO'    => 'Pregúntame sobre tus *clientes*, *planes nutricionales* o el *soporte*.',
            'ADMINISTRADOR' => 'Tienes acceso completo. ¿En qué te ayudo?',
            default         => 'Escribe *ayuda* para ver opciones.',
        };
        return "{$saludo}, {$nombre}! ({$rolLabel}) 💪\n\nSoy el asistente de CloudFit. {$extra}";
    }

    private function helpMessage(string $role): string
    {
        $base   = "🤖 *CloudFit Assistant* — Comandos:\n\n";
        $common = "• *soporte* — abrir un ticket\n• *adiós* — despedirme\n";
        return match($role) {
            'CLIENTE'    => $base . "• *progreso* · *rutina* · *nutrición*\n• *objetivo* · *plan*\n" . $common,
            'COACH'      => $base . "• *clientes* · *rutina*\n" . $common,
            'NUTRIOLOGO' => $base . "• *clientes* · *nutrición*\n" . $common,
            default      => $base . $common,
        };
    }

    private function progresoCliente(?string $idToken): string
    {
        return '📊 Aún no tienes registros de progreso. ¡Revisa tu panel pronto!';
    }

    private function rutinaCliente(?string $idToken): string
    {
        return '🏋️ Aún no tienes rutina asignada. Tu coach la configurará pronto.';
    }

    private function planNutricional(?string $idToken): string
    {
        return '🥗 Aún no tienes plan nutricional. Tu nutriólogo lo creará pronto.';
    }

    private function soporteInfo(): string
    {
        return "🎫 *Soporte CloudFit:*\n\n1. Ve a tu panel\n2. Sección *Soporte* → *Nuevo Ticket*\n3. Describe tu problema y envíalo\n\nEl equipo responderá lo antes posible. 🛠️";
    }

    private function fallback(): string
    {
        return "🤔 No entendí tu mensaje. Prueba:\n\n• *hola* · *progreso* · *rutina*\n• *nutrición* · *soporte* · *ayuda*";
    }

    private function matches(string $msg, array $keywords): bool
    {
        foreach ($keywords as $kw) {
            if (str_contains($msg, $kw)) return true;
        }
        return false;
    }
}
