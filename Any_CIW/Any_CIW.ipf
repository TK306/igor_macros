#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// Any CIW - color index maker - ver 1.7
// Takashi Kono   2020.10.04


// Input full path of where CIW template folder in your PC
	strconstant USERFOLDER="_default_" // This is used only when creating panel "CIW Maker"
// end


Macro Call_CIW_Maker()
	if(strlen(WinList("Any_CIW_panel", ";", "WIN:64")))
		DoWindow/F Any_CIW_panel
	else
		ac_init()
		Any_CIW_panel()
		ac_search_info()
		ac_make_prof()
		ac_do()
		ac_load_defaulttemps()
	endif
End

Function ac_init()
	string nf=GetDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O root:Any_CIW
	NewDataFolder/O root:Any_CIW:Gallery
	NewDataFolder/O root:Any_CIW:info
	NewDataFolder/O/S root:Any_CIW:misc
	string/g s_dfpath
	if(StrLen(s_dfpath)==0)
		if(StrLen(USERFOLDER)==0 || StringMatch(USERFOLDER,"_default_"))
			string/g s_dfpath=SpecialDirPath("Igor Pro User Files", 0, 0, 0)+"User Procedures:CIW_template:"
		else
			string/g s_dfpath=USERFOLDER
		endif
	endif
	
	string/g s_ws="Any_CIW_original"
	string/g s_name=s_ws
	string ws=s_ws
	variable/g v_intmax=100
	variable/g v_intmin=0
	variable/g v_ciwsize=256
	variable/g v_sl0=0
	variable/g v_sl1=0
	variable/g v_sl2=50
	variable/g v_sl3=50
	variable/g v_sl4=50
	variable/g v_sl5=50
	variable/g v_sl6=0
	variable/g v_sl7=0
	variable/g v_sl8=0
	variable/g v_sl9=0
	variable/g v_prof=1
	variable/g v_prof_xn=2
	variable/g v_prof_pk=10
	variable/g v_rev=0
	string/g s_proflist="x;logistic;(1-cos(pi*x))/2 ;x^2n;-(x-1)^2n+1;1-cos(pi/2*x);sin(pi/2*x)"
	make/O/N=(10,4) $("panel_info")
	make/O/N=256 $("prof")
	wave piw=$("panel_info")
	piw=0
	
	piw[2][0]=65535
	piw[2][1]=0
	piw[2][2]=0
	
	piw[3][0]=65535
	piw[3][1]=65535
	piw[3][2]=65535
	
	piw[4][0]=0
	piw[4][1]=0
	piw[4][2]=65535
	
	piw[5][0]=52428
	piw[5][1]=52425
	piw[5][2]=1
	
	
	variable/g v_slmax=100
	variable/g v_slmin=0
	make/O/N=(10,3) $("view_CIW")
	
	SetDataFolder root:Any_CIW:Gallery
	make/O/N=(10,3) $ws
	
	SetDataFolder root:Any_CIW:misc
	make/O/N=(256,1) $("view")
	
	SetDataFolder $nf
End

