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

        $text = str_replace(['á', 'é', 'í', 'ó', 'ú'], ['a', 'e', 'i', 'o', 'u'], $text);

        $intents = IntentRegistry::forRole($roleName);
        $bestIntent = null;
        $bestScore = 0;

        foreach ($intents as $intent => $config) {
            $score = 0;
            $keywords = $config['keywords'] ?? [];
            $label = mb_strtolower((string) ($config['label'] ?? ''));

            foreach ($keywords as $keyword) {
                $kw = mb_strtolower((string) $keyword);
                $kw = str_replace(['á', 'é', 'í', 'ó', 'ú'], ['a', 'e', 'i', 'o', 'u'], $kw);

                if ($kw !== '' && str_contains($text, $kw)) {
                    $score += mb_strlen($kw);
                }
            }

            $normalizedLabel = str_replace(['á', 'é', 'í', 'ó', 'ú', '¿', '?'], ['a', 'e', 'i', 'o', 'u', '', ''], mb_strtolower($label));
            if ($normalizedLabel !== '' && str_contains($text, $normalizedLabel)) {
                $score += 8;
            }

            if ($score > $bestScore) {
                $bestScore = $score;
                $bestIntent = $intent;
            }
        }

        return $bestScore >= 3 ? $bestIntent : null;
    }
}
