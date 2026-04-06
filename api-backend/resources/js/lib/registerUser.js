import { supabase } from './supabase';

const certificatesBucket = import.meta.env.VITE_SUPABASE_CERTIFICATES_BUCKET || 'certificates';

async function uploadCertificates({ userId, role, files }) {
  const uploadResults = await Promise.all(files.map(async (file) => {
    const sanitizedName = file.name.replace(/\s+/g, '-').toLowerCase();
    const filePath = `${role}/${userId}/${Date.now()}-${sanitizedName}`;

    const { error } = await supabase.storage
      .from(certificatesBucket)
      .upload(filePath, file, { upsert: false });

    if (error) throw new Error(error.message);

    return {
      name: file.name,
      path: filePath,
      type: file.type,
      size: file.size,
    };
  }));

  return uploadResults;
}

export async function registerUser({ role, account, profile, certificateFiles = [] }) {
  const payload = {
    nombre: account.name,
    role,
    profile,
  };

  const { data, error: authError } = await supabase.auth.signUp({
    email: account.email,
    password: account.password,
    options: { data: payload },
  });

  if (authError) return { ok: false, error: authError.message };
  if (!data.session) return { ok: true, requiresEmailConfirmation: true };

  if (certificateFiles.length > 0) {
    try {
      const uploadedCertificates = await uploadCertificates({
        userId: data.user.id,
        role,
        files: certificateFiles,
      });

      payload.profile = {
        ...profile,
        certificateUploads: uploadedCertificates,
      };
    } catch (error) {
      return {
        ok: false,
        error: `La cuenta se creó, pero falló la carga de certificados: ${error.message}`,
      };
    }
  }

  try {
    const response = await fetch('/api/sync', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${data.session.access_token}`,
      },
      body: JSON.stringify({
        name: account.name,
        role,
        profile: payload.profile,
      }),
    });

    if (!response.ok) {
      const details = await response.text();
      return {
        ok: false,
        error: `La cuenta se creó, pero no se pudo sincronizar el perfil: ${details}`,
      };
    }
  } catch (error) {
    return {
      ok: false,
      error: `La cuenta se creó, pero falló la sincronización del perfil: ${error.message}`,
    };
  }

  return { ok: true, requiresEmailConfirmation: false };
}