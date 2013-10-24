/*______________________________________________________________________
   ¦Autor     ¦ Eraldo Drumond                      ¦ Data ¦ 12/01/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatório do Quadro de Custos                         ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

#include "rwmake.ch" 


User Function RELSZI()

	private nTotal 	:= 0
	private cTab   	:= " "
    private cAnomes := ""
    private cCde    := ""
    private cCate   := ""
    private cUnid   := ""
    private cDescUn := ""
	private aOrd    := {"Anomes + Grupo.CC + C.C + D.C + CodDesp"}
	private aReturn := {"Especial", 1,"Administracao", 1, 2, 1, "", 2}
	private cPerg   := "SZI001"
	private Cabec1  := ""
	private Cabec2  := ""
	private cDesc1  := "QUADRO DE CUSTOS"
	private cString := "SZI"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "M"
	private Titulo  := cDesc1
	private wnrel   := "relSZI"
	private lAborta := .F.
   	private cxCabx1 := "                                          Custo do Mes       Variacao do Mes    Variacao Acumulada     Custo de Producao"
   	private cxCabx2 := "Despesas                               Previsto Realizado        R$       %         R$        %           R$/hr      %  "
	private cNomeEmp:= ""
	private cTipEmp := ""
	private nReduz  := 5
	private nComp	:= 120
	private nRelt	:= 0
	private cPict1  := "@E 999,999"
	private cPict2  := "@E 9,999,999"
	private cPict3  := "E 9,999.99"
    private cxCabec1:= ''
    private cxCabec2:= ''


	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	if nLastKey == 27 ; return ; endif

/*  ______________________________________________________________________
   Pergunta: SZI001 
   			mv_par01 - Ano/mes
   			mv_par02 - C.C de
   			mv_par03 - C.C até
   			mv_par04 - Impressora?: 1-Epson
   								    2-Laser
   			mv_par05 - Tipo ?	  : 1-Analitico
   									2-Sintetico	
   								    	
*/  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    
    If Empty(mv_par01) .or. Empty(mv_par02) .or. Empty(mv_par03) .or. Empty(mv_par04) .or. Empty(mv_par05)  
        return
    endif
	        
	cAnomes := right(mv_par01,2)+'/'+Left(mv_par01,4)
    nImp 	:= mv_par04 
	cEmp := iif(Left(mv_par01,2)='09','01','02')
	nRelt	:= mv_par05 
 	
	If nImp == 1
	   	Processa({|| ImprM()},"","Aguarde. Imprimindo...",lAborta)
	Else
		nComp := 105
		Processa({|| ImprL()},"","Aguarde impressão...",lAborta)
	EndIf

	set device to screen
	
	If lAborta    
		Ms_Flush()
		return
	EndIf
	
	if aReturn[5] == 1
		set printer to
		DbCommitAll()
		DbCloseArea()
		OurSpool(wnrel)
	else
		DbCloseArea()
	endif
	
	Ms_Flush()
return


Static Function ImprL()

dbselectarea("SZI")
dbSetOrder(2)
 
If nRelt == 1
	set filter to (ZI_AM = mv_par01) .and. (ZI_CUSTO >= mv_par02 .and. ZI_CUSTO <= mv_par03) .and. (ZI_VARMES <> 0) 
Else 
	set filter to (ZI_AM = mv_par01) .and. (ZI_CUSTO >= mv_par02 .and. ZI_CUSTO <= mv_par03) .and. (ZI_VARMES <> 0) .and. (ZI_TITULO = '1') 
