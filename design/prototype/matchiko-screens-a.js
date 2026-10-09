const SC={};
const stars=r=>`<span class="rate">${ic('star',13)}${r}</span>`;
const srow=(s,i)=>`<button class="srow" data-act="stadium" data-arg="${i}"><div class="thumb turf">${pitchLines(76,76,.35)}</div><div class="info"><div class="name">${L(s.n)}</div><div class="meta">${ic('pin',13)}${L(s.d)} · ${s.km} ${t('km')}</div><div class="meta">${stars(s.r)}<span class="tag sm">${s.fmt}</span></div></div><div class="price"><b>${num(s.price)}</b><span>${t('da')}${t('per_hour')}</span></div></button>`;

SC.home=()=>`<div class="scr">
<header class="top">${logo()}<div class="row g8"><button class="iconbtn" data-act="noop">${ic('bell',19)}<i class="badge"></i></button><button data-act="tab" data-arg="profile">${av('Amine B',40,0)}</button></div></header>
<section class="hero zel"><div class="live"><i class="dot"></i><span data-live>${t('live',{n:S.live})}</span></div><h1 class="disp">${t('home_title')}</h1><p>${t('play_sub')}</p><button class="cta" data-act="tab" data-arg="play">${ic('bolt',20)}${t('play_now')}</button></section>
<div class="sec-h"><h2>${t('open_games')}</h2></div>
<div class="hscroll">${OPEN.map((g,i)=>{const s=ST[g.st],tot=2*parseInt(s.fmt);return`<div class="og"><div class="row sb"><span class="tag">${s.fmt}</span><span class="meta">${ic('clock',14)}${t('tonight')} · <b class="num">${g.time}</b></span></div><div><div class="name">${L(s.n)}</div><div class="meta">${s.km} ${t('km')} · ${t('each',{p:ppp(g.st,s.fmt)})}</div></div><div class="fill" style="grid-template-columns:repeat(${tot},1fr)">${Array.from({length:tot},(_,k)=>`<span class="${k<tot-g.need?'on':''}"></span>`).join('')}</div><div class="row sb"><div class="row g8"><div class="stack">${[1,2,3,4].map(k=>av('ABCDEFGH'[k+i]+' '+'KMRS'[k],26,k+i)).join('')}</div><span class="need">${t('spots',{n:g.need})}</span></div><button class="btn-sm" data-act="join" data-arg="${i}">${t('join')}</button></div></div>`}).join('')}</div>
<div class="sec-h"><h2>${t('nearby')}</h2><button class="link">${t('see_all')}</button></div>
<div class="pad"><label class="search">${ic('search',18)}<input id="q" placeholder="${t('search_ph')}"/></label></div>
<div class="list" id="slist">${ST.map(srow).join('')}</div>
</div>`;

