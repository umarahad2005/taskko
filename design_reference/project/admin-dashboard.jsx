// Taskko Admin — Dashboard
// ===========================================================

function AdminDashboard({ data }) {
  return (
    <div style={{padding:24, display:'flex', flexDirection:'column', gap:18}}>
      <AdminTopBar
        title="Overview"
        subtitle="Live snapshot of how Taskko students are doing today."
        actions={
          <select style={{
            border:'1px solid #ECECF3', borderRadius:10, padding:'8px 12px',
            background:'#fff', fontSize:12.5, fontWeight:600, color:'#0F0F1A',
            fontFamily:'inherit', cursor:'pointer',
          }}>
            <option>Last 7 days</option>
            <option>Last 30 days</option>
            <option>This semester</option>
          </select>
        }
      />

      <div style={{padding:'0 28px 24px', display:'flex', flexDirection:'column', gap:18}}>
        {/* KPI grid */}
        <div style={{display:'grid', gridTemplateColumns:'repeat(4, 1fr)', gap:14}}>
          <StatCard label="Active users (DAU)" value="8,412" delta="+12.4% wow" spark="0,15 12,12 24,16 36,8 48,10 60,4 72,6"/>
          <StatCard label="New signups" value="624" delta="+3.1%" spark="0,18 12,14 24,16 36,10 48,12 60,8 72,5" accent="#FF8A65"/>
          <StatCard label="Avg streak" value="4.2d" delta="+0.6d vs last week" spark="0,16 12,14 24,12 36,10 48,8 60,9 72,6" accent="#FF8A65"/>
          <StatCard label="AI calls today" value="62,108" delta="-2.3% qoq" deltaTone="down" spark="0,8 12,10 24,9 36,12 48,11 60,14 72,16" accent="#34D399"/>
          <StatCard label="Pro conversions" value="148" delta="+22 this week" spark="0,18 12,14 24,12 36,9 48,11 60,6 72,4" accent="#5BCBF5"/>
          <StatCard label="Squads created" value="2,067" delta="+5.0%" spark="0,16 12,15 24,12 36,13 48,10 60,9 72,7" accent="#F472B6"/>
          <StatCard label="Badges shared" value="9,041" delta="+18% wow" spark="0,18 12,14 24,15 36,11 48,9 60,7 72,3" accent="#F5C544"/>
          <StatCard label="Reported content" value="7" delta="needs review" deltaTone="down" accent="#F26B47"/>
        </div>

        {/* Charts row */}
        <div style={{display:'grid', gridTemplateColumns:'1.6fr 1fr', gap:14}}>
          {/* Engagement line chart */}
          <AdminPanel
            title="Engagement"
            subtitle="Daily active users vs tasks completed"
            action={
              <div style={{display:'flex', gap:14, fontSize:11.5, fontWeight:600}}>
                <span style={{display:'inline-flex', alignItems:'center', gap:5, color:'#6B6B82'}}>
                  <span style={{width:9, height:9, borderRadius:99, background:'#1FB6F0'}}/> DAU
                </span>
                <span style={{display:'inline-flex', alignItems:'center', gap:5, color:'#6B6B82'}}>
                  <span style={{width:9, height:9, borderRadius:99, background:'#FF8A65'}}/> Tasks done
                </span>
              </div>
            }
          >
            <EngagementChart/>
          </AdminPanel>

          {/* Rank distribution */}
          <AdminPanel title="Rank distribution" subtitle="Across all active users">
            <div style={{display:'flex', flexDirection:'column', gap:10}}>
              {[
                { name:'Rookie',  pct:34, count:'4,283', c:'#A8A8BC' },
                { name:'Pro',     pct:42, count:'5,294', c:'#1FB6F0' },
                { name:'Elite',   pct:16, count:'2,016', c:'#FF8A65' },
                { name:'Master',  pct:6,  count:'755',   c:'#F5C544' },
                { name:'Legend',  pct:2,  count:'252',   c:'#A855F7' },
              ].map(r => (
                <div key={r.name}>
                  <div style={{display:'flex', justifyContent:'space-between', fontSize:12, fontWeight:700, color:'#2E2E3F', marginBottom:4}}>
                    <span style={{display:'inline-flex', alignItems:'center', gap:6}}>
                      <span style={{width:8, height:8, borderRadius:99, background:r.c}}/> {r.name}
                    </span>
                    <span className="mono" style={{color:'#6B6B82', fontWeight:600}}>{r.count} · {r.pct}%</span>
                  </div>
                  <div style={{height:6, background:'#F4F6FA', borderRadius:99, overflow:'hidden'}}>
                    <div style={{width:`${r.pct}%`, height:'100%', background:r.c, borderRadius:99}}/>
                  </div>
                </div>
              ))}
            </div>
          </AdminPanel>
        </div>

        {/* Tables row */}
        <div style={{display:'grid', gridTemplateColumns:'1fr 1fr', gap:14}}>
          {/* Top goals */}
          <AdminPanel title="Top goals being broken down" subtitle="What students are asking Tako to help with" action={<a style={{fontSize:12, fontWeight:700, color:'#0E8FC4', textDecoration:'none', cursor:'pointer'}}>See all →</a>}>
            <div style={{display:'flex', flexDirection:'column', gap:6}}>
              {[
                ['Prep for midterm exam',          1842, '#1FB6F0'],
                ['Finish capstone proposal',        924, '#FF8A65'],
                ['Read assigned chapters',          812, '#34D399'],
                ['Build portfolio website',         603, '#F472B6'],
                ['Practice LeetCode problems',      512, '#F5C544'],
                ['Write essay due Friday',          488, '#A855F7'],
              ].map(([g, n, c], i) => (
                <div key={g} style={{display:'flex', alignItems:'center', gap:10, padding:'6px 4px'}}>
                  <div className="mono" style={{width:18, fontSize:11, fontWeight:700, color:'#A8A8BC'}}>{String(i+1).padStart(2,'0')}</div>
                  <div style={{flex:1, fontSize:13, fontWeight:600, color:'#0F0F1A'}}>{g}</div>
                  <div style={{flex:'0 0 140px', height:6, background:'#F4F6FA', borderRadius:99, overflow:'hidden'}}>
                    <div style={{width:`${(n/1842)*100}%`, height:'100%', background:c, borderRadius:99}}/>
                  </div>
                  <div className="mono" style={{fontSize:11.5, color:'#6B6B82', fontWeight:600, width:44, textAlign:'right'}}>{n}</div>
                </div>
              ))}
            </div>
          </AdminPanel>

          {/* Recent activity */}
          <AdminPanel title="Recent activity" subtitle="Live feed of high-signal events" action={<span style={{fontSize:11, fontWeight:700, color:'#10B981', display:'inline-flex', alignItems:'center', gap:5}}><span style={{width:8, height:8, borderRadius:99, background:'#10B981'}}/> Live</span>}>
            <div style={{display:'flex', flexDirection:'column', gap:0}}>
              {[
                { who:'Sara K.',     what:'unlocked', target:'5-day streak badge',  time:'2m ago', tone:'#FF8A65', icon:'fire' },
                { who:'Omar T.',     what:'upgraded to', target:'Pro tier',         time:'4m ago', tone:'#1FB6F0', icon:'trophy' },
                { who:'Ana M.',     what:'reported',  target:'a share card',        time:'8m ago', tone:'#F26B47', icon:'flag' },
                { who:'Bilal A.',    what:'completed', target:'12 tasks today',     time:'12m ago', tone:'#10B981', icon:'check' },
                { who:'Aliyah S.',  what:'lost streak (used shield)', target:'6 days', time:'18m ago', tone:'#A855F7', icon:'shield' },
                { who:'Zara N.',     what:'shared report card to', target:'Instagram', time:'25m ago', tone:'#EC4899', icon:'share' },
              ].map((e, i) => (
                <div key={i} style={{
                  display:'flex', alignItems:'center', gap:10, padding:'9px 4px',
                  borderBottom: i < 5 ? '1px solid #F4F6FA' : 'none',
                }}>
                  <div style={{
                    width:30, height:30, borderRadius:9,
                    background:`${e.tone}15`, color:e.tone,
                    display:'grid', placeItems:'center', flexShrink:0,
                  }}><Icon name={e.icon} size={15}/></div>
                  <div style={{flex:1, fontSize:12.5, color:'#0F0F1A', lineHeight:1.4}}>
                    <b>{e.who}</b> <span style={{color:'#6B6B82'}}>{e.what}</span> <b style={{color:e.tone}}>{e.target}</b>
                  </div>
                  <div className="mono" style={{fontSize:11, color:'#A8A8BC', whiteSpace:'nowrap'}}>{e.time}</div>
                </div>
              ))}
            </div>
          </AdminPanel>
        </div>
      </div>
    </div>
  );
}

