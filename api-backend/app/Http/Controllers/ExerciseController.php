<?php

namespace App\Http\Controllers;

use App\Models\Exercise;
use Illuminate\Http\Request;

class ExerciseController extends Controller
{
    /**
     * Obtener todos los ejercicios
     */
    public function index()
    {
        try {
            $exercises = Exercise::orderBy('name')->get();

            return response()->json([
                'success' => true,
                'data' => $exercises,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al obtener ejercicios',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Obtener ejercicio por ID
     */
    public function show($id)
    {
        try {
            $exercise = Exercise::findOrFail($id);

            return response()->json([
                'success' => true,
                'data' => $exercise,
            ]);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Ejercicio no encontrado',
            ], 404);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al obtener ejercicio',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Obtener ejercicios por categoría
     */
    public function getByCategory($category)
    {
        try {
            $exercises = Exercise::where('category', $category)
                ->orderBy('name')
                ->get();

            return response()->json([
                'success' => true,
                'data' => $exercises,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al obtener ejercicios por categoría',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Obtener ejercicios por dificultad
     */
    public function getByDifficulty($difficulty)
    {
        try {
            $exercises = Exercise::where('difficulty', $difficulty)
                ->orderBy('name')
                ->get();

            return response()->json([
                'success' => true,
                'data' => $exercises,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al obtener ejercicios por dificultad',
                'error' => $e->getMessage(),
            ], 500);
        }
    }
}
