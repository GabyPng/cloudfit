<?php
require __DIR__.'/vendor/autoload.php';
$app = require __DIR__.'/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use Illuminate\Support\Facades\DB;

$rows = DB::table('clients')
    ->join('users', 'users.user_id', '=', 'clients.user_id')
    ->select('clients.user_id as id', 'users.name', 'users.avatar_url', 'clients.goal as objetivo')
    ->limit(8)->get();

echo 'Clientes encontrados: '.$rows->count().PHP_EOL;

$clean = function ($v) {
    if ($v === null || $v === '') return $v;
    return mb_check_encoding($v, 'UTF-8') ? $v : mb_convert_encoding($v, 'UTF-8', 'Windows-1252');
};

$out = $rows->map(function ($c) use ($clean) {
    $name = $clean($c->name) ?? '';
    $parts = preg_split('/\s+/', trim($name), -1, PREG_SPLIT_NO_EMPTY);
    $ini = '';
    foreach (array_slice($parts, 0, 2) as $p) {
        $ini .= mb_strtoupper(mb_substr($p, 0, 1, 'UTF-8'), 'UTF-8');
    }
    return ['id' => $c->id, 'name' => $name, 'initials' => $ini ?: '?', 'avatar' => $clean($c->avatar_url), 'objetivo' => $clean($c->objetivo)];
});

$json = json_encode($out->values(), JSON_UNESCAPED_UNICODE);
echo $json === false
    ? ('JSON FALLO: '.json_last_error_msg().PHP_EOL)
    : ('JSON OK ('.strlen($json).' bytes)'.PHP_EOL.$json.PHP_EOL);
