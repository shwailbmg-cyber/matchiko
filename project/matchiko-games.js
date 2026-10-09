const RPL=[{n:'Yacine K',h:'yacine_dz',p:'MID'},{n:'Hakim M',h:'hakim_m',p:'DEF'},{n:'Bilal T',h:'bilal_gk',p:'GK'},{n:'Redha K',h:'redha_k',p:'FWD'},{n:'Karim B',h:'karim_b',p:'MID'},{n:'Nassim H',h:'nassim_h',p:'DEF'},{n:'Karim Rahmani',h:'karim_ref',p:'REF'}];
const PTAGS=['👍 #fair_play','⏱️ #on_time','⚡ #skilled','🐢 #late'];
const RLA=['Riad M','Nabil F','Samy L','Farid O','Omar B','Adel Z'],RLB=['Ilyes K','Mehdi S','Anis R','Walid D','Chouaib B','Raouf G'];
const EV={goal:'⚽',yellow:'🟨',red:'🟥',mvp:'🏆'};
const dblock=d=>`<div class="date"><small>${wd(d)}</small><b>${dayDate(d).getDate()}</b></div>`;
SC.matches=()=>`<div class="scr"><header class="ptitle"><h1 class="disp">${t('nav_matches')}</h1></header>
<div class="pad"><div class="seg">${['upcoming','past'].map(k=>`<button class="${S.mtab===k?'on':''}" data-act="mtab" data-arg="${k}">${t(k)}</button>`).join('')}</div></div>
<div class="list mt16">${S.mtab==='upcoming'?S.up.map((m,i)=>`<div class="mcard col"><div class="row g14" style="width:100%">${dblock(m.day)}<div class="info"><div class="name">${L(ST[m.st].n)}</div><div class="meta"><b class="num">${m.time}</b> · ${m.fmt}${m.ref&&!m.iref?` · 🟨 ${t('with_ref')}`:''}</div>${m.iref?`<span class="stt stt-ref">🟨 ${t('ref_game')}</span>`:stTag(m.status)}</div>${m.iref?`<button class="btn-sm" data-act="${S.reported?'noop':'go'}" data-arg="reflog">${S.reported?t('reported'):t('ref_open')}</button>`:m.status!=='requested'?`<button class="iconbtn lime" data-act="qr" data-arg="${i}">${ic('qr',20)}</button>`:''}</div>${m.iref?'':`<div class="mini-l">${ladder(m.status)}</div>`}</div>`).join(''):PAST.map((m,i)=>`<div class="mcard">${dblock(m.day)}<div class="info"><div class="name">${L(ST[m.st].n)}</div><div class="meta">${m.fmt} · <span class="res ${m.res}">${t(m.res)}</span></div></div><div class="endcol"><b class="score">${m.score}</b>${S.rated[i]?`<span class="meta">${ic('check',13)}${t('rated')}</span>`:`<button class="btn-sm" data-act="rate" data-arg="${i}">${t('rate')}</button>`}</div></div>`).join('')}</div></div>
${S.sheet==='qr'?`<div class="overlay" data-act="close"><div class="sheet" data-act="noop"><div class="grab"></div>${ticket(S.up[S.qi])}<div class="card mt16">${ladder(S.up[S.qi].status)}</div><button class="ghost w" data-act="close">${ic('x',18)}</button></div></div>`:''}`;
SC.rate=()=>{const m=PAST[S.rateIdx??0];return`<div class="scr pb-foot"><header class="ptitle"><div class="row g10"><button class="iconbtn" data-act="tab" data-arg="matches">${ic('back',20,'flip')}</button><div><h1 class="t">${t('rate_title')}</h1><div class="meta">${L(ST[m.st].n)} · ${m.score}</div></div></div></header>
<div class="pad"><div class="card"><b>🏟️ ${t('rate_pitch')}</b><div class="rstars sm">${[1,2,3,4,5].map(n=>`<button class="${S.rateStars>=n?'on':''}" data-act="rstar" data-arg="${n}">${ic('star',30)}</button>`).join('')}</div></div>
<h2 class="mt">${t('rate_players')}</h2>
${RPL.map((p,i)=>{const v=S.rp[p.h]||0,tg=S.rpt[p.h]||[];return`<div class="rp"><div class="row g10">${av(p.n,36,i+1)}<div style="flex:1;min-width:0"><b>@${p.h}</b><div class="meta">${POS_E[p.p]} ${t('posf_'+p.p)}</div></div><div class="rs">${[1,2,3,4,5].map(n=>`<button class="${v>=n?'on':''}" data-act="rps" data-arg="${p.h}:${n}">${ic('star',20)}</button>`).join('')}</div></div>${v?`<div class="row g6 wrap mt8">${PTAGS.map(x=>`<button class="chip xs ${tg.includes(x)?'on':''}" data-act="rpt" data-arg="${p.h}|${x}">${x}</button>`).join('')}</div>`:''}</div>`}).join('')}</div></div>
<div class="foot"><button class="cta ${S.rateStars?'':'disabled'}" data-act="${S.rateStars?'rsubmit':'noop'}">${t('submit')} · ${t('earn')}</button></div>`};
SC.reflog=()=>{const g=S.up.find(x=>x.iref)||S.up[0];const ev=S.rl.ev;const sc=k=>ev.filter(e=>e.type==='goal'&&e.team===k).length;
const col=(T,k,c)=>`<div><h3 style="color:${c}">${k==='A'?'A':'B'}</h3>${T.map((n,i)=>{const mine=ev.filter(e=>e.n===n).map(e=>EV[e.type]).join('');return`<button class="rlp" data-act="rlp" data-arg="${k}:${n}">${av(n,26,i+(k==='A'?1:4))}<span>${n}</span><i>${mine}</i></button>`}).join('')}</div>`;
return`<div class="scr pb-foot"><header class="ptitle"><div class="row g10"><button class="iconbtn" data-act="tab" data-arg="matches">${ic('back',20,'flip')}</button><div><h1 class="t">${t('ref_log')}</h1><div class="meta">${L(ST[g.st].n)} · ${g.time}</div></div></div></header>
<div class="board zel"><span class="tl">A</span><b class="num">${sc('A')} – ${sc('B')}</b><span class="tl b">B</span></div>
<div class="pad"><div class="seg mt16">${Object.keys(EV).map(k=>`<button class="${S.rl.type===k?'on':''}" data-act="rlt" data-arg="${k}">${EV[k]} ${t(k)}</button>`).join('')}</div>
<p class="meta c mt8" style="justify-content:center">${t('pick_event')}</p>
<div class="teams" style="padding:10px 0 0">${col(RLA,'A','var(--lime)')}${col(RLB,'B','var(--terra)')}</div>
${ev.length?`<h2 class="mt">${t('events')}</h2><div class="group">${ev.slice().reverse().map(e=>`<div class="opt"><span class="pe">${EV[e.type]}</span><b style="flex:1">${e.n}</b><span class="meta">${e.team}</span></div>`).join('')}</div>`:''}</div></div>
<div class="foot"><button class="cta ${ev.length?'':'disabled'}" data-act="${ev.length?'rlsubmit':'noop'}">${t('submit_report')} · +50 🪙</button></div>`};
if(!S.up.some(x=>x.iref))S.up.push({st:0,day:0,time:'18:00',fmt:'6v6',status:'guaranteed',iref:true});
S.rl={type:'goal',ev:[]};S.rp={};S.rpt={};
Object.assign(ACT,{
qr(a){S.qi=+a;S.sheet='qr';render(1)},
rate(a){S.rateIdx=+a;S.rateStars=0;S.rp={};S.rpt={};go('rate')},
rps(a){const[h,n]=a.split(':');S.rp[h]=+n;render(1)},
rpt(a){const[h,x]=a.split('|');const c=S.rpt[h]||[];S.rpt[h]=c.includes(x)?c.filter(y=>y!==x):[...c,x];render(1)},
rsubmit(){S.rated[S.rateIdx]=1;S.coins+=10;S.xp+=5;save();go('matches')},
rlt(a){S.rl.type=a;render(1)},
rlp(a){const[team,n]=a.split(':');if(S.rl.type==='mvp')S.rl.ev=S.rl.ev.filter(e=>e.type!=='mvp');S.rl.ev.push({team,n,type:S.rl.type});render(1)},
rlsubmit(){S.reported=true;S.coins+=50;S.xp+=40;S.rl={type:'goal',ev:[]};save();go('matches')}
});
