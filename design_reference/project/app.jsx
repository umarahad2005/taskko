// Taskko — main app
// =====================================================

const INITIAL_TASKS = [
  { id:'t1', title:'Read CS-201 lecture 7 notes', minutes:30, points:40, goal:'CS-201 midterm', done:true },
  { id:'t2', title:'Practice 5 BST problems',     minutes:45, points:60, goal:'CS-201 midterm', done:true },
  { id:'t3', title:'Draft sociology essay intro', minutes:25, points:30, goal:'Essay due Friday', done:false },
  { id:'t4', title:'Review flashcards: Stats',    minutes:20, points:25, goal:'Stats quiz Mon',  done:false },
  { id:'t5', title:'Email TA about extension',    minutes: 5, points:10, goal:'Admin',           done:false },
];

const SAMPLE_PLAN_TEMPLATES = {
  'Prep for CS-201 midterm by Friday': [
    { id:'p1', title:'Re-read chapters 5 & 6',          minutes:45, points:60 },
    { id:'p2', title:'Solve 10 graph traversal problems',minutes:60, points:80 },
    { id:'p3', title:'Watch recitation recordings',     minutes:40, points:45 },
    { id:'p4', title:'Build dynamic programming cheat sheet', minutes:35, points:50 },
    { id:'p5', title:'Take a timed mock exam',          minutes:90, points:120 },
    { id:'p6', title:'Review missed mock questions',    minutes:30, points:40 },
  ],
  'default': [
    { id:'p1', title:'Outline the work',            minutes:15, points:20 },
    { id:'p2', title:'Tackle the first sub-piece',  minutes:45, points:60 },
    { id:'p3', title:'Mid-progress checkpoint',     minutes:10, points:15 },
    { id:'p4', title:'Push through hardest part',   minutes:60, points:80 },
    { id:'p5', title:'Polish & wrap up',            minutes:30, points:40 },
  ],
};

const INITIAL_CHAT = [
  { from:'tako', text:"Hey! I noticed your CS reading is overdue by a day. No drama — want me to slot it into tonight, or push it to tomorrow?" },
  { from:'tako', kind:'nudge', text:"Your 5-day streak is alive 🔥 One 25-minute task tonight keeps it going.", actions:['Start a session','Remind me in 1h'] },
  { from:'me', text:"I'm stuck on the practice problems, can't focus" },
  { from:'tako', text:"Totally fair. Let's shrink the next task — pick the smallest piece you can finish in 10 minutes and I'll start a focus timer. Often momentum > motivation." },
];

function initialState() {
  return {
    user: { name: 'Sara', initials: 'S' },
    streak: { days: 5, shields: 2 },
    points: 1240,
    rank: 'Pro',
    mood: 'focused',
    todayTasks: INITIAL_TASKS,
    nextTask: { title:'Draft sociology essay intro', minutes:25, points:30, goal:'Essay due Friday' },
    // Plan studio
    goalDraft: '',
    planStep: 'input', // input | generating | review
    planTasks: [],
    // Chat
    chatMessages: INITIAL_CHAT,
  };
}