Window Any_CIW_panel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(1209,105,1485,646) as "CIW Maker"
	ModifyPanel fixedSize=1
	SetDrawLayer UserBack
	DrawText 211,122,"High"
	DrawText 17,122,"Low"
	SetDrawEnv arrow= 2
	DrawLine 141,18,168,18
	SetVariable setvar_name,pos={11.00,9.00},size={125.00,18.00},bodyWidth=60,proc=ac_SetVarProc_name,title="CIW Name :"
	SetVariable setvar_name,limits={-inf,inf,0},value= root:Any_CIW:misc:s_name
	PopupMenu popup_select,pos={160.00,9.00},size={113.00,19.00},proc=ac_PopMenuProc_name,title="Select from Exists"
	PopupMenu popup_select,mode=0,value= #"ac_select_str()"
	Button button_set_targ,pos={4.00,32.00},size={60.00,20.00},proc=ac_ButtonProc_targ,title="set wave"
	SetVariable setvar_targ,pos={74.00,33.00},size={50.00,18.00},proc=ac_SetVarProc_targ,title=" "
	SetVariable setvar_targ,limits={-inf,inf,0},value= root:Any_CIW:misc:s_targw
	SetVariable setvar_intmin,pos={139.00,34.00},size={64.00,18.00},bodyWidth=40,proc=ac_SetVarProc_do,title="min"
	SetVariable setvar_intmin,value= root:Any_CIW:misc:v_intmin
	SetVariable setvar_intmax,pos={207.00,34.00},size={66.00,18.00},bodyWidth=40,proc=ac_SetVarProc_do,title="max"
	SetVariable setvar_intmax,value= root:Any_CIW:misc:v_intmax
	SetVariable text_min,pos={13.00,76.00},size={30.00,18.00},frame=0
	SetVariable text_min,value= _STR:"min",noedit= 1
	SetVariable text_max,pos={12.00,55.00},size={30.00,18.00},frame=0
	SetVariable text_max,value= _STR:"max",noedit= 1
	Slider slider_max,pos={42.00,56.00},size={165.00,22.00},proc=as_SliderProc_do
	Slider slider_max,limits={0,100,0.1},variable= root:Any_CIW:misc:v_slmax,vert= 0,ticks= 0
	Slider slider_min,pos={42.00,78.00},size={165.00,22.00},proc=as_SliderProc_do
	Slider slider_min,limits={0,100,0.1},variable= root:Any_CIW:misc:v_slmin,vert= 0,ticks= 0
	SetVariable setvar_max,pos={212.00,56.00},size={55.00,18.00},proc=ac_SetVarProc_do,title=" "
	SetVariable setvar_max,format="%g %"
	SetVariable setvar_max,limits={0,100,1},value= root:Any_CIW:misc:v_slmax
	SetVariable setvar_min,pos={212.00,79.00},size={55.00,18.00},proc=ac_SetVarProc_do,title=" "
	SetVariable setvar_min,format="%g %"
	SetVariable setvar_min,limits={0,100,1},value= root:Any_CIW:misc:v_slmin
	CheckBox check_rev,pos={10.00,132.00},size={32.00,15.00},proc=ac_CheckProc_rev,title="rev"
	CheckBox check_rev,variable= root:Any_CIW:misc:v_rev,side= 1
	SetVariable setvar_dens,pos={143.00,131.00},size={113.00,18.00},bodyWidth=60,proc=ac_SetVarProc_do,title="CIW size :"
	SetVariable setvar_dens,limits={2,inf,1},value= root:Any_CIW:misc:v_ciwsize
	PopupMenu popup_prof,pos={15.00,152.00},size={87.00,19.00},proc=ac_PopMenuProc_prof,title="Grad. profile"
	PopupMenu popup_prof,mode=0,value= #"ac_prof_str()"
	SetVariable setvar_prof_view,pos={22.00,172.00},size={110.00,18.00},bodyWidth=110,title=" "
	SetVariable setvar_prof_view,frame=0,value= root:Any_CIW:misc:s_prof,noedit= 1
	SetVariable setvar_prof_xn,pos={113.00,154.00},size={59.00,18.00},bodyWidth=40,disable=3,proc=ac_SetVarProc_do,title="n="
	SetVariable setvar_prof_xn,limits={1,inf,1},value= root:Any_CIW:misc:v_prof_xn
	SetVariable setvar_prof_pk,pos={113.00,154.00},size={58.00,18.00},bodyWidth=40,disable=3,proc=ac_SetVarProc_do,title="k="
	SetVariable setvar_prof_pk,limits={1,inf,1},value= root:Any_CIW:misc:v_prof_pk
	SetVariable setvar_prof_x0,pos={107.00,174.00},size={64.00,18.00},bodyWidth=40,disable=3,proc=ac_SetVarProc_do,title="x0="
	SetVariable setvar_prof_x0,limits={-1,1,0.1},value= root:Any_CIW:misc:v_prof_x0
	PopupMenu popup_cl0,pos={18.00,200.00},size={50.00,19.00},proc=ac_PopMenuProc_cl
	PopupMenu popup_cl0,mode=1,popColor= (0,0,0),value= #"\"*COLORPOP*\""
	PopupMenu popup_cl1,pos={18.00,230.00},size={50.00,19.00},proc=ac_PopMenuProc_cl
	PopupMenu popup_cl1,mode=1,popColor= (0,0,0),value= #"\"*COLORPOP*\""
	PopupMenu popup_cl2,pos={18.00,260.00},size={50.00,19.00},proc=ac_PopMenuProc_cl
	PopupMenu popup_cl2,mode=1,popColor= (65535,0,0),value= #"\"*COLORPOP*\""
	PopupMenu popup_cl3,pos={18.00,290.00},size={50.00,19.00},proc=ac_PopMenuProc_cl
	PopupMenu popup_cl3,mode=1,popColor= (65535,65535,65535),value= #"\"*COLORPOP*\""
	PopupMenu popup_cl4,pos={18.00,320.00},size={50.00,19.00},proc=ac_PopMenuProc_cl
	PopupMenu popup_cl4,mode=1,popColor= (0,0,65535),value= #"\"*COLORPOP*\""
	PopupMenu popup_cl5,pos={18.00,350.00},size={50.00,19.00},proc=ac_PopMenuProc_cl
	PopupMenu popup_cl5,mode=1,popColor= (52428,52425,1),value= #"\"*COLORPOP*\""
	PopupMenu popup_cl6,pos={18.00,380.00},size={50.00,19.00},proc=ac_PopMenuProc_cl
	PopupMenu popup_cl6,mode=1,popColor= (0,0,0),value= #"\"*COLORPOP*\""
	PopupMenu popup_cl7,pos={18.00,410.00},size={50.00,19.00},proc=ac_PopMenuProc_cl
	PopupMenu popup_cl7,mode=1,popColor= (0,0,0),value= #"\"*COLORPOP*\""
	PopupMenu popup_cl8,pos={18.00,440.00},size={50.00,19.00},proc=ac_PopMenuProc_cl
	PopupMenu popup_cl8,mode=1,popColor= (0,0,0),value= #"\"*COLORPOP*\""
	PopupMenu popup_cl9,pos={18.00,470.00},size={50.00,19.00},proc=ac_PopMenuProc_cl
	PopupMenu popup_cl9,mode=1,popColor= (0,0,0),value= #"\"*COLORPOP*\""
	Slider slider_cl1,pos={75.00,210.00},size={146.00,22.00},proc=as_SliderProc_do
	Slider slider_cl1,limits={0,100,1},variable= root:Any_CIW:misc:v_sl1,side= 2,vert= 0,ticks= 0
	Slider slider_cl2,pos={75.00,240.00},size={146.00,22.00},proc=as_SliderProc_do
	Slider slider_cl2,limits={0,100,1},variable= root:Any_CIW:misc:v_sl2,side= 2,vert= 0,ticks= 0
	Slider slider_cl3,pos={75.00,270.00},size={146.00,22.00},proc=as_SliderProc_do
	Slider slider_cl3,limits={0,100,1},variable= root:Any_CIW:misc:v_sl3,side= 2,vert= 0,ticks= 0
	Slider slider_cl4,pos={75.00,300.00},size={146.00,22.00},proc=as_SliderProc_do
	Slider slider_cl4,limits={0,100,1},variable= root:Any_CIW:misc:v_sl4,side= 2,vert= 0,ticks= 0
	Slider slider_cl5,pos={75.00,330.00},size={146.00,22.00},proc=as_SliderProc_do
	Slider slider_cl5,limits={0,100,1},variable= root:Any_CIW:misc:v_sl5,side= 2,vert= 0,ticks= 0
	Slider slider_cl6,pos={75.00,360.00},size={146.00,22.00},proc=as_SliderProc_do
	Slider slider_cl6,limits={0,100,1},variable= root:Any_CIW:misc:v_sl6,side= 2,vert= 0,ticks= 0
	Slider slider_cl7,pos={75.00,390.00},size={146.00,22.00},proc=as_SliderProc_do
	Slider slider_cl7,limits={0,100,1},variable= root:Any_CIW:misc:v_sl7,side= 2,vert= 0,ticks= 0
	Slider slider_cl8,pos={75.00,420.00},size={146.00,22.00},proc=as_SliderProc_do
	Slider slider_cl8,limits={0,100,1},variable= root:Any_CIW:misc:v_sl8,side= 2,vert= 0,ticks= 0
	Slider slider_cl9,pos={75.00,450.00},size={146.00,22.00},proc=as_SliderProc_do
	Slider slider_cl9,limits={0,100,1},variable= root:Any_CIW:misc:v_sl9,side= 2,vert= 0,ticks= 0
	SetVariable setvar_cp1,pos={226.00,213.00},size={50.00,18.00},title=" "
	SetVariable setvar_cp1,format="%g %",frame=0
	SetVariable setvar_cp1,limits={-inf,inf,0},value= root:Any_CIW:misc:v_cp1,noedit= 1
	SetVariable setvar_cp2,pos={226.00,243.00},size={50.00,18.00},title=" "
	SetVariable setvar_cp2,format="%g %",frame=0
	SetVariable setvar_cp2,limits={-inf,inf,0},value= root:Any_CIW:misc:v_cp2,noedit= 1
	SetVariable setvar_cp3,pos={226.00,273.00},size={50.00,18.00},title=" "
	SetVariable setvar_cp3,format="%g %",frame=0
	SetVariable setvar_cp3,limits={-inf,inf,0},value= root:Any_CIW:misc:v_cp3,noedit= 1
	SetVariable setvar_cp4,pos={226.00,303.00},size={50.00,18.00},title=" "
	SetVariable setvar_cp4,format="%g %",frame=0
	SetVariable setvar_cp4,limits={-inf,inf,0},value= root:Any_CIW:misc:v_cp4,noedit= 1
	SetVariable setvar_cp5,pos={226.00,333.00},size={50.00,18.00},title=" "
	SetVariable setvar_cp5,format="%g %",frame=0
	SetVariable setvar_cp5,limits={-inf,inf,0},value= root:Any_CIW:misc:v_cp5,noedit= 1
	SetVariable setvar_cp6,pos={226.00,363.00},size={50.00,18.00},title=" "
	SetVariable setvar_cp6,format="%g %",frame=0
	SetVariable setvar_cp6,limits={-inf,inf,0},value= root:Any_CIW:misc:v_cp6,noedit= 1
	SetVariable setvar_cp7,pos={226.00,393.00},size={50.00,18.00},title=" "
	SetVariable setvar_cp7,format="%g %",frame=0
	SetVariable setvar_cp7,limits={-inf,inf,0},value= root:Any_CIW:misc:v_cp7,noedit= 1
	SetVariable setvar_cp8,pos={226.00,423.00},size={50.00,18.00},title=" "
	SetVariable setvar_cp8,format="%g %",frame=0
	SetVariable setvar_cp8,limits={-inf,inf,0},value= root:Any_CIW:misc:v_cp8,noedit= 1
	SetVariable setvar_cp9,pos={226.00,453.00},size={50.00,18.00},title=" "
	SetVariable setvar_cp9,format="%g %",frame=0
	SetVariable setvar_cp9,limits={-inf,inf,0},value= root:Any_CIW:misc:v_cp9,noedit= 1
	PopupMenu popup_save,pos={104.00,495.00},size={103.00,19.00},proc=ac_PopMenuProc_save,title="Save CIW temp."
	PopupMenu popup_save,mode=0,value= #"ac_save_str()"
	PopupMenu popup_kill,pos={208.00,495.00},size={62.00,19.00},proc=ac_PopMenuProc_killCIW,title="Kill CIW"
	PopupMenu popup_kill,mode=0,value= #"ac_select_str()"
	PopupMenu popup_load,pos={1.00,495.00},size={105.00,19.00},proc=ac_PopMenuProc_load,title="Load CIW temp."
	PopupMenu popup_load,mode=0,value= #"\"load from folder;Browse CIW temp ibw file\""
	SetVariable setvar_dfpath,pos={48.00,516.00},size={221.00,18.00},title=" "
	SetVariable setvar_dfpath,value= root:Any_CIW:misc:s_dfpath
	Button button_path,pos={1.00,515.00},size={50.00,20.00},proc=ac_ButtonProc_path,title=">>Path"
	Button button_update_targ,pos={224.00,32.00},size={50.00,20.00},disable=3,proc=ac_ButtonProc_upd,title="update"
	Display/W=(46,106,203,126)/HOST=# 
	AppendImage :Any_CIW:misc:view
	ModifyImage view cindex= :Any_CIW:misc:view_CIW
	ModifyGraph margin(left)=1,margin(bottom)=1,margin(top)=1,margin(right)=1
	ModifyGraph mirror=2
	ModifyGraph nticks=0
	ModifyGraph standoff=0
	ModifyGraph axThick=0.5
	RenameWindow #,ciw_sw
	SetActiveSubwindow ##
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Any_CIW:misc:
	Display/W=(173,157,262,209)/HOST=#  prof
	SetDataFolder fldrSav0
	ModifyGraph margin(left)=2,margin(bottom)=2,margin(top)=2,margin(right)=2,width=85.0394
	ModifyGraph height=48.189,gbRGB=(61166,61166,61166)
	ModifyGraph rgb=(0,0,0)
	ModifyGraph mirror=1
	ModifyGraph nticks=0
	ModifyGraph axThick=0.5
	SetAxis left 0,1
	SetAxis bottom 0,1
	RenameWindow #,p_sw
	SetActiveSubwindow ##
