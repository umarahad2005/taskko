// Taskko — Splash, Onboarding, Sign-up, Login
// =====================================================

// ----- Big app logo (used on splash + auth screens) -----
function TaskkoAppLogo({ size = 120, animate = true }) {
  return (
    <div style={{
      width: size, height: size, position: 'relative',
      animation: animate ? 'float 3.6s ease-in-out infinite' : 'none',
    }}>
      <svg viewBox="0 0 120 120" width={size} height={size}>
        <defs>
          <linearGradient id="logo-bg" x1="0" y1="0" x2="1" y2="1">
            <stop offset="0%"   stopColor="#5BCBF5"/>
            <stop offset="55%"  stopColor="#1FB6F0"/>
            <stop offset="100%" stopColor="#0E8FC4"/>
          </linearGradient>
          <linearGradient id="logo-spark" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%" stopColor="#FFD7BC"/>
            <stop offset="100%" stopColor="#FF8A65"/>
          </linearGradient>
          <radialGradient id="logo-glow" cx="50%" cy="50%" r="50%">
            <stop offset="0%" stopColor="#C7B8FF" stopOpacity="0.7"/>
            <stop offset="100%" stopColor="#C7B8FF" stopOpacity="0"/>
          </radialGradient>
        </defs>
        <circle cx="60" cy="62" r="58" fill="url(#logo-glow)"/>
        {/* Squircle */}
        <path d="M60 8 C 96 8, 112 24, 112 60 C 112 96, 96 112, 60 112 C 24 112, 8 96, 8 60 C 8 24, 24 8, 60 8 Z"
              fill="url(#logo-bg)"/>
        {/* Inner highlight */}
        <path d="M60 14 C 92 14, 106 28, 106 60 C 106 92, 92 106, 60 106"
              fill="none" stroke="rgba(255,255,255,0.18)" strokeWidth="2"/>
        {/* Stylized 't' formed from a checkmark — encodes the app's verb (mark done) */}
        <path d="M40 60 L54 74 L84 38"
              fill="none" stroke="#fff" strokeWidth="9" strokeLinecap="round" strokeLinejoin="round"/>
        {/* Spark on top — energy/streak motif */}
        <g transform="translate(86 26)">
          <path d="M0 -10 L3 -3 L10 0 L3 3 L0 10 L-3 3 L-10 0 L-3 -3 Z" fill="url(#logo-spark)"
                style={{animation: animate ? 'spark 2s ease-in-out infinite' : 'none', transformOrigin: 'center'}}/>
        </g>
      </svg>
    </div>
  );
}

// =====================================================
// SPLASH
// =====================================================
function SplashScreen({ onDone, autoAdvance = true }) {
  const [stage, setStage] = React.useState(0); // 0: logo, 1: wordmark in
  React.useEffect(() => {
    const t1 = setTimeout(() => setStage(1), 800);
    const t2 = autoAdvance ? setTimeout(() => onDone && onDone(), 2400) : null;
    return () => { clearTimeout(t1); if (t2) clearTimeout(t2); };
  }, [autoAdvance]);

  return (
    <div style={{
      position:'absolute', inset:0,
      background: 'radial-gradient(120% 80% at 50% 30%, #1A1F4A 0%, #0F0F1A 60%, #050518 100%)',
      display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center',
      color:'#fff', overflow:'hidden',
    }}>
      {/* Decorative blobs */}
      <div style={{position:'absolute', top:-80, right:-40, width:240, height:240, borderRadius:99, background:'rgba(31,182,240,.18)'}}/>
      <div style={{position:'absolute', bottom:-60, left:-60, width:200, height:200, borderRadius:99, background:'rgba(255,138,101,.18)'}}/>

      <div style={{
        animation:'pop .5s cubic-bezier(.2,1.2,.4,1) both',
      }}>
        <TaskkoAppLogo size={132}/>
      </div>

      <div style={{
        marginTop: 22, fontFamily:'Fraunces, serif', fontWeight:700, fontSize: 40,
        letterSpacing:-1, opacity: stage>=1 ? 1 : 0,
        transform: stage>=1 ? 'translateY(0)' : 'translateY(8px)',
        transition: 'all .5s cubic-bezier(.2,1,.3,1)',
      }}>taskko</div>

      <div style={{
        marginTop: 6, fontSize: 13.5, fontWeight: 500, opacity: stage>=1 ? .85 : 0,
        transform: stage>=1 ? 'translateY(0)' : 'translateY(8px)',
        transition: 'all .55s .08s cubic-bezier(.2,1,.3,1)',
      }}>your AI productivity companion</div>

      <div style={{
        position:'absolute', bottom: 60, display:'flex', flexDirection:'column', alignItems:'center', gap:10,
        opacity: stage>=1 ? .8 : 0, transition: 'opacity .4s .2s',
      }}>
        <div className="shimmer" style={{
          width:120, height:4, borderRadius:99,
          background:'linear-gradient(90deg, rgba(255,255,255,.2), rgba(255,255,255,.7), rgba(255,255,255,.2))',
        }}/>
        <div style={{fontSize:11, fontWeight:600, opacity:.8, letterSpacing:0.4}}>loading…</div>
      </div>
    </div>
  );
}