function reducer(s, a) {
  switch (a.type) {
    case 'mood': return { ...s, mood: a.value };
    case 'toggle': {
      const todayTasks = s.todayTasks.map(t => t.id===a.id ? {...t, done: !t.done} : t);
      // Award points when marking done
      const flipped = s.todayTasks.find(t => t.id===a.id);
      const delta = flipped && !flipped.done ? flipped.points : (flipped && flipped.done ? -flipped.points : 0);
      // Next task = first undone
      const nextUndone = todayTasks.find(t => !t.done);
      return {
        ...s, todayTasks,
        points: Math.max(0, s.points + delta),
        nextTask: nextUndone ? { title: nextUndone.title, minutes: nextUndone.minutes, points: nextUndone.points, goal: nextUndone.goal } : s.nextTask,
      };
    }
    case 'goalDraft': return { ...s, goalDraft: a.value };
    case 'startPlan': {
      return { ...s, planStep: 'generating' };
    }
    case 'planReady': {
      const tpl = SAMPLE_PLAN_TEMPLATES[s.goalDraft] || SAMPLE_PLAN_TEMPLATES['default'];
      return { ...s, planStep: 'review', planTasks: tpl.map(t => ({...t, id: t.id + Math.random().toString(36).slice(2,5)})) };
    }
    case 'editPlan': return { ...s, planTasks: s.planTasks.map(t => t.id===a.id ? {...t, [a.field]: a.value} : t) };
    case 'delPlan':  return { ...s, planTasks: s.planTasks.filter(t => t.id !== a.id) };
    case 'addPlan':  return { ...s, planTasks: [...s.planTasks, { id:'np'+Math.random().toString(36).slice(2,6), title:'New task', minutes:25, points:30 }] };
    case 'regen':    return { ...s, planStep: 'generating' };
    case 'resetPlan':return { ...s, planStep: 'input', planTasks: [], goalDraft: '' };
    case 'commitPlan': {
      const newTasks = s.planTasks.map(t => ({
        id:'tn'+t.id, title:t.title, minutes:t.minutes, points:t.points,
        goal: s.goalDraft || 'New goal', done:false
      }));
      return { ...s, todayTasks: [...s.todayTasks, ...newTasks], planStep:'input', planTasks:[], goalDraft:'' };
    }
    case 'chatSend': return { ...s, chatMessages: [...s.chatMessages, { from:'me', text:a.text }] };
    case 'chatReply':return { ...s, chatMessages: [...s.chatMessages, { from:'tako', text:a.text }] };
    default: return s;
  }
}

