import React from 'react';
import RoleIndexLayout from './RoleIndexLayout';

export default function AdminIndex() {
  return (
    <RoleIndexLayout
      title="Panel Administrador"
      subtitle="Este es tu index de administrador. Desde aqui podras monitorear usuarios, roles y operacion general del sistema."
      accentClass="text-red-400"
    />
  );
}