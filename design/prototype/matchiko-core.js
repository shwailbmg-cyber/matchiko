const $=s=>document.querySelector(s);
const LS='matchiko_v2';
const S=Object.assign({lang:'en',screen:'home',tab:'home',stadium:0,day:0,slot:null,sheet:null,prefs:{day:0,times:['evening'],pos:['FWD','MID'],fmt:'6v6',radius:5,mode:'solo',friends:['yacine_dz','hakim_m'],team:0,city:'alger',ref:false},role:null,verified:true,coins:340,xp:1240,pay:'cash',bref:false,bookings:[{id:'b1',who:'Riad M',h:'riad_m',ver:true,time:'18:00',fmt:'6v6',st:'requested',ref:false},{id:'b2',who:'Nabil F',h:'nabil_f',ver:true,time:'19:00',fmt:'6v6',st:'confirmed',ref:true},{id:'b3',who:'Samy L',h:'samy_l',ver:true,time:'20:00',fmt:'6v6',st:'guaranteed',ref:false},{id:'b4',who:'Farid O',h:'farid_o',ver:false,time:'22:00',fmt:'6v6',st:'requested',ref:false}],vq:[{n:'Omar Belkacem',h:'omar_b',city:'Alger',g:3},{n:'Ilyes Kaci',h:'ilyes_k',city:'Blida',g:0}],rq:[{n:'Karim Rahmani',h:'karim_ref',g:64,r:4.8}],anytime:true,mtab:'upcoming',match:{st:0,time:'21:00',fmt:'6v6',day:0},joined:null,alerts:true,reminders:true,rt:340,rated:{},live:47,pend:{},rateStars:0,rateTags:[]},JSON.parse(localStorage.getItem(LS)||'{}'));
if(typeof S.prefs.pos==='string')S.prefs.pos=[S.prefs.pos];S.prefs=Object.assign({mode:'solo',friends:[],team:0,city:'alger',ref:false},S.prefs);
if(['searching','found','confirmed','satim','reflog','rate','wallet'].includes(S.screen))S.screen=S.role==='manager'?'mtoday':'play';if(!S.role)S.screen='login';
S.sheet=null;
const KEEP=['lang','screen','tab','stadium','prefs','anytime','mtab','match','joined','alerts','reminders','rated','role','verified','coins','xp','bookings','vq','rq','reported'];
function save(){const o={};KEEP.forEach(k=>o[k]=S[k]);localStorage.setItem(LS,JSON.stringify(o))}
const ACT={};
const t=(k,v={})=>{let s=(I18N[S.lang]||{})[k]??I18N.en[k]??k;for(const x in v)s=s.replace('{'+x+'}',v[x]);return s};
const L=o=>typeof o==='string'?o:(S.lang==='ar'?o.ar:o.l);
const num=n=>n.toLocaleString(S.lang==='fr'?'fr-FR':'en-US');
const LOC={en:'en-GB',fr:'fr-FR',ar:'ar-DZ'};
const dayDate=i=>{const d=new Date();d.setDate(d.getDate()+i);return d};
const wd=i=>new Intl.DateTimeFormat(LOC[S.lang],{weekday:'short'}).format(dayDate(i)).replace('.','');
const dayLabel=i=>i===0?t('today'):i===1?t('tomorrow'):wd(i);

