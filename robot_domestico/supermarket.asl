last_order_id(1). // initial belief
moneySuper(1000).


stock(beer, 11, estrella).
stock(beer, 11, aguila).
stock(beer, 11, volldamm).
stock(beer, 11, redvintage).
stock(beer, 11, heineken).

!sendPrice.

/* Plan */
	
+!sendPrice : true
   <- .println("No hay datos sobre precios en este supermercado").
   
+!lista_productos(P)[source(rmayordomo)]: price(beer, _, _) <-
	.println("Envío de precio al robot mayordomo");
	.findall(q(M, C), price(P, C, M), L);
	.print("Cervezas disponibles: ", L);
	.send(rmayordomo, tell, seleccion_productos(L)).	
	
+!lista_productos(P): true
	<- .print("No hay datos sobre este producto").

// plan to achieve the goal "order" for agent Ag
+!order(Product,Qtd, M)[source(Ag)] : stock(Product, P, Z) & P >= Qtd & M = Z
  <- 
  ?last_order_id(N);
     OrderId = N + 1;
	  ?price(beer, Z);
     -+last_order_id(OrderId); 
     -stock(beer, _, M);
     +stock(beer, P-Qtd, M);
     deliver(Product,Qtd);
	 ?price(beer, Z, Nm);
	 ?moneySuper(A);
	 -moneySuper(A);
	 X = Qtd*Z;
	 +moneySuper(A+X);
	 .print("akdsjad ajhdakshf ajsfdh aisjhfd laishdfl aihsd ", Ag);
     .send(Ag, tell, delivered(Product,Qtd,OrderId, M)).

+!order(Product,Qtd, M)[source(Ag)] : stock(Product, P, M) & P < Qtd
  <- .print("Out of stock: ", Product);
     .send(Ag, tell, not_enough_stock(Product, Qtd, P)).

+msg(M)[source(Ag)] : true
   <- .print("Message from ",Ag,": ",M);
      -msg(M).