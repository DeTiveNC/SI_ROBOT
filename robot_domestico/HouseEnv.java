import jason.NoValueException;
import jason.asSyntax.*;
import jason.environment.Environment;
import jason.environment.grid.Location;
import java.util.logging.Logger;

public class HouseEnv extends Environment {
 
    // common literals

    // Acción de abrir la nevera
    public static final Literal openFridge  = Literal.parseLiteral("open(fridge)");

    // Acción de cerrar la nevera
    public static final Literal closeFridge = Literal.parseLiteral("close(fridge)");

    // Acción de coger una cerveza
    public static final Literal getBeerAndPinchito  = Literal.parseLiteral("get(beer, pinchito)");
    
    // Acción de entregar una cerveza
    public static final Literal handInBeer  = Literal.parseLiteral("hand_in(beer)");

    // Acción de sorber la cerveza
    public static final Literal sipBeer  = Literal.parseLiteral("sip(beer)");

    // Acción de vaciar el cubo de basura
    public static final Literal vaciarBin  = Literal.parseLiteral("vaciar(bin)");

    // Acción de tirar una lata en el entorno
    public static final Literal generateTrash = Literal.parseLiteral("generateTrash(can)");
	
	// Acción de crear un plato sucio
    public static final Literal generatePlato = Literal.parseLiteral("generatePlato(plato)");

    // Acción de recoger una lata del entorno
    public static final Literal pickTrash = Literal.parseLiteral("pickTrash(rlimpiador,trash)");
	
	// Acción de recoger un plato del owner
    public static final Literal pickPlato = Literal.parseLiteral("pickPlato(rlimpiador,plato)");

	// Acciones de tirar los platos sucios al lavavajillas
    public static final Literal desecharP = Literal.parseLiteral("desecharP(rlimpiador,plato)");
	
	//Acion Burner
	public static final Literal burnerOn = Literal.parseLiteral("burnerOn");
	public static final Literal burnerOff = Literal.parseLiteral("burnerOff");
	
    // Acciones de tirar la basura el el cubo
    public static final Literal desecharRLimpiadorTrash = Literal.parseLiteral("desechar(rlimpiador,trash)");
    public static final Literal desecharOwnerTrash1 = Literal.parseLiteral("desechar(owner1,trash)");
    public static final Literal desecharOwnerTrash2 = Literal.parseLiteral("desechar(owner2,trash)");
	
	// Acciones de eliminar los platos del lavavajillas
    public static final Literal vaciarLa = Literal.parseLiteral("vaciarLa(lavavajillas)");
	// Acciones para poner platos en la lacena
	 public static final Literal ponerPla = Literal.parseLiteral("ponerPla(rlavador, lacena)");

    // Percepciones de tener cerveza
    public static final Literal hasOwnerBeer1 = Literal.parseLiteral("has(owner1,beer)");
    public static final Literal hasOwnerBeer2 = Literal.parseLiteral("has(owner2,beer)");

    // Creencias "at" para el agente mayordomo
    public static final Literal atRMayordomoFridge = Literal.parseLiteral("at(rmayordomo,fridge)");
    public static final Literal atRMayordomoCouch = Literal.parseLiteral("at(rmayordomo,couch)");
    public static final Literal atRMayordomoBase = Literal.parseLiteral("at(rmayordomo,baseRMayordomo)");
    
    // Creencias "at" para el agente limpiador
    public static final Literal atRLimpiadorBin = Literal.parseLiteral("at(rlimpiador,bin)");
    public static final Literal atRLimpiadorTrash = Literal.parseLiteral("at(rlimpiador,trash)");
    public static final Literal atRLimpiadorBase = Literal.parseLiteral("at(rlimpiador,baseRLimpiador)");
	public static final Literal atRLimpiadorCouch = Literal.parseLiteral("at(rlimpiador,couch)");
	public static final Literal atRLimpiadorLava = Literal.parseLiteral("at(rlimpiador,lavavajillas)");

    // Creencias "at" para el agente basurero
    public static final Literal atRBasureroBin = Literal.parseLiteral("at(rbasurero,bin)");
	public static final Literal atRBasureroBase = Literal.parseLiteral("at(rbasurero,baseRBasurero)");
	
	// Creencias "at" para el agente lavador
    public static final Literal atRLavadorBase = Literal.parseLiteral("at(rlavador,baseRLavador)");
	public static final Literal atRLavadorLava = Literal.parseLiteral("at(rlavador,lavavajillas)");
	public static final Literal atRLavadorLace = Literal.parseLiteral("at(rlavador,lacena)");

