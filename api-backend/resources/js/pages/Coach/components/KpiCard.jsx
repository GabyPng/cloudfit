

export default function KpiCard({ label, value, icon: Icon, iconColor = '', valueColor = 'text-[#cafd00]', children }) {
  return (
    <div className="bg-[#1a1a1a] rounded-xl p-6 relative overflow-hidden group">
      <div className={`absolute top-0 right-0 p-4 opacity-10 group-hover:opacity-20 transition-opacity ${iconColor}`}>
        <Icon size={56} />
      </div>
      <p className="text-[#adaaaa] text-xs font-headline uppercase tracking-widest mb-2">{label}</p>
      <h3 className={`text-4xl font-headline font-black ${valueColor}`}>{value}</h3>
      <div className="mt-4">{children}</div>
    </div>
  );
}
