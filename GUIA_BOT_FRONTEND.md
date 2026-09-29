# Guía de Conexión del Asistente Virtual (Bot IA) - Para el Equipo Frontend

Esta guía explica detalladamente cómo consumir el endpoint del Asistente Virtual IA ("Abas el capibara") de **Abastece+**, implementado en el backend con **Google Gemini** y **sincronización en tiempo real con la base de datos MySQL**.

---

## 1. Información del Endpoint

| Parámetro | Detalle |
| :--- | :--- |
| **URL** | `POST http://localhost:8000/?accion=bot_consultar` *(o `/api/?accion=bot_consultar` con Vite)* |
| **Método** | `POST` |
| **Headers** | `Content-Type: application/json` |
| **Autenticación** | **Opcional**. Si el usuario ha iniciado sesión (ej. Bodeguero), puedes enviar `Authorization: Bearer <TOKEN>` para que el bot conozca sus pedidos en tiempo real. Si no hay sesión, el bot responderá como visitante público. |

---

## 2. Estructura de la Petición (Request Body)

Envía un JSON con el mensaje del usuario y, opcionalmente, el historial reciente de la conversación:

```json
{
  "mensaje": "¿Tienen Coca Cola y cuánto cuesta?",
  "historial": [
    {
      "rol": "user",
      "texto": "Hola"
    },
    {
      "rol": "bot",
      "texto": "Hola. Soy Abas el capibara, asistente de Abastece+. ¿En qué puedo ayudarte?"
    }
  ]
}
```

### Parámetros:
- `mensaje` *(obligatorio, string)*: El texto escrito por el usuario en el chat.
- `historial` *(opcional, array)*: Lista de mensajes anteriores. El backend conserva automáticamente los mensajes relevantes para mantener el hilo sin sobrecargar la solicitud.

---

## 3. Estructura de la Respuesta (Response JSON)

El backend responde con código de estado HTTP `200 OK`:

```json
{
  "exito": true,
  "respuesta": "Hola. Sí, tenemos disponible Coca Cola (Fardo x 12 und) a S/ 34.00 con stock disponible en almacén.",
  "sugerencias": [
    "¿Tienen Aceite Primor o Abarrotes?",
    "¿Cuánto es el pedido mínimo?",
    "¿Cuánto demora la entrega?"
  ]
}
```

### Campos devueltos:
- `exito` *(boolean)*: `true` si la consulta fue procesada con éxito.
- `respuesta` *(string)*: Texto de respuesta generado por la IA en formato Markdown minimalista (viñetas con guiones y negritas simples).
- `sugerencias` *(array de strings)*: Preguntas frecuentes generadas dinámicamente según el contexto, útiles para renderizar botones de respuesta rápida ("chips").

---

## 4. Código Listo para Usar en el Frontend (Vanilla JS / TypeScript)

Puedes crear un servicio en `src/services/botService.js` (o `.ts`):

```javascript
/**
 * Envía una consulta al Asistente Virtual IA de Abastece+
 * @param {string} mensaje - Pregunta o mensaje del usuario
 * @param {Array} historial - Historial previo [{ rol: 'user'|'bot', texto: string }]
 * @param {string|null} token - Token JWT del usuario logueado (opcional)
 */
export async function consultarBot(mensaje, historial = [], token = null) {
  try {
    const headers = {
      'Content-Type': 'application/json'
    };

    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    const baseUrl = import.meta.env.VITE_API_URL || 'http://localhost:8000';

    const response = await fetch(`${baseUrl}/?accion=bot_consultar`, {
      method: 'POST',
      headers,
      body: JSON.stringify({
        mensaje: mensaje.trim(),
        historial
      })
    });

    if (!response.ok) {
      throw new Error(`Error en el servidor: ${response.status}`);
    }

    const data = await response.json();
    return data; // { exito: true, respuesta: "...", sugerencias: [...] }
  } catch (error) {
    console.error("Error al consultar el bot:", error);
    return {
      exito: false,
      respuesta: "Lo siento, hubo un problema al conectar con el asistente. Por favor intenta de nuevo en unos momentos.",
      sugerencias: ["Ver catálogo", "¿Cuáles son los métodos de pago?"]
    };
  }
}
```

---

## 5. Ejemplo de Integración en Componente React

```jsx
import React, { useState } from 'react';
import { consultarBot } from '../services/botService';

export function ChatBotWidget() {
  const [mensajes, setMensajes] = useState([
    { rol: 'bot', texto: 'Hola. Soy Abas el capibara, tu asistente en Abastece+. ¿En qué puedo ayudarte hoy?' }
  ]);
  const [input, setInput] = useState('');
  const [cargando, setCargando] = useState(false);
  const [sugerencias, setSugerencias] = useState([
    '¿Qué productos tienen?',
    '¿Cómo hago un pedido?',
    '¿Cuáles son las formas de pago?'
  ]);

  const enviarMensaje = async (textoAEnviar) => {
    const texto = textoAEnviar || input;
    if (!texto.trim() || cargando) return;

    const nuevoHistorial = [...mensajes, { rol: 'user', texto }];
    setMensajes(nuevoHistorial);
    setInput('');
    setCargando(true);

    const token = localStorage.getItem('token') || null;
    const data = await consultarBot(texto, nuevoHistorial, token);

    setMensajes([...nuevoHistorial, { rol: 'bot', texto: data.respuesta }]);
    if (data.sugerencias && data.sugerencias.length > 0) {
      setSugerencias(data.sugerencias);
    }
    setCargando(false);
  };

  return (
    <div className="chat-container">
      <div className="chat-messages">
        {mensajes.map((m, idx) => (
          <div key={idx} className={`mensaje ${m.rol}`}>
            <strong>{m.rol === 'bot' ? 'Abas' : 'Tú'}:</strong>
            <p>{m.texto}</p>
          </div>
        ))}
        {cargando && <p className="escribiendo">Abas está respondiendo...</p>}
      </div>

      {/* Sugerencias rápidas */}
      <div className="chat-sugerencias">
        {sugerencias.map((sug, i) => (
          <button key={i} onClick={() => enviarMensaje(sug)} disabled={cargando}>
            {sug}
          </button>
        ))}
      </div>

      {/* Formulario */}
      <form onSubmit={(e) => { e.preventDefault(); enviarMensaje(); }}>
        <input
          type="text"
          value={input}
          placeholder="Escribe tu consulta aquí..."
          onChange={(e) => setInput(e.target.value)}
          disabled={cargando}
        />
        <button type="submit" disabled={cargando}>Enviar</button>
      </form>
    </div>
  );
}
```

---

## 6. Características y Seguridad Garantizada

1. **Datos en Tiempo Real (Cero Alucinaciones):**  
   El backend consulta directamente `vista_catalogo_disponible` en cada solicitud. Cualquier cambio en la base de datos se refleja de inmediato.
2. **Consultas de Pedidos Personalizados:**  
   Si se envía el token de un bodeguero, Abas puede detallar el estado de sus pedidos recientes. También reconoce códigos como `COM-2026-0001`.
3. **Estilo Minimalista:**  
   Abas no utiliza emojis y mantiene un tono directo, sobrio y profesional.
