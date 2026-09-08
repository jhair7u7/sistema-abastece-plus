import "./Nosotros.css";


export default function Nosotros(){


const values=[

{
title:"Conexión",
text:"Unimos bodegas y proveedores en una misma plataforma."
},

{
title:"Confianza",
text:"Información clara para tomar mejores decisiones."
},

{
title:"Innovación",
text:"Tecnología aplicada al abastecimiento diario."
}


];



return(


<section className="about-page">


<div className="about-container">



{/* HISTORIA */}


<div className="about-main">



<div className="about-image">


<img

src="/nosotros.jpg"

alt="Historia Abastece"

/>


</div>





<div className="about-content">


<span>

Nuestra historia

</span>



<h1>

Transformando la manera de abastecer las bodegas.

</h1>



<p>

Abastece+ nace con el propósito de facilitar el acceso
a productos mayoristas, conectando pequeños negocios
con proveedores confiables mediante tecnología.

</p>



<p>

Buscamos que cada bodeguero pueda administrar mejor
su inventario, ahorrar tiempo y tomar decisiones
más inteligentes.

</p>



</div>



</div>







{/* MISION VISION */}


<div className="mission-grid">



<div className="mission-card">


<h2>

Misión

</h2>


<p>

Simplificar el abastecimiento de las bodegas
mediante una plataforma digital eficiente,
rápida y confiable.

</p>


</div>





<div className="mission-card">


<h2>

Visión

</h2>


<p>

Ser la plataforma líder de conexión entre
bodegueros y proveedores mayoristas.

</p>


</div>



</div>







{/* VALORES */}


<section className="values">


<h2>

Nuestros valores

</h2>



<div className="values-grid">


{

values.map((value,index)=>(


<div 

className="value-card"

key={index}

>


<h3>

{value.title}

</h3>



<p>

{value.text}

</p>


</div>


))

}


</div>



</section>





</div>


</section>


)


}