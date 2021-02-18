#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Macro Make_vol_scale(nws,e_n,t_n,z_s,z_st,outr)
	string nws="output"
	variable e_n=100,t_n=500,z_s=0,z_st=1,outr=-inf
	Prompt e_n,"X Points"
	Prompt t_n,"Y Points"
	Prompt z_s,"Z start"
	Prompt z_st,"Z step"
	Prompt outr,"Fill out of range with"
	Prompt nws,"Output Wave Name"
	mkvl_sc(nws,e_n,t_n,z_s,z_st,outr)
End

Function mkvl_sc(nws,e_n,t_n,z_s,z_st,outr)
	string nws
	variable e_n,t_n,z_s,z_st,outr
	string ws
	variable n
	
	ws=GetBrowserSelection(0)
	wave w=$ws
	
	variable tncheck
	if(t_n==0)
		tncheck=1
	endif
	
	variable e_s=inf,e_e=-inf
	variable t_s=inf,t_e=-inf
	variable es,ee,ts,te,z_n
	n=0
	do
		ws=GetBrowserSelection(n)
		if(StrLen(ws)==0)
			z_n=n
			break
		endif
		wave w=$ws
		
		es=DimOffset(w,0)
		ee=DimOffset(w,0)+DimDelta(w,0)*(DimSize(w,0)-1)
		ts=DimOffset(w,1)
		te=DimOffset(w,1)+DimDelta(w,1)*(DimSize(w,1)-1)
		
		if(es<e_s)
			e_s=es
		endif
		if(ee>e_e)
			e_e=ee
		endif
		
		if(ts<t_s)
			t_s=ts
		endif
		if(te>t_e)
			t_e=te
		endif
		
		if(DimSize(w,1)>t_n && tncheck==1)
			t_n=DimSize(w,1)
		endif
		
		n+=1
	while(1)
	
	variable e_st=(e_e-e_s)/(e_n-1)
	variable t_st=(t_e-t_s)/(t_n-1)
	
	make/O/N=(e_n,t_n,z_n) $nws
	wave nw=$nws
	
	variable t,e,e_i,ex,t_i,tx
	
	for(n=0;n<z_n;n+=1)
		ws=GetBrowserSelection(n)
		wave w=$ws
		for(e=0;e<e_n;e+=1)
			ex=e_s+e*e_st
			e_i=round((ex-DimOffset(w,0))/DimDelta(w,0))
			for(t=0;t<t_n;t+=1)
				tx=t_s+t*t_st
				t_i=round((tx-DimOffset(w,1))/DimDelta(w,1))
				if(e_i>=0 && e_i<DimSize(w,0) && t_i>=0 && t_i<DimSize(w,1))
					nw[e][t][n]=w[e_i][t_i]
				else
					nw[e][t][n]=outr
				endif
			endfor
		endfor
	endfor
	
	SetScale/I x,e_s,e_e,nw
	SetScale/I y,t_s,t_e,nw
	SetScale/P z,z_s,z_st,nw
End