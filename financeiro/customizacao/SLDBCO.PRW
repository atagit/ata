/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 17/10/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Refazer o saldo bancário                              ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "topconn.ch"
#include "protheus.ch"

user function SLDBCO(lJob)
	local cAlias := GetArea()
	
	default lJob := .F.
	
	if lJob
		DbSelectArea("SA6")
		SA6->(DbGoTop())
		
		while !SA6->(Eof())
			if SA6->A6_EXIBREL == "S" .and. SA6->A6_BLOCKED <> "1"
				Gravar(SA6->A6_COD,SA6->A6_AGENCIA,SA6->A6_NUMCON,DToS(dDataBase),DToS(dDataBase))
			endif
			
			SA6->(DbSkip())
		enddo
	else
		Pergunte("EXTBCO",.T.)
		Gravar(mv_par01,mv_par02,mv_par03,DToS(mv_par04),DToS(mv_par05))
	endif
	
	RestArea(cAlias)
return

static function Gravar(cBancoDe,cAgenciaDe,cContaDe,cDataDe,cDataAte)
	local cArqTrab1
	local aTempStru := {}
	local cTipoDoc := ""
	local cTipo := ""
	local cBenef := ""
	local cCliFor := ""
	local cLoja := ""
	local cDtDispo := ""
	local cMotBx := ""
	local nValorNF := 0
	
	private nSaldoAtual := 0
	private nSaldoPendente := 0
	
	if Select("TEMP") <> 0
		TEMP->(DbCloseArea())
	endif
	
	DbSelectArea("SZP")
	SZP->(DbGoTop())
	SZP->(DbSeek(xFilial("SZP")+cBancoDe+cAgenciaDe+cContaDe+cDataDe,.T.))
	SZP->(DbSkip(-1))
	
	nSaldoAtual := SZP->ZP_SALATUA
	
	AAdd(aTempStru,{"E5_DTDISPO","C",08,0})
	AAdd(aTempStru,{"E5_DATA","C",08,0})
	AAdd(aTempStru,{"E5_HISTOR","C",40,0})
	AAdd(aTempStru,{"E5_DOCUMEN","C",50,0})
	AAdd(aTempStru,{"E5_NUMCHEQ","C",15,0})
	AAdd(aTempStru,{"E5_PREFIXO","C",03,0})
	AAdd(aTempStru,{"E5_NUMERO","C",09,0})
	AAdd(aTempStru,{"E5_PARCELA","C",03,0})
	AAdd(aTempStru,{"E5_VALOR","N",17,2})
	AAdd(aTempStru,{"E5_RECPAG","C",01,0})
	AAdd(aTempStru,{"E5_RECONC","C",01,0})
	AAdd(aTempStru,{"E5_TIPODOC","C",02,0})
	AAdd(aTempStru,{"E5_DTDIGIT","C",08,0})
	AAdd(aTempStru,{"E5_TIPO","C",03,0})
	AAdd(aTempStru,{"E5_BENEF","C",30,0})
	AAdd(aTempStru,{"E5_CLIFOR","C",06,0})
	AAdd(aTempStru,{"E5_LOJA","C",02,0})
	AAdd(aTempStru,{"E5_BANCO","C",03,0})
	AAdd(aTempStru,{"E5_AGENCIA","C",05,0})
	AAdd(aTempStru,{"E5_CONTA","C",10,0})
	AAdd(aTempStru,{"E5_RECNO","C",06,0})
	AAdd(aTempStru,{"E5_MOTBX","C",3,0})
	
	cArqTrab1 := CriaTrab(aTempStru,.T.)
	
	DbUseArea(.T.,,cArqTrab1,"TEMP",.F.,.F.)
	
	cQry := "select E5_DTDISPO, E5_DATA, E5_HISTOR, E5_DOCUMEN, E5_NUMCHEQ, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_VALOR, E5_RECPAG, E5_RECONC, E5_TIPODOC, E5_DTDIGIT, E5_TIPO, E5_BENEF, E5_CLIFOR, E5_LOJA, E5_BANCO, E5_AGENCIA, E5_CONTA, E5_MOTBX, R_E_C_N_O_ as RECNO "
	cQry += "from "+RetSqlName("SE5")+" "
	cQry += "where (E5_DTDISPO between '"+cDataDe+"' and '"+cDataAte+"') and E5_BANCO = '"+cBancoDe+"' and E5_AGENCIA = '"+cAgenciaDe+"' and E5_CONTA = '"+cContaDe+"' and E5_SITUACA not in ('C','E','X') and E5_TIPODOC <> 'FAT' and ((E5_TIPODOC not in ('MT','BA','CH','EC','PA','ES','DC','JR')) or (E5_TIPODOC in ('CH','EC') and E5_RECONC = 'x')) and D_E_L_E_T_ <> '*' "
	cQry += "order by E5_DTDISPO, E5_BANCO, E5_AGENCIA, E5_CONTA, E5_NUMCHEQ, R_E_C_N_O_"
	
	tcquery cQry new alias "QTRB"
	
	DbSelectArea("QTRB")
	ProcRegua(QTRB->(RecCount()))
	QTRB->(DbGoTop())
	
	while !QTRB->(Eof())
		if QTRB->E5_TIPODOC == "EC"
			TEMP->(DbGoTop())
			
			while !TEMP->(Eof())
