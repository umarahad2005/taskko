// Taskko Admin — sidebar + shared UI
// ===========================================================

const ADMIN_NAV = [
  { k: 'dashboard',  label: 'Dashboard',     icon: 'home',     badge: null },
  { k: 'users',      label: 'Users',         icon: 'users',    badge: '12,4k' },
  { k: 'moderation', label: 'Moderation',    icon: 'shield',   badge: '7' },
  { k: 'ai',         label: 'AI insights',   icon: 'sparkles', badge: null },
  { k: 'revenue',    label: 'Revenue',       icon: 'trophy',   badge: 'NEW' },
  { k: 'settings',   label: 'Settings',      icon: 'edit',     badge: null },
];

function AdminSidebar({ tab, setTab, onExit, admin }) {
  return (
    <div style={{
      width: 240, flexShrink: 0,
      background: '#0F1B26',
      color: '#E6F2F8',
      padding: '22px 14px',
      display: 'flex', flexDirection: 'column', gap: 4,
      borderRight: '1px solid rgba(255,255,255,0.06)',
    }}>
      {/* Brand */}
      <div style={{
        display:'flex', alignItems:'center', gap:10, padding:'4px 8px 18px',
        borderBottom: '1px solid rgba(255,255,255,0.06)', marginBottom:10,
      }}>
        <div style={{
          width:34, height:34, borderRadius:10,
          background: 'linear-gradient(135deg, #5BCBF5, #1FB6F0, #0A6FA8)',
          display:'grid', placeItems:'center',
          color:'#fff', fontWeight:800, fontSize:18,
          fontFamily: 'Georgia, serif',
          boxShadow:'inset 0 1px 0 rgba(255,255,255,0.3)',
        }}>t</div>
        <div>
          <div style={{fontFamily:'Georgia, serif', fontWeight:700, fontSize:16, color:'#fff'}}>taskko</div>
          <div style={{fontSize:10, color:'#7BB3CB', fontWeight:700, letterSpacing:1, textTransform:'uppercase'}}>Admin Console</div>
        </div>
      </div>

      {/* Section label */}
      <div style={{fontSize:10, fontWeight:800, color:'#5B7B8E', letterSpacing:1.4, textTransform:'uppercase', padding:'6px 10px 4px'}}>Manage</div>

      {/* Nav items */}
      {ADMIN_NAV.map(n => {
        const active = tab === n.k;
        return (
          <button key={n.k} onClick={() => setTab(n.k)} className="tap" style={{
            border:'none', textAlign:'left', cursor:'pointer',
            background: active ? 'linear-gradient(90deg, rgba(31,182,240,0.18), rgba(31,182,240,0.05))' : 'transparent',
            color: active ? '#fff' : '#B4CCD8',
            padding: '10px 12px', borderRadius: 10,
            display:'flex', alignItems:'center', gap:10,
            fontWeight: active ? 700 : 600, fontSize: 13.5,
            position:'relative',
          }}>
            {active && <div style={{position:'absolute', left:-14, top:8, bottom:8, width:3, borderRadius:99, background:'#1FB6F0'}}/>}
            <span style={{color: active ? '#1FB6F0' : '#7BB3CB'}}><Icon name={n.icon} size={17} stroke={1.8}/></span>
            <span style={{flex:1}}>{n.label}</span>
            {n.badge && (
              <span style={{
                fontSize:10, fontWeight:800, padding:'2px 7px', borderRadius:99,
                background: n.badge === 'NEW' ? '#FF8A65' : (n.k === 'moderation' ? '#F26B47' : 'rgba(91,203,245,0.18)'),
                color: n.badge === 'NEW' || n.k === 'moderation' ? '#fff' : '#5BCBF5',
                letterSpacing: 0.4,
              }}>{n.badge}</span>
            )}
          </button>
        );
      })}

      <div style={{flex:1}}/>

      {/* Admin user card */}
      <div style={{
        padding:'10px 12px', borderRadius:12,
        background:'rgba(255,255,255,0.04)',
        border:'1px solid rgba(255,255,255,0.06)',
        display:'flex', alignItems:'center', gap:10, marginBottom:8,
      }}>
        <div style={{
          width:32, height:32, borderRadius:99,
          background:'linear-gradient(135deg, #FFD7BC, #FF8A65)',
          display:'grid', placeItems:'center', color:'#fff', fontWeight:800, fontSize:13,
        }}>{(admin.name || 'A')[0]}</div>
        <div style={{flex:1, minWidth:0}}>
          <div style={{fontSize:12.5, fontWeight:700, color:'#fff', whiteSpace:'nowrap', overflow:'hidden', textOverflow:'ellipsis'}}>{admin.name}</div>
          <div style={{fontSize:10.5, color:'#7BB3CB', display:'flex', alignItems:'center', gap:4}}>
            <span style={{width:6, height:6, borderRadius:99, background:'#34D399'}}/> Super admin
          </div>
        </div>
      </div>

      <button onClick={onExit} className="tap" style={{
        border:'1px solid rgba(255,255,255,0.1)', background:'transparent',
        color:'#7BB3CB', padding:'9px 12px', borderRadius:10, fontWeight:600, fontSize:12,
        cursor:'pointer', display:'flex', alignItems:'center', justifyContent:'center', gap:6,
      }}>
        <Icon name="back" size={14}/> Back to phone preview
      </button>
    </div>
  );
}

