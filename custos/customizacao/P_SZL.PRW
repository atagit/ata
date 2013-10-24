/*______________________________________________________________________
   ¦Autor     ¦ Eraldo Drumond                      ¦ Data ¦ 16/04/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Replica EPI's de um Cargo para outro                  ¦
   ¦                                                                  ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

#include "rwmake.ch"
#include "Protheus.ch"
#include "topconn.ch"

User Function P_SZL()
   
    private cCusto 	:= ""
    private cDC		:= ""
    private cCodesp	:= ""
    private cUnid	:= ""
    private lAborta := .F.
	private cQry	:= ''
	private cPerg	:= 'SZL001'

/*______________________________________________________________________
   Pergunta:SZK001
   			mv_par01 - Cargo Origem
   			mv_par02 - C.Custo Origem
   			mv_par03 - Cargo Destino 
   			mv_par04 - C.Custo Destino 
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
	
	If !Pergunte(cPerg)
	   Return
	EndIf
    
    If (mv_par01=' ') .or. (mv_par03=' ')     
        return
    endif

	Processa({|| Increplica()},"","Aguarde. Processando ...",lAborta)
           
return


Static Function Increplica()

	cCargo := mv_par03		// Cargo destino
	cCusto := mv_par04		// C.Custo destino
	nConta := 0

	dbSelectArea('SQ3')
	dbSetOrder(1)

	If !dbSeek(xfilial("SQ3")+cCargo)
	    msgbox('Cargo destino não encontrado na tabela de Cargos.') 
		Return
	EndIf			

	cDcargo	:= SQ3->Q3_DESCSUM

	cQry := "SELECT ZL_FILIAL FILIAL, ZL_CARGO CARGO, ZL_CUSTO CC, ZL_CODB1 CODB1, ZL_DESCB1 DESCB1, "
	cQry += " ZL_VALOR VALOR, ZL_QTDE QTDE, ZL_FREQ FREQ, ZL_QTMES QTMES, ZL_CODESP CODESP "
	cQry += " FROM "+RetSqlName("SZL")
    cQry += " WHERE ZL_CARGO='"+mv_par01+"' AND ZL_CUSTO='"+mv_par02+"' AND D_E_L_E_T_ <> '*' "
    cQry += " ORDER BY ZL_CARGO, ZL_CUSTO, ZL_CODB1 "

	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	DbGoTop()
	                            
	If TEMP->( Eof() )
	    DbCloseArea("TEMP")
		MsgBox('Nenhum registro selecionado.')
		Return
	EndIf	
	
	ProcRegua(TEMP->(RecCount()))
   	                         
	DbGoTop()
	While TEMP->( !Eof() )
	
		cCodB1	:= TEMP->CODB1
		
		dbselectarea("SZL")
		dbSetOrder(1)
		
		If !dbSeek(xfilial("SZL")+cCargo+cCusto+cCodB1)
			nConta := nConta + 1
			
			RecLock("SZL",.T.)
	    	SZL->ZL_FILIAL	:= TEMP->FILIAL
	   		SZL->ZL_CARGO 	:= cCargo
	   		SZL->ZL_DESC  	:= cDcargo
	   		SZL->ZL_CUSTO 	:= cCusto
		    SZL->ZL_CODB1 	:= cCodB1
	   		SZL->ZL_DESCB1 	:= TEMP->DESCB1
	   		
	   		SZL->ZL_VALOR	:= TEMP->VALOR
	   		SZL->ZL_QTDE	:= TEMP->QTDE  
	   		SZL->ZL_FREQ	:= TEMP->FREQ
	   		SZL->ZL_QTMES	:= TEMP->QTMES  

	   		SZL->ZL_CODESP	:= TEMP->CODESP
			MsUnlock()
			
		EndIf             

		dbSelectArea('TEMP')
		TEMP->(DbSkip())
                  
		IncProc()

    EndDo
    
	DbCloseArea("TEMP")

	msgbox('Registros incluidos: '+str(nconta))

Return