EndIf  
	
	ProcRegua(SZI->(RecCount()))
	
    dbGoTop()
	
	If Empty(SZI->ZI_AM)
	   msgbox('Nenhum registro selecionado. Verifique os parâmetros.')
	   set filter to
	   lAborta := .T.
	   Return
	EndIf
	
	While !SZI->(Eof())      
		
		dbselectarea("CTT")
	  	dbSetOrder(1)
	  	dbseek(xfilial("CTT")+SZI->ZI_CUSTO)
	  	
		dbselectarea("SZA")
	  	dbSetOrder(1)
	  	dbseek(xfilial("SZA")+SZI->ZI_CUSTO+SZI->ZI_DC)
	  	cUnid := trim(SZA->ZA_UNID)

	  	dbselectarea("SZI")
	  	dbSetOrder(2)                  
	  	       
	  	Do Case
	  		Case cUnid == "HMC"
	  			cDescun := "HORAS MES CALENDÁRIO" 		
	  		Case cUnid == "HMQ"
	  			cDescun := 'HORAS MÁQUINA MES' 			
	  		Case cUnid == "HH"
	  			cDescun := 'HOMENS HORAS MES' 			
	  		Case cUnid == "HHM"
	  			cDescun := 'HOMENS HORAS MANUTENÇÃO' 		
	  		Otherwise
	  			cDescun := 'XXXXXXXXXXX' 							
	  	EndCase

   	    impCabec()
 	  
	  	cCusto	 := SZI->ZI_CUSTO
	
	  While ( !SZI->(Eof()) ) .and. ( SZI->ZI_CUSTO == cCusto ) 
		        
		cGrupocd := SZI->ZI_GRUPOCD
	  
		If right(SZI->ZI_CODESP,3) == '999' .and. !SZI->ZI_CODESP == '070999'
			// não tem detalhes para totalização
		    SZI->(DbSkip())		
	        Loop
	    EndIf
	
		While ( !SZI->(Eof()) ) .and. ( SZI->ZI_CUSTO == cCusto ) .and. ( SZI->ZI_GRUPOCD == cGrupocd ) 

			If right(SZI->ZI_CODESP,3) == '999'
			   @Prow()+1,007 psay Replicate("-",98)
			EndIf

			@Prow()+1,000 	   	psay iif(SZI->ZI_TITULO='2',SZI->ZI_CODESP,'      ')
 			@Prow()  ,Pcol() 	psay iif(SZI->ZI_TITULO='2','-'+Left(SZI->ZI_DESCCD,38),'*'+Left(SZI->ZI_DESCCD,37))
			@Prow()  ,Pcol()+3 	psay SZI->ZI_orcado  picture "@E 999,999"
			@Prow()  ,Pcol()+3	psay SZI->ZI_realiza  picture "@E 999,999"   //cPict1
			@Prow()  ,Pcol()+2 	psay SZI->ZI_VARMES  picture "@E 9,999,999"  //    2
			@Prow()  ,Pcol()+2	psay SZI->ZI_PCVMES  picture "999"
			@Prow()  ,Pcol()+2 	psay SZI->ZI_VARACUM picture "@E 9,999,999"   //    2
			@Prow()  ,Pcol()+2	psay SZI->ZI_PCVACUM picture "999"
			@Prow()  ,Pcol()+2 	psay SZI->ZI_CUSTOP  picture "@E 9,999.99"    //    3
			@Prow()  ,Pcol()+2	psay SZI->ZI_PCUSTOP picture "999"
		    
			If SZI->ZI_TITULO == '1' .and. nRelt == 1
			   	@Prow()+1,007 psay Replicate("-",98)
			EndIf
			 
			IncProc()
		
			SZI->(DbSkip())

		    If ( !SZI->(Eof()) ) .and. ( (Prow() >= 55) ) .and. ( SZI->ZI_CUSTO == cCusto )
			  Roda(0,"",Tamanho)
			  impcabec()
		    endif

		 Enddo

		@Prow()+1,000 psay Replicate("-",105)
	  Enddo
	  
	  If !SZI->(Eof())	 
	      Roda(0,"",Tamanho)
	  EndIf
	  
	Enddo
	
	set filter to
	Roda(0,"",Tamanho)
	   
Return


Static Function ImprM()

dbselectarea("SZI")
dbSetOrder(2)