function AdminTopBar({ title, subtitle, actions }) {
  return (
    <div style={{
      padding:'18px 28px',
      borderBottom:'1px solid #ECECF3',
      background:'#fff',
      display:'flex', alignItems:'center', justifyContent:'space-between', gap:20,
    }}>
      <div>
        <div style={{fontSize:11, fontWeight:800, color:'#0E8FC4', letterSpacing:1.4, textTransform:'uppercase'}}>Admin</div>
        <div style={{fontFamily:'Fraunces, serif', fontWeight:700, fontSize:24, letterSpacing:-0.4, color:'#0F0F1A', marginTop:1}}>{title}</div>
        {subtitle && <div style={{fontSize:13, color:'#6B6B82', marginTop:2}}>{subtitle}</div>}
      </div>
      <div style={{display:'flex', gap:8, alignItems:'center'}}>
        {/* Search */}
        <div style={{
          display:'flex', alignItems:'center', gap:8,
          background:'#F4F6FA', borderRadius:10, padding:'8px 12px',
          border:'1px solid #ECECF3', minWidth:240,
        }}>
          <Icon name="info" size={15} color="#A8A8BC"/>
          <input placeholder="Search users, goals, badges…" style={{
            border:'none', outline:'none', background:'transparent', fontSize:12.5, color:'#0F0F1A',
            flex:1, fontFamily:'inherit',
          }}/>
          <span className="mono" style={{
            fontSize:10, color:'#A8A8BC', background:'#fff', border:'1px solid #ECECF3',
            padding:'2px 5px', borderRadius:5, fontWeight:700,
          }}>⌘K</span>
        </div>
        {actions}
        <button style={{
          width:38, height:38, borderRadius:99, border:'1px solid #ECECF3', background:'#fff',
          display:'grid', placeItems:'center', cursor:'pointer', position:'relative',
        }}>
          <Icon name="bell" size={17} color="#6B6B82"/>
          <span style={{position:'absolute', top:6, right:8, width:8, height:8, borderRadius:99, background:'#FF8A65', border:'2px solid #fff'}}/>
        </button>
      </div>
    </div>
  );
}

// Stat card
function StatCard({ label, value, delta, deltaTone = 'up', spark, accent = '#1FB6F0' }) {
  const tone = deltaTone === 'up' ? '#10B981' : deltaTone === 'down' ? '#F26B47' : '#6B6B82';
  return (
    <div style={{
      background:'#fff', border:'1px solid #ECECF3', borderRadius:16,
      padding:'18px 20px', position:'relative', overflow:'hidden',
    }}>
      <div style={{position:'absolute', right:-20, top:-20, width:80, height:80, borderRadius:99, background:`${accent}12`}}/>
      <div style={{fontSize:11.5, fontWeight:700, color:'#6B6B82', letterSpacing:0.4, textTransform:'uppercase'}}>{label}</div>
      <div style={{fontFamily:'Fraunces, serif', fontWeight:700, fontSize:32, color:'#0F0F1A', marginTop:6, lineHeight:1, letterSpacing:-0.5}}>{value}</div>
      <div style={{display:'flex', alignItems:'center', justifyContent:'space-between', marginTop:8, position:'relative'}}>
        <div style={{
          display:'inline-flex', alignItems:'center', gap:3, fontSize:11.5, fontWeight:700, color:tone,
          background:`${tone}15`, padding:'3px 8px', borderRadius:99,
        }}>
          {deltaTone === 'up' ? '↑' : deltaTone === 'down' ? '↓' : '·'} {delta}
        </div>
        {spark && (
          <svg width="78" height="22" viewBox="0 0 78 22">
            <polyline points={spark} fill="none" stroke={accent} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"/>
          </svg>
        )}
      </div>
    </div>
  );
}

// Panel
function AdminPanel({ title, subtitle, action, children, padding = 18 }) {
  return (
    <div style={{
      background:'#fff', border:'1px solid #ECECF3', borderRadius:16,
      overflow:'hidden',
    }}>
      {title && (
        <div style={{
          padding:'14px 18px', borderBottom:'1px solid #ECECF3',
          display:'flex', alignItems:'center', justifyContent:'space-between',
        }}>
          <div>
            <div style={{fontWeight:700, fontSize:14.5, color:'#0F0F1A'}}>{title}</div>
            {subtitle && <div style={{fontSize:11.5, color:'#6B6B82', marginTop:1}}>{subtitle}</div>}
          </div>
          {action}
        </div>
      )}
      <div style={{padding}}>{children}</div>
    </div>
  );
}

Object.assign(window, { AdminSidebar, AdminTopBar, StatCard, AdminPanel });
