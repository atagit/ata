/*______________________________________________________________________
   ¦Autor     ¦ Eraldo Drumond                      ¦ Data ¦ 27/01/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Atualiza Despesas realizadas no Quadro de Custos-SZI  ¦
   ¦            Origem: Despesas realizadas x CC - SZG                ¦
   				Verificar: despesas NÃO orçadas-ANOMES,CC,CD
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

#include "rwmake.ch"
#include "Protheus.ch"
#include "topconn.ch"

User Function P_SZG()
   
	private nTotal 	:= 0
	private	nPreco  := 0
	private nVacum	:= 0 
	private nQtReal := 0                    
  	private cAnomes	:= ""
  	private cAMant  := ""
	private nAno	:= 0
	private nMes	:= 0
    private cCusto 	:= ""
    private cCodesp	:= ""
    private cRateio	:= ""
    private lAborta := .F.
	private cQry	:= ''
	private cUPD	:= ''
    private cPerg	:= 'SZI001'	
    
	
/*  ______________________________________________________________________
   Pergunta:SZI001
   			mv_par01 - Ano/mes:
   			mv_par02 - C.C de
   			mv_par03 - C.C ate
*/  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
	
	If !Pergunte(cPerg)
	   Return
	EndIf
    
    If Empty(mv_par01) .or. Empty(mv_par02) .or. Empty(mv_par03)     
        return
    endif

    cAnomes := mv_par01 
	cCCde	:= mv_par02
	cCCate	:= mv_par03

	nAno	:= val(left(cAnomes,4))
	nMes	:= val(right(cAnomes,2))
		
	If nMes == 1
		nMes := 12
		nAno := nAno - 1
	Else
		nMes := nMes -1
    EndIf

	cAMant :=  Str(nAno) + Strzero(nMes,2)
	
	Processa({|| AtuQuadro()},"","Aguarde. Processando ...",lAborta)

	if lAborta
		Return
	EndIf    

	Processa({|| Sumariza()},"","Aguarde. Sumarizando ...",lAborta)
   
           
return



Static function AtuQuadro()


	dbselectarea("SZG")             			// DESPESAS REALIZADAS X CC
	dbSetOrder(1)

	If !dbSeek(xfilial("SZG")+cAnomes+cCCde)
		lAborta := .T.
		MsgInfo("'Ano/mes + C.C_de' sem registro de Despesa realizada.")
		Return
	EndIf	
	
	ProcRegua(SZG->(RecCount()))
	
	While !SZG->(Eof()) .and. ( SZG->ZG_AM == cAnoMes ) .and. ( SZG->ZG_CUSTO <= cCCate )

		
		If SZG->ZG_VALOR == 0
		   SZG->(DbSkip())
		   Loop
		EndIf

	  	cCusto 	:= SZG->ZG_CUSTO
		cCodesp	:= SZG->ZG_CODESP
		nQtReal := SZG->ZG_VALOR

		dbselectarea("SZB")
		dbSetOrder(1)                                         
		dbSeek(xfilial("SZB")+cCodesp)
		
		cRateio := SZB->ZB_RATEIO
      	
      	If cRateio == '2'
		
			cQry := "select SUM(ZH_PERC) n_RATEIO "    			
			cQry += "from "+RetSqlName("SZH")
    		cQry += " where ZH_EMP ='"+cEmp+"' and ZH_CODESP ='"+cCODESP+"' and ZH_CUSTO ='"+cCUSTO+"' and D_E_L_E_T_ <> '*' "

			tcquery cQry new alias "TEMP"
			DbSelectArea("TEMP")

			nRateio := (TEMP->n_RATEIO)
	
			DbCloseArea("TEMP")
			
			dbselectarea("SZE") 									// Rateio de Despesas
			dbSetOrder(1)                                           // busca valor realizado
			dbSeek(xfilial("SZE")+cEmp+cCodesp)	
			
			nQtReal := (nRATEIO * SZE->ZE_VRREAL)/100  
		
		EndIf
		
		
 		dbselectarea("SZI")               		// Quadro de custos
		dbSetOrder(3)
		                                    
		nVacum := 0
		If dbSeek(xfilial("SZI")+cAMant+cCusto+cCodesp)
			nVacum := SZI->ZI_VARACUM
    	EndIf    
	
		If !dbSeek(xfilial("SZI")+cAnomes+cCusto+cCodesp)
				              
			dbSelectArea('SZG')	
			
			Reclock("SZG",.F.)
            SZG->ZG_LANC := 'N'
			MsUnlock()

		Else

			dbselectarea("SZA")
		  	dbSetOrder(1)
	  		
	  		If !dbseek(xfilial("SZA")+cCusto+SZI->ZI_DC)
	  			MsgInfo("Atenção. Falta Direc. Custo para o C.C: "+rtrim(cCusto)+"/"+SZI->ZI_DC)
	  		Else
	  			If SZA->ZA_VOLREAL == 0
	  			   MsgInfo("Atenção. Falta Vol.Realizado para o C.C: "+rtrim(cCusto)+"/"+SZI->ZI_DC)
	  			EndIf
	  		EndIf
           
			dbselectarea("SZI")

			Reclock("SZI",.F.)
			SZI->ZI_VOLREAL	:= SZA->ZA_VOLREAL
			SZI->ZI_REALIZA := nQtReal  

			SZI->ZI_VARMES	:= SZI->ZI_ORCADO - SZI->ZI_REALIZA
			SZI->ZI_PCVMES	:= 0.00
			SZI->ZI_VARACUM	:= nVacum + SZI->ZI_VARMES  
			SZI->ZI_PCVACUM	:= 0.00

			SZI->ZI_CUSTOP	:= Iif(SZA->ZA_VOLREAL>0,SZI->ZI_REALIZA / SZA->ZA_VOLREAL, 0) 
			SZI->ZI_PCUSTOP	:= 0.00
			MsUnlock()
			
		EndIf

		IncProc()
		                        
		dbSelectArea('SZG')
		SZG->(DbSkip())
	    
  	Enddo
	  	
	   
