<?php

namespace Database\Seeders;

use Carbon\Carbon;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class MockClientDataSeeder extends Seeder
{
    public function run()
    {
        // 1. Obtener el coach (Jona Coach o el id correspondiente)
        $coach = DB::table('users')->where('email', 'jona-coach@gmail.com')->first();
        if (! $coach) {
            echo "No se encontró el coach. Verifica el email en la DB.\n";

            return;
        }

        // 2. Obtener un cliente (o crear uno de prueba)
        // Buscamos un usuario con role_id = 3 (cliente)
        $client = DB::table('users')->where('role_id', 3)->first();

        if (! $client) {
            echo "No se encontró ningún cliente en la tabla users.\n";

            return;
        }

        // Ensure coach exists in coaches table
        $coachLink = DB::table('coaches')->where('user_id', $coach->user_id)->first();
        if (! $coachLink) {
            DB::table('coaches')->insert([
                'user_id' => $coach->user_id,
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ]);
        }

        // Add avatar and objective to client if needed
        DB::table('users')->where('user_id', $client->user_id)->update([
            'objective' => 'Ganar masa muscular y reducir porcentaje de grasa',
            'avatar_url' => 'https://ui-avatars.com/api/?name='.urlencode($client->name).'&background=random',
        ]);

        // 3. Vincular al coach en la tabla clients
        $clientLink = DB::table('clients')->where('user_id', $client->user_id)->first();
        if (! $clientLink) {
            DB::table('clients')->insert([
                'user_id' => $client->user_id,
                'coach_id' => $coach->user_id,
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ]);
        } else {
            DB::table('clients')->where('user_id', $client->user_id)->update([
                'coach_id' => $coach->user_id,
            ]);
        }

        // 4. Insertar Progress logs (limpiar anteriores si existían)
        DB::table('progress')->where('client_id', $client->user_id)->delete();

        $progressData = [];
        for ($i = 6; $i >= 0; $i--) {
            $baseWeight = 75.0; // Empezó en 75 kg
            $progressData[] = [
                'client_id' => $client->user_id,
                'weight' => $baseWeight + rand(-15, 15) / 10, // Variación pequeña
                'date' => Carbon::now()->subWeeks($i)->format('Y-m-d H:i:s'),
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ];
        }
        DB::table('progress')->insert($progressData);

        // 5. Insertar Workout logs (limpiar anteriores)
        DB::table('workout_logs')->where('client_id', $client->user_id)->delete();

        $workoutLogs = [];
        for ($i = 0; $i < 5; $i++) {
            $workoutLogs[] = [
                'client_id' => $client->user_id,
                'routine_id' => 1,
                'is_complete' => rand(0, 1) == 1,
                'date' => Carbon::now()->subDays($i * 2)->format('Y-m-d H:i:s'),
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ];
        }
        DB::table('workout_logs')->insert($workoutLogs);

        echo "Datos mock insertados correctamente para el cliente: {$client->name} con el coach: {$coach->name}.\n";
    }
}
