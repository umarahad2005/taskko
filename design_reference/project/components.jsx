// Taskko — shared components
// =====================================================

// ----- Tako Mascot: an original abstract "spark" character ------
function TakoMascot({ size = 96, mood = 'happy', animate = true }) {
  // mood: happy | focused | tired | excited | calm
  const cfg = {
    happy:   { eye: 'normal', mouth: 'smile',   hueA: '#5BCBF5', hueB: '#1FB6F0', glow: '#C7B8FF' },
    focused: { eye: 'focus',  mouth: 'line',    hueA: '#1FB6F0', hueB: '#0E8FC4', glow: '#7BCEEC' },
    tired:   { eye: 'sleepy', mouth: 'flat',    hueA: '#7BB3CB', hueB: '#3B7C9A', glow: '#CFD1EC' },
    excited: { eye: 'star',   mouth: 'open',    hueA: '#FF8A65', hueB: '#F26B47', glow: '#FFC7B3' },
    calm:    { eye: 'soft',   mouth: 'smile',   hueA: '#34D399', hueB: '#10B981', glow: '#A7E8C9' },
  }[mood] || {};

  return (
    <div style={{
      width: size, height: size, position: 'relative',
      animation: animate ? 'float 3.4s ease-in-out infinite' : 'none',
      display: 'inline-block',
    }}>
      <svg viewBox="0 0 100 100" width={size} height={size}>
        <defs>
          <radialGradient id={`tg-${mood}`} cx="35%" cy="30%" r="80%">
            <stop offset="0%" stopColor="#fff" stopOpacity="0.9"/>
            <stop offset="30%" stopColor={cfg.hueA}/>
            <stop offset="100%" stopColor={cfg.hueB}/>
          </radialGradient>
          <radialGradient id={`tg-glow-${mood}`} cx="50%" cy="50%" r="50%">
            <stop offset="0%" stopColor={cfg.glow} stopOpacity="0.55"/>
            <stop offset="100%" stopColor={cfg.glow} stopOpacity="0"/>
          </radialGradient>
        </defs>
        {/* Outer glow */}
        <circle cx="50" cy="52" r="46" fill={`url(#tg-glow-${mood})`} />
        {/* Body — rounded squircle */}
        <path d="M50 14 C 78 14, 86 22, 86 50 C 86 78, 78 86, 50 86 C 22 86, 14 78, 14 50 C 14 22, 22 14, 50 14 Z"
              fill={`url(#tg-${mood})`} />
        {/* Antenna spark */}
        <line x1="50" y1="14" x2="50" y2="6" stroke={cfg.hueB} strokeWidth="2.2" strokeLinecap="round"/>
        <circle cx="50" cy="4" r="3" fill={cfg.hueA} style={{animation: animate ? 'spark 1.6s ease-in-out infinite' : 'none', transformOrigin: '50px 4px'}}/>
        {/* Eyes */}
        {cfg.eye === 'normal' && (
          <g fill="#fff">
            <circle cx="38" cy="48" r="6.5" />
            <circle cx="62" cy="48" r="6.5" />
            <circle cx="39" cy="47" r="2.4" fill="#0F0F1A"/>
            <circle cx="63" cy="47" r="2.4" fill="#0F0F1A"/>
          </g>
        )}
        {cfg.eye === 'focus' && (
          <g stroke="#fff" strokeWidth="3" strokeLinecap="round" fill="none">
            <line x1="32" y1="48" x2="44" y2="48"/>
            <line x1="56" y1="48" x2="68" y2="48"/>
          </g>
        )}
        {cfg.eye === 'sleepy' && (
          <g stroke="#fff" strokeWidth="3" strokeLinecap="round" fill="none">
            <path d="M32 50 Q 38 44 44 50"/>
            <path d="M56 50 Q 62 44 68 50"/>
          </g>
        )}
        {cfg.eye === 'star' && (
          <g fill="#fff">
            <path d="M38 42 L40 47 L45 48 L40 49 L38 54 L36 49 L31 48 L36 47 Z"/>
            <path d="M62 42 L64 47 L69 48 L64 49 L62 54 L60 49 L55 48 L60 47 Z"/>
          </g>
        )}
        {cfg.eye === 'soft' && (
          <g fill="#fff">
            <ellipse cx="38" cy="49" rx="5" ry="4"/>
            <ellipse cx="62" cy="49" rx="5" ry="4"/>
            <circle cx="39" cy="48" r="2" fill="#0F0F1A"/>
            <circle cx="63" cy="48" r="2" fill="#0F0F1A"/>
          </g>
        )}
        {/* Mouth */}
        {cfg.mouth === 'smile' && (
          <path d="M40 64 Q 50 72 60 64" stroke="#fff" strokeWidth="3" strokeLinecap="round" fill="none"/>
        )}
        {cfg.mouth === 'line' && (
          <line x1="42" y1="66" x2="58" y2="66" stroke="#fff" strokeWidth="3" strokeLinecap="round"/>
        )}
        {cfg.mouth === 'flat' && (
          <path d="M42 68 Q 50 64 58 68" stroke="#fff" strokeWidth="3" strokeLinecap="round" fill="none"/>
        )}
        {cfg.mouth === 'open' && (
          <ellipse cx="50" cy="66" rx="6" ry="5" fill="#fff"/>
        )}
        {/* Cheek dots */}
        <circle cx="28" cy="58" r="3" fill="#fff" opacity="0.35"/>
        <circle cx="72" cy="58" r="3" fill="#fff" opacity="0.35"/>
      </svg>
    </div>
  );
}

