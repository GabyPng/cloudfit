import React, { useEffect, useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import { Mail, Lock, User, Loader2 } from 'lucide-react';

const FIELD_ICONS = { name: User, email: Mail, password: Lock, confirmPassword: Lock };

function buildInitialValues(fields) {
  return fields.reduce((acc, field) => {
    acc[field.name] = field.type === 'file' ? [] : field.defaultValue ?? '';
    return acc;
  }, {});
}

function validateFileField(field, value) {
  const files = Array.isArray(value) ? value : [];
  if (field.required && files.length === 0) return `Debes agregar ${field.label.toLowerCase()}.`;
  if (field.maxFiles && files.length > field.maxFiles) return `Solo puedes subir hasta ${field.maxFiles} archivos en ${field.label.toLowerCase()}.`;
  if (field.maxSizeMb) {
    const oversized = files.find((f) => f.size > field.maxSizeMb * 1024 * 1024);
    if (oversized) return `${oversized.name} supera el límite de ${field.maxSizeMb} MB.`;
  }
  if (field.acceptedMimeTypes?.length) {
    const invalid = files.find((f) => !field.acceptedMimeTypes.includes(f.type));
    if (invalid) return `${invalid.name} no tiene un formato permitido.`;
  }
  return null;
}

function FilePreviewGrid({ files }) {
  const [previews, setPreviews] = useState([]);

  useEffect(() => {
    const nextPreviews = files.map((file) => ({
      key: `${file.name}-${file.size}-${file.lastModified}`,
      name: file.name,
      size: file.size,
      url: URL.createObjectURL(file),
    }));
    setPreviews(nextPreviews);
    return () => nextPreviews.forEach((preview) => URL.revokeObjectURL(preview.url));
  }, [files]);

  if (previews.length === 0) return null;

  return (
    <div className="grid grid-cols-2 gap-3 sm:grid-cols-3">
      {previews.map((preview) => (
        <div key={preview.key} className="overflow-hidden rounded-xl border border-[#2A2A2A] bg-[#151515]">
          <img src={preview.url} alt={preview.name} className="h-28 w-full object-cover" />
          <div className="space-y-1 px-3 py-2">
            <p className="truncate text-xs font-medium text-gray-200">{preview.name}</p>
            <p className="text-[11px] text-gray-500">{(preview.size / (1024 * 1024)).toFixed(2)} MB</p>
          </div>
        </div>
      ))}
    </div>
  );
}

export default function RoleRegisterForm({ roleLabel, helperText, fields, submitLabel, loading, error, message, onSubmit }) {
  const initialValues = useMemo(() => buildInitialValues(fields), [fields]);
  const [values, setValues] = useState(initialValues);
  const [localError, setLocalError] = useState(null);

  const handleChange = (fieldName, nextValue) => {
    setValues((current) => ({ ...current, [fieldName]: nextValue }));
  };

  const handleSubmit = async (event) => {
    event.preventDefault();
    setLocalError(null);

    if (values.password !== values.confirmPassword) {
      setLocalError('Las contraseñas no coinciden.');
      return;
    }

    for (const field of fields) {
      if (field.type === 'file') {
        const fileError = validateFileField(field, values[field.name]);
        if (fileError) {
          setLocalError(fileError);
          return;
        }
      }
    }

    await onSubmit(values, () => setValues(initialValues));
  };

  return (
    <>
      <div className="mb-6 rounded-2xl border border-[#2A2A2A] bg-[#111111] p-4">
        <p className="text-xs font-semibold uppercase tracking-[0.25em] text-[#CCFF00]">Registro {roleLabel}</p>
        <p className="mt-2 text-sm leading-relaxed text-gray-400">{helperText}</p>
      </div>

      {(error || localError) && <div className="mb-6 rounded-xl border border-red-500/50 bg-red-500/10 p-4 text-sm font-medium text-red-400">{error || localError}</div>}
      {message && <div className="mb-6 rounded-xl border border-green-500/50 bg-green-500/10 p-4 text-sm font-medium text-green-400">{message}</div>}

      <form onSubmit={handleSubmit} className="space-y-6">
        {fields.map((field) => {
          const Icon = FIELD_ICONS[field.name];
          return (
            <div key={field.name} className="space-y-2">
              <label className="text-xs font-semibold uppercase tracking-widest text-gray-400">{field.label}</label>

              {field.type === 'select' ? (
                <select
                  value={values[field.name]}
                  onChange={(event) => handleChange(field.name, event.target.value)}
                  className="w-full rounded-xl border border-[#2A2A2A] bg-[#0D0D0D] px-4 py-3.5 text-white transition-all focus:border-[#CCFF00] focus:outline-none"
                  required={field.required}
                >
                  <option value="">Selecciona una opción</option>
                  {field.options.map((option) => <option key={option.value} value={option.value}>{option.label}</option>)}
                </select>
              ) : field.type === 'file' ? (
                <div className="space-y-3 rounded-xl border border-dashed border-[#3A3A3A] bg-[#0D0D0D] p-4">
                  <input
                    type="file"
                    accept={field.accept}
                    multiple={field.multiple}
                    onChange={(event) => handleChange(field.name, Array.from(event.target.files ?? []))}
                    className="block w-full text-sm text-gray-300 file:mr-4 file:rounded-lg file:border-0 file:bg-[#CCFF00] file:px-4 file:py-2 file:font-semibold file:text-black hover:file:bg-[#bbf000]"
                    required={field.required && values[field.name].length === 0}
                  />
                  {values[field.name].length > 0 && <FilePreviewGrid files={values[field.name]} />}
                </div>
              ) : (
                <div className="relative group">
                  {Icon && <Icon className="absolute left-4 top-1/2 h-5 w-5 -translate-y-1/2 text-gray-500 transition-colors group-focus-within:text-[#CCFF00]" />}
                  <input
                    type={field.type}
                    value={values[field.name]}
                    onChange={(event) => handleChange(field.name, event.target.value)}
                    className={`w-full rounded-xl border border-[#2A2A2A] bg-[#0D0D0D] py-3.5 pr-4 text-white placeholder-gray-600 transition-all focus:border-[#CCFF00] focus:outline-none ${Icon ? 'pl-12' : 'pl-4'}`}
                    placeholder={field.placeholder}
                    required={field.required}
                    minLength={field.minLength}
                    min={field.min}
                    max={field.max}
                  />
                </div>
              )}

              {field.hint && <p className="text-xs text-gray-500">{field.hint}</p>}
            </div>
          );
        })}

        <button type="submit" disabled={loading} className="mt-2 flex w-full items-center justify-center rounded-xl bg-[#CCFF00] py-4 font-black text-black transition-all hover:bg-[#bbf000] focus:ring-4 focus:ring-[#CCFF00]/30 disabled:opacity-70">
          {loading ? <Loader2 className="h-5 w-5 animate-spin" /> : submitLabel}
        </button>
      </form>

      <div className="mt-6 text-center">
        <Link to="/login" className="text-sm text-gray-400 transition-colors hover:text-white">
          ¿Ya tienes una cuenta? <span className="font-semibold text-[#CCFF00] underline decoration-[#CCFF00]/50 underline-offset-4">Inicia sesión</span>
        </Link>
      </div>
    </>
  );
}