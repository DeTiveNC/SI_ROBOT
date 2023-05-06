import java.util.ArrayList;
import java.util.Arrays;
import java.util.Map;
import java.util.random.*;

import jason.environment.grid.GridWorldModel;
import jason.environment.grid.Location;

/** class that implements the Model of Domestic Robot application */
public class HouseModel extends GridWorldModel {

    // Constantes para los elementos del grid
    public static final int FRIDGE = 16;
    public static final int COUCH = 32;
    public static final int DELIVERY = 64;
    public static final int BIN = 128;
    public static final int TRASH = 256;
	public static final int LAVAVAJILLAS = 512;
	public static final int LACENA = 1024;
    public static final int OBSTACULE = 2048;

    // Tamaño del grid
    public static final int GSize = 11;

    // Map relacionando el nombre de los agentes con su id
    Map<String, Integer> agents = 
        Map.of(
            "rmayordomo",0,
            "rlimpiador", 1,
            "rbasurero", 2,
            "rpedidos", 3,
            "owner",4
        );

    // Variables de frigorifico abierto o cerrado
    boolean fridgeOpenMayordomo = false;
    boolean fridgeOpenOwner = false;

    // Variables de posesión de una cerveza
    boolean carryingBeerMayordomo = false;
    boolean carryingBeerOwner = false;

    // Número de sorbos que ha hecho el owner
    int sipCount = 0;
	
	
	// Boolean para cambiar de color el bin
	boolean burnerOn = false;

    // Cervezas disponibles
    int availableBeers  = 3;
	
	//Pinchitos Disponibles
	int pinchito = 10;

    // Cervezas en la zona de entrega
    int deliveryBeers = 0;

    // Número de cervezas que lleva el robot de pedidos
    int rpedidosBeers = 0;

    // Número de latas que hay en el cubo de basura
    int cansInTrash = 0;
	
	//Platos para limpiar
	int platosLimpiar = 0;
	
	//Platos a limpiar
	int platosALimpiar = 0;
	
	//Platos sucios
	int platosSucios = 0;
	
	//Platos Limpios
	int platosLimpios = 0;
	
	//Platos en la lacena
	int platosEnLacena = 0;
	
    
    // Posiciones de los elementos del entorno
    Location lFridge = new Location(0,0);
    Location lDelivery = new Location(0, GSize-1);
    Location lBin = new Location(GSize-1, 0);
    Location lCouch = new Location(GSize-1,GSize-1);
	Location lLavavajillas = new Location(0,GSize/2);
	Location lLacena = new Location(GSize/2-2, 0);

    // Posiciones originales de los agentes
    Location lRMayordomo = new Location(GSize/2, GSize/2);
    Location lRLimpiador = new Location(GSize/2, 0);
    Location lRBasurero = new Location(GSize-1, GSize/2-2);
    Location lRPedidos = new Location(GSize/2-2, GSize-1);
    Location lOwner = new Location(GSize-1,GSize-1);

    // ArrayList de posiciones de la basura
    ArrayList<Location> lTrash 
        = new ArrayList<>();

    
    
    // Arrays de posiciones permitidas para la colocación de los agentes

    // Posiciones permitidas del frigorifico
    ArrayList<Location> lFridgePositions 
        = new ArrayList<>(Arrays.asList(
            new Location(lFridge.x+1, lFridge.y+1),
            new Location(lFridge.x+1, lFridge.y),
            new Location(lFridge.x, lFridge.y+1)
        ));
    
    // Posiciones permitidas del sillón
    ArrayList<Location> lCouchPositions
        = new ArrayList<>(Arrays.asList(
            new Location(lCouch.x-1, lCouch.y-1),
            new Location(lCouch.x-1, lCouch.y),
            new Location(lCouch.x, lCouch.y-1)
        ));

    // Posiciones permitidas de la zona de entrega
    ArrayList<Location> lDeliveryPositions
        = new ArrayList<>(Arrays.asList(
            new Location(lDelivery.x+1, lDelivery.y),
            new Location(lDelivery.x, lDelivery.y-1),
            new Location(lDelivery.x+1, lDelivery.y-1)
        ));
    
