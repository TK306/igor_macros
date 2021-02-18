#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function RW_Rot_Wave_do(wdim)
	variable wdim
	variable x1,y1,x2,y2
	string nf=GetDataFolder(1)
	SetDataFolder root:Rot_Wave
	string/g s_ws
	string/g s_outname
	
	string inws,ows
	if(wdim==2)
		inws="root:Rot_Wave:ori_img"
		ows="root:Rot_Wave:rot_img"
	elseif(wdim==4)
		inws=s_ws
		ows="root:Rot_Wave:rot_slice"
	elseif(wdim==3)
		inws=s_ws
		ows=s_outname
	endif
	
	wave iw=$inws
	
	nvar x0=v_xc
	nvar y0=v_yc
	
	nvar rot=v_rot
	
	nvar ox_s=v_xs
	nvar ox_e=v_xe
	nvar ox_n=v_xn
	
	nvar oy_s=v_ys
	nvar oy_e=v_ye
	nvar oy_n=v_yn
	nvar or=v_outrange
	nvar shift=v_shift
	
	
	variable ox_st=(ox_e-ox_s)/(ox_n-1)
	variable oy_st=(oy_e-oy_s)/(oy_n-1)
	
	variable ix,iy,th=rot*pi/180,xp,yp,en
	if(wdim==2)
		make/O/N=(ox_n,oy_n) $ows
		wave ow=$ows
		ow=or
		
		for(iy=0;iy<DimSize(ow,1);iy+=1)
			y2=oy_s+iy*oy_st
			for(ix=0;ix<DimSize(ow,0);ix+=1)
				x2=ox_s+ix*ox_st
				
				if(shift==0)
					x1=x2*cos(th)+y2*sin(th)-(x0-x0*cos(th)+y0*sin(th))*cos(th)-(y0-x0*sin(th)-y0*cos(th))*sin(th)
					y1=-x2*sin(th)+y2*cos(th)+(x0-x0*cos(th)+y0*sin(th))*sin(th)-(y0-x0*sin(th)-y0*cos(th))*cos(th)
				else
					x1=x2*cos(th)+y2*sin(th)-(-x0*cos(th)+y0*sin(th))*cos(th)-(-x0*sin(th)-y0*cos(th))*sin(th)
					y1=-x2*sin(th)+y2*cos(th)+(-x0*cos(th)+y0*sin(th))*sin(th)-(-x0*sin(th)-y0*cos(th))*cos(th)
				endif
				xp=round((x1-DimOffset(iw,0))/DimDelta(iw,0))
				yp=round((y1-DimOffset(iw,1))/DimDelta(iw,1))
				
				if(xp>=0 && xp<DimSize(iw,0) && yp>=0 && yp<DimSize(iw,1))
					ow[ix][iy]=iw[xp][yp]
				endif
			endfor
		endfor
		
		SetScale/I x,ox_s,ox_e,ow
		SetScale/I y,oy_s,oy_e,ow
	elseif(wdim==4)
		make/O/N=(DimSize(iw,0),ox_n) $ows
		wave ow=$ows
		ow=or
		y2=0
		for(en=0;en<DimSize(ow,0);en+=1)
			for(ix=0;ix<DimSize(ow,1);ix+=1)
				x2=ox_s+ix*ox_st
				
				if(shift==0)
					x1=x2*cos(th)+y2*sin(th)-(x0-x0*cos(th)+y0*sin(th))*cos(th)-(y0-x0*sin(th)-y0*cos(th))*sin(th)
					y1=-x2*sin(th)+y2*cos(th)+(x0-x0*cos(th)+y0*sin(th))*sin(th)-(y0-x0*sin(th)-y0*cos(th))*cos(th)
				else
					x1=x2*cos(th)+y2*sin(th)-(-x0*cos(th)+y0*sin(th))*cos(th)-(-x0*sin(th)-y0*cos(th))*sin(th)
					y1=-x2*sin(th)+y2*cos(th)+(-x0*cos(th)+y0*sin(th))*sin(th)-(-x0*sin(th)-y0*cos(th))*cos(th)
				endif
				xp=round((x1-DimOffset(iw,1))/DimDelta(iw,1))
				yp=round((y1-DimOffset(iw,2))/DimDelta(iw,2))
				
				if(xp>=0 && xp<DimSize(iw,1) && yp>=0 && yp<DimSize(iw,2))
					ow[en][ix]=iw[en][xp][yp]
				endif
			endfor
		endfor
		
		SetScale/P x,DimOffset(iw,0),DimDelta(iw,0),ow
		SetScale/I y,ox_s,ox_e,ow
	elseif(wdim==3)
		make/O/N=(DimSize(iw,0),ox_n,oy_n) $ows
		wave ow=$ows
		ow=or
		print "Start"
		variable c,rc,tc=DimSize(iw,0)*ox_n*oy_n
		for(en=0;en<DimSize(ow,0);en+=1)
			for(iy=0;iy<DimSize(ow,2);iy+=1)
				y2=oy_s+iy*oy_st
				for(ix=0;ix<DimSize(ow,1);ix+=1)
					x2=ox_s+ix*ox_st
		
					if(shift==0)
						x1=x2*cos(th)+y2*sin(th)-(x0-x0*cos(th)+y0*sin(th))*cos(th)-(y0-x0*sin(th)-y0*cos(th))*sin(th)
						y1=-x2*sin(th)+y2*cos(th)+(x0-x0*cos(th)+y0*sin(th))*sin(th)-(y0-x0*sin(th)-y0*cos(th))*cos(th)
					else
						x1=x2*cos(th)+y2*sin(th)-(-x0*cos(th)+y0*sin(th))*cos(th)-(-x0*sin(th)-y0*cos(th))*sin(th)
						y1=-x2*sin(th)+y2*cos(th)+(-x0*cos(th)+y0*sin(th))*sin(th)-(-x0*sin(th)-y0*cos(th))*cos(th)
					endif
					
					xp=round((x1-DimOffset(iw,1))/DimDelta(iw,1))
					yp=round((y1-DimOffset(iw,2))/DimDelta(iw,2))
					
					if(xp>=0 && xp<DimSize(iw,1) && yp>=0 && yp<DimSize(iw,2))
						ow[en][ix][iy]=iw[en][xp][yp]
					endif
					c+=1
					if(round(c/tc*100)>rc)
						print num2str(round(c/tc*100))+" %"
					endif
					rc=round(c/tc*100)
				endfor
			endfor
		endfor
		
		SetScale/P x,DimOffset(iw,0),DimDelta(iw,0),ow
		SetScale/I y,ox_s,ox_e,ow
		SetScale/I z,oy_s,oy_e,ow
		print "End"
	endif
	SetDataFolder $nf
	
	RW_panel_gsize("ori")
	RW_panel_gsize("rot")