// ----- Taskko wordmark / logo -----
function TaskkoLogo({ size = 22 }) {
  return (
    <div style={{display:'flex', alignItems:'center', gap:8}}>
      <div style={{
        width: size*1.2, height: size*1.2, borderRadius: size*0.35,
        background: 'linear-gradient(135deg, #5BCBF5 0%, #1FB6F0 55%, #0A6FA8 100%)',
        boxShadow: '0 6px 16px rgba(31,182,240,.35), inset 0 1px 0 rgba(255,255,255,.4)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        color: '#fff', fontWeight: 800, fontSize: size*0.7,
        fontFamily: 'Fraunces, serif',
      }}>t</div>
      <span style={{
        fontFamily: 'Fraunces, serif', fontWeight: 700, fontSize: size,
        letterSpacing: -0.5, color: 'var(--ink)',
      }}>taskko</span>
    </div>
  );
}

// ----- Rank badge -----
function RankBadge({ rank = 'Pro', points = 1240 }) {
  const tone = {
    Rookie:  { bg:'#E8EAF1', fg:'#6B6B82' },
    Pro:     { bg:'#DDF3FE', fg:'#1FB6F0' },
    Elite:   { bg:'#FFE6DD', fg:'#F26B47' },
    Master:  { bg:'#FFF1C9', fg:'#B98A12' },
    Legend:  { bg:'linear-gradient(135deg,#FFE6DD,#DDF3FE)', fg:'#1FB6F0' },
  }[rank] || {bg:'#DDF3FE', fg:'#1FB6F0'};
  return (
    <div style={{
      display:'inline-flex', alignItems:'center', gap:6,
      background: tone.bg, color: tone.fg,
      padding:'4px 10px 4px 8px', borderRadius: 999,
      fontWeight: 700, fontSize: 12, letterSpacing: 0.2,
    }}>
      <span style={{
        width:18, height:18, borderRadius:999,
        background:'rgba(255,255,255,0.6)',
        display:'inline-flex', alignItems:'center', justifyContent:'center',
        fontSize: 11,
      }}>★</span>
      {rank}
      <span style={{ opacity:.7, fontWeight:600, marginLeft:4 }}>· {points.toLocaleString()} pts</span>
    </div>
  );
}

