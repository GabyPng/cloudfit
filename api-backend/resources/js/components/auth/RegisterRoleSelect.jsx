import React from 'react';

const ROLE_OPTIONS = [
  { value: 'cliente', label: 'Cliente', description: 'Regístrate para consultar tu progreso, rutinas y plan nutricional.' },
  { value: 'coach', label: 'Coach', description: 'Crea tu acceso para gestionar entrenamientos y acompañar a tus clientes.' },
  { value: 'nutriologo', label: 'Nutriólogo', description: 'Configura tu perfil profesional para crear y dar seguimiento a planes nutricionales.' },
];

export default function RegisterRoleSelect({ value, onChange }) {
  const selectedRole = ROLE_OPTIONS.find((option) => option.value === value);

  return (
    <div className="space-y-3">
      <label className="text-xs font-semibold text-gray-400 uppercase tracking-widest">Tipo de cuenta</label>
      <select
        value={value}
        onChange={(event) => onChange(event.target.value)}
        className="w-full bg-[#0D0D0D] border border-[#2A2A2A] rounded-xl py-3.5 px-4 focus:outline-none focus:border-[#CCFF00] transition-all text-white"
      >
        {ROLE_OPTIONS.map((option) => (
          <option key={option.value} value={option.value}>{option.label}</option>
        ))}
      </select>
      <p className="text-sm text-gray-500 leading-relaxed">{selectedRole?.description}</p>
    </div>
  );
}