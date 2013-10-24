/*______________________________________________________________________
   ¦Autor     ¦ Breno Ferreira                      ¦ Data ¦ 26/10/09 ¦
   +----------+-------------------------------------------------------¦
   ¦Descrição ¦ Divisão das parcelas do pedido de venda               ¦
   +----------+-------------------------------------------------------¦
   ¦          ¦ ao confirmar o pedido de venda                        ¦
  ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/

#include "rwmake.ch"

user function M410TIP9()
	local nLinini := 10
	
	private nTotalPed := nValPed
	private aVen := Array(9)
	private aVal := Array(9)
	private aDias := Array(9)
	private nParc := 0
	private cPrazo := Space(18)
	private oDlg
	private lOpc := .F.
	
	AFill(aVen,CToD(""))
	AFill(aVal,0)
	AFill(aDias,"")
	
	if (SE4->(DbSeek(xFilial("SE4")+M->C5_CONDPAG,.F.)))
		if SE4->E4_TIPO = "9"
			@010,010 to 360,266 dialog oDlg title "DIVISAO DAS PARCELAS"
				@005,020 to 020,110
				@nLinini,029 say "TOTAL Pedido: R$ "+Transf(nTotalPed,"@E 99,999.99")
				
				nLinini += 15
				@nLinini+2,010 say "Prazos"
				@nLinini,040 get cPrazo picture "@R 99-99-99-99-99-99-99-99-99" size 81,07 valid ChecaPrazo()
				
				nLinini += 15
				@nLinini,042 say "Vencimento"
				@nLinini,087 say "Valor"
				
				nLinini += 12
				@nLinini,010 say "1º Parcela"
				@nLinini-2,040 get aVen[1] size 30,07 when nParc >= 1
				@nLinini-2,075 get aVal[1] picture "@E 999,999,999.99" size 40,07 when nParc >= 1
				
				nLinini += 11
				@nLinini,010 say "2º Parcela"
				@nLinini-2,040 get aVen[2] size 30,07 when nParc >= 2
				@nLinini-2,075 get aVal[2] picture "@E 999,999,999.99" size 40,07 when nParc >= 2
				
				nLinini += 11
				@nLinini,010 say "3º Parcela"
				@nLinini-2,040 get aVen[3] size 30,07 when nParc >= 3
				@nLinini-2,075 get aVal[3] picture "@E 999,999,999.99" size 40,07 when nParc >= 3
				
				nLinini += 11
				@nLinini,010 say "4º Parcela"
				@nLinini-2,040 get aVen[4] size 30,07 when nParc >= 4
				@nLinini-2,075 get aVal[4] picture "@E 999,999,999.99" size 40,07 when nParc >= 4
				
				nLinini += 11
				@nLinini,010 say "5º Parcela"
				@nLinini-2,040 get aVen[5] size 30,07 when nParc >= 5
				@nLinini-2,075 get aVal[5] picture "@E 999,999,999.99" size 40,07 when nParc >= 5
				
				nLinini += 11
				@nLinini,010 say "6º Parcela"
				@nLinini-2,040 get aVen[6] size 30,07 when nParc >= 6
				@nLinini-2,075 get aVal[6] picture "@E 999,999,999.99" size 40,07 when nParc >= 6
				
				nLinini += 11
				@nLinini,010 say "7º Parcela"
				@nLinini-2,040 get aVen[7] size 30,07 when nParc >= 7
				@nLinini-2,075 get aVal[7] picture "@E 999,999,999.99" size 40,07 when nParc >= 7
				
				nLinini += 11
				@nLinini,010 say "8º Parcela"
				@nLinini-2,040 get aVen[8] size 30,07 when nParc >= 8
				@nLinini-2,075 get aVal[8] picture "@E 999,999,999.99" size 40,07 when nParc >= 8
				
				nLinini += 11
				@nLinini,010 say "9º Parcela"
				@nLinini-2,040 get aVen[9] size 30,07 when nParc >= 9
				@nLinini-2,075 get aVal[9] picture "@E 999,999,999.99" size 40,07 when nParc >= 9
				
				nLinini += 17
				@nLinini,061 bmpbutton type 01 action Gravar(aVal,aVen,aDias,nTotalPed)
				@nLinini,091 bmpbutton type 02 action Close(oDlg)
			activate dialog oDlg centered
			
			if lOpc ; return .T. ; return .F. ; endif
		else
			return .T.
		endif
	endif
return .F.

/* *** Função para gravar nas variáveis de memório as datas de vencimento e o valor das parcelas *** */
static function Gravar(v,d,di,t)
	local nSoma := 0
	local p := 0
	
	for nI := 1 to 9
		if !Empty(v[nI])
			p++
		endif
		
		nSoma += Round(v[nI],2)
	next
	
	if ChecaData(d,p) == .F.
		lOpc := .F.
	elseif ChecaValor(v,p) == .F.
		lOpc := .F.
	else
		if nSoma < t
			MsgBox("A soma das parcelas esta menor que o valor total do pedido, favor acertar os valores das parcelas!","Alerta","ALERT")
			lOpc := .F.
		elseif nSoma > t
			MsgBox("A soma das parcelas esta maior que o valor total do pedido, favor acertar os valores das parcelas!","Alerta","ALERT")
			lOpc := .F.
		else
			M->C5_PARC1 := v[1]
			M->C5_PARC2 := v[2]
			M->C5_PARC3 := v[3]
			M->C5_PARC4 := v[4]
			M->C5_PARC5 := v[5]
			M->C5_PARC6 := v[6]
			M->C5_PARC7 := v[7]
			M->C5_PARC8 := v[8]
			M->C5_PARC9 := v[9]
			
			M->C5_DATA1 := d[1]
			M->C5_DATA2 := d[2]
			M->C5_DATA3 := d[3]
			M->C5_DATA4 := d[4]
			M->C5_DATA5 := d[5]
			M->C5_DATA6 := d[6]
			M->C5_DATA7 := d[7]
			M->C5_DATA8 := d[8]
			M->C5_DATA9 := d[9]
			
			Close(oDlg)
			lOpc := .T.
		endif
	endif
