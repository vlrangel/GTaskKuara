
codeunit 80109 "Restapi"
{
    var
        Client: HttpClient;
        RequestHeaders: HttpHeaders;
        RequestContent: HttpContent;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        ResponseText: Text;
        contentHeaders: HttpHeaders;
        MEDIA_TYPE: Label 'application/json';

    trigger OnRun()
    begin


    end;

    procedure RecuperarToken(Url: Text; Usuario: Text; password: Text; var Token: Text);
    var
        Pregunta: Text;
        JSONMgt: Codeunit "JSON Management";
        JsonObjt: Codeunit "Json Text Reader/Writer";
        Name: Text;
        Value1: Text;
        i: Integer;
        RequestType: Option Get,patch,put,post,delete;
        GeneralLedgerSetup: Record "General Ledger Setup";
        Dur: Duration;
        FechaToken: DateTime;
        Dura: Integer;
        bigInt: BigInteger;
    begin
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Fecha Token" <> 0DT Then begin
            Dur := (CurrentDateTime - GeneralLedgerSetup."Fecha Token");
            bigInt := Dur;
            Dura := bigInt DIV (60 * 60 * 1000);
            if Dura < 48 then begin
                Token := GeneralLedgerSetup.Token;
                FechaToken := GeneralLedgerSetup."Fecha Token";
                exit;
            end
        end;
        if Url = '' Then
            Url := GeneralLedgerSetup."Url Tareas";
        Url := Url + '/user/login';
        If Usuario = '' Then Usuario := GeneralLedgerSetup."Usuario Tareas";
        if password = '' then password := GeneralLedgerSetup."Password Tareas";
        Pregunta += '{"username":"' + Usuario + '","password":"' + password + '"}';
        RequestContent.WriteFrom(Pregunta);

        RequestContent.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json');

        Client.Post(URL, RequestContent, ResponseMessage);
        ResponseMessage.Content().ReadAs(Token);
        JSONMgt.InitializeObject(Token);
        JSONMgt.ReadProperties();
        WHILE JSONMgt.GetNextProperty(Name, Value1) DO BEGIN

            CASE Name OF
                'access_token':
                    BEGIN
                        Token := Value1;
                    end;
            end;
        end;
        FechaToken := CurrentDateTime;
        GeneralLedgerSetup.Token := Token;
        GeneralLedgerSetup."Fecha Token" := FechaToken;
        GeneralLedgerSetup.Modify();

    end;

    procedure RestApi(url: Text; RequestType: Option Get,patch,put,post,delete; payload: Text): Text
    var
        Ok: Boolean;
        Respuesta: Text;
    begin
        RequestHeaders := Client.DefaultRequestHeaders();
        //RequestHeaders.Add('Authorization', StrSubstNo('Bearer %1',token));

        case RequestType of
            RequestType::Get:
                Client.Get(URL, ResponseMessage);
            RequestType::patch:
                begin
                    RequestContent.WriteFrom(payload);

                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json-patch+json');

                    RequestMessage.Content := RequestContent;

                    RequestMessage.SetRequestUri(URL);
                    RequestMessage.Method := 'PATCH';

                    client.Send(RequestMessage, ResponseMessage);
                end;
            RequestType::post:
                begin
                    RequestContent.WriteFrom(payload);

                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json');

                    Client.Post(URL, RequestContent, ResponseMessage);
                end;
            RequestType::delete:
                Client.Delete(URL, ResponseMessage);
        end;

        ResponseMessage.Content().ReadAs(ResponseText);
        exit(ResponseText);

    end;

    procedure RestApiToken(url: Text; RequestType: Option Get,patch,put,post,delete; payload: Text): Text
    var
        Ok: Boolean;
        Respuesta: Text;
        Token: Text;
        GlSetup: Record "General Ledger Setup";
    begin
        GlSetup.Get();
        url := GlSetup."Url Tareas" + url;
        RecuperarToken('', '', '', Token);
        RequestHeaders := Client.DefaultRequestHeaders();
        RequestHeaders.Add('Authorization', StrSubstNo('Bearer %1', token));

        case RequestType of
            RequestType::Get:
                Client.Get(URL, ResponseMessage);
            RequestType::patch:
                begin
                    RequestContent.WriteFrom(payload);

                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json-patch+json');

                    RequestMessage.Content := RequestContent;

                    RequestMessage.SetRequestUri(URL);
                    RequestMessage.Method := 'PATCH';

                    client.Send(RequestMessage, ResponseMessage);
                end;
            RequestType::post:
                begin
                    RequestContent.WriteFrom(payload);

                    RequestContent.GetHeaders(contentHeaders);
                    contentHeaders.Clear();
                    contentHeaders.Add('Content-Type', 'application/json');

                    Client.Post(URL, RequestContent, ResponseMessage);
                end;
            RequestType::delete:
                Client.Delete(URL, ResponseMessage);
        end;

        ResponseMessage.Content().ReadAs(ResponseText);
        exit(ResponseText);

    end;

    /// <summary>
    /// Establecimiento.
    /// </summary>
    /// <param name="url">Text.</param>
    /// <returns>Return value of type Text.</returns>
    procedure Establecimiento(url: Text): Text
    var
        RestApi: Codeunit Restapi;
        Token: Text;
        GenSetup: Record "General Ledger Setup";
        RequestType: Option Get,patch,put,post,delete;
        Pregunta: Text;
        JSONMgt: Codeunit "JSON Management";
        JsonObjt: Codeunit "Json Text Reader/Writer";
        Name: Text;
        Value1: Text;
        i: Integer;
        a: Integer;
        Json: Text;
        Id: Text;
        Salir: Boolean;
        b: Integer;
    begin
        GenSetup.Get();
        RestApi.RecuperarToken(GenSetup."Url Tareas", GenSetup."Usuario Tareas", GenSetup."Password Tareas", GenSetup.Token);
        Token := GenSetup.Token;
        Json := RestApi.RestApiToken(url, RequestType::Get, '');
        JSONMgt.InitializeCollection(Json);
        a := JSONMgt.GetCollectionCount;
        Salir := false;
        If a = 0 Then Error('No se han encontrado %', url);
        WHILE i < a DO BEGIN
            JSONMgt.GetObjectFromCollectionByIndex(Json, i);
            JSONMgt.InitializeObject(Json);
            IF Json <> '' THEN BEGIN
                JSONMgt.InitializeObject(Json);
                JSONMgt.ReadProperties();
                WHILE JSONMgt.GetNextProperty(Name, Value1) DO BEGIN
                    CASE Name OF
                        '_id':
                            Id := Value1;
                        'username':
                            begin
                                if Value1 = GenSetup."Usuario Tareas" then Salir := true;
                                b := i;
                                i := a;
                            end;

                    end;
                end;
                i += 1;
            end;
        end;
        JSONMgt.GetObjectFromCollectionByIndex(Json, b);
        JSONMgt.InitializeObject(Json);
        IF Json <> '' THEN BEGIN
            JSONMgt.InitializeObject(Json);
            JSONMgt.ReadProperties();
            WHILE JSONMgt.GetNextProperty(Name, Value1) DO BEGIN
                CASE Name OF
                    'establishment':
                        exit(Value1);

                end;
            end;
        end;
        Exit('Error');

    end;
}