EndMacro

Function ac_search_info()
	string nf=GetDataFolder(1)
	SetDataFolder root:Any_CIW:misc
	string/g s_ws
	string ws=s_ws
	string clws=s_ws+"_info"
	SetDataFolder root:Any_CIW:info
	if(Exists(ws+"_tw")==0)
		make/O/T/N=1 $(ws+"_tw")
		wave/T tw=$(ws+"_tw")
	endif
	if(Exists(clws)==0)
		make/O/N=(10,4) $clws
		wave clw=$clws
		make/O/N=19 $(ws+"_sl")
		wave slw=$(ws+"_sl")
		make/O/T/N=1 $(ws+"_tw")
		wave/T tw=$(ws+"_tw")
		SetDataFolder root:Any_CIW:misc
		wave piw=$("panel_info")
		variable/g v_ciwsize
		variable/g v_prof
		variable/g v_prof_xn
		variable/g v_prof_x0
		variable/g v_prof_pk
		variable/g v_sl1
		variable/g v_sl2
		variable/g v_sl3
		variable/g v_sl4
		variable/g v_sl5
		variable/g v_sl6
		variable/g v_sl7
		variable/g v_sl8
		variable/g v_sl9
		variable/g v_slmax
		variable/g v_slmin
		variable/g v_intmax
		variable/g v_intmin
		variable/g v_rev
		string/g s_targw="_none_"
		clw=piw
		
		slw[0]=v_sl1
		slw[1]=v_sl2
		slw[2]=v_sl3
		slw[3]=v_sl4
		slw[4]=v_sl5
		slw[5]=v_sl6
		slw[6]=v_sl7
		slw[7]=v_sl8
		slw[8]=v_sl9
		slw[9]=v_ciwsize
		slw[10]=v_prof
		slw[11]=v_prof_xn
		slw[12]=v_prof_x0
		slw[13]=v_prof_pk
		slw[14]=v_slmax
		slw[15]=v_slmin
		slw[16]=v_intmax
		slw[17]=v_intmin
		slw[18]=v_rev
		
		ac_SetMinMax()
		
	else
		SetDataFolder root:Any_CIW:info
		wave slw=$(ws+"_sl")
		wave/T tw=$(ws+"_tw")
		SetDataFolder root:Any_CIW:misc
		variable/g v_sl1=slw[0]
		variable/g v_sl2=slw[1]
		variable/g v_sl3=slw[2]
		variable/g v_sl4=slw[3]
		variable/g v_sl5=slw[4]
		variable/g v_sl6=slw[5]
		variable/g v_sl7=slw[6]
		variable/g v_sl8=slw[7]
		variable/g v_sl9=slw[8]
		variable/g v_ciwsize=slw[9]
		variable/g v_prof=slw[10]
		variable/g v_prof_xn=slw[11]
		variable/g v_prof_x0=slw[12]
		variable/g v_prof_pk=slw[13]
		if(DimSize(slw,0)>14)
			variable/g v_slmax=slw[14]
			variable/g v_slmin=slw[15]
			variable/g v_intmax=slw[16]
			variable/g v_intmin=slw[17]
			variable/g v_rev=slw[18]
		endif
		
		if(v_ciwsize<2)
			v_ciwsize=256
		endif
		
		if(v_sl1+v_sl2+v_sl3+v_sl4+v_sl5+v_sl6+v_sl7+v_sl8+v_sl9==0)
			v_sl1=1
		endif
		
		if(v_prof<1 || v_prof>7)
			variable/g v_prof=1
		endif
		if(v_prof_xn<1)
			variable/g v_prof_xn=2
		endif
		if(v_prof_pk<1)
			variable/g v_prof_pk=10
		endif
		
		if(v_prof_x0>1 || v_prof_x0<-1)
			variable/g v_prof_x0=0
		endif
		
		
		string/g s_targw=tw[0]
		ac_SetMinMax()
	endif
	
	ac_set_popc()
	
	SetDataFolder $nf
