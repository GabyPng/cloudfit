import React from 'react';
import RoleIndexLayout from './RoleIndexLayout';

export default function CoachIndex() {
  return (
    <RoleIndexLayout
      title="Panel Coach"
      subtitle="Este es tu index de coach. Aqui podras gestionar rutinas, seguimiento y evolucion de tus clientes."
      accentClass="text-blue-400"
    />
  );
}