// ----- Streak flame -----
function StreakFlame({ days = 5, size = 26, lit = true }) {
  return (
    <div style={{
      display:'inline-flex', alignItems:'center', gap:4,
      color: lit ? '#F26B47' : '#A8A8BC',
      fontWeight: 800, fontSize: size*0.6,
    }}>
      <svg width={size} height={size} viewBox="0 0 24 24">
        <defs>
          <linearGradient id="fl" x1="0" x2="0" y1="0" y2="1">
            <stop offset="0%" stopColor="#FFC062"/>
            <stop offset="50%" stopColor="#FF8A65"/>
            <stop offset="100%" stopColor="#F26B47"/>
          </linearGradient>
        </defs>
        <path d="M12 2 C 14 6 18 8 18 13 a 6 6 0 1 1 -12 0 c 0 -3 2 -5 3 -7 c 1 2 2 3 4 2 c -1 -2 -0.5 -4 -1 -6 Z"
              fill={lit ? 'url(#fl)' : '#D8D8E5'} />
        <path d="M12 12 c 1.5 1 2.5 2.5 2.5 4 a 2.5 2.5 0 1 1 -5 0 c 0 -1.5 1 -2 2.5 -4 Z" fill="#FFF1C9"/>
      </svg>
      <span className="mono">{days}</span>
    </div>
  );
}

// ----- Section heading -----
function SectionH({ children, action }) {
  return (
    <div style={{display:'flex', alignItems:'baseline', justifyContent:'space-between', gap:10, margin: '6px 4px 10px'}}>
      <div style={{fontSize: 13, fontWeight: 700, color: 'var(--ink-3)', letterSpacing: 0.8, textTransform:'uppercase', whiteSpace:'nowrap'}}>{children}</div>
      {action && <div style={{fontSize: 12, fontWeight: 600, color: 'var(--primary)', whiteSpace:'nowrap'}}>{action}</div>}
    </div>
  );
}

// ----- Card -----
function Card({ children, style, onClick, accent }) {
  return (
    <div className={onClick ? 'tap' : ''} onClick={onClick} style={{
      background: 'var(--surface)',
      borderRadius: 22,
      padding: 16,
      border: '1px solid var(--line)',
      boxShadow: '0 1px 0 rgba(15,15,26,.02), 0 6px 22px -10px rgba(20,80,120,.12)',
      position: 'relative',
      ...style,
    }}>
      {accent && (
        <div style={{
          position:'absolute', inset:0, borderRadius:22, pointerEvents:'none',
          background: `linear-gradient(135deg, ${accent}22, transparent 50%)`,
        }}/>
      )}
      <div style={{position:'relative'}}>{children}</div>
    </div>
  );
}

// ----- Big CTA button -----
function PrimaryCTA({ children, onClick, icon, full = true, tone = 'primary', disabled }) {
  const tones = {
    primary: { bg:'linear-gradient(180deg,#3BC2F5,#1FB6F0)', fg:'#fff', shadow:'0 10px 28px -8px rgba(31,182,240,.6)' },
    energy:  { bg:'linear-gradient(180deg,#FF9B7A,#FF7A5C)', fg:'#fff', shadow:'0 10px 28px -8px rgba(255,138,101,.55)' },
    ghost:   { bg:'#fff', fg:'var(--ink)', shadow:'0 1px 0 rgba(15,15,26,.05), 0 2px 12px -6px rgba(20,80,120,.18)' },
  }[tone];
  return (
    <button className="tap" disabled={disabled} onClick={onClick} style={{
      width: full ? '100%' : 'auto',
      border: tone==='ghost' ? '1px solid var(--line-2)' : 'none',
      background: tones.bg, color: tones.fg,
      padding: '16px 18px', borderRadius: 18,
      fontWeight: 700, fontSize: 16, letterSpacing: 0.1,
      fontFamily: 'Manrope, sans-serif',
      display: 'inline-flex', alignItems:'center', justifyContent:'center', gap:10,
      boxShadow: tones.shadow,
      cursor:'pointer', opacity: disabled ? .5 : 1,
    }}>
      {icon}{children}
    </button>
  );
}

