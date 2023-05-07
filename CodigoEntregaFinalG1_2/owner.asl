//Beliefs iniciales
/*trash/2 -> Basura, Cantidad
  platoVa/2 -> Plato, Cantidad
  money/1 -> Cantidad
*/
//Beliefs temporales
/*
	msg/1 -> Mensaje
	public: rmayordomo
	return: retorna un mensaje
*/

/*
	couldDrink/1 -> Cerveza
	return: le indica que puede beber cerveza
*/

/*
	seleccionProductos/2 -> Cerveza, seleccionProductos(L[price/3])
	public: rmayordomo
	return: una lista con distintas marcas de cervezas con su respectivos precios seleccionProductos(Cerveza, L[price/3])
*/
trash(can,0).
platoVa(plato, 0).
contarPlaLav(plato, 0).

/* Objetivos iniciales */

!money_aleatorio.
!bebe(owner, beer).
!pide_lista_productos.

!comprobar_aburrido. // initial goal: verify whether I am getting bored

/* Planes iniciales */

//creacion de money aleatorio
+!money_aleatorio : true 
	<- .random(X);
		F = X*10000+1;
		+money(F).

//despieza/3 -> le pasamos un belief en formato q(X,Y) y devuelve X, Y por separado
+!despieza([],[],[]).
+!despieza(q(X,Y),X,Y).

/*
	escoge_cerveza/0 
	private
	return: cuando el mayordomo actualiza seleccionProductos, se activa escoge_cerveza
	
*/

+!escoge_cerveza: seleccionProductos(beer, L1)[source(rmayordomo)]
	<- .random(L1, X);
	   !despieza(X, M, _); // _ = no me interesa valor
	   .print("Cerveza elegida: ", M); 
	   .send(rmayordomo, tell, cerveza_escogida(M)).
	   	   	   
+!escoge_cerveza
	<- .wait(100); //Esperando por la cerveza TODO: intentar solucionar recursividad		
	   !escoge_cerveza.

+!escoge_pinchito : seleccionProductos(pinchito, L1)[source(rmayordomo)]
	<- .random(L1, X);
		!despieza(X, M,_);
		.print("Pinchito elegido: ", M);
		.send(rmayordomo, tell, pinchito_escogido(M)).

+!escoge_pinchito
	<- .wait(100); //Esperando por la cerveza TODO: intentar solucionar recursividad		
	   !escoge_pinchito.
/*
	pide_lista_productos/0
	private
	return: le envia a rmayordomo una peticion para ver la lista_productos y luego escoge uno
*/	   
	   
+!pide_lista_productos 
	<-
	.send(rmayordomo, achieve, lista_productos(beer));
	.send(rmayordomo, achieve, lista_productos(pinchito));	
	!escoge_cerveza;
	!escoge_pinchito.	   
	   
/*
	get/1 -> cerveza
	private
	return: pedir una cerveza a rmayordomo
	
*/

+!get(beer) : not asked(beer) 
   <- .send(rmayordomo, tell, asked(beer));//1: Preguntarle a mayordomo por una cerveza
      .println("Owner ha pedido una cerveza al robot mayordomo.");
      +asked(beer);	//4: actualizar belief de que ya se ha pedido una cerveza
	  .wait(200).

/*
	restarDinero/1 -> Cantidad (C)
	return: actualiza belief de money 
*/
+!restarDinero(C): C == 0 <- true.	

+!restarDinero(C) : money(M) & M >= C
	<-  .print("Pago realizado.");		
		L = M - C;
		-money(M);
		+money(L).
		
+!restarDinero(C) : money(M) & M < C	  
  <- .print("Cantidad de dinero insuficiente.");
  	 false.

/*
	lanzar/1 -> Elemento
	private
	return: owner coje algo de la basura y lo lanza fuera
	TODO: cambiar nombre de trash a toTrash
*/	 
	 
+!lanzar(Elem) : trash(Elem, C) & C>0
   <- .println("Owner va a lanzar ", Elem);
      generateTrash(Elem);
      -+trash(Elem, C-1).
+!lanzar(Elem).	 

+hay_basura(owner, trash) [source(rmayordomo)]
   <- !recogerBasura(owner, trash);	  
      !tirarBasura(owner, bin);
      !go_at(owner, couch);
	  !hay_papeleraBin(rbasurero, bin);
      .abolish(hay_basura(owner, trash));
	  .send(rmayordomo, achieve, limpiezaTerminada).
	  
+!hay_papeleraBin(rbasurero, bin) <-
	.send(rbasurero, tell, papelera_llena(rbasurero, bin));
	.wait(1000);
	.send(rbasurero, untell, papelera_llena(rbasurero, bin)).
	  
