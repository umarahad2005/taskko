// Taskko — 4 core screens
// =====================================================

// =====================================================
// 1. HOME / DASHBOARD
// =====================================================
function HomeScreen({ state, dispatch, annotate, goTo, isAdmin, onOpenAdmin }) {
  const { user, streak, points, rank, todayTasks, mood, nextTask } = state;
  const completedToday = todayTasks.filter(t => t.done).length;
  const progressPct = Math.round((completedToday / todayTasks.length) * 100);

  return (
    <div className="phone-scroll" style={{padding:'56px 18px 110px', overflowY:'auto', height:'100%'}}>
      {/* Top bar */}
      <div style={{display:'flex', alignItems:'center', justifyContent:'space-between', marginBottom: 14}}>
        <TaskkoLogo size={20} />
        <div style={{display:'flex', gap:8, alignItems:'center'}}>
          {isAdmin && (
            <button onClick={onOpenAdmin} className="tap" style={{
              border:'none', cursor:'pointer',
              background: 'linear-gradient(135deg, #0F1B26, #1B2D3F)',
              color:'#fff', padding:'7px 12px', borderRadius:99,
              fontSize:11, fontWeight:800, letterSpacing:0.4, textTransform:'uppercase',
              display:'inline-flex', alignItems:'center', gap:6,
              boxShadow:'0 6px 16px -6px rgba(15,27,38,0.45)',
            }}>
              <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="#5BCBF5" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="M12 2l8 4v6c0 5-3.5 9-8 10-4.5-1-8-5-8-10V6z"/><path d="M9 12l2 2 4-4"/></svg>
              Admin
            </button>
          )}
          <button className="tap" style={{
            border:'none', background:'#fff', width:36, height:36, borderRadius:99,
            display:'grid', placeItems:'center',
            boxShadow:'0 1px 0 rgba(15,15,26,.04), 0 4px 14px -6px rgba(20,80,120,.18)',
          }}>
            <Icon name="bell" size={18} color="var(--ink-2)"/>
          </button>
          <div style={{
            width:36, height:36, borderRadius:99,
            background: 'linear-gradient(135deg,#FFD1B8,#FF8A65)',
            color:'#fff', display:'grid', placeItems:'center', fontWeight:700, fontSize:14,
            boxShadow:'0 4px 14px -6px rgba(242,107,71,.5)',
            position:'relative',
          }}>{user.initials}
            {isAdmin && (
              <div style={{
                position:'absolute', bottom:-2, right:-2,
                width:14, height:14, borderRadius:99,
                background:'#0F1B26', border:'2px solid #fff',
                display:'grid', placeItems:'center',
              }}>
                <svg width="7" height="7" viewBox="0 0 24 24" fill="none" stroke="#5BCBF5" strokeWidth="3.5" strokeLinecap="round" strokeLinejoin="round"><path d="M9 12l2 2 4-4"/></svg>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Greeting */}
      <div style={{marginBottom:18}}>
        <div style={{color:'var(--ink-3)', fontSize:13, fontWeight:500}}>Wednesday · May 21</div>
        <div style={{fontFamily:'Fraunces, serif', fontWeight:700, fontSize:28, letterSpacing:-0.5, marginTop:2}}>
          Morning, {user.name} 👋
        </div>
        <div style={{color:'var(--ink-3)', fontSize:14, marginTop:2}}>
          You've got {todayTasks.length - completedToday} tasks left today — let's go.
        </div>
      </div>

      {/* Streak + Rank bento */}
      <div style={{display:'grid', gridTemplateColumns:'1.2fr 1fr', gap:10, marginBottom:12, position:'relative'}}>
        {annotate && <HCIPin n="1" principle="Visibility · Gulf of Evaluation" title="Streak & Rank are first thing visible"
          body="High-status gamification stats sit above the fold so students always see progress. The flame uses warm color + numeric — readable at a glance." side="left" top={-6}/>}
        <Card style={{background:'linear-gradient(135deg,#FFF6EF 0%, #FFE6DD 100%)', border:'1px solid #FFD7C2'}}>
          <div style={{display:'flex', alignItems:'center', gap:6, color:'#B85A3A', fontSize:11, fontWeight:700, letterSpacing:0.6, textTransform:'uppercase'}}>
            <Icon name="fire" size={14}/> Streak
          </div>
          <div style={{display:'flex', alignItems:'baseline', gap:4, marginTop:6}}>
            <span style={{fontFamily:'Fraunces, serif', fontWeight:700, fontSize:38, color:'#C9542E', lineHeight:1}}>{streak.days}</span>
            <span style={{color:'#B85A3A', fontWeight:600, fontSize:13}}>days</span>
          </div>
          {/* 5-day visualizer */}
          <div style={{display:'flex', gap:4, marginTop:10}}>
            {[0,1,2,3,4].map(i => {
              const filled = i < streak.days;
              return (
                <div key={i} style={{
                  flex:1, height:6, borderRadius:99,
                  background: filled ? 'linear-gradient(90deg,#FFC062,#F26B47)' : 'rgba(184,90,58,.15)',
                }}/>
              );
            })}
          </div>
          <div style={{display:'flex', alignItems:'center', gap:4, marginTop:8, fontSize:11, color:'#B85A3A', fontWeight:600}}>
            <Icon name="shield" size={12}/> {streak.shields} shield{streak.shields!==1?'s':''} ready
          </div>
        </Card>

        <Card style={{background:'linear-gradient(135deg,#E6F6FE 0%, #C7E9F8 100%)', border:'1px solid #A8DDF5'}}>
          <div style={{display:'flex', alignItems:'center', gap:6, color:'#0A6FA8', fontSize:11, fontWeight:700, letterSpacing:0.6, textTransform:'uppercase'}}>
            <Icon name="trophy" size={14}/> Rank
          </div>
          <div style={{fontFamily:'Fraunces, serif', fontWeight:700, fontSize:22, color:'#0E8FC4', marginTop:6, lineHeight:1.1}}>
            {rank}
          </div>
          <div className="mono" style={{fontSize:13, fontWeight:700, color:'#1FB6F0', marginTop:2}}>{points.toLocaleString()} pts</div>
          <div style={{marginTop:8, height:6, borderRadius:99, background:'rgba(31,182,240,.18)', overflow:'hidden'}}>
            <div style={{width:'68%', height:'100%', background:'linear-gradient(90deg,#5BCBF5,#1FB6F0)', borderRadius:99}}/>
          </div>
          <div style={{fontSize:10.5, color:'#1FB6F0', fontWeight:600, marginTop:4}}>320 pts to Elite</div>
        </Card>
      </div>

      {/* Mood check-in */}
      <div style={{position:'relative'}}>
        {annotate && <HCIPin n="2" principle="Feedback · Mapping" title="Mood adjusts session live"
          body="Picking an emoji visibly changes the next session card (length, tone, break ratio). Direct mapping between user state and system response." side="right" top={6}/>}
        <Card style={{marginBottom:12}}>
          <div style={{display:'flex', alignItems:'center', justifyContent:'space-between', marginBottom:8}}>
            <div style={{minWidth:0}}>
              <div style={{fontWeight:700, fontSize:15, whiteSpace:'nowrap'}}>How are you feeling?</div>
              <div style={{fontSize:12, color:'var(--ink-3)', marginTop:2, whiteSpace:'nowrap'}}>I'll tailor your session.</div>
            </div>
            <TakoMascot size={42} mood={mood === 'tired' ? 'tired' : mood === 'energized' ? 'excited' : mood==='calm'?'calm':'happy'} />
          </div>
          <div style={{display:'flex', gap:6}}>
            {[
              { k:'energized', emoji:'🔥', label:'Fired up' },
              { k:'focused',   emoji:'🎯', label:'Focused' },
              { k:'calm',      emoji:'🌿', label:'Chill' },
              { k:'tired',     emoji:'😮‍💨', label:'Drained' },
            ].map(m => {
              const active = mood === m.k;
              return (
                <button key={m.k} className="tap" onClick={() => dispatch({type:'mood', value: m.k})} style={{
                  flex:1, border: active ? '2px solid var(--primary)' : '1px solid var(--line)',
                  background: active ? 'var(--primary-soft)' : '#fff',
                  borderRadius: 14, padding: '8px 4px',
                  display:'flex', flexDirection:'column', alignItems:'center', gap:2,
                  cursor:'pointer',
                }}>
                  <span style={{fontSize:20}}>{m.emoji}</span>
                  <span style={{fontSize:10, fontWeight:700, color: active ? 'var(--primary)' : 'var(--ink-2)'}}>{m.label}</span>
                </button>
              );
            })}
          </div>
        </Card>
      </div>

      {/* NEXT ACTION — the hero CTA */}
      <div style={{position:'relative', marginBottom:14}}>
        {annotate && <HCIPin n="3" principle="Visual Hierarchy · Gulf of Execution"
          title="One obvious 'next' action"
          body="The brightest, largest card on the screen — students never wonder what to do next. The button label is a verb + concrete task, removing decision cost." side="right" top={-4}/>}
        <div style={{
          borderRadius: 26, padding: 18,
          background: 'linear-gradient(135deg,#1FB6F0 0%, #1FB6F0 60%, #FF8A65 130%)',
          color:'#fff', position:'relative', overflow:'hidden',
          boxShadow:'0 20px 40px -16px rgba(31,182,240,.55)',
        }}>
          {/* spark deco */}
          <div style={{position:'absolute', right:-30, top:-30, width:140, height:140, borderRadius:99, background:'rgba(255,255,255,.12)'}}/>
          <div style={{position:'absolute', right:20, bottom:-20, width:80, height:80, borderRadius:99, background:'rgba(255,255,255,.08)'}}/>
          <div style={{display:'flex', alignItems:'center', gap:6, fontSize:11, fontWeight:700, letterSpacing:0.8, textTransform:'uppercase', opacity:.9, whiteSpace:'nowrap'}}>
            <Icon name="bolt" size={13}/> Next up
          </div>
          <div style={{fontFamily:'Fraunces, serif', fontWeight:700, fontSize:22, lineHeight:1.15, marginTop:6}}>
            {nextTask.title}
          </div>
          <div style={{display:'flex', gap:14, fontSize:12, marginTop:8, opacity:.92, fontWeight:600, whiteSpace:'nowrap'}}>
            <span>⏱ {nextTask.minutes} min</span>
            <span>+{nextTask.points} pts</span>
            <span style={{overflow:'hidden', textOverflow:'ellipsis'}}>· {nextTask.goal}</span>
          </div>
          <div style={{marginTop:14, display:'flex', gap:8, position:'relative', zIndex:2}}>
            <button className="tap" onClick={() => goTo('plan')} style={{
              flex:1, border:'none', background:'#fff', color:'var(--primary)',
              padding:'13px 14px', borderRadius:14, fontWeight:800, fontSize:15,
              display:'inline-flex', alignItems:'center', justifyContent:'center', gap:6, cursor:'pointer',
            }}><Icon name="play" size={16}/> <span style={{whiteSpace:'nowrap'}}>Start now</span></button>
            <button className="tap" style={{
              border:'1px solid rgba(255,255,255,.4)', background:'rgba(255,255,255,.16)',
              color:'#fff', padding:'13px 14px', borderRadius:14, fontWeight:700, fontSize:14, cursor:'pointer',
              backdropFilter:'blur(8px)',
            }}>Skip</button>
          </div>
        </div>
      </div>

      {/* Today's tasks */}
      <SectionH action={`${completedToday}/${todayTasks.length} done · ${progressPct}%`}>Today's tasks</SectionH>
      <div style={{display:'flex', flexDirection:'column', gap:8, position:'relative'}}>
        {annotate && <HCIPin n="4" principle="Gestalt · Proximity & Similarity"
          title="Tasks visually grouped"
          body="Same card shape, same spacing, indicator on the left = students perceive them as a single 'today' set. Completed items dim but remain visible for closure." side="left" top={6}/>}
        {todayTasks.map((t, i) => (
          <TaskRow key={t.id} task={t} onToggle={() => dispatch({type:'toggle', id:t.id})} />
        ))}
        <button className="tap" onClick={() => goTo('plan')} style={{
          border:'1px dashed var(--line-2)', background:'transparent',
          padding:12, borderRadius:14, color:'var(--ink-3)', fontSize:13, fontWeight:600,
          display:'inline-flex', alignItems:'center', justifyContent:'center', gap:6, cursor:'pointer',
        }}>
          <Icon name="sparkles" size={15}/> Break down a new goal with AI
        </button>
      </div>
    </div>
  );
}

function TaskRow({ task, onToggle }) {
  return (
    <div className="tap" onClick={onToggle} style={{
      background:'#fff', border:'1px solid var(--line)',
      borderRadius:16, padding:'12px 14px', display:'flex', gap:12, alignItems:'center',
      opacity: task.done ? 0.55 : 1,
      cursor:'pointer',
    }}>
      <div style={{
        width:24, height:24, borderRadius:8,
        border: task.done ? 'none' : '2px solid var(--line-2)',
        background: task.done ? 'linear-gradient(135deg,#42D391,#10B981)' : '#fff',
        display:'grid', placeItems:'center', flexShrink:0,
        transition:'all .2s',
      }}>
        {task.done && <Icon name="check" size={14} color="#fff" stroke={3}/>}
      </div>
      <div style={{flex:1, minWidth:0}}>
        <div style={{
          fontSize:14, fontWeight:600, color:'var(--ink)',
          textDecoration: task.done ? 'line-through' : 'none',
        }}>{task.title}</div>
        <div style={{fontSize:11.5, color:'var(--ink-3)', marginTop:2, display:'flex', gap:8}}>
          <span>⏱ {task.minutes}m</span>
          <span>· {task.goal}</span>
          {!task.done && <span style={{color:'var(--primary)', fontWeight:700}}>+{task.points} pts</span>}
        </div>
      </div>
    </div>
  );
}

// =====================================================
// 2. AI TASK BREAKDOWN
// =====================================================
function PlanScreen({ state, dispatch, annotate, goTo }) {
  const { goalDraft, planTasks, planning, planStep } = state;
  // planStep: 'input' | 'generating' | 'review'

  return (
    <div className="phone-scroll" style={{padding:'56px 18px 110px', height:'100%', overflowY:'auto'}}>
      {/* Header */}
      <div style={{display:'flex', alignItems:'center', justifyContent:'space-between', marginBottom:18}}>
        <button className="tap" onClick={() => goTo('home')} style={{
          border:'none', background:'#fff', width:36, height:36, borderRadius:99,
          display:'grid', placeItems:'center',
          boxShadow:'0 1px 0 rgba(15,15,26,.04), 0 4px 14px -6px rgba(20,80,120,.18)',
        }}><Icon name="back" size={18} color="var(--ink-2)"/></button>
        <div style={{display:'flex', alignItems:'center', gap:6}}>
          <Icon name="sparkles" size={16} color="var(--primary)"/>
          <span style={{fontWeight:700, fontSize:14, color:'var(--ink)'}}>AI Plan Studio</span>
        </div>
        <button className="tap" style={{border:'none', background:'transparent', cursor:'pointer'}}>
          <Icon name="dots" size={22} color="var(--ink-3)"/>
        </button>
      </div>

      {/* Step indicator */}
      <div style={{display:'flex', gap:6, marginBottom:18}}>
        {['Goal','Break down','Customize'].map((s, i) => {
          const stepIdx = planStep === 'input' ? 0 : planStep === 'generating' ? 1 : 2;
          const active = i <= stepIdx;
          return (
            <div key={s} style={{flex:1, display:'flex', flexDirection:'column', gap:4}}>
              <div style={{height:4, borderRadius:99, background: active ? 'linear-gradient(90deg,#5BCBF5,#1FB6F0)' : 'var(--line)'}}/>
              <div style={{fontSize:11, fontWeight:active?700:500, color: active ? 'var(--primary)' : 'var(--ink-3)'}}>{s}</div>
            </div>
          );
        })}
      </div>

      {planStep === 'input' && (
        <div className="fade-in" style={{position:'relative'}}>
          {annotate && <HCIPin n="1" principle="Constraints · Affordance"
            title="Guided goal input"
            body="Free-text box plus suggested chips. Chips constrain the input space to valid 'big goals' so the AI never receives junk — preventing user errors before they happen." side="right" top={-4}/>}
          <div style={{fontFamily:'Fraunces, serif', fontWeight:700, fontSize:26, letterSpacing:-0.5, marginBottom:6}}>
            What's the big thing?
          </div>
          <div style={{color:'var(--ink-3)', fontSize:14, marginBottom:14}}>
            Type any goal. I'll break it into bite-sized study sessions.
          </div>

          <div style={{
            background:'#fff', border:'1.5px solid var(--line-2)',
            borderRadius:18, padding:14, position:'relative',
            boxShadow:'0 1px 0 rgba(15,15,26,.02), 0 8px 24px -14px rgba(20,80,120,.25)',
          }}>
            <textarea
              value={goalDraft}
              onChange={(e) => dispatch({type:'goalDraft', value: e.target.value})}
              placeholder="e.g. Prep for CS-201 midterm by Friday"
              style={{
                width:'100%', border:'none', outline:'none', resize:'none',
                fontFamily:'Manrope, sans-serif', fontSize:15, fontWeight:500,
                color:'var(--ink)', minHeight:64, background:'transparent',
              }}
            />
            <div style={{display:'flex', justifyContent:'space-between', alignItems:'center', marginTop:6, fontSize:11, color:'var(--ink-4)'}}>
              <span>{goalDraft.length}/140</span>
              <span>Tako will draft 4–8 tasks</span>
            </div>
          </div>

          <div style={{margin:'14px 0 6px', fontSize:12, fontWeight:700, color:'var(--ink-3)', letterSpacing:0.6, textTransform:'uppercase'}}>Or try one</div>
          <div style={{display:'flex', flexWrap:'wrap', gap:8}}>
            {['CS-201 midterm Friday','Read 3 chapters of Sociology','Build my portfolio site','Finish capstone proposal'].map(s => (
              <button key={s} className="tap" onClick={() => dispatch({type:'goalDraft', value: s})} style={{
                border:'1px solid var(--line-2)', background:'#fff',
                padding:'8px 12px', borderRadius:99, fontSize:12.5, fontWeight:600,
                color:'var(--ink-2)', cursor:'pointer',
              }}>{s}</button>
            ))}
          </div>

          <div style={{marginTop:18}}>
            <PrimaryCTA disabled={!goalDraft.trim()} onClick={() => dispatch({type:'startPlan'})}
              icon={<Icon name="sparkles" size={18} color="#fff"/>}>
              Break it down with AI
            </PrimaryCTA>
          </div>
        </div>
      )}

      {planStep === 'generating' && (
        <div className="fade-in" style={{textAlign:'center', paddingTop:30}}>
          <TakoMascot size={120} mood="focused"/>
          <div style={{fontFamily:'Fraunces, serif', fontWeight:700, fontSize:22, marginTop:18}}>
            Cooking your plan…
          </div>
          <div style={{color:'var(--ink-3)', fontSize:13, marginTop:6, marginBottom:18}}>
            Splitting "<i>{state.goalDraft}</i>" into bite-sized chunks.
          </div>
          {['Parsing your goal','Estimating effort per task','Sequencing by dependency','Padding break time'].map((s,i) => (
            <div key={s} style={{
              display:'flex', alignItems:'center', gap:10, padding:'10px 14px',
              background:'#fff', border:'1px solid var(--line)', borderRadius:14,
              marginBottom:6, animation:`fade-in .4s ${i*0.25}s both`,
            }}>
              <div style={{
                width:18, height:18, borderRadius:99,
                background:i<3?'linear-gradient(135deg,#42D391,#10B981)':'var(--line)',
                display:'grid', placeItems:'center', flexShrink:0,
              }}>{i<3 && <Icon name="check" size={10} color="#fff" stroke={3}/>}</div>
              <div style={{fontSize:13, fontWeight:600, color: i<3 ? 'var(--ink)' : 'var(--ink-3)'}}>{s}</div>
              {i===3 && <div className="shimmer" style={{flex:1, height:8, borderRadius:99, background:'#DDF3FE'}}/>}
            </div>
          ))}
        </div>
      )}

      {planStep === 'review' && (
        <div className="fade-in" style={{position:'relative'}}>
          {annotate && <HCIPin n="2" principle="Feedback · Closure"
            title="Reviewable, editable plan"
            body="AI output is shown as discrete cards the student can re-order, edit, or delete — gives sense of control. Total time/points footer closes the loop ('here's exactly what you committed to')." side="right" top={-4}/>}
          <div style={{display:'flex', alignItems:'center', justifyContent:'space-between', marginBottom:6}}>
            <div>
              <div style={{fontSize:11, fontWeight:700, color:'var(--ink-3)', letterSpacing:0.6, textTransform:'uppercase'}}>Your plan</div>
              <div style={{fontFamily:'Fraunces, serif', fontWeight:700, fontSize:20, lineHeight:1.15, marginTop:2}}>{state.goalDraft || 'Prep for CS-201 midterm'}</div>
            </div>
            <button className="tap" onClick={() => dispatch({type:'regen'})} style={{
              border:'1px solid var(--line-2)', background:'#fff', borderRadius:99,
              padding:'8px 10px', display:'inline-flex', alignItems:'center', gap:4,
              fontSize:11, fontWeight:700, color:'var(--ink-2)', cursor:'pointer',
            }}><Icon name="refresh" size={13}/> Regen</button>
          </div>

          <div style={{display:'flex', flexDirection:'column', gap:10, marginTop:12}}>
            {planTasks.map((t, i) => (
              <PlanTaskCard key={t.id} task={t} index={i+1}
                onEdit={(field, val) => dispatch({type:'editPlan', id:t.id, field, value:val})}
                onDelete={() => dispatch({type:'delPlan', id:t.id})}/>
            ))}
            <button className="tap" onClick={() => dispatch({type:'addPlan'})} style={{
              border:'1px dashed var(--line-2)', background:'transparent',
              padding:12, borderRadius:14, color:'var(--ink-3)', fontSize:13, fontWeight:600,
              display:'inline-flex', alignItems:'center', justifyContent:'center', gap:6, cursor:'pointer',
            }}><Icon name="plus" size={14}/> Add a task</button>
          </div>

          {/* Footer */}
          <div style={{
            marginTop:14, padding:'14px 16px', background:'#fff',
            border:'1px solid var(--line)', borderRadius:18,
            display:'flex', alignItems:'center', justifyContent:'space-between',
          }}>
            <div>
              <div style={{fontSize:11, fontWeight:700, color:'var(--ink-3)', letterSpacing:0.6, textTransform:'uppercase'}}>Total</div>
              <div className="mono" style={{fontWeight:700, fontSize:15, marginTop:2}}>
                {planTasks.reduce((s,t)=>s+t.minutes,0)} min · +{planTasks.reduce((s,t)=>s+t.points,0)} pts
              </div>
            </div>
            <div style={{display:'flex', gap:6}}>
              {planTasks.slice(0,4).map(t => (
                <div key={t.id} style={{width:8, height:24, borderRadius:99, background: 'linear-gradient(180deg,#5BCBF5,#1FB6F0)'}}/>
              ))}
            </div>
          </div>

          <div style={{marginTop:14, display:'flex', gap:8}}>
            <PrimaryCTA tone="ghost" onClick={() => dispatch({type:'resetPlan'})}>Start over</PrimaryCTA>
            <PrimaryCTA onClick={() => { dispatch({type:'commitPlan'}); goTo('home'); }} icon={<Icon name="check" size={18} color="#fff"/>}>
              Add to today
            </PrimaryCTA>
          </div>
        </div>
      )}
    </div>
  );
}

function PlanTaskCard({ task, index, onEdit, onDelete }) {
  const [editing, setEditing] = React.useState(false);
  return (
    <div style={{
      background:'#fff', border:'1px solid var(--line)', borderRadius:18, padding:'12px 14px',
      display:'flex', alignItems:'center', gap:12,
    }}>
      <div style={{
        width:30, height:30, borderRadius:10,
        background:'linear-gradient(135deg,#DDF3FE,#B8E0F7)',
        color:'var(--primary)', fontWeight:800, display:'grid', placeItems:'center', fontSize:13,
        flexShrink:0,
      }}>{index}</div>
      <div style={{flex:1, minWidth:0}}>
        {editing ? (
          <input autoFocus value={task.title}
            onChange={(e)=>onEdit('title', e.target.value)}
            onBlur={()=>setEditing(false)}
            onKeyDown={(e)=>e.key==='Enter'&&setEditing(false)}
            style={{
              width:'100%', border:'none', outline:'none', fontSize:14,
              fontWeight:700, fontFamily:'Manrope, sans-serif', color:'var(--ink)',
              borderBottom:'2px solid var(--primary)', paddingBottom:2,
            }}/>
        ) : (
          <div onClick={()=>setEditing(true)} style={{fontSize:14, fontWeight:700, color:'var(--ink)', cursor:'text'}}>
            {task.title}
          </div>
        )}
        <div style={{fontSize:11.5, color:'var(--ink-3)', marginTop:2, display:'flex', gap:8}}>
          <span>⏱ {task.minutes}m</span>
          <span style={{color:'var(--primary)', fontWeight:700}}>+{task.points} pts</span>
        </div>
      </div>
      <button className="tap" onClick={()=>setEditing(true)} style={{
        border:'none', background:'transparent', cursor:'pointer', padding:6,
      }}><Icon name="edit" size={16} color="var(--ink-3)"/></button>
      <button className="tap" onClick={onDelete} style={{
        border:'none', background:'transparent', cursor:'pointer', padding:6,
      }}><Icon name="close" size={16} color="var(--ink-3)"/></button>
    </div>
  );
}

// =====================================================
// 3. GAMIFICATION + SOCIAL HUB
// =====================================================
function HubScreen({ state, dispatch, annotate }) {
  const [tab, setTab] = React.useState('badges'); // badges | leaderboard | report
  const [shareBadge, setShareBadge] = React.useState(null);

  return (
    <div className="phone-scroll" style={{padding:'56px 18px 110px', height:'100%', overflowY:'auto'}}>
      <div style={{display:'flex', alignItems:'center', justifyContent:'space-between', marginBottom:14}}>
        <div>
          <div style={{fontFamily:'Fraunces, serif', fontWeight:700, fontSize:26, letterSpacing:-0.5}}>Trophy room</div>
          <div style={{color:'var(--ink-3)', fontSize:13, marginTop:2}}>Earn it, share it, lord it over your squad.</div>
        </div>
        <TakoMascot size={48} mood="excited"/>
      </div>

      {/* Tabs */}
      <div style={{
        background:'#EEECF7', borderRadius:14, padding:4, display:'flex', gap:4, marginBottom:14,
      }}>
        {[{k:'badges', label:'Badges'},{k:'leaderboard', label:'Squad'},{k:'report', label:'Report card'}].map(t => {
          const active = tab === t.k;
          return (
            <button key={t.k} onClick={() => setTab(t.k)} className="tap" style={{
              flex:1, border:'none', borderRadius:10, padding:'8px 6px',
              background: active ? '#fff' : 'transparent',
              color: active ? 'var(--ink)' : 'var(--ink-3)',
              fontWeight: active ? 700 : 600, fontSize: 12.5,
              boxShadow: active ? '0 2px 8px -2px rgba(20,80,120,.18)' : 'none',
              cursor:'pointer',
            }}>{t.label}</button>
          );
        })}
      </div>

      {tab === 'badges' && (
        <div className="fade-in" style={{position:'relative'}}>
          {annotate && <HCIPin n="1" principle="Gestalt · Similarity"
            title="Earned vs locked groupings"
            body="Identical shape but color/saturation indicate state. The eye reads the unlocked set as a 'collection' (closure) — locked items provide aspirational pull without dominating." side="right" top={-4}/>}

          <Card style={{background:'linear-gradient(135deg,#FFE6DD 0%, #FFF1C9 100%)', marginBottom:14, border:'1px solid #FFD7C2'}}>
            <div style={{display:'flex', alignItems:'center', justifyContent:'space-between'}}>
              <div>
                <div style={{fontSize:11, fontWeight:700, color:'#B85A3A', letterSpacing:0.6, textTransform:'uppercase'}}>New badge!</div>
                <div style={{fontFamily:'Fraunces, serif', fontWeight:700, fontSize:18, marginTop:4}}>5-day streak</div>
                <div style={{fontSize:12, color:'#7A4628', marginTop:2}}>Unlocked this morning.</div>
              </div>
              <BadgeIcon kind="streak5" size={68} unlocked animate/>
            </div>
            <div style={{display:'flex', gap:6, marginTop:10}}>
              <PrimaryCTA tone="energy" full={false} onClick={() => setShareBadge({kind:'streak5', name:'5-day streak'})}
                icon={<Icon name="share" size={15} color="#fff"/>}>Share</PrimaryCTA>
              <button className="tap" style={{
                border:'1px solid rgba(184,90,58,.25)', background:'rgba(255,255,255,.5)',
                borderRadius:14, padding:'12px 14px', color:'#B85A3A', fontWeight:700, fontSize:13.5, cursor:'pointer',
              }}>View</button>
            </div>
          </Card>

          <SectionH action="12/24">All badges</SectionH>
          <div style={{display:'grid', gridTemplateColumns:'repeat(3, 1fr)', gap:10}}>
            {[
              {k:'streak5', name:'5 streak', unlocked:true},
              {k:'first', name:'First win', unlocked:true},
              {k:'night', name:'Night owl', unlocked:true},
              {k:'sprint', name:'Speedrun', unlocked:true},
              {k:'focus', name:'Deep focus', unlocked:false},
              {k:'social', name:'Squad up', unlocked:false},
              {k:'phoenix', name:'Phoenix', unlocked:false},
              {k:'legend', name:'Legend', unlocked:false},
              {k:'scholar', name:'Scholar', unlocked:false},
            ].map(b => (
              <div key={b.k} style={{
                background:'#fff', border:'1px solid var(--line)', borderRadius:16,
                padding:10, display:'flex', flexDirection:'column', alignItems:'center', gap:4,
                opacity: b.unlocked ? 1 : 0.55,
              }} className="tap" onClick={()=> b.unlocked && setShareBadge({kind:b.k, name:b.name})}>
                <BadgeIcon kind={b.k} size={52} unlocked={b.unlocked}/>
                <div style={{fontSize:11, fontWeight:700, color: b.unlocked ? 'var(--ink)' : 'var(--ink-4)', textAlign:'center'}}>{b.name}</div>
              </div>
            ))}
          </div>
        </div>
      )}

      {tab === 'leaderboard' && (
        <div className="fade-in" style={{position:'relative'}}>
          {annotate && <HCIPin n="2" principle="Visual Hierarchy"
            title="You are highlighted"
            body="Your row uses the primary accent + slightly larger type — instantly findable in a long list (Gulf of Evaluation). Top-3 podium uses scale to encode rank, not numbers alone." side="left" top={-6}/>}

          {/* Podium */}
          <div style={{display:'flex', alignItems:'flex-end', justifyContent:'center', gap:12, padding:'14px 0 6px'}}>
            {[
              {pos:2, name:'Maya', pts:2150, color:'#C0BFD3', h:60},
              {pos:1, name:'Zara', pts:2480, color:'#F5C544', h:84},
              {pos:3, name:'Omar', pts:1920, color:'#FF8A65', h:46},
            ].map(p => (
              <div key={p.pos} style={{display:'flex', flexDirection:'column', alignItems:'center', gap:6, flex:1}}>
                <div style={{
                  width:54, height:54, borderRadius:99,
                  background: `linear-gradient(135deg, #fff, ${p.color}55)`,
                  border:`3px solid ${p.color}`,
                  display:'grid', placeItems:'center',
                  fontWeight:800, fontSize:18, color:'var(--ink)',
                  position:'relative',
                }}>{p.name[0]}
                  {p.pos===1 && <div style={{position:'absolute', top:-18, fontSize:22}}>👑</div>}
                </div>
                <div style={{fontWeight:700, fontSize:13}}>{p.name}</div>
                <div className="mono" style={{fontSize:11.5, color:'var(--ink-3)', fontWeight:600}}>{p.pts.toLocaleString()} pts</div>
                <div style={{
                  width:'100%', height:p.h, borderRadius:'12px 12px 0 0',
                  background:`linear-gradient(180deg, ${p.color}, ${p.color}88)`,
                  display:'grid', placeItems:'center', color:'#fff', fontWeight:800, fontSize:18,
                }}>{p.pos}</div>
              </div>
            ))}
          </div>

          <SectionH action="Squad of 8">This week</SectionH>
          <div style={{display:'flex', flexDirection:'column', gap:6}}>
            {[
              {pos:4, name:'Ana',   pts:1640},
              {pos:5, name:'You',   pts:state.points, me:true},
              {pos:6, name:'Sara',  pts:1180},
              {pos:7, name:'Bilal', pts:920},
              {pos:8, name:'Aliyah',pts:680},
            ].map(r => (
              <div key={r.pos} style={{
                background: r.me ? 'linear-gradient(90deg, #DDF3FE, #fff)' : '#fff',
                border: r.me ? '1.5px solid var(--primary)' : '1px solid var(--line)',
                borderRadius:14, padding:'10px 12px',
                display:'flex', alignItems:'center', gap:10,
              }}>
                <div className="mono" style={{
                  width:24, fontWeight:800, fontSize:13,
                  color: r.me ? 'var(--primary)' : 'var(--ink-3)',
                }}>{r.pos}</div>
                <div style={{
                  width:32, height:32, borderRadius:99,
                  background: r.me ? 'linear-gradient(135deg,#FFD1B8,#FF8A65)' : 'linear-gradient(135deg,#C7E9F8,#A8DDF5)',
                  color: '#fff', display:'grid', placeItems:'center', fontWeight:800, fontSize:13,
                }}>{r.name[0]}</div>
                <div style={{flex:1, fontWeight: r.me ? 800 : 600, fontSize:14, color:'var(--ink)'}}>{r.name}</div>
                <div className="mono" style={{fontWeight:700, fontSize:13, color: r.me ? 'var(--primary)' : 'var(--ink-2)'}}>{r.pts.toLocaleString()}</div>
              </div>
            ))}
          </div>

          <button className="tap" style={{
            marginTop:14, width:'100%', border:'1px solid var(--line-2)', background:'#fff',
            borderRadius:14, padding:12, fontWeight:700, fontSize:13.5,
            display:'inline-flex', alignItems:'center', justifyContent:'center', gap:6,
            color:'var(--ink-2)', cursor:'pointer',
          }}><Icon name="users" size={16}/> Invite a friend</button>
        </div>
      )}

      {tab === 'report' && (
        <div className="fade-in" style={{position:'relative'}}>
          {annotate && <HCIPin n="3" principle="Closure · Feedback"
            title="Week summarized in one card"
            body="Big-number stats + a sparkline give an instant 'how did I do' read. One-tap share creates a closing emotional moment + drives organic growth." side="right" top={-4}/>}

          <div style={{
            background:'linear-gradient(135deg, #1FB6F0 0%, #1FB6F0 50%, #FF8A65 130%)',
            borderRadius:24, padding:18, color:'#fff', position:'relative', overflow:'hidden',
            boxShadow:'0 20px 40px -16px rgba(31,182,240,.55)',
          }}>
            <div style={{position:'absolute', right:-20, top:-20, width:120, height:120, borderRadius:99, background:'rgba(255,255,255,.1)'}}/>
            <div style={{display:'flex', alignItems:'center', justifyContent:'space-between'}}>
              <div>
                <div style={{fontSize:11, fontWeight:700, letterSpacing:0.8, textTransform:'uppercase', opacity:.9}}>Week 21 · 2026</div>
                <div style={{fontFamily:'Fraunces, serif', fontWeight:700, fontSize:22, marginTop:4}}>{state.user.name}'s report card</div>
              </div>
              <TaskkoLogo size={14}/>
            </div>

            <div style={{display:'grid', gridTemplateColumns:'1fr 1fr', gap:10, marginTop:14}}>
              {[
                {label:'Tasks done', value:'34', sub:'+18% vs last week'},
                {label:'Focus time', value:'12.5h', sub:'PRs: 3 days'},
                {label:'Points earned', value:'620', sub:'Top 15% of squad'},
                {label:'Streak high', value:'5🔥', sub:'New record!'},
              ].map(s => (
                <div key={s.label} style={{
                  background:'rgba(255,255,255,.14)', borderRadius:14, padding:10,
                  backdropFilter:'blur(10px)',
                }}>
                  <div style={{fontSize:10.5, fontWeight:700, opacity:.85, letterSpacing:0.4, textTransform:'uppercase'}}>{s.label}</div>
                  <div style={{fontFamily:'Fraunces, serif', fontWeight:700, fontSize:24, marginTop:2}}>{s.value}</div>
                  <div style={{fontSize:10.5, opacity:.85, marginTop:2}}>{s.sub}</div>
                </div>
              ))}
            </div>

            {/* Sparkline */}
            <div style={{marginTop:14, padding:'10px 12px', background:'rgba(255,255,255,.12)', borderRadius:14}}>
              <div style={{fontSize:11, fontWeight:700, opacity:.85, marginBottom:6}}>Tasks per day</div>
              <svg viewBox="0 0 200 50" width="100%" height="50">
                <polyline points="0,40 30,28 60,32 90,18 120,22 150,10 180,8 200,4"
                  fill="none" stroke="#fff" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"/>
                {[[0,40],[30,28],[60,32],[90,18],[120,22],[150,10],[180,8],[200,4]].map(([x,y],i)=>(
                  <circle key={i} cx={x} cy={y} r="3" fill="#fff"/>
                ))}
              </svg>
              <div style={{display:'flex', justifyContent:'space-between', fontSize:9.5, opacity:.8, marginTop:2}}>
                {['M','T','W','T','F','S','S'].map(d => <span key={d}>{d}</span>)}
              </div>
            </div>

            <div style={{marginTop:14, display:'flex', gap:8}}>
              <button onClick={() => setShareBadge({kind:'report', name:'Weekly report'})} className="tap" style={{
                flex:1, border:'none', background:'#fff', color:'var(--primary)',
                padding:'12px 14px', borderRadius:14, fontWeight:800, fontSize:14,
                display:'inline-flex', alignItems:'center', justifyContent:'center', gap:6, cursor:'pointer',
              }}><Icon name="share" size={16}/> Share my week</button>
              <button className="tap" style={{
                border:'1px solid rgba(255,255,255,.4)', background:'rgba(255,255,255,.16)',
                color:'#fff', padding:'12px 14px', borderRadius:14, fontWeight:700, fontSize:13, cursor:'pointer',
              }}>Details</button>
            </div>
          </div>

          <div style={{marginTop:14, padding:14, background:'#fff', border:'1px solid var(--line)', borderRadius:18}}>
            <div style={{fontSize:11, fontWeight:700, color:'var(--ink-3)', letterSpacing:0.6, textTransform:'uppercase'}}>Tako's note</div>
            <div style={{fontSize:13.5, marginTop:4, lineHeight:1.5, color:'var(--ink-2)'}}>
              You really showed up midweek. Tuesday's focus was your best in 3 weeks. Let's chase a 7-day streak next week — pace yourself on Sundays.
            </div>
          </div>
        </div>
      )}

      {/* Share sheet modal */}
      {shareBadge && <ShareSheet badge={shareBadge} onClose={() => setShareBadge(null)} userName={state.user.name}/>}
    </div>
  );
}

function BadgeIcon({ kind, size = 56, unlocked = true, animate = false }) {
  const palettes = {
    streak5: ['#FFC062','#F26B47'],
    first:   ['#5BCBF5','#1FB6F0'],
    night:   ['#1FB6F0','#1E1B5C'],
    sprint:  ['#FF8A65','#F26B47'],
    focus:   ['#34D399','#10B981'],
    social:  ['#F472B6','#EC4899'],
    phoenix: ['#F5C544','#F26B47'],
    legend:  ['#5BCBF5','#FF8A65'],
    scholar: ['#34D399','#1FB6F0'],
  };
  const [a, b] = palettes[kind] || ['#5BCBF5','#1FB6F0'];
  const icons = {
    streak5: '🔥', first: '✦', night: '🌙', sprint: '⚡', focus: '🎯', social: '👯', phoenix: '🐦‍🔥', legend: '👑', scholar: '📚',
  };
  return (
    <div style={{
      width:size, height:size, position:'relative',
      animation: animate ? 'float 2.6s ease-in-out infinite' : 'none',
    }}>
      <svg viewBox="0 0 100 100" width={size} height={size}>
        <defs>
          <linearGradient id={`bg-${kind}`} x1="0" y1="0" x2="1" y2="1">
            <stop offset="0%" stopColor={unlocked?a:'#D8D8E5'}/>
            <stop offset="100%" stopColor={unlocked?b:'#A8A8BC'}/>
          </linearGradient>
        </defs>
        {/* Octagonal medal */}
        <path d="M50 4 L78 16 L94 44 L86 76 L62 94 L38 94 L14 76 L6 44 L22 16 Z"
              fill={`url(#bg-${kind})`}/>
        <path d="M50 14 L70 22 L82 44 L76 70 L58 84 L42 84 L24 70 L18 44 L30 22 Z"
              fill="none" stroke="rgba(255,255,255,.55)" strokeWidth="1.5"/>
        <text x="50" y="60" textAnchor="middle" fontSize="32">{unlocked ? icons[kind] : '🔒'}</text>
      </svg>
    </div>
  );
}

function ShareSheet({ badge, onClose, userName }) {
  return (
    <div style={{
      position:'absolute', inset:0, zIndex:200,
      background:'rgba(15,15,26,.5)', backdropFilter:'blur(6px)',
      display:'flex', alignItems:'flex-end',
    }} onClick={onClose}>
      <div onClick={e => e.stopPropagation()} style={{
        width:'100%', background:'#F7F6FB', borderRadius:'28px 28px 0 0',
        padding:'14px 18px 30px',
      }}>
        <div style={{width:40, height:5, borderRadius:99, background:'var(--line-2)', margin:'0 auto 12px'}}/>
        <div style={{fontFamily:'Fraunces, serif', fontWeight:700, fontSize:20, textAlign:'center', marginBottom:14}}>
          Share to socials
        </div>

        {/* Generated share card preview */}
        <div style={{
          background:'linear-gradient(135deg,#1FB6F0,#1FB6F0,#FF8A65)',
          borderRadius:20, padding:22, color:'#fff', textAlign:'center',
          boxShadow:'0 20px 40px -10px rgba(31,182,240,.5)',
          marginBottom:14,
        }}>
          <div style={{display:'flex', alignItems:'center', justifyContent:'center', gap:6, opacity:.9, fontSize:11, fontWeight:700, letterSpacing:0.8, textTransform:'uppercase'}}>
            <TaskkoLogo size={12}/> · achievement
          </div>
          <div style={{margin:'14px auto'}}>
            <BadgeIcon kind={badge.kind === 'report' ? 'first' : badge.kind} size={88}/>
          </div>
          <div style={{fontFamily:'Fraunces, serif', fontWeight:700, fontSize:22}}>{badge.name}</div>
          <div style={{fontSize:13, marginTop:4, opacity:.92}}>{userName} just unlocked this on Taskko</div>
        </div>

        <div style={{display:'grid', gridTemplateColumns:'repeat(4, 1fr)', gap:10}}>
          {[
            {n:'Instagram', c:'linear-gradient(135deg,#F58529,#DD2A7B,#8134AF)'},
            {n:'X', c:'#000'},
            {n:'Snap', c:'#FFFC00'},
            {n:'Copy', c:'#fff'},
          ].map(s => (
            <button key={s.n} className="tap" style={{
              border:s.n==='Copy'?'1px solid var(--line-2)':'none',
              background:s.c, padding:'12px 8px', borderRadius:14,
              color: s.n==='Snap'?'#000': s.n==='Copy'?'var(--ink)':'#fff',
              fontWeight:700, fontSize:11.5, cursor:'pointer',
            }}>{s.n}</button>
          ))}
        </div>
        <button onClick={onClose} className="tap" style={{
          marginTop:12, width:'100%', border:'none', background:'transparent',
          color:'var(--ink-3)', fontWeight:600, fontSize:14, padding:8, cursor:'pointer',
        }}>Cancel</button>
      </div>
    </div>
  );
}

// =====================================================
// 4. AI CHATBOT (TAKO)
// =====================================================
function ChatScreen({ state, dispatch, annotate }) {
  const { chatMessages, mood } = state;
  const [draft, setDraft] = React.useState('');
  const [typing, setTyping] = React.useState(false);
  const scrollRef = React.useRef(null);

  React.useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [chatMessages, typing]);

  const send = (text) => {
    if (!text.trim()) return;
    dispatch({type:'chatSend', text});
    setDraft('');
    setTyping(true);
    setTimeout(() => {
      dispatch({type:'chatReply', text: pickReply(text)});
      setTyping(false);
    }, 1400);
  };

  return (
    <div style={{display:'flex', flexDirection:'column', height:'100%', paddingTop:48}}>
      {/* Header */}
      <div style={{
        padding:'10px 18px 12px', borderBottom:'1px solid var(--line)',
        display:'flex', alignItems:'center', gap:12, background:'rgba(247,246,251,.9)',
        backdropFilter:'blur(10px)',
      }}>
        <TakoMascot size={42} mood={mood === 'tired' ? 'tired' : mood === 'energized' ? 'excited' : 'happy'} animate={false}/>
        <div style={{flex:1}}>
          <div style={{fontWeight:700, fontSize:16, display:'flex', alignItems:'center', gap:6}}>
            Tako <span style={{width:8, height:8, borderRadius:99, background:'var(--mint)'}}/>
          </div>
          <div style={{fontSize:11.5, color:'var(--ink-3)', marginTop:1}}>Your AI study buddy · {mood} mode</div>
        </div>
        <button className="tap" style={{border:'none', background:'transparent', cursor:'pointer'}}>
          <Icon name="dots" size={22} color="var(--ink-3)"/>
        </button>
      </div>

      {/* Messages */}
      <div ref={scrollRef} className="phone-scroll" style={{
        flex:1, overflowY:'auto', padding:'14px 16px', display:'flex', flexDirection:'column', gap:8,
        background:'linear-gradient(180deg, #F7F6FB 0%, #EEECF7 100%)',
        position:'relative',
      }}>
        {annotate && <HCIPin n="1" principle="Gestalt · Proximity & Continuity"
          title="Conversation grouped by side"
          body="User and Tako messages anchor to opposite sides with distinct color — Gestalt grouping makes the conversation flow instantly readable. Avatar appears once per Tako block, not every message (closure)." side="right" top={6}/>}

        {chatMessages.map((m, i) => (
          <ChatBubble key={i} m={m} prev={chatMessages[i-1]}/>
        ))}
        {typing && (
          <div style={{display:'flex', alignItems:'flex-end', gap:6}}>
            <TakoMascot size={28} mood="happy" animate={false}/>
            <div style={{
              background:'#fff', border:'1px solid var(--line)',
              padding:'10px 14px', borderRadius:'18px 18px 18px 4px',
              display:'flex', gap:4,
            }}>
              {[0,1,2].map(i => (
                <div key={i} style={{
                  width:7, height:7, borderRadius:99, background:'var(--ink-4)',
                  animation:`float 1.2s ease-in-out ${i*0.15}s infinite`,
                }}/>
              ))}
            </div>
          </div>
        )}
      </div>

      {/* Quick prompts */}
      <div style={{padding:'10px 12px 6px', display:'flex', gap:6, overflowX:'auto', position:'relative'}}>
        {annotate && <HCIPin n="2" principle="Affordance · Constraints"
          title="Quick prompts reduce cold-start"
          body="Pre-formed nudge buttons make 'what should I say?' a non-question. Reduces effort and signals what Tako is good at." side="left" top={-2}/>}
        {[
          'I\'m stuck',
          'Plan my evening',
          'Motivate me',
          'I want a break',
          'Why am I behind?',
        ].map(q => (
          <button key={q} className="tap" onClick={() => send(q)} style={{
            border:'1px solid var(--line-2)', background:'#fff',
            padding:'8px 12px', borderRadius:99, fontSize:12, fontWeight:600,
            color:'var(--ink-2)', whiteSpace:'nowrap', cursor:'pointer', flexShrink:0,
          }}>{q}</button>
        ))}
      </div>

      {/* Input */}
      <div style={{
        padding:'8px 14px 30px', background:'#F7F6FB',
        display:'flex', alignItems:'center', gap:8,
      }}>
        <div style={{
          flex:1, background:'#fff', border:'1px solid var(--line-2)',
          borderRadius:24, padding:'4px 4px 4px 14px',
          display:'flex', alignItems:'center', gap:6,
          boxShadow:'0 1px 0 rgba(15,15,26,.02)',
        }}>
          <input
            value={draft}
            onChange={e => setDraft(e.target.value)}
            onKeyDown={e => e.key==='Enter' && send(draft)}
            placeholder="Message Tako…"
            style={{
              flex:1, border:'none', outline:'none', fontSize:14,
              fontFamily:'Manrope, sans-serif', color:'var(--ink)', background:'transparent', padding:'10px 0',
            }}
          />
          <button className="tap" style={{
            width:32, height:32, border:'none', borderRadius:99,
            background:'transparent', display:'grid', placeItems:'center', cursor:'pointer',
          }}><Icon name="mic" size={18} color="var(--ink-3)"/></button>
        </div>
        <button className="tap" disabled={!draft.trim()} onClick={() => send(draft)} style={{
          width:44, height:44, border:'none', borderRadius:99,
          background: draft.trim() ? 'linear-gradient(135deg,#5BCBF5,#1FB6F0)' : 'var(--line-2)',
          color:'#fff', display:'grid', placeItems:'center', cursor:'pointer',
          boxShadow: draft.trim() ? '0 8px 18px -8px rgba(31,182,240,.6)' : 'none',
        }}><Icon name="send" size={18} color="#fff"/></button>
      </div>
    </div>
  );
}