// ----- Icon (24px) -----
function Icon({ name, size = 22, color = 'currentColor', stroke = 1.8 }) {
  const props = { width:size, height:size, viewBox:'0 0 24 24', fill:'none', stroke:color, strokeWidth:stroke, strokeLinecap:'round', strokeLinejoin:'round' };
  const map = {
    home:   <svg {...props}><path d="M3 11l9-7 9 7v9a2 2 0 0 1-2 2h-4v-6h-6v6H5a2 2 0 0 1-2-2z"/></svg>,
    target: <svg {...props}><circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="5"/><circle cx="12" cy="12" r="1.6" fill={color}/></svg>,
    medal:  <svg {...props}><circle cx="12" cy="15" r="6"/><path d="M8 11L6 3l6 4 6-4-2 8"/></svg>,
    chat:   <svg {...props}><path d="M21 12a8 8 0 0 1-11.6 7.1L4 20l1-4.4A8 8 0 1 1 21 12z"/></svg>,
    check:  <svg {...props}><path d="M5 12l5 5L20 7"/></svg>,
    plus:   <svg {...props}><path d="M12 5v14M5 12h14"/></svg>,
    bolt:   <svg {...props}><path d="M13 2L4 14h7l-1 8 9-12h-7l1-8z" fill={color}/></svg>,
    share:  <svg {...props}><path d="M4 12v7a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-7"/><path d="M16 6l-4-4-4 4"/><path d="M12 2v14"/></svg>,
    play:   <svg {...props}><path d="M6 4l14 8-14 8z" fill={color}/></svg>,
    pause:  <svg {...props}><rect x="6" y="4" width="4" height="16" fill={color}/><rect x="14" y="4" width="4" height="16" fill={color}/></svg>,
    arrow:  <svg {...props}><path d="M5 12h14M13 5l7 7-7 7"/></svg>,
    back:   <svg {...props}><path d="M19 12H5M11 5l-7 7 7 7"/></svg>,
    sparkles: <svg {...props}><path d="M12 3l1.5 4.5L18 9l-4.5 1.5L12 15l-1.5-4.5L6 9l4.5-1.5z"/><path d="M19 14l.8 2.2L22 17l-2.2.8L19 20l-.8-2.2L16 17l2.2-.8z"/></svg>,
    shield: <svg {...props}><path d="M12 2l8 4v6c0 5-3.5 9-8 10-4.5-1-8-5-8-10V6z"/></svg>,
    fire:   <svg {...props}><path d="M12 2c2 4 6 6 6 11a6 6 0 1 1-12 0c0-3 2-5 3-7 1 2 2 3 4 2-1-2-.5-4-1-6z"/></svg>,
    send:   <svg {...props}><path d="M22 2L11 13M22 2l-7 20-4-9-9-4z"/></svg>,
    mic:    <svg {...props}><rect x="9" y="3" width="6" height="12" rx="3"/><path d="M5 11a7 7 0 0 0 14 0M12 18v3"/></svg>,
    close:  <svg {...props}><path d="M6 6l12 12M18 6l-12 12"/></svg>,
    info:   <svg {...props}><circle cx="12" cy="12" r="9"/><path d="M12 8v.01M11 12h1v5h1"/></svg>,
    bell:   <svg {...props}><path d="M18 16V11a6 6 0 1 0-12 0v5l-2 3h16zM10 22h4"/></svg>,
    coffee: <svg {...props}><path d="M4 10h12v6a4 4 0 0 1-4 4H8a4 4 0 0 1-4-4z"/><path d="M16 12h2a2 2 0 0 1 0 4h-2M8 2v3M12 2v3"/></svg>,
    refresh:<svg {...props}><path d="M3 12a9 9 0 0 1 15-6.7L21 8M21 3v5h-5M21 12a9 9 0 0 1-15 6.7L3 16M3 21v-5h5"/></svg>,
    edit:   <svg {...props}><path d="M12 20h9M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4z"/></svg>,
    dots:   <svg {...props}><circle cx="5" cy="12" r="1" fill={color}/><circle cx="12" cy="12" r="1" fill={color}/><circle cx="19" cy="12" r="1" fill={color}/></svg>,
    trophy: <svg {...props}><path d="M8 21h8M12 17v4M7 4h10v5a5 5 0 0 1-10 0z"/><path d="M5 6H3a3 3 0 0 0 4 3M19 6h2a3 3 0 0 1-4 3"/></svg>,
    crown:  <svg {...props}><path d="M3 7l4 4 5-6 5 6 4-4-2 12H5z"/></svg>,
    users:  <svg {...props}><circle cx="9" cy="8" r="4"/><path d="M2 21a7 7 0 0 1 14 0"/><circle cx="17" cy="9" r="3"/><path d="M22 20a5 5 0 0 0-5-5"/></svg>,
    heart:  <svg {...props}><path d="M12 21s-7-4.5-7-10a4 4 0 0 1 7-2.7A4 4 0 0 1 19 11c0 5.5-7 10-7 10z"/></svg>,
    moon:   <svg {...props}><path d="M21 12.8A8 8 0 1 1 11.2 3a6 6 0 0 0 9.8 9.8z"/></svg>,
    sun:    <svg {...props}><circle cx="12" cy="12" r="4"/><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"/></svg>,
    flag:   <svg {...props}><path d="M4 21V4h12l-2 4 2 4H4"/></svg>,
    calendar:<svg {...props}><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M16 3v4M8 3v4M3 11h18"/></svg>,
  };
  return map[name] || null;
}

