# $Id$
# By G ROBIN  , 

#===========================Radar ==================

#=========2 first dedicated to AI aircrafts (switch =1, =2 )========

#=========4 last dedicated to MP (switch =3 =4 =5 =6) aircrafts======

#===========7 to tacan===============================

altitude_me=0;

switch = 0;
reactivate = 0;
aicount_n=aicount=getprop("/ai/models/count");
setprop("/instrumentation/radar/alt-coef",1);
setprop("/instrumentation/radar/nm-coef",1);
setprop("/instrumentation/radar/alt-range",4000);
imp=0;
blanc="                ";
mpdummy="mpdummy";
swin_range= 0;

range_nm=[];
rotation=[];
altitude=[];
velocity=[];
heading=[];
select=[];
in_range=[];
no_prop=[];
setsize(range_nm,10);
setsize(rotation,10);
setsize(altitude,10);
setsize(velocity,10);
setsize(select,10);
setsize(in_range,10);
setsize(heading,10);
setsize(no_prop,10);

alt_tab=[];
setsize(alt_tab,8);
alt_tab[1]=1;
alt_tab[2]=2;
alt_tab[3]=4;
alt_tab[4]=8;
alt_tab[5]=16;
alt_tab[6]=32;
alt_tab[7]=64;

x_shift=[];
setsize(x_shift,10);
y_shift=[];
setsize(y_shift,10);
z_shift=[];
setsize(z_shift,10);
callsign=[];
setsize(callsign,10);
mark=[];
setsize(mark,10);

echo_nb=0;
echo_pos_x_shift=0;
echo_pos_y_shift=0;
echo_pos_z_shift=0;

for(i=0;i<10;i=i+1){
		in_range[i]=0;
		range_nm[i]=0;
		rotation[i]=0;
		x_shift[i]=0;
		y_shift[i]=0;
		z_shift[i]=0;
		altitude[i]=0;
		velocity[i]=0;
		heading[i]=0;
		select[i]=1;		
		no_prop[i]=0;	
		callsign[i]=blanc;
		mark[i]=0;
	}

#Init Tacan non selecté===============================
select[6]=0;
#Init Select les autres====================================	
for(i=0;i<10;i=i+1){
		setprop("/instrumentation/radar/aircraft["~i~"]/radar/range-nm",range_nm[i]);
		setprop("/instrumentation/radar/aircraft["~i~"]/radar/select",select[i]);
	}	   


#================Radar Fonction============================================


