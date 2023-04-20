//Beliefs locales
//last_order_id/1 -> identifica numero secuencial de order (solo puede aumentar)
//moneySuper/1 -> cantidad de dinero que tiene el supermercado
//stock/3 -> tipo, cantidad y marca
//price/3 -> tipo, precio y marca
last_order_id(1). // initial belief
moneySuper(1000).

stock(beer, 11, estrella).
stock(beer, 11, aguila).
stock(beer, 11, volldamm).
stock(beer, 11, redvintage).
stock(beer, 11, heineken).

/* Plan */
+!actualiza_order_id(OrderId)
	<- ?last_order_id(A);
		OrderId = A + 1;
		-+last_order_id(OrderId).
		
+!actualiza_moneySuper(M, C, T)
	<- ?price(T, P, M);
		?moneySuper(A);
		-moneySuper(A);
		X = C * P;
		+moneySuper(A + X).
		
+!decrementa_stock(T, C, M)
	<- -stock(T, _, M);
		+stock(T, P-C, M).
//lista_productos/1 -> tipo
// public: rmayordomo
//return: lista de seleccion_productos(L[price/3])
+!lista_productos(T)[source(rmayordomo)]: price(beer, _, _) <-
	.println("Envío de precio al robot mayordomo");
	.findall(q(M, C), price(T, C, M), L);
	.print("Cervezas disponibles: ", L);
	.send(rmayordomo, tell, seleccion_productos(L)).	
//Default	
+!lista_productos(P): true
	<- .print("No hay datos sobre este producto").

// plan to achieve the goal "order" for agent Ag
/*order/3 -> tipo, cantidad, marca
public: cualquiera(rmayordomo)
return: */

+!order(T,C, M)[source(Ag)] : stock(T, P, M2) & P >= C & M = M2 // comprueba la cantidad de stock
  <- 
  	 !actualiza_order_id(OrderId); //1: se actualiza el order_id
	 !actualiza_moneySuper(M, C, T); //2: actualiza moneySuper 
     !decrementa_stock(T, C, M);//3: actualiza stock
	 deliver(T,C); //4: invoca deliver
	 .send(rmayordomo, tell, price(beer, Cant, M));//5: Actualiza a rmayordomo y al Agt que lo invocó
     .send(Ag, tell, delivered(T,C,OrderId, M)).

+!order(T, C, M)[source(Ag)] : stock(T, P, M) & P < C
  <- .print("Out of stock: ", T);
     .send(Ag, tell, not_enough_stock(T, C, P)).
	 
+msg(M)[source(Ag)] : true
   <- .print("Message from ",Ag,": ",M);
      -msg(M).