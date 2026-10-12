import { useEffect, useRef, useState } from 'react';
import L from 'leaflet';
import { Layers3, LocateFixed } from 'lucide-react';
import { freshGps, pendingRoute, hasCoordinates, routeColors, warehouse } from '../services/transport';

const icon = (color, label, vehicle = false) => L.divIcon({ className: 'route-map-marker', html: `<span style="background:${color}" class="${vehicle ? 'is-vehicle' : ''}">${label}</span>`, iconSize: [32, 32], iconAnchor: [16, 16] });

export default function RouteMap({ routes, itinerary, selectedId, onSelect, onPick, small = false, tracking = false }) {
  const host = useRef(null), instance = useRef(null), group = useRef(null), signature = useRef('');
  const [mapError, setMapError] = useState('');
  const [tone, setTone] = useState(() => {
    try { const saved = localStorage.getItem('abastece.transport.mapTone'); return ['standard', 'light', 'dark'].includes(saved) ? saved : 'light'; }
    catch { return 'light'; }
  });
  const changeTone = value => { setTone(value); try { localStorage.setItem('abastece.transport.mapTone', value); } catch { /* El estilo funciona aunque el navegador impida guardar preferencias. */ } };
  useEffect(() => {
    const map = L.map(host.current, { zoomControl: true, scrollWheelZoom: !small }).setView([warehouse.lat, warehouse.lng], 12);
    const tiles = L.tileLayer(import.meta.env.VITE_MAP_TILES_URL || 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', { maxZoom: 19, referrerPolicy: 'strict-origin-when-cross-origin', attribution: import.meta.env.VITE_MAP_TILES_ATTRIBUTION || '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors' });
    let failed = 0;
    tiles.on('tileerror', () => { if (++failed >= 3) setMapError('El proveedor de mapas no respondió o denegó las imágenes. Los datos de tus rutas se conservan.'); });
    tiles.on('tileload', () => { failed = 0; setMapError(''); });
    tiles.addTo(map);
    instance.current = map;
    group.current = L.featureGroup().addTo(map);
    const observer = new ResizeObserver(() => map.invalidateSize());
    observer.observe(host.current);
    return () => { observer.disconnect(); map.remove(); instance.current = null; signature.current = ''; };
  }, [small]);
  useEffect(() => {
    const map = instance.current;
    const pick = e => onPick?.(e.latlng);
    if (onPick) map.on('click', pick);
    return () => { map.off('click', pick); };
  }, [onPick]);
  useEffect(() => {
    const map = instance.current, layers = group.current;
    if (!map || !layers) return;
    layers.clearLayers();
    if (!routes.some(hasCoordinates)) {
      const label = document.createElement('span'); label.textContent = warehouse.address;
      L.marker([warehouse.lat, warehouse.lng], { icon: icon(routeColors[0], '⌂') }).bindTooltip(label).addTo(layers);
    }
    const bounds = [];
    routes.forEach((row, index) => {
      const color = routeColors[(Number(row.ruta_id) - 1) % routeColors.length];
      const isSelected = Number(selectedId) === Number(row.ruta_id);
      if (freshGps(row) && pendingRoute(row) && row.estado_entrega === 'EN_TRAYECTO') {
        const position = [Number(row.latitud), Number(row.longitud)];
        bounds.push(position);
        const gpsPopup = document.createElement('div'); gpsPopup.textContent = `${row.codigo_guia} · GPS actualizado · precisión ${Math.round(row.precision_m)} m`;
        L.marker(position, { icon: icon(color, '🚚', true) }).bindPopup(gpsPopup).addTo(layers);
        if (isSelected && tracking) map.panTo(position, { animate: true });
      }
      if (!hasCoordinates(row)) return;
      const origin = [Number(row.origen_lat), Number(row.origen_lng)], destination = [Number(row.destino_lat), Number(row.destino_lng)];
      bounds.push(origin, destination);
      const popup = document.createElement('div');
      popup.textContent = `${row.codigo_guia} · ${row.destino_direccion}`;
      const originLabel = document.createElement('span'); originLabel.textContent = row.origen_direccion;
      L.marker(origin, { icon: icon(color, '⌂') }).bindTooltip(originLabel).addTo(layers);
      const stopNumber=itinerary?.paradas?.findIndex(stop=>Number(stop.ruta_id)===Number(row.ruta_id));
      popup.textContent += row.mapa_precision === 'INMUEBLE' ? ' · inmueble localizado' : ' · ubicación aproximada de la calle';
      L.marker(destination, { icon: icon(color, String(stopNumber >= 0 ? stopNumber + 1 : index + 1)) }).bindPopup(popup).on('click', () => onSelect?.(row.ruta_id)).addTo(layers);
      if (pendingRoute(row) && row.geometria?.type === 'LineString' && !itinerary?.tramos?.some(leg=>Number(leg.ruta_id)===Number(row.ruta_id))) {
        const coords = row.geometria.coordinates.filter(point => point.length >= 2 && point.every(Number.isFinite)).map(([lng, lat]) => [lat, lng]);
        L.polyline(coords, { color, weight: isSelected ? 6 : 4, opacity: isSelected ? 1 : .45 }).on('click', () => onSelect?.(row.ruta_id)).addTo(layers);
      }

    });
    itinerary?.tramos?.forEach(leg => {
      if (!routes.some(row => Number(row.ruta_id) === Number(leg.ruta_id) && pendingRoute(row)) || leg.geometria?.type !== 'LineString') return;
      const coords=leg.geometria.coordinates.filter(point=>point.length>=2 && point.every(Number.isFinite)).map(([lng,lat])=>[lat,lng]);
      const color=routeColors[(Number(leg.ruta_id)-1)%routeColors.length];
      L.polyline(coords,{color,weight:Number(selectedId)===Number(leg.ruta_id)?6:4,opacity:.9}).on('click',()=>onSelect?.(leg.ruta_id)).addTo(layers);
    });
    const key = routes.filter(hasCoordinates).map(row => `${row.ruta_id}:${row.origen_lat}:${row.origen_lng}:${row.destino_lat}:${row.destino_lng}`).join('|') + selectedId;
    if (bounds.length && signature.current !== key) { map.fitBounds(bounds, { padding: [small ? 20 : 60, 35], maxZoom: 15 }); signature.current = key; }
  }, [routes, itinerary, selectedId, onSelect, small, tracking]);
  const center = () => { if (group.current?.getLayers().length) instance.current.fitBounds(group.current.getBounds(), { padding: [30, 30], maxZoom: 15 }); };
  return <div className={`transport-map map-tone-${tone} ${small ? 'small' : ''}`}><div ref={host} className="transport-map-canvas" aria-label={small ? 'Mapa del recorrido seleccionado' : 'Mapa de mis rutas'} />
    {!small && <><div className="transport-map-legend"><strong>Mis rutas asignadas</strong>{routes.map(row => <button key={row.ruta_id} onClick={() => onSelect(row.ruta_id)} className={Number(selectedId) === Number(row.ruta_id) ? 'selected' : ''}><i style={{ background: routeColors[(Number(row.ruta_id) - 1) % 4] }} />{row.codigo_guia}<span>{Number(selectedId) === Number(row.ruta_id) ? '✓' : ''}</span></button>)}</div><button className="transport-map-center" onClick={center} aria-label="Centrar rutas"><LocateFixed size={20} /></button></>}
    {!routes.some(hasCoordinates) && <p className="transport-map-message">El destino se obtiene del bodeguero. El recorrido aparecerá cuando su dirección pueda localizarse.</p>}
    {mapError && <p className="transport-map-message" role="alert">{mapError}</p>}
    {!small && <label className="transport-map-style"><Layers3 size={17} /><select aria-label="Tonalidad del mapa" value={tone} onChange={e => changeTone(e.target.value)}><option value="standard">Original</option><option value="light">Claro</option><option value="dark">Oscuro</option></select></label>}
  </div>;
}
