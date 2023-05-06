/* Initial beliefs and rules */

available(beer,fridge).

// Limite de cerveza que puede beber el owner
limit(beer,5).
money(0).   
	

// Número de cervezas que se piden a la vez
nBeerPinchperTime(3).

// Calculo para determinar si el owner puede tomar más cerveza
too_much(B) :-
   .date(YY,MM,DD) &
   .count(consumed(YY,MM,DD,_,_,_,B),QtdB) &
   limit(B,Limit) &
   QtdB >= Limit.

/* Objetivos */

!bring(owner, beer).
!pide_lista_productos_super.

/* Planes */

+!despieza([],[],[]).
+!despieza(q(X,Y),X,Y).

+!go_at(rmayordomo,P) : at(rmayordomo,P) <- true.
+!go_at(rmayordomo,P) : not at(rmayordomo,P)
  <- move_towards(P);
     !go_at(rmayordomo,P).
	
/*
	pide_lista_productos_super/0
	private
	return: le pide a los supermercados que le envíen una lista de productos
*/	 	 
+!pide_lista_productos_super 
	<- .send(supermarket1, achieve, lista_productos(beer));
	   .send(supermarket2, achieve, lista_productos(beer));
	   .send(supermarket1, achieve, lista_productos(pinchito));
	   .send(supermarket2, achieve, lista_productos(pinchito)).

/*
	lista_productos/1: Cerveza
	private
	return: devuelve la lista de productos de los dos supermercados en una lista y se las envía al owner
			RMAYORDOMO TIENE LA RESONSABILIDAD DE RECONOCER LOS DIFERNTES SUPERMERCADOS
	TODO: hacer un findall para no meter la seleccion_productos agente por agente	
*/	   
+!lista_productos(beer): seleccion_productos(beer, L1)[source(supermarket1)] & seleccion_productos(beer, L2)[source(supermarket2)] 
	<-.concat(L1,L2,L3);
	  .send(owner, tell, seleccionProductos(beer,L3)).	  
	  
+!lista_productos(beer): true
	<- .print("Aun no llegaron los productos");
		.wait(100);
		!lista_productos(beer).
		
+!lista_productos(pinchito): seleccion_productos(pinchito, L1)[source(supermarket1)] & seleccion_productos(pinchito, L2)[source(supermarket2)] 
	<-.concat(L1,L2,L3);
	  .send(owner, tell, seleccionProductos(pinchito,L3)).	  
	  
+!lista_productos(pinchito): true
	<- .print("Aun no llegaron los productos");
		.wait(100);
		!lista_productos(pinchito).
		
/*
	hasBeer/1 -> Owner
	private
	return: coge la cerveza y se la entrega al owner
*/	
		
+!hasBeer(owner)
<- hand_in(beer);
   .println("El robot mayordomo pregunta al owner si ha cogido la cerveza y un pincho");
   ?has(owner,beer);
   .println("El Owner tiene la cerveza y pincho.");
   // remember that another beer has been consumed
   .date(YY,MM,DD); 
   .time(HH,NN,SS);
   +consumed(YY,MM,DD,HH,NN,SS,beer).
 
/*
	consulta_precio/2 -> Agente, Marca, Cantidad
	privado
	return: a partir de la lista obtenida en supermercado, devuelve el precio y la marca de la cerveza elegida
*/   

+!envia_precio(Agt, P, OrderId, Supermarket)
	<- 
		.print(P, " ");
		.send(Agt, tell, pagar_cervezaypincho(P, OrderId, Supermarket)).

+!consulta_precio(Agt,beer, M, C): seleccion_productos(beer, L)[source(Agt)] & .member(q(M, C), L)
	<-  .print("precio de ", M, " en " , Agt, " es ", C).
		
		
+!consulta_precio(Agt,beer, M, 100)
	<- .print("Cerveza no encontrada en supermercado ", Agt).

+!consulta_precio(Agt,pinchito, M, C): seleccion_productos(pinchito, L)[source(Agt)] & .member(q(M, C), L)
	<-  .print("precio de ", M, " en " , Agt, " es ", C).
		
		
+!consulta_precio(Agt,pinchito, M, 100)
	<- .print("Pinchito no encontrada en supermercado ", Agt).
	
/*
	comprar/3 -> supermercado, cerveza, Marca(cerveza)
	private
	return: 
	TODO: generalizar de los consulta precios a los diferentes supermercados
		  descartar los 100 en la lista (filtrar)
*/
+order_aceptado(Owner, OrderId, P)[source(Agt)]
	<- !envia_precio(Owner, P, OrderId, Agt).
	
+!comprar(supermarket, T, M) : not ordered(T) 
   <- 	  
	  !consulta_precio(supermarket1,T, M, PS1);
	  !consulta_precio(supermarket2,T, M, PS2);
	  L = [q(PS2, supermarket2), q(PS1, supermarket1)];
	  .min(L, X);
	  !despieza(X, Precio, Supermarket);
      ?nBeerPinchperTime(NBeerPinch);
	  .print("Comprando ", M, " en ", Supermarket);
	  .send(Supermarket, achieve, order(owner, T, NBeerPinch, M));
	  +ordered(T).	  
	  
+!comprar(supermarket, T, M).

// Esto es mejorable (Se queda parado mientras no se recoge la basura)
+!bring(owner,beer)[source(self)]:  trashInEnv(T) & T>0 & not entornoLimpio & cerveza_escogida(M) & pinchito_escogido(P)
   <- .println("El robot mayordomo revisa si hay basura");
      +entornoLimpio;
      .send(rlimpiador, tell, hay_basura(rlimpiador,trash));
      !bring(owner, beer).

