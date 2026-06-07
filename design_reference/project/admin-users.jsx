// Taskko Admin — Users management
// ===========================================================

const SAMPLE_USERS = [
  { id:'u1',  name:'Sara Khan',      email:'sara@uni.edu',        rank:'Pro',     points:1240, streak:5,  tier:'Free', status:'active',    joined:'Mar 12',  flags:0 },
  { id:'u2',  name:'Omar Tariq',     email:'omar@lums.edu.pk',    rank:'Elite',   points:1920, streak:12, tier:'Pro',  status:'active',    joined:'Feb 28',  flags:0 },
  { id:'u3',  name:'Zara Naseer',    email:'zara@nu.edu.pk',      rank:'Master',  points:2480, streak:21, tier:'Pro',  status:'active',    joined:'Jan 14',  flags:0 },
  { id:'u4',  name:'Bilal Ahmed',    email:'bilal@iba.edu',       rank:'Rookie',  points:520,  streak:2,  tier:'Free', status:'active',    joined:'May 02',  flags:0 },
  { id:'u5',  name:'Ana Mendez',     email:'ana@kth.se',          rank:'Pro',     points:1640, streak:8,  tier:'Free', status:'active',    joined:'Apr 18',  flags:0 },
  { id:'u6',  name:'Aliyah Saeed',   email:'aliyah@nust.edu',     rank:'Rookie',  points:680,  streak:0,  tier:'Free', status:'inactive',  joined:'Mar 30',  flags:0 },
  { id:'u7',  name:'Maya Reyes',     email:'maya@gmail.com',      rank:'Elite',   points:2150, streak:14, tier:'Pro',  status:'active',    joined:'Feb 06',  flags:0 },
  { id:'u8',  name:'Junaid Iqbal',   email:'junaid@uet.edu.pk',   rank:'Pro',     points:1180, streak:4,  tier:'Free', status:'active',    joined:'May 09',  flags:1 },
  { id:'u9',  name:'Hassan Raza',    email:'hraza@uni.edu',       rank:'Legend',  points:4320, streak:42, tier:'Pro',  status:'active',    joined:'Dec 04',  flags:0 },
  { id:'u10', name:'Mira Patel',     email:'mira@uni.edu',        rank:'Rookie',  points:120,  streak:1,  tier:'Free', status:'suspended', joined:'May 18',  flags:3 },
  { id:'u11', name:'Daniel Ortega',  email:'daniel@nu.edu',       rank:'Pro',     points:1410, streak:6,  tier:'Free', status:'active',    joined:'Apr 02',  flags:0 },
  { id:'u12', name:'Sana Mehmood',   email:'sana@fast.edu.pk',    rank:'Elite',   points:1820, streak:9,  tier:'Pro',  status:'active',    joined:'Jan 22',  flags:0 },
];

