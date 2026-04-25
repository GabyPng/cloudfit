<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // Allow routines to exist as templates without a client
        DB::statement('ALTER TABLE routines ALTER COLUMN client_id DROP NOT NULL');
    }

    public function down(): void
    {
        DB::statement('ALTER TABLE routines ALTER COLUMN client_id SET NOT NULL');
    }
};
