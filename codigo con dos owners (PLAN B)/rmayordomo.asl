/* Initial beliefs and rules */

/*TODO: hacer que el mayordomo envie precio a owner y owner pague la cerveza pista: usar consulta_precio
		hacer que funcione lo de ir a los supermercados		
*/
available(beer,fridge).

// Limite de cerveza que puede beber el owner
limit(beer,5).   

money(0).

// Basura que posee el robot
trash(can, 0). // Ya no es necesario

// Número de cervezas que se piden a la vez
nbeersPerTime(3).

// Calculo para determinar si el owner puede tomar más cerveza
too_much(B) :-
   .date(YY,MM,DD) &
   .count(consumed(YY,MM,DD,_,_,_,B),QtdB) &
   limit(B,Limit) &
   QtdB >= Limit.

/* Objetivos */

!bring(owner1, beer).
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
	   .send(supermarket2, achieve, lista_productos(beer)).

/*
	lista_productos/1: Cerveza
	public: owner
	return: devuelve la lista de productos de los dos supermercados en una lista y se las envía al owner
			RMAYORDOMO TIENE LA RESONSABILIDAD DE RECONOCER LOS DIFERNTES SUPERMERCADOS
	TODO: hacer un findall para no meter la seleccion_productos agente por agente	
*/	   
+!lista_productos(beer, Agt): seleccion_productos(L1)[source(supermarket1)] & seleccion_productos(L2)[source(supermarket2)] 
	<-.concat(L1,L2,L3);
	.print("mandando productos a agt ", Agt);
	  .send(Agt, tell, seleccionProductos(beer,L3)).	  
	  
+!lista_productos(beer, Agt): true
	<- .print("Aun no llegaron los productos");
		.wait(100);
		!lista_productos(beer, Agt).
		
/*
	hasBeer/1 -> Owner
	private
	return: coge la cerveza y se la entrega al owner
*/	
		
+!hasBeer(Agt)
<- hand_in(beer);
   .println("El robot mayordomo pregunta al owner si ha cogido la cerveza y un pincho");
   ?has(Agt, beer);
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
	<- //!consulta_precio(Agt,M,C);
		//L = P *2;
		.print(Agt, P, OrderId, Supermarket, "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE");
		.print(P, " ");
		.send(Agt, tell, pagar_cerveza(P, OrderId, Supermarket)).

+!consulta_precio(Agt, M, C): seleccion_productos(L)[source(Agt)] & .member(q(M, C), L)
	<-  .print("precio de ", M, " en " , Agt, " es ", C).
		
		
+!consulta_precio(Agt, M, 100)
	<- .print("Cerveza no encontrada en supermercado ", Agt).
	
/*
	comprar/3 -> supermercado, cerveza, Marca(cerveza)
	private
	return: 
	TODO: generalizar de los consulta precios a los diferentes supermercados
		  descartar los 100 en la lista (filtrar)
*/

+order_aceptado(Owner, OrderId, P)[source(Agt)]
	<- !envia_precio(Owner, P, OrderId, Agt);
		.print(Owner, P, OrderId, Agt, "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA").

+!comprar(Agt, beer, M) : not ordered(beer)
   <- 	  
	  !consulta_precio(supermarket1, M, PS1);
	  !consulta_precio(supermarket2, M, PS2);
	  L = [q(PS2, supermarket2), q(PS1, supermarket1)];
	  .min(L, X);
	  !despieza(X, Precio, Supermarket);
      ?nbeersPerTime(NBeer);
	  .print("Comprando ", M, " en ", Supermarket);
	  .send(Supermarket, achieve, order(Agt, beer, NBeer, M));
	  +ordered(beer).
	    	  	  
+!comprar(Agt, beer, M).

+!escoge_owner(owner1, P)
	<- !bring(owner2, P).
	
+!escoge_owner(owner2, P)
	<- !bring(owner1, P).