// =====================================================
// ONBOARDING (3 slides)
// =====================================================
const ONBOARDING = [
  {
    accent: 'linear-gradient(135deg, #1FB6F0, #1FB6F0)',
    bg: 'linear-gradient(180deg, #DDF3FE 0%, #fff 70%)',
    title: 'Big goals,\nbroken down.',
    body: 'Drop a goal — "prep for midterm", "finish capstone" — and Tako turns it into a guided plan you can actually start.',
    illo: 'plan',
  },
  {
    accent: 'linear-gradient(135deg, #FF9B7A, #F26B47)',
    bg: 'linear-gradient(180deg, #FFE6DD 0%, #fff 70%)',
    title: 'Streaks that\nfeel rewarding.',
    body: 'Earn points, climb ranks, collect badges. Streak shields keep your fire alive on the days life happens.',
    illo: 'streak',
  },
  {
    accent: 'linear-gradient(135deg, #34D399, #10B981)',
    bg: 'linear-gradient(180deg, #D6F5E6 0%, #fff 70%)',
    title: 'Your squad,\non your side.',
    body: 'Share badges in one tap. Compete on weekly leaderboards. Get a weekly report card you\'ll actually want to post.',
    illo: 'social',
  },
];

function OnboardingScreen({ onFinish, onSkip, initialSlide = 0 }) {
  const [i, setI] = React.useState(initialSlide);
  const slide = ONBOARDING[i];
  const isLast = i === ONBOARDING.length - 1;

  return (
    <div style={{
      position:'absolute', inset:0, background: slide.bg,
      display:'flex', flexDirection:'column',
      paddingTop: 48, transition: 'background .4s ease',
    }}>
      {/* Top: skip */}
      <div style={{display:'flex', justifyContent:'space-between', alignItems:'center', padding:'16px 22px'}}>
        <TaskkoLogo size={18}/>
        <button onClick={onSkip} className="tap" style={{
          border:'none', background:'transparent', color:'var(--ink-3)',
          fontWeight:700, fontSize:13.5, cursor:'pointer', padding:'6px 10px',
        }}>Skip</button>
      </div>

      {/* Illustration */}
      <div style={{flex:1, display:'flex', alignItems:'center', justifyContent:'center', padding:'0 24px'}}>
        <div key={i} className="fade-in" style={{width:'100%', maxWidth:300}}>
          <OnboardIllustration kind={slide.illo} accent={slide.accent}/>
        </div>
      </div>

      {/* Copy */}
      <div style={{padding:'10px 28px 0'}}>
        <div key={i+'-t'} className="fade-in" style={{
          fontFamily:'Fraunces, serif', fontWeight:700, fontSize: 32, letterSpacing:-1,
          lineHeight:1.05, whiteSpace:'pre-line', color:'var(--ink)',
        }}>{slide.title}</div>
        <div key={i+'-b'} className="fade-in" style={{
          fontSize: 15, color:'var(--ink-3)', marginTop:10, lineHeight:1.55,
        }}>{slide.body}</div>
      </div>

      {/* Dots + CTA */}
      <div style={{padding:'24px 22px 48px'}}>
        <div style={{display:'flex', alignItems:'center', justifyContent:'space-between', marginBottom:18}}>
          <div style={{display:'flex', gap:6}}>
            {ONBOARDING.map((_, idx) => (
              <div key={idx} style={{
                width: idx === i ? 22 : 6, height:6, borderRadius:99,
                background: idx === i ? 'var(--ink)' : 'rgba(15,15,26,.18)',
                transition: 'width .25s, background .25s',
              }}/>
            ))}
          </div>
          <div className="mono" style={{fontSize:11, color:'var(--ink-3)', fontWeight:600}}>{i+1}/{ONBOARDING.length}</div>
        </div>

        <button onClick={() => isLast ? onFinish() : setI(i+1)} className="tap" style={{
          width:'100%', border:'none', background: slide.accent, color:'#fff',
          padding:'16px 18px', borderRadius:18, fontWeight:800, fontSize:16,
          fontFamily:'Manrope, sans-serif',
          display:'inline-flex', alignItems:'center', justifyContent:'center', gap:8,
          cursor:'pointer',
          boxShadow:'0 14px 30px -10px rgba(31,182,240,.45)',
        }}>
          {isLast ? 'Get started' : 'Next'} <Icon name="arrow" size={18} color="#fff" stroke={2.2}/>
        </button>
      </div>
    </div>
  );
}