// ----- Tab bar -----
function TabBar({ tab, setTab }) {
  const tabs = [
    { k:'home',   label:'Home',     icon:'home' },
    { k:'plan',   label:'Plan',     icon:'target' },
    { k:'hub',    label:'Hub',      icon:'trophy' },
    { k:'chat',   label:'Tako',     icon:'sparkles' },
  ];
  return (
    <div style={{
      position:'absolute', left:12, right:12, bottom:18, zIndex:30,
      background:'rgba(255,255,255,0.92)',
      backdropFilter:'blur(20px) saturate(140%)',
      WebkitBackdropFilter:'blur(20px) saturate(140%)',
      border:'1px solid rgba(0,0,0,0.06)',
      borderRadius:28, padding:'10px 8px',
      boxShadow:'0 12px 30px -12px rgba(20,80,120,0.25)',
      display:'flex', justifyContent:'space-around',
    }}>
      {tabs.map(t => {
        const active = tab === t.k;
        return (
          <button key={t.k} className="tap" onClick={() => setTab(t.k)} style={{
            border:'none', background:'transparent', cursor:'pointer',
            display:'flex', flexDirection:'column', alignItems:'center', gap:2,
            padding:'4px 10px', minWidth:54,
            color: active ? 'var(--primary)' : 'var(--ink-3)',
          }}>
            <div style={{
              padding: 6, borderRadius: 14,
              background: active ? 'var(--primary-soft)' : 'transparent',
              transition: 'background .2s',
            }}>
              <Icon name={t.icon} size={20} stroke={active ? 2.2 : 1.8} />
            </div>
            <span style={{fontSize:10.5, fontWeight: active ? 700 : 600}}>{t.label}</span>
          </button>
        );
      })}
    </div>
  );
}

// ----- HCI annotation pin (visible when annotate mode is on) -----
function HCIPin({ n, title, principle, body, side = 'right', top = 0 }) {
  const [open, setOpen] = React.useState(false);
  const offsets = {
    right: { right: -8, top },
    left:  { left: -8, top },
  };
  return (
    <div style={{position:'absolute', zIndex:25, ...offsets[side]}}>
      <button onClick={() => setOpen(o => !o)} style={{
        width: 22, height: 22, borderRadius: 99,
        border: '2px solid #fff',
        background: 'linear-gradient(135deg,#FF9B7A,#FF7A5C)',
        color: '#fff', fontWeight: 800, fontSize: 11,
        cursor: 'pointer',
        boxShadow:'0 4px 14px -2px rgba(242,107,71,.55), 0 0 0 4px rgba(242,107,71,.18)',
        animation: 'pulse-ring 2s infinite',
      }}>{n}</button>
      {open && (
        <div className="fade-in" style={{
          position:'absolute', top: 28,
          [side==='right'?'right':'left']: 0,
          width: 230,
          background: '#0F0F1A', color:'#fff',
          padding: 12, borderRadius: 14,
          fontSize: 11.5, lineHeight: 1.5,
          boxShadow:'0 18px 40px -10px rgba(0,0,0,0.5)',
          zIndex: 40,
        }}>
          <div style={{fontWeight:700, fontSize:11, color:'#FF9B7A', letterSpacing:0.4, textTransform:'uppercase', marginBottom:4}}>{principle}</div>
          <div style={{fontWeight:700, marginBottom:4}}>{title}</div>
          <div style={{opacity:.85}}>{body}</div>
        </div>
      )}
    </div>
  );
}

Object.assign(window, { TakoMascot, TaskkoLogo, RankBadge, StreakFlame, SectionH, Card, PrimaryCTA, Icon, TabBar, HCIPin });
