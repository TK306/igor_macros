#pragma rtGlobals=1	// Use modern global access method.

Function trim_2dw(iws,ows,p,xs,xe,ys,ye) // FOR USER
	string iws,ows
	variable p,xs,xe,ys,ye
	
	
	// iws : input wave name, (both full path or not is ok)
	// ows : output wave name, default=NaN (both full path or not is ok)
	// p : range parameter setting, 0: point, 1: scale value
	// xs,xe,ys,ye : start and end value in x or y dim, default=NaN
	
	string nf=GetDataFolder(1)
	
	wave iw=$iws
	string iws1=GetWavesDatafolder(iw,2)
	iws=iws1
	variable go=TI_start(iws)
	if(go==1)
		SetDataFolder root:Trim_Image
		
		if(!StringMatch(ows,""))
			string/g s_outname=ows
		endif
		
		if(p==0)
			if(NumType(xs)==0)
				variable/g v_xs=xs
			endif
			if(NumType(xe)==0)
				variable/g v_xe=xe
			endif
			if(NumType(ys)==0)
				variable/g v_ys=ys
			endif
			if(NumType(ye)==0)
				variable/g v_ye=ye
			endif
			TI_s2p()
		elseif(p==1)
			if(NumType(xs)==0)
				variable/g v_xsp=xs
			endif
			if(NumType(xe)==0)
				variable/g v_xep=xe
			endif
			if(NumType(ys)==0)
				variable/g v_ysp=ys
			endif
			if(NumType(ye)==0)
				variable/g v_yep=ye
			endif
			TI_p2s()
		endif
		
		
		TI_trim_image_do()
		
		TI_save()
		
		KillDataFolder root:Trim_Image
	else
		print "Wave error"
	endif
	SetDataFolder $nf
End









Macro Call_Trim_Image_panel()
	variable go=TI_start(GetBrowserSelection(0))
	if(go==1)
		if(strlen(WinList("Trim_Image_p", ";", "WIN:64")))
			DoWindow/F Trim_Image_p
		else
			TI_make_panel()
		endif
		TI_set_panel()
		TI_trim_image_do()
	endif
End

Function TI_start(ws)
	string ws
	if(WaveExists($ws) && WaveDims($ws)==2)
		wave w=$ws
		string nf=GetDataFolder(1)
		NewDataFolder/S/O root:Trim_Image
		Duplicate/O w,ori_img
		Duplicate/O w,trim_img
		string/g s_ws=ws
		string/g s_outname=ws+"_TI"
		variable/g v_xs=DimOffset(w,0)
		variable/g v_xe=DimOffset(w,0)+DimDelta(w,0)*(DimSize(w,0)-1)
		variable/g v_ys=DimOffset(w,1)
		variable/g v_ye=DimOffset(w,1)+DimDelta(w,1)*(DimSize(w,1)-1)
		variable/g v_xsp=0
		variable/g v_ysp=0
		variable/g v_xep=DimSize(w,0)-1
		variable/g v_yep=DimSize(w,1)-1
		variable/g v_p
		variable/g v_val=-inf
		SetDataFolder $nf
		return 1
	else
		return 0
	endif
End

