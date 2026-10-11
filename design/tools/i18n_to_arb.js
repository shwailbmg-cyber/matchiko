// Converts the prototype's I18N string maps into Flutter ARB files.
// Usage: node design/tools/i18n_to_arb.js design/prototype app/lib/l10n
const fs=require('fs'),vm=require('vm'),path=require('path');
const [src,out]=process.argv.slice(2);
const ctx={window:{}};vm.createContext(ctx);
for(const f of ['matchiko-i18n.js','matchiko-i18n2.js','matchiko-i18n3.js']){
  let code=fs.readFileSync(path.join(src,f),'utf8');
  vm.runInContext(code+';var I18N=window.I18N||I18N;',ctx);
  if(!ctx.window.I18N&&ctx.I18N)ctx.window.I18N=ctx.I18N;
  ctx.I18N=ctx.window.I18N;
}
const I=ctx.window.I18N;
const RESERVED={in:'youreIn'};
const camel=k=>RESERVED[k]??k.replace(/_([a-zA-Z0-9])/g,(_,c)=>c.toUpperCase());
const keys=Object.keys(I.en);
const seen=new Map();
for(const lang of ['en','fr','ar']){
  const file=path.join(out,`app_${lang}.arb`);
  // Keep app-only keys (added in Flutter, not in the prototype).
  const old=fs.existsSync(file)?JSON.parse(fs.readFileSync(file,'utf8')):{};
  const o={'@@locale':lang};
  for(const k of keys){
    const ck=camel(k);
    if(seen.has(ck)&&seen.get(ck)!==k)throw new Error('collision '+k);
    seen.set(ck,k);
    const v=I[lang][k]??I.en[k];
    o[ck]=v;
    if(lang==='en'){
      const ph=[...new Set([...v.matchAll(/\{(\w+)\}/g)].map(m=>m[1]))];
      if(ph.length)o['@'+ck]={placeholders:Object.fromEntries(ph.map(p=>[p,{type:'String'}]))};
    }
  }
  for(const k in old)if(!(k in o))o[k]=old[k];
  fs.writeFileSync(file,JSON.stringify(o,null,2)+'\n');
}
const missing=l=>keys.filter(k=>I[l][k]===undefined);
console.log('keys',keys.length,'missing fr',missing('fr'),'missing ar',missing('ar'));
