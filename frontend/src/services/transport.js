export const routeColors = ["#6718df", "#247aff", "#f5a20a", "#f12640"];
// Punto público del almacén localizado en OpenStreetMap y dirección indicada por el usuario.
export const warehouse = {
  address: "Av. Argentina N.º 2833, Zona Industrial, Callao, Perú",
  lat: -12.0491321,
  lng: -77.1145179,
};
export function statusOf(route) {
  if (route.estado_pedido === "CANCELADO") return "CANCELADO";
  if (route.estado_pedido === "ENTREGADO") return "ENTREGADO";
  return route.estado_entrega === "EN_TRAYECTO"
    ? "EN_RUTA"
    : route.estado_entrega === "ASIGNADO"
      ? "PENDIENTE"
      : route.estado_entrega;
}
export const statusLabels = {
  ENTREGADO: "Entregado",
  EN_RUTA: "En ruta",
  PENDIENTE: "Pendiente",
};
export function routeMetrics(rows) {
  return ["ENTREGADO", "EN_RUTA", "PENDIENTE", "CANCELADO"].map((status) => {
    const count = rows.filter((row) => statusOf(row) === status).length;
    return {
      status,
      count,
      percentage: rows.length ? Math.round((count / rows.length) * 100) : 0,
    };
  });
}
export function hasCoordinates(row) {
  return ["origen_lat", "origen_lng", "destino_lat", "destino_lng"].every(
    (key) =>
      row[key] !== null &&
      row[key] !== undefined &&
      row[key] !== "" &&
      Number.isFinite(Number(row[key])) &&
      Math.abs(Number(row[key])) <= (key.endsWith("lat") ? 90 : 180),
  );
}
export function pendingRoute(row) {
  return (
    !!row &&
    !["ENTREGADO", "CANCELADO"].includes(row.estado_pedido) &&
    !Number(row.conformidad_completa) &&
    ["ASIGNADO", "EN_TRAYECTO"].includes(row.estado_entrega)
  );
}
export function freshGps(row, now = Date.now()) {
  const timestamp = Number(row.capturado_ms);
  return (
    timestamp > 0 &&
    now - timestamp <= 120000 &&
    now >= timestamp - 10000 &&
    row.latitud != null &&
    row.longitud != null &&
    Number.isFinite(Number(row.latitud)) &&
    Number.isFinite(Number(row.longitud)) &&
    Math.abs(Number(row.latitud)) <= 90 &&
    Math.abs(Number(row.longitud)) <= 180
  );
}
export const timeOf = (value) => (value ? String(value).slice(11, 16) : "—");
export const dateLabel = (value) =>
  value
    ? new Date(String(value).replace(" ", "T")).toLocaleString("es-PE", {
        dateStyle: "medium",
        timeStyle: "short",
      })
    : "Sin horario registrado";

export function routeClosedReason(row) {
  if (!row) return "";
  if (row.estado_pedido === "CANCELADO") return "El pedido está cancelado.";
  if (row.estado_pedido === "ENTREGADO" && row.estado_entrega !== "ENTREGADO")
    return "La ruta cambió de estado, pero la compra sigue ENTREGADO. Para repetir una prueba hay que reiniciar también la compra y las fechas de entrega.";
  if (row.estado_entrega === "ENTREGADO" || row.estado_pedido === "ENTREGADO")
    return "Esta entrega ya está registrada. Su recorrido está cerrado.";
  if (Number(row.conformidad_completa) === 1)
    return "Todos los productos ya tienen conformidad. El recorrido está cerrado.";
  return "";
}