Function TI_make_panel()
	string nf=GetDataFolder(1)
	SetDataFolder root:Trim_Image
	wave w=$("ori_img")
	PauseUpdate; Silent 1		// building window...
	NewPanel /N=Trim_Image_p/K=1/W=(355,78,935,423) as "Trimming panel"
	ModifyPanel cbRGB=(65534,65534,65534)
	ModifyPanel fixedSize=1
	SetDrawLayer UserBack
	DrawPoly 267.357142857143,70.972972972973,0.452381,0.432432,{237,378,284,375,285,348,318,394,283,422,281,399,234,400,237,378}
	DrawPoly 267.357142857143,118.972972972973,0.452381,0.432432,{237,378,284,375,285,348,318,394,283,422,281,399,234,400,237,378}
	DrawPoly 267.357142857143,166.972972972973,0.452381,0.432432,{237,378,284,375,285,348,318,394,283,422,281,399,234,400,237,378}
	SetVariable setvar_xs,pos={12.00,269.00},size={122.00,18.00},bodyWidth=80,proc=TI_SetVarProc_go,title="x start :"
	SetVariable setvar_xs,limits={-inf,inf,DimDelta(w,0)},value= root:Trim_Image:v_xs
	SetVariable setvar_xe,pos={15.00,291.00},size={119.00,18.00},bodyWidth=80,proc=TI_SetVarProc_go,title="x end :"
	SetVariable setvar_xe,limits={-inf,inf,DimDelta(w,0)},value= root:Trim_Image:v_xe
	SetVariable setvar_ys,pos={147.00,269.00},size={122.00,18.00},bodyWidth=80,proc=TI_SetVarProc_go,title="y start :"
	SetVariable setvar_ys,limits={-inf,inf,DimDelta(w,1)},value= root:Trim_Image:v_ys
	SetVariable setvar_ye,pos={150.00,290.00},size={119.00,18.00},bodyWidth=80,proc=TI_SetVarProc_go,title="y end :"
	SetVariable setvar_ye,limits={-inf,inf,DimDelta(w,1)},value= root:Trim_Image:v_ye
	SetVariable setvar_save,pos={360.00,292.00},size={215.00,18.00},bodyWidth=200,title="as"
	SetVariable setvar_save,limits={-inf,inf,0},value= root:Trim_Image:s_outname
	Button button_save,pos={343.00,270.00},size={50.00,20.00},proc=TI_ButtonProc_save,title="SAVE"
	CheckBox check_p,pos={17.00,309.00},size={44.00,15.00},proc=TI_CheckProc_p,title="Point"
	CheckBox check_p,value= 0
	Button button_auto,pos={71.00,309.00},size={60.00,20.00},proc=TI_ButtonProc_auto_set,title="Auto set"
	SetVariable setvar_autoval,pos={134.00,310.00},size={82.00,18.00},bodyWidth=30,title="outrange"
	SetVariable setvar_autoval,limits={-inf,inf,0},value= root:Trim_Image:v_val
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
	Cursor/P/I/S=2/H=1/N/C=(65535,65535,0) A ori_img 17,20;Cursor/P/I/S=2/H=1/N/C=(65535,65535,0) B ori_img 131,335
	RenameWindow #,ori_w
	SetActiveSubwindow ##
	Display/W=(308,7,568,267)/HOST=# 
	AppendImage $("trim_img")
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
	RenameWindow #,trim_w
	SetActiveSubwindow ##
	SetDataFolder $nf
EndMacro

Function TI_trim_image_do()
	string nf=GetDataFolder(1)
	SetDataFolder root:Trim_Image
	string iws="ori_img"
	string ows="trim_img"
	nvar xs=v_xs
	nvar xe=v_xe
	nvar ys=v_ys
	nvar ye=v_ye
	
	variable temp
	if(xs>xe)
		temp=xs
		xs=xe
		xe=temp
	endif
	
	if(ys>ye)
		temp=ys
		ys=ye
		ye=temp
	endif
	
	wave iw=$iws
	
	variable ixs=DimOffset(iw,0)
	variable ixst=DimDelta(iw,0)
	variable ixn=DimSize(iw,0)
	
	variable iys=DimOffset(iw,1)
	variable iyst=DimDelta(iw,1)
	variable iyn=DimSize(iw,1)
	
	variable xsp=round((xs-ixs)/ixst)
	variable ysp=round((ys-iys)/iyst)
	variable xep=round((xe-ixs)/ixst)
	variable yep=round((ye-iys)/iyst)
	
	variable oxs=ixs+xsp*ixst
	variable oxst=ixst
	variable oxe=ixs+xep*ixst
	variable oxn=(oxe-oxs)/oxst+1
	
	variable oys=iys+ysp*iyst
	variable oyst=iyst
	variable oye=iys+yep*iyst
	variable oyn=abs((oye-oys)/oyst)+1
	
	make/O/N=(oxn,oyn) $ows
	wave ow=$ows
	
	SetScale/P x,oxs,oxst,WaveUnits(iw,0),ow
	SetScale/P y,oys,oyst,WaveUnits(iw,1),ow
	
	variable oxi,oyi
	variable ixi,iyi
	iyi=ysp
	for(oyi=0;oyi<oyn;oyi+=1)
		ixi=xsp
		for(oxi=0;oxi<oxn;oxi+=1)
			ow[oxi][oyi]=iw[ixi][iyi]
			ixi+=1
		endfor
		iyi+=1
	endfor
	SetDataFolder $nf
	if(WinType("Trim_Image_p")==7)
		TI_set_cursor()
	endif
