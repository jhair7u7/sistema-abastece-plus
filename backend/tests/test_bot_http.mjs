import assert from 'node:assert/strict';

const base = process.env.TEST_API_URL || 'http://127.0.0.1:8001';

async function testBot() {
    console.log("Probando endpoint bot_consultar...");
    const res = await fetch(`${base}/?accion=bot_consultar`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            mensaje: "¿Tienen Coca Cola o gaseosas y cuál es su precio?"
        })
    });

    const text = await res.text();
    console.log("Status:", res.status);
    console.log("Raw Response:\n", text);
    const json = JSON.parse(text);
    console.log("Respuesta recibida:", json);
    assert.equal(json.exito, true);
    assert(typeof json.respuesta === 'string' && json.respuesta.length > 10);
    assert(Array.isArray(json.sugerencias) && json.sugerencias.length > 0);
    console.log("¡Prueba de integración HTTP del bot completada con éxito!");
}

testBot();
