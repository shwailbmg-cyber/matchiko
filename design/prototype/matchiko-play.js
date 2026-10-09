const MODES=[['solo','user'],['friends','users'],['team','shield']];
SC.play=()=>{const p=S.prefs;const W={morning:'08–12',afternoon:'12–17',evening:'17–21',night:'21–00'};
const fr=p.friends.map(h=>FRIENDS.find(x=>x.h===h)).filter(Boolean);
const modeBody=p.mode==='friends'?`<div class="field"><label>${t('tagged')}</label><div class="row g6 wrap">${fr.map((f,i)=>`<span class="tagc">${av(f.n,22,i+1)}@${f.h}<button data-act="untag" data-arg="${f.h}">${ic('x',14)}</button></span>`).join('')}<button class="tagc add" data-act="sheet" data-arg="tag">+ ${t('tag')}</button></div></div>`
:p.mode==='team'?`<div class="field"><label>${t('pick_team')}</label><div class="group">${MYTEAMS.map((tm,i)=>`<button class="opt" data-act="pref" data-arg="team:${i}"><span class="crest sm">${logoMark(20)}</span><div style="flex:1"><b>${tm.n}</b><div class="meta">${t('members',{n:tm.m.length+1})} · ${tm.fmt}</div></div><span class="radio ${p.team===i?'on':''}"></span></button>`).join('')}</div><p class="meta mt8">${t('vs_search',{f:MYTEAMS[p.team].fmt})}</p></div>`:'';
return`<div class="scr pb-foot">
<div class="ph zel-soft"><div class="live"><i class="dot"></i><span data-live>${t('live',{n:S.live})}</span></div><h1 class="disp">${t('play_title')}</h1><p class="meta">${t('play_hint')}</p></div>
<div class="pad">
<div class="field"><label>${t('mode')}</label><div class="modes">${MODES.map(([k,i])=>`<button class="mode ${p.mode===k?'on':''}" data-act="pref" data-arg="mode:${k}">${ic(i,22)}<b>${t('m_'+k)}</b><small>${t('m_'+k+'_sub')}</small></button>`).join('')}</div></div>
${modeBody}
${p.mode!=='team'?`<div class="field"><label>${t('format')}</label><div class="seg">${['5v5','6v6','8v8'].map(f=>`<button class="${p.fmt===f?'on':''}" data-act="pref" data-arg="fmt:${f}">${f}</button>`).join('')}</div></div>`:''}
<div class="field"><label>${t('city')}</label><div class="chips">${CITIES.map(([k])=>`<button class="chip ${p.city===k?'on':''}" data-act="pref" data-arg="city:${k}">${ic('pin',14)} ${cityName(k)}</button>`).join('')}</div></div>
<div class="field"><label>${t('day')}</label><div class="chips">${[0,1,2,3,4].map(i=>`<button class="chip ${p.day===i?'on':''}" data-act="pref" data-arg="day:${i}">${dayLabel(i)}</button>`).join('')}</div></div>
<div class="field"><label>${t('window')}</label><div class="grid2">${Object.keys(W).map(k=>`<button class="tw ${p.times.includes(k)?'on':''}" data-act="ptime" data-arg="${k}"><b>${t(k)}</b><small>${W[k]}</small></button>`).join('')}</div></div>
<div class="field"><label>${t('positions')}<small class="hint">${t('pos_hint')}</small></label><div class="posg">${['GK','DEF','MID','FWD'].map(x=>{const o=p.pos.indexOf(x);return`<button class="posb ${o>=0?'on':''}" data-act="ppos" data-arg="${x}">${o>=0?`<i class="ord">${o+1}</i>`:''}<span class="pe">${POS_E[x]}</span><b>${t('posf_'+x)}</b></button>`}).join('')}</div></div>
<div class="field"><label>${t('distance')}<b id="rv">${p.radius} ${t('km')}</b></label><input type="range" min="1" max="20" value="${p.radius}" data-inp="radius"/></div>
<button class="trow" data-act="tpref" data-arg="ref"><span class="pe">🟨</span><div style="flex:1"><b>${t('add_ref')}</b><div class="meta">${t('add_ref_sub')}</div></div><span class="sw ${p.ref?'on':''}"></span></button>
<button class="trow" data-act="toggle" data-arg="anytime" style="margin-top:10px"><span class="pe">🔔</span><div style="flex:1"><b>${t('anytime')}</b><div class="meta">${t('anytime_sub')}</div></div><span class="sw ${S.anytime?'on':''}"></span></button>
</div></div>
<div class="foot"><button class="cta" data-act="find">${ic('bolt',20)}${p.mode==='team'?t('find_opp'):t('find')}</button></div>
${S.sheet==='tag'?`<div class="overlay" data-act="close"><div class="sheet" data-act="noop"><div class="grab"></div><h2 class="t2">${t('tag_title')}</h2><div class="group mt16">${FRIENDS.map((f,i)=>`<button class="opt" data-act="tagf" data-arg="${f.h}">${av(f.n,36,i+1)}<div style="flex:1"><b>${f.n}</b><div class="meta">@${f.h}</div></div><span class="cbox ${p.friends.includes(f.h)?'on':''}">${ic('check',14)}</span></button>`).join('')}</div><button class="cta mt16" data-act="close">${t('done')} · ${p.friends.length}</button></div></div>`:''}`};
Object.assign(ACT,{
ppos(a){const x=S.prefs.pos;S.prefs.pos=x.includes(a)?(x.length>1?x.filter(y=>y!==a):x):[...x,a];save();render(1)},
tpref(a){S.prefs[a]=!S.prefs[a];save();render(1)},
tagf(a){const x=S.prefs.friends;S.prefs.friends=x.includes(a)?x.filter(y=>y!==a):[...x,a].slice(0,parseInt(S.prefs.fmt)-1);save();render(1)},
untag(a){S.prefs.friends=S.prefs.friends.filter(y=>y!==a);save();render(1)}
});
