<?php

namespace App\Services\Chatbot;

class IntentClassifier
{
    public static function classify(string $message, string $roleName): ?string
    {
        $text = mb_strtolower(trim($message));
        if ($text === '') {
            return null;
        }

        $intents = IntentRegistry::forRole($roleName);
        $bestIntent = null;
        $bestScore = 0;

        foreach ($intents as $intent => $config) {
            $score = 0;
            $keywords = $config['keywords'] ?? [];

            foreach ($keywords as $keyword) {
                $kw = mb_strtolower((string) $keyword);
                if ($kw !== '' && str_contains($text, $kw)) {
                    $score += mb_strlen($kw);
                }
            }

            if ($score > $bestScore) {
                $bestScore = $score;
                $bestIntent = $intent;
            }
        }

        return $bestScore >= 4 ? $bestIntent : null;
    }
}
