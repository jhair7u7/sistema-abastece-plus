<?php
class FavoritoController {
 public function __construct(private PDO $db) {}
 public static function listar(PDO $db,int $owner):array {
  $s=$db->prepare('SELECT v.*,v.precio_unitario precio_base_sugerido,v.stock_total stock_disponible,v.imagen_principal imagen_url FROM productos_favoritos f JOIN vista_catalogo_disponible v ON v.producto_id=f.producto_id WHERE f.bodeguero_id=? ORDER BY f.fecha_registro DESC,f.producto_id DESC');
  $s->execute([$owner]);return $s->fetchAll();
 }
 public function execute(string $action,string $method,array $data):bool {
  if(!in_array($action,['listar_favoritos','guardar_favorito'],true))return false;
  $user=AuthMiddleware::permitirRoles(['BODEGUERO']);
  if($method!==($action==='guardar_favorito'?'POST':'GET')){Response::json(['mensaje'=>'Método no permitido'],405);return true;}
  try {
   if($action==='listar_favoritos'){Response::json(['favoritos'=>self::listar($this->db,(int)$user['id'])]);return true;}
   $id=filter_var($data['producto_id']??null,FILTER_VALIDATE_INT);
   if(!$id||$id<1||!isset($data['favorito'])||!is_bool($data['favorito'])){Response::json(['mensaje'=>'Producto o selección no válidos'],422);return true;}
   $s=$this->db->prepare('SELECT producto_id FROM productos WHERE producto_id=?');$s->execute([$id]);
   if(!$s->fetchColumn()){Response::json(['mensaje'=>'El producto no existe'],404);return true;}
   $sql=$data['favorito']?'INSERT INTO productos_favoritos (bodeguero_id,producto_id) VALUES (?,?) ON DUPLICATE KEY UPDATE producto_id=VALUES(producto_id)':'DELETE FROM productos_favoritos WHERE bodeguero_id=? AND producto_id=?';
   $this->db->prepare($sql)->execute([(int)$user['id'],$id]);
   Response::json(['producto_id'=>$id,'favorito'=>$data['favorito']]);
  }catch(PDOException $e){Response::json(['mensaje'=>'No se pudieron guardar o consultar tus favoritos.'],500);}
  return true;
 }
}
