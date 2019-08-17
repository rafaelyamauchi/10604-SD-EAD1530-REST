unit UPizzariaControllerImpl;

interface

{$I dmvcframework.inc}

uses MVCFramework,
  MVCFramework.Logger,
  MVCFramework.Commons,
  Web.HTTPApp, UPizzaTamanhoEnum, UPizzaSaborEnum, UEfetuarPedidoDTOImpl;

type

  [MVCDoc('Pizzaria backend')]
  [MVCPath('/')]
  TPizzariaBackendController = class(TMVCController)
  public

    [MVCDoc('Criar novo pedido "201: Created"')]
    [MVCPath('/efetuarPedido')]
    [MVCHTTPMethod([httpPOST])]
    procedure efetuarPedido(const AContext: TWebContext);

    [MVCDoc('Criar novo pedido "200: Success"')]
    [MVCPath('/consultarPedido')]
    [MVCHTTPMethod([httpGet])]
    procedure consultarPedido(const AContext: TWebContext);
  end;

implementation

uses
  System.SysUtils,
  Rest.json,
  MVCFramework.SystemJSONUtils,
  UPedidoServiceIntf,
  UPedidoServiceImpl, UPedidoRetornoDTOImpl;

{ TApp1MainController }

procedure TPizzariaBackendController.consultarPedido(
  const AContext: TWebContext);
var
  oPedidoRetornoDTO: TPedidoRetornoDTO;
  oBody : string;
begin
  oBody := AContext.Request.QueryStringParam('DocumentoCliente');

    with TPedidoService.Create do
    try
      oPedidoRetornoDTO := consultarPedido(oBody);
      Render(TJson.ObjectToJsonString(oPedidoRetornoDTO));
    finally
      oPedidoRetornoDTO.Free
    end;
  Log.Info('==>Executou o m�todo ', 'consultarPedido');

end;

procedure TPizzariaBackendController.efetuarPedido(const AContext: TWebContext);
var
  oEfetuarPedidoDTO: TEfetuarPedidoDTO;
  oPedidoRetornoDTO: TPedidoRetornoDTO;
  requestStr : string;
begin
  requestStr        := AContext.Request.Body;
  oEfetuarPedidoDTO := TJson.JsonToObject<TEfetuarPedidoDTO>(requestStr);
  try
    with TPedidoService.Create do
    try
      oPedidoRetornoDTO := efetuarPedido(oEfetuarPedidoDTO.PizzaTamanho,
      oEfetuarPedidoDTO.PizzaSabor,
      oEfetuarPedidoDTO.DocumentoCliente);
      Render(TJson.ObjectToJsonString(oPedidoRetornoDTO));
    finally
      oPedidoRetornoDTO.Free
    end;
  finally
    oEfetuarPedidoDTO.Free;
  end;
  Log.Info('==>Executou o m�todo ', 'efetuarPedido');
end;

end.
