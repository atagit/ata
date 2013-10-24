/*______________________________________________________________________
   ¦Autor     ¦ Eraldo Drumond                      ¦ Data ¦ 12/01/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Relatório do Livro de Orçamento                       ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

#include "rwmake.ch" 


User Function RELSZF()

	private nTotal 	:= 0
	private nSrh	:= 0
	private nSrm	:= 0
	private nRelt	:= 0
	private cTab   	:= " "
    private cUnid   := ""
    private cPreco	:= ""
	private aOrd    := {"Grupo.CC + C.C + D.C + CodDesp"}
	private aReturn := {"Especial", 1,"Administracao", 1, 2, 1, "", 2}
	private cPerg   := ""
	private Cabec1  := ""
	private Cabec2  := ""
	private cDesc1  := "LIVRO DE ORCAMENTOS"
	private ContFun := 0
	private cString := "SZF"
	private m_pag   := 1
	private nOrdem  := 0
	private nTipo   := 0
	private Tamanho := "P"
	private Titulo  := cDesc1
	private wnrel   := "RELSZF"
	private lAborta := .T.
	private cPerg   := "SZF001"
	private CxCabec1 := "                                              Preco      Qtde    Custo Previsto" 
	private CxCabec2 := "Despesas                              Unid  Unitario   Orcada    Hora  ---Mes--"
	private cNomeEmp:= ""
	private cTipEmp := ""
	private nReduz  := 0
	private nComp	:= 80

	Pergunte(cPerg,.F.)
	
	wnrel := SetPrint(cString,wnrel,cPerg,Titulo,cDesc1,,,.T.,aOrd,,Tamanho)
	
	if nLastKey == 27 ; return ; endif
	
	SetDefault(aReturn,cString)
	nOrdem  := aReturn[8]
	
	
	if nLastKey == 27 ; return ; endif
	
	
/*  ______________________________________________________________________
   Pergunta: SZF001
   			mv_par01 - C.C de
   			mv_par02 - C.C até
   			mv_par03 - Impressora?: 1-Epson
   								    2-Laser
   			mv_par04 - Tipo ?	  : 1-Analitico
   									2-Sintetico	
*/  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
    
    If Empty(mv_par01) .or. Empty(mv_par02) .or. Empty(mv_par03) .or. Empty(mv_par04) 
        return
    endif

    nImp := mv_par03 
 	nRelt:= mv_par04    
 
	cEmp := iif(Left(mv_par01,2)='09','01','02')

	If nImp == 1
	   	Processa({|| ImprM()},"","Aguarde. Imprimindo...",lAborta)
	Else
		Processa({|| ImprL()},"","Aguarde. Imprimindo...",lAborta)
		Roda(0,"",Tamanho)
	EndIf

	set device to screen
	
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


static function ImprL()

dbselectarea("SZF")
dbSetOrder(2)       

If nRelt == 1
	set filter to ZF_CUSTOM > 0 .and. (ZF_CUSTO >= mv_par01 .and. ZF_CUSTO <= mv_par02)
Else 
	set filter to (ZF_CUSTOM > 0) .and. (ZF_TITULO = '1') .and. (ZF_CUSTO >= mv_par01 .and. ZF_CUSTO <= mv_par02) 
