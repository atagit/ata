/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 07/08/13 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Cadastro das folhas de cheques do talao               ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "protheus.ch"
#include "rwmake.ch"

user function TALAO()
	local cFiltro := ""
	
	private cCadastro := "Folha de Cheque"
	private aTalao := {{"Liberar","U_TALAOBJ(1)",0,6},;
						{"Liberar Varios","U_TALAOBJ(5)",0,6},;
						{"Bloquear","U_TALAOBJ(2)",0,6}}
	private aRotina := {{"Pesquisar","AxPesqui",0,1},;
						{"Visualizar","AxVisual",0,2},;
						{"Incluir","U_TALAOBJ(4)",0,3},;
						{"Excluir","U_TALAOBJ(3)",0,5},;
						{"Folha Chq",aTalao,0,6},;
						{"Legenda","U_LEGTALAO()",0,7}}
	private aColors := {{"Z8_STATUS == 'L'","BR_VERDE"},;
						{"Z8_STATUS == 'B'","BR_VERMELHO"},;
						{"Z8_STATUS == 'F'","BR_PRETO"}}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Banco                                             ³
	//³ mv_par02 - Agencia                                           ³
	//³ mv_par03 - Conta                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Pergunte("TALAO",.T.)
	
	if !Empty(mv_par01)
		cFiltro := "Z8_FILIAL = '"+xFilial("SZ8")+"' and Z8_BANCO = '"+mv_par01+"' and Z8_AGENCIA = '"+mv_par02+"' and Z8_CONTA = '"+mv_par03+"' "
	endif
	
	DbSelectArea("SZ8")
	MBrowse(006,008,022,071,"SZ8",,,,,,aColors,,,,,,,,cFiltro)
return

user function LEGTALAO()
	local aLegenda := {}
	
	AAdd(aLegenda,{"BR_VERDE","Liberado"})
	AAdd(aLegenda,{"BR_VERMELHO","Bloqueado"})
	AAdd(aLegenda,{"BR_PRETO","Finalizado"})
	
	BrwLegenda(cCadastro,"Legenda",aLegenda)
return(.T.)

