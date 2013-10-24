/*______________________________________________________________________
   ¦Autor     ¦ Eraldo Drumond                       ¦ Data ¦ 03/02/12 ¦
   +----------+--------------------------------------------------------¦
   ¦Descrição ¦ Cálculo % Rateio: Energia e Agua - Equipamentos        ¦
   ¦            Atualiza Orçamento para Provisionamento                ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function P_SZJ() 

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
	private cPerg	:= 'SZG001'	
  
	
	nOpc:= Aviso("Equipamentos","Escolha a rotina desejada: cálculo de Rateios, ou atualização de Provisão",{"Rateios", "Provisão","Sair"})
	
	If (nOpc == 0) .or. (nOpc == 3)
	   Return
	EndIf  

	If (nOpc == 1)

   	Processa({|| CalcEnergia()},"","Aguarde. Processando Rateio de Energia ...",lAborta)
   

	/*______________________________________________________________________
   		Pergunta:SZG001
   			mv_par01 - Data de:
   			mv_par02 - Data ate:
	  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
	
	MsgInfo("Rateio Água: informe a seguir Período de apuração de consumo Óleo Lubrif.")
	
	If !Pergunte(cPerg)
	   Return
	EndIf
    
    If empty(mv_par01) .or. empty(mv_par02)      
        return
    endif

	cDatade	 := dTos(mv_par01)
	cDataate := dTos(mv_par02)

	Processa({|| CalcAgua()},"","Aguarde. Processando Rateio de Água ...",lAborta)
	

 	Processa({|| Atualiza()},"","Atualiza tabela 'Rateio (%) Distribuido ...",lAborta)
   
	Else

 	Processa({|| Provisao()},"","Atualiza Orçamento de Provisão ...",lAborta)

    EndIf
    
Return

                            
Static Function CalcEnergia()

	cQry := "select sum(ZJ_POTENCI) nTOTKW "
	cQry += "from "+RetSqlName("SZJ")
	

	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	
	nRet := TEMP->nTOTKW 
	
	DbCloseArea("TEMP")
	
	DbSelectArea('SZJ')
	dbSetOrder(1)
	dbGoTop()
	
	ProcRegua(SZJ->(RecCount()))
	
	While !SZJ->(Eof())
	   
	    Reclock("SZJ",.F.)
		SZJ->ZJ_RATENER := (SZJ->ZJ_POTENCI / nRet) * 100
		MsUnlock()
              
		nSoma := nSoma + SZJ->ZJ_RATENER
		
		IncProc()
		                        
		SZJ->(DbSkip())
		
	
	EndDo

	msgbox('%Rateio calculado energia: '+str(nSoma,6,2)+'%')
	

return 


Static Function CalcAgua()
/* 
	busca consumo de Oleo soluvel para base de calculo de rateio de agua
*/                            
                                          
	cQry := "SELECT D3_CC CCUSTO,SUM(D3_QUANT) nQTDE,SUM(D3_CUSTO1) nVALOR "
	cQry += "from "+RetSqlName("SD3")
	cQry += " WHERE D3_TM='501' AND D3_ESTORNO<>'S' AND LEFT(D3_COD,6)='WLU026' AND "
	cQry += " D3_EMISSAO BETWEEN '"+cDatade+"' AND '"+cDataate+"' AND D_E_L_E_T_ <> '*' " "
	cQry += " GROUP BY D3_CC "
	cQry += " ORDER BY D3_CC "	
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	dbGoTop()
	
	ProcRegua(TEMP->(RecCount()))

	if TEMP->nQTDE == 0
	   	msgbox('Nenhum registro selecionado para o período informado.')
		DbCloseArea("TEMP")
	   	Return
	EndIf

	n_quant := 0
	n_valor := 0
	
	While !TEMP->(Eof())
	
		n_quant := n_quant + TEMP->nQTDE	
		n_valor := n_valor + TEMP->nVALOR
	   
		dbselectarea("SZJ")
		dbSetOrder(1)

		If dbSeek(xfilial("SZJ")+TEMP->CCUSTO)
			RecLock("SZJ",.F.)
			SZJ->ZJ_OLEOSOL := TEMP->nQTDE		
			MsUnlock()
		EndIf

		DbSelectArea("TEMP")
	
		TEMP->(DbSkip())
		
	EndDo
	
	DbCloseArea("TEMP")
	
	// atualiza % de rateio -----------------

	cQry := "select sum(ZJ_OLEOSOL) nTOTOL "
	cQry += "from "+RetSqlName("SZJ")

	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	
	nRet := TEMP->nTOTOL 

	DbCloseArea("TEMP")
	
	DbSelectArea('SZJ')
	dbSetOrder(1)

	SET FILTER TO ZJ_OLEOSOL > 0
	
	ProcRegua(SZJ->(RecCount()))
	
    nSoma := 0 
    nPerc := 0
    
	dbGoTop()
	While !SZJ->(Eof())
	   
	    Reclock("SZJ",.F.)
		SZJ->ZJ_RATAGUA := (SZJ->ZJ_OLEOSOL / nRet) * 100
		MsUnlock()
              
		nSoma 	:= nSoma + SZJ->ZJ_RATAGUA
		
		if nPerc < SZJ->ZJ_RATAGUA 
			nPerc 	:= SZJ->ZJ_RATAGUA
			cCusto	:= SZJ->ZJ_CUSTO
			cNumPat	:= SZJ->ZJ_NUMPAT 
		EndIf		
		
		IncProc()
		                        
		SZJ->(DbSkip())
	
	EndDo
    
   	msgbox('%Rateio calculado Água: '+str(nSoma,6,2)+'%')

	// CHECAR > 100,00= diferença, subtrair do maior Percentual
	if nSoma > 100.00
		
		nSoma := nSoma - 100.00
		
		dbSeek(xFilial("SZJ")+cCusto+cNumPat)
		
	    Reclock("SZJ",.F.)
		SZJ->ZJ_RATAGUA := SZJ->ZJ_RATAGUA - nSoma
		MsUnlock()
		
		nSoma := 0
		
		dbGoTop()
		While !SZJ->(Eof())
	   
			nSoma := nSoma + SZJ->ZJ_RATAGUA
		                        
			SZJ->(DbSkip())
	
		EndDo

 		msgbox('%Rateio corrigido: '+str(nSoma,6,2)+'%')
 	   
    EndIf
	SET FILTER TO
	

