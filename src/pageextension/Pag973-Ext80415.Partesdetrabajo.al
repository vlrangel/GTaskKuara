pageextension 80415 "Partes de trabajo" extends "Time Sheet Card" //973
{

    Caption = 'Partes de trabajo';

    layout
    {

        addafter("No.")
        {
            // field("No."; Header."No.")
            // {
            //     ApplicationArea = All;
            // }
            field("Descripcion tarea"; Tareas.Title)
            {
                Editable = false;
                ApplicationArea = All;
            }
            field("Descripcion trabajo"; Tareas.GetDescription())
            {
                Editable = false;
                ApplicationArea = All;
            }
            field(Cliente; Client)
            {

                ToolTip = 'Specifies the value of the Cliente field.';
                ApplicationArea = All;
                trigger OnValidate()
                begin
                    Header.Validate(Cliente, Client);
                end;

                trigger OnLookup(var Text: Text): Boolean
                var
                    Customer: Record Customer;
                begin
                    If Page.RunModal(0, Customer) = Action::LookupOK then begin
                        Header.Validate(Cliente, Customer."No.");
                        Header.Modify();
                    end;
                end;
            }
            field("Nombre Cliente"; Header."Nombre Cliente")
            {
                ToolTip = 'Specifies the value of the Nombre Cliente field.';
                ApplicationArea = All;
            }
            field("Dirección"; Header."Dirección")
            {
                ToolTip = 'Specifies the value of the Dirección field.';
                ApplicationArea = All;
            }
            field("Cód. Dirección Envio"; Dire)
            {
                ToolTip = 'Specifies the value of the Cód. Dirección Envio field.';
                ApplicationArea = All;
                trigger OnValidate()
                begin
                    Header.Validate("Cód. Dirección Envio", Dire);
                end;

                trigger OnLookup(var Text: Text): Boolean
                var
                    Direcion: Record 222;
                begin
                    Direcion.SetRange("Customer No.", Client);
                    if Page.RunModal(0, Direcion) = Action::LookupOK then begin
                        Header.Validate("Cód. Dirección Envio", Dire);
                        Header.Modify()
                    end;
                end;
            }
            field("Nombre Dirección Envio"; Dir.Name)
            {
                Editable = false;
                ToolTip = 'Specifies the value of the Cód. Dirección Envio field.';
                ApplicationArea = All;
            }
            field("Dirección Envio"; Header."Dirección Envio")
            {
                ToolTip = 'Specifies the value of the Dirección Envio field.';
                ApplicationArea = All;

            }
            field("Fecha Inicio"; Header."Fecha Inicio")
            {
                ToolTip = 'Specifies the value of the Fecha Inicio field.';
                ApplicationArea = All;
            }
            field("Fecha Fin"; Header."Fecha Fin")
            {
                ToolTip = 'Specifies the value of the Fecha Fin field.';
                ApplicationArea = All;
            }


            field(Proyecto; Header.Proyecto)
            {
                ToolTip = 'Specifies the value of the Proyecto field.';
                ApplicationArea = All;
            }
        }
        // part(Lineas; "Lineas parte de trabajo")
        // {
        //     ApplicationArea = All;
        //     SubPageLink = "Time Sheet No." = field("No.");
        // }
    }

    var
        Tareas: Record "User Task";
        Header: Record "Time Sheet Header";
        Dir: Record 222;
        Client: Code[20];
        Dire: Code[20];

    trigger OnAfterGetRecord()
    begin
        Header.Get(Rec."No.");
        Dire := Header."Cód. Dirección Envio";
        Client := Header.Cliente;
        If not Tareas.Get(Header.Tarea) then Tareas.Init();
        if not Dir.Get(Header.Cliente, Header."Cód. Dirección Envio") then Dir.Init();
    end;
}
pageextension 80416 "Lista Partes de trabajo" extends "Time Sheet List"
{


    Caption = 'Partes de trabajo';
    layout
    {
        addafter("No.")
        {
            field("Descripcion tarea"; Tareas.Title)
            {
                Editable = false;
                ApplicationArea = All;
            }
            field("Descripcion trabajo"; Tareas.GetDescription())
            {
                Editable = false;
                ApplicationArea = All;
            }
            field("Producto Servicio"; Rec."Producto Servicio")
            {
                ApplicationArea = All;
            }
            field("Descripción producto"; Rec."Descripción producto")
            {
                ApplicationArea = all;
            }
            field(Cliente; Rec.Cliente)
            {
                ToolTip = 'Specifies the value of the Cliente field.';
                ApplicationArea = All;
            }
            field("Nombre Cliente"; Rec."Nombre Cliente")
            {
                ToolTip = 'Specifies the value of the Nombre Cliente field.';
                ApplicationArea = All;
            }
            field("Dirección"; Rec."Dirección")
            {
                ToolTip = 'Specifies the value of the Dirección field.';
                ApplicationArea = All;
            }
            field("Cód. Dirección Envio"; Rec."Cód. Dirección Envio")
            {
                ToolTip = 'Specifies the value of the Cód. Dirección Envio field.';
                ApplicationArea = All;
            }
            field("Nombre Dirección Envio"; Dir.Name)
            {
                Editable = false;
                ToolTip = 'Specifies the value of the Cód. Dirección Envio field.';
                ApplicationArea = All;
            }
            field("Dirección Envio"; Rec."Dirección Envio")
            {
                ToolTip = 'Specifies the value of the Dirección Envio field.';
                ApplicationArea = All;
            }
            field("Fecha Inicio"; Rec."Fecha Inicio")
            {
                ToolTip = 'Specifies the value of the Fecha Inicio field.';
                ApplicationArea = All;
            }
            field("Fecha Fin"; Rec."Fecha Fin")
            {
                ToolTip = 'Specifies the value of the Fecha Fin field.';
                ApplicationArea = All;
            }


            field(Proyecto; Rec.Proyecto)
            {
                ToolTip = 'Specifies the value of the Proyecto field.';
                ApplicationArea = All;
            }
        }
    }


    actions
    {
        addafter("&Time Sheet")
        {
            action("Impotar")
            {
                ApplicationArea = All;
                Image = Import;
                trigger OnAction()
                var
                    Gtask: Codeunit GTask;
                begin
                    Gtask.GetPartes();
                end;
            }
        }
    }

    var
        Tareas: Record "User Task";
        Dir: Record 222;

    trigger OnAfterGetRecord()
    begin
        If not Tareas.Get(Rec.Tarea) then Tareas.Init();
        if not Dir.Get(Rec.Cliente, Rec."Cód. Dirección Envio") then Dir.Init();
    end;
}