user function TALAOBJ(nOpc)
	static oDlg
	static oButton1, oButton2
	static oGroup1, oGroup2
	static oMultiGet1
	static cMultiGet1 := Space(250)
	static oSay1, oSay2, oSay3, oSay4, oSay5
	static oGet1, oGet2, oGet3, oGet4, oGet5
	static cGet1 := Space(3)
	static cGet2 := Space(5)
	static cGet3 := Space(10)
	
	private cGet4 := Space(6)
	private cGet5 := Space(6)
	
	do case
		case nOpc == 1								//Liberar
			if SZ8->Z8_STATUS == "B"
				if MsgYesNo("Deseja realmente LIBERAR esse cheque para uso?","Liberar Cheque")
					RecLock("SZ8",.F.)
						SZ8->Z8_STATUS := "L"
						SZ8->Z8_DTLIBER := dDataBase
					MsUnLock()
				endif
			endif
		case nOpc == 2								//Bloquear
			if SZ8->Z8_STATUS == "L"
				if MsgYesNo("Deseja realmente BLOQUEAR esse cheque?","Bloquear Cheque")
					define msdialog oDlg title "Bloquear Cheque" from 000,000 to 155,500 colors 0,16777215 pixel
						@003,004 group oGroup1 to 056,246 prompt " Motivo do Bloqueio " of oDlg color 0,16777215 pixel
						@012,008 get oMultiGet1 var cMultiGet1 of oDlg multiline size 233,039 colors 0,16777215 pixel
						@060,208 button oButton1 prompt "Cancelar" size 037,012 of oDlg action Close(oDlg) pixel
						@060,167 button oButton2 prompt "OK" size 037,012 of oDlg action OK(oDlg,cMultiGet1) pixel
					activate msdialog oDlg center
				endif
			endif
		case nOpc == 3								//Excluir
			if SZ8->Z8_STATUS <> "F"
				if MsgYesNo("Deseja realmente excluir esse cheque?")
		            RecLock("SZ8",.F.)
		            	DbDelete()
		            MsUnLock()
		            
		            DbSelectArea("SX2")
		            DbSeek("SZ8")
		            RecLock("SX2",.F.)
		            	SX2->X2_DELET := SX2->X2_DELET + 1
		            MsUnLock()
				endif
			else
				MsgAlert("Nao pode excluir cheque ja usado (finalizado).")
			endif
		case nOpc == 4								//Incluir
			cGet1 := Space(3)
			cGet2 := Space(5)
			cGet3 := Space(10)
			cGet4 := Space(6)
			cGet5 := Space(6)
			
			define msdialog oDlg title "Incluir Cheque" from 000,000 to 170,325 colors 0,16777215 pixel
				@002,003 group oGroup1 to 034,159 prompt " Dados Bancario " of oDlg color 0,16777215 pixel
				@012,006 say oSay1 prompt "Banco" size 025,007 of oDlg colors 0,16777215 pixel
				@012,046 say oSay2 prompt "Agencia" size 025,007 of oDlg colors 0,16777215 pixel
				@012,093 say oSay3 prompt "Conta" size 025,007 of oDlg colors 0,16777215 pixel
				@020,006 msget oGet1 var cGet1 size 020,010 of oDlg colors 0,16777215 F3 "SA6" pixel
				@020,046 msget oGet2 var cGet2 size 032,010 of oDlg colors 0,16777215 pixel
				@020,093 msget oGet3 var cGet3 size 060,010 of oDlg colors 0,16777215 pixel
				@036,003 group oGroup2 to 068,159 prompt " Cheque " of oDlg color 0,16777215 pixel
				@046,006 say oSay4 prompt "Folha Ini" size 025,007 of oDlg colors 0,16777215 pixel
				@053,006 msget oGet4 var cGet4 size 034,010 of oDlg picture "@R 999999" valid ValCheque(@cGet4) colors 0,16777215 pixel
				@046,053 say oSay5 prompt "Folha Fin" size 025,007 of oDlg colors 0,16777215 pixel
				@053,053 msget oGet5 var cGet5 size 034,010 of oDlg picture "@R 999999" valid ValCheque(@cGet5) colors 0,16777215 pixel
				@070,121 button oButton1 prompt "Cancelar" size 037,012 of oDlg action Close(oDlg) pixel
				@070,079 button oButton2 prompt "Incluir" size 037,012 of oDlg action Gravar(nOpc,oDlg,cGet1,cGet2,cGet3,cGet4,cGet5) pixel
			activate msdialog oDlg centered
		case nOpc == 5								//Liberar Varios
			cGet1 := Space(3)
			cGet2 := Space(5)
			cGet3 := Space(10)
			cGet4 := Space(6)
			cGet5 := Space(6)
			
			define msdialog oDlg title "Liberar Cheque" from 000,000 to 170,325 colors 0,16777215 pixel
				@002,003 group oGroup1 to 034,159 prompt " Dados Bancario " of oDlg color 0,16777215 pixel
				@012,006 say oSay1 prompt "Banco" size 025,007 of oDlg colors 0,16777215 pixel
				@012,046 say oSay2 prompt "Agencia" size 025,007 of oDlg colors 0,16777215 pixel
				@012,093 say oSay3 prompt "Conta" size 025,007 of oDlg colors 0,16777215 pixel
				@020,006 msget oGet1 var cGet1 size 020,010 of oDlg colors 0,16777215 F3 "SA6" pixel
				@020,046 msget oGet2 var cGet2 size 032,010 of oDlg colors 0,16777215 pixel
				@020,093 msget oGet3 var cGet3 size 060,010 of oDlg colors 0,16777215 pixel
				@036,003 group oGroup2 to 068,159 prompt " Cheque " of oDlg color 0,16777215 pixel
				@046,006 say oSay4 prompt "Folha Ini" size 025,007 of oDlg colors 0,16777215 pixel
				@053,006 msget oGet4 var cGet4 size 034,010 of oDlg picture "@R 999999" valid ValCheque(@cGet4) colors 0,16777215 pixel
				@046,053 say oSay5 prompt "Folha Fin" size 025,007 of oDlg colors 0,16777215 pixel
				@053,053 msget oGet5 var cGet5 size 034,010 of oDlg picture "@R 999999" valid ValCheque(@cGet5) colors 0,16777215 pixel
				@070,121 button oButton1 prompt "Cancelar" size 037,012 of oDlg action Close(oDlg) pixel
				@070,079 button oButton2 prompt "Liberar" size 037,012 of oDlg action Gravar(nOpc,oDlg,cGet1,cGet2,cGet3,cGet4,cGet5) pixel
			activate msdialog oDlg centered
	endcase
