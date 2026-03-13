<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Http\Client\Response;

class DataConnectService
{
    private string $baseUrl;
    private bool $isEmulator;

    public function __construct()
    {
        $this->isEmulator = config('dataconnect.use_emulator', false);

        if ($this->isEmulator) {
            $host     = config('dataconnect.emulator_host', 'localhost');
            $port     = config('dataconnect.emulator_port', 9399);
            $project  = config('dataconnect.project_id', 'demo-cloudfit');
            $location = config('dataconnect.location', 'us-east4');
            $service  = config('dataconnect.service_id', 'cloudfit');
            $connector = config('dataconnect.connector_id', 'example');

            $this->baseUrl = "http://{$host}:{$port}/v1beta/projects/{$project}/locations/{$location}/services/{$service}/connectors/{$connector}";
        } else {
            $project   = config('dataconnect.project_id');
            $location  = config('dataconnect.location', 'us-east4');
            $service   = config('dataconnect.service_id', 'cloudfit');
            $connector = config('dataconnect.connector_id', 'example');

            $this->baseUrl = "https://firebasedataconnect.googleapis.com/v1beta/projects/{$project}/locations/{$location}/services/{$service}/connectors/{$connector}";
        }
    }

    // -------------------------------------------------------------------------
    // Métodos base
    // -------------------------------------------------------------------------

    /**
     * Ejecuta una Query de Data Connect.
     *
     * @param string      $operationName  Nombre exacto de la query (e.g. "GetMisClientes")
     * @param array       $variables      Variables de la query
     * @param string|null $firebaseIdToken Token Firebase del usuario autenticado (para @auth USER)
     */
    public function query(string $operationName, array $variables = [], ?string $firebaseIdToken = null): array
    {
        return $this->execute('executeQuery', $operationName, $variables, $firebaseIdToken);
    }

    /**
     * Ejecuta una Mutation de Data Connect.
     */
    public function mutation(string $operationName, array $variables = [], ?string $firebaseIdToken = null): array
    {
        return $this->execute('executeMutation', $operationName, $variables, $firebaseIdToken);
    }

    private function execute(string $action, string $operationName, array $variables, ?string $idToken): array
    {
        $request = Http::timeout(10)
            ->acceptJson()
            ->contentType('application/json');

        if ($idToken) {
            $request = $request->withToken($idToken);
        }

        $response = $request->post("{$this->baseUrl}:{$action}", [
            'operationName' => $operationName,
            'variables'     => $variables,
        ]);

        if ($response->failed()) {
            throw new \RuntimeException(
                "DataConnect error [{$operationName}]: " . $response->body(),
                $response->status()
            );
        }

        return $response->json('data', []);
    }

    // -------------------------------------------------------------------------
    // Queries — un método por operación
    // -------------------------------------------------------------------------

    public function getMiPerfil(string $idToken): array
    {
        return $this->query('GetMiPerfil', [], $idToken);
    }

    public function getAllCoaches(string $idToken): array
    {
        return $this->query('GetAllCoaches', [], $idToken);
    }

    public function getAllNutriologos(string $idToken): array
    {
        return $this->query('GetAllNutriologos', [], $idToken);
    }

    public function getMisClientes(string $idToken): array
    {
        return $this->query('GetMisClientes', [], $idToken);
    }

    public function getClientesByCoach(string $coachId, string $idToken): array
    {
        return $this->query('GetClientesByCoach', ['coachId' => $coachId], $idToken);
    }

    public function getClientesByNutriologo(string $nutriologoId, string $idToken): array
    {
        return $this->query('GetClientesByNutriologo', ['nutriologoId' => $nutriologoId], $idToken);
    }

    public function getProgresoCliente(string $clienteId, string $idToken): array
    {
        return $this->query('GetProgresoCliente', ['clienteId' => $clienteId], $idToken);
    }

    public function getPlanNutricional(string $clienteId, string $idToken): array
    {
        return $this->query('GetPlanNutricional', ['clienteId' => $clienteId], $idToken);
    }

    public function getRutinasByCliente(string $clienteId, string $idToken): array
    {
        return $this->query('GetRutinasByCliente', ['clienteId' => $clienteId], $idToken);
    }

    public function getEjercicios(string $idToken): array
    {
        return $this->query('GetEjercicios', [], $idToken);
    }

    public function getAllTickets(string $idToken): array
    {
        return $this->query('GetAllTickets', [], $idToken);
    }

    public function getMensajesTicket(string $ticketId, string $idToken): array
    {
        return $this->query('GetMensajesTicket', ['ticketId' => $ticketId], $idToken);
    }

    public function getCertificaciones(string $usuarioId, string $idToken): array
    {
        return $this->query('GetCertificaciones', ['usuarioId' => $usuarioId], $idToken);
    }

    // -------------------------------------------------------------------------
    // Mutations
    // -------------------------------------------------------------------------

    public function createUsuario(string $uid, string $email, string $nombre, string $role): array
    {
        return $this->mutation('CreateUsuario', [
            'uid'    => $uid,
            'email'  => $email,
            'nombre' => $nombre,
            'role'   => $role,
        ]);
    }

    public function registrarProgreso(string $clienteId, float $peso, float $imc, string $idToken): array
    {
        return $this->mutation('RegistrarProgreso', [
            'clienteId' => $clienteId,
            'peso'      => $peso,
            'imc'       => $imc,
        ], $idToken);
    }

    public function crearRutina(string $clienteId, string $nombre, string $descripcion, string $idToken): array
    {
        return $this->mutation('CrearRutina', [
            'clienteId'   => $clienteId,
            'nombre'      => $nombre,
            'descripcion' => $descripcion,
        ], $idToken);
    }
}