If nRelt == 1
	set filter to (ZI_AM = mv_par01) .and. (ZI_CUSTO >= mv_par02 .and. ZI_CUSTO <= mv_par03) .and. (ZI_VARMES <> 0) 
Else 
	set filter to (ZI_AM = mv_par01) .and. (ZI_CUSTO >= mv_par02 .and. ZI_CUSTO <= mv_par03) .and. (ZI_VARMES <> 0) .and. (ZI_TITULO = '1') 
EndIf  

	ProcRegua(SZI->(RecCount()))
	
    dbGoTop()

	If Empty(SZI->ZI_AM)
	   msgbox('Nenhum registro selecionado. Verifique os parâmetros.')
	   set filter to
	   lAborta := .T.
	   Return
	EndIf

	While !SZI->(Eof())
	
		dbselectarea("CTT")
	  	dbSetOrder(1)
	  	dbseek(xfilial("CTT")+SZI->ZI_CUSTO)
	  	
		dbselectarea("SZA")
	  	dbSetOrder(1)
	  	dbseek(xfilial("SZA")+SZI->ZI_CUSTO+SZI->ZI_DC)
	  	cUnid := trim(SZA->ZA_UNID)

	  	dbselectarea("SZI")
	  	dbSetOrder(2)                  
	  	       
	  	Do Case
	  		Case cUnid == "HMC"
	  			cDescun := "HORAS MES CALENDÁRIO" 		
	  		Case cUnid == "HMQ"
	  			cDescun := 'HORAS MÁQUINA MES' 			
	  		Case cUnid == "HH"
	  			cDescun := 'HOMENS HORAS MES' 			
	  		Case cUnid == "HHM"
	  			cDescun := 'HOMENS HORAS MANUTENÇÃO' 		
	  		Otherwise
	  			cDescun := 'XXXXXXXXXXX' 							
	  	EndCase

   	    impCabeP()
 	  
	  	cCusto	 := SZI->ZI_CUSTO
	
	  While ( !SZI->(Eof()) ) .and. ( SZI->ZI_CUSTO == cCusto ) 
		        
		cGrupocd := SZI->ZI_GRUPOCD
	  
		If right(SZI->ZI_CODESP,3) == '999' .and. !SZI->ZI_CODESP == '070999'
			// não tem detalhes para totalização
		    SZI->(DbSkip())		
	        Loop
	    EndIf
	
		While ( !SZI->(Eof()) ) .and. ( SZI->ZI_CUSTO == cCusto ) .and. ( SZI->ZI_GRUPOCD == cGrupocd ) 

			If right(SZI->ZI_CODESP,3) == '999'
			   @Prow()+1,007 psay Replicate("-",98)
			EndIf

			@Prow()+1,000 	   	psay iif(SZI->ZI_TITULO='2',SZI->ZI_CODESP,'      ')
 			@Prow()  ,Pcol() 	psay iif(SZI->ZI_TITULO='2','-'+Left(SZI->ZI_DESCCD,38),'*'+Left(SZI->ZI_DESCCD,37))
			@Prow()  ,Pcol()+3 	psay SZI->ZI_orcado  picture "@E 999,999"
			@Prow()  ,Pcol()+3	psay SZI->ZI_realiza  picture "@E 999,999"   //cPict1
			@Prow()  ,Pcol()+2 	psay SZI->ZI_VARMES  picture "@E 9,999,999"  //    2
			@Prow()  ,Pcol()+2	psay SZI->ZI_PCVMES  picture "999"
			@Prow()  ,Pcol()+2 	psay SZI->ZI_VARACUM picture "@E 9,999,999"   //    2
			@Prow()  ,Pcol()+2	psay SZI->ZI_PCVACUM picture "999"
			@Prow()  ,Pcol()+2 	psay SZI->ZI_CUSTOP  picture "@E 9,999.99"    //    3
			@Prow()  ,Pcol()+2	psay SZI->ZI_PCUSTOP picture "999"
		    
			If SZI->ZI_TITULO == '1' .and. nRelt == 1
			   	@Prow()+1,007 psay Replicate("-",98)
			EndIf
			 
			IncProc()
		
			SZI->(DbSkip())

		    If ( !SZI->(Eof()) ) .and. ( (Prow() >= 57) ) .and. ( SZI->ZI_CUSTO == cCusto )
			  //Roda(0,"",Tamanho)
			  ImpcabEp()
		    endif

		 Enddo

		@Prow()+1,000 psay Replicate("-",105)
	  Enddo
	  
	  If !SZI->(Eof())	 
	      //Roda(0,"",Tamanho)
	  EndIf
	  
	Enddo
	
	set filter to
	   
