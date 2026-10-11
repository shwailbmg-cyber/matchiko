const PNAV=['home','play','matches','profile'],MNAV=['mtoday','mscan','mplayers','settings'];
let T=[];const clearT=()=>{T.forEach(x=>{clearInterval(x);clearTimeout(x)});T=[]};
function navHTML(){if(S.role==='manager')return[['mtoday','cal'],['mscan','qr'],['mplayers','users'],['settings','gear']].map(([k,i])=>`<button class="nb ${S.tab===k?'on':''}" data-act="tab" data-arg="${k}">${ic(i,23)}<span>${t('mg_'+k.replace(/^m/,'').replace('players','players').replace('settings','settings'))}</span></button>`).join('');
return[['home','home'],['play','bolt'],['matches','cal'],['profile','user']].map(([k,i])=>k==='play'?`<button class="nb nb-play ${S.tab===k?'on':''}" data-act="tab" data-arg="play"><span class="disc">${ic(i,24)}</span><span>${t('nav_play')}</span></button>`:`<button class="nb ${S.tab===k?'on':''}" data-act="tab" data-arg="${k}">${ic(i,23)}<span>${t('nav_'+k)}</span></button>`).join('')}
function render(keep){const v=$('#view');const old=v.querySelector('.scr');const top=keep&&old?old.scrollTop:0;v.innerHTML=SC[S.screen]();const n=v.querySelector('.scr');if(n){if(keep)n.scrollTop=top;else n.classList.add('enter')}
const ph=$('#phone');ph.dir=S.lang==='ar'?'rtl':'ltr';ph.lang=S.lang;document.documentElement.lang=S.lang;
const nv=$('#nav');nv.innerHTML=navHTML();nv.hidden=!(S.role==='manager'?MNAV:PNAV).includes(S.screen)}
function go(s){clearT();if(PNAV.includes(s)||MNAV.includes(s))S.tab=s;if(s==='settings'&&S.role!=='manager')S.tab='profile';S.prev=S.screen;S.screen=s;S.sheet=null;if(s==='satim')S.payStage='form';save();render();start(s)}
function start(s){
if(s==='searching'){const tot=2*parseInt(S.match.fmt);let n=0;const st=k=>{for(let i=1;i<=4;i++){const e=$('#step'+i);if(e)e.className='step'+(i<k?' done':i===k?' act':'')}};st(1);
T.push(setInterval(()=>{const e=$('#rav'+n);if(e)e.classList.add('in');n++;$('#sc').textContent=n;st(Math.min(4,1+Math.floor(n/(tot/4))));if(n>=tot){clearT();st(5);T.push(setTimeout(()=>go('found'),650))}},200))}
if(s==='found'){const{A,B}=teams();let r=0;const order=[];A.forEach((_,i)=>{order.push('A'+i);if(B[i])order.push('B'+i)});
T.push(setInterval(()=>{if(r>=order.length)return;const k=order[r++];$('#pd'+k)?.classList.add('in');$('#pr'+k)?.classList.add('in')},150));
let sec=30;const circ=2*Math.PI*42;T.push(setInterval(()=>{sec--;if(sec<0){go('play');return}const a=$('#cda'),nEl=$('#cdn');if(!a)return;const col=sec>15?'#3ddc84':sec>7?'#e9c46a':'#f06464';a.style.strokeDashoffset=circ*(1-sec/30);a.setAttribute('stroke',col);nEl.textContent=sec;nEl.style.color=col},1000))}}
Object.assign(ACT,{
noop(){},go(a){go(a)},tab(a){go(a)},
back(){go(S.prev&&!['detail','satim'].includes(S.prev)?S.prev:'home')},
stadium(a){S.stadium=+a;S.day=0;S.slot=null;S.bref=false;go('detail')},
day(a){S.day=+a;S.slot=null;render(1)},
slot(a){S.slot=S.slot===a?null:a;render(1)},
sheet(a){S.sheet=a;render(1)},
close(){S.sheet=null;render(1)},
send(){S.sheet='sent';render(1);S.up.unshift({st:S.stadium,day:S.day,time:S.slot,fmt:ST[S.stadium].fmt,status:'requested',ref:S.bref});T.push(setTimeout(()=>{S.pend[`${S.stadium}-${S.day}-${parseInt(S.slot)}`]=1;S.slot=null;S.sheet=null;save();render(1)},1500))},
pref(a){const[k,v]=a.split(':');S.prefs[k]=(k==='day'||k==='team')?+v:v;if(k==='fmt')S.prefs.friends=S.prefs.friends.slice(0,parseInt(v)-1);save();render(1)},
ptime(a){const x=S.prefs.times;S.prefs.times=x.includes(a)?(x.length>1?x.filter(y=>y!==a):x):[...x,a];save();render(1)},
toggle(a){S[a]=!S[a];save();render(1)},
find(){const p=S.prefs;const tm={morning:'10:00',afternoon:'15:00',evening:'20:00',night:'22:00'};const w=['morning','afternoon','evening','night'].find(o=>p.times.includes(o))||'evening';const fmt=p.mode==='team'?MYTEAMS[p.team].fmt:p.fmt;S.match={st:{'5v5':2,'6v6':0,'8v8':1}[fmt],time:tm[w],fmt,day:p.day};go('searching')},
join(a){const g=OPEN[+a];S.prefs.mode='solo';S.match={st:g.st,time:g.time,fmt:ST[g.st].fmt,day:0};go('found')},
pass(){go('play')},
accept(){S.joined={...S.match};S.up.unshift({...S.match,status:'confirmed',ref:S.prefs.ref});S.xp+=0;save();go('confirmed')},
mtab(a){S.mtab=a;save();render()},
lang(a){S.lang=a;save();render(1)}
});
document.addEventListener('click',e=>{const el=e.target.closest('[data-act]');if(!el)return;e.stopPropagation();ACT[el.dataset.act]?.(el.dataset.arg,el)});
document.addEventListener('input',e=>{const x=e.target;if(x.dataset.inp==='radius'){S.prefs.radius=+x.value;$('#rv').textContent=x.value+' '+t('km');save()}
if(x.id==='q'){const q=x.value.toLowerCase();$('#slist').innerHTML=ST.map((s,i)=>[s,i]).filter(([s])=>(s.n.l+s.n.ar+s.d.l+s.d.ar).toLowerCase().includes(q)).map(([s,i])=>srow(s,i)).join('')}});
setInterval(()=>{S.live=Math.max(38,S.live+(Math.random()>.5?1:-1));document.querySelectorAll('[data-live]').forEach(e=>e.textContent=t('live',{n:S.live}))},3000);
function fit(){const ph=$('#phone');if(innerWidth<=440){ph.style.transform='';return}const s=Math.min(1,(innerHeight-32)/864,(innerWidth-32)/410);ph.style.transform=`scale(${s})`}
if(!SC[S.screen])S.screen=S.role?(S.role==='manager'?'mtoday':'home'):'login';
addEventListener('resize',fit);fit();render();start(S.screen);
