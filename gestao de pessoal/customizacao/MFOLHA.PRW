/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 07/12/11 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Importar funcionários do MFOLHA                       ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

#define _TATFFUN "\\atfsrv001\mastermaq$\MFOLHA\DADOS4\FUNCS016.DBF"
#define _TATFSAL "\\atfsrv001\mastermaq$\MFOLHA\DADOS4\SALAR016.DBF"
#define _TATAFUN "\\atfsrv001\mastermaq$\MFOLHA\DADOS1\FUNCS003.DBF"
#define _TATASAL "\\atfsrv001\mastermaq$\MFOLHA\DADOS1\SALAR003.DBF"
#define _IATFFUN "\\atfsrv001\mastermaq$\MFOLHA\DADOS4\FUNCS016.IDX"
#define _IATFSAL "\\atfsrv001\mastermaq$\MFOLHA\DADOS4\SALAR016.IDX"
#define _IATAFUN "\\atfsrv001\mastermaq$\MFOLHA\DADOS1\FUNCS003.IDX"
#define _IATASAL "\\atfsrv001\mastermaq$\MFOLHA\DADOS1\SALAR003.IDX"
#define _TFCOES "\\atfsrv001\mastermaq$\MFOLHA\FCOES.DBF"
#define _IFCOES "\\atfsrv001\mastermaq$\MFOLHA\FCOES.IDX"
#define _EMPDEF "01"

user function MFOLHA()
	local oButton1, oButton2
	local oSay1, oSay2
	local oComboBo1
	local cComboBo1 := ""
	local oGroup1
	
	private oDlg
	private cCodFuncao
	private cDesFuncao
	private lAborta := .T.
	
	define msdialog oDlg title "IMPORTAR MFOLHA" from 000,000 to 110,430 colors 0,16777215 pixel
		@003,004 group oGroup1 to 035,211 of oDlg color 0,16777215 pixel
		@010,008 say oSay1 prompt "Esta rotina tem como objetivo importar o(s) dado(s) do sistema MFOLHA." size 199,007 of oDlg colors 0,16777215 pixel
		@019,008 say oSay2 prompt "Selecione abaixo o que deseja importar." size 199,007 of oDlg colors 0,16777215 pixel
		@038,133 button oButton1 prompt "OK" size 037,012 of oDlg action Tela(cComboBo1,oDlg) pixel
		@038,173 button oButton2 prompt "Cancelar" size 037,012 of oDlg action Close(oDlg) pixel
		@039,004 mscombobox oComboBo1 var cComboBo1 items {"1- Funções","2- Funcionários"} size 105,010 of oDlg colors 0,16777215 pixel
	activate msdialog oDlg centered
return

static function Tela(cOpc,oJan)
	local oDlg, oFont
	
	define font oFont name "Arial" size 000,-12
	define msdialog oDlg title "IMPORTACAO MFOLHA" from 000,000 to 250,500 pixel
	
	do case
		case Left(cOpc,1) == "1"
			@005,010 to 100,242 pixel
			@010,015 say "Esta rotina tem como objetivo importar a(s) funcao(oes) cadastrado" pixel font oFont of oDlg
			@020,015 say "no sistema MFOLHA da Mastermaq." pixel font oFont of oDlg
			@105,147 bmpbutton type 05 action Pergunte("MFCOE",.T.)
			@105,179 bmpbutton type 01 action ImpFuncao(oDlg)
			@105,211 bmpbutton type 02 action Close(oDlg)
		case Left(cOpc,1) == "2"
			@005,010 to 100,242 pixel
			@010,015 say "Esta rotina tem como objetivo importar o(s) funcionario(s) cadastrado" pixel font oFont of oDlg
			@020,015 say "no sistema MFOLHA da Mastermaq." pixel font oFont of oDlg
			@105,147 bmpbutton type 05 action Pergunte("MFUNC",.T.)
			@105,179 bmpbutton type 01 action Processa({|| ImpFuncionario(oDlg)},"","Aguarde processando...",lAborta)
			@105,211 bmpbutton type 02 action Close(oDlg)
	endcase
	
	activate msdialog oDlg centered
	
	Close(oJan)