radar = func {
	switch = getprop("/instrumentation/radar/switch");

	if (switch == 0){	
		setprop("/instrumentation/radar/aircraft-target/altitude-ft",0);
		setprop("/instrumentation/radar/aircraft-target/airspeed",0);
		setprop("/instrumentation/radar/aircraft-target/true-heading",0);
		setprop("/instrumentation/radar/aircraft-target/range-nm",0);
	}

		
#=============AI  scenario=====De 0  a 1================


	for(i=0;i<2;i=i+1){
	
		in_range[i] = getprop("/ai/models/aircraft["~i~"]/radar/in-range");
		if (in_range[i] == 1){
			setprop("/instrumentation/radar/aircraft["~i~"]/radar/mark",1);
		} else {
			setprop("/instrumentation/radar/aircraft["~i~"]/radar/mark",0);
		}	
	
		select[i] = getprop("/instrumentation/radar/aircraft["~i~"]/radar/select");
			
		if (select[i] == 1){
			if (props.globals.getNode("/ai/models/aircraft["~i~"]") != nil){		
				range_nm[i] = getprop("/ai/models/aircraft["~i~"]/radar/range-nm");
				if (in_range[i] != 1){
					setprop("/instrumentation/radar/aircraft["~i~"]/radar/range-nm",0);
				} else {
					setprop("/instrumentation/radar/aircraft["~i~"]/radar/range-nm",range_nm[i]);
					
					x_shift[i] = getprop("/ai/models/aircraft["~i~"]/radar/x-shift");
					setprop("/instrumentation/radar/aircraft["~i~"]/radar/x-shift",x_shift[i]);
					
					y_shift[i] = getprop("/ai/models/aircraft["~i~"]/radar/y-shift");
					setprop("/instrumentation/radar/aircraft["~i~"]/radar/y-shift",y_shift[i]);
					
					rotation[i] = getprop("/ai/models/aircraft["~i~"]/radar/rotation");
						setprop("/instrumentation/radar/aircraft[1]/radar/rotation",rotation[i]);
						
					altitude[i]=getprop("/ai/models/aircraft["~i~"]/position/altitude-ft");
					altitude_me=getprop("/position/altitude-ft");
					z_shift[i]=altitude[i]-altitude_me;
					setprop("/instrumentation/radar/aircraft["~i~"]/radar/z-shift",z_shift[i]);
				}
			}else{
			setprop("/instrumentation/radar/aircraft["~i~"]/radar/mark",0);
			range_nm[i] = 0;
			} 
		}	
			
# ici on traite l'affichage de l'avion AI que l'on désire surveiller

			if (switch == i+1){
				if (range_nm[i] == 0 or in_range[i] != 1) {				
					setprop("/instrumentation/radar/aircraft-target/altitude-ft",0);
					setprop("/instrumentation/radar/aircraft-target/airspeed",0);
					setprop("/instrumentation/radar/aircraft-target/true-heading",0);
					setprop("/instrumentation/radar/aircraft-target/range-nm",0);
					setprop("/instrumentation/radar/aircraft-target/callsign",blanc);
					
				} else {
				
					altitude[i] = getprop("/ai/models/aircraft["~i~"]/position/altitude-ft");
					setprop("/instrumentation/radar/aircraft-target/altitude-ft",altitude[i]);
					
					velocity[i] = getprop("/ai/models/aircraft["~i~"]/velocities/true-airspeed-kt");
					setprop("/instrumentation/radar/aircraft-target/airspeed",velocity[i]);
					
					heading[i] = getprop("/ai/models/aircraft["~i~"]/orientation/true-heading-deg");
					setprop("/instrumentation/radar/aircraft-target/true-heading",heading[i]);
					
					callsign[i] = getprop("/ai/models/aircraft["~i~"]/callsign");
					setprop("/instrumentation/radar/aircraft-target/callsign",callsign[i]);
					
					setprop("/instrumentation/radar/aircraft-target/range-nm",range_nm[i]);
				}
			}
		
	}
#=================Multiplayer====De 2 a 5================	

#imp est l'index  pour suivre les avions multiplayer  dans la table  /instrumentation/radar/aircraft
	imp=1;
	for(i=0;i<8;i=i+1){
		
		
#mise à jour de l'espace de travail
#swin_range permet de déterminer si l'avion est in_range pour être dans la  table ou non
# multiplayer vide ou callsign mpdummy => pas de chargement
		
		if (props.globals.getNode("/ai/models/multiplayer["~i~"]") != nil)  {
			swin_range= getprop("/ai/models/multiplayer["~i~"]/radar/in-range");
			if (getprop("/ai/models/multiplayer["~i~"]/callsign") == mpdummy) {
			swin_range=0;
			}
			} else {
			swin_range=0;
			
			}
			
				if (swin_range == 1 ) {
#regarde si le niveau de la  table est vide	si oui charge les données sur le niveau
					if (getprop("/instrumentation/radar/aircraft["~imp~"]/radar/in-range") != 0 or imp < 2) {
					imp=imp+1;
					}
					mark[imp] = 1;
					in_range[imp] = swin_range;
					swin_range= 0;
					range_nm[imp] = getprop("/ai/models/multiplayer["~i~"]/radar/range-nm");
					in_range[imp] = getprop("/ai/models/multiplayer["~i~"]/radar/in-range");
					x_shift[imp] = getprop("/ai/models/multiplayer["~i~"]/radar/x-shift");
					y_shift[imp] = getprop("/ai/models/multiplayer["~i~"]/radar/y-shift");
					rotation[imp] = getprop("/ai/models/multiplayer["~i~"]/radar/rotation");
					callsign[imp] =  getprop("/ai/models/multiplayer["~i~"]/callsign");
					altitude[imp]=getprop("/ai/models/multiplayer["~i~"]/position/altitude-ft");
					velocity[imp] = getprop("/ai/models/multiplayer["~i~"]/velocities/true-airspeed-kt");
					heading[imp] = getprop("/ai/models/multiplayer["~i~"]/orientation/true-heading-deg");
					select[imp] = getprop("/instrumentation/radar/aircraft["~imp~"]/radar/select");
					
					setprop("/instrumentation/radar/aircraft["~imp~"]/radar/mark",mark[imp]);
					setprop("/instrumentation/radar/aircraft["~imp~"]/radar/in-range",in_range[imp]);
					altitude_me=getprop("/position/altitude-ft");
					z_shift[imp]=altitude[imp]-altitude_me;
					
					
				
				} else {
					imp=imp+1;
					mark[imp] = 0;
					x_shift[imp]=0;
					y_shift[imp]=0;
					z_shift[imp] =0;
					rotation[imp]=0;
					callsign[imp]=0;
					altitude[imp]=0;
					velocity[imp] =0;
					heading[imp]=0;
					in_range[imp] =0;
					range_nm[imp] =0;
					setprop("/instrumentation/radar/aircraft["~imp~"]/radar/mark",0);
					setprop("/instrumentation/radar/aircraft["~imp~"]/radar/in-range",0);
					setprop("/instrumentation/radar/aircraft["~imp~"]/radar/range-nm",0);
					}
		
#select identifie la volonté d'affichage du marqueur sur le radar ou non (voir fichiers xml)

		if (select[imp] == 1){
					setprop("/instrumentation/radar/aircraft["~imp~"]/radar/range-nm",range_nm[imp]);
					setprop("/instrumentation/radar/aircraft["~imp~"]/radar/x-shift",x_shift[imp]);
					setprop("/instrumentation/radar/aircraft["~imp~"]/radar/y-shift",y_shift[imp]);
					setprop("/instrumentation/radar/aircraft["~imp~"]/radar/rotation",rotation[imp]);				
					setprop("/instrumentation/radar/aircraft["~imp~"]/radar/z-shift",z_shift[imp]);
				
		}	
			
			
# ici on traite l'affichage de l'avion multiplayer que l'on désire surveiller

		if (switch == imp+1){	
			if (in_range[imp] != 1 ) {
				setprop("/instrumentation/radar/aircraft-target/altitude-ft",0);
				setprop("/instrumentation/radar/aircraft-target/airspeed",0);
				setprop("/instrumentation/radar/aircraft-target/true-heading",0);
				setprop("/instrumentation/radar/aircraft-target/range-nm",0);
				setprop("/instrumentation/radar/aircraft-target/callsign",blanc);
			} else {
				altitude[imp] = getprop("/ai/models/multiplayer["~i~"]/position/altitude-ft");
				
				callsign[imp] = getprop("/ai/models/multiplayer["~i~"]/callsign");
					
				setprop("/instrumentation/radar/aircraft-target/airspeed",velocity[imp]);
				setprop("/instrumentation/radar/aircraft-target/altitude-ft",altitude[imp]);
				setprop("/instrumentation/radar/aircraft-target/true-heading",heading[imp]);
				setprop("/instrumentation/radar/aircraft-target/range-nm",range_nm[imp]);
				setprop("/instrumentation/radar/aircraft-target/callsign",callsign[imp]);
			}
		}
		
	}

#==============================Tacan======================================
	if(props.globals.getNode("/instrumentation/tacan/display")!=nil){
		if(getprop("/instrumentation/tacan/in-range")==1){
			tacan_x_shift=getprop("/instrumentation/tacan/display/x-shift");
			tacan_y_shift=getprop("/instrumentation/tacan/display/y-shift");
			#tacan_rotation=getprop("/orientation/heading-deg");
			tacan_range_nm=getprop("/instrumentation/tacan/indicated-distance-nm");
			setprop("/instrumentation/radar/aircraft[6]/radar/mark",1);
		
		}else{
			tacan_x_shift=0;
			tacan_y_shift=0;
			tacan_rotation=0;
			tacan_range_nm=0;
			setprop("/instrumentation/radar/aircraft[6]/radar/mark",0);
		}	
		setprop("/instrumentation/radar/aircraft[6]/radar/x-shift",tacan_x_shift);
		setprop("/instrumentation/radar/aircraft[6]/radar/y-shift",tacan_y_shift);
		#setprop("/instrumentation/radar/aircraft[6]/radar/rotation",tacan_rotation);
		setprop("/instrumentation/radar/aircraft[6]/radar/range-nm",tacan_range_nm);
	}else{
	setprop("/instrumentation/radar/aircraft[6]/radar/mark",0);
	}
	
	settimer(radar,0.6);
	}


