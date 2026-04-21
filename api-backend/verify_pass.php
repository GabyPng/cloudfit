<?php
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\DB;

$user = DB::table('users')->where('email', 'admin.demo@cloudfit.test')->first();

if ($user) {
    echo "Is password? " . (Hash::check('password', $user->password) ? 'YES' : 'NO') . "\n";
    echo "Is password123? " . (Hash::check('password123', $user->password) ? 'YES' : 'NO') . "\n";
} else {
    echo "User not found\n";
}