End

Macro Call_Rot_Wave_panel()
	variable go=RW_start(GetBrowserSelection(0))
	if(go==1)
		if(strlen(WinList("Rot_Wave_p", ";", "WIN:64")))
			DoWindow/F Rot_Wave_p
		else
			RW_make_panel()
		endif
		RW_vol_slicer()
		RW_Rot_Wave_do(2)
		RW_im_colortable()
	endif
End

Function RW_start(ws)
	string ws
	if(WaveExists($ws) && (WaveDims($ws)==2 || WaveDims($ws)==3))
		wave w=$ws
		string nf=GetDataFolder(1)
		NewDataFolder/S/O root:Rot_Wave
		Duplicate/O w,ori_img
		Duplicate/O w,rot_img
		if(WaveDims($ws)==3)
			variable/g v_wdim=3
			variable/g v_xs=DimOffset(w,1)
			variable/g v_xe=DimOffset(w,1)+DimDelta(w,1)*(DimSize(w,1)-1)
			variable/g v_ys=DimOffset(w,2)
			variable/g v_ye=DimOffset(w,2)+DimDelta(w,2)*(DimSize(w,2)-1)
			variable/g v_xn=DimSize(w,1)
			variable/g v_yn=DimSize(w,2)
			variable/g v_esl=DimOffset(w,0)+floor(DimDelta(w,0)*DimSize(w,0)/2)
		else
			variable/g v_wdim=2
			variable/g v_xs=DimOffset(w,0)
			variable/g v_xe=DimOffset(w,0)+DimDelta(w,0)*(DimSize(w,0)-1)
			variable/g v_ys=DimOffset(w,1)
			variable/g v_ye=DimOffset(w,1)+DimDelta(w,1)*(DimSize(w,1)-1)
			variable/g v_xn=DimSize(w,0)
			variable/g v_yn=DimSize(w,1)
		endif
		
		string/g s_ws=ws
		string/g s_outname=ws+"_RW"
		variable/g v_xc=0
		variable/g v_yc=0
		variable/g v_rot=0
		variable/g v_outrange=-inf
		variable/g v_rev=0
		variable/g v_shift=1
		string/g s_popstr="BlueHot"
		SetDataFolder $nf
		return 1
	else
		print "RW message: Select 2D or 3D wave."
		return 0
	endif
End

