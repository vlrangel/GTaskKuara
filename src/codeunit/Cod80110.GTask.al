/// <summary>
/// Codeunit GTask (ID 80110).
/// </summary>
codeunit 80110 GTask
{
    trigger OnRun()
    begin

    end;

    procedure GetMaestro(Maestro: Text; Descripcion: Text; Campo: Text; var wRecordRef: RecordRef; Tabla: Integer): Text
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
        Link: Record "Data Migration Error";
        IdLink: Integer;
    begin
        Link.SetRange("Source Staging Table Record ID", wRecordRef.RecordId);
        Link.SetRange("Destination Table ID", Tabla);
        if Link.FindFirst() Then exit(Link."Migration Type");
        GenSetup.Get();
        RestApi.RecuperarToken(GenSetup."Url Tareas", GenSetup."Usuario Tareas", GenSetup."Password Tareas", GenSetup.Token);
        Token := GenSetup.Token;
        Json := RestApi.RestApiToken('/' + Maestro, RequestType::Get, '');
        JSONMgt.InitializeCollection(Json);
        a := JSONMgt.GetCollectionCount;
        If a = 0 Then exit('Error');
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
                        campo:
                            begin
                                if Value1 = Descripcion then begin
                                    If InsertLink(wRecordRef.RecordId, Tabla, Id) then
                                        exit(Id);
                                end;
                            end;
                        'username':
                            begin
                                if Value1 = Descripcion then begin
                                    if InsertLink(wRecordRef.RecordId, Tabla, Id) then
                                        exit(Id)
                                end;
                            end;
                    end;
                end;
            end;
            i += 1;
        end;
        Exit('Error');
    end;

    procedure GetNombreMaestro(Maestro: Text; Id: Text; Campo: Text; Tabla: Integer; NCampo: Integer; var tRecorId: RecordId): Boolean
    var
        Link: Record "Data Migration Error";
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
        b: Integer;
        RecordIDT: RecordId;
        RecordRefT: RecordRef;
        FieldRefT: FieldRef;
    begin
        Link.SetRange("Destination table Id", Tabla);
        Link.SetRange("Migration Type", Id);
        If Link.FindFirst() then begin
            tRecorId := Link."Source Staging Table Record ID";
            exit(true);
        end;
        b := -1;
        GenSetup.Get();
        RestApi.RecuperarToken(GenSetup."Url Tareas", GenSetup."Usuario Tareas", GenSetup."Password Tareas", GenSetup.Token);
        Token := GenSetup.Token;
        Json := RestApi.RestApiToken('/' + Maestro, RequestType::Get, '');
        JSONMgt.InitializeCollection(Json);
        a := JSONMgt.GetCollectionCount;

        If a = 0 Then exit(false);
        WHILE i < a DO BEGIN
            JSONMgt.GetObjectFromCollectionByIndex(Json, i);
            JSONMgt.InitializeObject(Json);
            IF Json <> '' THEN BEGIN
                JSONMgt.InitializeObject(Json);
                JSONMgt.ReadProperties();
                WHILE JSONMgt.GetNextProperty(Name, Value1) DO BEGIN
                    CASE Name OF
                        '_id':
                            if Id = Value1 then begin
                                b := i;
                                i := a;
                            end;

                    end;
                end;
            end;
            i += 1;
        end;
        if b = -1 then exit(false);
        JSONMgt.GetObjectFromCollectionByIndex(Json, b);
        JSONMgt.InitializeObject(Json);
        IF Json <> '' THEN BEGIN
            JSONMgt.InitializeObject(Json);
            JSONMgt.ReadProperties();
            WHILE JSONMgt.GetNextProperty(Name, Value1) DO BEGIN
                CASE Name OF
                    campo:
                        begin
                            RecordRefT.Open(Tabla, false, CompanyName);
                            FieldRefT := RecordRefT.Field(NCampo);
                            FieldRefT.SetRange(Value1);
                            If RecordRefT.FindFirst() then begin
                                tRecorId := RecordRefT.RecordId;
                                Exit(not InsertLink(tRecorId, Tabla, Id));

                            end else
                                exit(false);
                        end;
                end;
            end;
        end;
        Exit(false);
    end;

    procedure CrearTarea(var ProductoServicio: Record Resource; Tarea: Record "User Task")
    var
        JsoonFormater: Codeunit "Json Text Reader/Writer";
        RestApi: Codeunit Restapi;
        GenSetup: Record "General Ledger Setup";
        RequestType: Option Get,patch,put,post,delete;
        Pregunta: Text;
        JSONMgt: Codeunit "JSON Management";
        JsonFormater: Codeunit "Json Text Reader/Writer";
        jSon: Text;
        departament: Text;
        service: Text;
        category: Text;
        usuario: Text;
        GlSetup: Record "General Ledger Setup";
        supervisor: Text;
        User: Record User;
        Name: Text;
        Value1: Text;
        Id: Text;
        a: Integer;
        i: Integer;
        Desde: Date;
        Hasta: Date;
        Dias: Integer;
        Url: Text;
        link: Text;
        Company: Record "Company Information";
        TipoIncidencia: Record "User Task Group";
        wRecordRef: RecordRef;
        Recurso: Record Resource;
    begin
        GlSetup.Get();
        Company.Get;
        wRecordRef.Open(Database::"Company Information", false, CompanyName);
        wRecordRef.Get(Company.RecordId);
        departament := GetMaestro('department', 'Sat', 'name', wRecordRef, Database::"Company Information");
        If departament = 'Error' then begin
            CreaDepartamento('Sat', Company.RecordId, Database::Company);
            departament := GetMaestro('department', 'Sat', 'name', wRecordRef, Database::"Company Information");
        end;
        wRecordRef.Close();
        wRecordRef.Open(Database::Resource, false, CompanyName);
        wRecordRef.Get(ProductoServicio.RecordId);
        service := GetMaestro('service', ProductoServicio.Name, 'name', wRecordRef, Database::Resource);
        if service = 'Error' then begin
            CreaServicio(ProductoServicio, ProductoServicio.RecordId, Database::Resource);
            service := GetMaestro('service', ProductoServicio.Name, 'name', wRecordRef, Database::Resource);
        end;
        if not TipoIncidencia.Get('INTERVENCION') then begin
            TipoIncidencia.Init();
            TipoIncidencia."Code" := 'INTERVENCION';
            TipoIncidencia."Description" := 'Intervencion';
            TipoIncidencia.Insert();
            Commit();
        end;
        wRecordRef.Close();
        wRecordRef.Open(Database::"User Task Group", false, CompanyName);
        wRecordRef.Get(TipoIncidencia.RecordId);
        category := GetMaestro('category', 'Navision', 'name', wRecordRef, Database::"User Task Group");
        if category = 'Error' then begin
            CreaCategoria('Intervencion', TipoIncidencia.RecordId, Database::"User Task Group");
            category := GetMaestro('category', 'Intervencion', 'name', wRecordRef, Database::"User Task Group");
        end;
        wRecordRef.Close();
        Tarea.CalcFields("Assigned To User Name");
        User.Get(Tarea."Assigned To");
        if not Recurso.Get(User."Full Name") then begin
            Recurso.Init();
            Recurso."No." := User."Full Name";
            Recurso.Type := Recurso.Type::Person;
            Recurso.Name := User."Full Name";
            Recurso.Insert();
            Commit();
            CreaRecurso(Recurso, Recurso.RecordId, Database::Resource);

        end;
        wRecordRef.Open(Database::User);
        wRecordRef.Get(User.RecordId);
        usuario := GetMaestro('users', User."Full Name", 'username', wRecordRef, Database::User);
        if usuario = 'Error' then Error('Usuario no existe');
        wRecordRef.Close();
        wRecordRef.Open(Database::"General Ledger Setup", false, CompanyName);
        wRecordRef.Get(GlSetup.RecordId);
        supervisor := GetMaestro('users', GlSetup."Usuario Tareas", 'username', wRecordRef, Database::"General Ledger Setup");
        wRecordRef.Close();
        //     {
        // "department": "604767e49fea4e001874b283",
        // "expirationDate": {
        //     "date": "2021-10-26T10:42:02",
        //     "rule": null,
        //     "custom": false
        // },
        JsonFormater.WriteStartObject('');
        JsonFormater.WriteStringProperty('department', departament);
        JsonFormater.WriteStartObject('expirationDate');
        JsonFormater.WriteStringProperty('date', Format(Tarea."Due DateTime", 0, '<Year4>-<Month,2>-<Day,2>T00:00:00'));
        JsonFormater.WriteNullProperty('rule');
        JsonFormater.WriteBooleanProperty('custom', false);
        JsonFormater.WriteEndObject();
        Desde := Variant2Date(Tarea."Start DateTime");
        Hasta := Variant2Date(Tarea."Due DateTime");
        Dias := Hasta - Desde;
        JsonFormater.WriteStringProperty('daysToPerform', Dias + 1);
        JsonFormater.WriteStringProperty('description', Tarea.Title);
        JsonFormater.WriteStringProperty('observation', Tarea.GetDescription);
        JsonFormater.WriteStringProperty('service', service);
        JsonFormater.WriteStringProperty('category', category);
        JsonFormater.WriteStringProperty('user', usuario);
        JsonFormater.WriteStringProperty('supervisor', supervisor);
        JsonFormater.WriteStringProperty('priority', 'HIGH');
        Url := GetUrl(ClientType::Web, CompanyName, ObjectType::Page, Page::"User Task Card", Tarea);
        JsonFormater.WriteStringProperty('link', Url);
        JsonFormater.WriteEndObject();
        Json := JsonFormater.GetJSonAsText();
        Json := RestApi.RestApiToken('/task', RequestType::post, jSon);
        IF Json <> '' THEN BEGIN
            JSONMgt.InitializeCollection(Json);
            a := JSONMgt.GetCollectionCount;
            WHILE i < a DO BEGIN
                JSONMgt.GetObjectFromCollectionByIndex(Json, i);
                JSONMgt.InitializeObject(Json);
                JSONMgt.ReadProperties();
                WHILE JSONMgt.GetNextProperty(Name, Value1) DO BEGIN
                    CASE Name OF
                        '_id':
                            Id := Value1;
                        'link':
                            link := Value1;
                    end;
                end;
                i += 1;
                if link = Url then i := a;
            end;
        end;
        if Id <> '' then begin
            Tarea.Id_Tarea := Id;
            Tarea.Modify();
        end;
        // "daysToPerform": 1,
        // "description": "Tarea prueba",
        // "observation": "Observaciones",
        // "service": "60589ab346c40b00195cc993",
        // "category": "6047b4ad8163a70018d3a2dd",
        // "project": "604bf21602913a001899c173",
        // "user": "60d31d7d0c6fff00183fe616",
        // "supervisor": "60d348afd3c595001917760a",
        // "priority": "HIGH",
        // "commandOrder": [
        //     "60d34a51d3c5950019177675",
        //     "60d3485fd3c5950019177601",
        //     "60d34a0dd3c5950019177665"
        // ],
        // "mentions": ["60d31d7d0c6fff00183fe616"]
    end;

    /// <summary>
    /// CrearTareaServiceItem.
    /// </summary>
    /// <param name="ProductoServicio">VAR Record "Service Item".</param>
    /// <param name="Tarea">Record "Service Header".</param>
    procedure CrearTareaServiceItem(var ProductoServicio: Record "Service Item"; Tarea: Record "Service Header")
    var
        JsoonFormater: Codeunit "Json Text Reader/Writer";
        RestApi: Codeunit Restapi;
        GenSetup: Record "General Ledger Setup";
        RequestType: Option Get,patch,put,post,delete;
        Pregunta: Text;
        JSONMgt: Codeunit "JSON Management";
        JsonFormater: Codeunit "Json Text Reader/Writer";
        jSon: Text;
        departament: Text;
        service: Text;
        category: Text;
        usuario: Text;
        GlSetup: Record "General Ledger Setup";
        supervisor: Text;
        User: Record User;
        Name: Text;
        Value1: Text;
        Id: Text;
        a: Integer;
        i: Integer;
        Desde: Date;
        Hasta: Date;
        Dias: Integer;
        Url: Text;
        link: Text;
        Company: Record "Company Information";
        TipoIncidencia: Record "Service Order Type";
        wRecordRef: RecordRef;
        Recurso: Record Resource;
        ConfUser: Record "User Setup";
        resource: Text;

    begin
        GlSetup.Get();
        Company.Get;
        wRecordRef.Open(Database::"Company Information", false, CompanyName);
        wRecordRef.Get(Company.RecordId);
        departament := GetMaestro('department', 'Sat', 'name', wRecordRef, Database::"Company Information");
        If departament = 'Error' then begin
            CreaDepartamento('Sat', Company.RecordId, Database::Company);
            departament := GetMaestro('department', 'Sat', 'name', wRecordRef, Database::"Company Information");
        end;
        wRecordRef.Close();
        wRecordRef.Open(Database::Resource, false, CompanyName);
        wRecordRef.Get(ProductoServicio.RecordId);
        service := GetMaestro('service', ProductoServicio.Description, 'name', wRecordRef, Database::"Service Item");
        if service = 'Error' then begin
            CreaServicioServiceItem(ProductoServicio, ProductoServicio.RecordId, Database::Resource);
            service := GetMaestro('service', ProductoServicio.Description, 'name', wRecordRef, Database::"Service Item");
        end;
        if Tarea."Service Order Type" = '' Then Tarea."Service Order Type" := 'INTERVENCION';
        if not TipoIncidencia.Get('INTERVENCION') then begin
            TipoIncidencia.Init();
            TipoIncidencia."Code" := 'INTERVENCION';
            TipoIncidencia."Description" := 'Intervencion';
            TipoIncidencia.Insert();
            Commit();
        end;
        wRecordRef.Close();
        wRecordRef.Open(Database::"Service Order Type", false, CompanyName);
        wRecordRef.Get(TipoIncidencia.RecordId);
        category := GetMaestro('category', TipoIncidencia.Description, 'name', wRecordRef, Database::"Service Order Type");
        if category = 'Error' then begin
            CreaCategoria('Intervencion', TipoIncidencia.RecordId, Database::"Service Order Type");
            category := GetMaestro('category', 'Intervencion', 'name', wRecordRef, Database::"Service Order Type");
        end;
        wRecordRef.Close();
        ConfUser.Get(Tarea."Assigned User ID");
        User.Get(ConfUser."User ID");
        Tarea.TestField("Preferred Resource");
        //if Tarea."Preferred Resource"<>'' Then User."Full Name":=ProductoServicio."Preferred Resource";
        resource := GetMaestro('resource', Tarea."Preferred Resource", 'name', wRecordRef, Database::Resource);
        if resource = 'Error' then begin
            Recurso.Get(Tarea."Preferred Resource");
            CreaRecurso(Recurso, Recurso.RecordId, Database::Resource);

        end;
        wRecordRef.Open(Database::User);
        wRecordRef.Get(User.RecordId);
        usuario := GetMaestro('users', resource, 'name', wRecordRef, Database::User);
        if usuario = 'Error' then Error('Usuario %1 no existe', resource);
        wRecordRef.Close();
        wRecordRef.Open(Database::"General Ledger Setup", false, CompanyName);
        wRecordRef.Get(GlSetup.RecordId);
        supervisor := GetMaestro('users', GlSetup."Usuario Tareas", 'username', wRecordRef, Database::"General Ledger Setup");
        wRecordRef.Close();
        //     {
        // "department": "604767e49fea4e001874b283",
        // "expirationDate": {
        //     "date": "2021-10-26T10:42:02",
        //     "rule": null,
        //     "custom": false
        // },
        JsonFormater.WriteStartObject('');
        JsonFormater.WriteStringProperty('department', departament);
        JsonFormater.WriteStartObject('expirationDate');

        JsonFormater.WriteStringProperty('date', Format(CreateDateTime(Tarea."Due Date", Tarea."Finishing Time"), 0, '<Year4>-<Month,2>-<Day,2>T00:00:00'));
        JsonFormater.WriteNullProperty('rule');
        JsonFormater.WriteBooleanProperty('custom', false);
        JsonFormater.WriteEndObject();
        Desde := Tarea."Order Date";
        Hasta := Tarea."Finishing Date";
        Dias := Hasta - Desde;
        JsonFormater.WriteStringProperty('daysToPerform', Dias + 1);
        JsonFormater.WriteStringProperty('description', Tarea.Description);
        JsonFormater.WriteStringProperty('observation', Tarea.GetWorkDescription);
        JsonFormater.WriteStringProperty('service', service);
        JsonFormater.WriteStringProperty('category', category);
        JsonFormater.WriteStringProperty('user', usuario);
        JsonFormater.WriteStringProperty('supervisor', supervisor);
        JsonFormater.WriteStringProperty('priority', 'HIGH');
        Url := GetUrl(ClientType::Web, CompanyName, ObjectType::Page, Page::"User Task Card", Tarea);
        JsonFormater.WriteStringProperty('link', Url);
        JsonFormater.WriteEndObject();
        Json := JsonFormater.GetJSonAsText();
        Json := RestApi.RestApiToken('/task', RequestType::post, jSon);
        IF Json <> '' THEN BEGIN
            JSONMgt.InitializeCollection(Json);
            a := JSONMgt.GetCollectionCount;
            WHILE i < a DO BEGIN
                JSONMgt.GetObjectFromCollectionByIndex(Json, i);
                JSONMgt.InitializeObject(Json);
                JSONMgt.ReadProperties();
                WHILE JSONMgt.GetNextProperty(Name, Value1) DO BEGIN
                    CASE Name OF
                        '_id':
                            Id := Value1;
                        'link':
                            link := Value1;
                    end;
                end;
                i += 1;
                if link = Url then i := a;
            end;
        end;
        if Id <> '' then begin
            Tarea.Id_Tarea := Id;
            Tarea.Modify();
        end;
        // "daysToPerform": 1,
        // "description": "Tarea prueba",
        // "observation": "Observaciones",
        // "service": "60589ab346c40b00195cc993",
        // "category": "6047b4ad8163a70018d3a2dd",
        // "project": "604bf21602913a001899c173",
        // "user": "60d31d7d0c6fff00183fe616",
        // "supervisor": "60d348afd3c595001917760a",
        // "priority": "HIGH",
        // "commandOrder": [
        //     "60d34a51d3c5950019177675",
        //     "60d3485fd3c5950019177601",
        //     "60d34a0dd3c5950019177665"
        // ],
        // "mentions": ["60d31d7d0c6fff00183fe616"]
    end;

    /// <summary>
    /// CrearTareaTodo.
    /// </summary>
    /// <param name="Tarea">VAR Record "To-do".</param>
    procedure CrearTareaTodo(var Tarea: Record "To-do")
    var
        JsoonFormater: Codeunit "Json Text Reader/Writer";
        RestApi: Codeunit Restapi;
        GenSetup: Record "General Ledger Setup";
        RequestType: Option Get,patch,put,post,delete;
        Pregunta: Text;
        JSONMgt: Codeunit "JSON Management";
        JsonFormater: Codeunit "Json Text Reader/Writer";
        jSon: Text;
        departament: Text;
        service: Text;
        category: Text;
        usuario: Text;
        GlSetup: Record "General Ledger Setup";
        supervisor: Text;
        User: Record User;
        Name: Text;
        Value1: Text;
        Id: Text;
        a: Integer;
        i: Integer;
        Desde: Date;
        Hasta: Date;
        Dias: Integer;
        Url: Text;
        link: Text;
        Company: Record "Sales & Receivables Setup";
        TipoIncidencia: Record "User Task Group";
        wRecordRef: RecordRef;
        Recurso: Record Resource;
        SalesPerson: Record "Salesperson/Purchaser";
        ConfUser: Record "User Setup";
        Customer: Record Contact;
        Client: Text;

    begin
        GlSetup.Get();
        Company.Get;
        wRecordRef.Open(Database::"Sales & Receivables Setup", false, CompanyName);
        wRecordRef.Get(Company.RecordId);
        departament := GetMaestro('department', 'Comercial', 'name', wRecordRef, Database::"Sales & Receivables Setup");
        If departament = 'Error' then begin
            CreaDepartamento('Comercial', Company.RecordId, Database::"Sales & Receivables Setup");
            departament := GetMaestro('department', 'Comercial', 'name', wRecordRef, Database::"Sales & Receivables Setup");
        end;
        wRecordRef.Close();
        wRecordRef.Open(Database::Contact, false, CompanyName);
        Customer.Get(Tarea."Contact No.");
        wRecordRef.Get(Customer.RecordId);
        // service := GetMaestro('service', ProductoServicio.Description, 'name', wRecordRef, Database::Resource);
        // if service = 'Error' then begin
        //     CreaServicio(ProductoServicio, ProductoServicio.RecordId, Database::Resource);
        //     service := GetMaestro('service', ProductoServicio.Description, 'name', wRecordRef, Database::Resource);
        // end;
        Client := GetMaestro('client', Tarea."Contact No.", 'name', wRecordRef, Database::Contact);
        if Client = 'Error' then begin
            CreaContacto(Customer, Customer.RecordId, Database::Contact);
            Client := GetMaestro('client', Tarea."Contact No.", 'name', wRecordRef, Database::Contact);
        end;
        wRecordRef.Close();
        ;
        if not TipoIncidencia.Get(Format(Tarea.Type)) then begin
            TipoIncidencia.Init();
            TipoIncidencia."Code" := Format(Tarea.Type);
            TipoIncidencia."Description" := Format(Tarea.Type);
            TipoIncidencia.Insert();
            Commit();
        end;
        wRecordRef.Close();
        wRecordRef.Open(Database::"User Task Group", false, CompanyName);
        wRecordRef.Get(TipoIncidencia.RecordId);
        category := GetMaestro('category', Format(Tarea.Type), 'name', wRecordRef, Database::"User Task Group");
        if category = 'Error' then begin
            CreaCategoria(Format(Tarea.Type), TipoIncidencia.RecordId, Database::"User Task Group");
            category := GetMaestro('category', Format(Tarea.Type), 'name', wRecordRef, Database::"User Task Group");
        end;
        wRecordRef.Close();
        SalesPerson.Get(Tarea."Salesperson Code");
        ConfUser.SetRange("Salespers./Purch. Code", Tarea."Salesperson Code");
        ConfUser.FindFirst();
        User.SetRange(User."User Name", ConfUser."User ID");
        User.FindFirst();
        // if not Recurso.Get(User."Full Name") then begin
        //     Recurso.Init();
        //     Recurso."No." := User."Full Name";
        //     Recurso.Type := Recurso.Type::Person;
        //     Recurso.Name := User."Full Name";
        //     Recurso.Insert();
        //     Commit();
        //     CreaRecurso(Recurso, Recurso.RecordId, Database::Resource);

        // end;
        wRecordRef.Open(Database::User);
        wRecordRef.Get(User.RecordId);
        usuario := GetMaestro('users', User."Full Name", 'username', wRecordRef, Database::User);
        if usuario = 'Error' then Error('Usuario no existe');
        wRecordRef.Close();
        wRecordRef.Open(Database::"General Ledger Setup", false, CompanyName);
        wRecordRef.Get(GlSetup.RecordId);
        supervisor := GetMaestro('users', GlSetup."Usuario Tareas", 'username', wRecordRef, Database::"General Ledger Setup");
        wRecordRef.Close();
        //     {
        // "department": "604767e49fea4e001874b283",
        // "expirationDate": {
        //     "date": "2021-10-26T10:42:02",
        //     "rule": null,
        //     "custom": false
        // },
        JsonFormater.WriteStartObject('');
        JsonFormater.WriteStringProperty('department', departament);
        JsonFormater.WriteStartObject('expirationDate');
        JsonFormater.WriteStringProperty('date', Format(CreateDateTime(Tarea.Date, Tarea."Start Time"), 0, '<Year4>-<Month,2>-<Day,2>T<Hours24>:<Minutes,2>:<Seconds,2>'));
        JsonFormater.WriteNullProperty('rule');
        JsonFormater.WriteBooleanProperty('custom', false);
        JsonFormater.WriteEndObject();
        Dias := Tarea.Duration div (60 * 60 * 1000);
        JsonFormater.WriteStringProperty('daysToPerform', Dias + 1);
        JsonFormater.WriteStringProperty('description', Tarea.Description);
        JsonFormater.WriteStringProperty('observation', '');
        //JsonFormater.WriteStringProperty('service', service);
        JsonFormater.WriteStringProperty('client', Client);
        JsonFormater.WriteStringProperty('category', category);
        JsonFormater.WriteStringProperty('user', usuario);
        JsonFormater.WriteStringProperty('supervisor', supervisor);
        JsonFormater.WriteStringProperty('priority', 'HIGH');
        Url := GetUrl(ClientType::Web, CompanyName, ObjectType::Page, Page::"Task Card", Tarea);
        JsonFormater.WriteStringProperty('link', Url);
        JsonFormater.WriteEndObject();
        Json := JsonFormater.GetJSonAsText();
        Json := RestApi.RestApiToken('/task', RequestType::post, jSon);
        IF Json <> '' THEN BEGIN
            JSONMgt.InitializeCollection(Json);
            a := JSONMgt.GetCollectionCount;
            WHILE i < a DO BEGIN
                JSONMgt.GetObjectFromCollectionByIndex(Json, i);
                JSONMgt.InitializeObject(Json);
                JSONMgt.ReadProperties();
                WHILE JSONMgt.GetNextProperty(Name, Value1) DO BEGIN
                    CASE Name OF
                        '_id':
                            Id := Value1;
                        'link':
                            link := Value1;
                    end;
                end;
                i += 1;
                if link = Url then i := a;
            end;
        end;
        if Id <> '' then begin
            Tarea.Id_Tarea := Id;
            Tarea.Modify();
        end;
        // "daysToPerform": 1,
        // "description": "Tarea prueba",
        // "observation": "Observaciones",
        // "service": "60589ab346c40b00195cc993",
        // "category": "6047b4ad8163a70018d3a2dd",
        // "project": "604bf21602913a001899c173",
        // "user": "60d31d7d0c6fff00183fe616",
        // "supervisor": "60d348afd3c595001917760a",
        // "priority": "HIGH",
        // "commandOrder": [
        //     "60d34a51d3c5950019177675",
        //     "60d3485fd3c5950019177601",
        //     "60d34a0dd3c5950019177665"
        // ],
        // "mentions": ["60d31d7d0c6fff00183fe616"]
    end;

    /// <summary>
    /// CrearTareaJob.
    /// </summary>
    /// <param name="Job">VAR Record job.</param>
    /// <param name="Tarea">Record "User Task".</param>
    procedure CrearTareaJob(var Job: Record job; Tarea: Record "User Task")
    var
        JsoonFormater: Codeunit "Json Text Reader/Writer";
        RestApi: Codeunit Restapi;
        GenSetup: Record "General Ledger Setup";
        RequestType: Option Get,patch,put,post,delete;
        Pregunta: Text;
        JSONMgt: Codeunit "JSON Management";
        JsonFormater: Codeunit "Json Text Reader/Writer";
        jSon: Text;
        departament: Text;
        service: Text;
        category: Text;
        usuario: Text;
        GlSetup: Record "General Ledger Setup";
        supervisor: Text;
        User: Record User;
        Name: Text;
        Value1: Text;
        Id: Text;
        a: Integer;
        i: Integer;
        Desde: Date;
        Hasta: Date;
        Dias: Integer;
        Url: Text;
        link: Text;
        Company: Record "Sales & Receivables Setup";
        TipoIncidencia: Record "User Task Group";
        wRecordRef: RecordRef;
        Recurso: Record Resource;
        SalesPerson: Record "Salesperson/Purchaser";
        ConfUser: Record "User Setup";
        Customer: Record Customer;
        Client: Text;
        Proyect: Text;

    begin
        GlSetup.Get();
        Company.Get;
        wRecordRef.Open(Database::"Sales & Receivables Setup", false, CompanyName);
        wRecordRef.Get(Company.RecordId);
        departament := GetMaestro('department', 'Proyectos', 'name', wRecordRef, Database::"Sales & Receivables Setup");
        If departament = 'Error' then begin
            CreaDepartamento('Comercial', Company.RecordId, Database::"Sales & Receivables Setup");
            departament := GetMaestro('department', 'Proyectos', 'name', wRecordRef, Database::"Sales & Receivables Setup");
        end;
        wRecordRef.Close();
        wRecordRef.Open(Database::Contact, false, CompanyName);
        Customer.Get(Job."Bill-to Customer No.");
        wRecordRef.Get(Customer.RecordId);
        // service := GetMaestro('service', ProductoServicio.Description, 'name', wRecordRef, Database::Resource);
        // if service = 'Error' then begin
        //     CreaServicio(ProductoServicio, ProductoServicio.RecordId, Database::Resource);
        //     service := GetMaestro('service', ProductoServicio.Description, 'name', wRecordRef, Database::Resource);
        // end;
        Client := GetMaestro('client', Job."Bill-to Customer No.", 'name', wRecordRef, Database::Customer);
        if Client = 'Error' then begin
            CreaCliente(Customer, Customer.RecordId, Database::Customer);
            Client := GetMaestro('client', Job."Bill-to Customer No.", 'name', wRecordRef, Database::Customer);
        end;
        wRecordRef.Close();

        wRecordRef.Open(Database::Job, false, CompanyName);
        wRecordRef.Get(Job.RecordId);
        // service := GetMaestro('service', ProductoServicio.Description, 'name', wRecordRef, Database::Resource);
        // if service = 'Error' then begin
        //     CreaServicio(ProductoServicio, ProductoServicio.RecordId, Database::Resource);
        //     service := GetMaestro('service', ProductoServicio.Description, 'name', wRecordRef, Database::Resource);
        // end;
        Proyect := GetMaestro('proyect', Job.Description, 'name', wRecordRef, Database::Job);
        if Proyect = 'Error' then begin
            CreaProyecto(Job, Job.RecordId, Database::Job);
            Proyect := GetMaestro('proyect', Job.Description, 'name', wRecordRef, Database::Job);
        end;
        wRecordRef.Close();

        if not TipoIncidencia.Get(Tarea."User Task Group Assigned To") then begin
            TipoIncidencia.Init();
            TipoIncidencia."Code" := Tarea."User Task Group Assigned To";
            TipoIncidencia."Description" := Tarea."User Task Group Assigned To";
            TipoIncidencia.Insert();
            Commit();
        end;
        wRecordRef.Close();
        wRecordRef.Open(Database::"User Task Group", false, CompanyName);
        wRecordRef.Get(TipoIncidencia.RecordId);
        category := GetMaestro('category', 'Navision', 'name', wRecordRef, Database::"User Task Group");
        if category = 'Error' then begin
            CreaCategoria('Navision', TipoIncidencia.RecordId, Database::"User Task Group");
            category := GetMaestro('category', 'Navision', 'name', wRecordRef, Database::"User Task Group");
        end;
        wRecordRef.Close();

        // SalesPerson.Get(Tarea."Salesperson Code");
        // ConfUser.SetRange("Salespers./Purch. Code", Tarea."Salesperson Code");
        // ConfUser.FindFirst();
        User.SetRange(User."User Name", ConfUser."User ID");
        User.FindFirst();
        // if not Recurso.Get(User."Full Name") then begin
        //     Recurso.Init();
        //     Recurso."No." := User."Full Name";
        //     Recurso.Type := Recurso.Type::Person;
        //     Recurso.Name := User."Full Name";
        //     Recurso.Insert();
        //     Commit();
        //     CreaRecurso(Recurso, Recurso.RecordId, Database::Resource);

        // end;
        Tarea.CalcFields("Assigned To User Name");
        User.Get(Tarea."Assigned To");
        if not Recurso.Get(User."Full Name") then begin
            Recurso.Init();
            Recurso."No." := User."Full Name";
            Recurso.Type := Recurso.Type::Person;
            Recurso.Name := User."Full Name";
            Recurso.Insert();
            Commit();
            CreaRecurso(Recurso, Recurso.RecordId, Database::Resource);

        end;
        wRecordRef.Open(Database::User);
        wRecordRef.Get(User.RecordId);
        usuario := GetMaestro('users', User."Full Name", 'username', wRecordRef, Database::User);
        if usuario = 'Error' then Error('Usuario no existe');
        wRecordRef.Close();
        wRecordRef.Open(Database::"General Ledger Setup", false, CompanyName);
        wRecordRef.Get(GlSetup.RecordId);
        supervisor := GetMaestro('users', GlSetup."Usuario Tareas", 'username', wRecordRef, Database::"General Ledger Setup");
        wRecordRef.Close();
        //     {
        // "department": "604767e49fea4e001874b283",
        // "expirationDate": {
        //     "date": "2021-10-26T10:42:02",
        //     "rule": null,
        //     "custom": false
        // },
        JsonFormater.WriteStartObject('');
        JsonFormater.WriteStringProperty('department', departament);
        JsonFormater.WriteStartObject('expirationDate');
        JsonFormater.WriteStringProperty('date', Format(Tarea."Created DateTime", 0, '<Year4>-<Month,2>-<Day,2>T<Hours24>:<Minutes,2>:<Seconds,2>'));
        JsonFormater.WriteNullProperty('rule');
        JsonFormater.WriteBooleanProperty('custom', false);
        JsonFormater.WriteEndObject();
        Dias := 0;
        JsonFormater.WriteStringProperty('daysToPerform', Dias + 1);
        JsonFormater.WriteStringProperty('description', Tarea.Description);
        JsonFormater.WriteStringProperty('observation', '');
        JsonFormater.WriteStringProperty('proyect', Proyect);
        JsonFormater.WriteStringProperty('client', Client);
        JsonFormater.WriteStringProperty('category', category);
        JsonFormater.WriteStringProperty('user', usuario);
        JsonFormater.WriteStringProperty('supervisor', supervisor);
        JsonFormater.WriteStringProperty('priority', 'HIGH');
        Url := GetUrl(ClientType::Web, CompanyName, ObjectType::Page, Page::"Task Card", Tarea);
        JsonFormater.WriteStringProperty('link', Url);
        JsonFormater.WriteEndObject();
        Json := JsonFormater.GetJSonAsText();
        Json := RestApi.RestApiToken('/task', RequestType::post, jSon);
        IF Json <> '' THEN BEGIN
            JSONMgt.InitializeCollection(Json);
            a := JSONMgt.GetCollectionCount;
            WHILE i < a DO BEGIN
                JSONMgt.GetObjectFromCollectionByIndex(Json, i);
                JSONMgt.InitializeObject(Json);
                JSONMgt.ReadProperties();
                WHILE JSONMgt.GetNextProperty(Name, Value1) DO BEGIN
                    CASE Name OF
                        '_id':
                            Id := Value1;
                        'link':
                            link := Value1;
                    end;
                end;
                i += 1;
                if link = Url then i := a;
            end;
        end;
        if Id <> '' then begin
            Tarea.Id_Tarea := Id;
            Tarea.Modify();
        end;
        // "daysToPerform": 1,
        // "description": "Tarea prueba",
        // "observation": "Observaciones",
        // "service": "60589ab346c40b00195cc993",
        // "category": "6047b4ad8163a70018d3a2dd",
        // "project": "604bf21602913a001899c173",
        // "user": "60d31d7d0c6fff00183fe616",
        // "supervisor": "60d348afd3c595001917760a",
        // "priority": "HIGH",
        // "commandOrder": [
        //     "60d34a51d3c5950019177675",
        //     "60d3485fd3c5950019177601",
        //     "60d34a0dd3c5950019177665"
        // ],
        // "mentions": ["60d31d7d0c6fff00183fe616"]
    end;

    /// <summary>
    /// CreaDepartamento.
    /// </summary>
    /// <param name="Valor">Text.</param>
    /// <param name="tRecordId">RecordId.</param>
    /// <param name="Tabla">Integer.</param>
    procedure CreaDepartamento(Valor: Text; tRecordId: RecordId; Tabla: Integer)
    var
        JsonFormater: Codeunit "Json Text Reader/Writer";
        RestApi: Codeunit Restapi;
        jSon: Text;
        RequestType: Option Get,patch,put,post,delete;
        Link: Record "Data Migration Error";
        Name: Text;
        Value1: Text;
        JSONMgt: Codeunit "JSON Management";
    begin
        JsonFormater.WriteStartObject('');
        JsonFormater.WriteStringProperty('name', Valor);
        JsonFormater.WriteEndObject();
        Json := JsonFormater.GetJSonAsText();
        Json := RestApi.RestApiToken('/department', RequestType::post, jSon);
        JSONMgt.InitializeObject(Json);
        JSONMgt.ReadProperties();
        WHILE JSONMgt.GetNextProperty(Name, Value1) DO BEGIN
            CASE Name OF
                '_id':
                    begin
                        InsertLink(tRecordId, Tabla, Value1);
                    end;

            end;
        end;
    end;

    /// <summary>
    /// CreaCategoria.
    /// </summary>
    /// <param name="Valor">Text.</param>
    /// <param name="tRecordId">RecordId.</param>
    /// <param name="Tabla">Integer.</param>
    procedure CreaCategoria(Valor: Text; tRecordId: RecordId; Tabla: Integer)
    var
        JsonFormater: Codeunit "Json Text Reader/Writer";
        RestApi: Codeunit Restapi;
        jSon: Text;
        RequestType: Option Get,patch,put,post,delete;
        Link: Record "Data Migration Error";
        Name: Text;
        Value1: Text;
        JSONMgt: Codeunit "JSON Management";
    begin
        JsonFormater.WriteStartObject('');
        JsonFormater.WriteStringProperty('name', Valor);
        JsonFormater.WriteEndObject();
        Json := JsonFormater.GetJSonAsText();
        Json := RestApi.RestApiToken('/category', RequestType::post, jSon);
        JSONMgt.InitializeObject(Json);
        JSONMgt.ReadProperties();
        WHILE JSONMgt.GetNextProperty(Name, Value1) DO BEGIN
            CASE Name OF
                '_id':
                    begin
                        InsertLink(tRecordId, Tabla, Value1);
                    end;
            end;
        end;

    end;

    procedure CreaProveedor(Proveedor: Record Vendor; tRecordId: RecordId; Tabla: Integer)
    var
        JsonFormater: Codeunit "Json Text Reader/Writer";
        RestApi: Codeunit Restapi;
        jSon: Text;
        RequestType: Option Get,patch,put,post,delete;
        Link: Record "Data Migration Error";
        Name: Text;
        Value1: Text;
        JSONMgt: Codeunit "JSON Management";
    begin
        JsonFormater.WriteStartObject('');
        JsonFormater.WriteStringProperty('name', Proveedor.Name);
        JsonFormater.WriteStringProperty('street', Proveedor.Address);
        JsonFormater.WriteStringProperty('vatRegisterNO', Proveedor."VAT Registration No.");
        JsonFormater.WriteEndObject();
        Json := JsonFormater.GetJSonAsText();
        Json := RestApi.RestApiToken('/provider', RequestType::post, jSon);
        JSONMgt.InitializeObject(Json);
        JSONMgt.ReadProperties();
        WHILE JSONMgt.GetNextProperty(Name, Value1) DO BEGIN
            CASE Name OF
                '_id':
                    begin
                        InsertLink(tRecordId, Tabla, Value1);
                    end;
            end;
        end;
    end;

    procedure CreaCliente(Customer: Record Customer; tRecordId: RecordId; Tabla: Integer)
    var
        JsonFormater: Codeunit "Json Text Reader/Writer";
        RestApi: Codeunit Restapi;
        jSon: Text;
        RequestType: Option Get,patch,put,post,delete;
        Link: Record "Data Migration Error";
        Name: Text;
        Value1: Text;
        JSONMgt: Codeunit "JSON Management";
    begin
        JsonFormater.WriteStartObject('');
        JsonFormater.WriteStringProperty('name', Customer.Name);
        JsonFormater.WriteStringProperty('street', Customer.Address);
        JsonFormater.WriteStringProperty('vatRegisterNO', Customer."VAT Registration No.");
        JsonFormater.WriteEndObject();
        Json := JsonFormater.GetJSonAsText();
        Json := RestApi.RestApiToken('/client', RequestType::post, jSon);
        JSONMgt.InitializeObject(Json);
        JSONMgt.ReadProperties();
        WHILE JSONMgt.GetNextProperty(Name, Value1) DO BEGIN
            CASE Name OF
                '_id':
                    begin

                        InsertLink(tRecordId, Tabla, Value1);
                    end;
            end;
        end;
    end;

    procedure CreaContacto(Customer: Record Contact; tRecordId: RecordId; Tabla: Integer)
    var
        JsonFormater: Codeunit "Json Text Reader/Writer";
        RestApi: Codeunit Restapi;
        jSon: Text;
        RequestType: Option Get,patch,put,post,delete;
        Link: Record "Data Migration Error";
        Name: Text;
        Value1: Text;
        JSONMgt: Codeunit "JSON Management";
    begin
        JsonFormater.WriteStartObject('');
        JsonFormater.WriteStringProperty('name', Customer.Name);
        JsonFormater.WriteStringProperty('street', Customer.Address);
        JsonFormater.WriteStringProperty('vatRegisterNO', Customer."VAT Registration No.");
        JsonFormater.WriteEndObject();
        Json := JsonFormater.GetJSonAsText();
        Json := RestApi.RestApiToken('/client', RequestType::post, jSon);
        JSONMgt.InitializeObject(Json);
        JSONMgt.ReadProperties();
        WHILE JSONMgt.GetNextProperty(Name, Value1) DO BEGIN
            CASE Name OF
                '_id':
                    begin
                        InsertLink(tRecordId, Tabla, Value1);
                    end;
            end;
        end;
    end;

    procedure CreaProducto(Item: Record Item; tRecordId: RecordId; Tabla: Integer)
    var
        JsonFormater: Codeunit "Json Text Reader/Writer";
        RestApi: Codeunit Restapi;
        jSon: Text;
        RequestType: Option Get,patch,put,post,delete;
        Link: Record "Data Migration Error";
        Name: Text;
        Value1: Text;
        JSONMgt: Codeunit "JSON Management";
    begin
        JsonFormater.WriteStartObject('');
        JsonFormater.WriteStringProperty('name', item.Description);
        JsonFormater.WriteEndObject();
        Json := JsonFormater.GetJSonAsText();
        Json := RestApi.RestApiToken('/product', RequestType::post, jSon);
        JSONMgt.InitializeObject(Json);
        JSONMgt.ReadProperties();
        WHILE JSONMgt.GetNextProperty(Name, Value1) DO BEGIN
            CASE Name OF
                '_id':
                    begin
                        InsertLink(tRecordId, Tabla, Value1);
                    end;
            end;
        end;
    end;

    procedure CreaRecurso(Recurso: Record Resource; tRecordId: RecordId; Tabla: Integer)
    var
        JsonFormater: Codeunit "Json Text Reader/Writer";
        RestApi: Codeunit Restapi;
        jSon: Text;
        RequestType: Option Get,patch,put,post,delete;
        Link: Record "Data Migration Error";
        Name: Text;
        Value1: Text;
        JSONMgt: Codeunit "JSON Management";
    begin
        JsonFormater.WriteStartObject('');
        JsonFormater.WriteStringProperty('name', Recurso.Name);
        JsonFormater.WriteEndObject();
        Json := JsonFormater.GetJSonAsText();
        Json := RestApi.RestApiToken('/resource', RequestType::post, jSon);
        JSONMgt.InitializeObject(Json);
        JSONMgt.ReadProperties();
        WHILE JSONMgt.GetNextProperty(Name, Value1) DO BEGIN
            CASE Name OF
                '_id':
                    begin
                        InsertLink(tRecordId, Tabla, Value1);
                    end;
            end;
        end;
    end;

    procedure CreaServicio(ProductoServicio: Record Resource; tRecordId: RecordId; Tabla: Integer)
    var
        JsonFormater: Codeunit "Json Text Reader/Writer";
        RestApi: Codeunit Restapi;
        jSon: Text;
        RequestType: Option Get,patch,put,post,delete;
        Client: Text;
        Proveedor: Text;
        Customer: Record Customer;
        Vendor: Record Vendor;
        Producto: Text;
        Item: Record Item;
        Link: Record "Data Migration Error";
        Name: Text;
        Value1: Text;
        JSONMgt: Codeunit "JSON Management";
        wRecordRef: RecordRef;
    begin
        //       "_id": "60589ab346c40b00195cc993",
        //     "establishment": "604754af75efa40018027f62",
        //     "name": "BBB",
        //     "createdAt": "2021-03-22T13:25:07.999Z",
        //     "updatedAt": "2021-10-25T08:10:42.373Z",
        //     "__v": 0,
        //     "provider": "61711bcbe7a94c289c94fcc3",
        //     "client": "60ed44c26a580923c877cc43",
        //     "componentWarranty": 100,
        //     "componentWork": 13,
        //     "endDate": "2021-10-24T12:05:04.361Z",
        //     "product": "6172a8e7d86b5066a0c8710c",
        //     "resource": "6172a453d86b5066a0c8710a",
        //     "startDate": "2021-10-22T12:05:01.580Z"
        // },
        If Customer.Get(ProductoServicio."Customer No.") then begin
            wRecordRef.Open(Database::Customer, false, CompanyName);
            wRecordRef.Get(Customer.RecordId);
            Client := GetMaestro('client', Customer."VAT Registration No.", 'vatRegisterNO', wRecordRef, Database::Customer);
            If Client = 'Error' then begin
                CreaCliente(Customer, Customer.RecordId, Database::Customer);
                Client := GetMaestro('client', Customer."VAT Registration No.", 'vatRegisterNO', wRecordRef, Database::Customer);
            end;
            wRecordRef.Close();
        end;
        If Vendor.Get(ProductoServicio."Vendor No.") then begin
            wRecordRef.Open(Database::Vendor, false, CompanyName);
            wRecordRef.Get(Vendor.RecordId);
            Proveedor := GetMaestro('provider', Vendor."VAT Registration No.", 'vatRegisterNO', wRecordRef, Database::Vendor);
            if Proveedor = 'Error' Then begin
                CreaProveedor(Vendor, Vendor.RecordId, Database::Vendor);
                Proveedor := GetMaestro('provider', Vendor."VAT Registration No.", 'vatRegisterNO', wRecordRef, Database::Vendor);
            end;
            wRecordRef.Close();
        end;
        If Item.Get(ProductoServicio."Item No.") then begin
            wRecordRef.Open(Database::Item, false, CompanyName);
            wRecordRef.Get(Item.RecordId);
            Producto := GetMaestro('product', Item.Description, 'name', wRecordRef, Database::Item);
            if Producto = 'Error' Then begin
                CreaProducto(Item, Item.RecordId, Database::Item);
                Producto := GetMaestro('product', Item.Description, 'name', wRecordRef, Database::Item);
            end;
            wRecordRef.Close();
        end;
        JsonFormater.WriteStartObject('');
        JsonFormater.WriteStringProperty('name', ProductoServicio.Name);
        if Proveedor <> '' Then
            JsonFormater.WriteStringProperty('provider', Proveedor);
        if Client <> '' then
            JsonFormater.WriteStringProperty('client', Client);
        JsonFormater.WriteStringProperty('componentWarranty', Format(ProductoServicio."Warranty % (Parts)"));
        JsonFormater.WriteStringProperty('componentWork', Format(ProductoServicio."Warranty % (Labor)"));
        JsonFormater.WriteStringProperty('endDate', Format(ProductoServicio."Warranty Ending Date (Parts)", 0, '<Year4>-<Month,2>-<Day,2>T00:00:00'));
        if Producto <> '' Then
            JsonFormater.WriteStringProperty('product', Producto);
        JsonFormater.WriteStringProperty('startDate', Format(ProductoServicio."Warranty Starting Date (Parts)", 0, '<Year4>-<Month,2>-<Day,2>T00:00:00'));
        JsonFormater.WriteEndObject();
        Json := JsonFormater.GetJSonAsText();
        Json := RestApi.RestApiToken('/service', RequestType::post, jSon);
        JSONMgt.InitializeObject(Json);
        JSONMgt.ReadProperties();
        WHILE JSONMgt.GetNextProperty(Name, Value1) DO BEGIN
            CASE Name OF
                '_id':
                    begin
                        InsertLink(tRecordId, Tabla, Value1);
                    end;
            end;
        end;
    end;

    procedure CreaProyecto(Job: Record Job; tRecordId: RecordId; Tabla: Integer)
    var
        JsonFormater: Codeunit "Json Text Reader/Writer";
        RestApi: Codeunit Restapi;
        jSon: Text;
        RequestType: Option Get,patch,put,post,delete;
        Client: Text;
        Proveedor: Text;
        Customer: Record Customer;
        Vendor: Record Vendor;
        Producto: Text;
        Item: Record Item;
        Link: Record "Data Migration Error";
        Name: Text;
        Value1: Text;
        JSONMgt: Codeunit "JSON Management";
        wRecordRef: RecordRef;
    begin
        //       "_id": "60589ab346c40b00195cc993",
        //     "establishment": "604754af75efa40018027f62",
        //     "name": "BBB",
        //     "createdAt": "2021-03-22T13:25:07.999Z",
        //     "updatedAt": "2021-10-25T08:10:42.373Z",
        //     "__v": 0,
        //     "provider": "61711bcbe7a94c289c94fcc3",
        //     "client": "60ed44c26a580923c877cc43",
        //     "componentWarranty": 100,
        //     "componentWork": 13,
        //     "endDate": "2021-10-24T12:05:04.361Z",
        //     "product": "6172a8e7d86b5066a0c8710c",
        //     "resource": "6172a453d86b5066a0c8710a",
        //     "startDate": "2021-10-22T12:05:01.580Z"
        // },
        If Customer.Get(Job."Bill-to Customer No.") then begin
            wRecordRef.Open(Database::Customer, false, CompanyName);
            wRecordRef.Get(Customer.RecordId);
            Client := GetMaestro('client', Customer."VAT Registration No.", 'vatRegisterNO', wRecordRef, Database::Customer);
            If Client = 'Error' then begin
                CreaCliente(Customer, Customer.RecordId, Database::Customer);
                Client := GetMaestro('client', Customer."VAT Registration No.", 'vatRegisterNO', wRecordRef, Database::Customer);
            end;
            wRecordRef.Close();
        end;
        JsonFormater.WriteStartObject('');
        JsonFormater.WriteStringProperty('name', Job.Description);
        // if Proveedor <> '' Then
        //     JsonFormater.WriteStringProperty('provider', Proveedor);
        // if Client <> '' then
        //     JsonFormater.WriteStringProperty('client', Client);
        // JsonFormater.WriteStringProperty('componentWarranty', Format(ProductoServicio."Warranty % (Parts)"));
        // JsonFormater.WriteStringProperty('componentWork', Format(ProductoServicio."Warranty % (Labor)"));
        // JsonFormater.WriteStringProperty('endDate', Format(ProductoServicio."Warranty Ending Date (Parts)", 0, '<Year4>-<Month,2>-<Day,2>T00:00:00'));
        // if Producto <> '' Then
        //     JsonFormater.WriteStringProperty('product', Producto);
        // JsonFormater.WriteStringProperty('startDate', Format(ProductoServicio."Warranty Starting Date (Parts)", 0, '<Year4>-<Month,2>-<Day,2>T00:00:00'));
        JsonFormater.WriteEndObject();
        Json := JsonFormater.GetJSonAsText();
        Json := RestApi.RestApiToken('/proyect', RequestType::post, jSon);
        JSONMgt.InitializeObject(Json);
        JSONMgt.ReadProperties();
        WHILE JSONMgt.GetNextProperty(Name, Value1) DO BEGIN
            CASE Name OF
                '_id':
                    begin
                        InsertLink(tRecordId, Tabla, Value1);
                    end;
            end;
        end;
    end;

    procedure CreaServicioServiceItem(ProductoServicio: Record "Service Item"; tRecordId: RecordId; Tabla: Integer)
    var
        JsonFormater: Codeunit "Json Text Reader/Writer";
        RestApi: Codeunit Restapi;
        jSon: Text;
        RequestType: Option Get,patch,put,post,delete;
        Client: Text;
        Proveedor: Text;
        Customer: Record Customer;
        Vendor: Record Vendor;
        Producto: Text;
        Item: Record Item;
        Link: Record "Data Migration Error";
        Name: Text;
        Value1: Text;
        JSONMgt: Codeunit "JSON Management";
        wRecordRef: RecordRef;
    begin
        //       "_id": "60589ab346c40b00195cc993",
        //     "establishment": "604754af75efa40018027f62",
        //     "name": "BBB",
        //     "createdAt": "2021-03-22T13:25:07.999Z",
        //     "updatedAt": "2021-10-25T08:10:42.373Z",
        //     "__v": 0,
        //     "provider": "61711bcbe7a94c289c94fcc3",
        //     "client": "60ed44c26a580923c877cc43",
        //     "componentWarranty": 100,
        //     "componentWork": 13,
        //     "endDate": "2021-10-24T12:05:04.361Z",
        //     "product": "6172a8e7d86b5066a0c8710c",
        //     "resource": "6172a453d86b5066a0c8710a",
        //     "startDate": "2021-10-22T12:05:01.580Z"
        // },
        If Customer.Get(ProductoServicio."Customer No.") then begin
            wRecordRef.Open(Database::Customer, false, CompanyName);
            wRecordRef.Get(Customer.RecordId);
            Client := GetMaestro('client', Customer."VAT Registration No.", 'vatRegisterNO', wRecordRef, Database::Customer);
            If Client = 'Error' then begin
                CreaCliente(Customer, Customer.RecordId, Database::Customer);
                Client := GetMaestro('client', Customer."VAT Registration No.", 'vatRegisterNO', wRecordRef, Database::Customer);
            end;
            wRecordRef.Close();
        end;
        If Vendor.Get(ProductoServicio."Vendor No.") then begin
            wRecordRef.Open(Database::Vendor, false, CompanyName);
            wRecordRef.Get(Vendor.RecordId);
            Proveedor := GetMaestro('provider', Vendor."VAT Registration No.", 'vatRegisterNO', wRecordRef, Database::Vendor);
            if Proveedor = 'Error' Then begin
                CreaProveedor(Vendor, Vendor.RecordId, Database::Vendor);
                Proveedor := GetMaestro('provider', Vendor."VAT Registration No.", 'vatRegisterNO', wRecordRef, Database::Vendor);
            end;
            wRecordRef.Close();
        end;
        If Item.Get(ProductoServicio."Item No.") then begin
            wRecordRef.Open(Database::Item, false, CompanyName);
            wRecordRef.Get(Item.RecordId);
            Producto := GetMaestro('product', Item.Description, 'name', wRecordRef, Database::Item);
            if Producto = 'Error' Then begin
                CreaProducto(Item, Item.RecordId, Database::Item);
                Producto := GetMaestro('product', Item.Description, 'name', wRecordRef, Database::Item);
            end;
            wRecordRef.Close();
        end;
        JsonFormater.WriteStartObject('');
        JsonFormater.WriteStringProperty('name', ProductoServicio.Description);
        if Proveedor <> '' Then
            JsonFormater.WriteStringProperty('provider', Proveedor);
        if Client <> '' then
            JsonFormater.WriteStringProperty('client', Client);
        JsonFormater.WriteStringProperty('componentWarranty', Format(ProductoServicio."Warranty % (Parts)"));
        JsonFormater.WriteStringProperty('componentWork', Format(ProductoServicio."Warranty % (Labor)"));
        JsonFormater.WriteStringProperty('endDate', Format(ProductoServicio."Warranty Ending Date (Parts)", 0, '<Year4>-<Month,2>-<Day,2>T00:00:00'));
        if Producto <> '' Then
            JsonFormater.WriteStringProperty('product', Producto);
        JsonFormater.WriteStringProperty('startDate', Format(ProductoServicio."Warranty Starting Date (Parts)", 0, '<Year4>-<Month,2>-<Day,2>T00:00:00'));
        JsonFormater.WriteEndObject();
        Json := JsonFormater.GetJSonAsText();
        Json := RestApi.RestApiToken('/service', RequestType::post, jSon);
        JSONMgt.InitializeObject(Json);
        JSONMgt.ReadProperties();
        WHILE JSONMgt.GetNextProperty(Name, Value1) DO BEGIN
            CASE Name OF
                '_id':
                    begin
                        InsertLink(tRecordId, Tabla, Value1);
                    end;
            end;
        end;
    end;

    procedure GetPartes()
    var
        RestApi: Codeunit Restapi;
        Token: Text;
        GenSetup: Record "General Ledger Setup";
        RequestType: Option Get,patch,put,post,delete;
        Pregunta: Text;
        JSONMgt: Codeunit "JSON Management";
        JSONMgt2: Codeunit "JSON Management";
        JsonObjt: Codeunit "Json Text Reader/Writer";
        Name: Text;
        Value1: Text;
        Name2: Text;
        Value2: Text;
        i: Integer;
        a: Integer;
        Json: Text;
        Id: Text;
        PartesTrabajot: Record "Time Sheet Header" temporary;
        Lineast: Record "Time Sheet Line" temporary;
        PartesTrabajo: Record "Time Sheet Header";
        Lineas: Record "Time Sheet Line";
        Customer: Record Customer;
        Tareas: Record "User Task";
        ProductoServicio: Record Resource;
        ProductooRecurso: Text;
        Recurso: Record Resource;
        Producto: Record Item;
        Unidades: Record "Unit of Measure";
        d: Integer;
        e: Integer;
        wRecorId: RecordId;
        wRecordRef: recordref;
    begin
        GenSetup.Get();
        RestApi.RecuperarToken(GenSetup."Url Tareas", GenSetup."Usuario Tareas", GenSetup."Password Tareas", GenSetup.Token);
        Token := GenSetup.Token;
        Json := RestApi.RestApiToken('/workorder', RequestType::Get, '');
        JSONMgt.InitializeCollection(Json);
        a := JSONMgt.GetCollectionCount;
        If a = 0 Then exit;
        WHILE i < a DO BEGIN
            JSONMgt.GetObjectFromCollectionByIndex(Json, i);
            JSONMgt.InitializeObject(Json);
            IF Json <> '' THEN BEGIN
                JSONMgt.InitializeObject(Json);
                JSONMgt.ReadProperties();
                PartesTrabajot.Init();
                WHILE JSONMgt.GetNextProperty(Name, Value1) DO BEGIN
                    CASE Name OF
                        '_id':
                            PartesTrabajot."No." := Value1;

                        'client':
                            begin
                                //"61784d02a6d775001ad55f32",
                                if Value1 <> '' then begin
                                    If GetNombreMaestro('client', Value1, 'name', Database::Customer, Customer.FieldNo(Name), wRecorId) Then begin
                                        wRecordRef := wRecorId.GetRecord();
                                        PartesTrabajot.Validate(Cliente, wRecordRef.Field(Customer.FieldNo("No.")).Value);
                                        wRecordRef.Close();
                                    end;
                                end;
                            end;
                        'task':
                            begin
                                // "6178544da6d775001ad5600d",
                                Tareas.SetRange(Id_Tarea, Value1);
                                if not Tareas.FindFirst() then begin
                                    Tareas.Reset();
                                    Tareas.FindFirst();
                                end;
                                PartesTrabajot.Validate(Tarea, tareas.ID);
                            end;
                        'service':
                            begin
                                // "617851eda6d775001ad55fc7",
                                Clear(wRecorId);
                                If GetNombreMaestro('service', Value1, 'name', Database::Resource, ProductoServicio.FieldNo(Name), wRecorId) Then begin
                                    wRecordRef := wRecorId.GetRecord();
                                    PartesTrabajot.Validate("Producto Servicio", wRecordRef.Field(ProductoServicio.FieldNo("No.")).Value);
                                    wRecordRef.Close();
                                end;
                            end;
                        //'project': "617863aba6d775001ad561dc",
                        'startDate':
                            If Evaluate(PartesTrabajot."Fecha Inicio", Value1) then
                                ;// "2021-10-26T20:23:42.491Z",
                        'endDate':
                            If Evaluate(PartesTrabajot."Fecha fin", Value1) then
                                ;//"2021-10-27T20:23:49.939Z
                        'lines':
                            begin
                                JSONMgt2.InitializeCollection(Value1);
                                d := JSONMgt2.GetCollectionCount;
                                e := 0;
                                WHILE e < d DO BEGIN
                                    JSONMgt2.GetObjectFromCollectionByIndex(Value1, e);
                                    JSONMgt2.InitializeObject(Value1);
                                    JSONMgt2.ReadProperties();
                                    Lineast.Init();
                                    Lineast.No := 'temp';
                                    WHILE JSONMgt2.GetNextProperty(Name2, Value2) DO BEGIN
                                        CASE Name2 OF
                                            'resourceOrProduct':
                                                begin
                                                    //"61786418a6d775001ad561e6",
                                                    Clear(wRecorId);
                                                    If GetNombreMaestro('product', Value2, 'name', Database::Item, Producto.FieldNo(Description), wRecorId) then begin
                                                        wRecordRef := wRecorId.GetRecord();
                                                        Producto.SetRange(Description, ProductooRecurso);
                                                        Lineast.Tipo := Lineast.Tipo::Producto;
                                                        Lineast.Validate("Time Sheet No.", wRecordRef.Field(Producto.FieldNo("No.")).Value);
                                                        wRecordRef.Close();

                                                    end else begin
                                                        Clear(wRecorId);
                                                        If GetNombreMaestro('resource', Value2, 'name', Database::Resource, Recurso.FieldNo(Name), wRecorId) then begin
                                                            wRecordRef := wRecorId.GetRecord();
                                                            Lineast.Tipo := Lineast.Tipo::Recurso;
                                                            Lineast.Validate("Time Sheet No.", wRecordRef.Field(Recurso.FieldNo("No.")).Value);
                                                            wRecordRef.Close();
                                                        end else begin
                                                            Lineast.Tipo := Lineast.Tipo::" ";
                                                            Lineast.No := '';
                                                        end;
                                                    end;
                                                end;
                                            'unit':
                                                begin
                                                    If Unidades.Get(Value2) then Lineast.Unidad := Value2;
                                                end;
                                            'quantity':
                                                if Evaluate(Lineast.Cantidad, Value2) then
                                                    ;
                                            'description':
                                                Lineast.Descripcion := Value2; //"Piza repuesto A-120"
                                        end;
                                    end;
                                    Lineast."Line No." := e;
                                    Lineast.Insert(true);
                                    e += 1;
                                end;
                            end;
                    end;
                end;
                i += 1;
                if not PartesTrabajo.Get(PartesTrabajot."No.") Then begin
                    PartesTrabajo := PartesTrabajot;
                    PartesTrabajo.Insert(true);
                    if Lineast.FindFirst() then
                        repeat
                            Lineas := Lineast;
                            Lineas.No := PartesTrabajo."No.";
                            Lineas.Insert(true);
                        until Lineast.Next() = 0;

                end;
                Lineast.DeleteAll();
            end;
        end;

    end;

    procedure InsertLink(wRecordId: RecordId; Tabla: Integer; Id: Text): Boolean
    var
        IdLink: Integer;
        Link: Record "Data Migration Error";
    begin
        Link.SetRange("Migration Type", Id);
        Link.SetRange("Destination Table ID", Tabla);
        //Link.Reset();
        if Link.FindFirst() then exit(true);
        If Link.FindLast() Then IdLink := Link.Id;
        Link.Init();
        Link.Id := IdLink + 1;
        Link."Source Staging Table Record ID" := wRecordId;
        Link."Destination Table ID" := Tabla;
        Link."Migration Type" := Id;
        If Link.Insert() then;
        exit(true);
    end;
}