    // Posiciones permitidas del cubo de basura
    ArrayList<Location> lBinPositions
        = new ArrayList<>(Arrays.asList(
            new Location(lBin.x-1, lBin.y),
            new Location(lBin.x-1, lBin.y+1),
            new Location(lBin.x, lBin.y+1)
        ));
		
	// Posiciones permitidas para el lavavajillas
	
	ArrayList<Location> lLavavajillasPositions
        = new ArrayList<>(Arrays.asList(
            new Location(lLavavajillas.x, lLavavajillas.y+1),
            new Location(lLavavajillas.x, lLavavajillas.y-1),
            new Location(lLavavajillas.x+1, lLavavajillas.y),
			new Location(lLavavajillas.x+1, lLavavajillas.y-1),
			new Location(lLavavajillas.x+1, lLavavajillas.y+1)
        ));
		
	// Posiciones permitidas de la lacena
	ArrayList<Location> lLacenaPositions
        = new ArrayList<>(Arrays.asList(
            new Location(lLacena.x-1, lLacena.y),
            new Location(lLacena.x, lLacena.y+1),
            new Location(lLacena.x+1, lLacena.y),
			new Location(lLacena.x-1, lLacena.y+1),
			new Location(lLacena.x+1, lLacena.y+1)
        ));
		
	ArrayList<Location> lObstacules 
        = new ArrayList<>();
		

		
	// Clase par para almacenar posiciones para la funcion del move_towards
	public class Pair<L,R> {
	private L l;
	private R r;
	public Pair(L l, R r){
		this.l = l;
		this.r = r;
	}
	
	public L getL() { return l; }
	public R getR() { return r; }
	public void setL(L l) { this.l = l; }
	public void setR(R r) { this.r = r; }
	}
	
	// Siguiente movimiento para el agente
	private String getNextMove(Location dest, Location or){
		ArrayList<Pair<Location, String>> uncheckedMoves = new ArrayList<Pair<Location, String>>();
		
		ArrayList<Integer> explored = new ArrayList<Integer>();
		
		int i = ~0;
		
		uncheckedMoves.add(new Pair<Location, String>(or, ""));
		explored.add(or.x + or.y * GSize);
		
		do{
			Location l = uncheckedMoves.get(0).getL();
			String moves = uncheckedMoves.get(0).getR();
			uncheckedMoves.remove(0);
			
			
			if(l.isNeigbour(dest)) return moves;
			
			// TOP
			if   (isFree(i, l.x, l.y - 1) && !explored.contains(l.x + (l.y - 1) * GSize)) {
				uncheckedMoves.add(new Pair<Location, String>(new Location(l.x, l.y - 1), moves + 'u'));
				explored.add(l.x + (l.y - 1) * GSize);

			}
			
			// BOTTOM
			if(isFree(i, l.x, l.y + 1) && !explored.contains(l.x + (l.y + 1) * GSize)) {
				uncheckedMoves.add(new Pair<Location, String>(new Location(l.x, l.y + 1), moves + 'b'));
				explored.add(l.x + (l.y + 1) * GSize);

			}
			
			
			// LEFT
			if   (isFree(i, l.x - 1, l.y) && !explored.contains(l.x - 1 + l.y * GSize)) {
				uncheckedMoves.add(new Pair<Location, String>(new Location(l.x - 1, l.y), moves + 'l'));
				explored.add(l.x - 1 + l.y * GSize);

			}
			
			// RIGHT
			if(isFree(i, l.x + 1, l.y) && !explored.contains(l.x + 1 + l.y * GSize)) { 
				uncheckedMoves.add(new Pair<Location, String>(new Location(l.x + 1, l.y), moves + 'r'));
				explored.add(l.x + 1 + l.y * GSize);
			}
					
			
		} while(!uncheckedMoves.isEmpty());
						
		return "n";
			
	}


