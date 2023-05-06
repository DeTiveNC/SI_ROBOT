import jason.environment.grid.*;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;

/** class that implements the View of Domestic Robot application */
public class HouseView extends GridWorldView {

    HouseModel hmodel;
	int cont = 0;

    public HouseView(HouseModel model) {
        super(model, "Domestic Robot", 700);
        hmodel = model;
        defaultFont = new Font("Arial", Font.BOLD, 11); // change default font
        setVisible(true);
        repaint();
    }

    /** draw application objects */
    @Override
    public void draw(Graphics g, int x, int y, int object) {
        super.drawAgent(g, x, y, Color.lightGray, -1);
		cont++;

        // Dibujado de los elementos que no son agentes
        switch (object) {
        
            // Dibujado del frigorifico
            case HouseModel.FRIDGE:
                super.drawAgent(g, x, y, Color.WHITE, -1);
                g.setColor(Color.black);
                drawString(g, x, y, defaultFont, "F=(B:"+ hmodel.availableBeers + " ,P:" + hmodel.availablePinch +")");
                break;

            // Dibujado del sillón del owner
            case HouseModel.COUCH:
                super.drawAgent(g, x, y, Color.PINK, -1);
                g.setColor(Color.black);
                drawString(g, x, y, defaultFont, "Couch");
                break;

            // Dibujado de la zona de entrega
            case HouseModel.DELIVERY:
                super.drawAgent(g, x, y, Color.GRAY, -1);
                g.setColor(Color.black);
                drawString(g, x, y, defaultFont, "Delivery");
                break;
            
            // Dibujado del cubo de basura
            case HouseModel.BIN:
                String b = "Bin";
                if (hmodel.cansInTrash > 0) {
                    b +=  " ("+hmodel.cansInTrash+"/10)";
                }
				if(hmodel.burnerOn == false){
                super.drawAgent(g, x, y, Color.RED, -1);
				} else if(hmodel.burnerOn == true) {
				super.drawAgent(g,x,y,Color.GREEN, -1);	
				}
                g.setColor(Color.black);
                drawString(g, x, y, defaultFont, b);
                break;

            // Dibujado de la basura repartida por el entorno
            case HouseModel.TRASH:
                super.drawAgent(g, x, y, Color.LIGHT_GRAY, -1);
                g.setColor(Color.black);
                drawString(g, x, y, defaultFont, "Trash");
                break;
			// Dibujo para el lavavajillas
			case HouseModel.LAVAVAJILLAS:
				String a = "Lav";
				Color c = Color.yellow;
                if (hmodel.platosLimpiar > 0) {
                    a +=  " ("+hmodel.platosLimpiar+"/10)";
                }
                super.drawAgent(g, x, y, c, -1);
                g.setColor(Color.black);
                drawString(g, x, y, defaultFont, a);
                break;
				
			// Dibujo para la lacena
            case HouseModel.LACENA:
				String d = "Lac";
				Color r = Color.orange;
                if (hmodel.platosLimpios == 0) {
                    d +=  " ("+hmodel.platosEnLacena+"/10)";
                }
                super.drawAgent(g, x, y, r, -1);
                g.setColor(Color.black);
                drawString(g, x, y, defaultFont, d);
                break;
       
            // Dibujado de los posibles obstaculos del entorno
            case HouseModel.OBSTACULE:
                super.drawAgent(g, x, y, Color.darkGray, -1);
                g.setColor(Color.black);
                drawString(g, x, y, defaultFont, "Obstacule");
                break;
           
        }
		if(cont > 50){
        repaint();
		cont = 0;
		}
    }

    @Override
    public void drawAgent(Graphics g, int x, int y, Color c, int id) {

        // Dibujado de los elementos que son agentes
        switch(id){

            // Dibujado del agente rmayordomo
            case 0:
                c = Color.yellow;
                if (hmodel.carryingBeerMayordomo) c = Color.orange;
                super.drawAgent(g, x, y, c, -1);
                g.setColor(Color.black);
                super.drawString(g, x, y, defaultFont, "May");
                break;

            // Dibujado del agente rlimpiador
            case 1:
                c = Color.ORANGE;
                super.drawAgent(g, x, y, c, -1);
                g.setColor(Color.black);
                super.drawString(g, x, y, defaultFont, "Limp");
                break;
            
            // Dibujado del agente rbasurero
            case 2:
                c = Color.CYAN;
                super.drawAgent(g, x, y, c, -1);
                g.setColor(Color.black);
                super.drawString(g, x, y, defaultFont, "Bas");
                break;

            // Dibujado del agente rpedidos
            case 3:
                c = Color.magenta;
                super.drawAgent(g, x, y, c, -1);
                g.setColor(Color.black);
                super.drawString(g, x, y, defaultFont, "Ped");
                break;

			// Dibujado del agente owner
            case 4: 
                super.drawAgent(g, x, y, Color.BLUE, -1);
                String o = "Owner";
                if (hmodel.sipCount > 0) {
                    o +=  " ("+hmodel.sipCount+")";
                }
                g.setColor(Color.black);
                drawString(g, x, y, defaultFont, o);
                break;
        }
    }

    @Override
    public void drawEmpty(Graphics g, int x, int y){
        g.setColor(new Color(0xEEEEEE));
        g.fillRect(x * cellSizeW + 1, y * cellSizeH+1, cellSizeW-1, cellSizeH-1);
        g.setColor(Color.lightGray);
        g.drawRect(x*cellSizeW, y*cellSizeH, cellSizeW, cellSizeH);
    }
}