return

/* *** Função para fazer a divisão do valor das parcelas e das datas de vencimento *** */
static function Dividir(v,dt,d,t,p)
	local nSoma := 0
	
	if p = 1
		dt[1] := Date() + Val(d[1])
		v[1] := t
	else
		for nI := 1 to p-1
			dt[nI] := Date() + Val(d[nI])
			v[nI] := Round(t / p,2)
			nSoma += v[nI]
		next
		
		dt[p] := Date() + Val(d[p])
		v[p] := t - nSoma
	endif
return

/* *** Função para validar a data de vencimento *** */
static function ChecaData(d,p)
	if p = 1
		if Empty(d[p])
			MsgBox("O vencimento da "+AllTrim(Str(p))+"º parcela tem que ser preenchida!","Alerta","ALERT")
			return .F.
		endif
		
		if DToS(d[p]) < DToS(Date())
			MsgBox("A data de vencimento da "+AllTrim(Str(p))+"º parcela nao pode ser menor que a data atual do sistema!","Alerta","ALERT")
			return .F.
		endif
	else
		for nI := 2 to p
			if Empty(d[p])
				if APMsgYesNo("Deseja concluir os lancamentos das parcelas?")
					Close(oDlg)
				else
					MsgBox("A data de vencimento da "+AllTrim(Str(p))+"º parcela nao pode ser vazia!","Alerta","ALERT")
					return .F.
				endif
			endif
			
			if DToS(d[p]) <= DToS(Date())
				MsgBox("A data de vencimento da "+AllTrim(Str(p))+"º parcela nao pode ser menor ou igual que a data atual!","Alerta","ALERT")
				return .F.
			endif
			
			if DToS(d[p]) <= DToS(d[p-1])
				MsgBox("A data de vencimento da "+AllTrim(Str(p))+"º parcela nao pode ser menor ou igual que a data da "+AllTrim(Str(p-1))+"º parcela!","Alerta","ALERT")
				return .F.
			endif
		next
	endif
return .T.

/* *** Função para validar o valor da parcela *** */
static function ChecaValor(v,p)
	for nI := 1 to p
		if v[p] = 0
			MsgBox("O valor da "+AllTrim(Str(p))+"º parcela tem que ser preenchida!","Alerta","ALERT")
			return .F.
		endif
		
		if v[p] < 0
			MsgBox("O valor da "+AllTrim(Str(p))+"º parcela nao pode ser negativa!","Alerta","ALERT")
			return .F.
		endif
	next
return .T.

/* *** Função para atribuir os prazos de pagamento na variável aDias *** */
static function SeparaDias(p,d)
	local x := 1
	
	for I := 1 to 9
		d[I] := SubStr(p,x,2)
		x += 2
	next
return

static function ChecaPrazo()
	AFill(aVen,CToD(""))
	AFill(aVal,0)
	AFill(aDias,"")
	nParc := 0
	
	if Empty(cPrazo)
		MsgBox("Tem que ser preechido pelo menos um prazo para essa venda!","Alerta","ALERT")
		return .F.
	endif
	
	SeparaDias(cPrazo,@aDias)
	
	for nI := 1 to 9
		if !Empty(Val(aDias[nI])) .or. aDias[nI] == "00"
			nParc++
		endif
	next
	
	for nI := 1 to nParc
		if Empty(Val(aDias[nI]))
			MsgBox("O prazo nao pode ser zero e nem vazio!","Alerta","ALERT")
			return .F.
		endif
		
		if nI < nParc
			if Val(aDias[nI+1]) < Val(aDias[nI])
				MsgBox("O "+AllTrim(Str((nI+1)))+"º prazo nao pode ser menor que o "+AllTrim(Str(nI))+"º prazo!","Alerta","ALERT")
				return .F.
			endif
		endif
	next
	
	Dividir(aVal,aVen,aDias,nTotalPed,nParc)
return .T.