    // Creencias "at" para el agente pedidos
    public static final Literal atRPedidosDelivery = Literal.parseLiteral("at(rpedidos,delivery)");
    public static final Literal atRPedidosFridge = Literal.parseLiteral("at(rpedidos,fridge)");
    public static final Literal atRPedidosBase = Literal.parseLiteral("at(rpedidos,baseRPedidos)");

    // Creencias "at" para el agente owner
    public static final Literal atOwnerBin1 = Literal.parseLiteral("at(owner1,bin)");
    public static final Literal atOwnerCouch1 = Literal.parseLiteral("at(owner1,couch)");
    public static final Literal atOwnerFridge1 = Literal.parseLiteral("at(owner1,fridge)");
    public static final Literal atOwnerBin2 = Literal.parseLiteral("at(owner2,bin)");
    public static final Literal atOwnerCouch2 = Literal.parseLiteral("at(owner2,couch)");
    public static final Literal atOwnerFridge2 = Literal.parseLiteral("at(owner2,fridge)");


    static Logger logger = Logger.getLogger(HouseEnv.class.getName());

    HouseModel model; // the model of the grid

    @Override
    public void init(String[] args) {
        model = new HouseModel();

        if (args.length == 1 && args[0].equals("gui")) {
            HouseView view  = new HouseView(model);
            model.setView(view);
        }

        updatePercepts();
    }

    /** creates the agents percepts based on the HouseModel */
    void updatePercepts() {

        // Limpieza de creencias de todos los agentes
        clearPercepts("rmayordomo");
        clearPercepts("rlimpiador");
        clearPercepts("rbasurero");
        clearPercepts("rpedidos");
		clearPercepts("rlavador");
        clearPercepts("owner1");
        clearPercepts("owner2");

        // Obtención de las posiciones de todos los agentes
        Location lRMayordomo = model.getAgPos(model.agents.get("rmayordomo"));
        Location lRLimpiador = model.getAgPos(model.agents.get("rlimpiador"));
        Location lRBasurero = model.getAgPos(model.agents.get("rbasurero"));
        Location lRPedidos = model.getAgPos(model.agents.get("rpedidos"));
		Location lRLavador = model.getAgPos(model.agents.get("rlavador"));
        Location lOwner1 = model.getAgPos(model.agents.get("owner1"));
        Location lOwner2 = model.getAgPos(model.agents.get("owner2"));

        // Percepciones de posición del agente rmayordomo
        if (model.lFridgePositions.contains(lRMayordomo)) {
            addPercept("rmayordomo", atRMayordomoFridge);
        }
        else if (model.lCouchPositions.contains(lRMayordomo)) {
            addPercept("rmayordomo", atRMayordomoCouch);
        }
        else if(model.lRMayordomo.isNeigbour(lRMayordomo)){
            addPercept("rmayordomo", atRMayordomoBase);
        }

        // Percepciones de posición del agente rlimpiador
        if (model.lBinPositions.contains(lRLimpiador)){
            addPercept("rlimpiador", atRLimpiadorBin);
        }
        else if(!model.lTrash.isEmpty() && model.lTrash.get(0).isNeigbour(lRLimpiador)){
            addPercept("rlimpiador", atRLimpiadorTrash);
        }
        else if(model.lRLimpiador.isNeigbour(lRLimpiador)){
            addPercept("rlimpiador", atRLimpiadorBase);
        }
		else if (model.lCouchPositions.contains(lRLimpiador)) {
            addPercept("rlimpiador", atRLimpiadorCouch);
        }
		else if(model.lLavavajillasPositions.contains(lRLimpiador)){
            addPercept("rlimpiador", atRLimpiadorLava);
        }

        // Percepciones de posición del agente robot rbasurero
        if (model.lBinPositions.contains(lRBasurero)){
            addPercept("rbasurero", atRBasureroBin);
        } else if(model.lRBasurero.isNeigbour(lRBasurero)){
            addPercept("rbasurero", atRBasureroBase);
        }

		// Percepciones de posición del agente robot rlavador
        if (model.lLavavajillasPositions.contains(lRLavador)){
            addPercept("rlavador", atRLavadorLava);
        } else if(model.lRLavador.isNeigbour(lRLavador)){
            addPercept("rlavador", atRLavadorBase);
        }  else if (model.lLacenaPositions.contains(lRLavador)){
            addPercept("rlavador", atRLavadorLace);
        }
		
        // Percepciones de posición del agente rpedidos
        if (model.lDeliveryPositions.contains(lRPedidos)){
            addPercept("rpedidos", atRPedidosDelivery);
        }
        else if (model.lFridgePositions.contains(lRPedidos)) {
            addPercept("rpedidos", atRPedidosFridge);
        }
        else if(model.lRPedidos.isNeigbour(lRPedidos)){
            addPercept("rpedidos", atRPedidosBase);
        }

        // Percepciones de posición del agente owner
        if (model.lBinPositions.contains(lOwner1)){
            addPercept("owner1", atOwnerBin1);            
        }
        if (model.lBinPositions.contains(lOwner2)){
            addPercept("owner2", atOwnerBin2);
        }
        else if(model.lCouch.isNeigbour(lOwner1)){
            addPercept("owner1", atOwnerCouch1);
        }
        else if(model.lCouch.isNeigbour(lOwner2)){
            addPercept("owner2", atOwnerCouch2);
        }
        else if(model.lFridgePositions.contains(lOwner1)){
            addPercept("owner1", atOwnerFridge1);
        }
        else if(model.lFridgePositions.contains(lOwner2)){
            addPercept("owner2", atOwnerFridge2);
        }


        // Percepción de stock de cervezas para el agente mayordomo
        if (model.fridgeOpenMayordomo) {
            addPercept("rmayordomo", Literal.parseLiteral("stock(beer,"+model.availableBeers+")"));
        }

        // Percepción de cervezas en robot de pedidos
        if(model.rpedidosBeers > 0){
            addPercept("rpedidos", Literal.parseLiteral("beer("+model.rpedidosBeers+")"));
        }

        // Percepción de basura en el entorno para el agente mayordomo
        if(model.lTrash.size() > 0){
            addPercept("rmayordomo", Literal.parseLiteral("trashInEnv("+model.lTrash.size()+")"));
            addPercept("rlimpiador", Literal.parseLiteral("trashInEnv("+model.lTrash.size()+")"));
        }

        // Percepción de stock de cervezas para el agente owner
        if (model.fridgeOpenOwner) {
            addPercept("owner1", Literal.parseLiteral("stock(beer,"+model.availableBeers+")"));
            addPercept("owner2", Literal.parseLiteral("stock(beer,"+model.availableBeers+")"));
        }

        // Percepciones de que el owner tiene cerveza para los agentes mayordomo y owner
        if (model.sipCount1 > 0) {
            addPercept("rmayordomo", hasOwnerBeer1);
            addPercept("owner1", hasOwnerBeer1);
        }
        if (model.sipCount2 > 0) {
            addPercept("rmayordomo", hasOwnerBeer2);
            addPercept("owner2", hasOwnerBeer2);
        }
    }