    public HouseModel() {
        // Creación del grid con el tamaño definido en GSize
        // Número de agentes móviles: 6
        super(GSize, GSize, 5);

        // Añadido de posiciones iniciales para los agentes (móviles)
        setAgPos(agents.get("rmayordomo"), lRMayordomo);
        setAgPos(agents.get("rlimpiador"), lRLimpiador);
        setAgPos(agents.get("rbasurero"), lRBasurero);
        setAgPos(agents.get("rpedidos"), lRPedidos);
        setAgPos(agents.get("owner"), lOwner);

        // Añadido de posiciones para los elementos del entorno (no móviles)
        add(FRIDGE, lFridge);
        add(DELIVERY, lDelivery);
        add(BIN, lBin);
        add(COUCH, lCouch);
		add(LAVAVAJILLAS, lLavavajillas);
		add(LACENA, lLacena);
		int j = ~0;
		int i = 0;
		
		
		while(i < 8){
			int x = (int) (Math.random()*(GSize-1));
			int y = (int) (Math.random()*(GSize-1));
			if(isFree(j, x, y )){
				lObstacules.add( new Location(x, y));
				add(OBSTACULE, lObstacules.get(i));
				i++;
			}	
			
		}
        
    }

    // Abrir frigorífico
    boolean openFridge(String ag) {
        if (!fridgeOpenMayordomo && ag.equals("rmayordomo")) {
            fridgeOpenMayordomo = true;   
        } else if(!fridgeOpenOwner && ag.equals("owner")){
            fridgeOpenOwner = true;
        } else {
            return false;
        }

        return true;
    }

    // Cerrar frigorífico
    boolean closeFridge(String ag) {
        if (fridgeOpenMayordomo && ag.equals("rmayordomo")) {
            fridgeOpenMayordomo = false;   
        } else if(fridgeOpenOwner && ag.equals("owner")){
            fridgeOpenOwner = false;
        } else {
            return false;
        }

        return true;
    }
	
	boolean cambiarCol_On(){
		burnerOn = true;
		view.update(lBin.x, lBin.y);
		return true;	
	}
	
	boolean cambiarCol_Off(){
		burnerOn = false;
		view.update(lBin.x, lBin.y);
		return true;	
	}
	
	

    // Movimiento de los agentes por el entorno
    boolean moveTowards(String ag, Location dest) {

        int nAg = this.agents.get(ag);
        Location lAgent = getAgPos(nAg);
        
        String move = getNextMove(dest, lAgent);
		
		
		if(!move.isEmpty() && move.charAt(0) == 'u') {
			lAgent.y--;
			move = move.substring(1);
		} else if(  !move.isEmpty() && move.charAt(0) == 'l') {
			lAgent.x--;
			move = move.substring(1);
		} else if( !move.isEmpty()  && move.charAt(0) == 'b' ){
			lAgent.y++;
			move = move.substring(1);
		} else if ( !move.isEmpty() && move.charAt(0) == 'r' ) {
			lAgent.x++;
			move = move.substring(1);
		} else if(!move.isEmpty() && move.charAt(0) == 'n' ){
		    move = getNextMove(dest, lAgent);
			move = move.substring(1);
		}

        setAgPos(nAg, lAgent);

		
        
        return true;
    }

    // Coger cerveza del frigorifico
    boolean getBeerAndPinchito(String ag) {
        if (availableBeers > 0) {
            if(fridgeOpenMayordomo && ag.equals("rmayordomo") && !carryingBeerMayordomo){
                carryingBeerMayordomo = true;
            } else if(fridgeOpenOwner && ag.equals("owner") && !carryingBeerOwner){
                carryingBeerOwner = true;
            }
            
			pinchito--;
            availableBeers--;
            
            if (view != null) view.update(lFridge.x,lFridge.y);
            return true;
        } else {
            return false;
        }
    }

    // Meter cervezas en la zona de entrega
    boolean addBeerDelivery(int n) {
        deliveryBeers += n;
        if (view != null) view.update(lDelivery.x,lDelivery.y);
        return true;
    }

    boolean addBeerFridge(int n) {
        if(rpedidosBeers > 0){
            rpedidosBeers-=n;
            availableBeers+=n;
            if (view != null) view.update(lFridge.x,lFridge.y);
            return true;
        }
        else{
            return false;
        }
    }