+!recogerBasura(owner, trash) : trashInEnv(T) & T > 0
   <- !go_at(owner, trash);
      pickTrashO(owner,trash);
      ?trash(can, C);
      -+trash(can, C+1);
      !recogerBasura(owner,trash).
+!recogerBasura(owner, trash).

+!tirarBasura(owner, bin): trash(can, X) & X>0
   <- !go_at(owner, bin);
      !desechar(owner, trash).
+!tirarBasura(owner, bin).

+!desechar(owner, trash) : trash(can, X) & X>0
   <- desechar(owner,trash);
      -+trash(can, X-1);
      !desechar(owner, trash).
+!desechar(owner,trash)
   <- .println("Owner ha depositado toda la basura en el cubo").


/*
	recogerplatosucio/1 -> Elemento
	private
	return: recoge un plato sucio
	TODO: generalizar lanzar y recogerplatosucio; cambiar nombre de generatePlato
*/

+!recogerplatosucio(Elem) : platoVa(Elem, D) & D>0
 <-   .println("Owner deja su plato sucio.");
      generatePlato(Elem);
	  ?contarPlaLav(plato, C);
	  E=C+1;
      -+platoVa(Elem, D-1);
	  -+contarPlaLav(plato,E);
	   if(E >= 5){
	  	.send(rmayordomo, tell, platosSucios);
	  	.send(rmayordomo, achieve, recogerPlatoSucio(rmayordomo,plato));
	  }.
+!recogerplatosucio.	

+!dormirse
	<- .random(X);
	   .wait(X*5000+2000).
	   
+!despertarse(N): N < 0.5
	<- .send(rmayordomo, askOne, time(_), R); // when bored, I ask the robot about the time
       .print(R).
	   
+!despertarse(N)
	<- .send(rmayordomo, tell, hola).
	
/*
	comprobar_aburrido/0
	private
	return: 
*/		
+!comprobar_aburrido : true
   <- !dormirse;
   	  .random(Y);
	  !despertarse(Y);
      !comprobar_aburrido.
	  
/*
	go_at/2 -> owner, posicion
	private
	return: se mueve poco a poco a la posicion indicada
*/	  
	  
+!go_at(owner,P) : at(owner,P) <- true.
+!go_at(owner,P) : not at(owner,P)
  <- move_towards(P);
     !go_at(owner,P).
	
/*
	sip/1 -> Cerveza
	private
*/	 
	 
+!sip(beer) : not has(owner,beer)
   <- true.
+!sip(beer): has(owner,beer) & asked(beer) 
   <- .println("Owner va a empezar a beber cerveza y comer un pincho.");
      -asked(beer);
      sip(beer);
      !sip(beer).
+!sip(beer): has(owner,beer) & not asked(beer) 
   <- sip(beer);
      .println("Owner está bebiendo cerveza y comiendo un pincho.");
      !sip(beer).
	 
+!bebe(owner, beer) : not has(owner, beer) & not asked(beer) 
   <- .println("Owner no tiene cerveza y un pincho.");
      .random(X);
      !get(beer);
      !bebe(owner, beer).	  

+!bebe(owner, beer) : has(owner, beer)
   <- .println("Owner ya tiene una cerveza y se dispone a beberla.");
      !sip(beer);
      ?trash(can,C);
	  ?platoVa(plato, D);
      -+trash(can, C+1);
	  -+platoVa(plato, D+1);
      !lanzar(can);
	  !recogerplatosucio(plato);
      !bebe(owner, beer).

+!bebe(owner, beer) : ~couldDrink(beer) 
   <- .println("Owner ha bebido demasiado por hoy.").	

+!bebe(owner, beer) : not has(owner,beer) & asked(beer) 
   <- .println("Owner está esperando una cerveza.");
	   .wait(500);
	   !bebe(owner, beer).
	   
+pagar_cervezaypincho(C, OrderId, Supermarket)[source(Agt)]
	<-	!restarDinero(C);//TODO: se asume que restar dinero va a salir bien
		.send(Agt, tell, pago_cervezaypincho(C, OrderId, Supermarket));	
		-pagar_cervezapincho(C, OrderId, Supermarket).
	     		 
+stock(beer,0)
   :  available(beer,fridge)
   <- -available(beer,fridge).
+stock(beer,N)
   :  N > 0 & not available(beer,fridge)
   <- -+available(beer,fridge).


+msg(M)[source(Ag)] : true
   <- .print("Message from ",Ag,": ",M);
      -msg(M).
+chiste[(source(rmayordomo))] <- .print("Si"); .send(rmayordomo, tell, contarChiste).
