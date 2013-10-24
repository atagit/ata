/*______________________________________________________________________
   ¦Autor     ¦ Eraldo Drumond                      ¦ Data ¦ 27/01/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Replica Cód.Despesas de CC cadastrado para outro CC   ¦
   ¦            Origem: Despesas Orçadas x CC - SZK                   ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

#include "rwmake.ch"
#include "Protheus.ch"
#include "topconn.ch"

User Function P_SZK()
   
    private cCusto 	:= ""
    private cDC		:= ""
    private cCodesp	:= ""
    private cUnid	:= ""
    private lAborta := .F.
	private cQry	:= ''
	private cPerg	:= 'SZK001'

/*______________________________________________________________________
   Pergunta:SZK001
   			mv_par01 - C.Custo de:
   			mv_par02 - D.C
   			mv_par03 - C.Custo para:
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
	
	If !Pergunte(cPerg)
	   Return
	EndIf
    
    If (mv_par01=' ') .or. (mv_par02=' ') .or. (mv_par03=' ')     
        return
    endif
  
   

	Processa({|| Increplica()},"","Aguarde. Processando ...",lAborta)
           
return


Static Function Increplica()

	cQry := "SELECT ZK_FILIAL Filial, ZK_CUSTO CC,ZK_DC DC, ZK_CODESP CD, ZK_DESCCD DESCCD, ZK_PRECO PRECO, ZK_QTDORC QTDORC "
//	cQry += " FROM "+RetSqlName("SZK")
	cQry += " FROM SZK010 SZK "
    cQry += " WHERE ZK_CUSTO='"+mv_par01+"' AND ZK_DC='"+mv_par02+"' AND D_E_L_E_T_ <> '*' "
    cQry += " ORDER BY ZK_CUSTO,ZK_DC,ZK_CODESP "

	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	DbGoTop()
	                            
	If TEMP->( Eof() )
	    DbCloseArea("TEMP")
		MsgBox('Nenum registro selecionado.')
		Return
	EndIf	
		
	cDc	   := mv_par02		// D.C
	cCusto := mv_par03		// novo c.custo
	nConta := 0
	
	ProcRegua(TEMP->(RecCount()))
   	                         
	DbGoTop()
	While TEMP->( !Eof() )
	
		dbselectarea("SZK")
		dbSetOrder(1)
		
		If !dbSeek(xfilial("SZK")+cCusto+cDC+TEMP->CD)
			nConta := nConta + 1
			RecLock("SZK",.T.)
	    	SZK->ZK_FILIAL	:= TEMP->Filial
	   		SZK->ZK_CUSTO 	:= cCusto
		    SZK->ZK_DC    	:= cDC
	   		SZK->ZK_CODESP	:= TEMP->CD
	   		SZK->ZK_PRECO	:= 0
	   		SZK->ZK_QTDORC	:= 0  
	   		SZK->ZK_DESCCD	:= TEMP->DESCCD
			MsUnlock()
		EndIf             

		dbSelectArea('TEMP')
		TEMP->(DbSkip())
                  
		IncProc()

    EndDo
    
	DbCloseArea("TEMP")

	msgbox('Registros incluidos: '+str(nconta))

Return