//				if TEMP->E5_NUMCHEQ == QTRB->E5_NUMCHEQ .and. TEMP->E5_VALOR == QTRB->E5_VALOR .and. TEMP->E5_DTDISPO == QTRB->E5_DTDISPO .and. TEMP->E5_DATA == QTRB->E5_DATA
//				if TEMP->E5_NUMCHEQ == QTRB->E5_NUMCHEQ .and. TEMP->E5_VALOR == QTRB->E5_VALOR
				if TEMP->E5_NUMCHEQ == QTRB->E5_NUMCHEQ .and. TEMP->E5_VALOR == QTRB->E5_VALOR .and. TEMP->E5_DTDISPO == QTRB->E5_DTDISPO
					TEMP->(DbDelete())
					
					exit
				endif
				
				TEMP->(DbSkip())
			enddo
		else
			TEMP->(DbAppend())
			
			replace TEMP->E5_DTDISPO with QTRB->E5_DTDISPO,;
					TEMP->E5_DATA with QTRB->E5_DATA,;
					TEMP->E5_HISTOR with QTRB->E5_HISTOR,;
					TEMP->E5_DOCUMEN with QTRB->E5_DOCUMEN,;
					TEMP->E5_NUMCHEQ with QTRB->E5_NUMCHEQ,;
					TEMP->E5_PREFIXO with QTRB->E5_PREFIXO,;
					TEMP->E5_NUMERO with QTRB->E5_NUMERO,;
					TEMP->E5_PARCELA with QTRB->E5_PARCELA,;
					TEMP->E5_VALOR with QTRB->E5_VALOR,;
					TEMP->E5_RECPAG with QTRB->E5_RECPAG,;
					TEMP->E5_RECONC with QTRB->E5_RECONC,;
					TEMP->E5_TIPODOC with QTRB->E5_TIPODOC,;
					TEMP->E5_DTDIGIT with QTRB->E5_DTDIGIT,;
					TEMP->E5_TIPO with QTRB->E5_TIPO,;
					TEMP->E5_BENEF with QTRB->E5_BENEF,;
					TEMP->E5_CLIFOR with QTRB->E5_CLIFOR,;
					TEMP->E5_LOJA with QTRB->E5_LOJA,;
					TEMP->E5_BANCO with QTRB->E5_BANCO,;
					TEMP->E5_AGENCIA with QTRB->E5_AGENCIA,;
					TEMP->E5_CONTA with QTRB->E5_CONTA,;
					TEMP->E5_RECNO with Str(QTRB->RECNO,6),;
					TEMP->E5_MOTBX with QTRB->E5_MOTBX
			
			TEMP->(DbCommit())
		endif
		
		IncProc()
		QTRB->(DbSkip())
	enddo
	
	QTRB->(DbCloseArea())
	TEMP->(DbGoTop())
	
	while !TEMP->(Eof())
		cDataDispo := TEMP->E5_DTDISPO
		lGrava := .F.
		
		while TEMP->E5_DTDISPO == cDataDispo
			if TEMP->E5_TIPODOC == "VL" .and. TEMP->E5_MOTBX == "DEB" .and. Left(TEMP->E5_DOCUMEN,3) == "TED"
				cTipoDoc := TEMP->E5_TIPODOC
				cTipo := TEMP->E5_TIPO
				cBenef := TEMP->E5_BENEF
				cCliFor := TEMP->E5_CLIFOR
				cLoja := TEMP->E5_LOJA
				cDtDispo := TEMP->E5_DTDISPO
				cMotBx := TEMP->E5_MOTBX
				
				while !TEMP->(Eof()) .and. TEMP->E5_DTDISPO == cDtDispo .and. TEMP->E5_TIPODOC == cTipoDoc .and. TEMP->E5_BENEF == cBenef .and. TEMP->E5_CLIFOR == cCliFor .and. TEMP->E5_LOJA == cLoja .and. TEMP->E5_MOTBX == cMotBx .and. Left(TEMP->E5_DOCUMEN,3) == "TED"
					nValorNF += TEMP->E5_VALOR
					
					TEMP->(DbSkip())
				enddo
				
				TEMP->(DbSkip(-1))
			elseif TEMP->E5_TIPODOC == "VL" .and. TEMP->E5_MOTBX $ "DEB/NOR" .and. Empty(TEMP->E5_NUMCHEQ)
				cTipoDoc := TEMP->E5_TIPODOC
				cTipo := TEMP->E5_TIPO
				cBenef := TEMP->E5_BENEF
				cCliFor := TEMP->E5_CLIFOR
				cLoja := TEMP->E5_LOJA
				cDtDispo := TEMP->E5_DTDISPO
				cMotBx := TEMP->E5_MOTBX
				nValorNF := TEMP->E5_VALOR
				nCont := 0
				
				TEMP->(DbSkip())
				
				while !TEMP->(Eof()) .and. TEMP->E5_DTDISPO == cDtDispo .and. TEMP->E5_TIPODOC == cTipoDoc .and. TEMP->E5_BENEF == cBenef .and. TEMP->E5_CLIFOR == cCliFor .and. TEMP->E5_MOTBX == cMotBx .and. TEMP->E5_LOJA == cLoja .and. Empty(TEMP->E5_NUMCHEQ)
					nValorNF += TEMP->E5_VALOR
					nCont++
					
					TEMP->(DbSkip())
				enddo
				
				if Empty(nCont)
					cTipoDoc := "" ; cTipo := "" ; cBenef := "" ; cCliFor := "" ; cLoja := "" ; cDtDispo := "" ; cMotBx := "" ; nValorNF := 0
				endif
				
				TEMP->(DbSkip(-1))
			endif
			
			if TEMP->E5_RECPAG == "R"
				if Empty(cBenef)
					nSaldoAtual += TEMP->E5_VALOR
				else
					nSaldoAtual += nValorNF
				endif
			else
				if Empty(cBenef)
					nSaldoAtual -= TEMP->E5_VALOR
				else
					nSaldoAtual -= nValorNF
				endif
			endif
			
			cTipoDoc := "" ; cTipo := "" ; cBenef := "" ; cCliFor := "" ; cDtDispo := "" ; nValorNF := 0 ; cMotBx := "" ; cLoja := ""
			lGrava := .T.
			
			TEMP->(DbSkip())
		enddo
		
		if lGrava
			Pendentes()
			DbSelectArea("SZP")
			SZP->(DbGoTop())
			
			if SZP->(DbSeek(xFilial("SZP")+cBancoDe+cAgenciaDe+cContaDe+cDataDispo,.F.))
				if (SZP->ZP_SALATUA <> nSaldoAtual .and. !Empty(nSaldoAtual)) .or. (SZP->ZP_PENDENT <> nSaldoPendente .and. !Empty(nSaldoPendente))
					RecLock("SZP",.F.)
						SZP->ZP_SALATUA := nSaldoAtual
						SZP->ZP_PENDENT := nSaldoPendente
					MsUnLock()
				endif
			else
				if RecLock("SZP",.T.)
					SZP->ZP_FILIAL := xFilial("SZP")
					SZP->ZP_BANCO := cBancoDe
					SZP->ZP_AGENCIA := cAgenciaDe
					SZP->ZP_CONTA := cContaDe
					SZP->ZP_DTSALDO := SToD(cDataDispo)
					SZP->ZP_SALATUA := nSaldoAtual
					SZP->ZP_PENDENT := nSaldoPendente
					
					MsUnLock()
				endif
			endif
		endif
	enddo
	
	cDataIni := cDataDe
	
	while cDataIni <= cDataAte
		SZP->(DbGoTop())
		
		if !SZP->(DbSeek(xFilial("SZP")+cBancoDe+cAgenciaDe+cContaDe+cDataIni,.T.))
			SZP->(DbSkip(-1))
			
			nSaldoA := SZP->ZP_SALATUA
			nSaldoP := SZP->ZP_PENDENT
			
			if RecLock("SZP",.T.)
				SZP->ZP_FILIAL := xFilial("SZP")
				SZP->ZP_BANCO := cBancoDe
				SZP->ZP_AGENCIA := cAgenciaDe
				SZP->ZP_CONTA := cContaDe
				SZP->ZP_DTSALDO := SToD(cDataIni)
				SZP->ZP_SALATUA := nSaldoA
				SZP->ZP_PENDENT := nSaldoP
				
				MsUnLock()
			endif
		endif
		
		cDataIni := DToS(SToD(cDataIni) + 1)
	enddo
	
	if Select("QTRB") <> 0
		QTRB->(DbCloseArea())
	endif
	
	TEMP->(DbCloseArea())
	FErase(cArqTrab1+".dbf")
	FErase(cArqTrab1+".cdx")
