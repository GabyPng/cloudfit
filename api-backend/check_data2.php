<?php

use Illuminate\Support\Facades\DB;

$clients = DB::table('users')->where('role_id', 4)->get();

foreach ($clients as $client) {
    echo '--- '.$client->name." ---\n";

    $clientLink = DB::table('clients')->where('user_id', $client->user_id)->count();
    $progressCount = DB::table('progress')->where('client_id', $client->user_id)->count();
    $workoutsCount = DB::table('workout_logs')->where('client_id', $client->user_id)->count();

    echo "Link en tabla 'clients': ".($clientLink > 0 ? 'Sí' : 'No')."\n";
    echo 'Registros de peso (progress): '.$progressCount."\n";
    echo 'Registros de entreno (workout_logs): '.$workoutsCount."\n\n";
}