End

Function ac_set_popc()
	string nf=GetDataFolder(1)
	SetDataFolder root:Any_CIW:misc
	string/g s_ws
	string ws=s_ws
	make/O/N=(10,4) $("panel_info")
	wave piw=$("panel_info")
	variable/g v_prof
	variable prof=v_prof
	SetDataFolder root:Any_CIW:info
	wave clw=$(ws+"_info")
	piw=clw
	variable n
	string popst
	for(n=0;n<DimSize(clw,0);n+=1)
		popst="("+num2str(clw[n][0])+","+num2str(clw[n][1])+","+num2str(clw[n][2])+")"
		DoWindow/F Any_CIW_panel
		execute "PopupMenu popup_cl"+num2str(n)+" popColor="+popst
	endfor
	ac_set_prof()
	SetDataFolder $nf
	ac_do()
End

Function ac_make_CIW()
	string nf=GetDataFolder(1)
	SetDataFolder root:Any_CIW:misc
	string/g s_ws
	string ws=s_ws
	variable/g v_ciwsize
	variable ciwsize=v_ciwsize
	variable/g v_slsum
	variable slsum=v_slsum
	variable/g v_intmax
	variable imax=v_intmax
	variable/g v_intmin
	variable imin=v_intmin
	variable/g v_slmax
	variable slmax=v_slmax
	variable/g v_slmin
	variable slmin=v_slmin
	variable/g v_HSV
	variable hsv=v_HSV
	variable/g v_rev
	variable rev=v_rev
	
	wave pw=$("prof")
	
	SetDataFolder root:Any_CIW:info
	string clws=ws+"_info"
	wave clw=$clws
	
	SetDataFolder root:Any_CIW:Gallery
	make/O/N=(ciwsize,3) $ws // new wave
	wave w=$ws
	
	variable n,r0,g0,b0,i0,r1,g1,b1,i1,t,tmax,tmin,r,g,b,tt,ptt
	variable h0,s0,v0,h1,s1,v1,h,s,v
	
	for(n=1;n<DimSize(clw,0);n+=1)
		r0=clw[n-1][0]
		g0=clw[n-1][1]
		b0=clw[n-1][2]
		i0=clw[n-1][3]
		
		h0=ac_rgb2hsv(r0,g0,b0,0)
		s0=ac_rgb2hsv(r0,g0,b0,1)
		v0=ac_rgb2hsv(r0,g0,b0,2)
		
		r1=clw[n][0]
		g1=clw[n][1]
		b1=clw[n][2]
		i1=clw[n][3]
		
		h1=ac_rgb2hsv(r1,g1,b1,0)
		s1=ac_rgb2hsv(r1,g1,b1,1)
		v1=ac_rgb2hsv(r1,g1,b1,2)
		
		tmin=round(clw[n-1][3]/clw[DimSize(clw,0)-1][3]*ciwsize)
		tmax=clw[n][3]/clw[DimSize(clw,0)-1][3]*ciwsize
		
		for(t=tmin;t<tmax;t+=1)
			tt=(t-tmin)/(tmax-tmin) // 0 <= tt < 1 when tmin <= t < tmax
			
			ptt=pw[round((DimSize(pw,0)-1)*tt)]
			
			if(hsv==0)
				r=r0*(1-ptt)+r1*ptt
				g=g0*(1-ptt)+g1*ptt
				b=b0*(1-ptt)+b1*ptt
			elseif(hsv==1)
				h=h0*(1-ptt)+h1*ptt
				s=s0*(1-ptt)+s1*ptt
				v=v0*(1-ptt)+v1*ptt
				
				r=ac_hsv2rgb(h,s,v,0)
				g=ac_hsv2rgb(h,s,v,1)
				b=ac_hsv2rgb(h,s,v,2)
			endif
			
			w[t][0]=r
			w[t][1]=g
			w[t][2]=b
		endfor
	endfor
	
	variable slmin1,slmax1
	if(rev==1)
		slmin1=slmax
		slmax1=slmin
		slmin=slmin1
		slmax=slmax1
	endif
	
	SetScale/I x,imin+(imax-imin)*slmin/100,imin+(imax-imin)*slmax/100, $ws
	
	SetDataFolder root:Any_CIW:misc
	make/O/N=(ciwsize,3) $("view_CIW") // view CIW
	wave vciw=$("view_CIW")
	vciw=w
	SetScale/I x,imin+(imax-imin)*slmin/100,imin+(imax-imin)*slmax/100, vciw
	
	wave vw=$("view")
	vw=x*(imax-imin)/255+imin
	
	SetDataFolder $nf