Function RW_vol_slicer()
	string nf=GetDataFolder(1)
	
	SetDataFolder root:Rot_Wave
	string/g s_ws
	nvar wdim=v_wdim
	if(wdim==3)
		nvar x=v_esl
		
		string vws=s_ws
		string ims="ori_img"
		wave vw=$vws
		
		variable xp=round((x-DimOffset(vw,0))/DimDelta(vw,0))
		
		make/O/N=(DimSize(vw,1),DimSize(vw,2)) $ims
		wave im=$ims
		variable i,j
		for(j=0;j<DimSize(vw,2);j+=1)
			for(i=0;i<DimSize(vw,1);i+=1)
				im[i][j]=vw[xp][i][j]
			endfor
		endfor
		SetScale/P x,DimOffset(vw,1),DimDelta(vw,1),im
		SetScale/P y,DimOffset(vw,2),DimDelta(vw,2),im
	endif
	
	SetDataFolder $nf
End

Function RW_make_panel()
	string nf=GetDataFolder(1)
	SetDataFolder root:Rot_Wave
	wave w=$("ori_img")
	nvar wdim=v_wdim
	PauseUpdate; Silent 1		// building window...
	NewPanel /N=Rot_Wave_p/K=1/W=(355,78,935,462) as "Rotate panel"
	ModifyPanel cbRGB=(65534,65534,65534)
	ModifyPanel fixedSize=1
	SetDrawLayer UserBack
	DrawPoly 267.357142857143,70.972972972973,0.452381,0.432432,{237,378,284,375,285,348,318,394,283,422,281,399,234,400,237,378}
	DrawPoly 267.357142857143,118.972972972973,0.452381,0.432432,{237,378,284,375,285,348,318,394,283,422,281,399,234,400,237,378}
	DrawPoly 267.357142857143,166.972972972973,0.452381,0.432432,{237,378,284,375,285,348,318,394,283,422,281,399,234,400,237,378}
	SetVariable setvar_xs,pos={310,274},size={124,16},bodyWidth=80,proc=RW_SetVarProc_go,title="x start :"
	SetVariable setvar_xs,value= root:Rot_Wave:v_xs
	SetVariable setvar_xe,pos={316,296},size={118,16},bodyWidth=80,proc=RW_SetVarProc_go,title="x end :"
	SetVariable setvar_xe,value= root:Rot_Wave:v_xe
	SetVariable setvar_ys,pos={445,274},size={124,16},bodyWidth=80,proc=RW_SetVarProc_go,title="y start :"
	SetVariable setvar_ys,value= root:Rot_Wave:v_ys
	SetVariable setvar_ye,pos={451,295},size={118,16},bodyWidth=80,proc=RW_SetVarProc_go,title="y end :"
	SetVariable setvar_ye,value= root:Rot_Wave:v_ye
	SetVariable setvar_save,pos={49,341},size={216,16},bodyWidth=200,title="as"
	SetVariable setvar_save,limits={-inf,inf,0},value= root:Rot_Wave:s_outname
	Button button_save,pos={33,319},size={60,20},proc=RW_ButtonProc_save,title="SAVE to"
	SetVariable setvar_xc,pos={16,272},size={132,16},bodyWidth=80,proc=RW_SetVarProc_go,title="x center :"
	SetVariable setvar_xc,value= root:Rot_Wave:v_xc
	SetVariable setvar_yc,pos={151,272},size={132,16},bodyWidth=80,proc=RW_SetVarProc_go,title="y center :"
	SetVariable setvar_yc,value= root:Rot_Wave:v_yc
	SetVariable setvar_rot,pos={31,294},size={117,16},bodyWidth=80,proc=RW_SetVarProc_go,title="angle :"
	SetVariable setvar_rot,value= root:Rot_Wave:v_rot
	SetVariable setvar_xn,pos={302,322},size={131,16},bodyWidth=80,proc=RW_SetVarProc_go,title="x points :"
	SetVariable setvar_xn,value= root:Rot_Wave:v_xn
	SetVariable setvar_yn,pos={437,321},size={131,16},bodyWidth=80,proc=RW_SetVarProc_go,title="y points :"
	SetVariable setvar_yn,value= root:Rot_Wave:v_yn
	SetVariable setvar_or,pos={175,293},size={108,16},bodyWidth=50,proc=RW_SetVarProc_go,title="out range :"
	SetVariable setvar_or,value= root:Rot_Wave:v_outrange
	PopupMenu popup_cp,pos={33,362},size={64,20},bodyWidth=64,proc=RW_PopMenuProc
	PopupMenu popup_cp,mode=4,value= #"\"*COLORTABLEPOPNONAMES*\""
	CheckBox check_rev,pos={104,365},size={34,14},proc=RW_CheckProc,title="rev"
	CheckBox check_rev,value= 0
	Button button_opt,pos={466,343},size={100,20},proc=RW_ButtonProc_opt,title="Optimize range"
	CheckBox check_shift,pos={269.00,192.00},size={39.00,15.00},proc=RW_CheckProc_go,title="shift"
	CheckBox check_shift,variable= root:Rot_Wave:v_shift
	if(wdim==3)
		string/g s_ws
		wave vw=$s_ws
		SetVariable setvar_esl,pos={182.00,318.00},size={100.00,18.00},bodyWidth=50,proc=RW_SetVarProc_go,title="Eng cut :"
		SetVariable setvar_esl,limits={DimOffset(vw,0),DimOffset(vw,0)+DimDelta(vw,0)*(DimSize(vw,0)-1),DimDelta(vw,0)},value= root:Rot_Wave:v_esl
		Button button_extract,pos={359.00,344.00},size={80.00,20.00},proc=RW_ButtonProc_extract,title="Extract slice"
	endif
	Display/W=(5,5,265,265)/HOST=# 
	AppendImage $("ori_img")
	ModifyGraph margin(left)=28,margin(bottom)=28,margin(top)=5,margin(right)=5,width=226.772
	ModifyGraph height={Aspect,1}
	ModifyGraph mirror=2
	ModifyGraph nticks(left)=10,nticks(bottom)=4
	ModifyGraph minor=1
	ModifyGraph fSize=8
	ModifyGraph standoff=0
	ModifyGraph tkLblRot(left)=90
	ModifyGraph btLen=3
	ModifyGraph tlOffset=-2
	RenameWindow #,ori_w
	SetActiveSubwindow ##
	Display/W=(308,7,568,267)/HOST=# 
	AppendImage $("rot_img")
	ModifyGraph margin(left)=28,margin(bottom)=28,margin(top)=5,margin(right)=5,width=226.772
	ModifyGraph height={Aspect,1}
	ModifyGraph zero=1
	ModifyGraph mirror=2
	ModifyGraph nticks(left)=10,nticks(bottom)=4
	ModifyGraph minor=1
	ModifyGraph fSize=8
	ModifyGraph standoff=0
	ModifyGraph axRGB=(65535,65535,65535)
	ModifyGraph tkLblRot(left)=90
	ModifyGraph btLen=3
	ModifyGraph tlOffset=-2
	RenameWindow #,rot_w
	SetActiveSubwindow ##
	SetDataFolder $nf
