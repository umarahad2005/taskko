// Taskko Admin — Moderation, AI Insights, Revenue, Settings
// ===========================================================

function AdminModeration() {
  const [filter, setFilter] = React.useState('all');
  const reports = [
    { id:'r1', type:'share-card', reporter:'Maya R.',  target:'Junaid I.',   reason:'Offensive language in shared report card', time:'12m ago', severity:'high',   preview:'"this class is for [redacted]" — posted as report card caption'},
    { id:'r2', type:'badge',      reporter:'Ana M.',   target:'Mira P.',     reason:'Suspected fake streak / cheating',         time:'1h ago',  severity:'medium', preview:'Mira logged 14 tasks in 4 minutes — likely automated'},
    { id:'r3', type:'chat',       reporter:'Auto',     target:'@goalbreaker',reason:'Tako reply flagged: harmful advice',       time:'2h ago',  severity:'high',   preview:'Tako suggested skipping meds to "stay focused"'},
    { id:'r4', type:'squad',      reporter:'Bilal A.', target:'CS-201 grind', reason:'Spam invitations',                         time:'3h ago',  severity:'low',    preview:'Squad sent 40+ invites to non-classmates'},
    { id:'r5', type:'profile',    reporter:'Hassan R.',target:'newuser_8821', reason:'Impersonation attempt',                    time:'5h ago',  severity:'medium', preview:'Profile claims to be a TA but no verification'},
    { id:'r6', type:'share-card', reporter:'Zara N.',  target:'@anon_user',   reason:'NSFW content in shared image',             time:'8h ago',  severity:'high',   preview:'Image attached to weekly report card'},
    { id:'r7', type:'chat',       reporter:'Auto',     target:'@studentX',    reason:'Mental health distress signal',            time:'1d ago',  severity:'high',   preview:'Multiple messages mentioning self-harm — auto-routed to safety team'},
  ];

  const filtered = filter === 'all' ? reports : reports.filter(r => r.severity === filter);

  return (
    <div>
      <AdminTopBar
        title="Moderation queue"
        subtitle={`${reports.length} items pending · ${reports.filter(r=>r.severity==='high').length} flagged as high severity`}
        actions={
          <button style={{
            border:'none', background:'#0F0F1A', color:'#fff',
            padding:'8px 14px', borderRadius:10, fontSize:12.5, fontWeight:700, cursor:'pointer',
            display:'inline-flex', alignItems:'center', gap:6,
          }}><Icon name="shield" size={14}/> Policy docs</button>
        }
      />
      <div style={{padding:'18px 28px 28px'}}>
        {/* Severity filter */}
        <div style={{display:'flex', gap:6, marginBottom:14}}>
          {[
            {k:'all',    label:'All',    tone:'#6B6B82'},
            {k:'high',   label:'High',   tone:'#F26B47'},
            {k:'medium', label:'Medium', tone:'#F5C544'},
            {k:'low',    label:'Low',    tone:'#34D399'},
          ].map(s => {
            const active = filter === s.k;
            return (
              <button key={s.k} onClick={() => setFilter(s.k)} className="tap" style={{
                border: active ? `1.5px solid ${s.tone}` : '1px solid #ECECF3',
                background: active ? `${s.tone}15` : '#fff',
                color: active ? s.tone : '#2E2E3F',
                padding:'7px 14px', borderRadius:99, fontSize:12.5, fontWeight:700, cursor:'pointer',
              }}>{s.label}</button>
            );
          })}
        </div>

        <div style={{display:'flex', flexDirection:'column', gap:10}}>
          {filtered.map(r => (
            <div key={r.id} style={{
              background:'#fff', border:'1px solid #ECECF3', borderRadius:14,
              padding:'14px 18px',
              borderLeft: `4px solid ${r.severity==='high'?'#F26B47':r.severity==='medium'?'#F5C544':'#34D399'}`,
            }}>
              <div style={{display:'flex', alignItems:'flex-start', gap:14}}>
                <div style={{
                  width:38, height:38, borderRadius:10,
                  background: r.severity==='high'?'#FFE6DD':r.severity==='medium'?'#FFF5D1':'#D6F5E6',
                  color: r.severity==='high'?'#F26B47':r.severity==='medium'?'#B98A12':'#10B981',
                  display:'grid', placeItems:'center', flexShrink:0,
                }}><Icon name={r.type==='chat'?'chat':r.type==='badge'?'medal':r.type==='squad'?'users':r.type==='profile'?'sparkles':'flag'} size={18}/></div>

                <div style={{flex:1, minWidth:0}}>
                  <div style={{display:'flex', alignItems:'center', gap:8, flexWrap:'wrap'}}>
                    <span style={{
                      fontSize:10, fontWeight:800, padding:'2px 7px', borderRadius:5,
                      background: r.severity==='high'?'#F26B47':r.severity==='medium'?'#F5C544':'#34D399',
                      color:'#fff', letterSpacing:0.4, textTransform:'uppercase',
                    }}>{r.severity}</span>
                    <span style={{fontSize:11, fontWeight:700, color:'#0E8FC4', background:'#DDF3FE', padding:'2px 8px', borderRadius:99, textTransform:'uppercase', letterSpacing:0.4}}>{r.type}</span>
                    <span style={{fontSize:11.5, color:'#6B6B82'}}>Reported by <b style={{color:'#0F0F1A'}}>{r.reporter}</b> · target <b style={{color:'#0F0F1A'}}>{r.target}</b></span>
                    <span className="mono" style={{fontSize:10.5, color:'#A8A8BC', marginLeft:'auto'}}>{r.time}</span>
                  </div>
                  <div style={{fontSize:14, fontWeight:700, color:'#0F0F1A', marginTop:8}}>{r.reason}</div>
                  <div style={{
                    fontSize:12.5, color:'#2E2E3F', marginTop:6, padding:'8px 12px',
                    background:'#FAFBFD', borderRadius:8, fontStyle:'italic', borderLeft:'2px solid #ECECF3',
                  }}>{r.preview}</div>
                </div>

                <div style={{display:'flex', gap:6, flexShrink:0}}>
                  <button style={{
                    border:'none', background:'#10B981', color:'#fff',
                    padding:'8px 14px', borderRadius:9, fontSize:12, fontWeight:700, cursor:'pointer',
                  }}>Dismiss</button>
                  <button style={{
                    border:'1px solid #ECECF3', background:'#fff', color:'#2E2E3F',
                    padding:'8px 14px', borderRadius:9, fontSize:12, fontWeight:700, cursor:'pointer',
                  }}>Warn</button>
                  <button style={{
                    border:'1px solid #F26B47', background:'#FFE6DD', color:'#F26B47',
                    padding:'8px 14px', borderRadius:9, fontSize:12, fontWeight:700, cursor:'pointer',
                  }}>Suspend</button>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

function AdminAI() {
  return (
    <div>
      <AdminTopBar
        title="AI insights"
        subtitle="Gemini usage, Tako quality, and prompt patterns"
        actions={
          <button style={{
            border:'1px solid #ECECF3', background:'#fff', color:'#2E2E3F',
            padding:'8px 14px', borderRadius:10, fontSize:12.5, fontWeight:700, cursor:'pointer',
            display:'inline-flex', alignItems:'center', gap:6,
          }}><Icon name="refresh" size={14}/> Refresh</button>
        }
      />
      <div style={{padding:'18px 28px 28px', display:'flex', flexDirection:'column', gap:18}}>
        {/* Cost cards */}
        <div style={{display:'grid', gridTemplateColumns:'repeat(4, 1fr)', gap:14}}>
          <StatCard label="Gemini calls today"  value="62,108" delta="+4.2% vs avg"     accent="#1FB6F0" spark="0,12 12,14 24,10 36,12 48,8 60,9 72,5"/>
          <StatCard label="Avg latency"          value="1.2s"   delta="-180ms"           accent="#34D399" spark="0,18 12,14 24,16 36,12 48,10 60,8 72,6"/>
          <StatCard label="Cost today"            value="$84.30" delta="+$6.20 vs avg"  deltaTone="down" accent="#FF8A65" spark="0,16 12,12 24,14 36,10 48,11 60,9 72,7"/>
          <StatCard label="Failed responses"     value="0.4%"   delta="-0.2% wow"       accent="#A855F7" spark="0,16 12,14 24,18 36,14 48,12 60,9 72,8"/>
        </div>

        <div style={{display:'grid', gridTemplateColumns:'1.4fr 1fr', gap:14}}>
          {/* Tako quality */}
          <AdminPanel title="Tako conversation quality" subtitle="Auto-graded by sentiment + escalation triggers">
            <div style={{display:'flex', flexDirection:'column', gap:10}}>
              {[
                { label:'Helpful (👍 from user)',         pct:78, c:'#10B981' },
                { label:'Neutral (no signal)',            pct:14, c:'#A8A8BC' },
                { label:'Unhelpful (👎 from user)',       pct:6,  c:'#F5C544' },
                { label:'Escalated to safety review',     pct:2,  c:'#F26B47' },
              ].map(r => (
                <div key={r.label}>
                  <div style={{display:'flex', justifyContent:'space-between', fontSize:12.5, fontWeight:700, color:'#2E2E3F', marginBottom:4}}>
                    <span>{r.label}</span>
                    <span className="mono" style={{color:'#6B6B82'}}>{r.pct}%</span>
                  </div>
                  <div style={{height:8, background:'#F4F6FA', borderRadius:99, overflow:'hidden'}}>
                    <div style={{width:`${r.pct}%`, height:'100%', background:r.c, borderRadius:99}}/>
                  </div>
                </div>
              ))}
            </div>

            <div style={{
              marginTop:14, padding:'12px 14px',
              background:'#FFF5EC', border:'1px solid #FFD7C2', borderRadius:10,
              display:'flex', alignItems:'flex-start', gap:10,
            }}>
              <div style={{
                width:28, height:28, borderRadius:8, background:'#FF8A65', color:'#fff',
                display:'grid', placeItems:'center', flexShrink:0,
              }}><Icon name="info" size={16}/></div>
              <div style={{fontSize:12.5, color:'#7A4628', lineHeight:1.5}}>
                <b>2 escalations today</b> — both routed to the safety team. Tako should never give medical or mental-health advice; reinforce guardrails in the next system-prompt revision.
              </div>
            </div>
          </AdminPanel>

          {/* Common stuck points */}
          <AdminPanel title="Where students get stuck" subtitle="Phrases triggering 'I'm stuck' nudges">
            <div style={{display:'flex', flexDirection:'column', gap:6}}>
              {[
                ['"too much to read"',        428],
                ['"can\'t focus"',              312],
                ['"don\'t know where to start"', 287],
                ['"behind schedule"',          241],
                ['"deadline tomorrow"',        198],
                ['"failed this before"',       142],
              ].map(([p, n], i) => (
                <div key={p} style={{
                  display:'flex', alignItems:'center', gap:10,
                  padding:'8px 10px', borderRadius:9,
                  background: i === 0 ? '#FFF5EC' : 'transparent',
                }}>
                  <div className="mono" style={{fontSize:10.5, fontWeight:800, color:'#A8A8BC', width:22}}>{String(i+1).padStart(2,'0')}</div>
                  <div style={{flex:1, fontSize:12.5, color:'#0F0F1A', fontFamily:'JetBrains Mono, monospace'}}>{p}</div>
                  <div className="mono" style={{fontSize:11.5, fontWeight:700, color:'#6B6B82'}}>{n}</div>
                </div>
              ))}
            </div>
          </AdminPanel>
        </div>

        {/* Recent prompts */}
        <AdminPanel title="Recent goal-breakdown prompts" subtitle="Sampled live from anonymised users" action={<span style={{fontSize:11, fontWeight:700, color:'#10B981', display:'inline-flex', alignItems:'center', gap:5}}><span style={{width:8, height:8, borderRadius:99, background:'#10B981'}}/> Streaming</span>}>
          <div style={{display:'grid', gridTemplateColumns:'repeat(2, 1fr)', gap:8}}>
            {[
              {prompt:'Prep for ECON 201 midterm by Friday', tasks:6, time:'just now', sub:'8 min'},
              {prompt:'Finish 6-page essay on climate policy',tasks:5, time:'1m ago',  sub:'12 min'},
              {prompt:'Learn React hooks for class project',  tasks:7, time:'2m ago',  sub:'6 min'},
              {prompt:'Read chapters 4 & 5 of Sociology',     tasks:4, time:'3m ago',  sub:'9 min'},
              {prompt:'Build portfolio site before grad',      tasks:9, time:'4m ago',  sub:'14 min'},
              {prompt:'Practice IELTS speaking section',      tasks:5, time:'5m ago',  sub:'7 min'},
            ].map((p, i) => (
              <div key={i} style={{
                background:'#F7FBFD', border:'1px solid #DDF3FE', borderRadius:12,
                padding:'10px 14px',
              }}>
                <div style={{fontSize:11, fontWeight:800, color:'#0E8FC4', letterSpacing:0.4, textTransform:'uppercase', marginBottom:4, display:'flex', justifyContent:'space-between'}}>
                  <span>Goal</span><span style={{fontWeight:600, color:'#A8A8BC', letterSpacing:0, textTransform:'none'}}>{p.time}</span>
                </div>
                <div style={{fontSize:13, fontWeight:700, color:'#0F0F1A'}}>{p.prompt}</div>
                <div style={{fontSize:11.5, color:'#6B6B82', marginTop:4}}>
                  → broken into <b style={{color:'#1FB6F0'}}>{p.tasks} tasks</b> · generated in {p.sub}
                </div>
              </div>
            ))}
          </div>
        </AdminPanel>
      </div>
    </div>
  );
}

function AdminRevenue() {
  return (
    <div>
      <AdminTopBar
        title="Revenue & subscriptions"
        subtitle="Pro tier conversions, MRR, and growth"
      />
      <div style={{padding:'18px 28px 28px', display:'flex', flexDirection:'column', gap:18}}>
        <div style={{display:'grid', gridTemplateColumns:'repeat(4, 1fr)', gap:14}}>
          <StatCard label="MRR" value="PKR 1.42M" delta="+12% wow" accent="#1FB6F0" spark="0,18 12,14 24,12 36,10 48,7 60,5 72,2"/>
          <StatCard label="Pro subscribers" value="2,847" delta="+148 this week" accent="#FF8A65" spark="0,18 12,14 24,11 36,9 48,7 60,5 72,3"/>
          <StatCard label="Trial → paid"  value="32.4%" delta="+1.8 pp" accent="#10B981"/>
          <StatCard label="Churn (30d)"   value="3.1%"  delta="-0.4 pp" accent="#A855F7"/>
        </div>

        <div style={{display:'grid', gridTemplateColumns:'1fr 1fr', gap:14}}>
          <AdminPanel title="MRR over time" subtitle="Past 30 days · PKR thousands">
            <svg viewBox="0 0 600 220" width="100%">
              <defs>
                <linearGradient id="revGrad" x1="0" x2="0" y1="0" y2="1">
                  <stop offset="0%" stopColor="#1FB6F0" stopOpacity="0.3"/>
                  <stop offset="100%" stopColor="#1FB6F0" stopOpacity="0"/>
                </linearGradient>
              </defs>
              {[0,500,1000,1500].map((v,i) => (
                <g key={v}>
                  <line x1="40" x2="580" y1={190-i*45} y2={190-i*45} stroke="#F4F6FA"/>
                  <text x="6" y={194-i*45} fontSize="10" fill="#A8A8BC" fontFamily="JetBrains Mono, monospace">{v}k</text>
                </g>
              ))}
              {(() => {
                const pts = [820,840,900,950,1020,1040,1100,1080,1150,1240,1280,1310,1380,1420];
                const xs = i => 40 + (i/(pts.length-1))*540;
                const ys = v => 190 - (v/1500)*180;
                const path = pts.map((v,i) => `${i?'L':'M'} ${xs(i)} ${ys(v)}`).join(' ');
                const area = path + ` L ${xs(pts.length-1)} 190 L 40 190 Z`;
                return <>
                  <path d={area} fill="url(#revGrad)"/>
                  <path d={path} fill="none" stroke="#1FB6F0" strokeWidth="2.5" strokeLinecap="round"/>
                  {pts.map((v,i) => <circle key={i} cx={xs(i)} cy={ys(v)} r="2.5" fill="#1FB6F0"/>)}
                </>;
              })()}
            </svg>
          </AdminPanel>

          <AdminPanel title="Plan breakdown" subtitle="Where subscribers spend">
            <div style={{display:'flex', alignItems:'center', gap:20, padding:'10px 0'}}>
              <svg viewBox="0 0 100 100" width="140" height="140">
                {/* Donut chart */}
                {(() => {
                  const segs = [
                    {pct:62, c:'#1FB6F0'},
                    {pct:24, c:'#FF8A65'},
                    {pct:10, c:'#34D399'},
                    {pct:4,  c:'#A855F7'},
                  ];
                  let acc = -25; // start at top
                  const r = 38;
                  const C = 2 * Math.PI * r;
                  return segs.map((s, i) => {
                    const len = (s.pct/100) * C;
                    const offset = (acc/100) * C;
                    acc += s.pct;
                    return <circle key={i} cx="50" cy="50" r={r} fill="transparent"
                      stroke={s.c} strokeWidth="14"
                      strokeDasharray={`${len} ${C}`} strokeDashoffset={-offset}
                      transform="rotate(-90 50 50)"/>;
                  });
                })()}
                <text x="50" y="48" textAnchor="middle" fontSize="11" fill="#6B6B82" fontWeight="700">Pro</text>
                <text x="50" y="62" textAnchor="middle" fontSize="14" fill="#0F0F1A" fontWeight="800" fontFamily="Georgia, serif">2,847</text>
              </svg>
              <div style={{flex:1, display:'flex', flexDirection:'column', gap:8}}>
                {[
                  {l:'Monthly · PKR 499',  pct:62, c:'#1FB6F0'},
                  {l:'Annual · PKR 4,990', pct:24, c:'#FF8A65'},
                  {l:'Student bundle',     pct:10, c:'#34D399'},
                  {l:'Lifetime',           pct:4,  c:'#A855F7'},
                ].map(s => (
                  <div key={s.l} style={{display:'flex', alignItems:'center', gap:8, fontSize:12.5, color:'#2E2E3F'}}>
                    <span style={{width:10, height:10, borderRadius:99, background:s.c}}/>
                    <span style={{flex:1, fontWeight:600}}>{s.l}</span>
                    <span className="mono" style={{fontWeight:700, color:'#0F0F1A'}}>{s.pct}%</span>
                  </div>
                ))}
              </div>
            </div>
          </AdminPanel>
        </div>
      </div>
    </div>
  );
}

function AdminSettings() {
  const [flags, setFlags] = React.useState({
    mood: true, squads: true, weeklyReport: true, badgePacks: false, voiceTako: false, darkMode: false,
  });
  const toggle = k => setFlags(f => ({...f, [k]: !f[k]}));
  return (
    <div>
      <AdminTopBar title="Settings" subtitle="Feature flags, default behaviour, and admin team"/>
      <div style={{padding:'18px 28px 28px', display:'grid', gridTemplateColumns:'1.4fr 1fr', gap:14}}>
        <AdminPanel title="Feature flags" subtitle="Toggles affect the live mobile app immediately">
          <div style={{display:'flex', flexDirection:'column', gap:4}}>
            {[
              {k:'mood',         l:'Mood-aware sessions',     d:'Dashboard mood-picker rewrites the next session length.'},
              {k:'squads',       l:'Squad leaderboards',      d:'Show weekly squad leaderboard in the Hub tab.'},
              {k:'weeklyReport', l:'Weekly report card',      d:'Auto-generate and notify users every Sunday evening.'},
              {k:'badgePacks',   l:'Badge pack store',         d:'Allow one-time IAP for cosmetic badge packs.', tag:'BETA'},
              {k:'voiceTako',    l:'Voice messages with Tako', d:'Let students send voice notes instead of typing.', tag:'BETA'},
              {k:'darkMode',     l:'Dark mode',                d:'Currently in QA — opt-in for Pro users.', tag:'INTERNAL'},
            ].map(f => (
              <div key={f.k} style={{
                display:'flex', alignItems:'center', gap:14, padding:'12px 6px',
                borderBottom:'1px solid #F4F6FA',
              }}>
                <div style={{flex:1}}>
                  <div style={{display:'flex', alignItems:'center', gap:6, fontSize:13.5, fontWeight:700, color:'#0F0F1A'}}>
                    {f.l}
                    {f.tag && (
                      <span style={{
                        fontSize:9, fontWeight:800, color:'#fff', padding:'2px 6px', borderRadius:4,
                        background: f.tag === 'INTERNAL' ? '#0F0F1A' : '#A855F7', letterSpacing:0.4,
                      }}>{f.tag}</span>
                    )}
                  </div>
                  <div style={{fontSize:11.5, color:'#6B6B82', marginTop:1}}>{f.d}</div>
                </div>
                <button onClick={() => toggle(f.k)} style={{
                  width:42, height:24, borderRadius:99,
                  background: flags[f.k] ? '#1FB6F0' : '#DCDCE7',
                  border:'none', position:'relative', cursor:'pointer',
                  transition: 'background .2s',
                }}>
                  <div style={{
                    position:'absolute', top:2, left: flags[f.k] ? 20 : 2,
                    width:20, height:20, borderRadius:99, background:'#fff',
                    transition:'left .2s', boxShadow:'0 1px 3px rgba(0,0,0,0.15)',
                  }}/>
                </button>
              </div>
            ))}
          </div>
        </AdminPanel>

        <AdminPanel title="Admin team" subtitle="3 active admins · 2 super admins">
          <div style={{display:'flex', flexDirection:'column', gap:8}}>
            {[
              { n:'You (Umar)',     r:'Super admin', e:'admin@taskko.app', c:'#1FB6F0', me:true},
              { n:'Muhammad S.',    r:'Super admin', e:'sharjeel@taskko.app', c:'#FF8A65'},
              { n:'Sara Khan',      r:'Moderator',   e:'sara.admin@taskko.app', c:'#34D399'},
              { n:'Hassan Raza',    r:'Support',     e:'hassan@taskko.app', c:'#A855F7'},
            ].map(a => (
              <div key={a.e} style={{
                display:'flex', alignItems:'center', gap:10,
                padding:'10px 12px', borderRadius:10,
                background: a.me ? '#F7FBFD' : '#fff', border: a.me ? '1.5px solid #1FB6F0' : '1px solid #ECECF3',
              }}>
                <div style={{
                  width:32, height:32, borderRadius:99,
                  background:`linear-gradient(135deg, ${a.c}, ${a.c}AA)`,
                  color:'#fff', display:'grid', placeItems:'center', fontWeight:800, fontSize:12,
                }}>{a.n[0]}</div>
                <div style={{flex:1, minWidth:0}}>
                  <div style={{fontSize:12.5, fontWeight:700, color:'#0F0F1A'}}>{a.n}{a.me && <span style={{marginLeft:6, fontSize:10, fontWeight:800, color:'#0E8FC4', background:'#DDF3FE', padding:'1px 6px', borderRadius:99}}>YOU</span>}</div>
                  <div style={{fontSize:11, color:'#6B6B82'}}>{a.e}</div>
                </div>
                <span style={{fontSize:11, fontWeight:700, color:a.c, background:`${a.c}15`, padding:'3px 8px', borderRadius:99}}>{a.r}</span>
              </div>
            ))}
          </div>
          <button style={{
            marginTop:12, width:'100%', border:'1px dashed #DCDCE7', background:'transparent',
            color:'#6B6B82', padding:'10px', borderRadius:10, fontSize:12.5, fontWeight:700, cursor:'pointer',
            display:'inline-flex', alignItems:'center', justifyContent:'center', gap:6,
          }}><Icon name="plus" size={14}/> Invite admin</button>
        </AdminPanel>
      </div>
    </div>
  );
}

function AdminPortal({ tab, setTab, onExit, admin }) {
  const screen = {
    dashboard: <AdminDashboard/>,
    users: <AdminUsers/>,
    moderation: <AdminModeration/>,
    ai: <AdminAI/>,
    revenue: <AdminRevenue/>,
    settings: <AdminSettings/>,
  }[tab] || <AdminDashboard/>;

  return (
    <div style={{
      display:'flex', height:'100%', width:'100%',
      background:'#FAFBFD',
      fontFamily:'Manrope, sans-serif',
      color:'#0F0F1A',
    }}>
      <AdminSidebar tab={tab} setTab={setTab} onExit={onExit} admin={admin}/>
      <div style={{flex:1, overflow:'auto'}}>
        {screen}
      </div>
    </div>
  );
}

Object.assign(window, { AdminModeration, AdminAI, AdminRevenue, AdminSettings, AdminPortal });