#=====pour l'animation  le "nm range" de référence sera 40==================================
#=====pour l'animation  le "altitude range" de référence sera 4000==================================


		   
Echo_pos=func{	
	for(i=0;i<7;i=i+1){
	echo_nb=i;	
		radar_alt_coef=getprop("/instrumentation/radar/alt-coef");
		radar_alt_scale=alt_tab[radar_alt_coef];
		setprop("/instrumentation/radar/alt-range",4000/radar_alt_scale);
	
		radar_nm_coef=getprop("/instrumentation/radar/nm-coef");
		radar_nm_coef_value=alt_tab[radar_nm_coef];
		radar_range=40/radar_nm_coef_value;
		setprop("/instrumentation/radar/range",radar_range);
		
		if (getprop("/instrumentation/radar/aircraft["~echo_nb~"]/radar/x-shift")!=nil){			
			echo_pos_x_shift=getprop("/instrumentation/radar/aircraft["~echo_nb~"]/radar/x-shift");
			echo_pos_x_shift=echo_pos_x_shift/radar_range*40;
			setprop("/instrumentation/radar/echo["~echo_nb~"]/x-shift",echo_pos_x_shift);
		}
		if (getprop("/instrumentation/radar/aircraft["~echo_nb~"]/radar/y-shift")!=nil){			
			echo_pos_y_shift=getprop("/instrumentation/radar/aircraft["~echo_nb~"]/radar/y-shift");
			echo_pos_y_shift=echo_pos_y_shift/radar_range*40;
			setprop("/instrumentation/radar/echo["~echo_nb~"]/y-shift",echo_pos_y_shift);
		}
		if (getprop("/instrumentation/radar/aircraft["~echo_nb~"]/radar/z-shift")!=nil){			
			echo_pos_z_shift=getprop("/instrumentation/radar/aircraft["~echo_nb~"]/radar/z-shift");
			echo_pos_z_shift=echo_pos_z_shift*radar_alt_scale;
			setprop("/instrumentation/radar/echo["~echo_nb~"]/z-shift",echo_pos_z_shift);
			}
	}
	settimer(Echo_pos,0.6);
}

Echo_pos();



radar();