EndMacro

Function RW_ex_img()
	string nf=GetDataFolder(1)
	SetDataFolder root:Rot_Wave
	string ws="rot_slice"
	wave w=$ws
	
	Display/K=1/W=(593.25,85.25,852,344)/N=RW_viewer as "Live Viewer"
	AppendImage w
	ModifyGraph margin(left)=28,margin(bottom)=28,margin(top)=5,margin(right)=5
	ModifyGraph mirror=2
	ModifyGraph nticks(left)=10,nticks(bottom)=4
	ModifyGraph minor=1
	ModifyGraph fSize=8
	ModifyGraph standoff=0
	ModifyGraph tkLblRot(left)=90
	ModifyGraph btLen=3
	ModifyGraph tlOffset=-2
	ModifyGraph swapXY=1
	
	SetDataFolder $nf
End


Function RW_SetVarProc_go(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			nvar wdim=root:Rot_Wave:v_wdim
			RW_vol_slicer()
			RW_Rot_Wave_do(2)
			if(wdim==3)
				RW_Rot_Wave_do(4)
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


Function RW_save()
	string nf=GetDataFolder(1)
	SetDataFolder root:Rot_Wave
	string/g s_outname
	nvar wdim=v_wdim
	if(wdim==3)
		RW_Rot_Wave_do(3)
	else
		Duplicate/O $("rot_img"),$s_outname
	endif
	SetDataFolder $nf
End

Function RW_ButtonProc_save(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			RW_save()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function RW_panel_gsize(or)
	string or
	string nf=GetDataFolder(1)
	SetDataFolder root:Rot_Wave
	string ws=or+"_img"
	wave w=$ws
	
	variable hw=DimDelta(w,0)*(DimSize(w,0)-1)
	variable vw=DimDelta(w,1)*(DimSize(w,1)-1)
	
	variable para=200/max(hw,vw)
	
	string wn="Rot_Wave_p#"+or+"_w"
	
	ModifyGraph/W=$wn width={perUnit,para,bottom},height={perUnit,para,left}
	
	SetDataFolder $nf
End

Function RW_im_colortable()
	string nf=GetDataFolder(1)
	SetDataFolder root:Rot_Wave
	string/g s_popstr
	string str=s_popstr
	nvar rev=v_rev
	string or,wn,im
	or="ori"
	wn="Rot_Wave_p#"+or+"_w"
	im=or+"_img"
	ModifyImage/W=$wn $im ctab= {*,*,$str,rev}
	
	or="rot"
	wn="Rot_Wave_p#"+or+"_w"
	im=or+"_img"
	ModifyImage/W=$wn $im ctab= {*,*,$str,rev}
	
	SetDataFolder $nf
End

Function RW_PopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			string nf=GetDataFolder(1)
			SetDataFolder root:Rot_Wave
			string/g s_popstr=popstr
			RW_im_colortable()
			SetDataFolder $nf
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function RW_CheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			string nf=GetDataFolder(1)
			SetDataFolder root:Rot_Wave
			variable/g v_rev=checked
			RW_im_colortable()
			SetDataFolder $nf
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function RW_optimize_range()
	string nf=GetDataFolder(1)
	
	variable x1,y1,x2,y2
	
	SetDataFolder root:Rot_Wave
	nvar x0=v_xc
	nvar y0=v_yc
	nvar rot=v_rot
	nvar v_wdim
	variable th=rot*pi/180
	
	wave iw=$("ori_img")
	
	variable i,xmin=inf,xmax=-inf,ymin=inf,ymax=-inf
	for(i=0;i<4;i+=1)
		if(i==0)
			x1=DimOffset(iw,0)
			y1=DimOffset(iw,1)
		elseif(i==1)
			x1=DimOffset(iw,0)
			y1=DimOffset(iw,1)+DimDelta(iw,1)*(DimSize(iw,1)-1)
		elseif(i==2)
			x1=DimOffset(iw,0)+DimDelta(iw,0)*(DimSize(iw,0)-1)
			y1=DimOffset(iw,1)
		else
			x1=DimOffset(iw,0)+DimDelta(iw,0)*(DimSize(iw,0)-1)
			y1=DimOffset(iw,1)+DimDelta(iw,1)*(DimSize(iw,1)-1)
		endif
		
		x2=RW_rot(x0,y0,x1,y1,th,0)
		y2=RW_rot(x0,y0,x1,y1,th,1)
		
		if(x2<xmin)
			xmin=x2
		endif
		if(x2>xmax)
			xmax=x2
		endif
		
		if(y2<ymin)
			ymin=y2
		endif
		if(y2>ymax)
			ymax=y2
		endif
	endfor
	
	variable/g v_xs=xmin
	variable/g v_xe=xmax
	variable/g v_ys=ymin
	variable/g v_ye=ymax
	
	RW_Rot_Wave_do(2)
	if(v_wdim==3)
		RW_Rot_Wave_do(4)
	endif
	SetDataFolder $nf
End

Function RW_rot(x0,y0,x1,y1,th,v)
	variable x0,y0,x1,y1,th,v
	string nf=GetDataFolder(1)
	SetDataFolder root:Rot_Wave
	nvar shift=v_shift
	
	variable x2,y2
	
	if(shift==1)
		x2=x1*cos(th)-y1*sin(th)-x0*cos(th)+y0*sin(th)
		y2=x1*sin(th)+y1*cos(th)-x0*sin(th)-y0*cos(th)
	else
		x2=x1*cos(th)-y1*sin(th)+x0-x0*cos(th)+y0*sin(th)
		y2=x1*sin(th)+y1*cos(th)+y0-x0*sin(th)-y0*cos(th)
	endif
	
	SetDataFolder $nf
	if(v==0)
		return x2
	else
		return y2
	endif
End

Function RW_ButtonProc_opt(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			RW_optimize_range()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function RW_ButtonProc_extract(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(WinType("RW_viewer")==1)
				KillWindow $("RW_viewer")
			endif
			RW_ex_img()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function RW_CheckProc_go(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			RW_vol_slicer()
			RW_Rot_Wave_do(2)
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


//omake
Function perunit(size)
	variable size
	string ws=GetBrowserSelection(0)
	wave w=$ws
	
	variable hw=DimDelta(w,0)*(DimSize(w,0)-1)
	variable vw=DimDelta(w,1)*(DimSize(w,1)-1)
	
	variable para=size*100/max(hw,vw)
	
	ModifyGraph width={perUnit,para,bottom},height={perUnit,para,left}
End