// Esto es mejorable (Se queda parado mientras no se recoge la basura)
+!bring(Agt,beer)[source(self)]:  trashInEnv(T) & T>0 & not entornoLimpio & cerveza_escogida(M) 
   <- .println("El robot mayordomo revisa si hay basura");
      +entornoLimpio;
      .send(rlimpiador, tell, hay_basura(rlimpiador, trash, plato));
	  !escoge_owner(Agt, beer).

+!bring(Agt,beer) [source(self)]:  too_much(beer, Agt) & limit(beer,L)
   <- .concat("The Department of Health does not allow me to give you more than ", L,
              " beers a day! I am very sorry about that!",M);
      .send(Agt,tell,msg(M));
      .send(Agt, tell, ~couldDrink(beer));
      !go_at(rmayordomo, baseRMayordomo);
      .println("El Robot mayordomo descansa porque ", Agt,  " ha bebido mucho hoy.");
      .wait(10000);
	  !escoge_owner(Agt, beer).

+!bring(Agt,beer)[source(self)]:  available(beer,fridge) & not too_much(beer, Agt) & asked(beer) & cerveza_escogida(M) 
   <- .println("El robot mayordomo va a buscar una cerveza");  	  
      !go_at(rmayordomo,fridge);
      open(fridge);
      get(beer, pinchito);
	  !comprar(Agt, beer, M);
      close(fridge);
      !go_at(rmayordomo,couch);
	  .wait(1000);
      !hasBeer(Agt);
      .abolish(asked(beer));
	  !escoge_owner(Agt, beer).	  
   
+!bring(Agt,beer) [source(self)]:  not available(beer,fridge) & not ordered(beer) & cerverza_escogida(M)
   <- .println("El robot mayordomo realiza un pedido de ", M);
      !comprar(supermarket, beer, M);
	  !escoge_owner(Agt, beer).

+!bring(Agt, beer): cerveza_escogida(M)
   <- !go_at(rmayordomo, baseRMayordomo);
      .wait(2000);
	   .println("El robot mayordomo está esperando.");
	   !escoge_owner(Agt, beer).
	  	   
+!bring(Agt,beer)[source(self)]
   <- .println("El robot mayordomo espera a que owner elija cerveza");
   	  .wait(100);
	  !escoge_owner(Agt, beer).     

+!limpiezaTerminada <- -entornoLimpio.

+pago_cerveza(C, OrderId, Supermarket)[source(Agt)]
	<-  ?money(M);
		L = M + C;
		-money(M);
		+money(L);
		.send(Supermarket, tell, pago_order(OrderId, C)).

// when the supermarket makes a delivery, try the 'has' goal again
+delivered(beer, Precio, OrderId, Marca, Cantidad)[source(S)]
  <-  ?money(Money)[source(self)];
	  .print(N);
      -+money(Money-Precio); //.send(Agt, tell, delivered(T,P,OrderId, M));
      .send(rpedidos, tell, money(Precio));
      .send(rpedidos, tell, delivered(beer, Cantidad , OrderId, S, Marca)).
  
+available(beer, fridge)[source(rpedidos)]
   <- -ordered(beer).

+not_enough_stock(Product, Qtd, Stock)[source(supermarket)] : true
   <- .concat("The supermarket told me they don't have enouth ", Product, 
         "to fullfill my order. (Orderer: ", Qtd, ", Stock: ", Stock, ")", M);
      .send(owner1, tell, msg(M));
	  .send(owner2, tell, msg(M)).

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
+hola[source(Agt)] <- .print("Hola, te cuento un chiste?"); .send(rmayordomo, tell, chiste).
+contarChiste[source(Agt)] <- .print("Con evidentes señales de enfado, la maestra pregunta: Jaimito, ¿te has copiado de Pedro en el examen? Con cara de inocente, Jaimito responde: No, maestra. Entonces, ¿por qué en la respuesta de la pregunta 3, donde Pedro ha puesto no lo sé, has escrito yo tampoco").