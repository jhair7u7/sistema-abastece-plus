<?php
// Only shop addresses and road coordinates are sent to the configured providers.
class TransportMapService {
    private $db;
    private $fetch;
    public function __construct($db, $fetch=null) { $this->db=$db; $this->fetch=$fetch; }
    private function query($sql,$params=[]) { $q=$this->db->prepare($sql);$q->execute($params);return $q; }
    public static function normalized($value) { return trim(preg_replace('/\s+/u',' ',strtr(mb_strtolower($value,'UTF-8'),['á'=>'a','é'=>'e','í'=>'i','ó'=>'o','ú'=>'u','ü'=>'u','ñ'=>'n']))); }
    public static function address($row) {
        $parts=[];
        foreach (explode(',',implode(', ',array_filter([$row['direccion_exacta']??$row['direccion_entrega']??'', $row['distrito']??'', $row['provincia']??'', $row['departamento']??'', 'Perú']))) as $part) {
            $part=trim($part);$key=self::normalized($part);
            if ($part && !in_array($key,array_map([self::class,'normalized'],$parts),true)) $parts[]=$part;
        }
        return implode(', ',$parts);
    }
    private function request($url) {
        if ($this->fetch) return ($this->fetch)($url);
        $ch=curl_init($url);curl_setopt_array($ch,[CURLOPT_RETURNTRANSFER=>true,CURLOPT_TIMEOUT=>8,CURLOPT_CONNECTTIMEOUT=>3,CURLOPT_USERAGENT=>'AbastecePlus/1.0 (shop delivery planner)']);
        $raw=curl_exec($ch);$code=curl_getinfo($ch,CURLINFO_HTTP_CODE);curl_close($ch);
        return $code===200 && $raw ? json_decode($raw,true) : null;
    }
    private function cached($hash,$minutes) { $raw=$this->query('SELECT resultados FROM mapa_busquedas WHERE consulta_hash=? AND creado_en>DATE_SUB(NOW(),INTERVAL '.(int)$minutes.' MINUTE)',[$hash])->fetchColumn();return $raw?json_decode($raw,true):null; }
    private function cache($hash,$data) { $this->query('INSERT INTO mapa_busquedas (consulta_hash,resultados) VALUES (?,?) ON DUPLICATE KEY UPDATE resultados=VALUES(resultados),creado_en=NOW()',[$hash,json_encode($data)]); }
    public static function photonPoint($features,$address) {
        $needle=self::normalized(explode(',',$address)[0]);
        $words=preg_split('/[^a-z]+/',preg_replace('/\b(av|avenida|calle|jr|jiron|n|numero)\b/','',$needle),-1,PREG_SPLIT_NO_EMPTY);
        preg_match('/\b(\d+[a-z]?)\b/i',$needle,$number);
        foreach ($features as $place) {
            $p=$place['properties']??[];$coords=$place['geometry']['coordinates']??[];
            if (count($coords)<2 || !is_numeric($coords[0]) || !is_numeric($coords[1])) continue;
            // Restrict the Lima/Callao distribution area; never accept a same-named street abroad.
            if ($coords[0]<-77.5 || $coords[0]>-76.5 || $coords[1]<-12.6 || $coords[1]>-11.4) continue;
            $street=self::normalized($p['street']??$p['name']??'');
            if (!$words || count(array_filter($words,fn($w)=>strlen($w)>2 && !str_contains($street,$w)))>0) continue;
            $exact=isset($number[1],$p['housenumber']) && self::normalized($p['housenumber'])===$number[1];
            if (isset($p['housenumber']) && !$exact) continue;
            if (!$exact && ($p['type']??'')!=='street' && ($p['osm_key']??'')!=='highway') continue;
            return ['latitud'=>(float)$coords[1],'longitud'=>(float)$coords[0],'precision'=>$exact?'INMUEBLE':'CALLE'];
        }
        return null;
    }
    public function destination(&$row,$persist=true) {
        $address=self::address($row);$row['direccion_entrega']=$address;$row['destino_direccion']=$address;
        $row['mapa_estado']='PENDIENTE';$row['mapa_mensaje']='Localizando la dirección de la tienda…';
        $photon=rtrim(getenv('PHOTON_URL')?:'','/');$nominatim=rtrim(getenv('GEOCODING_URL')?:'','/');
        $hash=hash('sha256','destination-v3|'.($photon?:$nominatim).'|'.self::normalized($address));
        $entry=$this->cached($hash,43200);
        if (is_array($entry) && isset($entry['retry_at']) && $entry['retry_at']<time()) $entry=null;
        if ($address && ($row['mapa_direccion']??null)===$address && $row['destino_lat']!==null && $row['destino_lng']!==null && $row['geometria']) {
            $row['mapa_estado']='LISTO';$row['mapa_precision']=$entry['point']['precision']??'SIN_CONFIRMAR';
            $row['mapa_mensaje']=$row['mapa_precision']==='INMUEBLE'?'Ubicación del inmueble encontrada.':'Ubicación aproximada; el proveedor no confirma la puerta de la tienda.';return;
        }
        foreach (['destino_lat','destino_lng','geometria','distancia_m','duracion_s'] as $key) $row[$key]=null;
        if (preg_match('/\bdemo\b|direccion_exacta/i',$address)) { $row['mapa_mensaje']='Esta dirección es de demostración. El bodeguero debe registrar la dirección real de su tienda.';return; }
        if (!$photon && !$nominatim) { $row['mapa_mensaje']='La localización automática requiere autorizar y configurar el proveedor de direcciones.';return; }
        if ($entry===null) {
            $lock=fopen(sys_get_temp_dir().'/abastece-geocode.lock','c+');
            if (!$lock || !flock($lock,LOCK_EX|LOCK_NB)) { if ($lock) fclose($lock);return; }
            try {
                $previous=(float)stream_get_contents($lock);
                if (!$this->fetch && microtime(true)-$previous<15) return;
                ftruncate($lock,0);rewind($lock);fwrite($lock,(string)microtime(true));fflush($lock);
                if ($photon) {
                    $data=$this->request($photon.'/api/?'.http_build_query(['q'=>$address,'limit'=>5,'bbox'=>'-77.5,-12.6,-76.5,-11.4','lat'=>-12.05,'lon'=>-77.05]));
                    $point=is_array($data) ? self::photonPoint($data['features']??[],$address) : null;
                } else {
                    $data=$this->request($nominatim.'/search?'.http_build_query(['q'=>$address,'format'=>'jsonv2','addressdetails'=>1,'countrycodes'=>'pe','limit'=>1]));
                    $p=$data[0]??null;$point=isset($p['address']['house_number'],$p['lat'],$p['lon']) ? ['latitud'=>(float)$p['lat'],'longitud'=>(float)$p['lon'],'precision'=>'INMUEBLE'] : null;
                }
                $entry=['point'=>$point,'retry_at'=>$point?time()+2592000:time()+(is_array($data)?86400:3600),'service_error'=>!is_array($data)];$this->cache($hash,$entry);
            } finally {flock($lock,LOCK_UN);fclose($lock);}
        }
        $point=$entry['point']??null;
        if (!$point) { $row['mapa_mensaje']=!empty($entry['service_error'])?'El servicio de localización no respondió. Se reintentará más tarde.':'No se encontró esa dirección. El bodeguero debe revisar la calle, número y distrito.';return; }
        $a=-12.0491321;$b=-77.1145179;$lat=$point['latitud'];$lng=$point['longitud'];
        $route=$this->road([[$b,$a],[$lng,$lat]]);$geometry=$route['geometry']??null;
        $origin='Av. Argentina N.º 2833, Zona Industrial, Callao, Perú';
        if ($geometry && $persist) $this->query('INSERT INTO rutas_mapa (ruta_id,origen_direccion,destino_direccion,origen_lat,origen_lng,destino_lat,destino_lng,geometria,distancia_m,duracion_s) VALUES (?,?,?,?,?,?,?,?,?,?) ON DUPLICATE KEY UPDATE origen_direccion=VALUES(origen_direccion),destino_direccion=VALUES(destino_direccion),origen_lat=VALUES(origen_lat),origen_lng=VALUES(origen_lng),destino_lat=VALUES(destino_lat),destino_lng=VALUES(destino_lng),geometria=VALUES(geometria),distancia_m=VALUES(distancia_m),duracion_s=VALUES(duracion_s)',[$row['ruta_id'],$origin,$address,$a,$b,$lat,$lng,json_encode($geometry),$route['distance'],$route['duration']]);
        $row=array_merge($row,['origen_direccion'=>$origin,'origen_lat'=>$a,'origen_lng'=>$b,'destino_lat'=>$lat,'destino_lng'=>$lng,'geometria'=>$geometry?json_encode($geometry):null,'distancia_m'=>$route['distance']??null,'duracion_s'=>$route['duration']??null,'mapa_estado'=>'LISTO','mapa_precision'=>$point['precision'],'mapa_mensaje'=>$point['precision']==='INMUEBLE'?'Ubicación del inmueble encontrada.':'Ubicación aproximada de la calle. El proveedor no tiene registrado el número exacto de la tienda.']);
    }
    public function road($points) {
        $base=rtrim(getenv('ROUTING_URL')?:'https://router.project-osrm.org','/');
        $hash=hash('sha256','road-v3|'.$base.'|'.json_encode($points));$entry=$this->cached($hash,15);
        if ($entry!==null) return $entry['route']??null;
        $data=$this->request($base.'/route/v1/driving/'.implode(';',array_map(fn($p)=>implode(',',$p),$points)).'?overview=full&geometries=geojson&steps=true');
        $route=($data['code']??'')==='Ok'?$data['routes'][0]??null:null;
        $this->cache($hash,['route'=>$route]);return $route;
    }
    public static function stops($rows) {
        $active=array_values(array_filter($rows,fn($r)=>!in_array($r['estado_pedido'],['CANCELADO','ENTREGADO'],true) && empty($r['conformidad_completa']) && in_array($r['estado_entrega'],['ASIGNADO','EN_TRAYECTO'],true)));
        usort($active,fn($a,$b)=>(($a['estado_entrega']==='EN_TRAYECTO'?0:1)<=>($b['estado_entrega']==='EN_TRAYECTO'?0:1)) ?: ((int)$a['ruta_id']<=>(int)$b['ruta_id']));
        return $active;
    }
    public function itinerary($rows) {
        $stops=self::stops($rows);$points=[[-77.1145179,-12.0491321]];$located=[];$pending=[];
        foreach ($stops as $r) {
            if ($r['destino_lat']===null || $r['destino_lng']===null) {$pending[]=$r['codigo_guia'];continue;}
            $points[]=[(float)$r['destino_lng'],(float)$r['destino_lat']];$located[]=['ruta_id'=>$r['ruta_id'],'codigo'=>$r['codigo_guia'],'direccion'=>$r['destino_direccion'],'precision'=>$r['mapa_precision']??'SIN_CONFIRMAR'];
        }
        $result=['paradas'=>$located,'pendientes'=>$pending,'tramos'=>[],'distancia_m'=>null,'duracion_s'=>null];
        if (!$located) return $result;
        $route=$this->road($points);if (!$route) return $result;
        foreach ($route['legs']??[] as $index=>$leg) {
            $coords=[];foreach ($leg['steps']??[] as $step) foreach ($step['geometry']['coordinates']??[] as $c) if (end($coords)!==$c) $coords[]=$c;
            if ($coords && isset($located[$index])) $result['tramos'][]=['ruta_id'=>$located[$index]['ruta_id'],'geometria'=>['type'=>'LineString','coordinates'=>$coords]];
        }
        $result['distancia_m']=$route['distance'];$result['duracion_s']=$route['duration'];return $result;
    }
}