Return          



Static Function Sumariza()
	
	/*
		1 Sumário de Grupos de Cod.Despesa 
			O sumário para Totais são registrados no próprio Cod. de Despesas, onde
	    	a coluna Título='1'(sim) e right(codesp,3)='000' e são os primeiros do Grupo
	    
	    2 Totais Quadro de Custo ( resultado de custos/mes):
	    	Foram incluidos mais Cod.Despesas de subtotais para o relatório que,
	    	originalmente, apresenta os seguintes subtotais:
	    	- Total de Gerência (Grupo de Despesas de '01' a '07')
	    		. criado o Cod.Desp = '070999'
	    	- Total de Gerência + Depreciações (Grupo de Despesas '08')
	    		. criado o Cod.Desp = '080999'
	    	- Total de Gerência + Deprec + Recirculação (Grupo de Despesas '09')
	    		. criado o Cod.Desp = '090999'
	   	
		3 Percentual no Custo de Produção/hora
	   		Antes de atualizar totais e subtotais:
	   		- CALCULAR O PERCENTUAL PARTICIPATIVO de cada COD.DESP, onde titulo=2 
	   	  		. cálculo: CustoP-h/soma_custoP * 100 
	   	  		. Grupos : 	CC + GRUPO entre '01' e '06' // grupo 07-Financeiro
	   	  			 		CC + GRUPO = '08'
	   	  			 		CC + GRUPO = '09'
	   	  		
	    4 Despesas NÃO realizadas
			As despesas do mes anterior sem ocorrência no mes atual, devem ser
	   		transportadas para o mes atual
	   	  			  
	 	5 Agrupar para os right(Codesp,3)='000' e Titulo='1' 
	 		Onde: titulo=2, por CC+GRUPOCD  
	 	
	 	6 Agrupar para os right(Codesp,3)='999'
	 	    onde: mesmo critério de 3
	*/       
 
	// --------------------------------------------
 	// 3 Percentual no Custo de Produção/hora
 	// --------------------------------------------
 	
	cQry := "select ZI_AM AMES,ZI_CUSTO cCusto, '07' cGrupocd, SUM(ZI_CUSTOP) n_CustoP "
	cQry += " from "+RetSqlName("SZI")
    cQry += " where ZI_AM='"+cAnomes+"' and ZI_TITULO='2' and ZI_GRUPOCD BETWEEN '01' and '07' and ZI_CUSTOP>0 and D_E_L_E_T_ <> '*' "
    cQry += " Group by ZI_AM,ZI_CUSTO "
    cQry += "UNION "
 	cQry += "select ZI_AM AMES,ZI_CUSTO cCusto, '08' cGrupocd, SUM(ZI_CUSTOP) n_CustoP "
	cQry += " from "+RetSqlName("SZI")
    cQry += " where ZI_AM='"+cAnomes+"' and ZI_TITULO='2' and ZI_GRUPOCD='08' and ZI_CUSTOP>0 and D_E_L_E_T_ <> '*' "
    cQry += " Group by ZI_AM,ZI_CUSTO "
    cQry += "UNION "
 	cQry += "select ZI_AM AMES,ZI_CUSTO cCusto, '09' cGrupocd, SUM(ZI_CUSTOP) n_CustoP "
	cQry += " from "+RetSqlName("SZI")
    cQry += " where ZI_AM='"+cAnomes+"' and ZI_TITULO='2' and ZI_GRUPOCD='09' and ZI_CUSTOP>0 and D_E_L_E_T_ <> '*' "
    cQry += " Group by ZI_AM,ZI_CUSTO "


	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")

	ProcRegua(TEMP->(RecCount()))
	
	DbGoTop()
	While TEMP->( !Eof() )
	    
		cValor := alltrim(STR(TEMP->n_CustoP))
        
   		cUPD := ""
		cUPD := "update "+RetSqlName("SZI")
		cUPD += " set ZI_PCUSTOP = (ZI_CUSTOP /'"+cValor+"')*100 " 
        
        if TEMP->cGrupoCD == '07'
    	   cUPD += " where ZI_AM='"+cAnomes+"' and ZI_TITULO='2' and ZI_GRUPOCD BETWEEN '01' and '07' and ZI_CUSTOP>0 and D_E_L_E_T_ <> '*' "
    	Else
    	   cUPD += " where ZI_AM='"+cAnomes+"' and ZI_TITULO='2' and ZI_GRUPOCD = '"+temp->cGRUPOCD+"' and ZI_CUSTOP>0 and D_E_L_E_T_ <> '*' "
        EndIf
        
		TCSqlExec(cUPD)	 
	 	          
		IncProc()
	 	 
		dbSelectArea('TEMP')
		TEMP->(DbSkip())
	
	EndDo
 	// FIM. 3 Percentual no Custo de Produção/hora
	DbCloseArea("TEMP")

 	// --------------------------------------------
	// 4 Despesas NÃO realizadas
 	// --------------------------------------------

	cQry := "select ZI_AM,ZI_CUSTO,ZI_DC,ZI_CODESP,ZI_VOLORC,ZI_VOLREAL,ZI_ORCADO,"
	cQry += "ZI_REALIZA,ZI_VARMES,ZI_PCVMES,ZI_VARACUM,ZI_PCVACUM,ZI_CUSTOP,"
	cQry += "ZI_PCUSTOP,ZI_GRUPOCC,ZI_GRUPOCD,ZI_TITULO "
	cQry += " from "+RetSqlName("SZI")
    cQry += " where ZI_AM='"+cAMant+"' and ZI_TITULO='2' and D_E_L_E_T_ <> '*' "
    cQry += " Order by ZI_AM,ZI_CUSTO,ZI_DC,ZI_CODESP "

	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")

	ProcRegua(TEMP->(RecCount()))
	
	DbGoTop()
	While TEMP->( !Eof() )
    	
    	cCusto	:= TEMP->ZI_CUSTO
    	cCodesp	:= TEMP->ZI_CODESP
    	
 		dbselectarea("SZI")              		// Quadro de custos
		dbSetOrder(3)
		If !dbSeek(xfilial("SZI")+cAnomes+cCusto+cCodesp)

			RecLock("SZI",.T.)
		    SZI->ZI_FILIAL	:= xFilial("SZI")
	    	SZI->ZI_AM    	:= cAnomes
	    	SZI->ZI_CUSTO 	:= cCusto
		    SZI->ZI_DC    	:= TEMP->ZI_DC
	    	SZI->ZI_CODESP	:= cCodesp
	    	
			SZI->ZI_VOLORC	:= TEMP->ZI_VOLORC
			SZI->ZI_VOLREAL := 0 
			SZI->ZI_ORCADO	:= TEMP->ZI_ORCADO		
			SZI->ZI_REALIZA := 0 

			SZI->ZI_VARMES	:= 0
			SZI->ZI_PCVMES	:= 0.00
			SZI->ZI_VARACUM	:= TEMP->ZI_VARACUM
			SZI->ZI_PCVACUM	:= 0.00

			SZI->ZI_CUSTOP	:= 0.00
			SZI->ZI_PCUSTOP	:= 0.00
			
			SZI->ZI_GRUPOCC := TEMP->ZI_GRUPOCC
			SZI->ZI_GRUPOCD := TEMP->ZI_GRUPOCD
			SZI->ZI_TITULO  := TEMP->ZI_TITULO
			
			MsUnlock()
        	
     	EndIf

		IncProc()

		dbSelectArea('TEMP')
		TEMP->(DbSkip())

 	EndDo
 	// FIM. 4 Despesas NÃO realizadas 	
	dbCloseArea('TEMP')

 	// --------------------------------------------
	// 5 Agrupa para os right(Codesp,3)='000'
 	// --------------------------------------------
	
	cQry := "select ZI_CUSTO,ZI_GRUPOCD,SUM(ZI_ORCADO) VRORC,SUM(ZI_REALIZA) VREAL,"
	cQry += "SUM(ZI_VARMES) VARMES,SUM(ZI_VARACUM) VARACUM,SUM(ZI_CUSTOP) CUSTOP,"
	cQry += "SUM(ZI_PCUSTOP) PCUSTOP "
	cQry += " from "+RetSqlName("SZI")
    cQry += " where ZI_AM='"+cAnomes+"' and ZI_TITULO='2' and D_E_L_E_T_ <> '*' "
    cQry += " Group by ZI_CUSTO,ZI_GRUPOCD "
    cQry += " Order by ZI_CUSTO,ZI_GRUPOCD "

	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")

	ProcRegua(TEMP->(RecCount()))
	
	DbGoTop()
	While TEMP->( !Eof() )

		cCusto	 := TEMP->ZI_CUSTO
        cGrupoCD := TEMP->ZI_GRUPOCD+'0000' 
       
 		dbselectarea("SZI")              		// Quadro de custos
		dbSetOrder(3)
		If dbSeek(xfilial("SZI")+cAnomes+cCusto+cGrupoCD)

			RecLock("SZI",.F.)
			SZI->ZI_ORCADO	:= TEMP->VRORC		
			SZI->ZI_REALIZA := TEMP->VREAL 
			SZI->ZI_VARMES	:= TEMP->VARMES
			SZI->ZI_VARACUM	:= TEMP->VARACUM
			SZI->ZI_CUSTOP	:= TEMP->CUSTOP
			SZI->ZI_PCUSTOP	:= TEMP->PCUSTOP			
			MsUnlock()
        	
     	EndIf

		IncProc()

		dbSelectArea('TEMP')
		TEMP->(DbSkip())
	
	EndDo
 	// FIM. 3 Percentual no Custo de Produção/hora
	dbCloseArea('TEMP') 
	
	
	// ----------------------------------------------------
	// 6 Agrupa para os right(Codesp,3)='999'
	// ----------------------------------------------------

	dbselectarea("SZI")
	dbSetOrder(3)

	Set Filter to SZI->ZI_AM=cAnomes .and. SZI->ZI_TITULO='1' .and. SZI->ZI_GRUPOCD<'10'
    
	nORCADO	 := 0		
	nREALIZA := 0 
	nVARMES	 := 0
	nVARACUM := 0
	nCUSTOP	 := 0
	nPCUSTOP := 0			
	
    dbGoTop()
    While SZI->( !Eof() )

		nORCADO	 := nORCADO  + SZI->ZI_ORCADO 	 				
		nREALIZA := nREALIZA + SZI->ZI_REALIZA  
		nVARMES	 := nVARMES  + SZI->ZI_VARMES
		nVARACUM := nVARACUM + SZI->ZI_VARACUM
		nCUSTOP	 := nCUSTOP  + SZI->ZI_CUSTOP
		nPCUSTOP := nPCUSTOP + SZI->ZI_PCUSTOP
		
		SZI->(DbSkip())			
		
		If SZI->ZI_CODESP $'070999#080999#090999'
		
			RecLock("SZI",.F.)
			SZI->ZI_ORCADO	:= nORCADO		
			SZI->ZI_REALIZA := nREALIZA 
			SZI->ZI_VARMES	:= nVARMES
			SZI->ZI_VARACUM	:= nVARACUM
			SZI->ZI_CUSTOP	:= nCUSTOP
			SZI->ZI_PCUSTOP	:= nPCUSTOP			
			MsUnlock()
		
		    SZI->(DbSkip())        
		
		EndIf


    EndDo

    Set Filter to

Return                     