return

static function OK(oDlg,cMotivo)
	RecLock("SZ8",.F.)
		SZ8->Z8_STATUS := "B"
		SZ8->Z8_DTBLOQ := dDataBase
		SZ8->Z8_MOTBLOQ := cMotivo
	MsUnLock()
	Close(oDlg)
return

static function ValCheque(x)
	if !Empty(x)
		x := StrZero(Val(x),6)
	endif
return

static function Gravar(nOpc,oDlg,cBco,cAg,cCta,cFolIni,cFolFin)
	local lRet := .T.
	local nCheque := 0
	
	if Empty(cBco)
		lRet := .F.
	endif
	
	if Empty(cAg)
		lRet := .F.
	endif
	
	if Empty(cCta)
		lRet := .F.
	endif
	
	if Empty(cFolIni)
		lRet := .F.
	endif
	
	if Empty(cFolFin)
		lRet := .F.
	endif
	
	if lRet
		nCheque := Val(cFolIni)
		
		if nOpc == 4				//Incluir
			while nCheque <= Val(cFolFin)
				RecLock("SZ8",.T.)
					SZ8->Z8_FILIAL := xFilial("SZ8")
					SZ8->Z8_BANCO := cBco
					SZ8->Z8_AGENCIA := cAg
					SZ8->Z8_CONTA := cCta
					SZ8->Z8_NOMBCO := IIf(SA6->(DbSeek(xFilial("SA6")+cBco+cAg+cCta,.F.)),SA6->A6_NREDUZ," ")
					SZ8->Z8_CHEQUE := StrZero(nCheque,6)
					SZ8->Z8_STATUS := "B"
				MsUnLock()
				
				nCheque++
			enddo
			
			MsgAlert("Cheque(s) de "+cFolIni+" ate "+cFolFin+" foram incluidos.")
		elseif nOpc == 5				//Liberar Varios
			if MsgYesNo("Deseja realmente LIBERAR esse intervalo de cheque para uso?","Liberar Cheque")
				SZ8->(DbGoTop())
				SZ8->(DbSeek(xFilial("SZ8")+cBco+cAg+cCta+cFolIni,.F.))
				
				while !SZ8->(Eof()) .and. SZ8->Z8_BANCO == cBco .and. SZ8->Z8_AGENCIA == cAg .and. SZ8->Z8_CONTA == cCta .and. SZ8->Z8_CHEQUE >= cFolIni .and. SZ8->Z8_CHEQUE <= cFolFin
					if SZ8->Z8_STATUS == "B"
						RecLock("SZ8",.F.)
							SZ8->Z8_STATUS := "L"
							SZ8->Z8_DTLIBER := dDataBase
						MsUnLock()
					endif
					
					SZ8->(DbSkip())
				enddo
				
				MsgAlert("Os cheque(s) de "+cFolIni+" ate "+cFolFin+" foram liberados.")
			endif
		endif
		Close(oDlg)
	else
		MsgAlert("Alguns campos obrigatorios nao foram preenchidos.")
	endif
return

/*user function NUMTALAO(cBanco,cAgencia,cConta)
	local cRet := ""
	
	if Select("TEMP") <> 0
		TEMP->(DbCloseArea())
	endif
	
	cQry := "select max(Z8_TALAO) as MAIOR "
	cQry += "from "+RetSqlName("SZ8")+" "
	cQry += "where Z8_BANCO = '"+cBanco+"' and Z8_AGENCIA = '"+cAgencia+"' and Z8_CONTA = '"+cConta+"' and D_E_L_E_T_ <> '*' "
	
	tcquery cQry new alias "TEMP"
	
	DbSelectArea("TEMP")
	
	if Empty(TEMP->MAIOR)
		cRet := "000001"
	else
		cRet := StrZero(Val(TEMP->MAIOR) + 1,6)
	endif
return(cRet)*/