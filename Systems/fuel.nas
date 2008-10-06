# By G ROBIN  , that nasal code is going to be replaced by the FDM

#capacity=1348;  
#"gal_us "    Main =513  (tank[0])   ; transfer= 835   (tank[1])

numbertank=2;

UPDATE_PERIOD = 0.3;


fuelUpdate = func {	
	gals=0;
	lbs=0;
	
	#for(i=0;i<numbertank;i=i+1){
	#gals = gals + getprop("/consumables/fuel/tank[i]/level-gal_us");
	#lbs = lbs + getprop("/consumables/fuel/tank[i]/level-lb");     }
	
	
	gals = gals + getprop("/consumables/fuel/tank[0]/level-gal_us");
	gals = gals + getprop("/consumables/fuel/tank[1]/level-gal_us");
	#gals = gals + getprop("/consumables/fuel/tank[2]/level-gal_us");	
	
	lbs = lbs + getprop("/consumables/fuel/tank[0]/level-lb");
	lbs = lbs + getprop("/consumables/fuel/tank[1]/level-lb");
	#lbs = lbs + getprop("/consumables/fuel/tank[2]/level-lb");
	
	setprop("/consumables/fuel/total-fuel-gal", gals);
	setprop("/consumables/fuel/total-fuel-lb", lbs);
	 
	registerTimer();
 }
	
registerTimer = func {
	 settimer(fuelUpdate, UPDATE_PERIOD);
	 }
registerTimer();



first=1;
qty_tk0=0;
qty_tk1=0;
pump_qty=0;
setprop("/controls/flight/fuel-pump",0);

tank_transfer= func{
	if(getprop("/controls/flight/fuel-pump")==1){
		if(first=1){
			qty_tk0=getprop("consumables/fuel/tank/level-gal_us");
			qty_tk1=getprop("consumables/fuel/tank[1]/level-gal_us");
			pump_qty=513-qty_tk0;
			first=0;
		}
		if(qty_tk0>=513){
			end_full_transfer();
		}
		elsif(qty_tk1>=1){
			qty_tk0=qty_tk0+1;
			pump_qty=513-qty_tk0;
			qty_tk1=qty_tk1-1;
			setprop("consumables/fuel/tank/level-gal_us",qty_tk0);
			setprop("consumables/fuel/tank[1]/level-gal_us",qty_tk1);	
		}else{
			end_full_transfer();
		}
		settimer(tank_transfer,0.1);
	}else{
		end_part_transfer();
	}	
}

end_full_transfer=func{
	first=1;	
	setprop("/controls/flight/fuel-pump",0);
}

end_part_transfer=func{
	first=1;	
}


setlistener("/controls/flight/fuel-pump",tank_transfer,1);