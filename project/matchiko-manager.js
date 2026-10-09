const langPills=()=>`<div class="lpills">${[['en','EN'],['fr','FR'],['ar','ع']].map(([k,c])=>`<button class="${S.lang===k?'on':''}" data-act="lang" data-arg="${k}">${c}</button>`).join('')}</div>`;
SC.login=()=>`<div class="scr login"><div class="lhero zel">${langPills()}<div class="center"><div class="lmark">${logoMark(84)}</div><div class="wm big">matchi<b>ko</b></div><h1 class="disp">${t('login_title')}</h1><p class="meta c">${t('login_sub')}</p></div></div>
<div class="pad"><div class="fld"><label>${t('phone')}</label><div class="inp num phone"><span>🇩🇿 +213</span>555 12 34 56</div></div>
<div class="glabel">${t('continue_as')}</div>
${[['player','⚽'],['manager','🏟️']].map(([k,e])=>`<button class="rolec" data-act="login" data-arg="${k}"><span class="rle">${e}</span><div style="flex:1"><b>${t('role_'+k)}</b><div class="meta">${t('role_'+k+'_sub')}</div></div>${ic('chev',20,'flip')}</button>`).join('')}</div></div>`;
const bk=id=>S.bookings.find(b=>b.id===id);
const who=b=>`<div class="row g8">${av(b.who,30,b.who.length)}<div><b>${b.who}</b><div>${b.ver?verBadge():`<span class="vb warn">⚠️ ${t('unverified')}</span>`}</div></div></div>`;
SC.mtoday=()=>{const B=S.bookings,cnt=s=>B.filter(b=>b.st===s).length;return`<div class="scr"><header class="top">${logo()}<span class="tag gold">🏟️ ${t('manager')}</span></header>
<div class="pad"><h1 class="t">${L(ST[0].n)}</h1><div class="meta">${dayLabel(0)} · ${dayDate(0).toLocaleDateString(LOC[S.lang],{day:'numeric',month:'long'})}</div>
<div class="stats mstat">${[[B.length,t('bookings'),''],[cnt('requested'),t('to_confirm'),'sand'],[cnt('guaranteed'),t('st_guaranteed'),'lime']].map(([v,l,c])=>`<div class="stat"><b class="${c}">${v}</b><span>${l}</span></div>`).join('')}</div>
<div class="tline">${[17,18,19,20,21,22,23].map(h=>{const b=B.find(x=>parseInt(x.time)===h);return b?`<div class="tl-row"><span class="tl-h num">${hh(h)}</span><div class="bcard st-${b.st}"><div class="row sb">${who(b)}${stTag(b.st)}</div><div class="meta">${b.fmt}${b.ref?` · 🟨 ${t('with_ref')}`:''} · ${num(ST[0].price+(b.ref?200:0))} ${t('da')}</div>
${b.st==='requested'?`<div class="row g8"><button class="ghost sm" data-act="noop">📞 ${t('call')}</button><button class="btn-sm grow" data-act="mconfirm" data-arg="${b.id}">${t('confirm')}</button></div>`:b.st==='confirmed'?`<div class="row g8"><button class="ghost sm" data-act="mnoshow" data-arg="${b.id}">${t('noshow')}</button><button class="btn-sm grow" data-act="mscanid" data-arg="${b.id}">${ic('qr',16)} ${t('scan_qr')}</button></div>`:b.st==='noshow'?`<span class="meta" style="color:var(--red)">✕ ${t('noshow')}</span>`:''}</div></div>`:`<div class="tl-row"><span class="tl-h num">${hh(h)}</span><div class="bfree">${t('free_slot')}</div></div>`}).join('')}</div></div></div>`};
SC.mscan=()=>{const b=S.scanId?bk(S.scanId):S.bookings.find(x=>x.st==='confirmed');return`<div class="scr pb-foot"><header class="ptitle"><h1 class="t">${t('scan_title')}</h1></header>
<div class="vf"><i class="c1"></i><i class="c2"></i><i class="c3"></i><i class="c4"></i><div class="sline"></div><div class="vqr">${qr('MTK-demo',150)}</div></div>
<p class="meta c" style="justify-content:center;margin-top:14px">${t('scan_hint')}</p></div>
<div class="foot"><button class="cta ${b?'':'disabled'}" data-act="${b?'mscanned':'noop'}">${ic('qr',18)}${b?t('simulate'):t('all_done')}</button></div>
${S.sheet==='scanres'&&b?`<div class="overlay" data-act="close"><div class="sheet" data-act="noop"><div class="grab"></div><div class="row g8"><span class="okd">${ic('check',16)}</span><h2 class="t2">${t('scanned')}</h2></div>
<div class="card mt16">${who(b)}<div class="kv"><span>${t('when')}</span><b>${dayLabel(0)} · ${b.time}</b></div><div class="kv"><span>${t('total')}</span><b class="num" style="font-size:20px">${num(ST[0].price+(b.ref?200:0))} ${t('da')}</b></div></div>
<button class="trow" data-act="cashok"><span class="pe">💵</span><b style="flex:1">${t('cash_received')}</b><span class="cbox ${S.cashOk?'on':''}">${ic('check',14)}</span></button>
<button class="cta mt16 ${S.cashOk?'':'disabled'}" data-act="${S.cashOk?'mguar':'noop'}">🛡️ ${t('mark_guar')}</button></div></div>`:''}`};
SC.mplayers=()=>{const tab=S.mview||'verify';const L2=tab==='verify'?S.vq:S.rq;return`<div class="scr"><header class="ptitle"><h1 class="disp">${t('mg_players')}</h1></header>
<div class="pad"><div class="seg">${[['verify','verify_q',S.vq.length],['ref','ref_apps',S.rq.length]].map(([k,l,n])=>`<button class="${tab===k?'on':''}" data-act="mview" data-arg="${k}">${t(l)} · ${n}</button>`).join('')}</div>
${!L2.length?`<div class="empty">✅<b>${t('all_done')}</b></div>`:tab==='verify'?S.vq.map((p,i)=>{const c=S.chk[p.h]||[];return`<div class="card mt16"><div class="idcmp"><div class="idb">${av(p.n,64,i+4)}<small>📷 ${t('nav_profile')}</small></div><span class="vs">⇄</span><div class="idb id">🪪<small>${t('id_check')}</small></div></div>
<div><b class="name">${p.n}</b><div class="meta">@${p.h} · ${ic('pin',12)}${p.city} · ${t('games_n',{n:p.g})}</div></div>
<div class="group">${['chk_name','chk_photo','chk_age'].map(k=>`<button class="opt" data-act="chk" data-arg="${p.h}|${k}"><span class="cbox ${c.includes(k)?'on':''}">${ic('check',14)}</span><b style="flex:1;font-weight:700">${t(k)}</b></button>`).join('')}</div>
<div class="row g8"><button class="ghost sm" data-act="mrej" data-arg="vq|${i}">${t('reject')}</button><button class="btn-sm grow ${c.length===3?'':'disabled'}" data-act="${c.length===3?'mver':'noop'}" data-arg="${i}">✔ ${t('verify')}</button></div></div>`}).join(''):S.rq.map((p,i)=>`<div class="card mt16"><div class="row g10">${av(p.n,48,i+2)}<div style="flex:1"><b class="name">${p.n}</b><div class="meta">@${p.h} · ${t('games_n',{n:p.g})} · <span class="rate">${ic('star',12)}${p.r}</span></div></div>${posBadge('REF',0)}</div>
<div class="row g8"><button class="ghost sm" data-act="mrej" data-arg="rq|${i}">${t('reject')}</button><button class="btn-sm grow" data-act="mrej" data-arg="rq|${i}">🟨 ${t('approve')}</button></div></div>`).join('')}</div></div>`};
S.chk={};
Object.assign(ACT,{
login(a){S.role=a;go(a==='manager'?'mtoday':'home')},
logout(){S.role=null;go('login')},
mconfirm(a){bk(a).st='confirmed';save();render(1)},
mnoshow(a){bk(a).st='noshow';save();render(1)},
mscanid(a){S.scanId=a;go('mscan')},
mscanned(){S.cashOk=false;S.sheet='scanres';render(1)},
cashok(){S.cashOk=!S.cashOk;render(1)},
mguar(){const b=S.scanId?bk(S.scanId):S.bookings.find(x=>x.st==='confirmed');b.st='guaranteed';S.scanId=null;save();go('mtoday')},
mview(a){S.mview=a;render(1)},
chk(a){const[h,k]=a.split('|');const c=S.chk[h]||[];S.chk[h]=c.includes(k)?c.filter(x=>x!==k):[...c,k];render(1)},
mver(a){S.vq.splice(+a,1);save();render(1)},
mrej(a){const[l,i]=a.split('|');S[l].splice(+i,1);save();render(1)}
});
