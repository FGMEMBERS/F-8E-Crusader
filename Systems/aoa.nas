# $Id$
# By G ROBIN  , will be revisited, to be done by FDM

approach_speed=0;
ref_approach_speed=0;
approach_angle=0;
ref_approach_angle=0;
setprop("/orientation/alpha-deg",0);

ref_approach_speed_pls5=0;
ref_approach_speed_pls3=0;
ref_approach_speed_mns5=0;
ref_approach_speed_mns3=0;

ref_approach_angle_pls15=0;
ref_approach_angle_pls05=0;
ref_approach_angle_mns15=0;
ref_approach_angle_mns05=0;


#setprop("/sim/aoa-indicator/test_angle",1.6);

#setprop("/sim/aoa-indicator/test_speed",132);

#Initialisation   de l'index   ASI  aux valeur AOA 
setprop("/instrumentation/airspeed-indicator/landing-speed",getprop("/sim/aoa-indicator/speed"));


Cal_Aoa_Value=func{
	ref_approach_speed=getprop("/sim/aoa-indicator/speed");
	ref_approach_speed_pls5=ref_approach_speed+5;
	ref_approach_speed_pls3=ref_approach_speed+3;
	ref_approach_speed_mns5=ref_approach_speed-5;
	ref_approach_speed_mns3=ref_approach_speed-3;
	
	
#l'incidence est de 7 degres, pour satisfaire au manque de gestion de l'incidence dans le FDM, nous retirons 7 degres

	ref_approach_angle=(getprop("/sim/aoa-indicator/units")*1.5)-7;
	ref_approach_angle_pls15=ref_approach_angle+1.5;
	ref_approach_angle_pls05=ref_approach_angle+0.5;
	ref_approach_angle_mns15=ref_approach_angle-1.5;
	ref_approach_angle_mns05=ref_approach_angle-0.5;
	
	setprop("/sim/aoa-indicator/ref-approach-speed",ref_approach_speed);
	setprop("/sim/aoa-indicator/ref-approach-speed-pls5",ref_approach_speed_pls5);
	setprop("/sim/aoa-indicator/ref-approach-speed-pls3",ref_approach_speed_pls3);
	setprop("/sim/aoa-indicator/ref-approach-speed-mns5",ref_approach_speed_mns5);
	setprop("/sim/aoa-indicator/ref-approach-speed-mns3",ref_approach_speed_mns3);
	
	setprop("/sim/aoa-indicator/ref-approach-angle",ref_approach_angle);
	setprop("/sim/aoa-indicator/ref-approach-angle-pls15",ref_approach_angle_pls15);
	setprop("/sim/aoa-indicator/ref-approach-angle-pls05",ref_approach_angle_pls05);
	setprop("/sim/aoa-indicator/ref-approach-angle-mns15",ref_approach_angle_mns15);
	setprop("/sim/aoa-indicator/ref-approach-angle-mns05",ref_approach_angle_mns05);
}

Cal_Aoa_Value();








