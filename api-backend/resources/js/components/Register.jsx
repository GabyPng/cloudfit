import React, { useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import RegisterRoleSelect from './auth/RegisterRoleSelect';
import ClienteRegisterForm from './auth/forms/ClienteRegisterForm';
import CoachRegisterForm from './auth/forms/CoachRegisterForm';
import NutriologoRegisterForm from './auth/forms/NutriologoRegisterForm';
import { registerUser } from '../lib/registerUser';
import { getRoleHomePathFromRole } from '../lib/roleRouting';

export default function Register() {
  const [selectedRole, setSelectedRole] = useState('cliente');
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState(null);
  const [error, setError] = useState(null);
  const navigate = useNavigate();

  const roleForms = useMemo(() => ({
    cliente: ClienteRegisterForm,
    coach: CoachRegisterForm,
    nutriologo: NutriologoRegisterForm,
  }), []);

  const SelectedForm = roleForms[selectedRole];

  const handleRegister = async (values, resetForm) => {
    setLoading(true);
    setError(null);
    setMessage(null);

    const account = {
      name: values.name,
      email: values.email,
      password: values.password,
    };

    const certificateFiles = Array.isArray(values.certificatePhotos)
      ? values.certificatePhotos
      : [];

    const profile = Object.entries(values).reduce((accumulator, [key, value]) => {
      if (!['name', 'email', 'password', 'confirmPassword', 'certificatePhotos'].includes(key)) {
        accumulator[key] = value;
      }
      return accumulator;
    }, {});

    const result = await registerUser({
      role: selectedRole,
      account,
      profile,
      certificateFiles,
    });

    if (!result.ok) {
      setError(result.error);
      setLoading(false);
      return;
    }

    if (result.requiresEmailConfirmation) {
      setMessage('Registro exitoso. Revisa tu correo electrónico para verificar la cuenta si es necesario, y luego inicia sesión.');
      resetForm();
      setLoading(false);
      return;
    }

    navigate(getRoleHomePathFromRole(selectedRole), { replace: true });
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-[#0D0D0D] text-white overflow-hidden relative font-sans p-4">
      {/* Background blobs for aesthetics */}
      <div className="absolute top-[-10%] left-[-10%] w-96 h-96 bg-[#CCFF00] rounded-full mix-blend-multiply filter blur-[128px] opacity-20 pointer-events-none"></div>
      <div className="absolute bottom-[-10%] right-[-10%] w-96 h-96 bg-blue-600 rounded-full mix-blend-multiply filter blur-[128px] opacity-20 pointer-events-none"></div>

      <div className="w-full max-w-md p-8 bg-[#1A1A1A]/80 backdrop-blur-xl rounded-3xl border border-[#2A2A2A] shadow-2xl z-10">
        <div className="text-center mb-10">
          <h1 className="text-4xl font-black italic text-[#CCFF00] tracking-tighter mb-2">CLOUDFIT</h1>
          <p className="text-gray-400 text-sm font-medium">Crear nueva cuenta</p>
        </div>

        <div className="space-y-6">
          <RegisterRoleSelect value={selectedRole} onChange={setSelectedRole} />
          <SelectedForm
            key={selectedRole}
            loading={loading}
            error={error}
            message={message}
            onSubmit={handleRegister}
          />
        </div>
      </div>
    </div>
  );
}