// HCI Rationale panel (slide-out)
function HCIPanel({ tab, open, setOpen }) {
  const content = {
    splash: {
      title: 'Splash screen',
      summary: 'First impression. Builds brand recognition before any UI work begins, while async data loads behind it.',
      points: [
        ['Recognition over recall', 'The Taskko mark uses a checkmark inside a squircle — the verb (“mark done”) is encoded in the logo itself, so the brand is also a usage hint.'],
        ['Color & emotion', 'Cool indigo gradient communicates calm focus. A warm peach spark on top signals energy + reward — the two product pillars in one mark.'],
        ['Feedback', 'Animated shimmer + “loading…” label tell the user the system is alive. No silent waits (Nielsen #1).'],
        ['Constraints', 'No tappable controls during splash — prevents users from acting before the app is ready. Auto-advances after 2.4s.'],
        ['Gestalt (Closure)', 'Logo + wordmark + tagline sit as one centred composition; the eye perceives a unified brand block.'],
      ],
    },
    onboarding: {
      title: 'Onboarding tour',
      summary: 'Three-slide value-prop walkthrough. Optional, skippable, and never blocking real use.',
      points: [
        ['Affordance', 'Bottom “Next” button is the brightest element on the screen — the primary path is obvious. “Skip” sits top-right in muted text — secondary but always reachable.'],
        ['Constraints (escape hatch)', 'Skip is on every slide; users are never trapped. Jakob Nielsen heuristic #3 (user control & freedom).'],
        ['Feedback', 'Active dot widens into a pill. Slide content cross-fades. Each accent colour shifts with the slide content — visible progress.'],
        ['Mapping', 'Three pillars (Plan → Streaks → Squad) map 1:1 to the three main product surfaces students will see next.'],
        ['Chunking', 'One idea per slide. Reduces cognitive load (Miller’s law); each illustration is a single concrete vignette, not a wall of text.'],
        ['Recognition', 'Slides preview real UI bits (task cards, leaderboard, badge) so users will recognise them when they arrive.'],
      ],
    },
    signup: {
      title: 'Sign up',
      summary: 'Minimum viable form. Three fields, two social options. Validation is friendly, not punishing.',
      points: [
        ['Constraints', 'Real-time validation prevents bad emails and short passwords — errors caught before submit (Norman, error prevention).'],
        ['Feedback', 'Password strength bar fills as the user types. Each field validates on blur with a specific message, not generic “invalid”.'],
        ['Visibility', 'Show/Hide toggle on the password field. Lets users verify input — a known anti-frustration pattern.'],
        ['Affordance', 'Social buttons sit above the divider because they’re faster. Primary CTA stays disabled (visibly grey) until form is valid — it looks unclickable because it is.'],
        ['Gulf of Execution', 'One clear path forward. Name + email + password + agree → done. No optional fields to dither over.'],
        ['Mapping', '“Already on Taskko? Log in” sits at the bottom — where users naturally look after scanning the form. Two paths, one screen.'],
        ['Trust', 'Terms/Privacy linked at point of agreement, not buried.'],
      ],
    },
    login: {
      title: 'Log in',
      summary: 'Returning-user path. Faster than sign up, with a warm welcome.',
      points: [
        ['Recognition', 'Big app logo at top — returning users see brand instantly, reinforcing they’re in the right place.'],
        ['Affordance', 'Email is pre-filled with last-used in demo. Social-login buttons surface the fastest path.'],
        ['Feedback', '“Forgot?” link sits right of the field it relates to — in-context help, not buried in a menu (proximity).'],
        ['Constraints', 'CTA disabled until both fields look valid — no submit-and-shame.'],
        ['Emotion', '“Your streak’s waiting” copy primes the user with the variable-reward they’ll see next. Behavioural design for re-engagement.'],
      ],
    },
    home: {
      title: 'Home / Dashboard',
      summary: 'Pull-of-the-day surface. Reduces cognitive load by surfacing exactly one obvious next action.',
      points: [
        ['Visibility', 'Streak, rank, mood, next task are all visible above the fold — no menus needed.'],
        ['Mapping', 'Mood emoji directly drives the next session\'s length/break ratio — input maps to output.'],
        ['Feedback', 'Tapping a checkbox animates to filled-green and the points counter updates instantly.'],
        ['Gulf of Execution', 'The "Next up" hero card states a verb + a concrete task — students never wonder what to start.'],
        ['Gulf of Evaluation', 'Streak progress bar (5/5) + rank progress (68% to Elite) make state instantly readable.'],
        ['Gestalt (Proximity)', 'Today\'s tasks share identical card shape & spacing — perceived as one set.'],
        ['Visual Hierarchy', 'CTA card uses the most saturated colour + largest type. Stats use medium contrast. Tasks use neutral.'],
        ['Color & Burnout', 'Warm peach for streaks signals energy; cool indigo for ranks signals calm focus. Background stays low-saturation lavender to reduce visual fatigue.'],
      ],
    },
    plan: {
      title: 'AI Task Breakdown',
      summary: 'Bridges the Gulf of Execution for the user\'s hardest problem: "where do I even start?"',
      points: [
        ['Affordance', 'The text box looks like a text box. The "Break it down" button looks pressable (gradient + lift shadow). Chips look tappable.'],
        ['Constraints', 'Sample-goal chips prevent garbage input — they constrain the AI\'s input space without restricting freedom.'],
        ['Feedback', '4-step progress indicator during generation. Each completed parsing step lights up — system state is never opaque.'],
        ['Mapping', 'Step indicator at top matches the user\'s actual progress through the flow (Goal → Break down → Customize).'],
        ['Closure (Gestalt)', 'Numbered, identically-shaped task cards form a clear "list" gestalt. Total time/points footer closes the loop.'],
        ['Control', 'Generated tasks are editable, deletable, regenerable. AI suggests; user decides.'],
        ['Reading the system', 'Cumulative time + points footer answers "is this realistic?" at a glance.'],
      ],
    },
    hub: {
      title: 'Gamification & Social Hub',
      summary: 'Balances dopamine (badges, leaderboard) with reflection (report card). One tap = social sharing.',
      points: [
        ['Visibility', 'New badge surfaces at the top of Badges tab with a "Share" affordance — celebration is immediate.'],
        ['Similarity (Gestalt)', 'All badges share octagonal medal shape; only color/saturation differentiates earned vs locked.'],
        ['Hierarchy on Leaderboard', '"You" row uses primary accent + bolder weight — findable in ≤1 second. Podium uses size, not just numbers.'],
        ['Closure', 'Weekly report card summarizes the week into 4 stats + a sparkline — a complete unit, ready to share.'],
        ['Mapping', 'Share button on report card produces an actual share preview, not a hidden export — what you see is what posts.'],
        ['Avoiding overwhelm', 'Gamification is tab-scoped — never bleeds into the productivity surfaces. Students can opt in to "fun".'],
        ['Social accountability', 'Squad leaderboard surfaces peers, not strangers — accountability without comparison anxiety.'],
      ],
    },
    chat: {
      title: 'AI Chatbot (Tako)',
      summary: 'Conversational interface for emotional support and re-planning. Designed to feel like a friend, not a tool.',
      points: [
        ['Proximity (Gestalt)', 'Messages from the same speaker are spatially grouped; avatar only appears at the start of a block.'],
        ['Continuity', 'Bubbles flow top-to-bottom in time order; new messages animate in, anchoring the eye.'],
        ['Color coding', 'User messages = primary indigo. Tako = white with subtle border. Instantly readable as a dialogue.'],
        ['Affordance', 'Quick-prompt chips above the input remove the cold-start problem ("what do I say?").'],
        ['Feedback', 'Typing indicator with bouncing dots tells the user Tako is working — no silent waits.'],
        ['Nudge cards', 'High-priority messages render as distinct gradient cards with action buttons — separates info from action.'],
        ['Mapping to mood', 'Tako\'s avatar mood matches the user\'s current mood selection — visible empathy.'],
        ['Constraints', 'Mic + text input only — no overwhelming attachment/format menu. Single-purpose interface.'],
      ],
    },
  }[tab] || content.home;

  if (!open) {
    return (
      <button onClick={() => setOpen(true)} style={{
        position:'fixed', right:24, top:24, zIndex:50,
        border:'none', borderRadius:99,
        background:'linear-gradient(135deg,#FF9B7A,#FF7A5C)',
        color:'#fff', padding:'10px 16px',
        fontWeight:700, fontSize:13, cursor:'pointer',
        boxShadow:'0 12px 28px -10px rgba(242,107,71,.55)',
        display:'inline-flex', alignItems:'center', gap:8,
      }}>
        <Icon name="info" size={16} color="#fff"/> HCI rationale
      </button>
    );
  }

  return (
    <div className="fade-in" style={{
      position:'fixed', right:24, top:24, bottom:24, width:380, zIndex:50,
      background:'#fff', borderRadius:24, padding:'20px 22px',
      boxShadow:'0 30px 70px -20px rgba(15,15,26,.3), 0 0 0 1px rgba(15,15,26,.05)',
      overflowY:'auto',
    }}>
      <div style={{display:'flex', justifyContent:'space-between', alignItems:'flex-start', marginBottom:14}}>
        <div>
          <div style={{fontSize:11, fontWeight:700, color:'#FF7A5C', letterSpacing:0.6, textTransform:'uppercase'}}>HCI rationale</div>
          <div style={{fontFamily:'Fraunces, serif', fontWeight:700, fontSize:22, marginTop:2, letterSpacing:-0.3}}>{content.title}</div>
        </div>
        <button onClick={() => setOpen(false)} style={{
          border:'none', background:'#F2F2F7', width:32, height:32, borderRadius:99,
          display:'grid', placeItems:'center', cursor:'pointer',
        }}><Icon name="close" size={16} color="var(--ink-2)"/></button>
      </div>
      <div style={{
        background:'#F7F6FB', borderRadius:14, padding:'12px 14px', marginBottom:14,
        fontSize:13.5, lineHeight:1.55, color:'var(--ink-2)',
      }}>{content.summary}</div>
      <div style={{display:'flex', flexDirection:'column', gap:10}}>
        {content.points.map(([t, b], i) => (
          <div key={i} style={{
            padding:'12px 14px', background:'#fff', border:'1px solid var(--line)',
            borderRadius:14,
          }}>
            <div style={{fontSize:11, fontWeight:800, color:'var(--primary)', letterSpacing:0.4, textTransform:'uppercase', marginBottom:4}}>{t}</div>
            <div style={{fontSize:13, lineHeight:1.5, color:'var(--ink-2)'}}>{b}</div>
          </div>
        ))}
      </div>
      <div style={{
        marginTop:14, padding:'10px 12px', background:'#DDF3FE', borderRadius:12,
        fontSize:11.5, lineHeight:1.5, color:'var(--primary)', fontWeight:600,
      }}>
        Tip: tap the 🔴 numbered pins floating on the phone screen for in-context callouts.
      </div>
    </div>
  );
}

