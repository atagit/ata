/*______________________________________________________________________
   ¦Autor     ¦ Eraldo Drumond                       ¦ Data ¦ 30/03/12 ¦
   +----------+--------------------------------------------------------¦
   ¦Descrição : Atualiza Organograma via SR3-Funcinários               ¦
   ¦          : Verificar abono e adicionar ao salário                 ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function P_SRA() 

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


	Processa({|| AtuSZD()},"","Atualizando Organograma ...",lAborta)
    
Return

                            
Static Function AtuSZD()

	cQry := "SELECT ZZT_CUSTO CUSTO, ZZT_CARGO CARGO, COUNT(*) EFETIVO, AVG(ZZT_SALH) SALH, MIN(Q3_DESCSUM) DCARGO,MIN(CTT_DESC01) DCC "
	cQry += "FROM ZZT010 ZZT LEFT JOIN SQ3010 SQ3 ON Q3_CARGO=ZZT_CARGO " 
	cQry += "                     JOIN CTT010 CTT ON CTT_CUSTO=ZZT_CUSTO " 
	cQry += " WHERE ZZT_SALH<>0 AND ZZT.D_E_L_E_T_ <> '*' "
	cQry += " group by ZZT_CUSTO, ZZT_CARGO "
	cQry += " ORDER BY ZZT_CUSTO, ZZT_CARGO "	
	
	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	
	dbGoTop()
	
	ProcRegua(TEMP->(RecCount()))
	
	While !TEMP->(Eof())

		cEmp    := iif(Left(TEMP->CUSTO,2)='09','1','2')
		cCusto  := TEMP->CUSTO
		cCargo  := TEMP->CARGO   
	     
        // -------------------------------------------------------------------------
		// inclui na Tabela SZD-ORGANOGRAMA 
		// -------------------------------------------------------------------------
		
		dbSelectArea("SZD")
		dbSetOrder(1)
		
		If !dbSeek(xfilial("SZD")+cEmp+cCusto+cCargo)
			RecLock("SZD",.T.)
	    	SZD->ZD_FILIAL	:= xFilial("SZD")
	    	SZD->ZD_EMP    	:= cEmp
	   		SZD->ZD_CUSTO 	:= cCusto 
	   		SZD->ZD_FUNCAO	:= cCargo
	   		SZD->ZD_DESCFUN	:= TEMP->DCARGO
	   		SZD->ZD_DESCCC	:= TEMP->DCC

	   		SZD->ZD_PREV	:= TEMP->EFETIVO
	   		SZD->ZD_TURNO 	:= 1
	   		SZD->ZD_FOLGT 	:= 0
	   		SZD->ZD_TOTAL	:= (SZD->ZD_PREV * SZD->ZD_TURNO) + SZD->ZD_FOLGT
	   		
   			SZD->ZD_SALMED	:= TEMP->SALH
	   		SZD->ZD_TOTSAL	:= (SZD->ZD_TOTAL * SZD->ZD_SALMED)

			SZD->ZD_EFET	:= 0				// efetivo em SRA
			SZD->ZD_EFETSAL	:= 0.00       		// salario do efetivo->SRA
			
			SZD->ZD_NIVEL	:= 100 - INT(SZD->ZD_SALMED)	// apenas para ordenar nivel salarial
			SZD->ZD_GRUPOCC := Left(SZD->ZD_CUSTO,2)
			SZD->ZD_PROC	:= '2'		          
			MsUnlock()
		Else          
			RecLock("SZD",.F.)
	   		SZD->ZD_PREV	:= TEMP->EFETIVO
	   		SZD->ZD_TOTAL	:= (SZD->ZD_PREV * SZD->ZD_TURNO) + SZD->ZD_FOLGT
   			SZD->ZD_SALMED	:= TEMP->SALH
	   		SZD->ZD_TOTSAL	:= (SZD->ZD_TOTAL * SZD->ZD_SALMED)
			SZD->ZD_EFET	:= 0							// efetivo em SRA
			SZD->ZD_EFETSAL	:= 0.00       					// salario do efetivo->SRA
			SZD->ZD_NIVEL	:= 100 - INT(SZD->ZD_SALMED)	// ordena nivel salarial
			SZD->ZD_PROC	:= '2'		          
		  	MsUnlock()
	    EndIf
         
		dbSelectArea('TEMP')

		IncProc()
		                        
		TEMP->(DbSkip())
			
	EndDo    

	dbCloseArea('TEMP')    
 
return 