function ChatBubble({ m, prev }) {
  const isMe = m.from === 'me';
  const showAvatar = !isMe && (!prev || prev.from !== 'tako');

  // System cards (e.g. nudge with action)
  if (m.kind === 'nudge') {
    return (
      <div style={{display:'flex', gap:6, alignItems:'flex-end'}}>
        {showAvatar ? <TakoMascot size={28} mood="happy" animate={false}/> : <div style={{width:28}}/>}
        <div style={{
          maxWidth:'78%',
          background:'linear-gradient(135deg, #DDF3FE, #fff)',
          border:'1px solid #A8DDF5',
          padding:14, borderRadius:'18px 18px 18px 4px',
        }}>
          <div style={{display:'flex', alignItems:'center', gap:6, fontSize:11, fontWeight:700, color:'var(--primary)', letterSpacing:0.4, textTransform:'uppercase'}}>
            <Icon name="bolt" size={13}/> Nudge
          </div>
          <div style={{fontSize:14, fontWeight:600, color:'var(--ink)', marginTop:6, lineHeight:1.5}}>
            {m.text}
          </div>
          {m.actions && (
            <div style={{display:'flex', gap:6, marginTop:10}}>
              {m.actions.map(a => (
                <button key={a} className="tap" style={{
                  border:'none', background:'var(--primary)', color:'#fff',
                  padding:'8px 12px', borderRadius:99, fontSize:12, fontWeight:700, cursor:'pointer',
                }}>{a}</button>
              ))}
            </div>
          )}
        </div>
      </div>
    );
  }

  return (
    <div style={{
      display:'flex', justifyContent: isMe ? 'flex-end' : 'flex-start',
      gap:6, alignItems:'flex-end',
    }}>
      {!isMe && (showAvatar ? <TakoMascot size={28} mood="happy" animate={false}/> : <div style={{width:28}}/>)}
      <div style={{
        maxWidth:'78%',
        background: isMe ? 'linear-gradient(135deg,#5BCBF5,#1FB6F0)' : '#fff',
        color: isMe ? '#fff' : 'var(--ink)',
        border: isMe ? 'none' : '1px solid var(--line)',
        padding:'10px 14px',
        borderRadius: isMe ? '18px 18px 4px 18px' : '18px 18px 18px 4px',
        fontSize:14, lineHeight:1.5,
        boxShadow: isMe ? '0 8px 20px -10px rgba(31,182,240,.5)' : '0 1px 0 rgba(15,15,26,.02)',
      }}>
        {m.text}
      </div>
    </div>
  );
}

function pickReply(text) {
  const t = text.toLowerCase();
  if (t.includes('stuck')) return "Totally fair. Let's shrink the next task — pick the smallest piece you can finish in 10 minutes and I'll start a focus timer. Often momentum > motivation.";
  if (t.includes('motivat')) return "You're 320 points from Elite and on a 5-day streak. The version of you that finishes today's CS reading is one step closer to that rank. One task at a time. 🚀";
  if (t.includes('break')) return "Good call — your brain's not a machine. 15-min break, eyes off screen, glass of water. I'll ping you when it's time to come back.";
  if (t.includes('behind')) return "You're not behind, you're recalibrating. Want me to re-plan the rest of the week around what's left? I can compress the load without burning you out.";
  if (t.includes('plan') || t.includes('evening')) return "Here's a 90-min evening plan: 30m CS reading → 5m break → 25m practice problems → 5m break → 25m review. Sound good?";
  return "Got it. Want me to break this into smaller steps, or just sit with you while you work?";
}

Object.assign(window, { HomeScreen, PlanScreen, HubScreen, ChatScreen });
