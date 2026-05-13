<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Message;
use App\Models\Ticket;
use App\Models\User;
use Illuminate\Http\Request;

class TicketController extends Controller
{
    private function adminUserId(Request $request): ?int
    {
        $email = $request->attributes->get('supabase_email');
        if (! $email) {
            return null;
        }

        return User::where('email', $email)->value('user_id');
    }

    public function index(Request $request)
    {
        $status = $request->query('status');
        $category = $request->query('category');
        $urgency = $request->query('urgency');

        $tickets = Ticket::with('user:user_id,name,email,avatar_url')
            ->when($status, fn ($q) => $q->where('status', $status))
            ->when($category, fn ($q) => $q->where('category', $category))
            ->when($urgency, fn ($q) => $q->where('urgency', $urgency))
            ->orderByDesc('created_at')
            ->paginate(20);

        return response()->json([
            'data' => $tickets->map(fn ($t) => $this->formatTicket($t)),
            'meta' => [
                'current_page' => $tickets->currentPage(),
                'last_page' => $tickets->lastPage(),
                'total' => $tickets->total(),
            ],
        ]);
    }

    public function show(int $ticketId)
    {
        $ticket = Ticket::with([
            'user:user_id,name,email,avatar_url',
            'messages.sender:user_id,name,avatar_url',
        ])->findOrFail($ticketId);

        return response()->json(['data' => $this->formatTicket($ticket, withMessages: true)]);
    }

    public function updateStatus(Request $request, int $ticketId)
    {
        $validated = $request->validate([
            'status' => 'required|in:open,in_progress,resolved,closed',
        ]);

        $ticket = Ticket::findOrFail($ticketId);
        $ticket->update([
            'status' => $validated['status'],
            'resolved_at' => in_array($validated['status'], ['resolved', 'closed']) ? now() : null,
        ]);

        return response()->json(['message' => 'Estado actualizado.', 'data' => $this->formatTicket($ticket)]);
    }

    public function reply(Request $request, int $ticketId)
    {
        $validated = $request->validate([
            'content' => 'required|string|max:2000',
        ]);

        $adminId = $this->adminUserId($request);
        $ticket = Ticket::findOrFail($ticketId);

        $message = Message::create([
            'ticket_id' => $ticket->ticket_id,
            'sender_id' => $adminId,
            'content' => $validated['content'],
            'sent_at' => now(),
        ]);

        if ($ticket->status === 'open') {
            $ticket->update(['status' => 'in_progress']);
        }

        return response()->json(['message' => 'Respuesta enviada.', 'data' => $message]);
    }

    private function formatTicket(Ticket $ticket, bool $withMessages = false): array
    {
        $result = [
            'ticket_id' => $ticket->ticket_id,
            'subject' => $ticket->subject,
            'status' => $ticket->status,
            'category' => $ticket->category,
            'urgency' => $ticket->urgency,
            'resolved_at' => $ticket->resolved_at?->toISOString(),
            'created_at' => $ticket->created_at?->toISOString(),
            'user_id' => $ticket->user_id,
            'user_name' => $ticket->user?->name,
            'user_email' => $ticket->user?->email,
            'user_avatar' => $ticket->user?->avatar_url,
        ];

        if ($withMessages) {
            $result['messages'] = $ticket->messages->map(fn ($m) => [
                'message_id' => $m->message_id,
                'sender_id' => $m->sender_id,
                'sender_name' => $m->sender?->name,
                'content' => $m->content,
                'sent_at' => $m->sent_at?->toISOString(),
            ]);
        }

        return $result;
    }
}