return 


Static Function Atualiza()
	// ---------------------------------------------------------- 
	// agrupa os Percentuais de rateio por CC, de energia/agua no
	// cad. de equipamentos
	// para energia: demanda 061004  
	//				 consumo 061003
	//				 água    061001
	// ---------------------------------------------------------- 
   	// atualiza "Rateio (%) Distribuido" 
   	
   	
	cQry := "select ZJ_CUSTO CUSTO, 'E' TIPO, sum(ZJ_POTENCI) QTCONS, sum(ZJ_RATENER) PERC_R "
	cQry += "from "+RetSqlName("SZJ")
	cQry += " where ZJ_RATENER <> 0 and D_E_L_E_T_ <> '*' "
	cQry += " Group by ZJ_CUSTO "
	cQry += "UNION "
	cQry += "select ZJ_CUSTO CUSTO, 'A' TIPO, sum(ZJ_OLEOSOL) QTCONS, sum(ZJ_RATAGUA) PERC_R "
	cQry += "from "+RetSqlName("SZJ")
	cQry += " where ZJ_RATAGUA <> 0 and D_E_L_E_T_ <> '*' "
	cQry += " Group by ZJ_CUSTO "

	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	
	ProcRegua(TEMP->(RecCount()))
    
	dbGoTop()
	While !TEMP->(Eof())
          
		cEmp	:= iif(Left(TEMP->CUSTO,2)='09','1','2')
		cCusto 	:= TEMP->CUSTO                            

		dbSelectArea("SZH")
		dbSetOrder(1)				// empresa + codesp + cc
		
	   	If TEMP->TIPO = 'E'			
          
		  cCodesp := '061004'
			
		  If !dbSeek(xfilial("SZH")+cEmp+cCodesp+cCusto)
			RecLock("SZH",.T.)
	    	SZH->ZH_FILIAL	:= xFilial("SZH")
	    	SZH->ZH_EMP    	:= cEmp
	   		SZH->ZH_CODESP	:= cCodesp
   			SZH->ZH_CUSTO 	:= cCusto
	   		SZH->ZH_CODESP	:= cCodesp
			SZH->ZH_QTCONS	:= TEMP->QTCONS
			SZH->ZH_PERC 	:= TEMP->PERC_R		          
			MsUnlock()
		  Else             
	    	Reclock("SZH",.F.)
			SZH->ZH_QTCONS	:= TEMP->QTCONS
			SZH->ZH_PERC 	:= TEMP->PERC_R		          
			MsUnlock()
		  EndIf

		  cCodesp := '061003'
			
		  If !dbSeek(xfilial("SZH")+cEmp+cCodesp+cCusto)
			RecLock("SZH",.T.)
	    	SZH->ZH_FILIAL	:= xFilial("SZH")
	    	SZH->ZH_EMP    	:= cEmp
	   		SZH->ZH_CODESP	:= cCodesp
   			SZH->ZH_CUSTO 	:= cCusto
	   		SZH->ZH_CODESP	:= cCodesp
			SZH->ZH_QTCONS	:= TEMP->QTCONS
			SZH->ZH_PERC 	:= TEMP->PERC_R		          
			MsUnlock()
		  Else             
	    	Reclock("SZH",.F.)
			SZH->ZH_QTCONS	:= TEMP->QTCONS
			SZH->ZH_PERC 	:= TEMP->PERC_R		          
			MsUnlock()
		  EndIf

		Else

		  cCodesp := '061001'
			
		  If !dbSeek(xfilial("SZH")+cEmp+cCodesp+cCusto)
			RecLock("SZH",.T.)
	    	SZH->ZH_FILIAL	:= xFilial("SZH")
	    	SZH->ZH_EMP    	:= cEmp
	   		SZH->ZH_CODESP	:= cCodesp
   			SZH->ZH_CUSTO 	:= cCusto
	   		SZH->ZH_CODESP	:= cCodesp
			SZH->ZH_QTCONS	:= TEMP->QTCONS
			SZH->ZH_PERC 	:= TEMP->PERC_R		          
			MsUnlock()
		  Else             
	    	Reclock("SZH",.F.)
			SZH->ZH_QTCONS	:= TEMP->QTCONS
			SZH->ZH_PERC 	:= TEMP->PERC_R		          
			MsUnlock()
		  EndIf
		                           
		EndIf

		IncProc()

		DbSelectArea("TEMP")
		
		TEMP->(DbSkip())
	
	EndDo

	DbCloseArea("TEMP")
	
	msgBox('Tabela "Rateio (%) Distribuido" atualizada.')	        

