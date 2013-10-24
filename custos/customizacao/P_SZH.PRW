/*______________________________________________________________________
   ¦Autor     ¦ Eraldo Drumond                       ¦ Data ¦ 01/03/12 ¦
   +----------+--------------------------------------------------------¦
   ¦Descrição ¦ Cálculo do % Rateio Distribuido                        ¦
   +----------+--------------------------------------------------------¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function P_SZH() 

	private cAlias 	:= Alias()
	private cCusto 	:= ''                 
	private cNumPat	:= ''                 
	private cDatade	:= ''                 
	private cDataate:= ''                 
	private cQry 	:= ''                 
	private nSoma  	:= 0
	private nPerc  	:= 0
	private lAborta	:= .F.
	private nRet	:= 0
	private cPerg	:= ''	


	Processa({|| CalcRateio()},"","Aguarde. Processando ...",lAborta)
    
Return

                            
Static Function CalcRateio()

	cQry := "select ZH_EMP EMP,ZH_CODESP CODESP, sum(ZH_QTCONS) nTOTQTDE "
	cQry += "from "+RetSqlName("SZH")
	cQry += " WHERE D_E_L_E_T_ <> '*' "
	cQry += " GROUP BY ZH_EMP,ZH_CODESP "
	cQry += " ORDER BY ZH_EMP,ZH_CODESP "	
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	
	dbGoTop()
	
	ProcRegua(TEMP->(RecCount()))
	
	While !TEMP->(Eof())

		cEMP    := TEMP->EMP
		cCODESP := TEMP->CODESP   
		
		cQtde := alltrim(STR(TEMP->nTOTQTDE,10,2))
         
   		cUPD := ""
		cUPD := "update "+RetSqlName("SZH")
		cUPD += " set ZH_PERC = ZH_QTCONS/'"+cQtde+"' * 100 " 
 		cUPD += " where ZH_EMP='"+cEMP+"' and ZH_CODESP='"+cCODESP+"' AND D_E_L_E_T_ <> '*' "
        
		TCSqlExec(cUPD)	 
	     
        // -------------------------------------------------------------------------
		// inclui na Tabela "Rateio de Despesas", para digitar o P.unit e Qt.Orçada
        // -------------------------------------------------------------------------
		dbSelectArea("SZE")
		dbSetOrder(1)
		
		If !dbSeek(xfilial("SZE")+cEmp+cCodesp)
			RecLock("SZE",.T.)
	    	SZE->ZE_FILIAL	:= xFilial("SZE")
	    	SZE->ZE_EMP    	:= cEmp
	   		SZE->ZE_CODESP	:= cCodesp
   			SZE->ZE_PRECO 	:= 0.00
	   		SZE->ZE_QTDEORC	:= 0.00
			SZE->ZE_VRREAL	:= 0.00
			SZE->ZE_IDT		:= iif(Left(cCodesp,2)<'09','1','2')  	// 1-DESPESA; 2=Recirculação
			SZE->ZE_CUSTO	:= ''
			SZE->ZE_GRUPOCC := ''		          
			MsUnlock()
	    EndIf
         
		dbSelectArea('TEMP')

		IncProc()
		                        
		TEMP->(DbSkip())
			
	EndDo    

	dbCloseArea('TEMP')    
	

    // -----------------------------------      
	// verifica arredondamento para 100.00
	// -----------------------------------
	
	DbSelectArea('SZH')
	dbSetOrder(1)

	dbGoTop()
	
	ProcRegua(SZH->(RecCount()))	
	
    While !SZH->(Eof())

		cEMP    := SZH->ZH_EMP
		cCODESP := SZH->ZH_CODESP
		nPERC   := 0	   

		While !SZH->(Eof()) .and. (SZH->ZH_EMP == cEMP) .and. (SZH->ZH_CODESP == cCODESP) 
		
			nPERC := nPERC + SZH->ZH_PERC
		    
			SZH->(DbSkip())
		EndDo
		      
		If (nPERC <> 100.00)
		  
		  nPERC := 100.00 - nPERC
		  
		  cPERC := alltrim(STR(nPERC,6,2))
         
		  cUPD := "update "+RetSqlName("SZH")
		  cUPD += " set ZH_PERC = ZH_PERC + '"+cPERC+"' " 
 		  cUPD += " where ZH_EMP='"+cEMP+"' and ZH_CODESP='"+cCODESP+"' AND D_E_L_E_T_ <> '*' AND "
 		  cUPD += " ZH_PERC = (select MAX(ZH_PERC) from "+RetSqlName("SZH")
 		  cUPD += " where ZH_EMP='"+cEMP+"' and ZH_CODESP='"+cCODESP+"' AND D_E_L_E_T_ <> '*' ) "
        
		  nRet := TCSqlExec(cUPD)
		  
		  if nRet > 0
			MsgBox("Erro de atualização de Rateio!","Alerta","ALERT")
		  endif		  	 
		
		EndIf

		dbSelectArea('SZH')

		IncProc()
			
	EndDo

	msgbox('%Rateio calculado.')

return 

