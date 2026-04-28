import { useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';

// Fatigue level → visual style
const NIVEL_STYLES = {
  recuperado: { fill: 'rgba(255,255,255,0.04)', stroke: '#2a2a2a', glow: 'none',                  label: 'Recuperado', color: '#555' },
  bajo:       { fill: 'rgba(202,253,0,0.18)',   stroke: '#cafd00', glow: '0 0 8px #cafd0066',     label: 'Bajo',       color: '#cafd00' },
  moderado:   { fill: 'rgba(245,158,11,0.35)',  stroke: '#f59e0b', glow: '0 0 10px #f59e0b66',    label: 'Moderado',   color: '#f59e0b' },
  alto:       { fill: 'rgba(255,68,68,0.45)',   stroke: '#ff4444', glow: '0 0 14px #ff444488',    label: 'Alto',       color: '#ff4444' },
};

// Maps backend muscle group keys → SVG region IDs
const MUSCLE_TO_REGIONS = {
  pecho:          { front: ['pecho'],                                           back: [] },
  espalda:        { front: [],                                                  back: ['espalda_alta'] },
  espalda_baja:   { front: [],                                                  back: ['espalda_baja'] },
  trapecio:       { front: [],                                                  back: ['trapecio'] },
  hombros:        { front: ['delt_ant_izq', 'delt_ant_der'],                   back: ['delt_post_izq', 'delt_post_der'] },
  biceps:         { front: ['bicep_izq', 'bicep_der'],                         back: [] },
  triceps:        { front: [],                                                  back: ['tricep_izq', 'tricep_der'] },
  abdomen:        { front: ['abdomen', 'oblicuo_izq', 'oblicuo_der'],          back: [] },
  cuadriceps:     { front: ['cuad_izq', 'cuad_der'],                           back: [] },
  isquiotibiales: { front: [],                                                  back: ['isquio_izq', 'isquio_der'] },
  gluteos:        { front: [],                                                  back: ['gluteos'] },
  pantorrillas:   { front: ['pantorrilla_izq', 'pantorrilla_der'],             back: ['gemelo_izq', 'gemelo_der'] },
};

// Front view muscle regions (SVG viewBox 0 0 200 430)
const FRONT_MUSCLES = [
  { id: 'delt_ant_izq',    group: 'hombros',      label: 'Deltoides Ant.',   d: 'M58,62 Q68,56 78,64 L74,100 L50,96 Q45,80 50,68 Z' },
  { id: 'delt_ant_der',    group: 'hombros',      label: 'Deltoides Ant.',   d: 'M142,62 Q132,56 122,64 L126,100 L150,96 Q155,80 150,68 Z' },
  { id: 'pecho',           group: 'pecho',        label: 'Pecho',            d: 'M80,66 Q100,73 120,66 L118,118 Q100,125 82,118 Z' },
  { id: 'bicep_izq',       group: 'biceps',       label: 'Bíceps',           d: 'M46,100 L70,100 L68,146 L44,144 Z' },
  { id: 'bicep_der',       group: 'biceps',       label: 'Bíceps',           d: 'M130,100 L154,100 L156,144 L132,146 Z' },
  { id: 'abdomen',         group: 'abdomen',      label: 'Abdomen',          d: 'M84,122 Q100,128 116,122 L114,184 Q100,191 86,184 Z' },
  { id: 'oblicuo_izq',     group: 'abdomen',      label: 'Oblicuo',          d: 'M64,118 L84,122 L82,188 L62,196 Z' },
  { id: 'oblicuo_der',     group: 'abdomen',      label: 'Oblicuo',          d: 'M116,122 L136,118 L138,196 L118,188 Z' },
  { id: 'cuad_izq',        group: 'cuadriceps',   label: 'Cuádriceps',       d: 'M70,202 L100,202 L98,298 L67,298 Z' },
  { id: 'cuad_der',        group: 'cuadriceps',   label: 'Cuádriceps',       d: 'M100,202 L130,202 L133,298 L102,298 Z' },
  { id: 'pantorrilla_izq', group: 'pantorrillas', label: 'Pantorrilla',      d: 'M68,302 L97,302 L95,390 L66,390 Z' },
  { id: 'pantorrilla_der', group: 'pantorrillas', label: 'Pantorrilla',      d: 'M103,302 L132,302 L134,390 L105,390 Z' },
];

// Back view muscle regions
const BACK_MUSCLES = [
  { id: 'trapecio',        group: 'trapecio',       label: 'Trapecio',          d: 'M82,64 Q100,56 118,64 L114,100 Q100,108 86,100 Z' },
  { id: 'delt_post_izq',   group: 'hombros',        label: 'Deltoides Post.',   d: 'M52,65 Q64,57 82,64 L76,100 L50,98 Q44,82 48,70 Z' },
  { id: 'delt_post_der',   group: 'hombros',        label: 'Deltoides Post.',   d: 'M148,65 Q136,57 118,64 L124,100 L150,98 Q156,82 152,70 Z' },
  { id: 'tricep_izq',      group: 'triceps',        label: 'Tríceps',           d: 'M40,100 L62,100 L60,150 L38,148 Z' },
  { id: 'tricep_der',      group: 'triceps',        label: 'Tríceps',           d: 'M138,100 L160,100 L162,148 L140,150 Z' },
  { id: 'espalda_alta',    group: 'espalda',        label: 'Espalda Alta',      d: 'M66,106 L134,106 L128,164 L72,164 Z' },
  { id: 'espalda_baja',    group: 'espalda_baja',   label: 'Espalda Baja',      d: 'M74,167 L126,167 L120,200 L80,200 Z' },
  { id: 'gluteos',         group: 'gluteos',        label: 'Glúteos',           d: 'M70,205 L130,205 L126,260 L74,260 Z' },
  { id: 'isquio_izq',      group: 'isquiotibiales', label: 'Isquiotibiales',    d: 'M70,264 L100,264 L98,298 L67,298 Z' },
  { id: 'isquio_der',      group: 'isquiotibiales', label: 'Isquiotibiales',    d: 'M100,264 L130,264 L133,298 L102,298 Z' },
  { id: 'gemelo_izq',      group: 'pantorrillas',   label: 'Gemelo',            d: 'M68,302 L97,302 L95,390 L66,390 Z' },
  { id: 'gemelo_der',      group: 'pantorrillas',   label: 'Gemelo',            d: 'M103,302 L132,302 L134,390 L105,390 Z' },
];

// Body silhouette path (shared outline shape for front and back)
const BODY_SILHOUETTE = `
  M100,8 C116,8 120,18 120,30 C120,42 115,48 108,52
  Q132,57 148,68 Q166,82 163,148 Q161,155 152,160
  L150,196 Q148,202 138,206 L135,298 L133,392 L106,392
  L103,298 Q101,206 100,206 Q99,206 97,298
  L94,392 L67,392 L65,298 L62,206
  Q52,202 50,196 L48,160 Q39,155 37,148 Q34,82 52,68
  Q68,57 92,52 C85,48 80,42 80,30 C80,18 84,8 100,8 Z
`;

function BodySVG({ muscles, muscleData, view, onHover, tooltip }) {
  const muscleList = view === 'front' ? FRONT_MUSCLES : BACK_MUSCLES;

  const getStyle = (region) => {
    const group = region.group;
    const data = muscleData?.[group];
    const nivel = data?.nivel ?? 'recuperado';
    return NIVEL_STYLES[nivel] ?? NIVEL_STYLES.recuperado;
  };

  return (
    <svg viewBox="0 0 200 430" className="w-full h-full" style={{ maxHeight: 420 }}>
      {/* Body silhouette */}
      <path d={BODY_SILHOUETTE} fill="#161616" stroke="#2a2a2a" strokeWidth="1.5" />

      {/* Head */}
      <circle cx="100" cy="30" r="22" fill="#1c1c1c" stroke="#2a2a2a" strokeWidth="1.5" />

      {/* Muscle regions */}
      {muscleList.map((region) => {
        const style = getStyle(region);
        const data = muscleData?.[region.group];
        const isHovered = tooltip?.id === region.id;

        return (
          <g key={region.id}>
            <path
              d={region.d}
              fill={style.fill}
              stroke={style.stroke}
              strokeWidth={isHovered ? 2 : 1.2}
              style={{
                filter: isHovered ? `drop-shadow(${style.glow})` : style.glow !== 'none' ? `drop-shadow(${style.glow})` : 'none',
                cursor: 'pointer',
                transition: 'all 0.2s ease',
              }}
              onMouseEnter={(e) => {
                const rect = e.currentTarget.closest('svg').getBoundingClientRect();
                const bbox = e.currentTarget.getBBox();
                onHover({
                  id: region.id,
                  label: region.label,
                  group: region.group,
                  data,
                  x: bbox.x + bbox.width / 2,
                  y: bbox.y,
                });
              }}
              onMouseLeave={() => onHover(null)}
            />
          </g>
        );
      })}

      {/* View label */}
      <text x="100" y="418" textAnchor="middle" fontSize="9" fill="#555" fontFamily="sans-serif" letterSpacing="2">
        {view === 'front' ? 'FRENTE' : 'ESPALDA'}
      </text>
    </svg>
  );
}

export default function MapaFatiga({ muscleData = {} }) {
  const [view, setView] = useState('front');
  const [tooltip, setTooltip] = useState(null);

  const getLevelCount = (nivel) =>
    Object.values(muscleData).filter((m) => m?.nivel === nivel).length;

  return (
    <div className="flex flex-col gap-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h3 className="text-lg font-bold text-white">Mapa de Fatiga Muscular</h3>
          <p className="text-xs text-[#adaaaa] mt-0.5">Volumen acumulado últimos 7 días</p>
        </div>

        {/* View toggle */}
        <div className="flex bg-[#1a1a1a] rounded-lg p-1 border border-[#2a2a2a]">
          {['front', 'back'].map((v) => (
            <button
              key={v}
              onClick={() => setView(v)}
              className={`px-4 py-1.5 text-xs font-bold rounded-md transition-all duration-200 ${
                view === v
                  ? 'bg-[#cafd00] text-[#0e0e0e]'
                  : 'text-[#adaaaa] hover:text-white'
              }`}
            >
              {v === 'front' ? 'Frente' : 'Espalda'}
            </button>
          ))}
        </div>
      </div>

      <div className="flex flex-col lg:flex-row gap-8 items-start">
        {/* SVG Body */}
        <div className="relative flex-shrink-0 mx-auto" style={{ width: 200 }}>
          <AnimatePresence mode="wait">
            <motion.div
              key={view}
              initial={{ opacity: 0, x: view === 'front' ? -20 : 20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: view === 'front' ? 20 : -20 }}
              transition={{ duration: 0.25 }}
              style={{ width: 200 }}
            >
              <BodySVG
                muscles={view === 'front' ? FRONT_MUSCLES : BACK_MUSCLES}
                muscleData={muscleData}
                view={view}
                onHover={setTooltip}
                tooltip={tooltip}
              />
            </motion.div>
          </AnimatePresence>

          {/* Tooltip */}
          <AnimatePresence>
            {tooltip && (
              <motion.div
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.9 }}
                transition={{ duration: 0.12 }}
                className="absolute pointer-events-none z-20"
                style={{
                  left: Math.min(Math.max(tooltip.x - 60, 0), 120),
                  top: Math.max(tooltip.y - 72, 0),
                  width: 130,
                }}
              >
                <div className="bg-[#0e0e0e] border border-[#333] rounded-lg px-3 py-2 shadow-xl">
                  <p className="text-xs font-bold text-white">{tooltip.label}</p>
                  <div className="flex items-center gap-1 mt-1">
                    {(() => {
                      const nivel = tooltip.data?.nivel ?? 'recuperado';
                      const s = NIVEL_STYLES[nivel];
                      return (
                        <>
                          <span className="w-2 h-2 rounded-full inline-block" style={{ background: s.color }} />
                          <span className="text-[10px]" style={{ color: s.color }}>{s.label}</span>
                        </>
                      );
                    })()}
                  </div>
                  {tooltip.data && tooltip.data.series > 0 && (
                    <div className="mt-1 space-y-0.5">
                      <p className="text-[10px] text-[#adaaaa]">{tooltip.data.series} series esta semana</p>
                      {tooltip.data.volumen > 0 && (
                        <p className="text-[10px] text-[#adaaaa]">{Math.round(tooltip.data.volumen).toLocaleString()} kg vol.</p>
                      )}
                    </div>
                  )}
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </div>

        {/* Right panel: legend + muscle breakdown */}
        <div className="flex-1 flex flex-col gap-4 min-w-0">
          {/* Legend */}
          <div className="grid grid-cols-2 gap-2">
            {Object.entries(NIVEL_STYLES).map(([key, s]) => (
              <div key={key} className="flex items-center gap-2 bg-[#161616] rounded-lg px-3 py-2">
                <span className="w-3 h-3 rounded-full flex-shrink-0" style={{ background: s.color, boxShadow: `0 0 6px ${s.color}66` }} />
                <div>
                  <p className="text-xs font-semibold text-white">{s.label}</p>
                  <p className="text-[10px] text-[#555]">
                    {key === 'recuperado' && '0 series'}
                    {key === 'bajo' && '1 – 6 series'}
                    {key === 'moderado' && '7 – 12 series'}
                    {key === 'alto' && '13+ series'}
                  </p>
                </div>
                <span className="ml-auto text-xs font-bold" style={{ color: s.color }}>
                  {getLevelCount(key)}
                </span>
              </div>
            ))}
          </div>

          {/* Per-muscle breakdown */}
          <div className="bg-[#161616] rounded-xl border border-[#222] overflow-hidden">
            <div className="px-4 py-3 border-b border-[#222]">
              <p className="text-xs font-bold text-[#adaaaa] uppercase tracking-wider">Detalle por grupo muscular</p>
            </div>
            <div className="divide-y divide-[#1e1e1e] max-h-64 overflow-y-auto">
              {Object.entries(muscleData).map(([muscle, data]) => {
                const nivel = data?.nivel ?? 'recuperado';
                const style = NIVEL_STYLES[nivel];
                const barPct = Math.min((data?.series ?? 0) / 15 * 100, 100);
                const label = muscle.replace('_', ' ').replace(/\b\w/g, (c) => c.toUpperCase());

                return (
                  <div key={muscle} className="flex items-center gap-3 px-4 py-2.5">
                    <div className="w-2 h-2 rounded-full flex-shrink-0" style={{ background: style.color }} />
                    <span className="text-xs text-white capitalize w-28 flex-shrink-0">{label}</span>
                    <div className="flex-1 bg-[#222] rounded-full h-1.5 overflow-hidden">
                      <div
                        className="h-full rounded-full transition-all duration-500"
                        style={{ width: `${barPct}%`, background: style.color }}
                      />
                    </div>
                    <span className="text-xs text-[#adaaaa] w-14 text-right flex-shrink-0">
                      {data?.series ?? 0} series
                    </span>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
