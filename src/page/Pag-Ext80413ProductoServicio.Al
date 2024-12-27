pageextension 80413 "Ficha Producto Servicio" extends "Resource Card"
{
    Caption = 'Ficha Producto Servicio';
    PromotedActionCategories = 'Nuevo,Proceso,Informes,Navegar,Producto';
    layout
    {

        addafter(Name)
        {
            group(Prod)
            {
                Visible = Machine;
                Caption = '';
                field("Código Producto"; Rec."Item No.")
                {
                    Caption = 'Producto';
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the item number linked to the service item.';

                    trigger OnValidate()
                    begin
                        Rec.CalcFields("Item Description");
                    end;
                }
                field("Descripción Producto"; Rec."Item Description")
                {
                    Caption = 'Descripción Producto';
                    ApplicationArea = All;
                    DrillDown = false;
                    ToolTip = 'Specifies the description of the item that the service item is linked to.';
                }

                field("Preferred Resource"; Rec."Preferred Resource")
                {
                    Importance = Promoted;
                    Caption = 'Recurso preferido';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the resource that the customer prefers for servicing of the item.';
                }
            }


        }
        addbefore(Invoicing)
        {
            group(Customer)
            {
                Visible = Machine;
                Caption = 'Cliente';
                field("Customer No."; Rec."Customer No.")
                {
                    Caption = 'Código Cliente';
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the number of the customer who owns this item.';

                    trigger OnValidate()
                    begin
                        // Rec.CalcFields(Name, "Name 2", Address, "Address 2", "Post Code",
                        //   City, Contact, "Phone No.", County, "Country/Region Code");
                        CustomerNoOnAfterValidate();
                    end;
                }
                group("Sell-to")
                {
                    Caption = 'Venta-a';
                    field(Nombre; Rec."Nombre Cilente")
                    {
                        Caption = 'Nombre';
                        ApplicationArea = All;
                        DrillDown = false;
                        Importance = Promoted;
                        ToolTip = 'Specifies the name of the customer who owns this item.';
                    }
                    field(Direccion; Rec.Address)
                    {
                        Caption = 'Dirección';
                        ApplicationArea = All;
                        DrillDown = false;
                        QuickEntry = false;
                        ToolTip = 'Specifies the address of the customer who owns this item.';
                    }
                    field("Direccion 2"; Rec."Address 2")
                    {
                        Caption = 'Dirección 2';
                        ApplicationArea = All;
                        DrillDown = false;
                        QuickEntry = false;
                        ToolTip = 'Specifies additional address information.';
                    }
                    field(Poblacion; Rec.City)
                    {
                        Caption = 'Población';
                        ApplicationArea = All;
                        DrillDown = false;
                        QuickEntry = false;
                        ToolTip = 'Specifies the city of the customer address.';
                    }
                    group(Control23)
                    {
                        ShowCaption = false;
                        Visible = IsSellToCountyVisible;
                    }
                    field(Provincia; Rec.County)
                    {
                        Caption = 'Provincia';
                        ApplicationArea = All;
                        QuickEntry = false;
                    }
                    field("Cod. Postal"; Rec."Post Code")
                    {
                        Caption = 'Código Postal';
                        ApplicationArea = All;
                        DrillDown = false;
                        QuickEntry = false;
                        ToolTip = 'Specifies the postal code.';
                    }
                    field("Pais"; Rec."Country/Region Code")
                    {
                        Caption = 'País';
                        ApplicationArea = All;
                        QuickEntry = false;
                        ToolTip = 'Specifies the country/region of the address.';

                        trigger OnValidate()
                        begin
                            IsSellToCountyVisible := FormatAddress.UseCounty(Rec."Country/Region Code");
                        end;
                    }
                    field(Contact; Rec.Contact)
                    {
                        Caption = 'Contacto';
                        ApplicationArea = All;
                        DrillDown = false;
                        Importance = Promoted;
                        ToolTip = 'Specifies the name of the person you regularly contact when you do business with the customer who owns this item.';
                    }
                }
                field("Phone No."; Rec."Phone No.")
                {
                    Caption = 'Teléfono';
                    ApplicationArea = All;
                    DrillDown = false;
                    ToolTip = 'Specifies the customer phone number.';
                }
                field("Location of Service Item"; Rec."Location of Service Item")
                {
                    Caption = 'Ubicación producto servicio';
                    ApplicationArea = Location;
                    Importance = Promoted;
                    ToolTip = 'Specifies the code of the location of this item.';
                }
            }
            group(Shipping)
            {
                Visible = Machine;
                Caption = 'Envío';
                field("Ship-to Code"; Rec."Ship-to Code")
                {
                    Caption = 'Código dirección envío';
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies a code for an alternate shipment address if you want to ship to another address than the one that has been entered automatically. This field is also used in case of drop shipment.';

                    trigger OnValidate()
                    begin
                        UpdateShipToCode;
                    end;
                }
                group("Ship-to")
                {
                    Caption = 'Envio-a';
                    field("Ship-to Name"; Rec."Ship-to Name")
                    {
                        ApplicationArea = All;
                        Caption = 'Nnombre';
                        DrillDown = false;
                        ToolTip = 'Specifies the name of the customer at the address that the items are shipped to.';
                    }
                    field("Ship-to Address"; Rec."Ship-to Address")
                    {
                        ApplicationArea = All;
                        Caption = 'Dirección';
                        DrillDown = false;
                        QuickEntry = false;
                        ToolTip = 'Specifies the address that the items are shipped to.';
                    }
                    field("Ship-to Address 2"; Rec."Ship-to Address 2")
                    {
                        ApplicationArea = All;
                        Caption = 'Dirección 2';
                        DrillDown = false;
                        QuickEntry = false;
                        ToolTip = 'Specifies an additional part of the ship-to address, in case it is a long address.';
                    }
                    field("Ship-to City"; Rec."Ship-to City")
                    {
                        ApplicationArea = All;
                        Caption = 'Población';
                        DrillDown = false;
                        QuickEntry = false;
                        ToolTip = 'Specifies the city of the address that the items are shipped to.';
                    }
                    group(Control35)
                    {
                        ShowCaption = false;
                        Visible = IsShipToCountyVisible;
                    }
                    field("Ship-to County"; Rec."Ship-to County")
                    {
                        ApplicationArea = All;
                        Caption = 'Provincia';
                        QuickEntry = false;
                    }
                    field("Ship-to Post Code"; Rec."Ship-to Post Code")
                    {
                        ApplicationArea = All;
                        Caption = 'Código Postal';
                        DrillDown = false;
                        Importance = Promoted;
                        QuickEntry = false;
                        ToolTip = 'Specifies the postal code of the address that the items are shipped to.';
                    }
                    field("Ship-to Country/Region Code"; Rec."Ship-to Country/Region Code")
                    {
                        ApplicationArea = All;
                        Caption = 'País';
                        QuickEntry = false;

                        trigger OnValidate()
                        begin
                            IsShipToCountyVisible := FormatAddress.UseCounty(Rec."Ship-to Country/Region Code");
                        end;
                    }
                    field("Ship-to Contact"; Rec."Ship-to Contact")
                    {
                        ApplicationArea = All;
                        Caption = 'Contacto';
                        DrillDown = false;
                        Importance = Promoted;
                        ToolTip = 'Specifies the name of the contact person at the address that the items are shipped to.';
                    }
                }
                field("Ship-to Phone No."; Rec."Ship-to Phone No.")
                {
                    Caption = 'Teléfono';
                    ApplicationArea = All;
                    DrillDown = false;
                    ToolTip = 'Specifies the phone number at address that the items are shipped to.';
                }
            }
            group(Contract)
            {
                Visible = Machine;
                Caption = 'Contrato';
                field("Default Contract Cost"; Rec."Default Contract Cost")
                {
                    Caption = 'Coste por defedcto';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default contract cost of a service item that later will be included in a service contract or contract quote.';
                }
                field("Default Contract Value"; Rec."Default Contract Value")
                {
                    Caption = 'Precio por defecto';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default contract value of an item that later will be included in a service contract or contract quote.';
                }
                field("Default Contract Discount %"; Rec."Default Contract Discount %")
                {
                    Caption = '% Descuento por defecto';
                    ApplicationArea = All;
                    ToolTip = 'Specifies a default contract discount percentage for an item, if this item will be part of a service contract.';
                }
                field("Service Contracts"; Rec."Service Contracts")
                {
                    Caption = 'Contratos';
                    ApplicationArea = All;
                    ToolTip = 'Specifies that this service item is associated with one or more service contracts/quotes.';
                }
            }

        }
        addbefore(Invoicing)
        {
            group(Producto)
            {
                Visible = Machine;
                field("Item No."; Rec."Item No.")
                {
                    Caption = 'Producto';
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the item number linked to the service item.';

                    trigger OnValidate()
                    begin
                        Rec.CalcFields("Item Description");
                    end;
                }
                field("Item Description"; Rec."Item Description")
                {
                    Caption = 'Descripción Producto';
                    ApplicationArea = All;
                    DrillDown = false;
                    ToolTip = 'Specifies the description of the item that the service item is linked to.';
                }

                field("Service Price Group Code"; Rec."Service Price Group Code")
                {
                    Caption = 'Grupo Precio Servicio';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code of the Service Price Group associated with this item.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    Caption = 'Código Variante';
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant of the item on the line.';
                }
                field("Serial No."; Rec."Serial No.")
                {
                    Caption = 'Nº Serie';
                    ApplicationArea = ItemTracking;
                    AssistEdit = true;
                    ToolTip = 'Specifies the serial number of this item.';

                    trigger OnAssistEdit()
                    var
                        ItemLedgerEntry: Record "Item Ledger Entry";
                    begin
                        Clear(ItemLedgerEntry);
                        ItemLedgerEntry.FilterGroup(2);
                        ItemLedgerEntry.SetRange("Item No.", Rec."Item No.");
                        if Rec."Variant Code" <> '' then
                            ItemLedgerEntry.SetRange("Variant Code", Rec."Variant Code");
                        ItemLedgerEntry.SetFilter("Serial No.", '<>%1', '');
                        ItemLedgerEntry.FilterGroup(0);

                        if PAGE.RunModal(0, ItemLedgerEntry) = ACTION::LookupOK then
                            Rec.Validate("Serial No.", ItemLedgerEntry."Serial No.");
                    end;
                }
                field(Status; Rec.Status)
                {
                    Caption = 'Estado';
                    ApplicationArea = All;
                    Importance = Promoted;
                    ToolTip = 'Specifies the status of the service item.';
                }
                field("Service Item Components"; Rec."Service Item Components")
                {
                    Caption = 'Componentes';
                    ApplicationArea = All;
                    ToolTip = 'Specifies that there is a component for this service item.';
                }
                field("Search Description"; Rec."Search Description")
                {
                    Caption = 'Alias';
                    ApplicationArea = All;
                    ToolTip = 'Specifies an alternate description to search for the service item.';
                }
                field("Response Time (Hours)"; Rec."Response Time (Hours)")
                {
                    Caption = 'Tiempo de respuesta (Horas)';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the estimated number of hours this item requires before service on it should be started.';
                }
                field(Priority; Rec.Priority)
                {
                    Caption = 'Prioridad';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the service priority for this item.';
                }
                field("Last Service Date"; Rec."Last Service Date")
                {
                    Caption = 'Último fecha servicio';
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the date of the last service on this item.';
                }
                field("Warranty Starting Date (Parts)"; Rec."Warranty Starting Date (Parts)")
                {
                    Caption = 'Inicio garantía piezas';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the starting date of the spare parts warranty for this item.';
                }
                field("Warranty Ending Date (Parts)"; Rec."Warranty Ending Date (Parts)")
                {
                    Caption = 'Fin garantía piezas';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ending date of the spare parts warranty for this item.';
                }
                field("Warranty % (Parts)"; Rec."Warranty % (Parts)")
                {
                    Caption = '% garantía piezas';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the percentage of spare parts costs covered by the warranty for the item.';
                }
                field("Warranty Starting Date (Labor)"; Rec."Warranty Starting Date (Labor)")
                {
                    Caption = 'Inicio Garantía mano de obra';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the starting date of the labor warranty for this item.';
                }
                field("Warranty Ending Date (Labor)"; Rec."Warranty Ending Date (Labor)")
                {
                    Caption = 'Fin garantía mano de obra';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ending date of the labor warranty for this item.';
                }
                field("Warranty % (Labor)"; Rec."Warranty % (Labor)")
                {
                    Caption = '% garantía mano de obra';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the percentage of labor costs covered by the warranty for this item.';
                }

            }
            group(Vendor)
            {
                Visible = Machine;
                Caption = 'Proveedor';
                field("Vendor No."; Rec."Vendor No.")
                {
                    Caption = 'Código';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the vendor for this item.';

                    trigger OnValidate()
                    begin
                        Rec.CalcFields("Vendor Name");
                    end;
                }
                field("Vendor Name"; Rec."Vendor Name")
                {
                    Caption = 'Nombre';
                    ApplicationArea = All;
                    DrillDown = false;
                    ToolTip = 'Specifies the vendor name for this item.';
                }
                field("Vendor Item No."; Rec."Vendor Item No.")
                {
                    Caption = 'Producto Proveedor';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number that the vendor uses for this item.';
                }
                field("Vendor Item Name"; Rec."Vendor Item Name")
                {
                    Caption = 'Nombre producto proveedor';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name assigned to this item by the vendor.';
                }
            }
        }

        addafter(Invoicing)
        {
            group(Detail)
            {
                Visible = Machine;
                Caption = 'Detalle';
                field("Sales Unit Cost"; Rec."Sales Unit Cost")
                {
                    Caption = 'Precio de compra';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit cost of this item when it was sold.';
                }
                field("Sales Unit Price"; Rec."Sales Unit Price")
                {
                    Caption = 'Precio de venta';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit price of this item when it was sold.';
                }
                field("Sales Date"; Rec."Sales Date")
                {
                    Caption = 'Fecha Venta';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when this item was sold.';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    Caption = 'Unidad de medida';
                    ApplicationArea = All;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                field("Installation Date"; Rec."Installation Date")
                {
                    Caption = 'Fecha Instalación';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when this item was installed at the customer''s site.';
                }
            }
        }
        addbefore(Control39)
        {
            part(Control1900316107; "Customer Details FactBox")
            {
                Visible = Machine;
                ApplicationArea = All;
                SubPageLink = "No." = FIELD("Customer No."),
                              "Date Filter" = FIELD("Date Filter");

            }

        }
    }

    actions
    {
        addafter("&Resource")
        {
            action("Crear Tarea")
            {
                Visible = Machine;
                Image = Task;
                ApplicationArea = All;
                Promoted = true;
                trigger OnAction()
                var
                    Tareas: Record "User Task";
                    Gtask: Codeunit GTask;
                    Id: Integer;

                begin
                    Tareas.Init();
                    Tareas.Title := Rec.Name;
                    Tareas."Created DateTime" := CurrentDateTime;
                    Tareas."Object Type" := Tareas."Object Type"::Page;
                    Tareas."Object ID" := 80111;
                    Tareas.Insert(true);
                    Id := Tareas.ID;
                    Commit();
                    Page.RunModal(Page::"User Task Card", Tareas);
                    Commit();
                    Tareas.Get(Id);
                    Gtask.CrearTarea(Rec, Tareas);

                end;
            }
        }
    }

    var
        Machine: Boolean;

    trigger OnAfterGetRecord()
    begin
        Machine := rec.Type = rec.Type::Machine;
        UpdateShipToCode;

    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if Rec."Item No." = '' then
            if Rec.GetFilter("Item No.") <> '' then
                if Rec.GetRangeMin("Item No.") = Rec.GetRangeMax("Item No.") then
                    Rec."Item No." := Rec.GetRangeMin("Item No.");

        if Rec."Customer No." = '' then
            if Rec.GetFilter("Customer No.") <> '' then
                if Rec.GetRangeMin("Customer No.") = Rec.GetRangeMax("Customer No.") then
                    Rec."Customer No." := Rec.GetRangeMin("Customer No.");
    end;

    trigger OnOpenPage()
    begin
        IsSellToCountyVisible := FormatAddress.UseCounty(Rec."Country/Region Code");
        IsShipToCountyVisible := FormatAddress.UseCounty(Rec."Ship-to Country/Region Code");
    end;

    var
        ResourceSkill: Record "Resource Skill";
        FormatAddress: Codeunit "Format Address";
        SkilledResourceList: Page "Skilled Resource List";
        IsSellToCountyVisible: Boolean;
        IsShipToCountyVisible: Boolean;

    local procedure UpdateShipToCode()
    begin
        if Rec."Ship-to Code" = '' then begin
            Rec."Ship-to Name" := Rec.Name;
            Rec."Ship-to Address" := Rec.Address;
            Rec."Ship-to Address 2" := Rec."Address 2";
            Rec."Ship-to Post Code" := Rec."Post Code";
            Rec."Ship-to City" := Rec.City;
            Rec."Ship-to County" := Rec.County;
            Rec."Ship-to Phone No." := Rec."Phone No.";
            Rec."Ship-to Contact" := Rec.Contact;
        end else
            Rec.CalcFields(
              "Ship-to Name", "Ship-to Name 2", "Ship-to Address", "Ship-to Address 2", "Ship-to Post Code", "Ship-to City",
              "Ship-to County", "Ship-to Country/Region Code", "Ship-to Contact", "Ship-to Phone No.");
    end;

    local procedure CustomerNoOnAfterValidate()
    begin
        if Rec."Customer No." <> xRec."Customer No." then begin
            UpdateShipToCode;
        end;
    end;
}
pageextension 80412 SaerviceOrder extends "Service Order"
{
    layout
    {
        addafter("Contact No.")
        {
            field("Preferred Resource"; Rec."Preferred Resource")
            {
                ApplicationArea = All;
            }
        }
        addafter(Description)
        {
            group("Work Description")
            {
                Caption = 'Descripción Trabajo';
                field(WorkDescription; WorkDescription)
                {
                    ApplicationArea = Basic, Suite;
                    Importance = Additional;
                    MultiLine = true;
                    ShowCaption = false;
                    ToolTip = 'Specifies the products or service being offered.';

                    trigger OnValidate()
                    begin
                        Rec.SetWorkDescription(WorkDescription);
                    end;
                }
            }
        }

    }
    actions
    {
        addafter("F&unctions")
        {
            action("Crear Tarea")
            {
                Image = Task;
                ApplicationArea = All;
                Promoted = true;
                trigger OnAction()
                var
                    Gtask: Codeunit GTask;
                    Id: Integer;
                    PrductoServicio: Record "Service Item";
                    Lineas: Record "Service Line";
                begin
                    Lineas.SetRange("Document Type", Rec."Document Type");
                    Lineas.SetRange("Document No.", Rec."No.");
                    Lineas.FindFirst();
                    PrductoServicio.Get(Lineas."No.");
                    Gtask.CrearTareaServiceItem(PrductoServicio, Rec);

                end;
            }
        }
    }
    var
        WorkDescription: Text;

    trigger OnAfterGetRecord()
    begin
        WorkDescription := Rec.GetWorkDescription;
    end;
}