End

Function TI_SetVarProc_go(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			TI_set_params()
			TI_trim_image_do()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function TI_set_cursor()
	string nf=GetDataFolder(1)
	SetDataFolder root:Trim_Image
	nvar xs=v_xs
	nvar xe=v_xe
	nvar ys=v_ys
	nvar ye=v_ye
	
	Cursor/I/C=(65535,65535,0)/W=Trim_Image_p#ori_w/A=1/h=1/s=2/N=1 a ori_img,xs,ys
	Cursor/I/C=(65535,65535,0)/W=Trim_Image_p#ori_w/A=1/h=1/s=2/N=1 b ori_img,xe,ye
	
	SetDataFolder $nf
End

Function CursorMovedHook(info)
	String info
	string nf=GetDataFolder(1)
	if(StringMatch(StringByKey("GRAPH",info),"ori_w") && StringMatch(StringByKey("TNAME",info),"ori_img"))
		SetDataFolder root:Trim_Image
		string/g s_ws
		wave w=$s_ws
		variable xp,yp,xv,yv
		xp=str2num(StringByKey("POINT",info))
		yp=str2num(StringByKey("YPOINT",info))
		
		xv=DimOffset(w,0)+xp*DimDelta(w,0)
		yv=DimOffset(w,1)+yp*DimDelta(w,1)
		
		if(StringMatch(StringByKey("CURSOR",info),"A"))
			variable/g v_xs=xv
			variable/g v_ys=yv
			variable/g v_xsp=xp
			variable/g v_ysp=yp
		elseif(StringMatch(StringByKey("CURSOR",info),"B"))
			variable/g v_xe=xv
			variable/g v_ye=yv
			variable/g v_xep=xp
			variable/g v_yep=yp
		endif
		TI_trim_image_do()
	endif
	SetDataFolder $nf
End

Function TI_save()
	string nf=GetDataFolder(1)
	SetDataFolder root:Trim_Image
	string/g s_outname
	Duplicate/O $("trim_img"),$s_outname
	SetDataFolder $nf
End

Function TI_ButtonProc_save(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			TI_save()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function TI_s2p()
	string nf=GetDataFolder(1)
	SetDataFolder root:Trim_Image
	string/g s_ws
	wave w=$s_ws
	nvar xs=v_xs
	nvar xe=v_xe
	nvar ys=v_ys
	nvar ye=v_ye
	
	variable/g v_xsp=round((xs-DimOffset(w,0))/DimDelta(w,0))
	variable/g v_ysp=round((ys-DimOffset(w,1))/DimDelta(w,1))
	variable/g v_xep=round((xe-DimOffset(w,0))/DimDelta(w,0))
	variable/g v_yep=round((ye-DimOffset(w,1))/DimDelta(w,1))
	SetDataFolder $nf
End

Function TI_p2s()
	string nf=GetDataFolder(1)
	SetDataFolder root:Trim_Image
	string/g s_ws
	wave w=$s_ws
	nvar xsp=v_xsp
	nvar xep=v_xep
	nvar ysp=v_ysp
	nvar yep=v_yep
	
	variable/g v_xs=DimOffset(w,0)+xsp*DimDelta(w,0)
	variable/g v_ys=DimOffset(w,1)+ysp*DimDelta(w,1)
	variable/g v_xe=DimOffset(w,0)+xep*DimDelta(w,0)
	variable/g v_ye=DimOffset(w,1)+yep*DimDelta(w,1)
	SetDataFolder $nf
End

Function TI_set_params()
	string nf=GetDataFolder(1)
	SetDataFolder root:Trim_Image
	variable/g v_p
	
	if(v_p==0)
		TI_s2p()
	elseif(v_p==1)
		TI_p2s()
	endif
	SetDataFolder $nf
End

Function TI_CheckProc_p(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			string nf=GetDataFolder(1)
			SetDataFolder root:Trim_Image
			variable/g v_p=checked
			SetDataFolder $nf
			TI_set_panel()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

Function TI_set_panel()
	string nf=GetDataFolder(1)
	SetDataFolder root:Trim_Image
	variable/g v_p
	wave w=$("ori_img")
	
	variable xs=DimOffset(w,0)
	variable xe=DimOffset(w,0)+DimDelta(w,0)*(DimSize(w,0)-1)
	variable ys=DimOffset(w,1)
	variable ye=DimOffset(w,1)+DimDelta(w,1)*(DimSize(w,1)-1)
	
	if(v_p==0)
		SetVariable setvar_xs win=Trim_Image_p,value=root:Trim_Image:v_xs
		SetVariable setvar_ys win=Trim_Image_p,value=root:Trim_Image:v_ys
		SetVariable setvar_xe win=Trim_Image_p,value=root:Trim_Image:v_xe
		SetVariable setvar_ye win=Trim_Image_p,value=root:Trim_Image:v_ye
		SetVariable setvar_xs win=Trim_Image_p,limits={xs,xe,DimDelta(w,0)}
		SetVariable setvar_ys win=Trim_Image_p,limits={ys,ye,DimDelta(w,1)}
		SetVariable setvar_xe win=Trim_Image_p,limits={xs,xe,DimDelta(w,0)}
		SetVariable setvar_ye win=Trim_Image_p,limits={ys,ye,DimDelta(w,1)}
		CheckBox check_p win=Trim_Image_p,value=0
	elseif(v_p==1)
		SetVariable setvar_xs win=Trim_Image_p,value=root:Trim_Image:v_xsp
		SetVariable setvar_ys win=Trim_Image_p,value=root:Trim_Image:v_ysp
		SetVariable setvar_xe win=Trim_Image_p,value=root:Trim_Image:v_xep
		SetVariable setvar_ye win=Trim_Image_p,value=root:Trim_Image:v_yep
		SetVariable setvar_xs win=Trim_Image_p,limits={0,DimSize(w,0)-1,1}
		SetVariable setvar_ys win=Trim_Image_p,limits={0,DimSize(w,1)-1,1}
		SetVariable setvar_xe win=Trim_Image_p,limits={0,DimSize(w,0)-1,1}
		SetVariable setvar_ye win=Trim_Image_p,limits={0,DimSize(w,1)-1,1}
		CheckBox check_p win=Trim_Image_p,value=1
	endif
	SetDataFolder $nf
End


Function TI_auto_set()
	string nf=GetDataFolder(1)
	SetDataFolder root:Trim_Image
	nvar v_xsp
	nvar v_xep
	nvar v_ysp
	nvar v_yep
	nvar val=v_val
	string ws="ori_img"
	wave w=$ws
	make/O/N=(DimSize(w,0)) $("sl_x")
	make/O/N=(DimSize(w,1)) $("sl_y")
	wave sx=$("sl_x")
	wave sy=$("sl_y")
	v_xsp=0
	v_ysp=0
	v_xep=DimSize(w,0)-1
	v_yep=DimSize(w,1)-1
	variable i,j,go,f
	for(j=0;j<DimSize(w,1);j+=1)
		i=0
		go=1
		do
			if(w[i][j]!=val)
				go=0
				f=0
			endif
			if(i==DimSize(w,0)-1)
				go=0
				f=1
			endif
			i+=1
		while(go)
		sy[j]=f
	endfor
	
	for(i=0;i<DimSize(w,0);i+=1)
		j=0
		go=1
		do
			if(w[i][j]!=val)
				go=0
				f=0
			endif
			if(j==DimSize(w,1)-1)
				go=0
				f=1
			endif
			j+=1
		while(go)
		sx[i]=f
	endfor
	
	i=0
	do
		if(sx[i]==0)
			break
		endif
		i+=1
		v_xsp=i
	while(1)
	
	i=0
	do
		if(sx[DimSize(sx,0)-1-i]==0)
			break
		endif
		i+=1
		v_xep=DimSize(sx,0)-1-i
	while(1)
	
	i=0
	do
		if(sy[i]==0)
			break
		endif
		i+=1
		v_ysp=i
	while(1)
	
	i=0
	do
		if(sy[DimSize(sy,0)-1-i]==0)
			break
		endif
		i+=1
		v_yep=DimSize(sy,0)-1-i
	while(1)
	
	SetDataFolder $nf
	TI_p2s()
	TI_trim_image_do()
End

Function TI_ButtonProc_auto_set(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			TI_auto_set()
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
