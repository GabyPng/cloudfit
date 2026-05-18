<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Only add indexes that don't already exist
        $this->addIndexIfMissing('users', ['email'], 'users_email_idx');
        $this->addIndexIfMissing('users', ['role_id'], 'users_role_id_idx');
        $this->addIndexIfMissing('workout_logs', ['client_id', 'date'], 'workout_logs_client_date_idx');
        $this->addIndexIfMissing('tickets', ['user_id', 'status'], 'tickets_user_status_idx');
        $this->addIndexIfMissing('messages', ['ticket_id', 'sent_at'], 'messages_ticket_sent_idx');
        $this->addIndexIfMissing('coaches', ['is_verified'], 'coaches_is_verified_idx');
        $this->addIndexIfMissing('nutriologos', ['is_verified'], 'nutriologos_is_verified_idx');
    }

    public function down(): void
    {
        $drops = [
            ['users', 'users_email_idx'],
            ['users', 'users_role_id_idx'],
            ['workout_logs', 'workout_logs_client_date_idx'],
            ['tickets', 'tickets_user_status_idx'],
            ['messages', 'messages_ticket_sent_idx'],
            ['coaches', 'coaches_is_verified_idx'],
            ['nutriologos', 'nutriologos_is_verified_idx'],
        ];

        foreach ($drops as [$table, $idx]) {
            try {
                Schema::table($table, fn (Blueprint $t) => $t->dropIndex($idx));
            } catch (\Throwable) {
            }
        }
    }

    private function addIndexIfMissing(string $table, array $columns, string $name): void
    {
        try {
            $existing = DB::select('SELECT indexname FROM pg_indexes WHERE tablename = ? AND indexname = ?', [$table, $name]);
            if (empty($existing)) {
                Schema::table($table, function (Blueprint $t) use ($columns, $name) {
                    $t->index($columns, $name);
                });
            }
        } catch (\Throwable) {
        }
    }
};