function OnboardIllustration({ kind, accent }) {
  // Stylized SVG/mockup vignettes — no photo realism, just bold geometric.
  if (kind === 'plan') {
    return (
      <div style={{
        position:'relative', height:300, display:'flex', alignItems:'center', justifyContent:'center',
      }}>
        {/* Floating mascot */}
        <div style={{position:'absolute', top:0, left:'52%'}}>
          <TakoMascot size={84} mood="focused"/>
        </div>
        {/* "Big goal" card */}
        <div style={{
          position:'absolute', left:0, top:60, padding:'10px 14px',
          background:'#fff', border:'1px solid var(--line)', borderRadius:14,
          boxShadow:'0 18px 40px -14px rgba(20,80,120,.25)',
          transform:'rotate(-3deg)',
        }}>
          <div style={{fontSize:10, fontWeight:800, color:'var(--primary)', letterSpacing:0.5, textTransform:'uppercase'}}>Goal</div>
          <div style={{fontWeight:700, fontSize:13, marginTop:2}}>Prep CS-201 midterm</div>
        </div>
        {/* Arrow + sparkles */}
        <div style={{position:'absolute', left:'42%', top:130, color:'var(--primary)', fontSize:24}}>✨</div>
        {/* Generated tasks stack */}
        <div style={{position:'absolute', right:0, bottom:0, display:'flex', flexDirection:'column', gap:6, transform:'rotate(3deg)'}}>
          {['Re-read ch. 5','Solve 10 problems','Build cheat sheet'].map((t, i) => (
            <div key={t} style={{
              background:'#fff', border:'1px solid var(--line)', borderRadius:12,
              padding:'8px 12px', fontSize:11.5, fontWeight:600, color:'var(--ink-2)',
              boxShadow:'0 8px 20px -10px rgba(20,80,120,.2)',
              display:'flex', alignItems:'center', gap:6, minWidth:170,
            }}>
              <div style={{
                width:18, height:18, borderRadius:6,
                background: i===0 ? 'linear-gradient(135deg,#42D391,#10B981)' : '#fff',
                border: i===0 ? 'none' : '1.5px solid var(--line-2)',
                display:'grid', placeItems:'center', flexShrink:0,
              }}>{i===0 && <Icon name="check" size={11} color="#fff" stroke={3}/>}</div>
              {t}
            </div>
          ))}
        </div>
      </div>
    );
  }
  if (kind === 'streak') {
    return (
      <div style={{position:'relative', height:300, display:'flex', alignItems:'center', justifyContent:'center'}}>
        {/* Big flame */}
        <div style={{position:'relative'}}>
          <svg viewBox="0 0 100 130" width="160" height="200">
            <defs>
              <linearGradient id="bigflame" x1="0" x2="0" y1="0" y2="1">
                <stop offset="0%" stopColor="#FFD7BC"/>
                <stop offset="40%" stopColor="#FFC062"/>
                <stop offset="80%" stopColor="#FF8A65"/>
                <stop offset="100%" stopColor="#F26B47"/>
              </linearGradient>
            </defs>
            <path d="M50 4 C 60 28 86 38 86 70 a 36 36 0 1 1 -72 0 c 0 -18 12 -28 18 -42 c 4 10 12 14 22 10 c -6 -12 -2 -22 -4 -34 Z"
                  fill="url(#bigflame)"/>
            <path d="M50 60 c 8 8 14 14 14 24 a 14 14 0 1 1 -28 0 c 0 -10 6 -14 14 -24 Z" fill="#FFF1C9"/>
          </svg>
          <div style={{
            position:'absolute', inset:0, display:'grid', placeItems:'center',
            fontFamily:'Fraunces, serif', fontWeight:800, fontSize:48, color:'#fff',
            textShadow:'0 4px 12px rgba(192,80,40,.55)',
            paddingTop:30,
          }}>5</div>
        </div>
        {/* Days strip */}
        <div style={{position:'absolute', bottom:0, left:0, right:0, display:'flex', justifyContent:'center', gap:8}}>
          {['M','T','W','T','F'].map((d,i) => (
            <div key={d+i} style={{
              width:38, padding:'6px 0', borderRadius:12,
              background: i < 5 ? 'linear-gradient(180deg,#FFC062,#F26B47)' : '#fff',
              color: i < 5 ? '#fff' : 'var(--ink-3)',
              border: i < 5 ? 'none' : '1px solid var(--line)',
              textAlign:'center', fontWeight:700, fontSize:12,
              boxShadow: i < 5 ? '0 6px 14px -6px rgba(242,107,71,.5)' : 'none',
            }}>{d}</div>
          ))}
        </div>
        {/* Badge in corner */}
        <div style={{position:'absolute', top:0, right:0, animation:'float 3s ease-in-out infinite'}}>
          <BadgeIcon kind="streak5" size={68} unlocked/>
        </div>
      </div>
    );
  }
  // social
  return (
    <div style={{position:'relative', height:300, display:'flex', alignItems:'center', justifyContent:'center'}}>
      {/* Phone showing leaderboard */}
      <div style={{
        background:'#fff', border:'1px solid var(--line)', borderRadius:18,
        padding:14, width:200,
        boxShadow:'0 18px 40px -14px rgba(20,80,120,.25)',
      }}>
        <div style={{fontSize:10, fontWeight:800, color:'var(--ink-3)', letterSpacing:0.6, textTransform:'uppercase', marginBottom:8}}>Squad leaderboard</div>
        {[
          {n:'Zara', p:2480, c:'#F5C544', me:false},
          {n:'You',  p:1240, c:'#FF8A65', me:true},
          {n:'Omar', p:1920, c:'#5BCBF5', me:false},
        ].map((r,i) => (
          <div key={i} style={{
            display:'flex', alignItems:'center', gap:8, padding:'6px 8px', borderRadius:10,
            background: r.me ? 'linear-gradient(90deg,#DDF3FE,#fff)' : 'transparent',
            border: r.me ? '1px solid #A8DDF5' : '1px solid transparent',
            marginBottom: 4,
          }}>
            <div className="mono" style={{width:14, fontSize:11, fontWeight:800, color:'var(--ink-3)'}}>{i+1}</div>
            <div style={{
              width:22, height:22, borderRadius:99,
              background: `linear-gradient(135deg, #fff, ${r.c})`,
              display:'grid', placeItems:'center', fontWeight:800, fontSize:10, color:'#fff',
            }}>{r.n[0]}</div>
            <div style={{flex:1, fontSize:11.5, fontWeight: r.me ? 800 : 600}}>{r.n}</div>
            <div className="mono" style={{fontSize:11, fontWeight:700}}>{r.p}</div>
          </div>
        ))}
      </div>
      {/* Floating badge share */}
      <div style={{
        position:'absolute', top:30, right:0, transform:'rotate(8deg)',
        background:'linear-gradient(135deg,#1FB6F0,#FF8A65)', borderRadius:18,
        padding:10, color:'#fff', boxShadow:'0 18px 40px -14px rgba(31,182,240,.45)',
        width:120,
      }}>
        <BadgeIcon kind="streak5" size={42} unlocked/>
        <div style={{fontSize:10, fontWeight:700, marginTop:6, opacity:.9, letterSpacing:0.4, textTransform:'uppercase'}}>Just unlocked</div>
        <div style={{fontFamily:'Fraunces, serif', fontWeight:700, fontSize:14, lineHeight:1.1}}>5-day streak</div>
      </div>
      {/* Heart particle */}
      <div style={{position:'absolute', left:8, top:48, fontSize:18, animation:'spark 2s ease-in-out infinite'}}>💜</div>
      <div style={{position:'absolute', left:30, bottom:90, fontSize:14, animation:'spark 2.5s .3s ease-in-out infinite'}}>✨</div>
    </div>
  );
}