return 




Static Function Provisao()

	DbSelectArea('SZB')
	dbSetOrder(1)
                     
	dbSeek(xfilial("SZB")+'080005')

	DbSelectArea('SZJ')
	dbSetOrder(1)

	dbGoTop()
	
	ProcRegua(SZJ->(RecCount()))	
	
    While !SZJ->(Eof())

		cCUSTO  := SZJ->ZJ_CUSTO
		cDC		:= '002'
		cCODESP := '080005'
		
		If SZJ->ZJ_VRADEPR > 0

			DbSelectArea('SZK')
			dbSetOrder(1)
			
			If !dbSeek(xfilial("SZK")+cCusto+cDC+cCODESP)
				RecLock("SZK",.T.)
	    		SZK->ZK_FILIAL	:= xFilial('SZK')
	   			SZK->ZK_CUSTO 	:= cCusto
		    	SZK->ZK_DC    	:= cDC
	   			SZK->ZK_CODESP	:= cCODESP
	   			SZK->ZK_PRECO	:= SZJ->ZJ_VRADEPR
	   			SZK->ZK_QTDORC	:= 1  
	   			SZK->ZK_DESCCD	:= SZB->ZB_DESC
				MsUnlock()
			EndIf             

	    EndIf
	    
		DbSelectArea('SZJ')

		SZJ->(DbSkip())
        
		incproc()
    EndDo


Return



