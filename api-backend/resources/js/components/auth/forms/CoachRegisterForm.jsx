import React from 'react';
import RoleRegisterForm from './RoleRegisterForm';

const fields = [
  { name: 'name', label: 'Nombre completo', type: 'text', placeholder: 'Maria Lopez', required: true },
  { name: 'email', label: 'Correo Electronico', type: 'email', placeholder: 'coach@cloudfit.com', required: true },
  { name: 'password', label: 'Contrasena', type: 'password', placeholder: '********', required: true, minLength: 6 },
  { name: 'confirmPassword', label: 'Confirmar contrasena', type: 'password', placeholder: '********', required: true, minLength: 6 },
  {
    name: 'specialty',
    label: 'Especialidad',
    type: 'select',
    required: true,
    options: [
      { value: 'fuerza', label: 'Fuerza' },
      { value: 'funcional', label: 'Entrenamiento funcional' },
      { value: 'rehabilitacion', label: 'Rehabilitacion' },
      { value: 'alto_rendimiento', label: 'Alto rendimiento' },
    ],
  },
  {
    name: 'experienceYears',
    label: 'Anos de experiencia',
    type: 'number',
    placeholder: '3',
    required: true,
    min: 0,
    max: 60,
    hint: 'Nos ayuda a identificar tu perfil profesional.',
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
    hint: 'Sube hasta 3 imagenes de tus certificaciones en formato PNG, JPG o WEBP.',
  },
];

export default function CoachRegisterForm(props) {
  return (
    <RoleRegisterForm
      {...props}
      roleLabel="Coach"
      helperText="Registra tu perfil profesional para gestionar rutinas y acompanar a tus clientes dentro de CloudFit."
      submitLabel="REGISTRARME COMO COACH"
      fields={fields}
    />
  );
}