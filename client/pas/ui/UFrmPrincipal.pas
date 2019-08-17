unit UFrmPrincipal;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edtDocumentoCliente: TLabeledEdit;
    cmbTamanhoPizza: TComboBox;
    cmbSaborPizza: TComboBox;
    Button1: TButton;
    mmRetornoWebService: TMemo;
    edtEnderecoBackend: TLabeledEdit;
    edtPortaBackend: TLabeledEdit;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

uses
  Rest.JSON,
  MVCFramework.RESTClient,
  UEfetuarPedidoDTOImpl,
  System.Rtti,
  UPizzaSaborEnum,
  UPizzaTamanhoEnum,
  UPedidoRetornoDTOImpl;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  Clt: TRestClient;
  oEfetuarPedido: TEfetuarPedidoDTO;
begin
  Clt := MVCFramework.RESTClient.TRestClient.Create(edtEnderecoBackend.Text,
    StrToIntDef(edtPortaBackend.Text, 80), nil);
  try
    oEfetuarPedido := TEfetuarPedidoDTO.Create;
    try
      oEfetuarPedido.PizzaTamanho :=
        TRttiEnumerationType.GetValue<TPizzaTamanhoEnum>(cmbTamanhoPizza.Text);
      oEfetuarPedido.PizzaSabor :=
        TRttiEnumerationType.GetValue<TPizzaSaborEnum>(cmbSaborPizza.Text);
      oEfetuarPedido.DocumentoCliente := edtDocumentoCliente.Text;
      mmRetornoWebService.Text := Clt.doPOST('/efetuarPedido', [],
        TJson.ObjecttoJsonString(oEfetuarPedido)).BodyAsString;
    finally
      oEfetuarPedido.Free;
    end;
  finally
    Clt.Free;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  Clt: TRestClient;
  retorno : TPedidoRetornoDTO;
  Response: IRESTResponse;
  tamanhoPizza, saborPizza : string;
begin
  Clt := MVCFramework.RESTClient.TRestClient.Create(edtEnderecoBackend.Text,
    StrToIntDef(edtPortaBackend.Text, 80), nil);
  try
    try
      mmRetornoWebService.Lines.Clear;
      Clt.QueryStringParams.Add('DocumentoCliente=' + edtDocumentoCliente.Text);
      Response := Clt.doGET('/consultarPedido', []);
      retorno := TJson.JsonToObject<TPedidoRetornoDTO>(Response.BodyAsString);

      mmRetornoWebService.Lines.Add('Resumo do pedido');
      case retorno.PizzaTamanho of
        enPequena : tamanhoPizza := 'Pequena';
        enMedia   : tamanhoPizza := 'Media';
        enGrande  : tamanhoPizza := 'Grande';
      end;
      case retorno.PizzaSabor of
        enCalabresa  : saborPizza := 'Calabresa';
        enMarguerita : saborPizza := 'Marguerita';
        enPortuguesa : saborPizza := 'Portuguesa';
      end;
      mmRetornoWebService.Lines.Add('Pizza : '+tamanhoPizza +' '+saborPizza+' '+
      formatfloat('R$ #.#0', retorno.ValorTotalPedido));
      mmRetornoWebService.Lines.Add('Tempo: '+Format('%d', [retorno.TempoPreparo])+ ' minutos');
      mmRetornoWebService.Lines.Add('Valor total pedido: '+
      formatfloat('R$ #.#0', retorno.ValorTotalPedido));


      //mmRetornoWebService.Text := Response.BodyAsString;
    finally
    end;
  finally
    Clt.Free;
  end;
end;

end.
