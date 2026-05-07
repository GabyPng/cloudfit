<?php

namespace App\Http\Controllers\Cliente;

use App\Http\Controllers\Controller;
use App\Models\Message;
use App\Models\Ticket;
use App\Models\User;
use Illuminate\Http\Request;

class ClienteTicketController extends Controller
{
    private function currentUserId(Request $request): ?int
    {
        $email = $request->attributes->get('supabase_email');
        if (!$email) return null;
        return User::where('email', $email)->value('user_id');
    }

    public function index(Request $request)
    {
        $userId  = $this->currentUserId($request);
        $tickets = Ticket::where('user_id', $userId)
            ->orderByDesc('created_at')
            ->get()
            ->map(fn ($t) => [
                'ticket_id'  => $t->ticket_id,
                'subject'    => $t->subject,
                'status'     => $t->status,
                'category'   => $t->category,
                'urgency'    => $t->urgency,
                'created_at' => $t->created_at?->toISOString(),
            ]);

        return response()->json(['data' => $tickets]);
    }

    public function store(Request $request)
    {
        $userId = $this->currentUserId($request);
        if (!$userId) return response()->json(['error' => 'No autenticado'], 401);

        $validated = $request->validate([
            'subject'  => 'required|string|max:255',
            'category' => 'required|in:bug,duda,sugerencia',
            'urgency'  => 'required|in:baja,media,alta',
            'message'  => 'required|string|max:2000',
        ]);

        $ticket = Ticket::create([
            'user_id'  => $userId,
            'subject'  => $validated['subject'],
            'category' => $validated['category'],
            'urgency'  => $validated['urgency'],
            'status'   => 'open',
        ]);

        Message::create([
            'ticket_id' => $ticket->ticket_id,
            'sender_id' => $userId,
            'content'   => $validated['message'],
            'sent_at'   => now(),
        ]);

        return response()->json(['message' => 'Ticket creado.', 'ticket_id' => $ticket->ticket_id], 201);
    }

    public function show(Request $request, int $ticketId)
    {
        $userId = $this->currentUserId($request);
        $ticket = Ticket::with([
            'messages.sender:user_id,name,avatar_url',
        ])->where('ticket_id', $ticketId)->where('user_id', $userId)->firstOrFail();

        return response()->json([
            'data' => [
                'ticket_id'  => $ticket->ticket_id,
                'subject'    => $ticket->subject,
                'status'     => $ticket->status,
                'category'   => $ticket->category,
                'urgency'    => $ticket->urgency,
                'created_at' => $ticket->created_at?->toISOString(),
                'messages'   => $ticket->messages->map(fn ($m) => [
                    'message_id'  => $m->message_id,
                    'sender_id'   => $m->sender_id,
                    'sender_name' => $m->sender?->name,
                    'content'     => $m->content,
                    'sent_at'     => $m->sent_at?->toISOString(),
                ]),
            ],
        ]);
    }

    public function reply(Request $request, int $ticketId)
    {
        $userId = $this->currentUserId($request);
        $ticket = Ticket::where('ticket_id', $ticketId)->where('user_id', $userId)->firstOrFail();

        $validated = $request->validate(['content' => 'required|string|max:2000']);

        $message = Message::create([
            'ticket_id' => $ticket->ticket_id,
            'sender_id' => $userId,
            'content'   => $validated['content'],
            'sent_at'   => now(),
        ]);

        return response()->json(['message' => 'Respuesta enviada.', 'data' => $message]);
    }
}