function EngagementChart() {
  const dau    = [42, 48, 52, 58, 55, 64, 68, 72, 68, 78, 82, 84, 88, 92];
  const tasks  = [55, 62, 58, 68, 72, 78, 82, 76, 88, 92, 86, 94, 96, 100];
  const W = 600, H = 220, P = 30;
  const xs = i => P + (i/(dau.length-1))*(W-P*2);
  const ys = v => H - P - (v/100)*(H-P*2);
  const dpath = dau.map((v,i) => `${i?'L':'M'} ${xs(i)} ${ys(v)}`).join(' ');
  const tpath = tasks.map((v,i) => `${i?'L':'M'} ${xs(i)} ${ys(v)}`).join(' ');
  const darea = dpath + ` L ${xs(dau.length-1)} ${H-P} L ${xs(0)} ${H-P} Z`;
  return (
    <svg viewBox={`0 0 ${W} ${H}`} width="100%" style={{display:'block'}}>
      <defs>
        <linearGradient id="dauGrad" x1="0" x2="0" y1="0" y2="1">
          <stop offset="0%" stopColor="#1FB6F0" stopOpacity="0.25"/>
          <stop offset="100%" stopColor="#1FB6F0" stopOpacity="0"/>
        </linearGradient>
      </defs>
      {/* gridlines */}
      {[0,25,50,75,100].map(v => (
        <g key={v}>
          <line x1={P} x2={W-P} y1={ys(v)} y2={ys(v)} stroke="#F4F6FA" strokeWidth="1"/>
          <text x={6} y={ys(v)+3} fontSize="10" fill="#A8A8BC" fontFamily="JetBrains Mono, monospace">{v}</text>
        </g>
      ))}
      <path d={darea} fill="url(#dauGrad)"/>
      <path d={dpath} fill="none" stroke="#1FB6F0" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"/>
      <path d={tpath} fill="none" stroke="#FF8A65" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round" strokeDasharray="0"/>
      {dau.map((v,i) => <circle key={'d'+i} cx={xs(i)} cy={ys(v)} r="2.5" fill="#1FB6F0"/>)}
      {tasks.map((v,i) => <circle key={'t'+i} cx={xs(i)} cy={ys(v)} r="2.5" fill="#FF8A65"/>)}
      {/* x labels */}
      {['M','T','W','T','F','S','S','M','T','W','T','F','S','S'].map((d,i) => (
        <text key={i} x={xs(i)} y={H-10} fontSize="10" textAnchor="middle" fill="#A8A8BC" fontFamily="JetBrains Mono, monospace">{d}</text>
      ))}
    </svg>
  );
}

Object.assign(window, { AdminDashboard });
