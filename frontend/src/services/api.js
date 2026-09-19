const API_URL = import.meta.env.VITE_API_URL || '/api';

export async function apiRequest(action, options = {}) {
  const { method = 'GET', body, token, params } = options;
  const query = new URLSearchParams({ accion: action, ...params });
  const response = await fetch(`${API_URL}/?${query}`, {
    method,
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    ...(body ? { body: JSON.stringify(body) } : {}),
  });

  let data;
  try {
    data = await response.json();
  } catch {
    data = { mensaje: 'El servidor devolvió una respuesta no válida.' };
  }

  if (!response.ok) {
    const error = new Error(data.mensaje || 'No se pudo completar la solicitud.');
    error.status = response.status;
    throw error;
  }

  return data;
}
