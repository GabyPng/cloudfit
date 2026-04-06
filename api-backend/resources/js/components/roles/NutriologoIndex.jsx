import React from 'react';
import RoleIndexLayout from './RoleIndexLayout';
import { getCachedLocalUser } from '../../lib/localUserSync';

export default function NutriologoIndex() {
  const localUser = getCachedLocalUser();
  const profile = localUser?.nutriologo_profile || localUser?.nutriologoProfile || null;
  const certificateUploads = Array.isArray(profile?.certificate_uploads)
    ? profile.certificate_uploads
    : [];
  const hasProfile = Boolean(profile);

  return (
    <RoleIndexLayout
      title="Panel Nutriologo"
      subtitle="Este es tu index de nutriologo. Aqui podras administrar planes nutricionales y seguimiento de pacientes."
      accentClass="text-emerald-400"
    >
      <section className="rounded-xl border border-emerald-500/30 bg-emerald-500/5 p-5">
        <p className="text-xs font-semibold uppercase tracking-[0.2em] text-emerald-300">
          Perfil profesional
        </p>

        {!hasProfile ? (
          <p className="mt-3 text-sm text-gray-300">
            No se encontro un perfil profesional de nutriologo para esta cuenta.
          </p>
        ) : (
          <div className="mt-4 grid gap-3 sm:grid-cols-3">
            <div className="rounded-lg border border-[#2A2A2A] bg-[#101010] p-4">
              <p className="text-xs uppercase tracking-wide text-gray-500">Cedula</p>
              <p className="mt-1 text-base font-semibold text-white">{profile.license_number || '-'}</p>
            </div>

            <div className="rounded-lg border border-[#2A2A2A] bg-[#101010] p-4">
              <p className="text-xs uppercase tracking-wide text-gray-500">Enfoque</p>
              <p className="mt-1 text-base font-semibold text-white">{profile.focus || '-'}</p>
            </div>

            <div className="rounded-lg border border-[#2A2A2A] bg-[#101010] p-4">
              <p className="text-xs uppercase tracking-wide text-gray-500">Certificados</p>
              <p className="mt-1 text-base font-semibold text-white">{certificateUploads.length}</p>
            </div>
          </div>
        )}
      </section>
    </RoleIndexLayout>
  );
}