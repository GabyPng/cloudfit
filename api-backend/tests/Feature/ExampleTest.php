<?php

namespace Tests\Feature;

use PHPUnit\Framework\Attributes\Test;
use Tests\TestCase;

class ExampleTest extends TestCase
{
    #[Test]
    public function api_requiere_autenticacion(): void
    {
        // Verifica que el backend responde y protege sus endpoints.
        $this->getJson('/api/me')->assertStatus(401);
    }
}
