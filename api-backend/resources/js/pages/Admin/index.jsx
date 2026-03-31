import React from 'react';
import RoleIndexLayout from '../RoleIndexLayout';

export default function AdminIndexPage() {
return (
<RoleIndexLayout
title="Panel Administrador"
subtitle="Este es tu index de administrador. Desde aquí podrás monitorear usuarios, roles y operación general del sistema."
accentClass="text-red-400"
/>
);
}
