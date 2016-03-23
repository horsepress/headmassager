// See http://curriculum.makerbot.com/daily_lessons/february/openscad_write.html for details of write.scad library
use <Write.scad>
use <Thread.scad>

$fn=100;

TEXT = "* SOMETHING *";  // text to display on side of nodes. Pad with 

r_NODE = 0.9;       	//radius of large circle of node
h_NODE=0.7;			//radius of small circle of node
count_NODE=12;			//number of nodes
angle_NODE = 30;		//maximum angle of rotation of nodes
r_TAB = 0.1;			//cross-radius of rotation tab

h_HANDLE = 3.5;		// height of handle
h_BASE = 1;     // height of base
USE_CIRCULAR_END = true;  //do handle and base have circular end?
h_CLIP = 0.1;			//clip 
l_CLIP = 3;

r_PRONG = 0.2;			// radius of prongs
l_PRONG = 35;
arc_PRONG = 90;
r_PRONG_TIP = 0.3;

r_HOLE = 0.45;			// radius of central hole
r_BOLT = 0.43;			// radius of bolt

r_NUT = 0.55;			// radius of nut body
h_NUT = 1.2;			// height of nut body
r_NUTHEX = 0.4;		// radius of hex key socket on nut
r_NUTTOP = 0.8;		// radius of top of nut (and bolt)
h_TOP = 0.2;			// height of top of nut (and bolt)

a_ROTATE = 30;			// displayed angle of rotation
h_EXPLODE = 1;			// explode factor. Set to 1 for exploded view

// derived values
h_TAB = h_NODE / 1.8;

// what to display
//node(prongHole=true,text="V");
//prong();
assembly();

module assembly(){
	//nodes and prongs
	prongUnits(rotate=a_ROTATE,translate=h_NODE,count=count_NODE);
	//bolt
	translate([0,0,-h_NODE-h_EXPLODE*(count_NODE-5)*h_NODE])bolt();
	//handle
	rotate([0,0,a_ROTATE*(-count_NODE-1)])translate([0,0,count_NODE*h_NODE+h_EXPLODE*(count_NODE+7)*h_NODE]) handle();
	//base
	rotate([180,0,0])translate([0,0,0]) handle(h=h_BASE,isBase=true);
	//locknut
	translate([0,0,count_NODE*h_NODE+h_HANDLE-h_NUT+ h_EXPLODE*(count_NODE+10)*h_NODE]) lockNut();
}


module clip (){
	rotate([0,0,-90])
	translate([-1.1,-0.1,0]){
		cube([0.3,0.2,0.1]);
		translate([0,0,-l_CLIP])cube([0.1,0.2,l_CLIP]);		
	}

//rotate([0,-80,0])rotate([0,-90,90])translate([-49.0,0,0])torusSection(0.1,50,0,10);
}


// ************ HANDLE ***************

module handle(h=h_HANDLE,isBase=false,useCircularEnd=USE_CIRCULAR_END){
	difference(){
		hull(){
			nodeShape(h=0.1);
			if(useCircularEnd){rotate([0,0,180])translate([0,0,h-h_NODE]) cylinder(h=h_NODE,r=r_NODE);}
			else{rotate([0,0,180])translate([0,0,h-0.4]) nodeShape(h=0.4);}
		}
		boltHole(h=h+1);
		// sleeve for nut
		if(isBase==false){
			translate([0,0,h-2]) cylinder(r=r_NUT,h=2);
			//negative curved arc
			translate([0,0,-0.1])curvedArc(r1=r_HOLE+r_TAB,h=h_TAB+0.15,a1=180-angle_NODE,a2=angle_NODE*3,r2=0.12);
			//negative curved arc pimple
			translate([-r_HOLE-r_TAB-0.025,0,h_TAB / 2]) nodePimple();		
		}
		// sleeve for nut top
		translate([0,0,h-h_TOP+0.01]) cylinder(r=r_NUTTOP,h=h_TOP);

	}
	if (isBase==true){
		translate([0,0,-h_TAB]){
			curvedArc(r1=r_HOLE+r_TAB,h=h_TAB,a1=180-angle_NODE,a2=angle_NODE*2);
			translate([-r_HOLE-r_TAB-0.02,0,h_TAB / 2]) nodePimple();
		}
	}else{
		translate([0,0,h_HANDLE-h_CLIP])clip();
	}
}

// ************ NUT & BOLT ******************

module bolt(h=count_NODE*h_NODE+h_HANDLE){
	boltCylinder(h=h);
	//this is the end of the bolt
	translate([0,0,-h_TOP])lockNutTop();
}

module boltCylinder(r=r_BOLT,h=count_NODE*h_NODE+h_HANDLE,hThread=0){
	cylinder(r=r,h=h-hThread,center=false,$fn=100);
	translate([0,0,h-hThread]) cylinder(r=r-0.1,h=hThread,center=false,$fn=100);
	//translate([0,0,h-hThread])metric_thread(0.6, 0.4, hThread,internal=false);
}


module lockNut(hNut=h_NUT,rNut=r_NUT,rHole=r_BOLT){
	hBody = hNut-h_TOP;
	difference(){
		cylinder (r=rNut,h=hBody);
		cylinder (r=r_BOLT,h=hBody);
		//metric_thread(0.6, 0.4, hNut,internal=true);
	}
	// this is the top
	translate([0,0,hBody]) lockNutTop();

}

