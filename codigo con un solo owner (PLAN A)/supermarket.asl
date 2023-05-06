//Beliefs locales
//last_order_id/1 -> identifica numero secuencial de order (solo puede aumentar)
//moneySuper/1 -> cantidad de dinero que tiene el supermercado
//stock/3 -> tipo, cantidad y marca
//price/3 -> tipo, precio y marca
last_order_id(1). // initial belief
/*Initial goal*/
!recibir_stockyprecio.


/* Plan */
+!recibir_stockyprecio : true 
	<-
		.random(X);
		F = X*1000000+1;
		+moneySuper(F);
		.send(abastecedor, tell, dar_precioystock);
		.wait(100).

/*Actualizacion de dinero*/
+!actualizar_moneySuperNeg(P):  moneySuper(A)
	<-  -moneySuper(A);
		+moneySuper(A - P).
+!actualizar_moneySuperNeg(P)
	<-  .print("No se puede actualizar dinero").	

+!actualiza_order_id(OrderId)
	<- ?last_order_id(A);
		OrderId = A + 1;
		-+last_order_id(OrderId).
		
+!actualizar_moneySuper(P):  moneySuper(A)
	<-  -moneySuper(A);
		+moneySuper(A + P).
+!actualizar_moneySuper(P)
	<-  .print("No se puede actualizar dinero").		
		
+!decrementa_stock(T, C, M, P)
	<- -stock(T, P, M);
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
+pago_order(OrderId, P)[source(Agt)]: pending_order(OrderId, P, T, M, C)
	<- !actualizar_moneySuper(P);
		deliver(T, P);
		.send(Agt, tell, delivered(T,P,OrderId, M, C));
		-pending_order(OrderId, P, T, M, C).

+pago_order(OrderId, P)[source(Agt)]
	<- 
		?pending_order(Order, Pp, T, M);
		.print(OrderId," ", Order," ", P," ", Pp).
	

+!order(Owner, T, C, M)[source(Ag)] : stock(T, P, M2) & P >= C & M = M2 // comprueba la cantidad de stock
  <- 
  	 !actualiza_order_id(OrderId); //1: se actualiza el order_id
	 //!actualiza_moneySuper(M, C, T); //2: actualiza moneySuper 
     !decrementa_stock(T, C, M ,P);//3: actualiza stock//2: actualiza stock
	 ?price(T, Precio, M);
	 G = Precio * C;
	 +pending_order(OrderId, G, T, M, C);
	 //deliver(T,C); //4: invoca deliver
	 .send(Ag, tell, order_aceptado(Owner, OrderId, G)).//5: Actualiza a rmayordomo y al Agt que lo invocó
     //.send(Ag, tell, delivered(T,C,OrderId, M)).

+!order(_, T, C, M)[source(Ag)] : stock(T, P, M) & P < C
  <- .print("Out of stock: ", T);
  	 .send(abastecedor, tell, dar_nuevo_stock(T, P, M));
	 .wait(100);
     !order(Owner, T, C, M).
	 
+msg(M)[source(Ag)] : true
   <- .print("Message from ",Ag,": ",M);
      -msg(M).