    // Entrega de cerveza al owner
    boolean handInBeer(String ag) {
        if(ag.equals("rmayordomo") && carryingBeerMayordomo){
            carryingBeerMayordomo = false;
        } else if(ag.equals("owner") && carryingBeerOwner){
            carryingBeerOwner = false;
        } else{
            return false;
        }
            
        sipCount = 10;
            
        if(view != null){
            Location lAgent = getAgPos(this.agents.get("owner"));
            view.update(lAgent.x,lAgent.y);
        }
            
        return true;
    }

    // Sorver cerveza
    boolean sipBeer() {
        if (sipCount > 0) {
            sipCount--;
            if(view != null){
                Location lAgent = getAgPos(this.agents.get("owner"));
                view.update(lAgent.x,lAgent.y);
            }
            return true;
        } else {
            return false;
        }
    }

    // desechar la basura
    boolean desechar(){
        cansInTrash++;
        if (view != null) view.update(lBin.x,lBin.y);
        return true; 
    }
	
	// desechar los platos
    boolean desecharP(){
		System.out.println("adadwadadawdwadadawdawda");
		if(platosALimpiar > 0){
			  platosLimpiar+=platosALimpiar;
			  platosALimpiar=0;
		}
      
        if (view != null) view.update(lLavavajillas.x,lLavavajillas.y);
        return true; 
    }
	
   // Poner los platos en la lacena
   boolean vaciarLavavajillas(){
        if(platosLimpiar > 0){
			platosLimpios+=platosLimpiar;
            platosLimpiar = 0;
			
        } 
		  if (view != null) view.update(lLavavajillas.x,lLavavajillas.y);
            return true;
    }
	
	// Poner platos lacena
	boolean ponerPlatos(){
	    platosEnLacena+=platosLimpios;
		platosLimpios = 0;
		if (view != null) view.update(lLacena.x,lLacena.y);
            return true;
	}


    // Vacía el cubo de basura
    boolean vaciarPapelera(){
        if(cansInTrash > 0){
            cansInTrash = 0;
          
        } 
		  if (view != null) view.update(lBin.x,lBin.y);
            return true;
    }


    // Desperdigar la basura que tira el owner por el entorno
    boolean generateTrash() {
        Location location;
        do{
            int x = (int) (Math.random()*(GSize-1));
            int y = (int) (Math.random()*(GSize-1));
            location = new Location(x, y);
        }while(
            //lObstacules.contains(location) &&
            location.equals(lBin) &&
            location.equals(lFridge) &&
            location.equals(lCouch) &&
            location.equals(lDelivery) &&
			location.equals(lLavavajillas) &&
			location.equals(lLacena) &&
			lFridgePositions.contains(location) &&
			lBinPositions.contains(location) &&
			lCouchPositions.contains(location) &&
			lDeliveryPositions.contains(location) &&
			lLavavajillasPositions.contains(location) &&
			lLacenaPositions.contains(location) &&
			lObstacules.contains(location)
        );
        
        add(TRASH, location);
        lTrash.add(location);
        return true;

    }
	
	// Crear los platos sucios
    boolean generatePlato() {
		platosSucios++;
		return true;
    }


    // Recoger la basura que se encuentra en el entorno
    boolean pickTrash() {
        Location r1 = lTrash.get(0);

        if (hasObject(TRASH, r1)) {
            if(lTrash.contains(r1)){
                lTrash.remove(lTrash.indexOf(r1));

            }
            remove(TRASH, r1);
			return true;
        }
		return false;
    }
	
	// Recoger los platos
    boolean pickPlato() {
	   platosALimpiar+=platosSucios;
	   platosSucios=0;
	   return true;
    }

    // Recoger las cervezas del punto de recogida
    public boolean getDelivery(int n) {
        if (deliveryBeers > 0) {
            deliveryBeers-=n;
            rpedidosBeers+=n;
			pinchito+=n;
            if(view != null){
                view.update(lDelivery.x,lDelivery.y);
            }
            return true;
        } else {
            return false;
        }
    }
}
