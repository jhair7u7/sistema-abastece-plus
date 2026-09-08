import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import Navbar from './components/Navbar';
import Home from './pages/Home';
import Catalogo from './pages/Catalogo';
import Nosotros from './pages/Nosotros';
import ComoFunciona from './pages/ComoFunciona';

function App() {
  return (
    <Router>
      {/* El Navbar se muestra en todas las rutas */}
      <Navbar />
      
      {/* Aquí definimos qué componente carga en cada URL */}
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/catalogo" element={<Catalogo />} />
        <Route path="/nosotros" element={<Nosotros />} />
        <Route path="/como-funciona" element={<ComoFunciona />} />
      </Routes>
    </Router>
  );
}

export default App;