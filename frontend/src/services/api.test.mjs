import {test} from 'node:test';
import assert from 'node:assert/strict';
import {apiRequest} from './api.js';
test('Una solicitud colgada se cancela, termina y permite reintentar',async()=>{
 const originalFetch=globalThis.fetch, originalWindow=globalThis.window;
 let timers=0;
 globalThis.window={setTimeout:(fn,ms)=>{timers++;return setTimeout(fn,ms);},clearTimeout:id=>{timers--;clearTimeout(id);}};
 try {
  globalThis.fetch=(_url,{signal})=>new Promise((_resolve,reject)=>signal.addEventListener('abort',()=>reject(new Error('abort'))));
  await assert.rejects(apiRequest('preparar_recorrido',{timeoutMs:5}),/tardó demasiado/);
  assert.equal(timers,0);
  globalThis.fetch=async()=>({ok:true,json:async()=>({recorrido_listo:true})});
  assert.equal((await apiRequest('preparar_recorrido',{timeoutMs:100})).recorrido_listo,true);
  assert.equal(timers,0);
 } finally { globalThis.fetch=originalFetch;globalThis.window=originalWindow; }
});
