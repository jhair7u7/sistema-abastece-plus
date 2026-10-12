<?php
class DireccionBodega {
    public static function validar($data) {
        $address=[];
        foreach (['direccion_exacta'=>200,'distrito'=>60,'provincia'=>50,'departamento'=>50] as $field=>$limit) {
            $value=$data[$field]??(in_array($field,['provincia','departamento'],true)?'Lima':'');
            if(!is_string($value)||mb_strlen(trim($value))<2||mb_strlen(trim($value))>$limit) throw new InvalidArgumentException('Completa una dirección exacta y un distrito válidos.');
            $address[$field]=trim($value);
        }
        $ref=$data['referencia']??'';
        if(!is_string($ref)||mb_strlen($ref)>200) throw new InvalidArgumentException('La referencia admite hasta 200 caracteres.');
        $address['referencia']=trim($ref);
        return $address;
    }
    public static function consultar($db,$id) {
        $q=$db->prepare('SELECT direccion_id,direccion_exacta,distrito,provincia,departamento,referencia FROM direcciones WHERE bodeguero_id=? ORDER BY es_principal DESC,direccion_id DESC LIMIT 1');$q->execute([$id]);return $q->fetch(PDO::FETCH_ASSOC)?:null;
    }
    public static function guardar($db,$id,$address) {
        $current=self::consultar($db,$id);
        if($current && !array_diff_assoc($address,array_intersect_key($current,$address))) return;
        // Nueva versión: los pedidos previos conservan su destino original.
        $q=$db->prepare('UPDATE direcciones SET es_principal=0 WHERE bodeguero_id=?');$q->execute([$id]);
        $district=mb_strtolower($address['distrito']);
        $zone=in_array($district,['los olivos','san martín de porres','san martin de porres','independencia','rímac','rimac','comas','carabayllo','puente piedra','ancón','ancon','santa rosa'],true)?'LIMA_NORTE':(in_array($district,['callao','bellavista','la perla','ventanilla','carmen de la legua'],true)?'CALLAO':'LIMA_CENTRO');
        $q=$db->prepare('INSERT INTO direcciones (bodeguero_id,direccion_exacta,distrito,provincia,departamento,referencia,zona_reparto,es_principal) VALUES (?,?,?,?,?,?,?,1)');$q->execute([$id,$address['direccion_exacta'],$address['distrito'],$address['provincia'],$address['departamento'],$address['referencia'],$zone]);
    }
}