return


static function Pendentes()
	local nValor := 0
	
	if Select("QTRB") <> 0
		QTRB->(DbCloseArea())
	endif
	
	aTempStru := {}
	
	AAdd(aTempStru,{"PREVISAO","C",08,0})
	AAdd(aTempStru,{"CHEQUE","C",06,0})
	AAdd(aTempStru,{"EMISSAO","C",08,0})
	AAdd(aTempStru,{"NATUREZ","C",02,0})
	AAdd(aTempStru,{"OPERACAO","C",40,0})
	AAdd(aTempStru,{"VALOR","N",17,2})
	
	cArqTrab2 := CriaTrab(aTempStru,.T.)
	
	DbUseArea(.T.,,cArqTrab2,"PEND",.F.,.F.)
	index on PREVISAO+CHEQUE to IPEND
	
	cQry := "select E5_DTDISPO, E5_NUMCHEQ, E5_DTDIGIT, E5_HISTOR, E5_VALOR, EF_DTPREDA, EF_PREDATA, E5_TIPODOC "
	cQry += "from "+RetSqlName("SE5")+" SE5 inner join "+RetSqlName("SEF")+" SEF on (E5_NUMCHEQ = EF_NUM and '' = EF_TIPO and E5_BANCO = EF_BANCO and E5_AGENCIA = EF_AGENCIA and E5_CONTA = EF_CONTA) "
	cQry += "where E5_DTDISPO <= '"+DToS(mv_par05)+"' and E5_BANCO = '"+mv_par01+"' and E5_AGENCIA = '"+mv_par02+"' and E5_CONTA = '"+mv_par03+"' and E5_TIPODOC in ('CH','EC') and E5_RECONC <> 'x' and SE5.D_E_L_E_T_ <> '*' and SEF.D_E_L_E_T_ <> '*' "
	cQry += "order by E5_DTDISPO, E5_NUMCHEQ"
	
	tcquery cQry new alias "QTRB"
	
	DbSelectArea("QTRB")
	ProcRegua(QTRB->(RecCount()))
	QTRB->(DbGoTop())
	
	while !QTRB->(Eof())
		if QTRB->E5_TIPODOC == "EC"
			PEND->(DbGoTop())
			
			while !PEND->(Eof())
				if AllTrim(PEND->CHEQUE) == AllTrim(QTRB->E5_NUMCHEQ) .and. PEND->VALOR == QTRB->E5_VALOR
					PEND->(DbDelete())
				endif
				
				PEND->(DbSkip())
			enddo
		else
			PEND->(DbAppend())
			
			replace PEND->PREVISAO with QTRB->E5_DTDISPO,;
					PEND->CHEQUE with AllTrim(QTRB->E5_NUMCHEQ),;
					PEND->EMISSAO with QTRB->E5_DTDIGIT,;
					PEND->NATUREZ with IIf(QTRB->EF_PREDATA == "F","AV","PR"),;
					PEND->OPERACAO with QTRB->E5_HISTOR,;
					PEND->VALOR with QTRB->E5_VALOR
			
			PEND->(DbCommit())
		endif
		
		IncProc()
		QTRB->(DbSkip())
	enddo
	
	PEND->(DbGoTop())
	
	while !PEND->(Eof())
		nValor += PEND->VALOR
		
		PEND->(DbSkip())
	enddo
	
	nSaldoPendente := nSaldoAtual - nValor
	
	PEND->(DbCloseArea())
	FErase(cArqTrab2+".dbf")
	FErase(cArqTrab2+".cdx")
return