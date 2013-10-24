/*______________________________________________________________________
   ¦Autor     ¦ Eraldo Drumond                      ¦ Data ¦ 27/01/12 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Replica Cód.Despesas de CC cadastrado para outro CC   ¦
   ¦            Origem: Despesas Orçadas x CC - SZK                   ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

#include "rwmake.ch"
#include "Protheus.ch"
#include "topconn.ch"

User Function PTESTE()
   
    private cCusto 	:= ""
    private cDC		:= ""
    private cCodesp	:= ""
    private cUnid	:= ""
    private lAborta := .F.
	private cQry	:= ''
	private cPerg	:= ''

	Processa({|| Increplica()},"","Aguarde. Processando ...",lAborta)
           
return


Static Function Increplica()

	cQry := "SELECT MAX(D1_DOC) DOC "
	cQry += " FROM "+RetSqlName("SD1")
//	cQry += " FROM SD1010 SD1 "
    cQry += " WHERE D_E_L_E_T_ <> '*' "

	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	DbGoTop()
	                            
	If TEMP->( Eof() )
	    DbCloseArea("TEMP")
		MsgBox('Nenum registro selecionado.')
		Return
	EndIf	

    msgbox(temp->doc)
    
	DbCloseArea("TEMP")
//--------------------------------------------------
	cQry := "SELECT MAX(D1_DOC) DOC "
	cQry += " FROM "+RetSqlName("SD1")

//	cQry += " FROM SD1020 SD1 "
    cQry += " WHERE D_E_L_E_T_ <> '*' "

	tcquery cQry new alias "TEMP"
	DbSelectArea("TEMP")
	DbGoTop()
	                            
	If TEMP->( Eof() )
	    DbCloseArea("TEMP")
		MsgBox('Nenum registro selecionado.')
		Return
	EndIf	
                        
    msgbox(temp->doc)
    
	DbCloseArea("TEMP")

Return