return

static function ImpFuncao(oDlg)
	local cFunIni := ""
	local cFunFin := ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Funcao de                                         ³
	//³ mv_par02 - Funcao ate                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	if Empty(mv_par01) .and. Empty(mv_par02)
		MsgBox("Favor entrar nos parametros e configura-lo.","Alerta","ALERT")
		
		return
	endif
	
	cFunIni := mv_par01
	cFunFin := mv_par02
	
	DbUseArea(.T.,DBSetDriver("CTREECDX"),_TFCOES,"FCO",.T.,.T.)
	FCO->(DbSetIndex(_IFCOES))
	
	Processa({|| IncluirFuncao(cFunIni,cFunFin,.T.)},"","Aguarde processando...",lAborta)
	
	FCO->(DbCloseArea())
	Close(oDlg)
return

static function IncluirFuncao(cFunIni,cFunFin,lMsg)
	DbSelectArea("SRJ")
	SRJ->(DbSetOrder(5))
	
	if lMsg
		ProcRegua((Val(cFunFin) - Val(cFunIni)) + 1)
	endif
	
	if FCO->(DbSeek(cFunIni,.F.))
		while FCO->Funcao >= cFunIni .and. FCO->Funcao <= cFunFin
			SRJ->(DbGoTop())
			
			if lMsg
				IncProc()
				
				if SRJ->(DbSeek(xFilial("SRJ")+FCO->Funcao,.F.))
					RecLock("SRJ",.F.)
						SRJ->RJ_DESC := If(Empty(SRJ->RJ_DESC),FCO->Nome,SRJ->RJ_DESC)
						SRJ->RJ_CODCBO := If(Empty(SRJ->RJ_CODCBO),FCO->Cbo,SRJ->RJ_CODCBO)
						SRJ->RJ_CBO := If(Empty(SRJ->RH_CBO),FCO->Cbo_old,SRJ->RH_CBO)
						SRJ->RJ_MFOLHA := If(Empty(SRJ->RJ_MFOLHA),FCO->Funcao,SRJ->RJ_MFOLHA)
					MsUnLock()
				else
					RecLock("SRJ",.T.)
						SRJ->RJ_FILIAL := xFilial()
						SRJ->RJ_FUNCAO := GetSXENum("SRJ","RJ_FUNCAO")
						SRJ->RJ_DESC := FCO->Nome
						SRJ->RJ_CODCBO := FCO->Cbo
						SRJ->RJ_CBO := FCO->Cbo_old
						SRJ->RJ_MFOLHA := FCO->Funcao
					MsUnLock()
					ConfirmSX8()
				endif
			else
				if !SRJ->(DbSeek(xFilial("SRJ")+FCO->Funcao,.F.))
					RecLock("SRJ",.T.)
						SRJ->RJ_FILIAL := xFilial()
						SRJ->RJ_FUNCAO := GetSXENum("SRJ","RJ_FUNCAO")
						SRJ->RJ_DESC := FCO->Nome
						SRJ->RJ_CODCBO := FCO->Cbo
						SRJ->RJ_CBO := FCO->Cbo_old
						SRJ->RJ_MFOLHA := FCO->Funcao
					MsUnLock()
					ConfirmSX8()
				endif
				
				cCodFuncao := SRJ->RJ_FUNCAO
				cDesFuncao := SRJ->RJ_DESC
			endif
			
			FCO->(DbSkip())
		enddo
		
		if lMsg
			MsgInfo("Dados importado com sucesso!")
		endif
	endif
return