EndIf   
 
		
	ProcRegua(SZF->(RecCount()))
	
    dbGoTop()
	While !SZF->(Eof())
	
		dbselectarea("CTT")
	  	dbSetOrder(1)
	  	dbseek(xfilial("CTT")+SZF->ZF_CUSTO)

	  	dbselectarea("SZF")
	  	dbSetOrder(2)                  
	  	       
	  	cUnid := SZF->ZF_UNID
	  	Do Case
	  		Case cUnid == 'HMC'
	  			cDesc := 'HORAS MES CALENDÁRIO' 		
	  		Case cUnid == 'HMQ'
	  			cDesc := 'HORAS MÁQUINA MES   ' 			
	  		Case cUnid == 'HH'
	  			cDesc := 'HOMENS HORAS MES    ' 			
	  		Case cUnid == 'HHM'
	  			cDesc := 'HOMENS HORAS MANUTENÇÃO' 		
	  		Otherwise
	  			cDesc := 'XXXXXX' 							
	  	EndCase

 		impCabec()
 	  	
	  	cCusto := SZF->ZF_CUSTO
	
	  while ( !SZF->(Eof()) ) .and. ( SZF->ZF_CUSTO == cCusto ) 
		        
		cGrupocd := SZF->ZF_GRUPOCD
		
		If right(SZF->ZF_CODESP,3) == '999' .and. !SZF->ZF_CODESP == '070999'
			// não tem detalhes para totalização
		    SZF->(DbSkip())		
	        Loop
	    EndIf
	     
		While ( !SZF->(Eof()) ) .and. ( SZF->ZF_CUSTO == cCusto ) .and. ( SZF->ZF_GRUPOCD == cGrupocd ) 
			                                            
			nPreco 	:= SZF->ZF_PRECO   
		    cPreco	:= str(nPreco,12,4)
		    cPreco	:= AllTrim(cPreco)

			If len(cPreco) > 8
				cPreco := transform(SZF->ZF_PRECO, "@E 9999,999")
			else
			  	cPreco := transform(SZF->ZF_PRECO, "@E 9,999.99")
			EndIf
			
			If right(SZF->ZF_CODESP,3) == '999'
			   @Prow()+1,007 psay Replicate("-",73)
			EndIf
						
			@Prow()+1,000 	   	psay iif(SZF->ZF_TITULO='2',SZF->ZF_CODESP,'      ')
 			@Prow()  ,Pcol() 	psay iif(SZF->ZF_TITULO='2','-'+Left(SZF->ZF_DESCCD,30),'*'+Left(SZF->ZF_DESCCD,30))
			@Prow()  ,Pcol()+1	psay iif(SZF->ZF_TITULO='2',Left(SZF->ZF_UNID,3),'   ')
			@Prow()  ,Pcol()+3 	psay iif(SZF->ZF_PRECO>0, cPreco,"        ")
			@Prow()  ,Pcol()+1 	psay iif(SZF->ZF_QTDORC>0,transform(SZF->ZF_QTDORC,"@E 9,999.99"),"        ")
			@Prow()  ,Pcol()+1 	psay SZF->ZF_CUSTOU picture "@E 9999.99"
			@Prow()  ,Pcol()+1	psay SZF->ZF_CUSTOM picture "@E 9,999,999"
		    
			If SZF->ZF_TITULO == '1' .and. nRelt == 1
			   @Prow()+1,007 psay Replicate("-",73)
			EndIf
			 
			IncProc()
		
			SZF->(DbSkip())

			If ( !SZF->(Eof()) ) .and. ( (Prow() >= 55) ) .and. ( SZF->ZF_CUSTO == cCusto )
				Roda(0,"",Tamanho)
				impcabec()
			endif                      
		 
		 Enddo

		@Prow()+1,000 psay Replicate("-",80)
	 Enddo
	  
	  If !SZF->(Eof())	                  
	    Roda(0,"",Tamanho)
	  EndIf
	  
	Enddo
	
	set filter to
	   
Return
                     
 

Static Function impCabec()
		
	Cabec(Titulo,Cabec1,Cabec2,wnrel,Tamanho,nTipo)
                        
    cxTit := trim(cDesc)+'-[' + trim(cUnid) + ': ' + transform(SZF->ZF_VOLORC, "@E 9,999.99")+ ']'
                          
	@Prow()+1,000 psay Left(SZF->ZF_CUSTO,5) +'-'+CTT->CTT_DESC01
	@Prow()  , 80-len(cxTit) psay cxTit
	@Prow()+1,000 psay replicate("-",80)
    //58       67   +12      81  +12       Qt orçada?     R$/Hora
	@Prow()+1,000 psay "                                              Preço      Qtde    Custo Previsto"
	@Prow()+1,000 psay "Despesas                              Unid  Unitário   Orçada    Hora  ---Mes--"                                                  
	@Prow()+1,000 psay replicate("-",80)

Return



Static Function ImprM()

dbselectarea("SZF")
dbSetOrder(2)

If nRelt == 1
	set filter to ZF_CUSTOM > 0 .and. (ZF_CUSTO >= mv_par01 .and. ZF_CUSTO <= mv_par02)
Else 
	set filter to (ZF_CUSTOM > 0) .and. (ZF_TITULO = '1') .and. (ZF_CUSTO >= mv_par01 .and. ZF_CUSTO <= mv_par02) 