// =====================================================
// SIGN UP
// =====================================================
function SignUpScreen({ onSignUp, onGoLogin }) {
  const [name, setName] = React.useState('');
  const [email, setEmail] = React.useState('');
  const [pw, setPw] = React.useState('');
  const [agree, setAgree] = React.useState(false);
  const [touched, setTouched] = React.useState({});

  const emailOk = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  const pwOk = pw.length >= 6;
  const nameOk = name.trim().length >= 2;
  const formOk = emailOk && pwOk && nameOk && agree;

  const pwStrength = !pw ? 0 : pw.length < 6 ? 1 : pw.length < 10 ? 2 : 3;
  const strengthColors = ['transparent','#F26B47','#F5C544','#10B981'];
  const strengthLabel = ['','Weak','Okay','Strong'];

  return (
    <div className="phone-scroll" style={{
      position:'absolute', inset:0, overflowY:'auto', paddingTop:48,
      background:'linear-gradient(180deg, #DDF3FE 0%, #fff 35%)',
    }}>
      <div style={{padding:'16px 22px 8px', display:'flex', alignItems:'center', justifyContent:'space-between'}}>
        <TaskkoLogo size={18}/>
      </div>

      <div style={{padding:'18px 24px 30px'}}>
        <div style={{display:'flex', alignItems:'center', gap:12, marginBottom:14}}>
          <TaskkoAppLogo size={56} animate={false}/>
          <div>
            <div style={{fontFamily:'Fraunces, serif', fontWeight:700, fontSize:24, letterSpacing:-0.4, lineHeight:1.1}}>
              Create your account
            </div>
            <div style={{fontSize:13, color:'var(--ink-3)', marginTop:2}}>
              Set up your AI study buddy in 30 seconds.
            </div>
          </div>
        </div>

        {/* Social buttons */}
        <div style={{display:'flex', flexDirection:'column', gap:8, marginBottom:14}}>
          <SocialButton provider="google"/>
          <SocialButton provider="apple"/>
        </div>

        <div style={{display:'flex', alignItems:'center', gap:10, color:'var(--ink-4)', fontSize:11, fontWeight:600, margin:'6px 0 12px'}}>
          <div style={{flex:1, height:1, background:'var(--line)'}}/> OR SIGN UP WITH EMAIL <div style={{flex:1, height:1, background:'var(--line)'}}/>
        </div>

        <Field label="Name" value={name} onChange={setName}
          placeholder="Sara Khan" valid={!touched.name || nameOk}
          onBlur={() => setTouched(s => ({...s, name:true}))}
          error={touched.name && !nameOk && 'At least 2 characters'}/>

        <Field label="Email" type="email" value={email} onChange={setEmail}
          placeholder="sara@uni.edu" valid={!touched.email || emailOk}
          onBlur={() => setTouched(s => ({...s, email:true}))}
          error={touched.email && !emailOk && 'Enter a valid email'}/>

        <Field label="Password" type="password" value={pw} onChange={setPw}
          placeholder="At least 6 characters" valid={!touched.pw || pwOk}
          onBlur={() => setTouched(s => ({...s, pw:true}))}
          error={touched.pw && !pwOk && 'Use 6+ characters'}>
          {pw && (
            <div style={{display:'flex', alignItems:'center', gap:8, marginTop:6}}>
              <div style={{flex:1, height:5, borderRadius:99, background:'var(--line)', overflow:'hidden', display:'flex', gap:3, padding:0}}>
                {[1,2,3].map(lvl => (
                  <div key={lvl} style={{
                    flex:1, height:'100%', borderRadius:99,
                    background: pwStrength >= lvl ? strengthColors[pwStrength] : 'transparent',
                    transition:'background .2s',
                  }}/>
                ))}
              </div>
              <div style={{fontSize:11, fontWeight:700, color: strengthColors[pwStrength], minWidth:50}}>{strengthLabel[pwStrength]}</div>
            </div>
          )}
        </Field>

        {/* Agree */}
        <label style={{display:'flex', alignItems:'flex-start', gap:8, marginTop:14, cursor:'pointer'}}>
          <div onClick={() => setAgree(!agree)} className="tap" style={{
            width:22, height:22, borderRadius:7, flexShrink:0, marginTop:1,
            border: agree ? 'none' : '2px solid var(--line-2)',
            background: agree ? 'linear-gradient(135deg,#5BCBF5,#1FB6F0)' : '#fff',
            display:'grid', placeItems:'center', cursor:'pointer',
          }}>{agree && <Icon name="check" size={14} color="#fff" stroke={3}/>}</div>
          <div style={{fontSize:12, color:'var(--ink-3)', lineHeight:1.5}}>
            I agree to Taskko's <span style={{color:'var(--primary)', fontWeight:600}}>Terms</span> and <span style={{color:'var(--primary)', fontWeight:600}}>Privacy Policy</span>.
          </div>
        </label>

        <div style={{marginTop:18}}>
          <PrimaryCTA disabled={!formOk} onClick={() => onSignUp(name.trim())}>
            Create account
          </PrimaryCTA>
        </div>

        <div style={{textAlign:'center', marginTop:14, fontSize:13, color:'var(--ink-3)'}}>
          Already on Taskko? <button onClick={onGoLogin} style={{
            border:'none', background:'transparent', color:'var(--primary)', fontWeight:700, cursor:'pointer', padding:0, fontSize:13,
          }}>Log in</button>
        </div>
      </div>
    </div>
  );
}

