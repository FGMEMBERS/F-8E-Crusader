


setprop("/preset/input/freqtype",0);
#***0=adf********1=dme*******2=nav**************3=comm*********4=acls*********


setprop("instrumentation/heading-indicator/nav-switch",0);
#*********    Manuel = 0 ,3   ADF  = 1  NAV =2 

setprop("/instrumentation/tacan/indicated-bearing-true-deg",0);
setprop("/instrumentation/heading-indicator/switch-tacan-acls",0);
#temporairement tacan est exclusif à TACAN  et acls dédié à MARKER ADF DME NAV
#*********ŧacan=0              acls=1







#Specifique  HSI  ACLS  instruments========
orientation=nav_heading=fromto_pointer=store_heading_marker=store_course_pointer=aig_course_pointer=aig_heading_marker=course_pointer_calc=0;

setprop("/instrumentation/heading-indicator/heading-marker",0);
setprop("/instrumentation/heading-indicator/manual-heading",0);
setprop("/instrumentation/heading-indicator/setting-manual-hdg",0);
setprop("/instrumentation/heading-indicator/course-pointer",0);
setprop("/instrumentation/heading-indicator/switch-tacan-acls",0);


setprop("/instrumentation/heading-indicator/fromto-pointer",0);

#setprop("/orientation/heading-magnetic-deg",0);
setprop("/instrumentation/nav[0]/heading-deg",0);



#aig_course_pointer  	aig_heading_markr  pour garder la position en mémoire lorsque nav-switch activé

course_pointer=func{
	if (getprop("/instrumentation/heading-indicator/switch-tacan-acls")==1){
		if (getprop("/instrumentation/heading-indicator/nav-switch")==1 ){
		course_pointer_calc=getprop("/instrumentation/adf/indicated-bearing-deg")+getprop("/orientation/heading-magnetic-deg");
			if(course_pointer_calc>360){
			setprop("/instrumentation/heading-indicator/course-pointer",course_pointer_calc-360);
			}else{
			setprop("/instrumentation/heading-indicator/course-pointer",course_pointer_calc);
			}
		}
		elsif (getprop("/instrumentation/heading-indicator/nav-switch")==2 ){
		setprop("/instrumentation/heading-indicator/course-pointer",getprop("/instrumentation/nav[0]/heading-deg"));
		}
		elsif (getprop("/instrumentation/heading-indicator/nav-switch")==3 ){
			if(aig_course_pointer==1){
			aig_course_pointer=0;
			setprop("/instrumentation/heading-indicator/setting-manual-hdg",store_course_pointer);
			}
		store_course_pointer=getprop("/instrumentation/heading-indicator/setting-manual-hdg");		
		setprop("/instrumentation/heading-indicator/course-pointer",store_course_pointer);
		}		
	}
	elsif	(getprop("/instrumentation/heading-indicator/switch-tacan-acls")==0){
	setprop("/instrumentation/heading-indicator/course-pointer",getprop("/instrumentation/tacan/indicated-bearing-true-deg")-getprop("/environment/magnetic-variation-deg"));		
	}
	if (getprop("/instrumentation/heading-indicator/nav-switch")!=3 or getprop("/instrumentation/heading-indicator/switch-tacan-acls")==0){
		if(aig_heading_marker==1){
		aig_heading_marker=0;
		setprop("/instrumentation/heading-indicator/setting-manual-hdg",store_heading_marker);
		}
	store_heading_marker=getprop("/instrumentation/heading-indicator/setting-manual-hdg");
	setprop("/instrumentation/heading-indicator/heading-marker",store_heading_marker);
	}	
	settimer(course_pointer,0,1);
}
course_pointer();


survey_nav_switch=func{	
	aig_course_pointer=1;
	aig_heading_marker=1;	
}

setlistener("/instrumentation/heading-indicator/nav-switch",survey_nav_switch,3);







survey_autopilot=func{
	if(getprop("fdm/jsbsim/instruments/autopilot-hold")) {

			if (getprop("fdm/jsbsim/instruments/autopilot-lock-true-heading")==1){
			setprop("/autopilot/locks/heading","true-heading-hold");
                        }
                        if (getprop("fdm/jsbsim/instruments/autopilot-lock-heading-bug")==1){
			setprop("/autopilot/locks/heading","dg-heading-hold");
			}
                        if (getprop("fdm/jsbsim/instruments/autopilot-lock-altitude")==1){
			setprop("/autopilot/locks/altitude","altitude-hold");
			}
			if (getprop("fdm/jsbsim/instruments/autopilot-lock-aoa")==1){
			setprop("/autopilot/locks/altitude","aoa-hold");
			}
	}else{
	setprop("/autopilot/locks/heading", "");
        setprop("/autopilot/locks/altitude", "");
	}
}
setlistener("fdm/jsbsim/instruments/autopilot-hold",survey_autopilot);