EndIf   
	
	ProcRegua(SZF->(RecCount()))
	
    dbGoTop()
	While !SZF->(Eof())
	
		dbselectarea("CTT")
	  	dbSetOrder(1)
	  	dbseek(xfilial("CTT")+SZF->ZF_CUSTO)

	  	dbselectarea("SZF")
	  	dbSetOrder(2)                  
	  	       
	  	cUnid := SZF->ZF_UNID
	  	Do Case
	  		Case cUnid == 'HMC'
	  			cDesc := 'HORAS MES CALENDÁRIO' 		
	  		Case cUnid == 'HMQ'
	  			cDesc := 'HORAS MÁQUINA MES   ' 			
	  		Case cUnid == 'HH'
	  			cDesc := 'HOMENS HORAS MES    ' 			
	  		Case cUnid == 'HHM'
	  			cDesc := 'HOMENS HORAS MANUTENÇÃO' 		
	  		Otherwise
	  			cDesc := 'XXXXXX' 							
	  	EndCase
        
		cEmp := iif(Left(SZF->ZF_CUSTO,2)='09','01','02')
 

		U_ImpCab80(cNomeEmp,cTipEmp,Titulo,cxCabec1,cxCabec2,Tamanho,nReduz,nComp,cEmp)
	  	m_Pag := m_Pag + 1

	    cxTit := trim(cDesc)+'-[' + trim(cUnid) + ': ' + transform(SZF->ZF_VOLORC, "@E 9,999.99")+ ']'
		@Prow()+1,000 psay Left(SZF->ZF_CUSTO,5) +'-'+CTT->CTT_DESC01
		@Prow()  , 80-len(cxTit) psay cxTit
		@Prow()+1,000 psay replicate("-",80)

	  	cCusto := SZF->ZF_CUSTO
	
	  While ( !SZF->(Eof()) ) .and. ( SZF->ZF_CUSTO == cCusto ) 
		        
		cGrupocd := SZF->ZF_GRUPOCD
		
		If right(SZF->ZF_CODESP,3) == '999' .and. !SZF->ZF_CODESP == '070999'
			// não tem detalhes para totalização
		    SZF->(DbSkip())		
	        Loop
	    EndIf
	    
	     
		While ( !SZF->(Eof()) ) .and. ( SZF->ZF_CUSTO == cCusto ) .and. ( SZF->ZF_GRUPOCD == cGrupocd ) 
			                                            
			nPreco 	:= SZF->ZF_PRECO   
		    cPreco	:= str(nPreco,12,4)
		    cPreco	:= AllTrim(cPreco)

			If len(cPreco) > 8
				cPreco := transform(SZF->ZF_PRECO, "@E 9999,999")
			else
			  	cPreco := transform(SZF->ZF_PRECO, "@E 9,999.99")
			EndIf
			
			If right(SZF->ZF_CODESP,3) == '999'
			   @Prow()+1,007 psay Replicate("-",73)
			EndIf
						
			@Prow()+1,000 	   	psay iif(SZF->ZF_TITULO='2',SZF->ZF_CODESP,'      ')
 			@Prow()  ,Pcol() 	psay iif(SZF->ZF_TITULO='2','-'+Left(SZF->ZF_DESCCD,30),'*'+Left(SZF->ZF_DESCCD,30))
			@Prow()  ,Pcol()+1	psay iif(SZF->ZF_TITULO='2',Left(SZF->ZF_UNID,3),'   ')
			@Prow()  ,Pcol()+3 	psay iif(SZF->ZF_PRECO>0, cPreco,"        ")
			@Prow()  ,Pcol()+1 	psay iif(SZF->ZF_QTDORC>0,transform(SZF->ZF_QTDORC,"@E 9,999.99"),"        ")
			@Prow()  ,Pcol()+1 	psay SZF->ZF_CUSTOU picture "@E 9999.99"
			@Prow()  ,Pcol()+1	psay SZF->ZF_CUSTOM picture "@E 9,999,999"
		    
			If SZF->ZF_TITULO == '1'.and. nRelt == 1
			   @Prow()+1,007 psay Replicate("-",73)
			EndIf
			 
			IncProc()
		
			SZF->(DbSkip())

			If ( !SZF->(Eof()) ) .and. ( (Prow() >= 57) ) .and. ( SZF->ZF_CUSTO == cCusto )

				cEmp := iif(Left(SZF->ZF_CUSTO,2)='09','01','02')
				U_ImpCab80(cNomeEmp,cTipEmp,Titulo,cxCabec1,cxCabec2,Tamanho,nReduz,nComp,cEmp)
	  			m_Pag := m_Pag + 1

			    cxTit := trim(cDesc)+'-[' + trim(cUnid) + ': ' + transform(SZF->ZF_VOLORC, "@E 9,999.99")+ ']'
				@Prow()+1,000 psay Left(SZF->ZF_CUSTO,5) +'-'+CTT->CTT_DESC01
				@Prow()  , 80-len(cxTit) psay cxTit
				@Prow()+1,000 psay replicate("-",80)

			endif                      
		 
		 Enddo

		@Prow()+1,000 psay Replicate("-",80)
	 Enddo
	  
	  If !SZF->(Eof())	                  
	    //@60,00o repli("-",80)
	  EndIf
	  
	Enddo
	
	set filter to
	   
Return

