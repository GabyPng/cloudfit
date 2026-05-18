<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // SQLite no soporta ALTER COLUMN; en testing client_id ya es nullable por definición.
        if (DB::getDriverName() === 'sqlite') {
            return;
        }
        DB::statement('ALTER TABLE routines ALTER COLUMN client_id DROP NOT NULL');
    }

    public function down(): void
    {
        DB::statement('ALTER TABLE routines ALTER COLUMN client_id SET NOT NULL');
    }
};