End

Function ac_make_prof()
	string nf=GetDataFolder(1)
	SetDataFolder root:Any_CIW:misc
	variable/g v_ciwsize
	variable siz=v_ciwsize
	variable/g v_prof
	variable prof=v_prof
	variable/g v_prof_xn
	variable xn=v_prof_xn
	variable/g v_prof_pk
	variable pk=v_prof_pk
	variable/g v_prof_x0
	variable x0=v_prof_x0
	variable/g v_prev
	make/O/N=(siz) ,$("prof")
	wave pw=$("prof")
	SetScale/I x,0,1,pw
	if(prof==1)
		pw=x
	elseif(prof==2)
		pw=1/(1+exp(-pk*(x-x0-0.5)))
	elseif(prof==3)
		pw=(1-cos(pi*x))/2
	elseif(prof==4)
		pw=x^(2*xn)
	elseif(prof==5)
		pw=-(x-1)^(2*xn)+1
	elseif(prof==6)
		pw=1-cos(pi/2*x)
	elseif(prof==7)
		pw=sin(pi/2*x)
	endif
	
	variable pmin=pw[0]
	variable pmax=pw[DimSize(pw,0)-1]
	
	pw=(pw-pmin)/(pmax-pmin)
	
	SetDataFolder $nf
End

Function ac_rgb2hsv(r,g,b,n)
	variable r,g,b,n
	variable h,s,v
	variable ma=max(r,max(g,b))
	variable mi=min(r,max(g,b))
	
	if(ma==mi)
		h=NaN
	elseif(r==mi)
		h=60*(b-g)/(ma-mi)+180
	elseif(g==mi)
		h=60*(r-b)/(ma-mi)+300
	elseif(b==mi)
		h=60*(g-r)/(ma-mi)+60
	endif
	
	s=ma-mi
	
	v=ma
	
	if(n==0)
		return h
	elseif(n==1)
		return s
	elseif(n==2)
		return v
	endif
End

Function ac_hsv2rgb(h,s,v,n)
	variable h,s,v,n
	variable r,g,b
	variable hp,c,x
	
	c=s
	hp=h/60
	x=c*(1-abs(mod(hp,2)-1))
	
	if(h==NaN)
		r=0
		g=0
		b=0
	elseif(hp<1)
		r=v-c+c
		g=v-c+x
		b=v-c+0
	elseif(hp<2)
		r=v-c+x
		g=v-c+c
		b=v-c+0
	elseif(hp<3)
		r=v-c+0
		g=v-c+c
		b=v-c+x
	elseif(hp<4)
		r=v-c+0
		g=v-c+x
		b=v-c+c
	elseif(hp<5)
		r=v-c+x
		g=v-c+0
		b=v-c+c
	elseif(hp<6)
		r=v-c+c
		g=v-c+0
		b=v-c+x
	endif
	
	if(n==0)
		return r
	elseif(n==1)
		return g
	elseif(n==2)
		return b
	endif
End

Function ac_do()
	string nf=GetDataFolder(1)
	SetDataFolder root:Any_CIW:misc
	variable/g v_sl0
	variable/g v_sl1
	variable/g v_sl2
	variable/g v_sl3
	variable/g v_sl4
	variable/g v_sl5
	variable/g v_sl6
	variable/g v_sl7
	variable/g v_sl8
	variable/g v_sl9
	variable/g v_slsum=v_sl9+v_sl8+v_sl7+v_sl6+v_sl5+v_sl4+v_sl3+v_sl2+v_sl1+v_sl0
	string/g s_ws
	string ws=s_ws
	string clws=s_ws+"_info"
	ac_calc_cp()
	SetDataFolder root:Any_CIW:info
	wave clw=$clws
	clw[0][3]=v_sl0
	clw[1][3]=v_sl1+v_sl0
	clw[2][3]=v_sl2+v_sl1+v_sl0
	clw[3][3]=v_sl3+v_sl2+v_sl1+v_sl0
	clw[4][3]=v_sl4+v_sl3+v_sl2+v_sl1+v_sl0
	clw[5][3]=v_sl5+v_sl4+v_sl3+v_sl2+v_sl1+v_sl0
	clw[6][3]=v_sl6+v_sl5+v_sl4+v_sl3+v_sl2+v_sl1+v_sl0
	clw[7][3]=v_sl7+v_sl6+v_sl5+v_sl4+v_sl3+v_sl2+v_sl1+v_sl0
	clw[8][3]=v_sl8+v_sl7+v_sl6+v_sl5+v_sl4+v_sl3+v_sl2+v_sl1+v_sl0
	clw[9][3]=v_sl9+v_sl8+v_sl7+v_sl6+v_sl5+v_sl4+v_sl3+v_sl2+v_sl1+v_sl0
	SetDataFolder $nf
	ac_make_CIW()
	
	SetDataFolder root:Any_CIW:misc
	string/g s_ws
	ws=s_ws
	string slws=ws+"_sl"
	variable/g v_sl1
	variable sl1=v_sl1
	variable/g v_sl2
	variable sl2=v_sl2
	variable/g v_sl3
	variable sl3=v_sl3
	variable/g v_sl4
	variable sl4=v_sl4
	variable/g v_sl5
	variable sl5=v_sl5
	variable/g v_sl6
	variable sl6=v_sl6
	variable/g v_sl7
	variable sl7=v_sl7
	variable/g v_sl8
	variable sl8=v_sl8
	variable/g v_sl9
	variable sl9=v_sl9
	variable/g v_ciwsize
	variable  ciwsize=v_ciwsize
	variable/g v_prof
	variable  prof=v_prof
	variable/g v_prof_xn
	variable  xn=v_prof_xn
	variable/g v_prof_x0
	variable  x0=v_prof_x0
	variable/g v_prof_pk
	variable  pk=v_prof_pk
	nvar v_slmax
	nvar v_slmin
	nvar v_intmax
	nvar v_intmin
	nvar v_rev
	string/g s_targw
	string tws=s_targw
	SetDataFolder root:Any_CIW:info
	make/O/N=19 $slws
	wave slw=$slws
	slw[0]=sl1
	slw[1]=sl2
	slw[2]=sl3
	slw[3]=sl4
	slw[4]=sl5
	slw[5]=sl6
	slw[6]=sl7
	slw[7]=sl8
	slw[8]=sl9
	slw[9]=ciwsize
	slw[10]=prof
	slw[11]=xn
	slw[12]=x0
	slw[13]=pk
	slw[14]=v_slmax
	slw[15]=v_slmin
	slw[16]=v_intmax
	slw[17]=v_intmin
	slw[18]=v_rev
	make/O/T/N=1 $(ws+"_tw")
	wave/T tw=$(ws+"_tw")
	tw[0]=tws
	SetDataFolder $nf
