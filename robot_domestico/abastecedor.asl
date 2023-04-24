/*Stock de cada cerveza que se enviara a los supermercados */
stock(beer, 30, estrella).
stock(beer, 30, aguila).
stock(beer, 30, volldamm).
stock(beer, 30, redvintage).
stock(beer, 30, heineken).
/*Precios de las cervezas*/
price(beer, 8, aguila).
price(beer, 6, estrella). 
price(beer, 3, volldamm). 
price(beer, 7, heineken). 
price(beer, 10, redvintage).
price(beer, 9, aguila).
price(beer, 4, estrella). 
price(beer, 5, volldamm). 
price(beer, 5, heineken). 
price(beer, 12, redvintage).


+dar_precioystock[source(supermarket1)] : true
	<-	.send(supermarket1, tell, stock(beer, 30, estrella));
		.send(supermarket1, tell, stock(beer, 30, aguila));
		.send(supermarket1, tell, stock(beer, 30, volldamm));
		.send(supermarket1, tell, stock(beer, 30, redvintage));
		.send(supermarket1, tell, stock(beer, 30, heineken));
		.send(supermarket1, tell, price(beer, 8, aguila));
		.send(supermarket1, tell, price(beer, 6, estrella));
		.send(supermarket1, tell, price(beer, 3, volldamm));
		.send(supermarket1, tell, price(beer, 7, heineken));
		.send(supermarket1, tell, price(beer, 10, redvintage)).
+dar_precioystock[source(supermarket2)] : true
	<-	.send(supermarket2, tell, stock(beer, 30, estrella));
		.send(supermarket2, tell, stock(beer, 30, aguila));
		.send(supermarket2, tell, stock(beer, 30, volldamm));
		.send(supermarket2, tell, stock(beer, 30, redvintage));
		.send(supermarket2, tell, stock(beer, 30, heineken));
		.send(supermarket2, tell, price(beer, 9, aguila));
		.send(supermarket2, tell, price(beer, 4, estrella));
		.send(supermarket2, tell, price(beer, 5, volldamm));
		.send(supermarket2, tell, price(beer, 5, heineken));
		.send(supermarket2, tell, price(beer, 12, redvintage)).


+msg(M)[source(Ag)] : true
   <- .print("Message from ",Ag,": ",M);
      -msg(M).