function App() {
  const [state, dispatch] = React.useReducer(reducer, undefined, initialState);
  const [tab, setTab] = React.useState('home');
  const [panelOpen, setPanelOpen] = React.useState(false);
  // Pre-auth phases: splash -> onboarding -> signup/login -> app
  const [phase, setPhase] = React.useState('splash'); // splash | onboarding | signup | login | app
  // Surface: 'phone' (mobile prototype) | 'admin' (desktop admin portal)
  const [surface, setSurface] = React.useState('phone');
  const [adminTab, setAdminTab] = React.useState('dashboard');
  // Admin permission — granted to specific demo account
  const [isAdmin, setIsAdmin] = React.useState(false);
  const initialMount = React.useRef(true);
  React.useEffect(() => { initialMount.current = false; }, []);

  // Expose nav hook for screenshot / pptx capture
  React.useEffect(() => {
    window.__taskkoNav = (target) => {
      initialMount.current = false;
      // target can be a phase name OR 'app:<tab>'
      if (target.startsWith('app:')) {
        setPhase('app');
        setTab(target.slice(4));
      } else {
        setPhase(target);
      }
    };
    return () => { delete window.__taskkoNav; };
  }, []);

  const TWEAK_DEFAULS = /*EDITMODE-BEGIN*/{
    "showAnnotations": false,
    "primaryColor": "#1FB6F0",
    "accentColor": "#FF8A65",
    "userName": "Sara",
    "background": "mint"
  }/*EDITMODE-END*/;

  const [t, setTweak] = window.useTweaks(TWEAK_DEFAULS);

  // Apply primary color
  React.useEffect(() => {
    document.documentElement.style.setProperty('--primary', t.primaryColor);
    document.documentElement.style.setProperty('--energy', t.accentColor);
    // background variants
    const bgs = {
      lavender: 'radial-gradient(1100px 700px at 12% -10%, #DDF3FE 0%, transparent 55%), radial-gradient(900px 600px at 100% 110%, #FFE9DE 0%, transparent 55%), #F4F2FA',
      mint:     'radial-gradient(1100px 700px at 12% -10%, #DDF3E8 0%, transparent 55%), radial-gradient(900px 600px at 100% 110%, #E8E6FA 0%, transparent 55%), #F2F7F4',
      slate:    'radial-gradient(1100px 700px at 12% -10%, #DCE0EB 0%, transparent 55%), radial-gradient(900px 600px at 100% 110%, #F0E6E0 0%, transparent 55%), #EDEEF3',
      cream:    'radial-gradient(1100px 700px at 12% -10%, #FFF1DB 0%, transparent 55%), radial-gradient(900px 600px at 100% 110%, #FFE2E2 0%, transparent 55%), #FBF7F0',
    };
    document.body.style.background = bgs[t.background] || bgs.lavender;
  }, [t.primaryColor, t.accentColor, t.background]);

  // Sync userName into state
  React.useEffect(() => {
    if (t.userName && t.userName !== state.user.name) {
      // soft mutate
      state.user.name = t.userName;
      state.user.initials = (t.userName[0] || 'S').toUpperCase();
    }
  }, [t.userName]);

  // Simulate AI generation delay
  React.useEffect(() => {
    if (state.planStep === 'generating') {
      const id = setTimeout(() => dispatch({type:'planReady'}), 2200);
      return () => clearTimeout(id);
    }
  }, [state.planStep]);

  // Sync panel tab to active screen
  React.useEffect(() => { /* panel content tracks `tab` */ }, [tab]);

  const screens = {
    splash:     <SplashScreen onDone={() => setPhase('onboarding')} autoAdvance={initialMount.current}/>,
    onboarding: <OnboardingScreen onFinish={() => setPhase('signup')} onSkip={() => setPhase('signup')}/>,
    signup:     <SignUpScreen onSignUp={(name) => { if (name) { state.user.name = name; state.user.initials = name[0].toUpperCase(); setTweak('userName', name); } setPhase('app'); }} onGoLogin={() => setPhase('login')}/>,
    login:      <LoginScreen onLogin={(emailFromForm) => {
      const isAdminLogin = (emailFromForm || '').trim().toLowerCase() === 'admin@taskko.app';
      if (isAdminLogin) {
        setIsAdmin(true);
        state.user.name = 'Umar';
        state.user.initials = 'U';
        state.user.email = emailFromForm;
        setPhase('app');
        // Auto-route to admin surface for admin accounts (user opted in)
        setSurface('admin');
      } else {
        setIsAdmin(false);
        setPhase('app');
      }
    }} onGoSignup={() => setPhase('signup')}/>,
    home: <HomeScreen state={state} dispatch={dispatch} annotate={t.showAnnotations} goTo={setTab} isAdmin={isAdmin} onOpenAdmin={() => setSurface('admin')}/>,
    plan: <PlanScreen state={state} dispatch={dispatch} annotate={t.showAnnotations} goTo={setTab}/>,
    hub:  <HubScreen  state={state} dispatch={dispatch} annotate={t.showAnnotations}/>,
    chat: <ChatScreen state={state} dispatch={dispatch} annotate={t.showAnnotations}/>,
  };

  // What to render inside the phone
  const inApp = phase === 'app';
  const phoneContent = inApp ? screens[tab] : screens[phase];
  const inAdmin = inApp && isAdmin && surface === 'admin';

  // ===== ADMIN SURFACE (desktop portal) =====
  if (inAdmin) {
    return (
      <div style={{
        minHeight:'100vh', padding:'24px', display:'flex', flexDirection:'column', gap:14,
      }}>
        {/* Top context bar */}
        <div style={{
          display:'flex', alignItems:'center', justifyContent:'space-between',
          padding:'10px 14px', background:'#fff', border:'1px solid var(--line)',
          borderRadius:14, boxShadow:'0 6px 22px -10px rgba(60,60,120,.12)',
        }}>
          <div style={{display:'flex', alignItems:'center', gap:14}}>
            <TaskkoLogo size={18}/>
            <span style={{fontSize:11, color:'var(--ink-3)', fontWeight:600}}>·</span>
            <span style={{
              fontSize:11, fontWeight:800, color:'#0F1B26', background:'#DDF3FE',
              padding:'4px 10px', borderRadius:99, letterSpacing:0.4, textTransform:'uppercase',
              display:'inline-flex', alignItems:'center', gap:6,
            }}>
              <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="#0E8FC4" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="M12 2l8 4v6c0 5-3.5 9-8 10-4.5-1-8-5-8-10V6z"/><path d="M9 12l2 2 4-4"/></svg>
              Admin Console
            </span>
            <span style={{fontSize:12, color:'var(--ink-3)'}}>Signed in as <b style={{color:'var(--ink-2)'}}>{state.user.name || 'Admin'}</b> · admin@taskko.app</span>
          </div>
          <div style={{display:'flex', gap:8}}>
            <button onClick={() => setSurface('phone')} className="tap" style={{
              border:'1px solid var(--line-2)', background:'#fff',
              padding:'8px 14px', borderRadius:10, fontSize:12.5, fontWeight:700,
              cursor:'pointer', color:'var(--ink-2)',
              display:'inline-flex', alignItems:'center', gap:6,
            }}>
              <Icon name="home" size={14}/> Switch to student app
            </button>
          </div>
        </div>

        {/* Admin desktop window */}
        <div style={{
          flex:1, height:'calc(100vh - 110px)', minHeight:720,
          background:'#fff', borderRadius:18, overflow:'hidden',
          border:'1px solid var(--line)',
          boxShadow:'0 30px 80px -20px rgba(15,15,26,0.18), 0 0 0 1px rgba(15,15,26,0.04)',
        }}>
          <AdminPortal
            tab={adminTab}
            setTab={setAdminTab}
            onExit={() => setSurface('phone')}
            admin={{ name: state.user.name || 'Umar', email: 'admin@taskko.app' }}
          />
        </div>

        {/* Tweaks panel still available */}
        <window.TweaksPanel title="Tweaks">
          <window.TweakSection label="Surface">
            <window.TweakButton label="← Switch to student app" onClick={() => setSurface('phone')}/>
          </window.TweakSection>
        </window.TweaksPanel>
      </div>
    );
  }

  // ===== PHONE SURFACE =====
  return (
    <div style={{
      minHeight:'100vh', padding:'40px 24px', display:'flex',
      alignItems:'center', justifyContent:'center', gap:48,
    }}>
      {/* Left: copy */}
      <div style={{maxWidth:380, flexShrink:0}}>
        <TaskkoLogo size={28}/>
        <div style={{
          fontFamily:'Fraunces, serif', fontWeight:700, fontSize:44, letterSpacing:-1.2,
          lineHeight:1.05, marginTop:18, color:'var(--ink)',
        }}>
          Big goals,<br/>
          <span style={{
            background:'linear-gradient(135deg,#1FB6F0,#FF8A65)',
            WebkitBackgroundClip:'text', WebkitTextFillColor:'transparent',
          }}>bite-sized wins.</span>
        </div>
        <p style={{fontSize:15.5, lineHeight:1.6, color:'var(--ink-3)', marginTop:14}}>
          Taskko is an AI productivity companion built for students. It turns overwhelming goals into a guided plan,
          rewards consistency, and keeps you accountable through your squad — all while reading your mood so it never burns you out.
        </p>

        <div style={{
          marginTop:20, padding:16, background:'#fff', border:'1px solid var(--line)', borderRadius:18,
        }}>
          <div style={{fontSize:11, fontWeight:800, color:'var(--primary)', letterSpacing:0.6, textTransform:'uppercase', marginBottom:8}}>
            High-fidelity prototype · 8 screens
          </div>
          <div style={{display:'flex', flexDirection:'column', gap:6}}>
            {[
              ['splash',     'sparkles', 'Splash',                'phase'],
              ['onboarding', 'flag',     'Onboarding tour',       'phase'],
              ['signup',     'plus',     'Sign up',               'phase'],
              ['login',      'shield',   'Log in',                'phase'],
              ['home',       'home',     'Home / Dashboard',      'tab'],
              ['plan',       'sparkles', 'AI Task Breakdown',     'tab'],
              ['hub',        'trophy',   'Gamification & Social', 'tab'],
              ['chat',       'chat',     'AI Chatbot (Tako)',     'tab'],
            ].map(([k, icon, label, kind]) => {
              const active = kind === 'phase' ? (phase === k) : (inApp && tab === k);
              return (
              <button key={k} onClick={() => { if (kind === 'phase') { initialMount.current = false; setPhase(k); } else { setPhase('app'); setTab(k); } }} className="tap" style={{
                width:'100%', textAlign:'left',
                background: active ? 'linear-gradient(90deg, #DDF3FE, #fff)' : 'transparent',
                border: active ? '1px solid #A8DDF5' : '1px solid transparent',
                padding:'10px 12px', borderRadius:12,
                display:'flex', alignItems:'center', gap:10,
                cursor:'pointer',
              }}>
                <div style={{
                  width:30, height:30, borderRadius:10,
                  background: active ? 'var(--primary)' : 'var(--primary-soft)',
                  color: active ? '#fff' : 'var(--primary)',
                  display:'grid', placeItems:'center',
                }}>
                  <Icon name={icon} size={16} stroke={2}/>
                </div>
                <div style={{flex:1}}>
                  <div style={{fontWeight:700, fontSize:14, color:'var(--ink)'}}>{label}</div>
                </div>
                {active && <div style={{width:6, height:6, borderRadius:99, background:'var(--primary)'}}/>}
              </button>
            )})}
          </div>
        </div>

        {/* Admin portal CTA */}
        {isAdmin ? (
          <button onClick={() => setSurface('admin')} className="tap" style={{
            marginTop:12, width:'100%', textAlign:'left',
            background:'linear-gradient(135deg, #0F1B26, #1B2D3F)',
            color:'#fff', border:'none', padding:'14px 16px', borderRadius:14,
            cursor:'pointer', display:'flex', alignItems:'center', gap:12,
            boxShadow:'0 12px 28px -10px rgba(15,27,38,0.5)',
          }}>
            <div style={{
              width:36, height:36, borderRadius:10,
              background:'linear-gradient(135deg, #5BCBF5, #1FB6F0)',
              display:'grid', placeItems:'center', flexShrink:0,
            }}>
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#fff" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round"><path d="M12 2l8 4v6c0 5-3.5 9-8 10-4.5-1-8-5-8-10V6z"/><path d="M9 12l2 2 4-4"/></svg>
            </div>
            <div style={{flex:1}}>
              <div style={{fontSize:10.5, fontWeight:800, color:'#5BCBF5', letterSpacing:0.6, textTransform:'uppercase'}}>You have admin access</div>
              <div style={{fontWeight:700, fontSize:14, marginTop:2}}>Open admin portal →</div>
            </div>
          </button>
        ) : (
          <button onClick={() => { setPhase('login'); }} className="tap" style={{
            marginTop:12, width:'100%', textAlign:'left',
            background:'transparent', color:'var(--ink-3)',
            border:'1px dashed var(--line-2)', padding:'10px 12px', borderRadius:12,
            cursor:'pointer', display:'flex', alignItems:'center', gap:8, fontSize:12, fontWeight:600,
          }}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M12 2l8 4v6c0 5-3.5 9-8 10-4.5-1-8-5-8-10V6z"/></svg>
            Try logging in as admin → admin portal
          </button>
        )}

        <div style={{
          marginTop:14, fontSize:12.5, color:'var(--ink-3)', lineHeight:1.6,
        }}>
          <b style={{color:'var(--ink-2)'}}>How to explore:</b> tap the bottom-nav inside the phone to switch screens, mark tasks done, pick a mood, type a goal, chat with Tako, and share a badge. Toggle <b>HCI annotations</b> from Tweaks to surface pinned design rationale.
        </div>
      </div>

      {/* Phone */}
      <div style={{position:'relative'}}>
        <IOSDevice width={402} height={874}>
          <div style={{position:'relative', height:'100%', background:'transparent'}}>
            {phoneContent}
            {inApp && <TabBar tab={tab} setTab={setTab}/>}
          </div>
        </IOSDevice>
        {/* screen label below */}
        <div style={{
          marginTop:14, textAlign:'center', fontSize:12,
          color:'var(--ink-3)', fontWeight:600,
        }}>
          {inApp
            ? {home:'Screen 5 — Dashboard', plan:'Screen 6 — AI Task Breakdown', hub:'Screen 7 — Gamification & Social Hub', chat:'Screen 8 — AI Chatbot'}[tab]
            : {splash:'Screen 1 — Splash', onboarding:'Screen 2 — Onboarding tour', signup:'Screen 3 — Sign up', login:'Screen 4 — Log in'}[phase]}
        </div>
      </div>

      {/* HCI Rationale */}
      <HCIPanel tab={inApp ? tab : phase} open={panelOpen} setOpen={setPanelOpen}/>

      {/* Tweaks */}
      <window.TweaksPanel title="Tweaks">
        <window.TweakSection label="Design system">
          <window.TweakColor label="Primary" value={t.primaryColor}
            onChange={v => setTweak('primaryColor', v)}
            options={['#1FB6F0','#5B5BF5','#10B981','#EC4899','#F59E0B']}/>
          <window.TweakColor label="Accent (streak)" value={t.accentColor}
            onChange={v => setTweak('accentColor', v)}
            options={['#FF8A65','#F472B6','#F5C544','#34D399','#1FB6F0']}/>
          <window.TweakSelect label="Background" value={t.background}
            onChange={v => setTweak('background', v)}
            options={[
              {value:'mint', label:'Mint + lilac'},
              {value:'lavender', label:'Lavender + peach'},
              {value:'slate', label:'Cool slate'},
              {value:'cream', label:'Warm cream'},
            ]}/>
        </window.TweakSection>
        <window.TweakSection label="HCI">
          <window.TweakToggle label="Show annotation pins"
            value={t.showAnnotations} onChange={v => setTweak('showAnnotations', v)}/>
          <window.TweakButton label={panelOpen ? 'Close rationale panel' : 'Open rationale panel'}
            onClick={() => setPanelOpen(o => !o)}/>
        </window.TweakSection>
        <window.TweakSection label="Demo data">
          <window.TweakText label="Student name" value={t.userName}
            onChange={v => setTweak('userName', v)}/>
          <window.TweakButton label="Reset demo" onClick={() => location.reload()}/>
        </window.TweakSection>
      </window.TweaksPanel>
    </div>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App/>);