    @Override
    public boolean executeAction(String ag, Structure action) {
        //System.out.println("["+ag+"] doing: "+action);
        boolean result = false;

        // Acciones de movimiento
        if (action.getFunctor().equals("move_towards")){
            String l = action.getTerm(0).toString();
            Location dest = null;

            // Acciones de movimiento para el robot mayordomo
            if(ag.equals("rmayordomo")){
                if (l.equals("fridge")) {
                    dest = model.lFridge;
                } else if (l.equals("couch")) {
                    dest = model.lCouch;
                } else if(l.equals("baseRMayordomo")){
                    dest = model.lRMayordomo;
                }
            }

            // Acciones de movimiento para el robot limpiador
            else if(ag.equals("rlimpiador")){
                if(l.equals("bin")){
                    dest = model.lBin;
                } else if(l.equals("trash")){
                    dest = model.lTrash.get(0);
                } else if(l.equals("baseRLimpiador")){
                    dest = model.lRLimpiador;
                }else if (l.equals("couch")) {
                    dest = model.lCouch;
                }else if (l.equals("lavavajillas")) {
                    dest = model.lLavavajillas;
                }
            }

            // Acciones de movimiento para el robot basurero
            else if(ag.equals("rbasurero")){
                if(l.equals("bin")){
                    dest = model.lBin;
                } else if(l.equals("baseRBasurero")){
                    dest = model.lRBasurero;
                }
            }
			
			// Acciones de movimiento para el robot lavador
            else if(ag.equals("rlavador")){
                if(l.equals("lavavajillas")){
                    dest = model.lLavavajillas;
                } else if(l.equals("baseRLavador")){
                    dest = model.lRLavador;
				} else if(l.equals("lacena")){
                    dest = model.lLacena;
                }
            }


            // Acciones de movimiento para el robot de pedidos
            else if(ag.equals("rpedidos")){
                if (l.equals("delivery")){
                    dest = model.lDelivery;
                } else if (l.equals("fridge")) {
                    dest = model.lFridge;
                } else if(l.equals("baseRPedidos")){
                    dest = model.lRPedidos;
                }
            }

            // Acciones de movimiento para el owner
            else if(ag.equals("owner")){
                if (l.equals("fridge")) {
                    dest = model.lFridge;
                } else if (l.equals("couch")) {
                    dest = model.lCouch;
                } else if(l.equals("bin")){
                    dest = model.lBin;
                }
            }

            try {
                result = model.moveTowards(ag, dest);
            } catch (Exception e) {
                e.printStackTrace();
            }

        }

        // Acción de abrir el frigorifico
        else if (action.equals(openFridge) 
            && (ag.equals("rmayordomo") || (ag.equals("owner1") ||  ag.equals("owner2")))) {
            result = model.openFridge(ag);
        } 
        
        // Acción de cerrar el frigorifico
        else if (action.equals(closeFridge) 
            && (ag.equals("rmayordomo")|| (ag.equals("owner1") ||  ag.equals("owner2")))) {
            result = model.closeFridge(ag);

        }

        // Acción de coger una cerveza
        else if (action.equals(getBeerAndPinchito) 
            && (ag.equals("rmayordomo") || (ag.equals("owner1") ||  ag.equals("owner2")))) {
                result = model.getBeerAndPinchito(ag);
        }
        
        // Acción de entregar una cerveza
        else if (action.equals(handInBeer)
            && (ag.equals("rmayordomo") || (ag.equals("owner1") ||  ag.equals("owner2")))) {
            result = model.handInBeer(ag);
        } 
        
        // Acción de sorber la cerveza
        else if (action.equals(sipBeer) && (ag.equals("owner1") ||  ag.equals("owner2")) ) {
            result = model.sipBeer(ag);
        }

        // Acción de tirar basura en el entorno
        else if(action.equals(generateTrash) && (ag.equals("owner1") ||  ag.equals("owner2"))){
            result = model.generateTrash();
        }
		
		// Acción de generar platos sucios
        else if(action.equals(generatePlato) && (ag.equals("owner1") ||  ag.equals("owner2"))){
            result = model.generatePlato();
        }
        
        // Acción de recoger basura del entorno
        else if(action.equals(pickTrash) 
            && (ag.equals("rlimpiador") || (ag.equals("owner1") ||  ag.equals("owner2")))){
			result = model.pickTrash();	
		}
		
		// Acción de recoger platos del owner
        else if(action.equals(pickPlato) 
            && ag.equals("rlimpiador") ){
			result = model.pickPlato();	
		}
        
        
        // Acción de tiral la basura al cubo
        else if
        (
            (action.equals(desecharRLimpiadorTrash) && ag.equals("rlimpiador")) || 
            (action.equals(desecharOwnerTrash1) && ag.equals("owner1") || action.equals(desecharOwnerTrash2) && ag.equals("owner2"))
        ){
            result = model.desechar();	
        }
		
		//Accion de hechar los platos
		else if (action.equals(desecharP) && ag.equals("rlimpiador")){
            result = model.desecharP();	
        }
		//Accion de burner on o off
		else if(action.equals(burnerOn) && ag.equals("rbasurero")){
			result = model.cambiarCol_On();	
		}
		
		else if(action.equals(burnerOff) && ag.equals("rbasurero")){
			result = model.cambiarCol_Off();	
		}

        // Acción de vaciar el cubo de basura
        else if(action.equals(vaciarBin) && ag.equals("rbasurero")){
            result = model.vaciarPapelera();
        }
		
		// Acción de vaciar el lavavajillas
        else if(action.equals(vaciarLa) && ag.equals("rlavador")){
            result = model.vaciarLavavajillas();
        }
		
		// Acción de vaciar los platos y poner los platos en la lacena
        else if(action.equals(ponerPla) && ag.equals("rlavador")){
            result = model.ponerPlatos();
        }


        // Acción de proveer cerveza
        else if (action.getFunctor().equals("deliver") && ag.contains("supermarket")) {
            // wait 4 seconds to finish "deliver"
            try {
                Thread.sleep(4000);
                result = model.addBeerDelivery((int)((NumberTerm)action.getTerm(1)).solve());
            } catch (Exception e) {
                logger.info("Failed to execute action deliver!"+e);
            }
        }

        // Acción de coger cerveza del punto de recogida
        else if(action.getFunctor().equals("getDelivery") && ag.equals("rpedidos")){
            try {
                result = model.getDelivery((int)((NumberTerm)action.getTerm(1)).solve());
            } catch (NoValueException e) {
                logger.info("Failed to execute action deliver!"+e);
            }
        }

        // Acción de reponer las cervezas de la nevera
        else if(action.getFunctor().equals("reponer") && ag.equals("rpedidos")){
            try {
                result = model.addBeerFridge((int)((NumberTerm)action.getTerm(1)).solve());
            } catch (NoValueException e) {
                logger.info("Failed to execute action deliver!"+e);
            }
        }

        // Error en la realización de alguna acción
        else {
            logger.info("Failed to execute action "+action);
        }

        if (result) {
            updatePercepts();
            try {
                Thread.sleep(100);
            } catch (Exception e) {}
        }
        return result;
    }
}