unit UPedidoRepositoryImpl;

interface

uses
  UPedidoRepositoryIntf, UPizzaTamanhoEnum, UPizzaSaborEnum, UDBConnectionIntf, FireDAC.Comp.Client;

type
  TPedidoRepository = class(TInterfacedObject, IPedidoRepository)
  private
    FDBConnection: IDBConnection;
    FFDQuery: TFDQuery;
  public
    procedure efetuarPedido(const APizzaTamanho: TPizzaTamanhoEnum; const APizzaSabor: TPizzaSaborEnum; const AValorPedido: Currency;
      const ATempoPreparo: Integer; const ACodigoCliente: Integer);

    procedure consultarPedido(const ADocumentoCliente: String; out AFDQuery: TFDQuery );
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

implementation

uses
  UDBConnectionImpl, System.SysUtils, Data.DB, FireDAC.Stan.Param;

const
  CMD_INSERT_PEDIDO
    : String =
    'INSERT INTO tb_pedido (cd_cliente, dt_pedido, dt_entrega, vl_pedido, ' +
    'nr_tempopedido, sabor_pizza, tamanho_pizza) VALUES (:pCodigoCliente, ' +
    ' :pDataPedido, :pDataEntrega, :pValorPedido, :pTempoPedido, :pSaborPizza, ' +
    ':pTamanhoPizza)';

const
  CMD_CONSULTA_PEDIDO
    : String =
    'SELECT tamanho_pizza, sabor_pizza,'+
    'vl_pedido, nr_tempopedido from tb_pedido ped inner join  tb_cliente cli '+
    'on (ped.cd_cliente = cli.id) where cli.nr_documento = :pdocumentoCliente '+
    'order by cli.id desc limit 1';
  { TPedidoRepository }

procedure TPedidoRepository.consultarPedido(const ADocumentoCliente: String;
  out AFDQuery: TFDQuery);
begin
  AFDQuery.Connection := FDBConnection.getDefaultConnection;
  AFDQuery.SQL.Text   := CMD_CONSULTA_PEDIDO;

  AFDQuery.ParamByName('pdocumentoCliente').AsString := ADocumentoCliente;
  AFDQuery.Prepare;
  AFDQuery.Open;
end;

constructor TPedidoRepository.Create;
begin
  inherited;

  FDBConnection := TDBConnection.Create;
  FFDQuery := TFDQuery.Create(nil);
  FFDQuery.Connection := FDBConnection.getDefaultConnection;
end;

destructor TPedidoRepository.Destroy;
begin
  FFDQuery.Free;
  inherited;
end;

procedure TPedidoRepository.efetuarPedido(const APizzaTamanho: TPizzaTamanhoEnum; const APizzaSabor: TPizzaSaborEnum; const AValorPedido: Currency;
  const ATempoPreparo: Integer; const ACodigoCliente: Integer);
var
  pizzaTamanho, pizzaSabor : string;
begin
  case APizzaTamanho of
    enPequena:
      pizzaTamanho := 'enPequena';
    enMedia:
      pizzaTamanho := 'enMedia';
    enGrande:
      pizzaTamanho := 'enGrande';
  end;

  case APizzaSabor of
    enCalabresa:
      pizzaSabor := 'enCalabresa';
    enMarguerita:
      pizzaSabor := 'enMarguerita';
    enPortuguesa:
      pizzaSabor := 'enPortuguesa';
  end;

  FFDQuery.SQL.Text := CMD_INSERT_PEDIDO;

  FFDQuery.ParamByName('pCodigoCliente').AsInteger  := ACodigoCliente;
  FFDQuery.ParamByName('pDataPedido').AsDateTime    := now();
  FFDQuery.ParamByName('pDataEntrega').AsDateTime   := now();
  FFDQuery.ParamByName('pValorPedido').AsCurrency   := AValorPedido;
  FFDQuery.ParamByName('pTempoPedido').AsInteger    := ATempoPreparo;
  FFDQuery.ParamByName('pSaborPizza').AsString      := pizzaSabor;
  FFDQuery.ParamByName('pTamanhoPizza').AsString    := pizzaTamanho;

  FFDQuery.Prepare;
  FFDQuery.ExecSQL();
end;


end.