// =====================================================
// LOGIN
// =====================================================
function LoginScreen({ onLogin, onGoSignup }) {
  const [email, setEmail] = React.useState('sara@uni.edu');
  const [pw, setPw] = React.useState('');
  const [touched, setTouched] = React.useState({});
  const emailOk = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
  const pwOk = pw.length >= 1;
  const formOk = emailOk && pwOk;
  const isAdmin = email.trim().toLowerCase() === 'admin@taskko.app';

  return (
    <div className="phone-scroll" style={{
      position:'absolute', inset:0, overflowY:'auto', paddingTop:48,
      background:'linear-gradient(180deg, #DDF3FE 0%, #fff 35%)',
    }}>
      <div style={{padding:'16px 22px'}}>
        <TaskkoLogo size={18}/>
      </div>

      <div style={{padding:'22px 24px 30px'}}>
        <div style={{display:'flex', flexDirection:'column', alignItems:'center', marginBottom:20}}>
          <TaskkoAppLogo size={84}/>
          <div style={{fontFamily:'Fraunces, serif', fontWeight:700, fontSize:26, letterSpacing:-0.5, marginTop:14, textAlign:'center'}}>
            Welcome back
          </div>
          <div style={{fontSize:13.5, color:'var(--ink-3)', marginTop:4, textAlign:'center'}}>
            Your streak's waiting.
          </div>
          {isAdmin && (
            <div style={{
              marginTop:10, display:'inline-flex', alignItems:'center', gap:6,
              background:'#0F1B26', color:'#5BCBF5',
              padding:'5px 11px', borderRadius:99,
              fontSize:11, fontWeight:800, letterSpacing:0.4, textTransform:'uppercase',
            }}>
              <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="M12 2l8 4v6c0 5-3.5 9-8 10-4.5-1-8-5-8-10V6z"/><path d="M9 12l2 2 4-4"/></svg>
              Admin access detected
            </div>
          )}
        </div>

        <div style={{display:'flex', flexDirection:'column', gap:8, marginBottom:14}}>
          <SocialButton provider="google"/>
          <SocialButton provider="apple"/>
        </div>

        <div style={{display:'flex', alignItems:'center', gap:10, color:'var(--ink-4)', fontSize:11, fontWeight:600, margin:'6px 0 12px'}}>
          <div style={{flex:1, height:1, background:'var(--line)'}}/> OR <div style={{flex:1, height:1, background:'var(--line)'}}/>
        </div>

        <Field label="Email" type="email" value={email} onChange={setEmail}
          placeholder="sara@uni.edu" valid={!touched.email || emailOk}
          onBlur={() => setTouched(s => ({...s, email:true}))}
          error={touched.email && !emailOk && 'Enter a valid email'}/>

        <Field label="Password" type="password" value={pw} onChange={setPw}
          placeholder="Your password" valid={!touched.pw || pwOk}
          onBlur={() => setTouched(s => ({...s, pw:true}))}
          rightSlot={
            <button style={{
              border:'none', background:'transparent', color:'var(--primary)',
              fontSize:11.5, fontWeight:700, cursor:'pointer', padding:0,
            }}>Forgot?</button>
          }/>

        <div style={{marginTop:18}}>
          <PrimaryCTA disabled={!formOk} onClick={() => onLogin(email)}>
            Log in{isAdmin ? ' to Admin' : ''}
          </PrimaryCTA>
        </div>

        {/* Demo: try as admin */}
        <button onClick={() => { setEmail('admin@taskko.app'); setPw('admin'); }} style={{
          marginTop:10, width:'100%', border:'1px dashed #DCDCE7', background:'transparent',
          color:'var(--ink-3)', padding:'10px 12px', borderRadius:12,
          fontSize:12, fontWeight:700, cursor:'pointer',
          display:'inline-flex', alignItems:'center', justifyContent:'center', gap:6,
        }}>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M12 2l8 4v6c0 5-3.5 9-8 10-4.5-1-8-5-8-10V6z"/></svg>
          Try as admin (demo)
        </button>

        <div style={{textAlign:'center', marginTop:14, fontSize:13, color:'var(--ink-3)'}}>
          New here? <button onClick={onGoSignup} style={{
            border:'none', background:'transparent', color:'var(--primary)', fontWeight:700, cursor:'pointer', padding:0, fontSize:13,
          }}>Create account</button>
        </div>
      </div>
    </div>
  );
}