const P={
home:'<path d="M3 11l9-7 9 7v9a1 1 0 01-1 1h-5v-6H9v6H4a1 1 0 01-1-1z"/>',
cal:'<rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 10h18M8 3v4M16 3v4"/>',
user:'<circle cx="12" cy="8" r="4"/><path d="M4 21c0-4.4 3.6-7 8-7s8 2.6 8 7"/>',
bolt:'<path d="M13 2L4 14h7l-1 8 9-12h-7z"/>',
search:'<circle cx="11" cy="11" r="7"/><path d="M20 20l-4-4"/>',
back:'<path d="M15 18l-6-6 6-6"/>',
chev:'<path d="M9 6l6 6-6 6"/>',
pin:'<path d="M12 21s7-6.2 7-12a7 7 0 10-14 0c0 5.8 7 12 7 12z"/><circle cx="12" cy="9" r="2.5"/>',
star:'<path d="M12 3l2.8 5.8 6.2.9-4.5 4.4 1 6.2L12 17.4 6.5 20.3l1-6.2L3 9.7l6.2-.9z" fill="currentColor" stroke="none"/>',
light:'<path d="M9 18h6M10 21h4M12 3a6 6 0 00-3.5 10.9c.6.5 1 1.2 1 2.1h5c0-.9.4-1.6 1-2.1A6 6 0 0012 3z"/>',
ball:'<circle cx="12" cy="12" r="9"/><path d="M12 7.5l3.8 2.8-1.4 4.4H9.6L8.2 10.3z"/><path d="M12 3v4.5M15.8 10.3l4.4-1.4M14.4 14.7l2.7 3.8M9.6 14.7l-2.7 3.8M8.2 10.3L3.8 8.9"/>',
shower:'<path d="M5 21V8a4 4 0 017.5-2"/><path d="M10 9h8a4 4 0 00-8 0z"/><path d="M11 13v1M14 13v1M17 13v1M12.5 17v1M15.5 17v1"/>',
roof:'<path d="M3 10l9-6 9 6"/><path d="M5 9v11h14V9"/>',
whistle:'<circle cx="9" cy="14" r="5"/><path d="M12.5 10.5L21 7v4l-6.5 2.5"/><circle cx="9" cy="14" r="1.5"/>',
check:'<path d="M5 12.5l4.5 4.5L19 7"/>',
clock:'<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',
users:'<circle cx="9" cy="8" r="3.5"/><path d="M2.5 20c0-3.6 2.9-6 6.5-6s6.5 2.4 6.5 6"/><path d="M16 4.6a3.5 3.5 0 010 6.8M18 14.2c2.3.7 3.5 2.8 3.5 5.8"/>',
gear:'<circle cx="12" cy="12" r="3"/><path d="M12 2v3M12 19v3M4.9 4.9l2.1 2.1M17 17l2.1 2.1M2 12h3M19 12h3M4.9 19.1L7 17M17 7l2.1-2.1"/>',
bell:'<path d="M6 16v-5a6 6 0 0112 0v5l2 2H4z"/><path d="M10 21h4"/>',
qr:'<rect x="3" y="3" width="7" height="7" rx="1"/><rect x="14" y="3" width="7" height="7" rx="1"/><rect x="3" y="14" width="7" height="7" rx="1"/><path d="M14 14h3v3h-3zM18 18h3v3h-3zM14 20h2M20 14v2"/>',
x:'<path d="M6 6l12 12M18 6L6 18"/>',
shield:'<path d="M12 3l8 3v6c0 4.5-3.4 8.3-8 9-4.6-.7-8-4.5-8-9V6z"/><path d="M8.5 12l2.5 2.5 4.5-5"/>',
cash:'<rect x="2" y="6" width="20" height="12" rx="2"/><circle cx="12" cy="12" r="3"/><path d="M6 10v4M18 10v4"/>',
globe:'<circle cx="12" cy="12" r="9"/><path d="M3 12h18M12 3c2.5 2.5 3.8 5.5 3.8 9s-1.3 6.5-3.8 9c-2.5-2.5-3.8-5.5-3.8-9S9.5 5.5 12 3z"/>'
};
const ic=(n,s=20,c='')=>`<svg class="ic ${c}" width="${s}" height="${s}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round">${P[n]}</svg>`;
const logoMark=(s=34)=>`<svg width="${s}" height="${s}" viewBox="0 0 40 40"><g fill="#3ddc84"><rect x="8" y="8" width="24" height="24" rx="2.5"/><rect x="8" y="8" width="24" height="24" rx="2.5" transform="rotate(45 20 20)"/></g><circle cx="20" cy="20" r="8.6" fill="#06110b"/><path d="M20 14.6l5.1 3.7-2 6h-6.2l-2-6z" fill="none" stroke="#3ddc84" stroke-width="1.5" stroke-linejoin="round"/></svg>`;
const logo=()=>`<div class="logo">${logoMark()}<span class="wm">matchi<b>ko</b></span></div>`;
const AVC=['#3ddc84','#e9c46a','#6cb4ee','#ef7b5a','#b39ddb','#4dd0c8','#f4a261','#90be6d'];
const av=(n,s=32,c=0,extra='')=>{const col=AVC[c%AVC.length];const ini=n.split(' ').map(x=>x[0]).join('').slice(0,2).toUpperCase();return`<span class="av" style="width:${s}px;height:${s}px;background:${col}26;color:${col};font-size:${Math.round(s*.36)}px;${extra}">${ini}</span>`};
const pitchLines=(w,h,op=.45)=>`<svg width="${w}" height="${h}" viewBox="0 0 ${w} ${h}" style="position:absolute;inset:0"><g fill="none" stroke="#eaf5ee" stroke-opacity="${op}" stroke-width="1.2"><rect x="5" y="5" width="${w-10}" height="${h-10}" rx="2"/><line x1="${w/2}" y1="5" x2="${w/2}" y2="${h-5}"/><circle cx="${w/2}" cy="${h/2}" r="${Math.min(w,h)*.15}"/><rect x="5" y="${h*.3}" width="${w*.11}" height="${h*.4}"/><rect x="${w-5-w*.11}" y="${h*.3}" width="${w*.11}" height="${h*.4}"/></g></svg>`;
function qr(seed,size=176){const n=25,c=size/n;let h=0;for(const ch of seed)h=(h*31+ch.charCodeAt(0))>>>0;const rnd=()=>{h=(h*1103515245+12345)>>>0;return(h>>>16)&1};const fz=(x,y)=>(x<8&&y<8)||(x>=n-8&&y<8)||(x<8&&y>=n-8);let r='';for(let y=0;y<n;y++)for(let x=0;x<n;x++){if(!fz(x,y)&&rnd())r+=`<rect x="${x*c}" y="${y*c}" width="${c+.2}" height="${c+.2}"/>`}const f=(x,y)=>`<rect x="${x*c}" y="${y*c}" width="${7*c}" height="${7*c}"/><rect x="${(x+1)*c}" y="${(y+1)*c}" width="${5*c}" height="${5*c}" fill="#eaf5ee"/><rect x="${(x+2)*c}" y="${(y+2)*c}" width="${3*c}" height="${3*c}"/>`;return`<svg width="${size}" height="${size}" viewBox="0 0 ${size} ${size}" fill="#06110b" shape-rendering="crispEdges">${r}${f(0,0)}${f(n-7,0)}${f(0,n-7)}</svg>`}