module lockNutTop(rTop=r_NUTTOP,hTop=h_TOP){
		difference(){
			cylinder (r=rTop,h=hTop,$fn=20); 
			circle(r=r_NUTHEX,$fn=6);
		}
}

// *********** PRONGS ******************

module prongUnits(rotate=
30,translate=1,count=12, text=TEXT, start = 1){

	for (i = [start:count]){
		rotate([0,0,-i*rotate]) 
		translate([0,0,translate*(i-1)+i*+h_EXPLODE]) 
			prongUnit(
				r2=(l_PRONG+1.0*i),
				arc=arc_PRONG+0.2*i,
				text=text[count-i]
			);
	}
}

module prongUnit(r2,arc,text=""){
		difference(){
			union(){
				node(text=text);
				prong(r2=r2,arc=arc);
			}
			boltCylinder();
		}
}

module prong(r1=r_PRONG,r2=80,a1=0,arc=77,dip=10,zdisp=0,xdisp=r_HOLE+0.1){
	//$fn=10;
	
	difference(){
		translate([xdisp,0,zdisp+0.55])
		rotate([-0,dip,0]) 
		rotate([0,-90,-90]) 
		translate([-r2,0,0])
		union(){
			// this is the actual prong
			torusSection(r1,r2,a1,arc);  // 
			// this is the end of the prong
			rotate(a1+arc)translate([r2,0,0])sphere(r=r_PRONG_TIP,center=true);
		};
		//lop off any prong over top of node
		translate([0,0,h_NODE-0.02])nodeShape();
		boltHole();
	}
	
}

// ************** NODE ****************

module node(rHole=r_HOLE,r1=r_NODE,r2=r_NODE * 0.75,d=0.85,h=h_NODE,hTab=h_NODE / 1.8,text=text,prongHole=false){
	difference(){
		union(){
			nodeShape(rHole=rHole,r1=r1,r2=r2,d=d,h=h);
			translate([0,0,h])curvedArc(r1=rHole+r_TAB,h=hTab,a1=180-angle_NODE,a2=angle_NODE*2);
			translate([-rHole-r_TAB-0.02,0,h+hTab / 2]) nodePimple();
		}
		translate([0,0,-0.1])curvedArc(r1=rHole+r_TAB,h=hTab+0.15,a1=180-angle_NODE,a2=angle_NODE*3,r2=0.12);
		translate([-rHole-r_TAB-0.025,0,hTab / 2]) nodePimple();
		rotate([0,0,angle_NODE])translate([-rHole-r_TAB-0.025,0,hTab / 2]) nodePimple();
		writesphere(text=text,radius=r1,h=h,t=0.1,where=[0,0,h/1.7],font="knewave.dxf",east=5);
		if (prongHole){prong(r1=r_PRONG);}
	}
}

module nodeShape(rHole=r_HOLE,r1=r_NODE,r2=r_NODE * 0.75,d=r_NODE,h=h_NODE){
		difference(){
			hull(){
				cylinder(r=r1,h=h);
				translate([d,0,0]) cylinder(r=r2,h=h);
			}
			boltHole();
		}
}



module boltHole(rHole=r_HOLE,h=h_NODE+0.1){
 translate([0,0,-0.05]) cylinder(r=rHole,h=h);
}

module nodePimple(r=0.1){
	sphere(r=r); // use  cylinder(r=0.6,h=15) to check alignment
}


// ************ SHAPES ****************

module torusSection(r1,r2,a1=0,a2=90,r3=0){
	intersection(){
		difference(){
			torus(r1,r2);
		}
		block(width=1.3*r2+4*r1,height=r1*1.1,a1=a1,a2=a2);
	}
}

module torus(r1=1,r2=2){
	rotate_extrude() translate([r2,0,0]) circle(r1, $fn = 100);
}

// This produces an arc section. Used to remove portions of a circular element
module block(width=2,height=1,a1=0,a2=90,rotate=0){
	rotate([0,0,a1+rotate]){
		polyhedron(
  			points=[ 	
				// on z axis, doesn't change
				[0,0,-height],
				[0,0,height],   
				// along y axis, changes
				[width*cos(a2),width*sin(a2),-height],
				[width*cos(a2),width*sin(a2),height], 
				// along x axis, doesn't change  
				[width,0,-height],
				[width,0,height],
				// off axes, changes   
				[width*cos(a2/2),width*sin(a2/2),-height],
				[width*cos(a2/2),width*sin(a2/2),height]     
			],                                
  			triangles=[ 
				[0,2,1],[1,2,3],     // x face
				 [0,1,4],[4,1,5],     // y face    
              [2,6,3],[3,6,7],
				 [4,5,6],[5,7,6],	// back
				 [0,4,2],[2,4,6],     //bottom
				 [1,3,5],[3,7,5]      // top 
			]                        
 		);
	}
}	

module curvedArc(r1=0.6,r2=r_TAB,a1=0,a2=60,h=1){
		intersection(){
			difference(){
				cylinder(h=h,r=r1+r2);
				translate([0,0,-0.05])cylinder(r=r1-r2,h=h+0.1);
			}
			block(a1=a1,a2=a2,height=h);
		}
		rotate([0,0,a1])translate([r1,0,0])cylinder(r=r2,h=h);
		rotate([0,0,a2+a1])translate([r1,0,0])cylinder(r=r2,h=h);
}



