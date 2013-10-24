/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 11/02/10 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Após gravação da NF's de saída                        ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

#include "rwmake.ch"
#include "protheus.ch"

user function M460FIM()
	local cPlaca := Space(9)
	local cUfPlaca := Space(2)
	local nQuant := 0
	local cEspecie := Space(2)
	local nPesoLiq := 0
	
	private oDlg
	private dSaida := CToD("")
	
	cPlaca := SC5->C5_PLACA
	cUfPlaca := SC5->C5_UFPLACA
	nQuant := SC5->C5_VOLUME1
	cEspecie := SC5->C5_ESPECI1
	nPesoLiq := SC5->C5_PESOL
	
	define msdialog oDlg title "TRANSPORTADORA / VOLUMES" from U_C(178),U_C(181) to U_C(370),U_C(569) pixel
		@U_C(005),U_C(004) to U_C(027),U_C(193) label " Data " pixel of oDlg
		@U_C(016),U_C(007) say "Data Saida" size U_C(030),U_C(008) pixel of oDlg
		@U_C(014),U_C(031) msget oGet6 var dSaida size U_C(018),U_C(009) pixel of oDlg
		
		@U_C(030),U_C(004) to U_C(052),U_C(193) label " Transportadora " pixel of oDlg
		@U_C(041),U_C(007) say "Placa" size U_C(018),U_C(008) pixel of oDlg
		@U_C(039),U_C(020) msget oGet1 var cPlaca size U_C(029),U_C(009) picture "@! AAA9999" when Empty(SC5->C5_PLACA) pixel of oDlg
		@U_C(041),U_C(053) say "UF" size U_C(018),U_C(008) pixel of oDlg
		@U_C(039),U_C(060) msget oGet2 var cUfPlaca F3 "12" size U_C(014),U_C(009) picture "@! AA" when Empty(SC5->C5_UFPLACA) pixel of oDlg
		
		@U_C(055),U_C(004) to U_C(077),U_C(193) label " Volume " pixel of oDlg
		@U_C(066),U_C(007) say "Quantidade" size U_C(030),U_C(008) pixel of oDlg
		@U_C(064),U_C(031) msget oGet3 var nQuant size U_C(044),U_C(009) picture "@E 999,999,999.99" when Empty(SC5->C5_VOLUME1) pixel of oDlg
		@U_C(066),U_C(079) say "Especie" size U_C(024),U_C(008) pixel of oDlg
		@U_C(064),U_C(098) msget oGet4 var cEspecie F3 "SAH" size U_C(014),U_C(009) picture "@! AA" when Empty(SC5->C5_ESPECI1) pixel of oDlg
		@U_C(066),U_C(118) say "Peso Liquido" size U_C(037),U_C(008) pixel of oDlg
		@U_C(064),U_C(145) msget oGet5 var nPesoLiq size U_C(046),U_C(009) picture "@E 999,999,999.999" when Empty(SC5->C5_PESOL) pixel of oDlg
		
		@U_C(082),U_C(145) bmpbutton type 01 action GravPlaca(cPlaca,cUfPlaca,nQuant,cEspecie,nPesoLiq)
		@U_C(082),U_C(170) bmpbutton type 02 action Fechar()
	activate msdialog oDlg centered
return

static function GravPlaca(cPlaca,cUfPlaca,nQuant,cEspecie,nPesoLiq)
	DbSelectArea("SC5")
	
	NFServico()
	
	if !Empty(dSaida)
		if DbSeek(xFilial("SC5")+SC5->C5_NUM,.F.)
			if SF2->(DbSeek(xFilial("SF2")+SC5->C5_NOTA+SC5->C5_SERIE+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.))
				RecLock("SF2",.F.)
					SF2->F2_SAIDA := dSaida
				MsUnLock()
			endif
		endif
	endif
	
//	if !Empty(cPlaca) .and. !Empty(cUfPlaca) .and. !Empty(nQuant) .and. !Empty(cEspecie) .and. !Empty(nPesoLiq)
//		if Empty(cPlaca) .and. Empty(cUfPlaca) .and. Empty(nQuant) .and. Empty(cEspecie) .and. Empty(nPesoLiq)
//			MsgBox("Os campos não foram preenchidos!","Alerta","ALERT")
//		elseif Empty(cPlaca) .or. Empty(cUfPlaca)
//			MsgBox("Os 2 (dois) campos da TRANSPORTADORA tem que ser preenchidos!","Alerta","ALERT")
//		elseif Empty(nQuant) .or. Empty(cEspecie) .or. Empty(nPesoLiq)
//			MsgBox("Os 3 (três) campos do VOLUME tem que ser preenchidos!","Alerta","ALERT")
//		else
//			if DbSeek(xFilial("SC5")+SC5->C5_NUM,.F.)
//				RecLock("SC5",.F.)
//					SC5->C5_PLACA := If(Empty(SC5->C5_PLACA),cPlaca,SC5->C5_PLACA)
//					SC5->C5_UFPLACA := If(Empty(SC5->C5_UFPLACA),cUfPlaca,SC5->C5_UFPLACA)
//					SC5->C5_VOLUME1 := If(Empty(SC5->C5_VOLUME1),nQuant,SC5->C5_VOLUME1)
//					SC5->C5_ESPECI1 := If(Empty(SC5->C5_ESPECI1),cEspecie,SC5->C5_ESPECI1)
//					SC5->C5_PESOL := If(Empty(SC5->C5_PESOL),nPesoLiq,SC5->C5_PESOL)
//				MsUnLock()
//			else
//				MsgBox("Nao foi possivel gravar os dados!","Alerta","ALERT")
//			endif
			
//			Close(oDlg)
//		endif
//	else
		Close(oDlg)
//	endif
return

static function Fechar()
	NFServico()
	Close(oDlg)
return

static function NFServico()
	if AllTrim(SC5->C5_SERIE) == "A" .or. AllTrim(SC5->C5_SERIE) == "A1"
		if SF2->(DbSeek(xFilial("SF2")+SC5->C5_NOTA+SC5->C5_SERIE+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.))
			RecLock("SF2",.F.)
				SF2->F2_ESPECIE := "NFPS"
			MsUnLock()
		endif
	endif
return