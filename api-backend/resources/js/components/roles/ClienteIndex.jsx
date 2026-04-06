import React from 'react';
import RoleIndexLayout from './RoleIndexLayout';

export default function ClienteIndex() {
  return (
    <RoleIndexLayout
      title="Panel Cliente"
      subtitle="Este es tu index de cliente. Aqui consultaras progreso, entrenamiento y plan nutricional."
      accentClass="text-[#CCFF00]"
    />
  );
}