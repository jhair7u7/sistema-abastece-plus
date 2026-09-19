import { createContext, useContext, useMemo, useState } from "react";

const CartContext = createContext();

export function CartProvider({ children }) {
  const [cart, setCart] = useState([]);

  const addProduct = (product) => {
    setCart((current) => {
      const exist = current.find(
        (item) => item.producto_id === product.producto_id,
      );

      if (exist) {
        return current.map((item) =>
          item.producto_id === product.producto_id
            ? {
                ...item,
                cantidad: item.cantidad + 1,
              }
            : item,
        );
      }

      return [
        ...current,
        {
          ...product,
          cantidad: 1,
        },
      ];
    });
  };

  const decreaseProduct = (id) => {
    setCart((current) => {
      return current
        .map((item) =>
          item.producto_id === id
            ? {
                ...item,
                cantidad: item.cantidad - 1,
              }
            : item,
        )
        .filter((item) => item.cantidad > 0);
    });
  };

  const removeProduct = (id) => {
    setCart((current) => current.filter((item) => item.producto_id !== id));
  };

  const total = useMemo(() => {
    return cart.reduce(
      (sum, item) => sum + Number(item.precio_base_sugerido) * item.cantidad,
      0,
    );
  }, [cart]);

  const units = useMemo(() => {
    return cart.reduce((sum, item) => sum + item.cantidad, 0);
  }, [cart]);

  return (
    <CartContext.Provider
      value={{
        cart,
        setCart,
        clearCart: () => setCart([]),
        addProduct,
        decreaseProduct,
        removeProduct,
        total,
        units,
      }}
    >
      {children}
    </CartContext.Provider>
  );
}

export function useCart() {
  return useContext(CartContext);
}
