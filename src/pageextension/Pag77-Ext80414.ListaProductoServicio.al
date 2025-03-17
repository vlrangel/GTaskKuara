pageextension 80414 "Lista Producto Servicio" extends "Resource List" //77
{

    layout
    {
        addafter(Name)
        {
            field("Item No."; Rec."Item No.")
            {
                Caption = 'Producto';
                ApplicationArea = All;
                ToolTip = 'Specifies the item number linked to the service item.';
            }
            field("Item Description"; Rec."Item Description")
            {
                Caption = 'Descripción Producto';
                ApplicationArea = All;
                ToolTip = 'Specifies the description of the item that the service item is linked to.';
            }
            field("Serial No."; Rec."Serial No.")
            {
                Caption = 'Nº Serie';
                ApplicationArea = ItemTracking;
                ToolTip = 'Specifies the serial number of this item.';
            }
            field("Customer No."; Rec."Customer No.")
            {
                Caption = 'Cliente';
                ApplicationArea = All;
                ToolTip = 'Specifies the number of the customer who owns this item.';
            }
            field("Ship-to Code"; Rec."Ship-to Code")
            {
                Caption = 'Envío a Código';
                ApplicationArea = All;
                ToolTip = 'Specifies a code for an alternate shipment address if you want to ship to another address than the one that has been entered automatically. This field is also used in case of drop shipment.';
            }
            field("Warranty Starting Date (Parts)"; Rec."Warranty Starting Date (Parts)")
            {
                Caption = 'Fecha inicio garantía componentes';
                ApplicationArea = All;
                ToolTip = 'Specifies the starting date of the spare parts warranty for this item.';
            }
            field("Warranty Ending Date (Parts)"; Rec."Warranty Ending Date (Parts)")
            {
                Caption = 'Fecha fin garantía componentes';
                ApplicationArea = All;
                ToolTip = 'Specifies the ending date of the spare parts warranty for this item.';
            }
            field("Warranty Starting Date (Labor)"; Rec."Warranty Starting Date (Labor)")
            {
                Caption = 'Fecha inicio garantía mano de obra';

                ApplicationArea = All;
                ToolTip = 'Specifies the starting date of the labor warranty for this item.';
            }
            field("Warranty Ending Date (Labor)"; Rec."Warranty Ending Date (Labor)")
            {
                Caption = 'Fecha fin garantía mano de obra';
                ApplicationArea = All;
                ToolTip = 'Specifies the ending date of the labor warranty for this item.';
            }
            field("Search Description"; Rec."Search Description")
            {
                Caption = 'Alias';
                ApplicationArea = All;
                ToolTip = 'Specifies an alternate description to search for the service item.';
            }
            field(Status; Rec.Status)
            {
                Caption = 'Estado';
                ApplicationArea = All;
                ToolTip = 'Specifies the status of the service item.';
                Visible = false;
            }
            field(Priority; Rec.Priority)
            {
                Caption = 'Prioridad';
                ApplicationArea = All;
                ToolTip = 'Specifies the service priority for this item.';
                Visible = false;
            }
            field("Last Service Date"; Rec."Last Service Date")
            {
                Caption = 'Última fecha servicio';
                ApplicationArea = All;
                ToolTip = 'Specifies the date of the last service on this item.';
                Visible = false;
            }
            // field("Service Contracts"; "Service Contracts")
            // {
            //     ApplicationArea=All;
            //     ToolTip = 'Specifies that this service item is associated with one or more service contracts/quotes.';
            //     Visible = false;
            // }
            field("Vendor No."; Rec."Vendor No.")
            {
                Caption = 'Proveedor';
                ApplicationArea = All;
                ToolTip = 'Specifies the number of the vendor for this item.';
                Visible = false;
            }
            field("Vendor Name"; Rec."Vendor Name")
            {
                Caption = 'Nombre proveedor';
                ApplicationArea = All;
                ToolTip = 'Specifies the vendor name for this item.';
                Visible = false;
            }
            field("Installation Date"; Rec."Installation Date")
            {
                Caption = 'Fecha Instalación';
                ApplicationArea = All;
                ToolTip = 'Specifies the date when this item was installed at the customer''s site.';
                Visible = false;
            }
        }
    }




    var
        ResourceSkill: Record "Resource Skill";
        SkilledResourceList: Page "Skilled Resource List";
}

