#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function stit_img() //stitch 2D images
	string wnws="wave_name"
	string trws="theta_ref"
	wave/T wnw=$wnws
	wave trw=$trws
	
	variable size=DimSize(wnw,0) //nmax+1
	
	variable nmin,nmax,thn
	variable thmin,thmax
	nmin=WaveMin(trw)
	nmax=WaveMax(trw)
	print nmin,nmax
	string ws
	variable n,tr,es,en,est,ts,tn,tst,ins
	
	for(n=0;n<size;n+=1)
		ws=wnw[n]
		tr=trw[n]
		wave w=$ws
		
		ts=DimOffset(w,1)
		tn=DimSize(w,1)
		tst=DimDelta(w,1)
		es=DimOffset(w,0)
		en=Dimsize(w,0)
		est=DimDelta(w,0)
		
		if(tr==nmax)
			thmin=ts-nmax
		endif
		if(tr==nmin)
			thmax=ts+tn*tst-nmin
		endif

	endfor
	
	print thmax,thmin
	thn=round((thmax-thmin)/tst)+1
	print thn
	variable i,j,k,t,e,tp
	for(n=0;n<size;n+=1)
		string nws="new_"+num2str(n)
		string wws="ww_"+num2str(n)
		make/D/O/N=(en,thn) $nws
		wave nw=$nws
		SetScale/P x,es,est,$nws
		SetScale/P y,thmin,tst,$nws
		
		make/D/O/N=(thn) $wws
		SetScale/P x,thmin,tst,$wws
		wave ww=$wws
		
		ws=wnw[n]
		wave w=$ws
		tr=trw[n]
		
		ts=DimOffset(w,1)
		tn=DimSize(w,1)
		tst=DimDelta(w,1)
		
		ww=0
		for(i=0;i<thn;i+=1)
			t=thmin+i*tst
			if(abs(t+tr)<5)
				ww[i]=1-abs(t+tr)/5
			endif
			if(tr==nmin)
				if(t>tr*-1)
					ww[i]=1
				endif
			endif
			if(tr==nmax)
				if(t<tr*-1)
					ww[i]=1
				endif
			endif
		endfor
	
		for(j=0;j<tn;j+=1)
			for(i=0;i<en;i+=1)
				t=ts+j*tst
				tp=round((t-tr-thmin)/tst)
				nw[i][tp]=w[i][j]*ww[tp]
			endfor
		endfor
		KillWaves $wws
	endfor
	
	string opws="out"
	make/D/O/N=(en,thn) $opws
	wave opw=$opws
	SetScale/P x,es,est,$opws
	SetScale/P y,thmin,tst,$opws
	
	opw=0
	for(n=0;n<size;n+=1)
		ws="new_"+num2str(n)
		wave w=$ws
		opw+=w
		KillWaves $ws
	endfor
End

Function stit_vol() //stitch 3D volumes
	string wnws="wave_name"
	string trws="theta_ref"
	wave/T wnw=$wnws
	wave trw=$trws
	
	variable size=DimSize(wnw,0) //nmax+1
	
	variable nmin,nmax,thn
	variable thmin,thmax
	nmin=WaveMin(trw)
	nmax=WaveMax(trw)
	print nmin,nmax
	string ws
	variable n,tr,es,en,est,ts,tn,tst,ins
	variable ps,pn,pst
	
	for(n=0;n<size;n+=1)
		ws=wnw[n]
		tr=trw[n]
		wave w=$ws
		
		ps=DimOffset(w,2)
		pn=DimSize(w,2)
		pst=DimDelta(w,2)
		ts=DimOffset(w,1)
		tn=DimSize(w,1)
		tst=DimDelta(w,1)
		es=DimOffset(w,0)
		en=Dimsize(w,0)
		est=DimDelta(w,0)
		print tn
		if(tr==nmax)
			thmin=ts-nmax
		endif
		if(tr==nmin)
			thmax=ts+tn*tst-nmin
		endif

	endfor
	
	print thmax,thmin
	thn=round((thmax-thmin)/tst)+1
	print thn
	variable i,j,k,t,e,tp
	for(n=0;n<size;n+=1)
		string nws="new_"+num2str(n)
		string wws="ww_"+num2str(n)
		make/D/O/N=(en,thn,pn) $nws
		wave nw=$nws
		SetScale/P x,es,est,$nws
		SetScale/P y,thmin,tst,$nws
		SetScale/P z,ps,pst,$nws
		
		make/D/O/N=(thn) $wws
		SetScale/P x,thmin,tst,$wws
		wave ww=$wws
		
		ws=wnw[n]
		wave w=$ws
		tr=trw[n]
		
		ts=DimOffset(w,1)
		tn=DimSize(w,1)
		tst=DimDelta(w,1)
		ps=DimOffset(w,2)
		pn=DimSize(w,2)
		pst=DimDelta(w,2)
		
		//wave nom=$("ww")
		
		ww=0
		for(i=0;i<thn;i+=1)
			t=thmin+i*tst
			if(abs(t+tr)<5)
				ww[i]=1-abs(t+tr)/5
			endif
			if(tr==nmin)
				if(t>tr*-1)
					ww[i]=1
				endif
			endif
			if(tr==nmax)
				if(t<tr*-1)
					ww[i]=1
				endif
			endif
		endfor
		
		for(k=0;k<pn;k+=1)	
			for(j=0;j<tn;j+=1)
				for(i=0;i<en;i+=1)
					t=ts+j*tst
					tp=round((t-tr-thmin)/tst)
					nw[i][tp][k]=w[i][j][k]*ww[tp]// /nom[tp]
				endfor
			endfor
		endfor
		//KillWaves $wws
	endfor
	
	string opws="out"
	make/D/O/N=(en,thn,pn) $opws
	wave opw=$opws
	SetScale/P x,es,est,$opws
	SetScale/P y,thmin,tst,$opws
	SetScale/P z,ps,pst,$opws
	
	opw=0
	for(n=0;n<size;n+=1)
		ws="new_"+num2str(n)
		wave w=$ws
		opw+=w
		KillWaves $ws
	endfor
End