+!bring(owner,beer) [source(self)]:  too_much(beer) & limit(beer,L) 
   <- .concat("The Department of Health does not allow me to give you more than ", L,
              " beers a day! I am very sorry about that!",M);
      .send(owner,tell,msg(M));
      .send(owner, tell, ~couldDrink(beer));
      .println("El Robot mayordomo descansa porque Owner ha bebido mucho hoy.");
      .wait(10000);
      !bring(owner, beer).

+!bring(owner,beer)[source(self)]:  available(beer,fridge) & not too_much(beer) & asked(beer) & cerveza_escogida(M) & pinchito_escogido(P) 
   <- .println("El robot mayordomo va a buscar una cerveza");
      !go_at(rmayordomo,fridge);
      open(fridge);
      get(beer, pinchito);
	  ?cerveza_escogida(M);
	  ?pinchito_escogido(P);
	  .send(rpedidos, tell, trabajando);
	  !comprar(supermarket, beer, M);
	  .wait(100);
	   .send(rpedidos, tell, trabajando);
	  !comprar(supermarket, pinchito, P);
      close(fridge);
      !go_at(rmayordomo,couch);
	  .wait(1000);
      !hasBeer(owner);
      .abolish(asked(beer));
      !bring(owner, beer).	  
   
+!bring(owner,beer) [source(self)]:  not available(beer,fridge) & not ordered(beer) & cerverza_escogida(M) & pinchito_escogido(P) 
   <- .println("El robot mayordomo realiza un pedido de ", M);
   	  ?cerveza_escogida(M);
	  ?pinchito_escogido(P);
	   .send(rpedidos, tell, trabajando);
      !comprar(supermarket, beer, M);
	  .wait(100);
	  println("El robot mayordomo realiza un pedido de ", P);
	   .send(rpedidos, tell, trabajando);
	  !comprar(supermarket, pinchito, P);
      !bring(owner, beer).

+!bring(owner, beer): cerveza_escogida(M) & pinchito_escogido(P)
   <- !go_at(rmayordomo, baseRMayordomo);
      .wait(2000);
	   .println("El robot mayordomo está esperando.");
	   !bring(owner, beer).
	   
+!bring(owner,beer)[source(self)] 
   <- .println("El robot mayordomo espera a que owner elija cerveza");
   	  .wait(100);
      !bring(owner, beer).

+!limpiezaTerminada <- -entornoLimpio.

+pago_cervezaypincho(C, OrderId, Supermarket)[source(Agt)]
	<-  ?money(M);
		L = M + C;
		-money(M);
		+money(L);
		.send(Supermarket, tell, pago_order(OrderId, C)).

// Apartado limpieza platos sucios
+!recogerPlatoSucio(rmayordomo,plato) : platosSucios
   <- !go_at(rmayordomo, couch);
      .println("El robot rmayordomo recoge los platos con tranquilidad");
      pickPlato(rmayordomo, plato);
	  -platosSucios;
      !desecharP(rmayordomo, plato).

+!desecharP(rmayordomo, plato)
   <-  !go_at(rmayordomo,lavavajillas);
   	   desecharP(rmayordomo, plato);
       !lavavajillas_lleno(rmayordomo, lavavajillas).

   
  //Apartado coger platos sucios y llevarlos a la lacena
+!lavavajillas_lleno(rmayordomo, lavavajillas)
    <-  .println("Poniendo el lavavajillas");
		.wait(6000);
        vaciarLa(lavavajillas);
        !go_at(rmayordomo, lacena);
		ponerPla(rmayordomo, lacena);
		!go_at(rmayordomo, baseRMayordomo).
		
// Pago de cervezas por parte del owner
+pago_cerveza(C, OrderId, Supermarket)[source(Agt)]
	<-  ?money(M);
		L = M + C;
		-money(M);
		+money(L);
		.send(Supermarket, tell, pago_order(OrderId, C)).

// when the supermarket makes a delivery, try the 'has' goal again
+delivered(T,Precio,OrderId,Marca, Cantidad)[source(S)]
  <-  ?money(Money)[source(self)];
      .print(N);
      -+money(Money-Precio);
      .send(rpedidos, tell, money(Precio));
      .send(rpedidos, tell, delivered(T, Cantidad, OrderId, S, Marca)).
  
+available(beer, fridge)[source(rpedidos)]
   <- -ordered(beer).


// when the fridge is opened, the beer stock is perceived
// and thus the available belief is updated
+stock(beer,0)
   :  available(beer,fridge)
   <- -available(beer,fridge).
+stock(beer,N)
   :  N > 0 & not available(beer,fridge)
   <- -+available(beer,fridge).

+?time(T) : true
  <-  time.check(T). 

+msg(M)[source(Ag)] : true
   <- .print("Message from ",Ag,": ",M);
      -msg(M).
+hola[source(owner)] <- .print("Hola, te cuento un chiste?"); .send(rmayordomo, tell, chiste).
+contarChiste[source(owner)] <- .print("Con evidentes señales de enfado, la maestra pregunta: Jaimito, ¿te has copiado de Pedro en el examen? Con cara de inocente, Jaimito responde: No, maestra. Entonces, ¿por qué en la respuesta de la pregunta 3, donde Pedro ha puesto no lo sé, has escrito yo tampoco").