SC.detail=()=>{const s=ST[S.stadium];const days=[0,1,2,3,4,5,6];return`<div class="scr pb-foot">
<div class="d-hero turf">${pitchLines(390,210,.3)}<div class="d-shade"></div><div class="d-bar"><button class="round" data-act="back">${ic('back',20,'flip')}</button><span class="tag solid">${s.fmt}</span></div><div class="zband"></div></div>
<div class="pad">
<div class="d-head"><div><h1 class="t">${L(s.n)}</h1><div class="meta">${ic('pin',14)}${L(s.d)} · ${s.km} ${t('km')}</div><div class="meta" style="margin-top:4px">${stars(s.r)}<span>${t('reviews_n',{n:s.rv})}</span></div></div><div class="price big"><b>${num(s.price)}</b><span>${t('da')}${t('per_hour')}</span></div></div>
<div class="feats">${Object.keys(FEAT).map(k=>`<div class="feat ${s.f.includes(k)?'':'off'}">${ic(FEAT[k],20)}<span>${t('f_'+k)}</span></div>`).join('')}</div>
<h2 class="mt">${t('slots_title')}</h2>
<div class="days">${days.map(i=>`<button class="dayb ${S.day===i?'on':''}" data-act="day" data-arg="${i}"><small>${i===0?t('today'):wd(i)}</small><b>${dayDate(i).getDate()}</b></button>`).join('')}</div>
<div class="legend"><span class="lg"><i class="free"></i>${t('free')}</span><span class="lg"><i class="booked"></i>${t('booked')}</span><span class="lg"><i class="pending"></i>${t('pending')}</span></div>
<div class="slots">${HOURS.map(h=>{const st=slotStatus(S.stadium,S.day,h);const sel=S.slot===hh(h);return`<button class="sl ${st} ${sel?'sel':''}" ${st==='free'?`data-act="slot" data-arg="${hh(h)}"`:''}>${hh(h)}</button>`}).join('')}</div>
<h2 class="mt">${t('reviews')}</h2>
${s.revs.map((r,i)=>`<div class="rev"><div class="row sb"><div class="row g8">${av(r.a,32,i+2)}<b>${r.a}</b></div><span class="meta">${stars(r.r)} · ${r.ago}</span></div><p>${r.t}</p><div class="row g6">${r.tags.map(x=>`<span class="htag">${x}</span>`).join('')}</div></div>`).join('')}
</div></div>
<div class="foot"><button class="cta ${S.slot?'':'disabled'}" data-act="${S.slot?'book':'noop'}">${S.slot?t('book',{t:S.slot})+' · '+num(s.price)+' '+t('da'):t('pick_slot')}</button></div>
${S.sheet==='book'?bookSheet(s):''}${S.sheet==='verify'?verifySheet():''}
${S.sheet==='sent'?`<div class="overlay"><div class="sheet center"><div class="grab"></div><div class="ok sm">${ic('check',28)}</div><h2 class="t2">${t('sent')}</h2><p class="meta c">${t('sent_sub')}</p></div></div>`:''}`};

SC.play=()=>{const p=S.prefs;const W={morning:'08–12',afternoon:'12–17',evening:'17–21',night:'21–00'};return`<div class="scr pb-foot">
<div class="ph zel-soft"><div class="live"><i class="dot"></i><span data-live>${t('live',{n:S.live})}</span></div><h1 class="disp">${t('play_title')}</h1><p class="meta">${t('play_hint')}</p></div>
<div class="pad">
<div class="field"><label>${t('format')}</label><div class="seg">${['5v5','6v6','8v8'].map(f=>`<button class="${p.fmt===f?'on':''}" data-act="pref" data-arg="fmt:${f}">${f}</button>`).join('')}</div></div>
<div class="field"><label>${t('day')}</label><div class="chips">${[0,1,2,3,4].map(i=>`<button class="chip ${p.day===i?'on':''}" data-act="pref" data-arg="day:${i}">${dayLabel(i)}</button>`).join('')}</div></div>
<div class="field"><label>${t('window')}</label><div class="grid2">${Object.keys(W).map(k=>`<button class="tw ${p.times.includes(k)?'on':''}" data-act="ptime" data-arg="${k}"><b>${t(k)}</b><small>${W[k]}</small></button>`).join('')}</div></div>
<div class="field"><label>${t('position')}</label><div class="seg">${['GK','DEF','MID','FWD'].map(x=>`<button class="${p.pos===x?'on':''}" data-act="pref" data-arg="pos:${x}">${POS_E[x]} ${t('pos_'+x)}</button>`).join('')}</div></div>
<div class="field"><label>${t('distance')}<b id="rv">${p.radius} ${t('km')}</b></label><input type="range" min="1" max="20" value="${p.radius}" data-inp="radius"/></div>
<button class="trow" data-act="toggle" data-arg="anytime"><div style="flex:1"><b>${t('anytime')}</b><div class="meta">${t('anytime_sub')}</div></div><span class="sw ${S.anytime?'on':''}"></span></button>
</div></div>
<div class="foot"><button class="cta" data-act="find">${ic('bolt',20)}${t('find')}</button></div>`};