Return
 

Static Function impCabec()
		
	Cabec(Titulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)

 	cAux  := 'Mes/Ano  :  '+cAnomes+']'
	cxTit := space(nComp -Len(cAux))
	cxTit := cxTit + cAux
	@Prow()+1,000 psay cxTit
                        
    cxTit := cDescun + '-['+'PREVISTO: '+transform(SZI->ZI_VOLORC, "@E 9,999.99")+ ']'
    cxTit := cxTit + '-['+' REALIZADO: '+transform(SZI->ZI_VOLORC, "@E 9,999.99")+ ']' 
                          
	@Prow()+1,000 psay Left(SZI->ZI_CUSTO,5) +'-'+Left(CTT->CTT_DESC01,30)
	@Prow()  ,105-len(cxTit) psay cxTit
	@Prow()+1,000 psay replicate("-",105)
  	//                                                                                                                        105
	@Prow()+1,000 psay "                                          Custo do Mes      Variação  Mes  Variação Acum  Custo Produção"
	@Prow()+1,000 psay "Despesas                               Previsto Realizado       R$      %      R$      %      R$/hr    %"                                                  
	//													          (a)      (b)      (c)=(a-b)         (+c)            (b/hr)     
	//													        999,999   999,999  9,999,999  999  9,999,999 999   9,999.99  999
	@Prow()+1,000 psay replicate("-",105)

Return

 

Static Function impCabEp()

	cEmp :=iif(Left(SZI->ZI_CUSTO,2)='09','01','02')
	U_ImpCab80(cNomeEmp,cTipEmp,Titulo,cxCabec1,cxCabec2,Tamanho,nReduz,nComp,cEmp)
	m_Pag := m_Pag + 1
                                                  
 	cAux  := 'Mes/Ano  :  '+cAnomes+']'
	cxTit := space(nComp -Len(cAux))
	cxTit := cxTit + cAux
   
	@Prow()+1,000 psay U_Reduz(5) + cxTit + U_Reduz(0)

    cxTit := cDescun + '-['+'PREVISTO: '+transform(SZI->ZI_VOLORC, "@E 9,999.99")+ ']'
    cxTit := cxTit + '-['+'REALIZADO: '+transform(SZI->ZI_VOLORC, "@E 9,999.99")+ ']' 
    nLenT := len(cxTit)       
           
    cxImp := Left(SZI->ZI_CUSTO,5) +'-'+Left(CTT->CTT_DESC01,30)
    nLenI := len(cxImp)
    
    cxImp := cxImp + space(nComp -(nLenT + nLenI))
    cxImp := cxImp + cxTit                       
  
	@Prow()+1,000 psay U_Reduz(5) + cxImp + U_Reduz(0)                                     // Left(SZI->ZI_CUSTO,4) +'-'+Left(CTT->CTT_DESC01,30)
   //	@Prow()  ,nComp-len(cxTit) psay cxTit
	@Prow()+1,000 psay U_Reduz(5)+replicate("-",120)+U_Reduz(0)
  	                                                                                                                        105
	@Prow()+1,000 psay U_Reduz(5) + cxCabx1 + U_Reduz(0)
	@Prow()+1,000 psay U_Reduz(5) + cxCabx2 + U_Reduz(0)

	@Prow()+1,000 psay U_Reduz(5) + replicate("-",nComp) + U_Reduz(0)

Return


