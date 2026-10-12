const API_URL = import.meta.env?.VITE_API_URL || '/api';

export async function apiRequest(action, options = {}) {
  const { method = 'GET', body, token, params, timeoutMs = 0 } = options;
  const isFormData = body instanceof FormData;
  const query = new URLSearchParams({ accion: action, ...params });
  const controller = timeoutMs > 0 ? new AbortController() : null;
  const timer = controller ? window.setTimeout(() => controller.abort(), timeoutMs) : null;
  try {
  const response = await fetch(`${API_URL}/?${query}`, {
    method,
    ...(controller ? { signal: controller.signal } : {}),
    headers: {
      ...(!isFormData ? { 'Content-Type': 'application/json' } : {}),
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    ...(body ? { body: isFormData ? body : JSON.stringify(body) } : {}),
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
    if (response.status === 401 && token) {
      window.dispatchEvent(new Event('auth:unauthorized'));
    }
    throw error;
  }

  return data;
  } catch (error) {
    if (controller?.signal.aborted) throw new Error('La solicitud tardó demasiado. Inténtalo otra vez; los controles se han habilitado.', { cause: error });
    throw error;
  } finally { if (timer !== null) window.clearTimeout(timer); }
}
