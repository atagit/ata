/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 10/09/10 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Parametro fechar mes fiscal                           ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/
#include "rwmake.ch"
#include "protheus.ch"

user function GETMVFIS()
	local nLinini := 10
	
	private dDataFis := GetMv("MV_DATAFIS")
	private dDataFisMv := GetMv("MV_DATAFIS")
	
	define msdialog oDlg from 000,000 to 190,430 pixel title "PARAMETROS"
		@005,005 to 035,210 of oDlg pixel
		@010,010 say "Data Fiscal" of oDlg pixel
		oGet := TGet():New(008,040,{|u| If(PCount() > 0,dDataFis := u,dDataFis)},oDlg,050,010,"@!",,,,,,,.T.,,,,,,,,,,"dDataFis")
		@025,010 say "Ultima data de encerramento de operacoes fiscais" of oDlg pixel
		
		oButton := TButton():New(080,145,"Salvar",oDlg,{|| Gravar()},030,010,,,,.T.)
		oButton := TButton():New(080,180,"Cancelar",oDlg,{|| oDlg:End()},030,010,,,,.T.)
	activate msdialog oDlg center
return

static function Gravar()
	if dDataFis < dDataFisMv
		MsgAlert("Nao pode regredir a data do parametro, favor informar ao setor de TI.")
	else
		PutMv("MV_DATAFIS",dDataFis)
	endif
	
	oDlg:End()
return