function AdminUsers() {
  const [filter, setFilter] = React.useState('all');
  const [selected, setSelected] = React.useState(null);
  const filtered = SAMPLE_USERS.filter(u => {
    if (filter === 'all') return true;
    if (filter === 'pro') return u.tier === 'Pro';
    if (filter === 'free') return u.tier === 'Free';
    if (filter === 'suspended') return u.status === 'suspended';
    if (filter === 'flagged') return u.flags > 0;
    return true;
  });

  return (
    <div style={{display:'flex', flexDirection:'column', minHeight:'100%'}}>
      <AdminTopBar
        title="Users"
        subtitle={`${SAMPLE_USERS.length.toLocaleString()} total · 12,396 active this month`}
        actions={
          <>
            <button style={{
              border:'1px solid #ECECF3', background:'#fff', color:'#2E2E3F',
              padding:'8px 14px', borderRadius:10, fontSize:12.5, fontWeight:700, cursor:'pointer',
              display:'inline-flex', alignItems:'center', gap:6,
            }}><Icon name="share" size={14}/> Export CSV</button>
            <button style={{
              border:'none', background:'linear-gradient(180deg,#3BC2F5,#1FB6F0)', color:'#fff',
              padding:'8px 14px', borderRadius:10, fontSize:12.5, fontWeight:700, cursor:'pointer',
              display:'inline-flex', alignItems:'center', gap:6,
              boxShadow:'0 6px 14px -6px rgba(31,182,240,0.55)',
            }}><Icon name="plus" size={14}/> Invite admin</button>
          </>
        }
      />

      <div style={{padding:'18px 28px 28px', flex:1}}>
        {/* Filter chips */}
        <div style={{display:'flex', gap:6, marginBottom:14}}>
          {[
            {k:'all',       label:'All',        count:SAMPLE_USERS.length},
            {k:'pro',       label:'Pro tier',   count:SAMPLE_USERS.filter(u=>u.tier==='Pro').length, tone:'#1FB6F0'},
            {k:'free',      label:'Free tier',  count:SAMPLE_USERS.filter(u=>u.tier==='Free').length},
            {k:'flagged',   label:'Flagged',    count:SAMPLE_USERS.filter(u=>u.flags>0).length, tone:'#F26B47'},
            {k:'suspended', label:'Suspended',  count:SAMPLE_USERS.filter(u=>u.status==='suspended').length, tone:'#A855F7'},
          ].map(f => {
            const active = filter === f.k;
            return (
              <button key={f.k} onClick={() => setFilter(f.k)} className="tap" style={{
                border: active ? '1.5px solid #1FB6F0' : '1px solid #ECECF3',
                background: active ? '#DDF3FE' : '#fff',
                color: active ? '#0E8FC4' : '#2E2E3F',
                padding:'7px 14px', borderRadius:99, fontSize:12.5, fontWeight:700, cursor:'pointer',
                display:'inline-flex', alignItems:'center', gap:6,
              }}>
                {f.label}
                <span style={{
                  fontSize:10.5, fontWeight:800, color: active ? '#0E8FC4' : '#A8A8BC',
                  background: active ? 'rgba(31,182,240,0.18)' : '#F4F6FA',
                  padding:'1px 6px', borderRadius:99,
                }}>{f.count}</span>
              </button>
            );
          })}
        </div>

        <div style={{display:'grid', gridTemplateColumns: selected ? '1fr 320px' : '1fr', gap:14}}>
          {/* Table */}
          <AdminPanel padding={0}>
            <div style={{maxHeight: selected ? 580 : 660, overflow:'auto'}}>
              <table style={{width:'100%', borderCollapse:'collapse', fontSize:13}}>
                <thead>
                  <tr style={{background:'#FAFBFD', position:'sticky', top:0}}>
                    {['Student','Rank · Streak','Points','Tier','Status','Joined',''].map(h => (
                      <th key={h} style={{
                        textAlign:'left', padding:'10px 14px',
                        fontSize:10.5, fontWeight:800, color:'#6B6B82', letterSpacing:0.6, textTransform:'uppercase',
                        borderBottom:'1px solid #ECECF3',
                      }}>{h}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {filtered.map(u => (
                    <tr key={u.id} onClick={() => setSelected(u)} style={{
                      cursor:'pointer',
                      background: selected && selected.id === u.id ? '#F7FBFD' : 'transparent',
                      borderLeft: selected && selected.id === u.id ? '3px solid #1FB6F0' : '3px solid transparent',
                    }}>
                      <td style={{padding:'10px 14px', borderBottom:'1px solid #F4F6FA'}}>
                        <div style={{display:'flex', alignItems:'center', gap:10}}>
                          <div style={{
                            width:30, height:30, borderRadius:99,
                            background: 'linear-gradient(135deg,#FFD7BC,#FF8A65)',
                            color:'#fff', display:'grid', placeItems:'center', fontWeight:800, fontSize:12,
                          }}>{u.name[0]}</div>
                          <div>
                            <div style={{fontWeight:700, color:'#0F0F1A'}}>{u.name}{u.flags > 0 && <span style={{marginLeft:6, fontSize:10, color:'#F26B47', fontWeight:800, background:'#FFE6DD', padding:'1px 6px', borderRadius:99}}>{u.flags} flag{u.flags>1?'s':''}</span>}</div>
                            <div style={{fontSize:11, color:'#6B6B82'}}>{u.email}</div>
                          </div>
                        </div>
                      </td>
                      <td style={{padding:'10px 14px', borderBottom:'1px solid #F4F6FA'}}>
                        <div style={{display:'flex', alignItems:'center', gap:6, fontWeight:600}}>
                          <span style={{
                            fontSize:11, fontWeight:800, color:'#0E8FC4',
                            background:'#DDF3FE', padding:'2px 7px', borderRadius:99,
                          }}>{u.rank}</span>
                          <span style={{fontSize:12, color:'#6B6B82', display:'inline-flex', alignItems:'center', gap:3}}>
                            <Icon name="fire" size={12} color={u.streak > 0 ? '#FF8A65' : '#A8A8BC'}/> {u.streak}d
                          </span>
                        </div>
                      </td>
                      <td className="mono" style={{padding:'10px 14px', borderBottom:'1px solid #F4F6FA', fontWeight:700, color:'#0F0F1A'}}>{u.points.toLocaleString()}</td>
                      <td style={{padding:'10px 14px', borderBottom:'1px solid #F4F6FA'}}>
                        {u.tier === 'Pro' ? (
                          <span style={{fontSize:11, fontWeight:800, color:'#fff', background:'linear-gradient(135deg,#FF8A65,#F26B47)', padding:'3px 8px', borderRadius:6}}>PRO</span>
                        ) : (
                          <span style={{fontSize:11, fontWeight:700, color:'#6B6B82', background:'#F4F6FA', padding:'3px 8px', borderRadius:6}}>Free</span>
                        )}
                      </td>
                      <td style={{padding:'10px 14px', borderBottom:'1px solid #F4F6FA'}}>
                        <span style={{
                          fontSize:11.5, fontWeight:700, display:'inline-flex', alignItems:'center', gap:5,
                          color: u.status==='active'?'#10B981':u.status==='inactive'?'#6B6B82':'#F26B47',
                        }}>
                          <span style={{width:7, height:7, borderRadius:99, background:'currentColor'}}/>
                          {u.status}
                        </span>
                      </td>
                      <td className="mono" style={{padding:'10px 14px', borderBottom:'1px solid #F4F6FA', fontSize:11.5, color:'#6B6B82'}}>{u.joined}</td>
                      <td style={{padding:'10px 14px', borderBottom:'1px solid #F4F6FA', textAlign:'right'}}>
                        <Icon name="dots" size={16} color="#A8A8BC"/>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </AdminPanel>

          {/* Detail drawer */}
          {selected && <UserDetailDrawer user={selected} onClose={() => setSelected(null)}/>}
        </div>
      </div>
    </div>
  );
}

function UserDetailDrawer({ user, onClose }) {
  return (
    <div style={{
      background:'#fff', border:'1px solid #ECECF3', borderRadius:16,
      padding:18, position:'sticky', top:24, alignSelf:'start',
    }}>
      <div style={{display:'flex', justifyContent:'space-between', alignItems:'flex-start', marginBottom:14}}>
        <div style={{fontSize:10.5, fontWeight:800, color:'#0E8FC4', letterSpacing:0.6, textTransform:'uppercase'}}>User profile</div>
        <button onClick={onClose} style={{
          border:'none', background:'#F4F6FA', width:28, height:28, borderRadius:99,
          display:'grid', placeItems:'center', cursor:'pointer',
        }}><Icon name="close" size={14} color="#6B6B82"/></button>
      </div>
      <div style={{display:'flex', flexDirection:'column', alignItems:'center', textAlign:'center', marginBottom:14}}>
        <div style={{
          width:64, height:64, borderRadius:99,
          background:'linear-gradient(135deg,#FFD7BC,#FF8A65)',
          color:'#fff', display:'grid', placeItems:'center', fontWeight:800, fontSize:24,
          boxShadow:'0 8px 20px -8px rgba(255,138,101,0.55)',
        }}>{user.name[0]}</div>
        <div style={{fontFamily:'Fraunces, serif', fontWeight:700, fontSize:20, color:'#0F0F1A', marginTop:8}}>{user.name}</div>
        <div style={{fontSize:12, color:'#6B6B82', marginTop:1}}>{user.email}</div>
        <div style={{
          marginTop:8, display:'inline-flex', alignItems:'center', gap:4,
          background:'#DDF3FE', color:'#0E8FC4', padding:'3px 10px', borderRadius:99,
          fontSize:11, fontWeight:800,
        }}>
          <Icon name="trophy" size={11}/> {user.rank} · {user.points.toLocaleString()} pts
        </div>
      </div>

      {/* Stats */}
      <div style={{display:'grid', gridTemplateColumns:'1fr 1fr', gap:8, marginBottom:14}}>
        {[
          {l:'Streak', v:`${user.streak}d`,  c:'#FF8A65'},
          {l:'Tier',   v:user.tier,           c:'#1FB6F0'},
          {l:'Status', v:user.status,         c:'#10B981'},
          {l:'Joined', v:user.joined,         c:'#A855F7'},
        ].map(s => (
          <div key={s.l} style={{
            background:'#F7FBFD', borderRadius:10, padding:'8px 10px',
          }}>
            <div style={{fontSize:10, fontWeight:800, color:'#6B6B82', letterSpacing:0.4, textTransform:'uppercase'}}>{s.l}</div>
            <div style={{fontSize:14, fontWeight:800, color:s.c, marginTop:1, textTransform:'capitalize'}}>{s.v}</div>
          </div>
        ))}
      </div>

      <div style={{fontSize:11, fontWeight:800, color:'#6B6B82', letterSpacing:0.4, textTransform:'uppercase', marginBottom:6}}>Activity</div>
      <div style={{display:'flex', flexDirection:'column', gap:6, fontSize:12}}>
        {[
          ['Tasks this week',     '23'],
          ['Goals broken down',   '7'],
          ['Badges earned',       '12'],
          ['Reports against',     user.flags || 0],
        ].map(([l, v]) => (
          <div key={l} style={{display:'flex', justifyContent:'space-between'}}>
            <span style={{color:'#6B6B82'}}>{l}</span>
            <span className="mono" style={{fontWeight:700, color:'#0F0F1A'}}>{v}</span>
          </div>
        ))}
      </div>

      <div style={{borderTop:'1px solid #ECECF3', marginTop:14, paddingTop:12, display:'flex', flexDirection:'column', gap:6}}>
        <button style={{
          border:'1px solid #ECECF3', background:'#fff', color:'#0F0F1A',
          padding:'9px 12px', borderRadius:10, fontSize:12.5, fontWeight:700, cursor:'pointer',
        }}>Message user</button>
        <button style={{
          border:'1px solid #ECECF3', background:'#fff', color:'#0F0F1A',
          padding:'9px 12px', borderRadius:10, fontSize:12.5, fontWeight:700, cursor:'pointer',
        }}>Grant 100 bonus pts</button>
        {user.status === 'suspended' ? (
          <button style={{
            border:'none', background:'#10B981', color:'#fff',
            padding:'9px 12px', borderRadius:10, fontSize:12.5, fontWeight:700, cursor:'pointer',
          }}>Reinstate account</button>
        ) : (
          <button style={{
            border:'1px solid #F26B47', background:'#FFE6DD', color:'#F26B47',
            padding:'9px 12px', borderRadius:10, fontSize:12.5, fontWeight:700, cursor:'pointer',
          }}>Suspend account</button>
        )}
      </div>
    </div>
  );
}

Object.assign(window, { AdminUsers });
