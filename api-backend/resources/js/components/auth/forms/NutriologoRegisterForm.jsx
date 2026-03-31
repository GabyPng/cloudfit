import React from 'react';
import RoleRegisterForm from './RoleRegisterForm';

const fields = [
  { name: 'name', label: 'Nombre completo', type: 'text', placeholder: 'Laura Martinez', required: true },
  { name: 'email', label: 'Correo Electronico', type: 'email', placeholder: 'nutriologo@cloudfit.com', required: true },
  { name: 'password', label: 'Contrasena', type: 'password', placeholder: '********', required: true, minLength: 6 },
  { name: 'confirmPassword', label: 'Confirmar contrasena', type: 'password', placeholder: '********', required: true, minLength: 6 },
  {
    name: 'licenseNumber',
    label: 'Cedula profesional',
    type: 'text',
    placeholder: 'CED-123456',
    required: true,
    hint: 'Se guardara como dato de perfil para futuras validaciones.',
  },
  {
    name: 'focus',
    label: 'Enfoque nutricional',
    type: 'select',
    required: true,
    options: [
      { value: 'deportivo', label: 'Nutricion deportiva' },
      { value: 'clinico', label: 'Nutricion clinica' },
      { value: 'control_peso', label: 'Control de peso' },
      { value: 'bienestar', label: 'Bienestar integral' },
    ],
  },
  {
    name: 'certificatePhotos',
    label: 'Fotos de certificados',
    type: 'file',
    required: true,
    multiple: true,
    accept: 'image/png,image/jpeg,image/webp',
    acceptedMimeTypes: ['image/png', 'image/jpeg', 'image/webp'],
    maxFiles: 3,
    maxSizeMb: 5,
    hint: 'Sube hasta 3 imagenes de tus certificaciones o constancias en formato PNG, JPG o WEBP.',
  },
];

export default function NutriologoRegisterForm(props) {
  return (
    <RoleRegisterForm
      {...props}
      roleLabel="Nutriologo"
      helperText="Completa tu informacion profesional para administrar planes nutricionales y seguimiento de pacientes."
      submitLabel="REGISTRARME COMO NUTRIOLOGO"
      fields={fields}
    />
  );
}