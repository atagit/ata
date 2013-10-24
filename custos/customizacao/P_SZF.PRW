/*______________________________________________________________________
   ¦Autor     ¦ Eraldo Drumond                      ¦ Data ¦ 27/01/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Gera Livro de Orçamento - SZF                         ¦
   ¦            Origem: Despesas Orçadas x CC - SZK                   ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

#include "rwmake.ch"
#include "Protheus.ch"
#include "topconn.ch"

User Function P_SZF()
   
	private nTotal 	:= 0.00
    private nCustou := 0.00
    private nVolHMC := 0.00
    private nSalh	:= 0.00
    private nPerc	:= 0.00
	private	nPreco  := 0.00                     
	private	nQtorc  := 0.00
    private	nRateio := 0.00   
    private cCusto 	:= ""
    private CC_fora := ""
    private cDC		:= ""
    private cCodesp	:= ""
    private cUnid	:= ""
    private cUndesp := ""
    private cTit	:= "" 
    private cRateio := ""
    private cGrupoCD:= ""
    private cGrupoCC:= ""
	private cEmp	:= ""
	private cQry	:= ''
    private lAborta := .F.
    private lTaxa	:= .F.
	

	Processa({|| IncLivro()},"","Aguarde. Processando ...",lAborta)

 	Processa({|| Sumariza()},"","Aguarde. Sumarizando ...",lAborta)
   
           
return


static function IncLivro()

	dbselectarea("SZK")             			// C.C x COD.DESPESAS PARA LIVRO ORÇ.
	dbSetOrder(1)
   
   //	set filter to (ZK_PRECO > 0) .and. (ZK_QTDORC > 0)
	
	dbGoTop()
	
	ProcRegua(SZK->(RecCount()))
	
	While !SZK->(Eof())
                
     	If SZK->ZK_CUSTO == CC_fora
		   SZK->(DbSkip())
		   Loop
     	EndIf    

	  	cCusto 	:= SZK->ZK_CUSTO
 	  	cDC	 	:= SZK->ZK_DC
		cGrupoCC:= Left(SZK->ZK_CUSTO,2)
 	  	lTaxa	:= .F.
 	 
 	  	dbselectarea("SZA")              		// volume orçado
		dbSetOrder(1)
		dbSeek(xfilial("SZA")+cCusto+cDC)
		cUnid := SZA->ZA_UNID
		
		If SZA->ZA_VOLORCA == 0
		   msgbox('Atenção! Falta Volume na Tab. D.C. do Centro de Custo: '+trim(cCusto)+'-'+cDC)
		   SZK->(DbSkip())
		   Loop
		EndIf
		
		
		If nVolHMC == 0
		   nVolHMC := SZA->ZA_VOLORCA      		// Horas HMC utilizado para Qt.Orç nos sub_cc
		EndIf
        
		dbselectarea("SZK")
		dbSetOrder(1)
		
		
		while ( !SZK->(Eof()) ) .and. ( SZK->ZK_CUSTO == cCusto ) .and. ( SZK->ZK_DC == cDC )
	 	  	
	 	  	cCodesp	:= SZK->ZK_CODESP      

	 	  	dbselectarea("SZB")              		// cód. despesas
			dbSetOrder(1)
			dbSeek(xfilial("SZB")+cCodesp)
		   
			cTit 	:= SZB->ZB_TITULO
            cGrupoCD:= SZB->ZB_GRUPO 
			cUndesp	:= SZB->ZB_UNID   
			cRateio	:= SZB->ZB_RATEIO
		
 		  	dbselectarea("SZF")              		// Livro orçamento
			dbSetOrder(1)
			
				
			If cTit == '1'  						// Cód. refere-se a título e acumla valor

				If !dbSeek(xfilial("SZF")+cCusto+cDC+cCodesp)
				
					RecLock("SZF",.T.)
				    SZF->ZF_FILIAL	:= xFilial("SZF")
			    	SZF->ZF_CUSTO 	:= cCusto
				    SZF->ZF_DC    	:= cDC
			    	SZF->ZF_CODESP	:= cCodesp
					SZF->ZF_UNID  	:= iif(right(cCodesp,3)='000',SZB->ZB_UNID,cUnid)                    // unid. volume
					SZF->ZF_DESCCD	:= SZB->ZB_DESC
					SZF->ZF_VOLORC	:= SZA->ZA_VOLORCA
					SZF->ZF_PRECO 	:= 0.00		
					SZF->ZF_QTDORC	:= 0.00
					SZF->ZF_CUSTOU	:= 0.00
					SZF->ZF_CUSTOM	:= 0.00
					SZF->ZF_DATA  	:= Date()
					SZF->ZF_GRUPOCC := Left(cCusto,2)
					SZF->ZF_GRUPOCD := Left(cCodesp,2)
					SZF->ZF_TITULO  := '1'
					MsUnlock()
				Else
					Reclock("SZF",.F.)
					SZF->ZF_VOLORC	:= SZA->ZA_VOLORCA
					SZF->ZF_PRECO 	:= 0.00		
					SZF->ZF_QTDORC	:= 0.00
					SZF->ZF_CUSTOU	:= 0.00
					SZF->ZF_CUSTOM	:= 0.00
					SZF->ZF_DATA  	:= Date()
					MsUnlock()
				EndIf

				dbSelectArea("SZK")
				SZK->(DbSkip())
		    	Loop
			EndIf

			Do case
				Case cGrupoCD == '01'					
					rotMOD()						// Mão de Obra Direta
				Case cGrupoCD == '02'
				    rotENC()						// Emcargos
			   	Case cGrupoCD == '03'
					rotBEN()						// Beneficios 
				Case cGrupoCD == '04'
					//rotPRO()						// Mat. de Produção 
				Case cGrupoCD == '05'
					rotMAT()						// Desp. Administrativas, Financ.,donativos 
				Case cGrupoCD == '06'
					rotSER()						// Serviços proprios,terceiros 
				Case cGrupoCD == '07'
					//rotOUT()						// impostos e taxas
				Case cGrupoCD == '08'
					rotCOMUM()						// Provisão
				Case cGrupoCD == '09'
					//rotREC()						// Recirculação 
				Case cGrupoCD == '10'
					//rotPRI						// Matéria Prima 
			EndCase
		
			IncProc()
		                        
			dbSelectArea('SZK')
			SZK->(DbSkip())
	    
	  	Enddo
	  	
	Enddo

    //set filter to
	   
Return          


Static Function rotMOD()
// -----------------------------------------------------------
// SUMARIZA: media(salh) e qtde vagas previstas no Organograma
//   CODESP: 010001 - SALARIOS    
// -----------------------------------------------------------

	cQry := "select ZD_CUSTO, AVG(ZD_SALMED) n_SALMED, SUM(ZD_TOTAL) n_TOTAL "
	cQry += "from "+RetSqlName("SZD")
    cQry += " where ZD_CUSTO ='"+cCusto+"' and D_E_L_E_T_ <> '*' "
    cQry += " Group by ZD_CUSTO"

	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")

	If TEMP->( Eof() )
	    DbCloseArea("TEMP")
	    CC_fora := cCusto
		MsgBox('Organograma sem registro para o C.Custo:'+cCusto)
		cCusto  := "9999"
		Return
	EndIf	
	
	dbselectarea("SZF")
	dbSetOrder(1)
	If !dbSeek(xfilial("SZF")+cCusto+cDC+cCodesp)
		RecLock("SZF",.T.)
	    SZF->ZF_FILIAL	:= xFilial("SZF")
   		SZF->ZF_CUSTO 	:= cCusto
	    SZF->ZF_DC    	:= cDC
	   	SZF->ZF_CODESP	:= cCodesp
		SZF->ZF_UNID  	:= cUndesp
		SZF->ZF_DESCCD	:= SZB->ZB_DESC
		SZF->ZF_VOLORC	:= SZA->ZA_VOLORCA
		SZF->ZF_PRECO 	:= TEMP->n_SALMED		                // média de salário do CC
		//----------------------------------
		SZF->ZF_QTDORC	:= iif(cUnid=='HMC',TEMP->n_TOTAL,(nVolHMC/SZA->ZA_VOLORCA)*TEMP->n_TOTAL)  // total de vagas previstas
		//----------------------------------
		SZF->ZF_CUSTOU	:= SZF->ZF_PRECO * ZF_QTDORC                                  // COM EXCEÇÃO para HMQ
		SZF->ZF_CUSTOM	:= SZF->ZF_CUSTOU * SZA->ZA_VOLORCA
		SZF->ZF_DATA  	:= Date()
		SZF->ZF_GRUPOCC := Left(cCusto,2)
		SZF->ZF_GRUPOCD := Left(cCodesp,2)
		SZF->ZF_TITULO  := '2'
		MsUnlock()
	Else             
	    Reclock("SZF",.F.)
		SZF->ZF_VOLORC	:= SZA->ZA_VOLORCA
		SZF->ZF_PRECO 	:= TEMP->n_SALMED		                // média de salário do CC
		//----------------------------------
		SZF->ZF_QTDORC	:= iif(cUnid=='HMC',TEMP->n_TOTAL,(nVolHMC/SZA->ZA_VOLORCA)*TEMP->n_TOTAL) // total de vagas previstas
		//----------------------------------
		SZF->ZF_CUSTOU	:= SZF->ZF_PRECO * ZF_QTDORC
		SZF->ZF_CUSTOM	:= SZF->ZF_CUSTOU * SZA->ZA_VOLORCA
		SZF->ZF_DATA  	:= Date()
		MsUnlock()
	EndIf
    
	If dbSeek(xfilial("SZF")+cCusto+cDC+'010000')
    	Reclock("SZF",.F.)
		SZF->ZF_VOLORC	:= SZA->ZA_VOLORCA
		SZF->ZF_PRECO 	:= TEMP->n_SALMED		                // média de salário do CC
		//----------------------------------
		SZF->ZF_QTDORC	:= iif(cUnid=='HMC',TEMP->n_TOTAL,(nVolHMC/SZA->ZA_VOLORCA)*TEMP->n_TOTAL) // total de vagas previstas
		//----------------------------------
		SZF->ZF_CUSTOU	:= SZF->ZF_PRECO * ZF_QTDORC
		SZF->ZF_CUSTOM	:= SZF->ZF_CUSTOU * SZA->ZA_VOLORCA
		SZF->ZF_DATA  	:= Date()
		MsUnlock()
		
		nCustou := SZF->ZF_CUSTOU            	// utilizado em rotENC() = qtOrc
		nTOTAL	:= TEMP->n_TOTAL                // utilizado em rotMAT() = qtOrc (efetivo prev)
	EndIf
    
    DbSelectArea("TEMP")
	DbCloseArea("TEMP")
	
Return


Static Function rotENC()
    
	cQry := "select ZC_PERC n_PERC "
	cQry += "from "+RetSqlName("SZC")
    cQry += " where ZC_CODESP ='"+cCODESP+"' and D_E_L_E_T_ <> '*' "

	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")

	nPreco := (TEMP->n_PERC)/100
	nQtorc := nCustoU     		
	
	DbCloseArea("TEMP")

	incluiSZF()

Return


Static Function rotBEN()

	nPreco := 0.00                     
	nQtorc := 0.00

	dbselectarea("SZB") 									// COD. DESPESAS
	dbSetOrder(1)                                           // busca preço unitário comum
	dbSeek(xfilial("SZB")+cCodesp)	                        // a todos os C.C
	
	Do Case
		Case cCodesp == '030001'							// Vale Tranporte
			nPreco := SZB->ZB_PRECO
            nQtorc := (nTotal * 2 * 22) / SZA->ZA_VOLORCA

		Case cCodesp == '030002'							// Vale Refeição
			nPreco := SZB->ZB_PRECO
            nQtorc := (nTotal * 1 * 22) / SZA->ZA_VOLORCA

		Otherwise 											// Outros
			nPreco := SZB->ZB_PRECO
			If SZK->ZK_QTDORC > 0
				nQtorc := SZK->ZK_QTDORC / SZA->ZA_VOLORCA
			Else
            	nQtorc := nTotal / SZA->ZA_VOLORCA
   			EndIf
	
	EndCase	
	
	incluiSZF()

Return


Static Function rotSER()

	nPreco 	:= 0.00                     
	nQtorc 	:= 0.00
    nRateio	:= 0.00
    cEmp	:= Iif(cGrupoCC=='09','1','2')   
     
	If cRateio ==  '2'                           			// SIM
	
		//-------------------------------------------------------------------------------
		cQry := "select SUM(ZH_PERC) n_RATEIO "    			// CADASTRO DE RATEIOS
		cQry += "from "+RetSqlName("SZH")
    	cQry += " where ZH_EMP ='"+cEmp+"' and ZH_CODESP ='"+cCODESP+"' and ZH_CUSTO ='"+cCUSTO+"' and D_E_L_E_T_ <> '*' "

		tcquery cQry new alias "TEMP"
		DbSelectArea("TEMP")

		nRateio := (TEMP->n_RATEIO)
	
		DbCloseArea("TEMP")

		dbselectarea("SZE") 									// Rateio de Despesas
		dbSetOrder(1)                                           // busca Preço e Qtde orçada
		dbSeek(xfilial("SZE")+cEmp+cCodesp)	
	
		nPreco := SZE->ZE_PRECO   		  						
        nQtorc := (nRATEIO * SZE->ZE_QTDEORC)/100		    	
	    nQtorc := nQtorc/SZA->ZA_VOLORCA                   		

	Else 
	
		nPreco := SZK->ZK_PRECO
        nQtorc := SZK->ZK_QTDORC/SZA->ZA_VOLORCA				// segue o padão   
        
	EndIf
	
	incluiSZF()

Return

            

Static Function rotMAT()

	nPreco := 0.00                     
	nQtorc := 0.00
	
	nPRECO := SZK->ZK_PRECO

	If SZK->ZK_QTDORC > 0
		nQtorc := SZK->ZK_QTDORC / SZA->ZA_VOLORCA    		// zk_qtdorc = qtd parcial do efet
	Else
       	nQtorc := nTotal / SZA->ZA_VOLORCA					// nTotal = qtde efet.previsto
	EndIf

	incluiSZF()
	
Return


Static Function rotCOMUM()

	nPreco := 0.00                     
	nQtorc := 0.00
	
	nPRECO := SZK->ZK_PRECO

	nQtorc := SZK->ZK_QTDORC / SZA->ZA_VOLORCA    		

	incluiSZF()
	
Return



Static Function incluiSZF()

	dbselectarea("SZF")
	dbSetOrder(1)

	If !dbSeek(xfilial("SZF")+cCusto+cDC+cCodesp)
		RecLock("SZF",.T.)
	    SZF->ZF_FILIAL	:= xFilial("SZF")
   		SZF->ZF_CUSTO 	:= cCusto
	    SZF->ZF_DC    	:= cDC
	   	SZF->ZF_CODESP	:= cCodesp
		SZF->ZF_UNID  	:= cUndesp
		SZF->ZF_DESCCD	:= SZB->ZB_DESC
		SZF->ZF_VOLORC	:= SZA->ZA_VOLORCA
		SZF->ZF_PRECO 	:= nPreco		
		SZF->ZF_QTDORC	:= nQtorc
		SZF->ZF_CUSTOU	:= SZF->ZF_PRECO  * SZF->ZF_QTDORC
		SZF->ZF_CUSTOM	:= SZF->ZF_CUSTOU * SZA->ZA_VOLORCA
		SZF->ZF_DATA  	:= Date()
		SZF->ZF_GRUPOCC := Left(cCusto,2)
		SZF->ZF_GRUPOCD := Left(cCodesp,2)
		SZF->ZF_TITULO  := '2'
		MsUnlock()
	Else             
	    Reclock("SZF",.F.)
		SZF->ZF_VOLORC	:= SZA->ZA_VOLORCA
		SZF->ZF_PRECO 	:= nPreco		
		SZF->ZF_QTDORC	:= nQtorc
		SZF->ZF_CUSTOU	:= SZF->ZF_PRECO  * SZF->ZF_QTDORC 
		SZF->ZF_CUSTOM	:= SZF->ZF_CUSTOU * SZA->ZA_VOLORCA
		SZF->ZF_DATA  	:= Date()
		MsUnlock()
	EndIf

Return


Static Function Sumariza()
	/* Para 030 - Beneficios :verificar com Arizio: 
	   não sumarizar _Preço,_QtdOrçada pois os Itens têm cálculo fora do padrão
	   Para grupo_codesp='01,02' sumariza
	                    >'02' não sumazriza                        
	*/

	cQry := "select ZF_CUSTO Custo,ZF_DC DC, ZF_GRUPOCD Grupo, MIN(ZF_QTDORC) n_MINQT, sum(ZF_PRECO) n_PRECO, sum(ZF_QTDORC) n_QTDORC,sum(ZF_CUSTOU) n_CUSTOU, sum(ZF_CUSTOM) n_CUSTOM "
	cQry += " from "+RetSqlName("SZF")
    cQry += " where ZF_TITULO='2' and ZF_PRECO > 0 and D_E_L_E_T_ <> '*' "
    cQry += " Group by ZF_CUSTO,ZF_DC,ZF_GRUPOCD "

	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	DbGoTop()
	
	While TEMP->( !Eof() )
	
		dbselectarea("SZF")
		dbSetOrder(1)

		If dbSeek(xfilial("SZF")+TEMP->Custo+TEMP->DC+TEMP->Grupo+'0000')
    		Reclock("SZF",.F.)
            if TEMP->GRUPO $'01,02'
			   SZF->ZF_PRECO 	:= TEMP->n_PRECO		
			   SZF->ZF_QTDORC	:= iif(TEMP->GRUPO='02',TEMP->n_MINQT,TEMP->n_QTDORC)
			Else
			   SZF->ZF_PRECO 	:= 0.00		
			   SZF->ZF_QTDORC	:= 0.00
			EndIf
			SZF->ZF_CUSTOU	:= TEMP->n_CUSTOU 
			SZF->ZF_CUSTOM	:= TEMP->n_CUSTOM
			SZF->ZF_DATA  	:= Date()
			MsUnlock()
		EndIf
	
		dbSelectArea('TEMP')
		TEMP->(DbSkip())
	
	EndDo
			
	DbSelectArea("TEMP")
	DbCloseArea("TEMP")

	/*   -->>>> 070.000 = impostos e taxas
	 -----------------------------------------------------------
	   SUMZARIZA REGISTROS DE TITULOS:
	   ate '06' -> 069.999 - CUSTOS GERENCIA
	     + '08' -> 080.999 - CUSTOS GERENCIA + PROVISÃO
	     + '09' -> 090.999 - CUSTOS GERENCIA + PROVISÃO + RECIRCULAÇÃO
     -----------------------------------------------------------
    */

	dbselectarea("SZF")
	dbSetOrder(1)

	Set Filter to SZF->ZF_TITULO='1' .and. SZF->ZF_GRUPOCD<'10'
    
	nCustoU := 0
	nCustoM := 0
	
    dbGoTop()
    
    While SZF->( !Eof() )

    	nCustoU := nCustoU + SZF->ZF_CUSTOU
    	nCustoM := nCustoM + SZF->ZF_CUSTOM

		SZF->(DbSkip())
		
		If SZF->ZF_CODESP $'069999#080999#090999'
		
    		Reclock("SZF",.F.)
			SZF->ZF_CUSTOU	:= nCUSTOU 
			SZF->ZF_CUSTOM	:= nCUSTOM
			SZF->ZF_DATA  	:= Date()
			MsUnlock()
		
			SZF->(DbSkip())
        
		EndIf

    EndDo

    Set Filter to

	DbCloseArea("SZF")

	/*
	 -----------------------------------------------------------
	 linha: iif(TEMP->GRUPO='02',TEMP->n_MINQT,TEMP->n_QTDORC)
	 		----------------------------------------------------
	 	 	grupo = '02' - Encargos
	 	 	: a Qtde Orçada para encargos é igual ao _PREÇO do
	 	 	  Cod. Despesa 010.000 Mão de Obra. Então não pode
	 	 	  ser sumarizado, pois é um valor fixo para todos
	 	 	  os grupos de encargos 
     -----------------------------------------------------------
    */
Return                     


