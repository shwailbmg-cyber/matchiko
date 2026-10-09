if(!S.up)S.up=[{st:0,day:0,time:'22:00',fmt:'6v6',status:'guaranteed',ref:true},{st:1,day:1,time:'19:00',fmt:'8v8',status:'requested'}];KEEP.push('up');
const STEPS=['requested','confirmed','guaranteed'];
const ladder=st=>{const k=STEPS.indexOf(st);return`<div class="ladder">${STEPS.map((s,i)=>`<div class="lstep ${i<=k?'on':''} ${i===k?'cur':''}"><i>${i<k||st==='guaranteed'?ic('check',11):''}</i><span>${t('st_'+s)}</span></div>`).join('')}</div><div class="meta lsub">${t('st_'+['req','conf','guar'][k]+'_sub')}</div>`};
const stTag=st=>`<span class="stt stt-${st}">${st==='guaranteed'?'🛡️':st==='confirmed'?'✅':'⏳'} ${t('st_'+st)}</span>`;
const bookTotal=s=>s.price+(S.bref?200:0);
function bookSheet(s){const tot=bookTotal(s);return`<div class="overlay" data-act="close"><div class="sheet" data-act="noop"><div class="grab"></div><h2 class="t2">${t('req_title')}</h2><div class="meta">${L(s.n)} · ${dayLabel(S.day)} · ${S.slot}–${hh(parseInt(S.slot)+1)}</div>
<button class="trow" data-act="bref"><span class="pe">🟨</span><div style="flex:1"><b>${t('add_ref')}</b><div class="meta">${t('add_ref_sub')}</div></div><span class="sw ${S.bref?'on':''}"></span></button>
<div class="glabel">${t('pay_method')}</div><div class="group">${[['cash','cash'],['online','shield']].map(([k,i])=>`<button class="opt" data-act="paym" data-arg="${k}"><span class="lcode ${k==='online'?'lime':''}">${ic(i,18)}</span><div style="flex:1"><b>${t('pay_'+k)}</b><div class="meta">${t('pay_'+k+'_sub')}</div></div><span class="radio ${S.pay===k?'on':''}"></span></button>`).join('')}</div>
<div class="kvs"><div class="kv"><span>${t('pitch')}</span><b>${num(s.price)} ${t('da')}</b></div>${S.bref?`<div class="kv"><span>${t('ref_fee')}</span><b>200 ${t('da')}</b></div>`:''}<div class="kv"><span>${t('total')}</span><b class="num" style="font-size:20px">${num(tot)} ${t('da')}</b></div></div>
${S.pay==='cash'?`<div class="note">${ic('cash',20)}<span>${t('cash_note')}</span></div><button class="cta" data-act="send">${t('send')}</button>`:`<button class="cta mt16" data-act="go" data-arg="satim">${ic('shield',18)}${t('pay_btn',{a:num(tot)})}</button>`}
<button class="ghost w" data-act="close">${t('cancel')}</button></div></div>`}
const verifySheet=()=>`<div class="overlay" data-act="close"><div class="sheet" data-act="noop"><div class="grab"></div><div class="center"><span class="bigemo">🪪</span><h2 class="t2">${t('verify_needed')}</h2><p class="meta c" style="max-width:300px;margin:6px auto 0">${t('verify_needed_sub')}</p><div class="ticket mini"><div class="qrbox">${qr('VERIFY-amineB7',140)}</div><div class="code"><small>${t('my_verify_code')}</small><b>@amineB7</b></div></div></div><button class="ghost w" data-act="close">${t('done')}</button></div></div>`;
SC.satim=()=>{const s=ST[S.stadium],tot=bookTotal(s),st=S.payStage||'form';
if(st==='done')return`<div class="scr pb-foot"><div class="center" style="padding-top:18px"><div class="ok">${ic('check',32)}</div><h1 class="disp">${t('paid')}</h1><p class="meta c">${t('paid_sub')}</p><span class="coinpop">🪙 +15</span></div><div class="pad mt16"><div class="card">${ladder('guaranteed')}</div></div>${ticket({st:S.stadium,day:S.day,time:S.slot,fmt:s.fmt})}</div><div class="foot"><button class="cta" data-act="tab" data-arg="matches">${t('go_matches')}</button></div>`;
return`<div class="scr pb-foot"><header class="ptitle"><div class="row g10"><button class="iconbtn" data-act="go" data-arg="detail">${ic('back',20,'flip')}</button><h1 class="t">${t('satim_title')}</h1></div><span class="satim">SATIM</span></header>
<div class="pad"><div class="ccard zel"><div class="row sb"><b class="cbrand">${S.card==='edahabia'?'EDAHABIA':'CIB'}</b><span class="chip-ic"></span></div><div class="cnum">•••• •••• •••• 4821</div><div class="row sb"><span>AMINE BENALI</span><span>09/28</span></div></div>
<div class="seg mt16">${['cib','edahabia'].map(k=>`<button class="${(S.card||'cib')===k?'on':''}" data-act="card" data-arg="${k}">${k==='cib'?'CIB':'Edahabia'}</button>`).join('')}</div>
<div class="fld"><label>${t('card_no')}</label><div class="inp num">6280 5500 1234 4821</div></div>
<div class="grid2"><div class="fld"><label>${t('expiry')}</label><div class="inp num">09/28</div></div><div class="fld"><label>${t('cvv')}</label><div class="inp num">•••</div></div></div>
<div class="kvs"><div class="kv"><span>${L(s.n)} · ${S.slot}</span><b>${num(s.price)} ${t('da')}</b></div>${S.bref?`<div class="kv"><span>${t('ref_fee')}</span><b>200 ${t('da')}</b></div>`:''}</div></div></div>
<div class="foot"><button class="cta ${st==='proc'?'disabled':''}" data-act="${st==='proc'?'noop':'paynow'}">${st==='proc'?`<span class="spin"></span>${t('processing')}`:`${ic('shield',18)}${t('pay_btn',{a:num(tot)})}`}</button></div>`};
Object.assign(ACT,{
bref(){S.bref=!S.bref;render(1)},
paym(a){S.pay=a;render(1)},
card(a){S.card=a;render(1)},
paynow(){S.payStage='proc';render(1);T.push(setTimeout(()=>{S.payStage='done';S.coins+=15;S.up.unshift({st:S.stadium,day:S.day,time:S.slot,fmt:ST[S.stadium].fmt,status:'guaranteed',ref:S.bref});S.pend[`${S.stadium}-${S.day}-${parseInt(S.slot)}`]=1;save();render()},1600))},
book(){S.sheet=S.verified?'book':'verify';render(1)}
});
