(*
  Copyright 2016, MARS-Curiosity library

  Home: https://github.com/andrea-magni/MARS
*)
unit MARS.Client.Client.Net;

{$I MARS.inc}

interface

uses
  SysUtils, Classes
  , MARS.Core.JSON, MARS.Client.Utils, MARS.Client.Client

  // Net
, System.Net.URLClient, System.Net.HttpClient, System.Net.HttpClientComponent
  ;

type
  {$ifdef DelphiXE2_UP}
    [ComponentPlatformsAttribute(
        pidWin32 or pidWin64
     or pidOSX32
     or pidiOSSimulator
     or pidiOSDevice
    {$ifdef DelphiXE8_UP}
     or pidiOSDevice32 or pidiOSDevice64
    {$endif}
     or pidAndroid)]
  {$endif}
  TMARSNetClient = class(TMARSCustomClient)
  private
    FHttpClient: TNetHTTPClient;
    FLastResponse: IHTTPResponse;
  protected
    procedure AssignTo(Dest: TPersistent); override;
//    function GetProtocolVersion: TIdHTTPProtocolVersion;
//    procedure SetProtocolVersion(const Value: TIdHTTPProtocolVersion);

    function GetConnectTimeout: Integer; override;
    function GetReadTimeout: Integer; override;
    procedure SetConnectTimeout(const Value: Integer); override;
    procedure SetReadTimeout(const Value: Integer); override;

    procedure EndorseAuthorization(const AAuthToken: string); override;
    procedure CheckLastCmdSuccess; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Delete(const AURL: string; AContent, AResponse: TStream; const AAuthToken: string); override;
    procedure Get(const AURL: string; AResponseContent: TStream; const AAccept: string; const AAuthToken: string); override;
    procedure Post(const AURL: string; AContent, AResponse: TStream; const AAuthToken: string); override;
    procedure Put(const AURL: string; AContent, AResponse: TStream; const AAuthToken: string); override;

    function LastCmdSuccess: Boolean; override;
    function ResponseText: string; override;
  published
//    property ProtocolVersion: TIdHTTPProtocolVersion read GetProtocolVersion write SetProtocolVersion;
    property HttpClient: TNetHTTPClient read FHttpClient;
  end;

procedure Register;

implementation

uses
    Rtti, TypInfo
  , MARS.Client.CustomResource
  , MARS.Client.Resource
  , MARS.Client.Resource.JSON
  , MARS.Client.Resource.Stream
  , MARS.Client.Application
;

procedure Register;
begin
  RegisterComponents('MARS-Curiosity Client', [TMARSNetClient]);
end;

{ TMARSNetClient }

procedure TMARSNetClient.AssignTo(Dest: TPersistent);
var
  LDestClient: TMARSNetClient;
begin
  inherited;
  if Dest is TMARSNetClient then
  begin
    LDestClient := Dest as TMARSNetClient;
//    LDestClient.ProtocolVersion := ProtocolVersion;
    LDestClient.AuthEndorsement := AuthEndorsement;
//    LDestClient.HttpClient.IOHandler := HttpClient.IOHandler;
    LDestClient.HttpClient.AllowCookies := HttpClient.AllowCookies;
//    LDestClient.HttpClient.ProxyParams.BasicAuthentication := HttpClient.ProxyParams.BasicAuthentication;
//    LDestClient.HttpClient.ProxyParams.ProxyPort := HttpClient.ProxyParams.ProxyPort;
//    LDestClient.HttpClient.ProxyParams.ProxyServer := HttpClient.ProxyParams.ProxyServer;
//    LDestClient.HttpClient.Request.BasicAuthentication := HttpClient.Request.BasicAuthentication;
//    LDestClient.HttpClient.Request.Host := HttpClient.Request.Host;
//    LDestClient.HttpClient.Request.Password := HttpClient.Request.Password;
//    LDestClient.HttpClient.Request.Username := HttpClient.Request.Username;
  end;
end;

procedure TMARSNetClient.CheckLastCmdSuccess;
begin
  if not Assigned(FLastResponse) then
    Exit;

  if not LastCmdSuccess then
    raise EMARSClientHttpException.Create(FLastResponse.StatusText, FLastResponse.StatusCode);
end;

constructor TMARSNetClient.Create(AOwner: TComponent);
begin
  inherited;

  FHttpClient := TNetHTTPClient.Create(Self);
  try
    FHttpClient.SetSubComponent(True);
    FHttpClient.Name := 'HttpClient';
  except
    FHttpClient.Free;
    raise;
  end;
end;


procedure TMARSNetClient.Delete(const AURL: string; AContent, AResponse: TStream; const AAuthToken: string);
begin
  inherited;

  FLastResponse := FHttpClient.Delete(AURL, AResponse);
  CheckLastCmdSuccess;
end;

destructor TMARSNetClient.Destroy;
begin
  FHttpClient.Free;
  inherited;
end;

procedure TMARSNetClient.EndorseAuthorization(const AAuthToken: string);
begin
  if AuthEndorsement = AuthorizationBearer then
  begin
    if not (AAuthToken = '') then
      FHttpClient.CustomHeaders['Authorization'] := 'Bearer ' + AAuthToken
    else
      FHttpClient.CustomHeaders['Authorization'] := '';
  end;
end;

procedure TMARSNetClient.Get(const AURL: string; AResponseContent: TStream;
  const AAccept: string; const AAuthToken: string);
begin
  FHttpClient.Accept := AAccept;
  inherited;
  FLastResponse := FHttpClient.Get(AURL, AResponseContent);
  CheckLastCmdSuccess;
end;

function TMARSNetClient.GetConnectTimeout: Integer;
begin
  Result := FHttpClient.ConnectionTimeout;
end;

function TMARSNetClient.GetReadTimeout: Integer;
begin
  Result := FHttpClient.ResponseTimeout;
end;

function TMARSNetClient.LastCmdSuccess: Boolean;
begin
  Result := FLastResponse.StatusCode = 200;
end;

procedure TMARSNetClient.Post(const AURL: string; AContent, AResponse: TStream; const AAuthToken: string);
begin
  inherited;
  AContent.Position := 0;
  FLastResponse := FHttpClient.Post(AURL, AContent, AResponse);
  CheckLastCmdSuccess;
end;

procedure TMARSNetClient.Put(const AURL: string; AContent, AResponse: TStream; const AAuthToken: string);
begin
  inherited;
  AContent.Position := 0;
  FLastResponse := FHttpClient.Put(AURL, AContent, AResponse);
  CheckLastCmdSuccess;
end;

function TMARSNetClient.ResponseText: string;
begin
  Result := FLastResponse.StatusText;
end;

procedure TMARSNetClient.SetConnectTimeout(const Value: Integer);
begin
  FHttpClient.ConnectionTimeout := Value;
end;

//procedure TMARSNetClient.SetProtocolVersion(const Value: TIdHTTPProtocolVersion);
//begin
//  FHttpClient.ProtocolVersion := Value;
//end;

procedure TMARSNetClient.SetReadTimeout(const Value: Integer);
begin
  FHttpClient.ResponseTimeout := Value;
end;

//function TMARSNetClient.GetProtocolVersion: TIdHTTPProtocolVersion;
//begin
//  Result := FHttpClient.ProtocolVersion;
//end;

end.