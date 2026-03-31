import React from 'react';
import RoleRegisterForm from './RoleRegisterForm';

const fields = [
  { name: 'name', label: 'Nombre completo', type: 'text', placeholder: 'Juan Perez', required: true },
  { name: 'email', label: 'Correo Electronico', type: 'email', placeholder: 'ejemplo@correo.com', required: true },
  { name: 'password', label: 'Contrasena', type: 'password', placeholder: '********', required: true, minLength: 6 },
  { name: 'confirmPassword', label: 'Confirmar contrasena', type: 'password', placeholder: '********', required: true, minLength: 6 },
  {
    name: 'objective',
    label: 'Objetivo principal',
    type: 'select',
    required: true,
    options: [
      { value: 'perder_peso', label: 'Perder peso' },
      { value: 'ganar_masa', label: 'Ganar masa muscular' },
      { value: 'mejorar_condicion', label: 'Mejorar condicion fisica' },
      { value: 'bienestar_general', label: 'Bienestar general' },
    ],
  },
  {
    name: 'activityLevel',
    label: 'Nivel de actividad',
    type: 'select',
    required: true,
    options: [
      { value: 'bajo', label: 'Bajo' },
      { value: 'medio', label: 'Medio' },
      { value: 'alto', label: 'Alto' },
    ],
  },
];

export default function ClienteRegisterForm(props) {
  return (
    <RoleRegisterForm
      {...props}
      roleLabel="Cliente"
      helperText="Cuentanos que quieres lograr para personalizar tu experiencia desde el inicio."
      submitLabel="REGISTRARME COMO CLIENTE"
      fields={fields}
    />
  );
}