static function ImpFuncionario(oDlg)
	local lError := .T.
	local cMatIni := ""
	local cMatFin := ""
	
	private lMsErroAuto := .F.
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Parametros utilizados pelo programa                          ³
	//³ mv_par01 - Matricula de                                      ³
	//³ mv_par02 - Matricula ate                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	if Empty(mv_par01) .and. Empty(mv_par02)
		MsgBox("Favor entrar nos parametros e configura-lo.","Alerta","ALERT")
		
		return
	endif
	
	cMatIni := mv_par01
	cMatFin := mv_par02
	
	DbSelectArea("SRA")
	SRA->(DbSetOrder(27))
	
	DbUseArea(.T.,DBSetDriver(),If(cEmpAnt == _EMPDEF,_TATASAL,_TATFSAL),"SAL",.T.,.T.)
	SAL->(DbSetIndex(If(cEmpAnt == _EMPDEF,_IATASAL,_IATFSAL)))
	
	DbUseArea(.T.,DBSetDriver(),_TFCOES,"FCO",.T.,.T.)
	FCO->(DbSetIndex(_IFCOES))
	
	DbUseArea(.T.,DBSetDriver(),If(cEmpAnt == _EMPDEF,_TATAFUN,_TATFFUN),"FUN",.T.,.T.)
	FUN->(DbSetIndex(If(cEmpAnt == _EMPDEF,_IATAFUN,_IATFFUN)))
	
	ProcRegua((Val(cMatFin) - Val(cMatIni)) + 1)
	
	if FUN->(DbSeek(cMatIni,.F.))
		while FUN->Funcc >= cMatIni .and. FUN->Funcc <= cMatFin
			IncProc()
			
			if !Empty(FUN->Rescisao) ; FUN->(DbSkip()) ; loop ; endif
			
			SRA->(DbGoTop())
			SAL->(DbGoTop())
			
			IncluirFuncao(FUN->Funcao,FUN->Funcao,.F.)
			
			SRJ->(DbSetOrder(1))
			
			if SAL->(DbSeek(FUN->Funcc,.F.))
				cDataSal := SAL->Data
				nSalario := SAL->Valor
				
				while !SAL->(Eof()) .and. SAL->Funcc >= FUN->Funcc .and. SAL->Funcc <= FUN->Funcc
					if SAL->Data >= cDataSal
						cDataSal := SAL->Data
						nSalario := SAL->Valor
					endif
					
					SAL->(DbSkip())
				enddo
			endif
			
			cMat := StrZero(Val(FUN->Registro),6)
			cCpf := StrTran(StrTran(AllTrim(FUN->Cpf),".",""),"-","")
			cHabilitacao := StrTran(AllTrim(FUN->Carthabil),"-","")
			cTitEleitor := StrTran(AllTrim(FUN->Titeleit),"-","")
			
			do case
				case FUN->Tipo_adm == "1"
					cTipoAdm := "9A"
				case FUN->Tipo_adm == "2"
					cTipoAdm := "9B"
				otherwise
					cTipoAdm := ""
			endcase
			
			do case
				case FUN->Est_civil == "1"
					cEstCivil := "C"
				case FUN->Est_civil == "2"
					cEstCivil := "S"
				case FUN->Est_civil == "3"
					cEstCivil := "V"
				case FUN->Est_civil == "4"
					cEstCivil := "Q"
				case FUN->Est_civil == "5"
					cEstCivil := "D"
				otherwise
					cEstCivil := "M"
			endcase
			
			do case
				case FUN->Instrucao == "01"
					cInstrucao := "10"
				case FUN->Instrucao == "02"
					cInstrucao := "20"
				case FUN->Instrucao == "03"
					cInstrucao := "25"
				case FUN->Instrucao == "04"
					cInstrucao := "30"
				case FUN->Instrucao == "05"
					cInstrucao := "35"
				case FUN->Instrucao == "06"
					cInstrucao := "40"
				case FUN->Instrucao == "07"
					cInstrucao := "45"
				case FUN->Instrucao == "08"
					cInstrucao := "50"
				case FUN->Instrucao == "09"
					cInstrucao := "55"
				case FUN->Instrucao == "10"
					cInstrucao := "85"
				case FUN->Instrucao == "11"
					cInstrucao := "65"
				case FUN->Instrucao == "12"
					cInstrucao := "75"
				case FUN->Instrucao == "13"
					cInstrucao := "95"
				otherwise
					cInstrucao := ""
			endcase
			
			aVetor := {{"RA_FILIAL",xFilial("SRA"),nil},;
						{"RA_MAT",cMat,nil},;
						{"RA_NOME",FUN->Nome,nil},;
						{"RA_ENDEREC",FUN->Endereco,nil},;
						{"RA_BAIRRO",FUN->Bairro,nil},;
						{"RA_MUNICIP",If(Right(AllTrim(FUN->Cidade),10) == "FABRICIANO","CORONEL FABRICIANO",AllTrim(FUN->Cidade)),nil},;
						{"RA_ESTADO",FUN->Uf,nil},;
						{"RA_CEP",FUN->Cep,nil},;
						{"RA_TELEFON",FUN->Telefone,nil},;
						{"RA_PAI",FUN->Pai,nil},;
						{"RA_MAE",FUN->Mae,nil},;
						{"RA_SEXO",If(FUN->Sexo == "1","M","F"),nil},;
						{"RA_NASC",FUN->Nascimento,nil},;
						{"RA_CIC",cCpf,nil},;
						{"RA_PIS",FUN->Pis,nil},;
						{"RA_RG",FUN->Ci,nil},;
						{"RA_NUMCP",FUN->Carteira,nil},;
						{"RA_SERCP",FUN->Serie,nil},;
						{"RA_UFCP",FUN->Uf_cp,nil},;
						{"RA_HABILIT",cHabilitacao,nil},;
						{"RA_TITULOE",cTitEleitor,nil},;
						{"RA_ZONASEC",FUN->Zona+"/"+FUN->Secaoele,nil},;
						{"RA_REGISTR",FUN->Funcc,nil},;
						{"RA_NOMECMP",FUN->Nome_compl,nil},;
						{"RA_NATURAL",FUN->Uf_natural,nil},;
						{"RA_ADMISSA",FUN->Admissao,nil},;
						{"RA_HRSMES",FUN->Horas_mes,nil},;
						{"RA_HRSEMAN",FUN->Horas_sem,nil},;
						{"RA_CODFUNC",cCodFuncao,nil},;
						{"RA_DESCFUN",cDesFuncao,nil},;
						{"RA_BCDPFGT","0332290",nil},;
						{"RA_CTDPFGT","000000000000",nil},;
						{"RA_SALARIO",nSalario,nil},;
						{"RA_CRACHA",Left(cMat,6),nil},;
						{"RA_CHAPA",Right(cMat,5),nil},;
						{"RA_OPCAO",FUN->Admissao,nil},;
						{"RA_NACIONA",If(FUN->Nacional == "10","10",FUN->Nacional),nil},;
						{"RA_ESTCIVI",cEstCivil,nil},;
						{"RA_TIPOADM",cTipoAdm,nil},;
						{"RA_GRINRAI",cInstrucao,nil},;
						{"RA_TNOTRAB","001",nil},;
						{"RA_ADTPOSE","***N**",nil},;
						{"RA_ANOCHEG","00",nil},;
						{"RA_CATFUNC","H",nil},;
						{"RA_TIPOPGT","M",nil},;
						{"RA_TPMAIL","1",nil},;
						{"RA_MSBLQL","2",nil},;
						{"RA_PGCTSIN","P",nil},;
						{"RA_SINDICA","01",nil},;
						{"RA_DEFIFIS","2",nil},;
						{"RA_VIEMRAI","10",nil},;
						{"RA_CC","10101",nil},;
						{"RA_TPDEFFI","0",nil}}
			
			MsExecAuto({|x,y,k,w| GPEA010(x,y,k,w)},nil,nil,aVetor,If(SRA->(DbSeek(xFilial("SRA")+FUN->Funcc,.F.)),4,3))
			
			if lMsErroAuto
				MostraErro()
				
				lError := .T.
				lMsErroAuto := .F.
			endif
			
			FUN->(DbSkip())
		enddo
		
		if lError
			MsgInfo("Dados importado com sucesso! Favor atualizar alguns dados desse(s) funcionario(s).")
		else
			MsgBox("Alguns registros nao foram importados, conforme tela de error apresentada anteriormente.","Alert","ALERT")
		endif
	endif
	
	FUN->(DbCloseArea())
	FCO->(DbCloseArea())
	SAL->(DbCloseArea())
	SRA->(DbSetOrder(1))
	Close(oDlg)
return