End

Function ac_calc_cp()
	string nf=GetDataFolder(1)
	SetDataFolder root:Any_CIW:misc
	variable/g v_sl1
	variable/g v_sl2
	variable/g v_sl3
	variable/g v_sl4
	variable/g v_sl5
	variable/g v_sl6
	variable/g v_sl7
	variable/g v_sl8
	variable/g v_sl9
	variable/g v_slsum
	
	variable/g v_cp1=round(v_sl1/v_slsum*1000)/10
	variable/g v_cp2=round(v_sl2/v_slsum*1000)/10
	variable/g v_cp3=round(v_sl3/v_slsum*1000)/10
	variable/g v_cp4=round(v_sl4/v_slsum*1000)/10
	variable/g v_cp5=round(v_sl5/v_slsum*1000)/10
	variable/g v_cp6=round(v_sl6/v_slsum*1000)/10
	variable/g v_cp7=round(v_sl7/v_slsum*1000)/10
	variable/g v_cp8=round(v_sl8/v_slsum*1000)/10
	variable/g v_cp9=round(v_sl9/v_slsum*1000)/10
	SetDataFolder $nf
End

Function as_SliderProc_do(sa) : SliderControl
	STRUCT WMSliderAction &sa

	switch( sa.eventCode )
		case -3: // Control received keyboard focus
		case -2: // Control lost keyboard focus
		case -1: // Control being killed
			break
		default:
			if( sa.eventCode & 1 ) // value set
				Variable curval = sa.curval
				string nf=GetDataFolder(1)
				ac_do()
			endif
			break
	endswitch

	return 0
End

