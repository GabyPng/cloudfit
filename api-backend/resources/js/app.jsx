import './bootstrap';
import React from 'react';
import { createRoot } from 'react-dom/client';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import LoginPage from './pages/Login';
import RegisterPage from './pages/Register';
import RoleRedirectPage from './pages/RoleRedirect';
import ProtectedRoute from './components/auth/ProtectedRoute';
import AdminIndexPage from './pages/Admin';
import CoachIndexPage from './pages/Coach';
import NutriologoIndexPage from './pages/Nutriologo';
import ClienteIndexPage from './pages/Cliente';

function App() {
    return (
        <BrowserRouter>
            <Routes>
                <Route path="/login" element={<LoginPage />} />
                <Route path="/register" element={<RegisterPage />} />
                <Route path="/" element={<RoleRedirectPage />} />
                <Route
                    path="/admin"
                    element={(
                        <ProtectedRoute allowedRoles={['admin']}>
                            <AdminIndexPage />
                        </ProtectedRoute>
                    )}
                />
                <Route
                    path="/coach/*"
                    element={(
                        <ProtectedRoute allowedRoles={['coach']}>
                            <CoachIndexPage />
                        </ProtectedRoute>
                    )}
                />
                <Route
                    path="/nutriologo"
                    element={(
                        <ProtectedRoute allowedRoles={['nutriologo']}>
                            <NutriologoIndexPage />
                        </ProtectedRoute>
                    )}
                />
                <Route
                    path="/cliente"
                    element={(
                        <ProtectedRoute allowedRoles={['cliente']}>
                            <ClienteIndexPage />
                        </ProtectedRoute>
                    )}
                />
                <Route path="*" element={<Navigate to="/" replace />} />
            </Routes>
        </BrowserRouter>
    );
}

const container = document.getElementById('app');
if (container) {
    const root = createRoot(container);
    root.render(<App />);
}