// ----- Shared form Field -----
function Field({ label, value, onChange, type='text', placeholder, valid=true, error, onBlur, children, rightSlot }) {
  const [show, setShow] = React.useState(false);
  const realType = type==='password' && show ? 'text' : type;
  return (
    <div style={{marginTop:12}}>
      <div style={{display:'flex', alignItems:'center', justifyContent:'space-between', marginBottom:6}}>
        <label style={{fontSize:12, fontWeight:700, color:'var(--ink-2)', letterSpacing:0.2}}>{label}</label>
        {rightSlot}
      </div>
      <div style={{
        background:'#fff',
        border: error ? '1.5px solid #F26B47' : (valid ? '1.5px solid var(--line-2)' : '1.5px solid var(--line-2)'),
        borderRadius:14, padding:'0 12px',
        display:'flex', alignItems:'center', gap:8,
        boxShadow:'0 1px 0 rgba(15,15,26,.02)',
      }}>
        <input
          type={realType} value={value}
          onChange={e => onChange(e.target.value)}
          onBlur={onBlur}
          placeholder={placeholder}
          style={{
            flex:1, border:'none', outline:'none', padding:'13px 0',
            fontFamily:'Manrope, sans-serif', fontSize:14, fontWeight:500,
            color:'var(--ink)', background:'transparent',
          }}
        />
        {type==='password' && value && (
          <button onClick={()=>setShow(s=>!s)} style={{
            border:'none', background:'transparent', cursor:'pointer', padding:4, color:'var(--ink-3)',
            fontSize:11, fontWeight:700,
          }}>{show ? 'Hide' : 'Show'}</button>
        )}
      </div>
      {children}
      {error && <div style={{fontSize:11.5, color:'#E25C3D', marginTop:4, fontWeight:600, display:'flex', alignItems:'center', gap:4}}>
        <span style={{display:'inline-block', width:14, height:14, borderRadius:99, background:'#FFE6DD', color:'#E25C3D', textAlign:'center', lineHeight:'14px', fontSize:10}}>!</span>
        {error}
      </div>}
    </div>
  );
}