Function ac_PopMenuProc_cl(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			variable n=str2num(ReplaceString("popup_cl",pa.ctrlName,""))
			string nf=GetDataFolder(1)
			
			popStr=ReplaceString("(", popStr, "")
			popStr=ReplaceString(")", popStr, "")
			popStr=ReplaceString(",", popStr, ";")
			string p0=StringFromList(0,popStr)
			string p1=StringFromList(1,popStr)
			string p2=StringFromList(2,popStr)
			
			SetDataFolder root:Any_CIW:misc
			string/g s_ws
			string clws=s_ws+"_info"
			make/O/N=(10,4) $("panel_info")
			wave piw=$("panel_info")
			SetDataFolder root:Any_CIW:info
			wave clw=$clws
			
			clw[n][0]=str2num(p0)
			clw[n][1]=str2num(p1)
			clw[n][2]=str2num(p2)
			
			piw=clw
			
			SetDataFolder $nf
			ac_make_CIW()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function ac_SetMinMax()
	string nf=GetDataFolder(1)
	SetDataFolder root:Any_CIW:misc
	string/g s_targw
	string tws=s_targw
	
	variable inmax,inmin
	SetDataFolder $nf
	if(StringMatch(tws,"_none_"))
		inmax=100
		inmin=0
		SetDataFolder root:Any_CIW:misc
		variable/g v_slmax=100
		variable/g v_slmin=0
		DoWindow/F Any_CIW_panel
		SetVariable setvar_intmax disable=0
		SetVariable setvar_intmin disable=0
		Button button_update_targ disable=3
		SetVariable setvar_targ size={50,18}
	else
		DoWindow/F Any_CIW_panel
		SetVariable setvar_intmax disable=3
		SetVariable setvar_intmin disable=3
		Button button_update_targ disable=0
		SetVariable setvar_targ size={150,18}
		SetDataFolder $nf
		if(WaveExists($tws))
			wave w=$tws
			inmax=WaveMax(w)
			inmin=WaveMin(w)
			
			variable i,j,mi=inf,ma=-inf
			
			if(inmax==inf)
				for(i=0;i<DimSize(w,1);i+=1)
					for(j=0;j<DimSize(w,0);j+=1)
						if(w[j][i]!=inf && w[j][i]>ma)
							ma=w[j][i]
						endif
					endfor
				endfor
				inmax=ma
			endif
			
			if(inmin==-inf)
				for(i=0;i<DimSize(w,1);i+=1)
					for(j=0;j<DimSize(w,0);j+=1)
						if(w[j][i]!=-inf && w[j][i]<mi)
							mi=w[j][i]
						endif
					endfor
				endfor
				inmin=mi
			endif
		else
			SetDataFolder root:Any_CIW:misc
			string/g s_targw="_none_"
			DoWindow/F Any_CIW_panel
			SetVariable setvar_intmax disable=0
			SetVariable setvar_intmin disable=0
			Button button_update_targ disable=3
			SetVariable setvar_targ size={50,18}
			variable/g v_slmax=100
			variable/g v_slmin=0
			inmax=100
			inmin=0
		endif
	endif
	
	SetDataFolder root:Any_CIW:misc
	variable/g v_intmax=inmax
	variable/g v_intmin=inmin
	
	SetDataFolder $nf
End

//Function ac_PopMenuProc_targ(pa) : PopupMenuControl
//	STRUCT WMPopupAction &pa
//
//	switch( pa.eventCode )
//		case 2: // mouse up
//			Variable popNum = pa.popNum
//			String popStr = pa.popStr
//			string nf=GetDataFolder(1)
//			
//			SetDataFolder root:Any_CIW:misc
//			string/g s_targw=popStr
//			SetDataFolder $nf
//			
//			ac_SetMinMax()
//			
//			ac_do()
//			break
//		case -1: // control being killed
//			break
//	endswitch
//
//	return 0
//End



Function/S ac_select_str()
	string nf=GetDataFolder(1)
	SetDataFolder root:Any_CIW:info
	string str=WaveList("*_info",";","dims:2")
	str=RemoveFromList(WaveList("*_temp_info",";","dims:2"),str)
	str+=";\M1-;"+WaveList("*_temp_info",";","dims:2")
	str=ReplaceString("_info", str, "")
	SetDataFolder $nf
	return str
End

Function/S ac_save_str()
	string nf=GetDataFolder(1)
	SetDataFolder root:Any_CIW:info
	string str=WaveList("*_temp_info",";","dims:2")
	str=ReplaceString("_info", str, "")
	SetDataFolder $nf
	return str
End

Function ac_PopMenuProc_killCIW(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			string nf=GetDataFolder(1)
			SetDataFolder root:Any_CIW:misc
			string/g s_killtarget=popStr
			execute "ac_promp()"
			variable/g V_Flag
			if(V_Flag==1)
				variable exis_f
				if(!StringMatch(popstr,"*_temp"))
					SetDataFolder root:Any_CIW:Gallery
					KillWaves/Z $popStr
					if(WaveExists($popstr))
						exis_f=1
					endif
				else
					exis_f=0
				endif
				if(exis_f==1)
					execute "ac_alert()"
				else
					SetDataFolder root:Any_CIW:info
					KillWaves/Z $(popStr+"_info"),$(popStr+"_sl"),$(popStr+"_tw")
				endif
			endif
			SetDataFolder $nf
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Proc ac_alert()
	string nf=GetDataFolder(1)
	SetDataFolder root:Any_CIW:misc
	string/g s_killtarget
	DoAlert/T="Any_CIW message" 0,"I can not kill root:Any_CIW:Gallery:"+s_killtarget+" because you are using it."
	SetDataFolder $nf
End

Proc ac_promp()
	string nf=GetDataFolder(1)
	SetDataFolder root:Any_CIW:misc
	string/g s_killtarget
	DoAlert/T="Any_CIW message" 1,"Are you sure to kill "+s_killtarget+"?"
	SetDataFolder $nf
End


Function/S ac_prof_str()
	string nf=GetDataFolder(1)
	SetDataFolder root:Any_CIW:misc
	string/g s_proflist
	string str=s_proflist
	SetDataFolder $nf
	return str
End

Function ac_set_prof()
	string nf=GetDataFolder(1)
	SetDataFolder root:Any_CIW:misc
	variable/g v_prof
	variable prof=v_prof
	string/g s_proflist
	string/g s_prof="f(x)="+StringFromList(prof-1,s_proflist)
	if(prof==2)
		DoWindow/F Any_CIW_panel
		SetVariable setvar_prof_pk disable=0
		SetVariable setvar_prof_x0 disable=0
	else
		DoWindow/F Any_CIW_panel
		SetVariable setvar_prof_pk disable=3
		SetVariable setvar_prof_x0 disable=3
	endif
	
	if(prof==4 || prof==5)
		DoWindow/F Any_CIW_panel
		SetVariable setvar_prof_xn disable=0
	else
		DoWindow/F Any_CIW_panel
		SetVariable setvar_prof_xn disable=3
	endif
	SetDataFolder $nf
End





Function ac_TabProc_hsv(tca) : TabControl
	STRUCT WMTabControlAction &tca

	switch( tca.eventCode )
		case 2: // mouse up
			Variable tab = tca.tab
			string nf=GetDataFolder(1)
			SetDataFolder root:Any_CIW:misc
			variable/g v_HSV=tab
			ac_do()
			SetDataFolder $nf
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function ac_CheckProc_rev(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			ac_do()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

//
//Function sts()
//	variable i
//	for(i=0;i<50;i+=1)
//	print "i = "+num2str(i)+"; "+GetErrMessage(i)
//	endfor
//
//End

Function ac_PopMenuProc_prof(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			string nf=GetDataFolder(1)
			SetDataFolder root:Any_CIW:misc
			string/g s_prof="f(x)="+popStr
			variable/g v_prof=popNum
			SetDataFolder $nf
			ac_make_prof()
			ac_do()
			ac_set_prof()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function ac_SetVarProc_do(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			ac_make_prof()
			ac_do()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

//Function CheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			ac_make_prof()
			ac_do()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function ac_ButtonProc_targ(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			string nf=GetDataFolder(1)
			string str=StringFromList(0,ac_selectWaves_fromDF())
			if(StrLen(str)!=0)
				if(WaveDims($str)==2)
					SetDataFolder root:Any_CIW:misc
					string/g s_targw=str
					SetDataFolder $nf
					ac_SetMinMax()
					ac_do()
				else
					print "Please Select 2D wave from Data Browser"
					print str+" is not 2D wave"
				endif
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

#if (IgorVersion() >= 7.00) 
	Function/S ac_selectWaves_fromDF() // for igor 7, 8
		CreateBrowser/M prompt="Select a target wave:"
		ModifyBrowser/M sort=1, showWaves=1, showVars=0, showStrs=0, showInfo=1, showPlot=1
		ModifyBrowser/M showModalBrowser
		if (V_Flag == 0)
			return ""		// User cancelled
		endif
		return S_BrowserList	
	End
#else
	Function/S ac_selectWaves_fromDF() // for igor 6
		String cdfBefore = GetDataFolder(1)	// Save current data folder before.
		Execute "CreateBrowser prompt=\"Select a target wave:\", showWaves=1, showVars=0, showStrs=0"
		String cdfAfter = GetDataFolder(1)
		SetDataFolder cdfBefore
		SVAR S_BrowserList=S_BrowserList
		NVAR V_Flag=V_Flag
		if(V_Flag==0)
			return ""
		else
			return S_BrowserList
		endif
	End
#endif


Function ac_SetVarProc_targ(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			ac_SetMinMax()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ac_save_temp(ciwt)
	string ciwt
	if(StringMatch(ciwt,"*_temp"))
		string nf=GetDataFolder(1)
		SetDataFolder root:Any_CIW:info
		string iws=ciwt+"_info"
		string sws=ciwt+"_sl"
		string ws="prep"
		if(WaveExists($iws) && WaveExists($sws))
			wave iw=$iws
			wave sw=$sws
			make/N=54 $ws
			wave w=$ws
			variable i
			for(i=0;i<54;i+=1)
				if(i<40)
					w[i]=iw[mod(i,10)][floor(i/10)]
				else
					w[i]=sw[i-40]
				endif
			endfor
			Save/C w as "CIW_"+ciwt+".ibw"
			KillWaves w
		endif
		SetDataFolder $nf
	else
		print ciwt+" is not CIW template."
	endif
End

Function ac_load_temp(filename)
	string filename
	string nf=GetDataFolder(1)
	SetDataFolder root:Any_CIW:info
	if(StrLen(filename)>0)
		string ws
		ws=ParseFilePath(0, filename, ":", 1, 0)
		if(StringMatch(ws,"CIW_*") && StringMatch(ws,"*_temp.ibw"))
			LoadWave/O/Q/P=ac_temppath filename
			ws=ReplaceString("CIW_",ws,"")
			ws=ReplaceString(".ibw",ws,"")
			string ciwt=ws
			string iws=ciwt+"_info"
			string sws=ciwt+"_sl"
			wave w=$("prep")
			make/O/N=(10,4) $iws
			make/O/N=14 $sws
			wave iw=$iws
			wave sw=$sws
			variable i
			for(i=0;i<54;i+=1)
				if(i<40)
					iw[mod(i,10)][floor(i/10)]=w[i]
				else
					sw[i-40]=w[i]
				endif
			endfor
			KillWaves w
		else
			print fileName+" is not CIW template."
		endif
	endif
	SetDataFolder $nf
End

Function ac_PopMenuProc_save(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			if(StringMatch(popStr,"_all_"))
				variable n
				string ts
				do
					ts=StringFromList(n,ac_save_str())
					if(StrLen(ts)==0)
						break
					endif
					ac_save_temp(ts)
					n+=1
				while(1)
			else
				ac_save_temp(popStr)
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function ac_PopMenuProc_name(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			string nf=GetDataFolder(1)
			SetDataFolder root:Any_CIW:misc
			string/g s_ws
			if(StringMatch(popStr,"*_temp"))
				string ws=s_ws
				SetDataFolder root:Any_CIW:info
				make/O/N=(10,4) $(ws+"_info")
				wave w=$(ws+"_info")
				wave tw=$(popStr+"_info")
				w=tw
				make/O/N=14 $(ws+"_sl")
				wave sw=$(ws+"_sl")
				wave tsw=$(popStr+"_sl")
				sw=tsw
			else
				string/g s_ws=popStr
				string/g s_name=s_ws
			endif
			SetDataFolder $nf
			ac_search_info()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function ac_SetVarProc_name(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			string nf=GetDataFolder(1)
			SetDataFolder root:Any_CIW:misc
			string/g s_ws
			string ws=s_ws
			if(StringMatch(sval,"*_temp"))
				SetDataFolder root:Any_CIW:info
				Duplicate/O $(ws+"_info"), $(sval+"_info")
				Duplicate/O $(ws+"_sl"), $(sval+"_sl")
				SetDataFolder root:Any_CIW:misc
				string/g s_name=ws
			else
				SetDataFolder root:Any_CIW:misc
				string/g s_ws=sval
				ac_search_info()
			endif
			SetDataFolder $nf
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function ac_load_defaulttemps()
	string filename
	string nf=GetDataFolder(1)
	SetDataFolder root:Any_CIW:misc
	string/g s_dfpath
	variable br
	if(StringMatch(s_dfpath,"_Browse_"))
		br=1
	endif
	KillPath/A
	NewPath/Q/O ac_temppath, s_dfpath
	pathinfo ac_temppath
	string/g s_dfpath=s_path
	if(br==0)
		if(V_Flag)
			variable n=0
			do
				filename=IndexedFile(ac_temppath, n, ".ibw")
				if(StrLen(filename)==0)
					break
				endif
				ac_load_temp(s_dfpath+filename)
				n+=1
			while(1)
			print "Any_CIW: "+num2str(n)+" CIW templates are loaded from "+s_dfpath
		endif
	endif
	SetDataFolder $nf
End


Function ac_load_from_file()
	variable refNum
	Open/D/R/T=".ibw"  refNum
	FStatus refNum
	NewPath/Q/O ac_temppath, ""
	ac_load_temp(S_fileName)
End

Function ac_PopMenuProc_load(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			if(popNum==1)
				ac_load_defaulttemps()
			else
				ac_load_from_file()
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function ac_ButtonProc_browse_temp(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
				string nf=GetDataFolder(1)
				SetDataFolder root:Any_CIW:misc
				variable refNum
				Open/D/R/T=".ibw"  refNum
				FStatus refNum
				print v_flag
				string/g s_dfpath=s_path
				SetDataFolder $nf
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function ac_ButtonProc_path(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			string nf=GetDataFolder(1)
			SetDataFolder root:Any_CIW:misc
			string/g s_dfpath
			string dfpath_save=s_dfpath
			string/g s_dfpath="_Browse_"
			ac_load_defaulttemps()
			string/g s_dfpath
			if(StrLen(s_dfpath)==0)
				string/g s_dfpath=dfpath_save
			endif
			SetDataFolder $nf
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function ac_ButtonProc_upd(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			ac_SetMinMax()
			ac_do()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

