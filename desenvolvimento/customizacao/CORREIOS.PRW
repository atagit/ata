/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 13/08/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Retorna informacoes de cadastro de endereço           ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"

user function CORREIOS()
	private cAlias := Alias()
	private cQry := ""
	
	@010,010 to 127,165 dialog oDlg1 title "COMPLETAR"
		@005,005 to 038,075
		
		if cAlias == "SA2"
			@010,010 button "CEP pesquisa Endereco" size 060,010 action PesEND(M->A2_CEP)
			@023,010 button "Endereco pesquisa CEP" size 060,010 action PesCEP(M->A2_END,M->A2_BAIRRO,M->A2_MUN,M->A2_EST)
		elseif cAlias == "SA1"
			@010,010 button "CEP pesquisa Endereco" size 060,010 action PesEND(M->A1_CEP)
			@023,010 button "Endereco pesquisa CEP" size 060,010 action PesCEP(M->A1_END,M->A1_BAIRRO,M->A1_MUN,M->A1_EST)
		endif
		
		@043,049 bmpbutton type 02 action close(oDlg1)
	activate dialog oDlg1 center
return

//Pelo CEP pesquisa o Endereco
static function PesEND(cCep)
	dbselectarea("SZ9")
	dbsetorder(1)

	if alltrim(cCep) <> "" .or. !empty(cCep)
		cQry := "select * "
		cQry += "from "+retsqlname("SZ9")+" "
		cQry += "where Z9_CEP = '"+cCep+"'"
		
		TCQuery cQry New Alias "TEMP"
		dbselectarea("TEMP")
		
		if !empty(TEMP->Z9_CEP)
			if cAlias == "SA2"
				M->A2_END	 := alltrim(TEMP->Z9_LOGADO)+" "+alltrim(TEMP->Z9_DESCR)
				M->A2_BAIRRO := alltrim(TEMP->Z9_BAIRRO)
				M->A2_MUN	 := alltrim(TEMP->Z9_CIDADE)
				M->A2_EST	 := alltrim(TEMP->Z9_UF)
			elseif cAlias == "SA1"
				M->A1_END	 := alltrim(TEMP->Z9_LOGADO)+" "+alltrim(TEMP->Z9_DESCR)
				M->A1_BAIRRO := alltrim(TEMP->Z9_BAIRRO)
				M->A1_MUN	 := alltrim(TEMP->Z9_CIDADE)
				M->A1_EST	 := alltrim(TEMP->Z9_UF)
			endif
		else
			msgbox("CEP nao encontrado!","Atencao","ALERT")
		endif
	else
		msgbox("CEP vazio!","Atencao","ALERT")
	endif
	
	TEMP->(dbclosearea())
	close(oDlg1)
return

//Pelo Endereco pesquisa o CEP
static function PesCEP(cEnd,cBai,cMun,cEst)
	local cLog := ""
	local cEndereco:= ""
	
	dbselectarea("SZ9")
	dbsetorder(2)
	dbgotop()
	
	if alltrim(cEnd) <> "" .or. !empty(cEnd)
		if alltrim(cBai) <> "" .or. !empty(cBai)
			if alltrim(cMun) <> "" .or. !empty(cMun)
				if alltrim(cEst) <> "" .or. !empty(cEst)
					for i := 1 to len(cEnd)
						if substr(cEnd,i,1) = " "
							exit
						else
							cLog += substr(cEnd,i,1)
						endif
					next
					
					cEndereco := substr(cEnd,len(cLog)+2,len(cEnd))
					cEnd := cEndereco+replicate(" ",70-len(cEndereco))
					cBai := cBai+replicate(" ",72-len(cBai))
					cMun := cMun+replicate(" ",50-len(cMun))
					cLog := cLog+replicate(" ",72-len(cLog))
					
					cQry := "select * "
					cQry += "from "+retsqlname("SZ9")+" "
					cQry += "where Z9_UF = '"+cEst+"' and Z9_CIDADE = '"+cMun+"' and Z9_BAIRRO = '"+cBai+"' and Z9_DESCR = '"+cEnd+"'"
					
					TCQuery cQry New Alias "TEMP"
					dbselectarea("TEMP")
					
					if !empty(cEst) .and. !empty(cMun) .and. !empty(cBai) .and. !empty(cEnd)
						if cAlias == "SA2"
							M->A2_CEP := TEMP->Z9_CEP
						elseif cAlias == "SA1"
							M->A1_CEP := TEMP->Z9_CEP
						endif
					else
						msgbox("Endereco nao encontrado!","Atencao","ALERT")
					endif
				else
					msgbox("Estado vazio!","Atencao","ALERT")
				endif
			else
				msgbox("Municipio vazio!","Atencao","ALERT")
			endif
		else
			msgbox("Bairro vazio!","Atencao","ALERT")
		endif
	else
		msgbox("Endereco vazio!","Atencao","ALERT")
	endif
	
	TEMP->(dbclosearea())
	close(oDlg1)
return