function SocialButton({ provider }) {
  if (provider === 'google') {
    return (
      <button className="tap" style={{
        width:'100%', border:'1.5px solid var(--line-2)', background:'#fff',
        padding:'13px 14px', borderRadius:14, cursor:'pointer',
        display:'inline-flex', alignItems:'center', justifyContent:'center', gap:10,
        fontWeight:700, fontSize:14, color:'var(--ink)',
      }}>
        <svg width="18" height="18" viewBox="0 0 48 48">
          <path fill="#FFC107" d="M43.6 20.5H42V20.4H24v7.2h11.3c-1.5 4.2-5.5 7.2-10.3 7.2-6 0-10.9-4.9-10.9-10.8S19 13.2 25 13.2c2.7 0 5.2 1 7.1 2.7l5.1-5.1C34 7.8 29.8 6 25 6 14.5 6 6 14.5 6 25s8.5 19 19 19 19-8.5 19-19c0-1.5-.2-3-.4-4.5z"/>
          <path fill="#FF3D00" d="M8.3 14.7l5.9 4.3c1.6-4.1 5.6-7 10.3-7 2.7 0 5.2 1 7.1 2.7l5.1-5.1C34 7.8 29.8 6 25 6 17.4 6 10.8 10.5 8.3 14.7z"/>
          <path fill="#4CAF50" d="M25 44c4.8 0 9-1.8 12.2-4.7l-5.6-4.7c-1.7 1.3-4 2.1-6.6 2.1-4.8 0-8.9-3-10.3-7.2L8.6 33.2C11 38.6 17.5 44 25 44z"/>
          <path fill="#1976D2" d="M43.6 20.5H42V20.4H24v7.2h11.3c-.7 2-2 3.7-3.7 5l5.6 4.7c-.4.4 6.2-4.5 6.2-12.4 0-1.5-.2-3-.4-4.4z"/>
        </svg>
        Continue with Google
      </button>
    );
  }
  return (
    <button className="tap" style={{
      width:'100%', border:'none', background:'#0F0F1A', color:'#fff',
      padding:'13px 14px', borderRadius:14, cursor:'pointer',
      display:'inline-flex', alignItems:'center', justifyContent:'center', gap:10,
      fontWeight:700, fontSize:14,
    }}>
      <svg width="16" height="18" viewBox="0 0 16 18" fill="#fff">
        <path d="M11.5 9.4c0-2 1.7-3 1.8-3-1-1.4-2.5-1.6-3-1.6-1.3-.1-2.5.8-3.1.8-.7 0-1.6-.8-2.7-.7-1.4 0-2.7.8-3.4 2.1-1.4 2.6-.4 6.4 1 8.5.7 1 1.5 2.1 2.6 2.1 1 0 1.4-.7 2.7-.7 1.2 0 1.6.7 2.7.6 1.1 0 1.8-1 2.5-2 .5-.7 1-1.6 1.2-2.5-2.5-.9-2.3-3.3-2.3-3.6zM9.4 3.2c.6-.7 1-1.7.8-2.7-.9 0-2 .6-2.6 1.3-.5.6-1 1.6-.9 2.5 1 0 2-.5 2.7-1.1z"/>
      </svg>
      Continue with Apple
    </button>
  );
}

Object.assign(window, {
  TaskkoAppLogo, SplashScreen, OnboardingScreen, SignUpScreen, LoginScreen,
});