const ST=[
{n:{l:'Complexe El Harrach',ar:'مركب الحراش'},d:{l:'El Harrach, Alger',ar:'الحراش، الجزائر'},km:0.8,r:4.7,rv:143,fmt:'6v6',price:2500,f:['light','ball','roof'],revs:[{a:'Yacine K',r:5,t:"Meilleur terrain d'Alger, gazon impeccable.",tags:['#new_turf','#great_lights'],ago:'2d'},{a:'Hakim M',r:4,t:'ملعب نظيف والإنارة ممتازة في الليل.',tags:['#clean'],ago:'5d'}]},
{n:{l:'Terrain El Biar',ar:'ملعب الأبيار'},d:{l:'El Biar, Alger',ar:'الأبيار، الجزائر'},km:1.4,r:4.3,rv:89,fmt:'8v8',price:3000,f:['light','shower','ref'],revs:[{a:'Redha K',r:4,t:'Grand terrain, vestiaires disponibles.',tags:['#has_showers'],ago:'3d'},{a:'Karim R',r:3,t:'Ballon un peu usé mais terrain correct.',tags:['#old_ball'],ago:'1w'}]},
{n:{l:'Kouba Five',ar:'ملعب القبة'},d:{l:'Kouba, Alger',ar:'القبة، الجزائر'},km:2.1,r:4.9,rv:201,fmt:'5v5',price:2000,f:['light','ball','shower','roof'],revs:[{a:'Sofiane A',r:5,t:'أفضل سعر في المدينة، والعشب جديد.',tags:['#affordable','#new_turf'],ago:'1d'},{a:'Bilal T',r:5,t:'Synthétique parfait, vestiaires nickel.',tags:['#clean'],ago:'4d'}]}
];
const FEAT={light:'light',ball:'ball',shower:'shower',roof:'roof',ref:'whistle'};
const OPEN=[{st:0,time:'20:00',need:3},{st:2,time:'21:00',need:1},{st:1,time:'22:30',need:5}];
const HOURS=[8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23];
const hh=h=>String(h).padStart(2,'0')+':00';
function slotStatus(st,day,h){if(S.pend[`${st}-${day}-${h}`])return'pending';const x=(st*7+day*13+h*29)%11;return x<5?'free':x<9?'booked':'pending'}
const FORM={5:['GK','DEF','DEF','MID','FWD'],6:['GK','DEF','DEF','MID','MID','FWD'],8:['GK','DEF','DEF','DEF','MID','MID','MID','FWD']};
const handle=n=>n.toLowerCase().replace(' ','_');
const FRIENDS=[{n:'Yacine K',h:'yacine_dz'},{n:'Hakim M',h:'hakim_m'},{n:'Sofiane A',h:'sofi_alg'},{n:'Bilal T',h:'bilal_gk'},{n:'Walid D',h:'walid_d'},{n:'Anis R',h:'anis_r'},{n:'Mehdi S',h:'mehdi_s'}];
const MYTEAMS=[{n:'FC El Harrach',m:['yacine_dz','hakim_m','sofi_alg','bilal_gk','walid_d'],fmt:'6v6',rec:'12 – 8',role:'captain'},{n:'Amis du Mercredi',m:['anis_r','mehdi_s','yacine_dz','walid_d','hakim_m','bilal_gk','sofi_alg'],fmt:'8v8',rec:'7 – 5',role:'member'}];
const CITIES=[['alger','Alger','الجزائر'],['oran','Oran','وهران'],['constantine','Constantine','قسنطينة'],['blida','Blida','البليدة'],['annaba','Annaba','عنابة'],['tizi','Tizi Ouzou','تيزي وزو']];
const cityName=k=>{const c=CITIES.find(x=>x[0]===k)||CITIES[0];return S.lang==='ar'?c[2]:c[1]};
function teams(){const size=parseInt(S.match.fmt);const f=FORM[size];const m=S.prefs.mode;const fr=m==='team'?MYTEAMS[S.prefs.team].m:m==='friends'?S.prefs.friends:[];
const pool=[...fr.map(h=>FRIENDS.find(x=>x.h===h)).filter(Boolean),...['Omar B','Ilyes K','Samy L','Adel Z','Riad M','Nabil F','Farid O'].map(n=>({n,h:handle(n)}))];
const pB=['Redha K','Karim B','Chouaib B','Nassim H','Omar S','Raouf G','Ilyes M','Adel Z'];
let me=f.indexOf(S.prefs.pos[0]);if(me<0)me=f.indexOf(S.prefs.pos[1]);if(me<0)me=f.indexOf('MID');let ai=0;
const A=f.map((p,i)=>{if(i===me)return{n:'Amine B',h:'amineB7',p,you:true,c:0,xp:S.xp};const o=pool[ai++];return{...o,p,friend:fr.includes(o.h),c:ai,xp:760+(ai*271)%900}});
const B=f.map((p,i)=>({n:pB[i],h:handle(pB[i]),p,c:i+3,xp:800+(i*313)%880}));
const avg=T=>Math.round(T.reduce((s,x)=>s+x.xp,0)/T.length);return{A,B,size,avgA:avg(A),avgB:avg(B)}}
const ppp=(st,fmt)=>Math.round(ST[st].price/(2*parseInt(fmt))/10)*10;

const POS_E={GK:'🧤',DEF:'🛡️',MID:'🎯',FWD:'⚽',REF:'🟨'};
const RANKS=[['bronze','🥉',0],['silver','🥈',500],['gold','🥇',1000],['elite','💎',2000],['legend','👑',3500]];
const rankOf=p=>{let r=RANKS[0];for(const x of RANKS)if(p>=x[2])r=x;return r};
const posBadge=(p,full=1)=>`<span class="pb pb-${p}">${POS_E[p]} ${t(full?'posf_'+p:'pos_'+p)}</span>`;
const rankBadge=k=>{const r=RANKS.find(x=>x[0]===k);return`<span class="rb rb-${k}">${r[1]} ${t('rank_'+k)}</span>`};
const verBadge=()=>`<span class="vb">✔ ${t('verified')}</span>`;
